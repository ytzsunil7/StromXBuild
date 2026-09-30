import 'package:flutter/material.dart';

void main() {
  runApp(const CloudIdeApp());
}

class CloudIdeApp extends StatelessWidget {
  const CloudIdeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StromX Cloud IDE',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(color: Color(0xFF252526)),
      ),
      home: const WorkspaceScreen(),
    );
  }
}

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace: StromXBuild', style: TextStyle(fontSize: 14)),
        actions: [
          IconButton(icon: const Icon(Icons.build, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble_outline, size: 20), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Code Editor Area
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E1E1E),
              child: const Text(
                '// Write your code here...\n\nvoid main() {\n  print("Hello from StromX IDE");\n}',
                style: TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 16),
              ),
            ),
          ),
          Container(height: 1, color: Colors.grey.shade800),
          // Terminal Area
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              child: const Text(
                'root@stromx-workspace:~# _\nTerminal connected successfully.',
                style: TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
