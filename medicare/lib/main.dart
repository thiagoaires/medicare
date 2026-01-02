import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <--- Importe isso

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carrega o arquivo .env
  await dotenv.load(fileName: ".env");

  // 2. Recupera as chaves (com um valor padrão de segurança caso falhe)
  final keyApplicationId = dotenv.env['APP_ID'] ?? '';
  final keyClientKey = dotenv.env['CLIENT_KEY'] ?? '';
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  // Verifica se as chaves foram carregadas (opcional, mas bom para debug)
  if (keyApplicationId.isEmpty || keyClientKey.isEmpty) {
    throw Exception('CHAVES DO PARSE NÃO ENCONTRADAS NO .ENV');
  }

  // 3. Inicializa o Parse
  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(const MedicareApp());
}

class MedicareApp extends StatelessWidget {
  const MedicareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicare TCC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset('assets/images/logo.webp', width: 150)],
          ),
        ),
      ),
    );
  }
}
