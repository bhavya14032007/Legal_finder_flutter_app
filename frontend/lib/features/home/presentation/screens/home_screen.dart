import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../saved/data/saved_repository.dart';
import '../../../saved/models/saved_item.dart';

/// Redesigned Premium Legal Helper Dashboard
///
/// Implements a modern legal-tech design inspired by Linear, Notion,
/// and contemporary dark-mode fintech apps while preserving 100% of the
/// existing Supabase backend integration, navigation, and state.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit(String query) {
    if (query.trim().isNotEmpty) {
      context.push(RouteNames.legalAdvisor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final savedState = ref.watch(savedControllerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final heroBorder = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    // Dynamic user name from auth state with graceful default
    final displayName = authState.userName?.trim().isNotEmpty == true
        ? authState.userName!.trim()
        : (ref.isHindi ? 'राजेश शर्मा' : 'Adv. Rajesh Sharma');

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ListView(
          // Bottom padding of 92px ensures the floating AI button never obstructs content
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 92),
          children: [
            // =================================================================
            // 1. DASHBOARD HEADER: WELCOME + DYNAMIC USER + PROFILE AVATAR
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.isHindi ? 'वापसी पर स्वागत है,' : 'WELCOME BACK,',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayName,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.me),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF7955F5),
                              Color(0xFF6366F1),
                              Color(0xFF06B6D4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7955F5).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.primaryAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scaffoldBg,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x6610B981),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // =================================================================
            // 2. SEARCH BAR: REFINED INPUT & INTERACTIVE CTA
            // =================================================================
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cardBorder,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x22000000) : const Color(0x06000000),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: ref.isHindi
                            ? 'कानूनी सवाल पूछें या धाराएं खोजें...'
                            : 'Ask any legal question or search statutes...',
                        hintStyle: TextStyle(
                          color: textSecondary.withValues(alpha: 0.8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: _handleSearchSubmit,
                    ),
                  ),
                  _ScaleTap(
                    onTap: () => _handleSearchSubmit(_searchController.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7955F5),
                            Color(0xFF6366F1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x447955F5),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // 3. AI LEGAL ADVISOR HERO SECTION: PRIMARY VISUAL ELEMENT
            // =================================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF111827),
                          const Color(0xFF151D30),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF8FAFC),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? heroBorder : const Color(0xFFE2E8F0),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x33000000) : const Color(0x0A7955F5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF7955F5).withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF7955F5),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ref.isHindi ? 'एआई कानूनी सलाहकार' : 'AI Legal Advisor',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2E1065)
                                        : const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'v3.5',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFD8B4FE)
                                          : const Color(0xFF7955F5),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.isHindi
                                  ? 'भारतीय कानून एवं वैधानिक प्रश्नों का त्वरित उत्तर'
                                  : 'Statutory Guidance & Case Roadmap',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ref.isHindi
                        ? 'कानूनी धाराओं के आधार पर त्वरित वैधानिक मार्गदर्शन, नोटिस विश्लेषण और कार्ययोजना पाएं।'
                        : 'Get instant statutory clarifications, legal notice analysis, and procedural roadmap guidance.',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Capability chips (Linear/Notion inspired information architecture)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CapabilityChip(
                        label: ref.isHindi ? 'वैधानिक स्पष्टीकरण' : 'Statutory Clarification',
                        isDark: isDark,
                      ),
                      _CapabilityChip(
                        label: ref.isHindi ? 'नोटिस विश्लेषण' : 'Notice Analysis',
                        isDark: isDark,
                      ),
                      _CapabilityChip(
                        label: ref.isHindi ? 'प्रक्रियात्मक रोडमैप' : 'Procedural Roadmap',
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Primary CTA Button: Prominently styled and wired to existing legal advisor flow
                  _ScaleTap(
                    onTap: () => context.push(RouteNames.legalAdvisor),
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7955F5),
                            Color(0xFF6366F1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7955F5).withValues(alpha: isDark ? 0.35 : 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ref.isHindi ? 'परामर्श शुरू करें' : 'Start Consultation',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 4. QUICK-ACCESS TOOLS HEADER
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      ref.isHindi ? 'त्वरित-पहुंच उपकरण' : 'Quick-Access Tools',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7955F5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.explore),
                  child: Text(
                    ref.isHindi ? 'सभी देखें →' : 'View All →',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA5B4FC) : AppColors.primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // =================================================================
            // 5. 2x2 RESPONSIVE GRID: 4 TOOLS (15-20% HEIGHT REDUCTION)
            // =================================================================
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.20,
              children: [
                // 1. Simplifier (Teal)
                _ToolCard(
                  title: ref.isHindi ? 'सरलीकरण' : 'Simplifier',
                  subtitle: ref.isHindi ? 'सरल भाषा में समझें' : 'Plain language clauses',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.menu_book_outlined,
                  accentColor: const Color(0xFF0D9488),
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.documentSimplifier),
                ),
                // 2. Drafting (Purple)
                _ToolCard(
                  title: ref.isHindi ? 'प्रारूपण' : 'Drafting',
                  subtitle: ref.isHindi ? 'अनुबंध व पत्र' : 'Agreements & notices',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.edit_outlined,
                  accentColor: const Color(0xFF7955F5),
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.drafting),
                ),
                // 3. Notice Reply (Blue)
                _ToolCard(
                  title: ref.isHindi ? 'नोटिस उत्तर' : 'Notice Reply',
                  subtitle: ref.isHindi ? 'बचाव रणनीति' : 'Rebuttal generator',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.reply_rounded,
                  accentColor: const Color(0xFF2563EB),
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.noticeReply),
                ),
                // 4. Scam Detector (Red)
                _ToolCard(
                  title: ref.isHindi ? 'धोखाधड़ी शील्ड' : 'Scam Detector',
                  subtitle: ref.isHindi ? 'खतरा एवं रिस्क स्कोर' : 'Risk & threat score',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.shield_outlined,
                  accentColor: const Color(0xFFEF4444),
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  isDark: isDark,
                  onTap: () => context.push(RouteNames.scamDetector),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 6. RECENTLY SAVED SECTION (CONNECTED TO REAL SUPABASE REPOSITORY)
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref.isHindi ? 'हाल ही में सहेजे गए' : 'Recently Saved',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.saved),
                  child: Text(
                    ref.isHindi ? 'लाइब्रेरी खोलें' : 'Open Library',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA5B4FC) : AppColors.primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Real backend items or clean empty state
            if (savedState.items.isEmpty)
              _EmptySavedState(
                isDark: isDark,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onExplore: () => context.go(RouteNames.explore),
              )
            else
              ...savedState.items.take(3).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SavedItemCard(
                    item: item,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    onTap: () => context.go(RouteNames.saved),
                  ),
                );
              }),
            const SizedBox(height: 14),

            // =================================================================
            // 7. STATUTORY LEGAL AID & SECURITY HELPLINE
            // =================================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cardBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: Color(0xFF7955F5),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.isHindi ? 'मुफ्त कानूनी सहायता एवं हेल्पलाइन' : 'Free Legal Aid & Support',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ref.isHindi
                              ? 'अनुच्छेद 39A (NALSA/DLSA) एवं राष्ट्रीय हेल्पलाइन 1930'
                              : 'Article 39A (NALSA & DLSA) & Cyber Helpline 1930',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ScaleTap(
                    onTap: () => context.push(RouteNames.legalAid),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1B4B) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF7955F5).withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        ref.isHindi ? 'जांचें' : 'Check',
                        style: const TextStyle(
                          color: Color(0xFF7955F5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // =================================================================
            // 8. IMPORTANT NOTICE DISCLAIMER BANNER
            // =================================================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1322) : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFBAE6FD),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0284C7),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: ref.isHindi ? 'महत्वपूर्ण सूचना: ' : 'Important Notice: ',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ref.isHindi
                                ? 'लीगल हेल्पर केवल सामान्य सूचनात्मक व वैधानिक संदर्भ के लिए सहायता प्रदान करता है। यह औपचारिक कानूनी परामर्श या अधिवक्ता प्रतिनिधित्व का विकल्प नहीं है।'
                                : 'Legal Helper provides AI-assisted statutory information for reference purposes only. It is not an attorney, law firm, or substitute for formal legal representation.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 10.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linear-style subtle capability chip
class _CapabilityChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _CapabilityChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF26334D) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      child: Text(
        '✦ $label',
        style: TextStyle(
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Compact, responsive Tool Card (15-20% height reduction)
class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String openLabel;
  final IconData icon;
  final Color accentColor;
  final Color cardBg;
  final Color cardBorder;
  final bool isDark;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.openLabel,
    required this.icon,
    required this.accentColor,
    required this.cardBg,
    required this.cardBorder,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return _ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? cardBorder : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x1F000000) : const Color(0x06000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.16 : 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    openLabel,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Recently Saved Item connected to real Supabase data
class _SavedItemCard extends StatelessWidget {
  final SavedItem item;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _SavedItemCard({
    required this.item,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  String _formatType(SavedItemType type) {
    switch (type) {
      case SavedItemType.draft:
        return 'Draft';
      case SavedItemType.document:
        return 'Notice';
      case SavedItemType.research:
        return 'Precedent';
      case SavedItemType.conversation:
        return 'Advice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = _formatType(item.type);
    final dateLabel = _formatDate(item.createdAt);

    return _ScaleTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cardBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x1F000000) : const Color(0x06000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF7955F5).withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF7955F5),
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: textSecondary.withValues(alpha: 0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Polished empty state when user has no saved items yet
class _EmptySavedState extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onExplore;

  const _EmptySavedState({
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              color: textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No saved documents yet',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Generated drafts and notices appear here',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _ScaleTap(
            onTap: onExplore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Explore',
                style: TextStyle(
                  color: Color(0xFF7955F5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle press interaction wrapper (150ms spring-like feedback)
class _ScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleTap({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
