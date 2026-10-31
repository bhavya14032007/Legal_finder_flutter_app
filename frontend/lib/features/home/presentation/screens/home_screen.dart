import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../saved/data/saved_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final savedState = ref.watch(savedControllerProvider);

    // Matches target screenshot identity while honoring auth state
    final displayName = authState.userName?.isNotEmpty == true
        ? authState.userName!
        : 'Adv. Rajesh Sharma';

    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF090D18),
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
                      const Text(
                        'WELCOME BACK,',
                        style: TextStyle(
                          color: Color(0xFF8B95B5),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
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
                color: const Color(0xFF101524),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF222B45),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF818CF8),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask any legal question or search statut',
                        hintStyle: TextStyle(
                          color: Color(0xFF64748B),
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
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x666366F1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF101526),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF283456),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141C33),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF38BDF8),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Legal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                          Text(
                            'Advisor',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A213D),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF343F68),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'v3.5',
                          style: TextStyle(
                            color: Color(0xFFA5B4FC),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.legalAdvisor),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x666366F1),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Start\nConsult',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
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
                  const SizedBox(height: 12),
                  const Text(
                    'Get instant statutory clarifications, legal notice analysis, and procedural roadmap guidance.',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
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
                    const Text(
                      'Quick-Access Tools',
                      style: TextStyle(
                        color: Colors.white,
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
                  child: const Text(
                    'View All →',
                    style: TextStyle(
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
              childAspectRatio: 1.15,
              children: [
                _ToolCard(
                  title: 'Simplifier',
                  subtitle: 'Plain language clauses',
                  icon: Icons.menu_book_outlined,
                  accentColor: const Color(0xFF06B6D4),
                  openTextColor: const Color(0xFF38BDF8),
                  cardBorderColor: const Color(0xFF0369A1).withValues(alpha: 0.45),
                  iconBgColor: const Color(0xFF0369A1).withValues(alpha: 0.2),
                  onTap: () => context.push(RouteNames.documentSimplifier),
                ),
                _ToolCard(
                  title: 'Drafting',
                  subtitle: 'Agreements & notices',
                  icon: Icons.edit_outlined,
                  accentColor: const Color(0xFFA855F7),
                  openTextColor: const Color(0xFFC084FC),
                  cardBorderColor: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                  iconBgColor: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  onTap: () => context.push(RouteNames.drafting),
                ),
                _ToolCard(
                  title: 'Notice Reply',
                  subtitle: 'Rebuttal generator',
                  icon: Icons.reply_rounded,
                  accentColor: const Color(0xFF38BDF8),
                  openTextColor: const Color(0xFF60A5FA),
                  cardBorderColor: const Color(0xFF2563EB).withValues(alpha: 0.45),
                  iconBgColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
                  onTap: () => context.push(RouteNames.noticeReply),
                ),
                _ToolCard(
                  title: 'Scam Detector',
                  subtitle: 'Risk & threat score',
                  icon: Icons.shield_outlined,
                  accentColor: const Color(0xFFF43F5E),
                  openTextColor: const Color(0xFFFB7185),
                  cardBorderColor: const Color(0xFFE11D48).withValues(alpha: 0.5),
                  iconBgColor: const Color(0xFFE11D48).withValues(alpha: 0.2),
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
                const Text(
                  'Recently Saved',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.saved),
                  child: const Text(
                    'Open Library',
                    style: TextStyle(
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
                  : 'Residential Lease Agreement',
              timeLabel: 'Yesterday',
              onTap: () => context.go(RouteNames.saved),
            ),
            const SizedBox(height: 10),

            // Item 2: Section 138 NI Act Dishonour Notice
            _SavedItemCard(
              title: savedState.items.length > 1
                  ? savedState.items[1].title
                  : 'Section 138 NI Act Dishonour Noti...',
              timeLabel: '3 days ago',
              onTap: () => context.go(RouteNames.saved),
            ),
            const SizedBox(height: 18),

            // =================================================================
            // 7. IMPORTANT NOTICE DISCLAIMER BANNER
            // =================================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF101526),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF1E2840),
                  width: 1.1,
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: Color(0xFF60A5FA),
                    size: 19,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Important Notice: ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Legal Helper provides AI-assisted legal information, document simplification, and automated drafting for general informational purposes only. It is not an attorney, law firm, or substitute for professional legal advice or formal representation.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
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
  final IconData icon;
  final Color accentColor;
  final Color openTextColor;
  final Color cardBorderColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.openTextColor,
    required this.cardBorderColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF101526),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cardBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 19,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF14192E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  'Open →',
                  style: TextStyle(
                    color: openTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF101526),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E2840),
            width: 1.1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF171B33),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF312E81),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: Color(0xFFA5B4FC),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
