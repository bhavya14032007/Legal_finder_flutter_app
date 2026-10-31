import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/document_simplifier/presentation/screens/document_simplifier_screen.dart';
import '../../features/drafting/presentation/screens/drafting_screen.dart';
import '../../features/evidence_timeline/presentation/screens/evidence_timeline_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lawyer_prep/presentation/screens/lawyer_prep_screen.dart';
import '../../features/legal_advisor/presentation/screens/legal_advisor_screen.dart';
import '../../features/legal_aid/presentation/screens/legal_aid_screen.dart';
import '../../features/legal_research/presentation/screens/legal_research_screen.dart';
import '../../features/legal_vault/presentation/screens/legal_vault_screen.dart';
import '../../features/notice_reply/presentation/screens/notice_reply_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/saved/presentation/screens/saved_screen.dart';
import '../../features/scam_detector/presentation/screens/scam_detector_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'explore');
final GlobalKey<NavigatorState> _savedNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'saved');
final GlobalKey<NavigatorState> _meNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'me');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.home,
  routes: [
    // Auth Routes
    GoRoute(
      path: RouteNames.login,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.register,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Bottom Navigation Stateful Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Branch 1: Home
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Branch 2: Explore
        StatefulShellBranch(
          navigatorKey: _exploreNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),

        // Branch 3: Saved
        StatefulShellBranch(
          navigatorKey: _savedNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.saved,
              builder: (context, state) => const SavedScreen(),
            ),
          ],
        ),

        // Branch 4: Me
        StatefulShellBranch(
          navigatorKey: _meNavigatorKey,
          routes: [
            GoRoute(
              path: RouteNames.me,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Feature Detail Screens (Pushed over root navigator)
    GoRoute(
      path: RouteNames.legalAdvisor,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LegalAdvisorScreen(),
    ),
    GoRoute(
      path: RouteNames.legalResearch,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LegalResearchScreen(),
    ),
    GoRoute(
      path: RouteNames.documentSimplifier,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DocumentSimplifierScreen(),
    ),
    GoRoute(
      path: RouteNames.drafting,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DraftingScreen(),
    ),
    GoRoute(
      path: RouteNames.noticeReply,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NoticeReplyScreen(),
    ),
    GoRoute(
      path: RouteNames.legalVault,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LegalVaultScreen(),
    ),
    GoRoute(
      path: RouteNames.scamDetector,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScamDetectorScreen(),
    ),
    GoRoute(
      path: RouteNames.evidenceTimeline,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EvidenceTimelineScreen(),
    ),
    GoRoute(
      path: RouteNames.lawyerPrep,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LawyerPrepScreen(),
    ),
    GoRoute(
      path: RouteNames.legalAid,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LegalAidScreen(),
    ),
    GoRoute(
      path: RouteNames.settings,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

