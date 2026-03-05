import 'package:bhandarx_flutter/app/themes/app_theme.dart';
import 'package:bhandarx_flutter/app/themes/theme_mode_provider.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/providers/language_provider.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/login_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/logout_confirmation_screen.dart';
import 'package:bhandarx_flutter/features/auth/presentation/pages/register_screen.dart';
import 'package:bhandarx_flutter/features/home/presentation/pages/home_screen.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:bhandarx_flutter/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/change_password_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/profile_screen.dart';
import 'package:bhandarx_flutter/features/profile/presentation/pages/settings_screen.dart';
import 'package:bhandarx_flutter/features/splash/presentation/pages/splash_screen.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/customers_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/products_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/sales_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/transaction_insights_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/transactions_page.dart';
import 'package:bhandarx_flutter/features/workspace/presentation/pages/workspace_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final locale = language == AppLanguage.nepali
        ? const Locale('ne')
        : const Locale('en');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BhandarX',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ne')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
        EditProfileScreen.routeName: (_) => const EditProfileScreen(),
        ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        LogoutConfirmationScreen.routeName: (_) =>
            const LogoutConfirmationScreen(),
        WorkspaceDashboardScreen.routeName: (_) =>
            const WorkspaceDashboardScreen(),
        ProductsPage.routeName: (_) => const ProductsPage(),
        CustomersPage.routeName: (_) => const CustomersPage(),
        SalesPage.routeName: (_) => const SalesPage(),
        TransactionsPage.routeName: (_) => const TransactionsPage(),
        TransactionInsightsPage.routeName: (_) =>
            const TransactionInsightsPage(),
      },
    );
  }
}
