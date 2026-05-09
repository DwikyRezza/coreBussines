// ============================================================
// CORE: Router — App Navigation (go_router)
// lib/core/router/app_router.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Onboarding & Auth
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

// Home & Shell
import '../../features/home/presentation/pages/home_page.dart';
import '../shell/app_shell.dart';

// Transactions
import '../../features/transactions/presentation/pages/history_page.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/transactions/presentation/pages/edit_transaction_page.dart';
import '../../features/transactions/presentation/pages/transaction_detail_page.dart';
import '../../features/transactions/presentation/pages/ai_detection_page.dart';
import '../../features/transactions/presentation/pages/camera_scan_page.dart';
import '../../features/transactions/presentation/pages/scan_receipt_intro_page.dart';
import '../../features/transactions/presentation/pages/scan_receipt_result_page.dart';
import '../../features/transactions/presentation/pages/invoice_detail_page.dart';

// Analytics
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/analytics/presentation/pages/analytics_overview_page.dart';
import '../../features/analytics/presentation/pages/financial_overview_page.dart';
import '../../features/analytics/presentation/pages/smart_ai_insights_page.dart';
import '../../features/analytics/presentation/pages/report_export_page.dart';
import '../../features/analytics/presentation/pages/business_score_page.dart';
import '../../features/analytics/presentation/pages/financial_goals_page.dart';

// Schedule
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/schedule/presentation/pages/add_schedule_page.dart';

// Notifications
import '../../features/notifications/presentation/pages/recent_alerts_page.dart';
import '../../features/notifications/presentation/pages/notifications_empty_page.dart';

// Settings & Access
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/dashboard_customize_page.dart';
import '../../features/settings/presentation/pages/manager_access_page.dart';
import '../../features/settings/presentation/pages/tag_management_page.dart';
import '../../features/settings/presentation/pages/team_management_page.dart';
import '../../features/settings/presentation/pages/sync_settings_page.dart';
import '../../features/settings/presentation/pages/edit_profile_page.dart';
import '../../features/settings/presentation/pages/security_settings_page.dart';
import '../../features/settings/presentation/pages/empty_states_overview_page.dart';

// Additional Features
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/search/presentation/pages/search_empty_page.dart';
import '../../features/wallets/presentation/pages/wallets_page.dart';
import '../../features/business/presentation/pages/business_portfolio_page.dart';
import '../../features/inventory/presentation/pages/inventory_overview_page.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';

abstract class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/';
  
  // Transactions
  static const String history = '/history';
  static const String addTransaction = '/transaction/add';
  static const String editTransaction = '/transaction/:id/edit';
  static const String transactionDetail = '/transaction/detail/:id';
  static const String aiDetection = '/transaction/ai-detection';
  static const String cameraScan = '/transaction/scan';
  static const String scanReceiptIntro = '/transaction/scan/intro';
  static const String scanReceiptResult = '/transaction/scan/result';
  static const String invoiceDetail = '/transaction/invoice';

  // Analytics
  static const String analytics = '/analytics';
  static const String analyticsOverview = '/analytics/overview';
  static const String financialOverview = '/analytics/financial';
  static const String smartAiInsights = '/analytics/insights';
  static const String reportExport = '/analytics/export';
  static const String businessScore = '/analytics/score';
  static const String financialGoals = '/analytics/goals';

  // Schedule
  static const String schedule = '/schedule';
  static const String addSchedule = '/schedule/add';

  // Notifications
  static const String alerts = '/alerts';
  static const String notificationsEmpty = '/notifications/empty';

  // Settings
  static const String settings = '/settings';
  static const String dashboardCustomize = '/settings/dashboard';
  static const String managerAccess = '/settings/manager-access';
  static const String tagManagement = '/settings/tags';
  static const String teamManagement = '/settings/team';
  static const String syncSettings = '/settings/sync';
  static const String securitySettings = '/settings/security';
  static const String emptyStatesOverview = '/settings/empty-states';
  
  // Profile (Non-shell)
  static const String editProfile = '/profile/edit';

  // Other Core Features
  static const String search = '/search';
  static const String searchEmpty = '/search/empty';
  static const String wallets = '/wallets';
  static const String businessPortfolio = '/business/portfolio';
  static const String inventoryOverview = '/inventory/overview';
  static const String catalog = '/catalog';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  routes: [
    // Top Level Routes
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      name: 'addTransaction',
      builder: (context, state) => const AddTransactionPage(),
    ),
    GoRoute(
      path: AppRoutes.aiDetection,
      name: 'aiDetection',
      builder: (context, state) => const AiDetectionPage(),
    ),
    GoRoute(
      path: AppRoutes.cameraScan,
      name: 'cameraScan',
      builder: (context, state) => const CameraScanPage(),
    ),
    GoRoute(
      path: AppRoutes.scanReceiptIntro,
      name: 'scanReceiptIntro',
      builder: (context, state) => const ScanReceiptIntroPage(),
    ),
    GoRoute(
      path: AppRoutes.scanReceiptResult,
      name: 'scanReceiptResult',
      builder: (context, state) => const ScanReceiptResultPage(),
    ),
    GoRoute(
      path: AppRoutes.reportExport,
      name: 'reportExport',
      builder: (context, state) => const ReportExportPage(),
    ),
    GoRoute(
      path: AppRoutes.addSchedule,
      name: 'addSchedule',
      builder: (context, state) => const AddSchedulePage(),
    ),
    GoRoute(
      path: AppRoutes.alerts,
      name: 'alerts',
      builder: (context, state) => const RecentAlertsPage(),
    ),
    GoRoute(
      path: AppRoutes.notificationsEmpty,
      name: 'notificationsEmpty',
      builder: (context, state) => const NotificationsEmptyPage(),
    ),
    GoRoute(
      path: AppRoutes.managerAccess,
      name: 'managerAccess',
      builder: (context, state) => const ManagerAccessPage(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfilePage(),
    ),

    // Shell Route (Bottom Navigation)
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.history,
          name: 'history',
          builder: (context, state) => const HistoryPage(),
        ),
        GoRoute(
          path: AppRoutes.analytics,
          name: 'analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
        GoRoute(
          path: AppRoutes.analyticsOverview,
          name: 'analyticsOverview',
          builder: (context, state) => const AnalyticsOverviewPage(),
        ),
        GoRoute(
          path: AppRoutes.financialOverview,
          name: 'financialOverview',
          builder: (context, state) => const FinancialOverviewPage(),
        ),
        GoRoute(
          path: AppRoutes.smartAiInsights,
          name: 'smartAiInsights',
          builder: (context, state) => const SmartAiInsightsPage(),
        ),
        GoRoute(
          path: AppRoutes.businessScore,
          name: 'businessScore',
          builder: (context, state) => const BusinessScorePage(),
        ),
        GoRoute(
          path: AppRoutes.financialGoals,
          name: 'financialGoals',
          builder: (context, state) => const FinancialGoalsPage(),
        ),
        GoRoute(
          path: AppRoutes.schedule,
          name: 'schedule',
          builder: (context, state) => const SchedulePage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.tagManagement,
          name: 'tagManagement',
          builder: (context, state) => const TagManagementPage(),
        ),
        GoRoute(
          path: AppRoutes.teamManagement,
          name: 'teamManagement',
          builder: (context, state) => const TeamManagementPage(),
        ),
        GoRoute(
          path: AppRoutes.syncSettings,
          name: 'syncSettings',
          builder: (context, state) => const SyncSettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.securitySettings,
          name: 'securitySettings',
          builder: (context, state) => const SecuritySettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.emptyStatesOverview,
          name: 'emptyStatesOverview',
          builder: (context, state) => const EmptyStatesOverviewPage(),
        ),
        GoRoute(
          path: AppRoutes.editTransaction,
          name: 'editTransaction',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return EditTransactionPage(transactionId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.search,
          name: 'search',
          builder: (context, state) => const SearchPage(),
        ),
        GoRoute(
          path: AppRoutes.searchEmpty,
          name: 'searchEmpty',
          builder: (context, state) => const SearchEmptyPage(),
        ),
        GoRoute(
          path: AppRoutes.wallets,
          name: 'wallets',
          builder: (context, state) => const WalletsPage(),
        ),
        GoRoute(
          path: AppRoutes.businessPortfolio,
          name: 'businessPortfolio',
          builder: (context, state) => const BusinessPortfolioPage(),
        ),
        GoRoute(
          path: AppRoutes.inventoryOverview,
          name: 'inventoryOverview',
          builder: (context, state) => const InventoryOverviewPage(),
        ),
        GoRoute(
          path: AppRoutes.catalog,
          name: 'catalog',
          builder: (context, state) => const CatalogPage(),
        ),
      ],
    ),
    
    // Other Details
    GoRoute(
      path: AppRoutes.transactionDetail,
      name: 'transactionDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TransactionDetailPage(transactionId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.invoiceDetail,
      name: 'invoiceDetail',
      builder: (context, state) => const InvoiceDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboardCustomize,
      name: 'dashboardCustomize',
      builder: (context, state) => const DashboardCustomizePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
