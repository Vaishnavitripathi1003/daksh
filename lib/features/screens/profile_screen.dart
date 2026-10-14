import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/enums/subscription_level.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/user_models.dart';
import '../../shared/widgets/add_family_member_dialog.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Profile Screen fetching and binding SQLite Admin & Candidate Data.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dailyRemindersEnabled = true;
  String _adminName = 'Aarav Mahipal';
  String _adminEmail = 'aarav.student@daksh.edu';
  String _adminMobile = '+91 9815997176';
  SubscriptionLevel _subscriptionLevel = SubscriptionLevel.level1;
  List<User> _candidateMembers = [];

  @override
  void initState() {
    super.initState();
    _loadAdminProfileData();
  }

  Future<void> _loadAdminProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);

      final sub = userPref.getSubscription();
      final sqliteAdmin = await DatabaseHelper.instance.getAdminData();
      final sqliteCandidates =
          await DatabaseHelper.instance.getCandidateMembers();

      if (mounted) {
        setState(() {
          _subscriptionLevel = sub;
          if (sqliteAdmin != null) {
            final fName = sqliteAdmin.firstName ?? '';
            final lName = sqliteAdmin.lastName ?? '';
            final fullName = '$fName $lName'.trim();
            if (fullName.isNotEmpty) {
              _adminName = fullName;
            }
            if (sqliteAdmin.email != null && sqliteAdmin.email!.isNotEmpty) {
              _adminEmail = sqliteAdmin.email!;
            }
            if (sqliteAdmin.mobile != null && sqliteAdmin.mobile!.isNotEmpty) {
              _adminMobile = sqliteAdmin.mobile!;
            }
          }
          if (sqliteCandidates.isNotEmpty) {
            _candidateMembers = sqliteCandidates;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading SQLite Admin Data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Row
                  _buildHeaderRow(context, isNarrow),

                  const SizedBox(height: 14),

                  // 2. Active Admin User Profile Card (Bound from SQLite)
                  _buildAdminProfileCard(context, isNarrow),

                  const SizedBox(height: 14),

                  // 3. Subscription Plan Banner
                  _buildSubscriptionPlanBanner(context, isNarrow),

                  const SizedBox(height: 14),

                  // 4. Family / Candidate Members Card (Bound from SQLite)
                  _buildFamilyMembersCard(context, isNarrow),

                  const SizedBox(height: 14),

                  // 5. Preferences & Support Card
                  _buildPreferencesCard(context, isNarrow),

                  const SizedBox(height: 80), // Bottom navigation padding
                ],
              ),
            ),

            // Floating Ask Vayo Widget
           /* const Positioned(
              right: 12,
              bottom: 16,
              child: AskVayoFloatingWidget(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isNarrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Admin & Profile',
          style: TextStyle(
            fontSize: context.scaleFont(22),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),

        // Plan Badge Pill
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE047), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                'Family Plan',
                style: TextStyle(
                  fontSize: context.scaleFont(11),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminProfileCard(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF08A).withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 2.5),
            ),
            child: const Center(
              child: Text('👦', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),

          // Bound Admin User Info from SQLite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _adminName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.scaleFont(17),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$_adminEmail • $_adminMobile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.scaleFont(11.5),
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
               /* Text(
                  'SQLite Database Synced',
                  style: TextStyle(
                    fontSize: context.scaleFont(11.5),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlanBanner(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B), // Indigo 950
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('👑', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription: ${_subscriptionLevel.value}',
                  style: TextStyle(
                    fontSize: context.scaleFont(13.5),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '10-Finger AI Counseling Active',
                  style: TextStyle(
                    fontSize: context.scaleFont(11),
                    color: const Color(0xFFC7D2FE),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                fontSize: context.scaleFont(10.5),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyMembersCard(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Candidate Members (${_candidateMembers.length})',
                style: TextStyle(
                  fontSize: context.scaleFont(14),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              InkWell(
                onTap: () {
                  AddFamilyMemberDialog.show(
                    context,
                    onMemberAdded: (_) => setState(() {}),
                  );
                },
                child: Text(
                  '+ Add Member',
                  style: TextStyle(
                    fontSize: context.scaleFont(12),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_candidateMembers.isEmpty)
            _buildMemberTile(
              context: context,
              emoji: '👦',
              name: _adminName,
              role: 'Primary Student • Class 8',
              isHighlighted: true,
            )
          else
            ...List.generate(_candidateMembers.length, (index) {
              final item = _candidateMembers[index];
              final candidateName =
                  (item.dataName != null && item.dataName!.isNotEmpty)
                      ? item.dataName!
                      : '${item.firstName ?? "Candidate"} ${item.lastName ?? ""}';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildMemberTile(
                  context: context,
                  emoji: index % 2 == 0 ? '👦' : '👧',
                  name: candidateName,
                  role:
                      'ID: ${item.id.isNotEmpty ? item.id.substring(0, item.id.length.clamp(0, 8)) : "Active"} •  Scan',
                  isHighlighted: index == 0,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMemberTile({
    required BuildContext context,
    required String emoji,
    required String name,
    required String role,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF8FAFC) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFC7D2FE) : Colors.transparent,
          width: isHighlighted ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF08A).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: context.scaleFont(11),
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences & Support',
            style: TextStyle(
              fontSize: context.scaleFont(14),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Daily AI Counselor Reminders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily AI Counselor Reminders',
                style: TextStyle(
                  fontSize: context.scaleFont(12),
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch.adaptive(
                value: _dailyRemindersEnabled,
                onChanged: (val) =>
                    setState(() => _dailyRemindersEnabled = val),
                activeTrackColor: AppTheme.primary,
              ),
            ],
          ),

          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Assessment Data Privacy
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Assessment Data Privacy',
                    style: TextStyle(
                      fontSize: context.scaleFont(12),
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),

          const Divider(height: 16, color: Color(0xFFF1F5F9)),

          // Help & Mentorship Hotline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Help & Student Mentorship Hotline',
                style: TextStyle(
                  fontSize: context.scaleFont(12),
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Support →',
                  style: TextStyle(
                    fontSize: context.scaleFont(12),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
