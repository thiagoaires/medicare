import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/ui/view_model/auth_view_model.dart';
import 'features/auth/ui/widgets/login_screen.dart';
import 'features/core/ui/widgets/splash_screen.dart';
import 'features/home/ui/widgets/home_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Inicializa injeção de dependência e Parse
  runApp(const MedicareApp());
}

class MedicareApp extends StatelessWidget {
  const MedicareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<AuthViewModel>()),
      ],
      child: MaterialApp(
        title: 'Medicare TCC',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/home': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return HomeScreen(userType: args);
          },
        },
      ),
    );
  }
}
