import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
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
      providers: [ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>())],
      child: MaterialApp(
        title: 'Medicare TCC',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginPage(),
      ),
    );
  }
}
