import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geography_geyser/provider/auth_provider/signup_provider/signup_provider.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/delete_xp_provider.dart';
import 'package:geography_geyser/provider/module_provider/selecttime_provider.dart';
import 'package:geography_geyser/provider/module_provider/subject_provider.dart';
import 'package:geography_geyser/provider/settings_provider/account_delete_provider.dart';
import 'package:geography_geyser/provider/settings_provider/general_settings_provider.dart';
import 'package:geography_geyser/provider/settings_provider/privacy_settings.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/forgot_password/forgot_pass_provider.dart';
import 'package:geography_geyser/provider/forgot_password/new_pass_set_provider.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/splash/splash_screen.dart';
import 'package:geography_geyser/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => ProfileUpdateProvider()),
        ChangeNotifierProvider(create: (_) => PrivacySettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UserStatsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SelectTimeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => QuizFinishProvider()),
        ChangeNotifierProvider(create: (_) => DeleteXpProvider()),
        ChangeNotifierProvider(create: (_) => AccountDeleteProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => NewPassSetProvider()),
        ChangeNotifierProvider(create: (_) => OptionalModuleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Geography Geyser',
        theme: ThemeData(),
        home: child,
      ),
      child: SplashScreen(),
    );
  }
}
