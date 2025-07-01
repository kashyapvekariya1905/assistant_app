import 'package:flutter/material.dart';
import '../features/user/view/user_page.dart';
import '../features/navigator/view/navigator_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AR Aid',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Aid')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserPage()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60), 
              ),
              child: const Text("User", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NavigatorPage()),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 60), 
              ),
              child: const Text("Aid", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
