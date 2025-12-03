import 'package:cms/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cms/globals/auth_service.dart';
import 'package:cms/globals/app_state.dart';

@NowaGenerated()
late final SharedPreferences sharedPrefs;

@NowaGenerated()
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

@NowaGenerated({'visibleInNowa': false})
class MyApp extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (context) => AuthService(),
      child: ChangeNotifierProvider<AppState>(
        create: (context) => AppState(),
        builder: (context, child) => MaterialApp(
          theme: AppState.of(context).theme,
          initialRoute: 'HomePage',
          routes: {'HomePage': (context) => const LoginScreen()},
        ),
      ),
    );
  }
}
