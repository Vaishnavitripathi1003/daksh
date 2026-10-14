import 'package:daksh/core/Global/global_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/intelligence_models.dart';
import '../../core/models/reportResponse.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'ai_counselor_screen.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Complete Personality Profile Screen binding API Personality data (primary & secondary) with fully responsive overflow-proof layouts.
class PersonalityDetailScreen extends StatefulWidget {
  final Personality? personality;

  const PersonalityDetailScreen({super.key, this.personality});

  @override
  State<PersonalityDetailScreen> createState() =>
      _PersonalityDetailScreenState();
}

class _PersonalityDetailScreenState extends State<PersonalityDetailScreen> {
  int _selectedTabIndex = 0;
  int _selectedScenarioIndex = 0;
  Personality? _personality;

  final List<String> _tabs = [
    'Archetype & Blend',
    /*'Behavioral Metrics',
    'In Action',
    'Mentorship',*/
  ];

  @override
  void initState() {
    super.initState();
    _personality = widget.personality;
    if (_personality == null) {
      _loadPersonalityData();
    }
  }

  Future<void> _loadPersonalityData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final memberId = GlobalClass.selected_member;

      if (token.isNotEmpty && memberId.isNotEmpty) {
        final response = await ApiService().findReportByUserDataId(
          auth: token,
          userDataId: memberId,
        );

        if (response.statusCode == 200 && response.data != null) {
          final reportResp = ReportResponse.fromJson(response.data);
          if (reportResp.report.isNotEmpty) {
            if (mounted) {
              setState(() {
                _personality = reportResp.report.first.personality;
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading personality data: $e');
    }
  }

  void _openCounselor(BuildContext context, [String? initialPrompt]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AICounselorScreen(
          profile: const StudentProfile(
            id: '1',
            name: 'Aarav',
            role: 'Class 8',
            avatar: '👦',
            gender: 'boy',
            grade: 'Class 8',
            active: true,
          ),
          initialPrompt: initialPrompt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final primary = _personality?.primary.isNotEmpty == true
        ? _personality!.primary
        : 'Dominant';
    final secondary = _personality?.secondary.isNotEmpty == true
        ? _personality!.secondary
        : 'Steady';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personality Profile',
              style: TextStyle(
                fontSize: context.scaleFont(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '$primary – $secondary Blend',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                size: 20, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Category Tabs Row
                _buildTabsRow(context, isNarrow),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: padding, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedTabIndex == 0)
                          _buildArchetypeAndBlendTab(
                              context, isNarrow, primary, secondary),
                        if (_selectedTabIndex == 1)
                          _buildBehavioralMetricsTab(context, isNarrow, primary, secondary),
                        if (_selectedTabIndex == 2)
                          _buildInActionTab(context, isNarrow, primary),
                        if (_selectedTabIndex == 3)
                          _buildMentorshipTab(context, isNarrow, primary),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Ask Vayo Overlay Widget
           /* const Positioned(
              right: 16,
              bottom: 20,
              child: AskVayoFloatingWidget(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildTabsRow(BuildContext context, bool isNarrow) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final bool isSelected = _selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedTabIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // TAB 1: Archetype & Blend
  Widget _buildArchetypeAndBlendTab(BuildContext context, bool isNarrow,
      String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary DISC Synthesis Card
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Primary DISC Synthesis',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  Text('$primary–$secondary',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$primary Driver',
                          style: TextStyle(
                            fontSize: context.scaleFont(20),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Decisive leadership propelled by $secondary traits and rapid execution',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.bolt_rounded,
                          color: Color(0xFF7C3AED), size: 24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Responsive Sub-pills Wrap (prevents Row overflow)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                 /* Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Full Blend (60/40)',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),*/
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$primary (Primary)',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7E22CE))),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$secondary (Secondary)',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D))),
                  ),
                ],
              ),

              const SizedBox(height: 20),

           /*   // Ratio Donut Progress
              Center(
                child: SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 130,
                        height: 130,
                        child: CircularProgressIndicator(
                          value: 0.60,
                          strokeWidth: 14,
                          backgroundColor: Color(0xFF10B981),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('60 / 40',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A))),
                          Text('RATIO BALANCE',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 10, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 4),
                      Text('$primary  60%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155))),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text('$secondary  40%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF334155))),
                    ],
                  ),
                ],
              ),*/
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Unique Cognitive Advantage Card
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Unique Cognitive Advantage',
                      style: TextStyle(fontSize: 12, color: Color(0xFFC7D2FE))),
                  Text('Dual Synergy',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFEF08A))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'The $primary & $secondary Synergy',
                      style: TextStyle(
                        fontSize: context.scaleFont(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Combining $primary drive with $secondary stability inspires people with vision and personally manages execution across the finish line.',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFE0E7FF), height: 1.45),
              ),
              const Divider(height: 24, color: Colors.white24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 8,
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Natural Leadership Stance: Action + Stability',
                    style: TextStyle(fontSize: 11, color: Color(0xFFC7D2FE)),
                  ),
                  InkWell(
                    onTap: () => _openCounselor(context,
                        'Explain my natural leadership stance (Action + Stability)'),
                    child: const Text(
                      'Explore with AI →',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFEF08A)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Primary Personality Breakdown Card
        _buildPersonalityBreakdownCard(
          avatarChar: primary.isNotEmpty ? primary[0] : 'D',
          avatarBg: const Color(0xFFF3E8FF),
          title: '$primary Personality',
          percentage: '60%',
          subtitle: 'The Primary Driver',
          description:
              'Leads with bold confidence, focuses on milestones, and takes charge of objectives.',
          chips: [
            'Result-oriented',
            'Strong-willed',
            'Decisive',
            'Direct & Candid',
            'Milestone Driven'
          ],
          chipBg: const Color(0xFFFAF5FF),
          chipText: const Color(0xFF7E22CE),
        ),

        const SizedBox(height: 16),

        // Secondary Personality Breakdown Card
        _buildPersonalityBreakdownCard(
          avatarChar: secondary.isNotEmpty ? secondary[0] : 'S',
          avatarBg: const Color(0xFFDCFCE7),
          title: '$secondary Personality',
          percentage: '40%',
          subtitle: 'The Secondary Anchor',
          description:
              'Provides consistent focus, reliable support, and balanced execution.',
          chips: [
            'Reliable',
            'Patient',
            'Supportive',
            'Methodical',
            'Team Anchor'
          ],
          chipBg: const Color(0xFFECFDF5),
          chipText: const Color(0xFF15803D),
        ),

        const SizedBox(height: 16),
/*
        // Verified Top Strengths Card
        _buildTopStrengthsCard(context, isNarrow),

        const SizedBox(height: 16),

        // Exemplary Role Models Card
        _buildRoleModelsCard(context, isNarrow),*/
      ],
    );
  }

  // TAB 2: Behavioral Metrics
  Widget _buildBehavioralMetricsTab(BuildContext context, bool isNarrow, String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Behavioral Intensity Meters
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Behavioral Intensity Meters',
                style: TextStyle(
                  fontSize: context.scaleFont(15),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Standardized scoring across key work and study dimensions',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              _buildMeterRow('Decisiveness & Drive ($primary)', 'Exceptional', 0.94, '94%',
                  const Color(0xFF7C3AED)),
              const SizedBox(height: 12),
              _buildMeterRow('Consistency & Patience ($secondary)', 'Very High', 0.84,
                  '84%', const Color(0xFF2563EB)),
              const SizedBox(height: 12),
              _buildMeterRow('Task Autonomy', 'Exceptional', 0.90, '90%',
                  const Color(0xFF7C3AED)),
              const SizedBox(height: 12),
              _buildMeterRow('Pace & Execution Urgency', 'Exceptional', 0.92,
                  '92%', const Color(0xFF7C3AED)),
              const SizedBox(height: 12),
              _buildMeterRow('Collaborative Listening', 'Balanced', 0.74,
                  '74%', const Color(0xFF10B981)),
              const SizedBox(height: 12),
              _buildMeterRow('Calculated Risk Appetite', 'High', 0.86, '86%',
                  const Color(0xFF2563EB)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // DISC Quadrant Coordinates Card
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISC Quadrant Coordinates',
                style: TextStyle(
                  fontSize: context.scaleFont(15),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Overall psychometric matrix placement',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isNarrow ? 1 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isNarrow ? 2.8 : 1.10,
                children: [
                  _QuadrantCard(
                    title: '$primary (Primary)',
                    score: '60% High',
                    subtitle:
                        'Fast-paced, task-focused, overcomes opposition',
                    bgColor: const Color(0xFFFAF5FF),
                    borderColor: const Color(0xFFE9D5FF),
                    titleColor: const Color(0xFF7E22CE),
                  ),
                  _QuadrantCard(
                    title: '$secondary (Secondary)',
                    score: '40% High',
                    subtitle: 'Reliable, supportive, creates stability',
                    bgColor: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                    titleColor: const Color(0xFF059669),
                  ),
                  const _QuadrantCard(
                    title: 'Influence',
                    score: 'Moderate',
                    subtitle:
                        'People-focused, generates buy-in and enthusiasm',
                    bgColor: Color(0xFFF8FAFC),
                    borderColor: Color(0xFFE2E8F0),
                    titleColor: Color(0xFF475569),
                  ),
                  const _QuadrantCard(
                    title: 'Compliance',
                    score: 'Strategic',
                    subtitle:
                        'Values quality outcomes over excessive micromanagement',
                    bgColor: Color(0xFFF8FAFC),
                    borderColor: Color(0xFFE2E8F0),
                    titleColor: Color(0xFF475569),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: In Action
  Widget _buildInActionTab(BuildContext context, bool isNarrow, String primary) {
    final scenarios = [
      {
        'title': 'In Group Projects',
        'subtitle': 'Natural Captain & Coordinator',
        'icon': Icons.groups_outlined
      },
      {
        'title': 'Under Academic Pressure',
        'subtitle': 'Competitive Clarity & Speed',
        'icon': Icons.bolt_outlined
      },
      {
        'title': 'Communication Playbook',
        'subtitle': 'Direct, Expressive & Candid',
        'icon': Icons.chat_bubble_outline_rounded
      },
      {
        'title': 'Optimal Learning Environment',
        'subtitle': 'Challenge-Driven & Active',
        'icon': Icons.track_changes_rounded
      },
    ];

    final currentScenario = scenarios[_selectedScenarioIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scenario Sub-tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(scenarios.length, (index) {
              final bool isSel = _selectedScenarioIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedScenarioIndex = index),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      scenarios[index]['title'] as String,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 16),

        // Scenario Breakdown Box
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SCENARIO BREAKDOWN',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6366F1),
                                letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(
                          currentScenario['title'] as String,
                          style: TextStyle(
                              fontSize: context.scaleFont(16),
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary),
                        ),
                        Text(
                          currentScenario['subtitle'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(currentScenario['icon'] as IconData,
                        color: const Color(0xFF4338CA), size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Observed Natural Behavior',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(
                'Driven by $primary traits, naturally outlines milestones, assigns responsibilities according to strengths, and keeps the team focused when deadlines loom.',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Text.rich(
                  TextSpan(
                    children: const [
                      TextSpan(
                          text: 'Optimization Tip: ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A))),
                      TextSpan(
                          text:
                              'Encourage team check-ins where every member voices their opinion before finalizing decisions.'),
                    ],
                  ),
                  style: const TextStyle(
                      fontSize: 11.5, color: Color(0xFF334155), height: 1.35),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openCounselor(context,
                      'How should I behave ${currentScenario['title']}?'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF2FF),
                    foregroundColor: const Color(0xFF4338CA),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: const Text('Ask AI Counselor About This Scenario',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Other Real-World Moments
        Text('Other Real-World Moments',
            style: TextStyle(
                fontSize: context.scaleFont(15),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),

        for (int i = 0; i < scenarios.length; i++) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: i == _selectedScenarioIndex
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(scenarios[i]['icon'] as IconData,
                    size: 20, color: const Color(0xFF4338CA)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scenarios[i]['title'] as String,
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                      Text(scenarios[i]['subtitle'] as String,
                          style: const TextStyle(
                              fontSize: 10.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => _selectedScenarioIndex = i),
                  child: const Text('View →',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1))),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // TAB 4: Mentorship
  Widget _buildMentorshipTab(BuildContext context, bool isNarrow, String primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent & Mentor Playbook
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parent & Mentor Playbook',
                  style: TextStyle(
                      fontSize: context.scaleFont(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              const Text(
                  "Evidence-based guidelines to unlock full potential",
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 14),

              _buildPlaybookBox('For Parents & Mentors',
                  'Grant autonomy over the roadmap while setting clear non-negotiable milestones. When trust is given, initiative doubles.'),
              const SizedBox(height: 10),
              _buildPlaybookBox('Communication Key',
                  'Be direct and concise. Lead with the ultimate destination and show how suggestions accelerate goals.'),
              const SizedBox(height: 10),
              _buildPlaybookBox('Growth Exercise',
                  'Practice the "3–Beat Pause": Before finalizing a team decision, ask two quiet peers for their take.'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Psychological Triggers Card
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Psychological Triggers',
                  style: TextStyle(
                      fontSize: context.scaleFont(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA7F3D0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥 What Fuels The Engine:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46))),
                    const SizedBox(height: 4),
                    Text(
                      'Clear ambitious $primary goals, acknowledgment of wins, competitive challenges, freedom to innovate, and speaking opportunities.',
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF047857),
                          height: 1.35),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('⚠️ What Drains Energy:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9F1239))),
                    SizedBox(height: 4),
                    Text(
                      'Repetitive rote memorization, delayed feedback loops, prolonged indecisiveness in teams, restrictive rules without clear logic, and isolated desk-bound tasks.',
                      style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFBE123C),
                          height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Ask Vayo Custom Advice Banner
        Container(
          padding: EdgeInsets.all(isNarrow ? 14 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('🤖', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Ask Vayo AI Custom Advice',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A))),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Ask our AI counselor specific questions about academic subject choices, stream selections, or study habits tailored to this personality.',
                style: TextStyle(
                    fontSize: 11.5, color: Color(0xFF2563EB), height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openCounselor(context,
                      'Give me custom advice for subject and stream selections.'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Launch Tailored Counselor Chat >',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityBreakdownCard({
    required String avatarChar,
    required Color avatarBg,
    required String title,
    required String percentage,
    required String subtitle,
    required String description,
    required List<String> chips,
    required Color chipBg,
    required Color chipText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                    BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                child: Center(
                    child: Text(avatarChar,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: chipText))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                          const TextSpan(text: ' • '),
                          TextSpan(
                              text: percentage,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: chipText)),
                        ],
                      ),
                    ),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              const Text('Details',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED))),
            ],
          ),
          const SizedBox(height: 10),
          Text(description,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF475569), height: 1.35)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: chipBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(c,
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: chipText)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStrengthsCard(BuildContext context, bool isNarrow) {
    final strengths = [
      {
        'num': '1',
        'title': 'Executive Initiative',
        'pct': '96%',
        'desc': 'Takes proactive ownership without waiting for instructions'
      },
      {
        'num': '2',
        'title': 'Persuasive Vision',
        'pct': '92%',
        'desc':
            'Articulates goals so clearly that others enthusiastically follow'
      },
      {
        'num': '3',
        'title': 'Crisis Decisiveness',
        'pct': '90%',
        'desc':
            'Maintains composure and makes decisive calls when others hesitate'
      },
      {
        'num': '4',
        'title': 'Milestone Execution',
        'pct': '88%',
        'desc': 'Relentlessly tracks and drives projects across the finish line'
      },
      {
        'num': '5',
        'title': 'Team Morale Catalyst',
        'pct': '85%',
        'desc':
            'Infuses optimism and lifts group energy during challenging phases'
      },
    ];

    return Container(
      padding: EdgeInsets.all(isNarrow ? 14 : 18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Verified Top Strengths',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              Text('5 Core Pillars',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1))),
            ],
          ),
          const Text('Ranked by psychometric dominance',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          for (final s in strengths) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                        child: Text(s['num']!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4338CA)))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s['title']!,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary)),
                            Text(s['pct']!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B))),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(s['desc']!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleModelsCard(BuildContext context, bool isNarrow) {
    final roleModels = [
      {
        'name': 'Steve Jobs',
        'tag': 'Visionary Innovator',
        'desc':
            'Iconic blend of relentless product drive and charismatic stage presence.'
      },
      {
        'name': 'Serena Williams',
        'tag': 'Champion & Venture Leader',
        'desc':
            'Fierce competitive determination coupled with inspiring global advocacy.'
      },
      {
        'name': 'Winston Churchill',
        'tag': 'Historic Statesman',
        'desc':
            'Uncompromising resolve articulated through stirring, morale-lifting speeches.'
      },
    ];

    return Container(
      padding: EdgeInsets.all(isNarrow ? 14 : 18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exemplary Role Models',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const Text('Historical & contemporary figures',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          for (final rm in roleModels) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(rm['name']!,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Text(rm['tag']!,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(rm['desc']!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                          height: 1.3)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeterRow(
      String label, String rating, double value, String pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ),
            Row(
              children: [
                Text(rating,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(width: 6),
                Text(pct,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybookBox(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA))),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontSize: 11.5, color: Color(0xFF334155), height: 1.35)),
        ],
      ),
    );
  }
}

class _QuadrantCard extends StatelessWidget {
  final String title;
  final String score;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color titleColor;

  const _QuadrantCard({
    required this.title,
    required this.score,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: titleColor),
                      overflow: TextOverflow.ellipsis)),
              Text(score,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: titleColor)),
            ],
          ),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 9.5, color: Color(0xFF64748B), height: 1.25)),
        ],
      ),
    );
  }
}
