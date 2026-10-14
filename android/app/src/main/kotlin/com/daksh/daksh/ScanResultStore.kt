package com.daksh.daksh

import android.content.Context
import android.graphics.Bitmap
import com.daksh.daksh.model.EnhancedImageResult
import com.daksh.daksh.model.ScanStep
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.RandomAccessFile
import java.util.concurrent.atomic.AtomicLong
import android.os.SystemClock
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext

/**
 * Turns native scan results into compressed JPG files for fast transmission.
 * Images are saved as high-quality JPGs (85% compression) to reduce file sizes
 * from ~500KB down to ~120KB per image (4x faster network uploads).
 */
object ScanResultStore {

    private const val DIR_NAME = "scans"
    private val fileSequence = AtomicLong(System.currentTimeMillis())

    // Avoid filename collisions when a finger is retaken while an old job is finishing.
    private fun uniqueStamp(): Long = fileSequence.updateAndGet { last ->
        maxOf(System.currentTimeMillis(), last + 1)
    }

    fun save(context: Context, result: EnhancedImageResult): JSONObject {
        val dir = scanDir(context)
        val stamp = uniqueStamp()
        val originalFile = File(dir, "${stamp}_${result.step.name}_original.jpg")
        val enhancedFile = File(dir, "${stamp}_${result.step.name}_enhanced.jpg")

        try {
            writeJpeg(result.originalBitmap, originalFile)
            writeJpeg(result.enhancedBitmap, enhancedFile)
            return toJson(result.step, result, originalFile, enhancedFile)
        } catch (e: Exception) {
            originalFile.delete()
            enhancedFile.delete()
            throw e
        }
    }

    /**
     * Same filenames, JPEG quality and response as save(), but independently
     * compresses the original and enhanced images on two worker threads.
     * This is used by group capture; the existing synchronous API is retained.
     */
    suspend fun saveParallel(context: Context, result: EnhancedImageResult): JSONObject = coroutineScope {
        val startedAt = SystemClock.elapsedRealtime()
        val dir = scanDir(context)
        val stamp = uniqueStamp()
        val originalFile = File(dir, "${stamp}_${result.step.name}_original.jpg")
        val enhancedFile = File(dir, "${stamp}_${result.step.name}_enhanced.jpg")
        try {
            val originalJob = async(Dispatchers.IO) { writeJpeg(result.originalBitmap, originalFile) }
            val enhancedJob = async(Dispatchers.IO) { writeJpeg(result.enhancedBitmap, enhancedFile) }
            originalJob.await()
            enhancedJob.await()
        } catch (e: Exception) {
            originalFile.delete()
            enhancedFile.delete()
            throw e
        }
        check(isValidJpeg(originalFile) && isValidJpeg(enhancedFile)) {
            "Incomplete JPEG persistence: ${result.step.name}"
        }
        Log.d("FP_PERF", "Group JPG save ${result.step.name}: ${SystemClock.elapsedRealtime() - startedAt}ms")
        toJson(result.step, result, originalFile, enhancedFile)
    }

    /** Fast header/trailer integrity check; does not recompress or alter the image. */
    fun isValidJpeg(file: File): Boolean {
        if (!file.isFile || file.length() < 4) return false
        return try {
            RandomAccessFile(file, "r").use { reader ->
                val first = reader.readUnsignedByte() == 0xFF && reader.readUnsignedByte() == 0xD8
                reader.seek(reader.length() - 2)
                val last = reader.readUnsignedByte() == 0xFF && reader.readUnsignedByte() == 0xD9
                first && last
            }
        } catch (_: IOException) { false }
    }

    /** Remove only the files uploaded by this scan, not other scans still in progress. */
    fun clearUploaded(results: Collection<EnhancedImageResult>): Int {
        var deleted = 0
        results.forEach { result ->
            listOf(result.rawPath, result.enhancedPath).filter { it.isNotBlank() }.forEach { path ->
                if (File(path).delete()) deleted++
            }
        }
        return deleted
    }

    fun stepToJson(step: ScanStep): JSONObject = JSONObject().apply {
        put("name", step.name)
        put("handSide", step.handSide.name)
        put("fingerName", step.fingerName)
        put("title", step.title)
        put("description", step.description)
        put("fingerCount", step.fingerCount)
    }

    /** Deletes every saved scan image. Call when the user logs out / finishes a report. */
    fun clear(context: Context): Int {
        val files = scanDir(context).listFiles() ?: return 0
        var deleted = 0
        for (f in files) if (f.delete()) deleted++
        return deleted
    }

    private fun toJson(
        step: ScanStep,
        r: EnhancedImageResult,
        original: File,
        enhanced: File
    ): JSONObject = JSONObject().apply {
        put("step", step.name)
        put("handSide", step.handSide.name)
        put("fingerName", step.fingerName)
        put("fingerCount", step.fingerCount)
        put("pattern", r.predictedPattern)
        put("description", r.patternDescription)
        put("confidence", r.confidenceScore.toDouble())
        put(
            "topPredictions",
            JSONArray().apply {
                r.topPredictions.forEach { (label, score) ->
                    put(JSONObject().put("label", label).put("score", score.toDouble()))
                }
            }
        )
        put("clarity", r.clarityScore)
        put("contrastBoost", r.contrastBoost)
        put("resolution", r.resolutionText)
        put("originalPath", original.absolutePath)
        put("enhancedPath", enhanced.absolutePath)
    }

    private fun scanDir(context: Context): File =
        File(context.cacheDir, DIR_NAME).apply { mkdirs() }

    /** Atomic per-file publication: no other operation sees a partially written JPG. */
    private fun writeJpeg(bitmap: Bitmap, file: File) {
        val temp = File(file.parentFile, file.name + ".writing")
        val maxDim = 1000
        val targetBmp = if (bitmap.width > maxDim || bitmap.height > maxDim) {
            val scale = maxDim.toFloat() / maxOf(bitmap.width, bitmap.height)
            Bitmap.createScaledBitmap(
                bitmap,
                (bitmap.width * scale).toInt().coerceAtLeast(1),
                (bitmap.height * scale).toInt().coerceAtLeast(1),
                true
            )
        } else {
            bitmap
        }
        try {
            FileOutputStream(temp).use { out ->
                // Buffered writes reduce small disk writes without modifying JPEG bytes.
                val buffered = BufferedOutputStream(out, 64 * 1024)
                if (!targetBmp.compress(Bitmap.CompressFormat.JPEG, 82, buffered)) {
                    throw IOException("JPEG encoding failed: ${file.name}")
                }
                buffered.flush()
                // Keep durability: publish only after all bytes are flushed to disk.
                out.fd.sync()
            }
            if (!isValidJpeg(temp)) throw IOException("JPEG is invalid: ${file.name}")
            if (!temp.renameTo(file)) throw IOException("Could not publish JPEG: ${file.name}")
            if (!isValidJpeg(file)) throw IOException("Published JPEG is invalid: ${file.name}")
        } catch (e: Exception) {
            temp.delete()
            file.delete()
            throw e
        } finally {
            if (targetBmp !== bitmap) targetBmp.recycle()
        }
    }
}
