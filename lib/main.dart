import 'package:flutter/material.dart';
import 'pages/levels_progress_page.dart';
import 'services/progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProgressService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanzi Learner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LevelsProgressPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
