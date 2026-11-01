import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../saved/data/saved_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final savedState = ref.watch(savedControllerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF090D18) : const Color(0xFFF4F6FF);
    final cardBg = isDark ? const Color(0xFF101524) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF222B45) : const Color(0xFFF1F5F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF8B95B5) : const Color(0xFF64748B);
    final heroBg = isDark ? const Color(0xFF101526) : Colors.white;
    final heroBorder = isDark ? const Color(0xFF283456) : const Color(0xFFEEF2FF);

    // Matches target screenshot identity while honoring auth state
    final displayName = authState.userName?.isNotEmpty == true
        ? authState.userName!
        : 'Adv. Rajesh Sharma';

    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // =================================================================
            // 1. TOP HEADER: WELCOME + PROFILE AVATAR WITH ONLINE RING
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
                      const SizedBox(height: 3),
                      Text(
                        displayName,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
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
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF06B6D4),
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x666366F1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D1222),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
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
                            color: const Color(0xFF10B981),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF090D18),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x8810B981),
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
            const SizedBox(height: 18),

            // =================================================================
            // 2. GLOBAL SEARCH / ASK BAR WITH GRADIENT ACTION BUTTON
            // =================================================================
            Container(
              height: 52,
              padding: const EdgeInsets.only(left: 14, right: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? cardBorder : const Color(0xFFE8ECF8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x33000000) : const Color(0x0C4F46E5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: ref.isHindi
                            ? 'कानूनी एआई से पूछें (उदा. नोटिस उत्तर, अनुबंध शर्तें)...'
                            : 'Ask any legal question or search statutes...',
                        hintStyle: TextStyle(
                          color: textSecondary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (query) {
                        if (query.trim().isNotEmpty) {
                          context.push(RouteNames.legalAdvisor);
                        }
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(RouteNames.legalAdvisor);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF6366F1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x557C3AED),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // 3. HERO BANNER: AI LEGAL ADVISOR (v3.5)
            // =================================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: heroBg,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: heroBorder,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? const Color(0x44000000) : const Color(0x0C4F46E5),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x220F172A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF38BDF8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                ref.isHindi ? 'कानूनी एआई' : 'AI Legal',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2E1065) : const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'v3.5',
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            ref.isHindi ? 'सलाहकार' : 'Advisor',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.legalAdvisor),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7C3AED),
                                Color(0xFF6366F1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x557C3AED),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ref.isHindi ? 'परामर्श शुरू करें' : 'Start Consult',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ref.isHindi
                        ? 'कानूनी धाराओं के आधार पर त्वरित वैधानिक मार्गदर्शन, नोटिस विश्लेषण और कार्ययोजना पाएं।'
                        : 'Get instant statutory clarifications, legal notice analysis, and procedural roadmap guidance.',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 4. QUICK-ACCESS TOOLS HEADER + GLOWING BLUE DOT
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF60A5FA),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF60A5FA),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.explore),
                  child: Text(
                    ref.isHindi ? 'सभी देखें →' : 'View All →',
                    style: const TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // =================================================================
            // 5. 2x2 GRID: SIMPLIFIER, DRAFTING, NOTICE REPLY, SCAM DETECTOR
            // =================================================================
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _ToolCard(
                  title: ref.isHindi ? 'सरलीकरण' : 'Simplifier',
                  subtitle: ref.isHindi ? 'सरल भाषा में समझें' : 'Plain language clauses',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.menu_book_outlined,
                  accentColor: const Color(0xFF0D9488),
                  openTextColor: const Color(0xFF0D9488),
                  pillBgColor: const Color(0xFFF0FDFA),
                  pillBorderColor: const Color(0xFFCCFBF1),
                  cardBorderColor: const Color(0xFF0D9488).withValues(alpha: 0.3),
                  iconBgColor: const Color(0xFFF0FDFA),
                  onTap: () => context.push(RouteNames.documentSimplifier),
                ),
                _ToolCard(
                  title: ref.isHindi ? 'प्रारूपण' : 'Drafting',
                  subtitle: ref.isHindi ? 'अनुबंध व पत्र' : 'Agreements & notices',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.edit_outlined,
                  accentColor: const Color(0xFF7C3AED),
                  openTextColor: const Color(0xFF7C3AED),
                  pillBgColor: const Color(0xFFFAF5FF),
                  pillBorderColor: const Color(0xFFF3E8FF),
                  cardBorderColor: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                  iconBgColor: const Color(0xFFFAF5FF),
                  onTap: () => context.push(RouteNames.drafting),
                ),
                _ToolCard(
                  title: ref.isHindi ? 'नोटिस उत्तर' : 'Notice Reply',
                  subtitle: ref.isHindi ? 'बचाव रणनीति' : 'Rebuttal generator',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.reply_rounded,
                  accentColor: const Color(0xFF0284C7),
                  openTextColor: const Color(0xFF0284C7),
                  pillBgColor: const Color(0xFFF0F9FF),
                  pillBorderColor: const Color(0xFFE0F2FE),
                  cardBorderColor: const Color(0xFF0284C7).withValues(alpha: 0.3),
                  iconBgColor: const Color(0xFFF0F9FF),
                  onTap: () => context.push(RouteNames.noticeReply),
                ),
                _ToolCard(
                  title: ref.isHindi ? 'धोखाधड़ी शील्ड' : 'Scam Detector',
                  subtitle: ref.isHindi ? 'खतरा एवं रिस्क स्कोर' : 'Risk & threat score',
                  openLabel: ref.isHindi ? 'खोलें →' : 'Open →',
                  icon: Icons.shield_outlined,
                  accentColor: const Color(0xFFE11D48),
                  openTextColor: const Color(0xFFE11D48),
                  pillBgColor: const Color(0xFFFFF1F2),
                  pillBorderColor: const Color(0xFFFFE4E6),
                  cardBorderColor: const Color(0xFFE11D48).withValues(alpha: 0.3),
                  iconBgColor: const Color(0xFFFFF1F2),
                  onTap: () => context.push(RouteNames.scamDetector),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // =================================================================
            // 6. RECENTLY SAVED SECTION
            // =================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref.isHindi ? 'हाल ही में सहेजे गए' : 'Recently Saved',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.saved),
                  child: Text(
                    ref.isHindi ? 'लाइब्रेरी खोलें' : 'Open Library',
                    style: const TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Item 1: Residential Lease Agreement
            _SavedItemCard(
              title: savedState.items.isNotEmpty
                  ? savedState.items[0].title
                  : (ref.isHindi ? 'आवासीय किराया समझौता' : 'Residential Lease Agreement'),
              timeLabel: ref.isHindi ? 'कल' : 'Yesterday',
              onTap: () => context.go(RouteNames.saved),
            ),
            const SizedBox(height: 10),

            // Item 2: Section 138 NI Act Dishonour Notice
            _SavedItemCard(
              title: savedState.items.length > 1
                  ? savedState.items[1].title
                  : (ref.isHindi
                      ? 'धारा 138 एनआई एक्ट चेक बाउंस नोटिस'
                      : 'Section 138 NI Act Dishonour Notice'),
              timeLabel: ref.isHindi ? '3 दिन पहले' : '3 days ago',
              onTap: () => context.go(RouteNames.saved),
            ),
            const SizedBox(height: 18),

            // =================================================================
            // 7. IMPORTANT NOTICE DISCLAIMER BANNER
            // =================================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFBAE6FD),
                  width: 1.1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0284C7),
                    size: 19,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: ref.isHindi ? 'महत्वपूर्ण सूचना: ' : 'Important Notice: ',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ref.isHindi
                                ? 'लीगल हेल्पर केवल सामान्य सूचनात्मक उद्देश्यों के लिए एआई-सहायता प्राप्त कानूनी जानकारी, दस्तावेज़ सरलीकरण और स्वचालित प्रारूपण प्रदान करता है। यह कोई वकील, कानूनी फर्म या पेशेवर कानूनी सलाह का विकल्प नहीं है।'
                                : 'Legal Helper provides AI-assisted legal information, document simplification, and automated drafting for reference purposes only. It is not an attorney, law firm, or substitute for professional legal advice or formal representation.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String openLabel;
  final IconData icon;
  final Color accentColor;
  final Color openTextColor;
  final Color pillBgColor;
  final Color pillBorderColor;
  final Color cardBorderColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    this.openLabel = 'Open →',
    required this.icon,
    required this.accentColor,
    required this.openTextColor,
    required this.pillBgColor,
    required this.pillBorderColor,
    required this.cardBorderColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF101526) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? cardBorderColor : const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? accentColor.withValues(alpha: 0.08) : const Color(0x0C4F46E5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? accentColor.withValues(alpha: 0.15) : iconBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? accentColor.withValues(alpha: 0.4) : pillBorderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? accentColor.withValues(alpha: 0.15) : pillBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? accentColor.withValues(alpha: 0.35) : pillBorderColor,
                  width: 1,
                ),
              ),
              child: Text(
                openLabel,
                style: TextStyle(
                  color: isDark ? openTextColor : accentColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final String title;
  final String timeLabel;
  final VoidCallback onTap;

  const _SavedItemCard({
    required this.title,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF101526) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2840) : const Color(0xFFF1F5F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final iconBoxBg = isDark ? const Color(0xFF171B33) : const Color(0xFFF3F4FE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cardBorder,
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x22000000) : const Color(0x084F46E5),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBoxBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
