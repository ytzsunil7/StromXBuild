import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const StromXApp());

const _channel = MethodChannel('com.stromx.ide/native');

class StromXApp extends StatelessWidget {
  const StromXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'StromX Code Studio',
    theme: ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF0B0F14),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF35D07F), brightness: Brightness.dark),
    ),
    home: const StudioHome(),
  );
}

class StudioHome extends StatefulWidget {
  const StudioHome({super.key});
  @override
  State<StudioHome> createState() => _StudioHomeState();
}

class _StudioHomeState extends State<StudioHome> {
  int tab = 0;
  String fileName = 'main.py';
  String source = 'print("Hello from StromX Code Studio!")\n';
  final command = TextEditingController();
  final editor = TextEditingController(text: 'print("Hello from StromX Code Studio!")\n');
  final output = <String>['StromX Terminal v1.0', 'Android app sandbox shell. Type help to see supported commands.'];
  bool busy = false;

  Future<void> runCommand() async {
    final cmd = command.text.trim();
    if (cmd.isEmpty || busy) return;
    command.clear();
    setState(() { output.add('$ $cmd'); busy = true; });
    try {
      if (cmd == 'help') {
        output.add('Supported: help, pwd, ls, date, whoami, uname, clear, echo TEXT');
        output.add('Note: Android sandbox shell; this is not a full Linux distribution.');
      } else if (cmd == 'clear') {
        output.clear();
      } else {
        final result = await _channel.invokeMethod<String>('runCommand', {'command': cmd});
        output.add((result ?? '').trim().isEmpty ? '(no output)' : result!.trimRight());
      }
    } on PlatformException catch (e) {
      output.add('Error: ${e.message ?? e.code}');
    } catch (e) {
      output.add('Command unavailable: $e');
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> saveFile() async {
    setState(() => source = editor.text);
    try {
      final path = await _channel.invokeMethod<String>('saveFile', {'name': fileName, 'content': source});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: ${path ?? fileName}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  @override
  void dispose() { command.dispose(); editor.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.terminal, color: Color(0xFF35D07F)), SizedBox(width: 9), Text('StromX Code Studio', style: TextStyle(fontWeight: FontWeight.w700))]),
        actions: [IconButton(tooltip: 'Save file', onPressed: saveFile, icon: const Icon(Icons.save_outlined)), const SizedBox(width: 6)],
      ),
      body: SafeArea(child: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 4, 14, 12), padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: const Color(0xFF151C24), borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            _tabButton('Editor', Icons.code, 0), _tabButton('Terminal', Icons.terminal, 1), _tabButton('Projects', Icons.folder_open, 2),
          ]),
        ),
        Expanded(child: IndexedStack(index: tab, children: [_editorView(), _terminalView(), _projectsView()])),
      ])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.code), label: 'Editor'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'Terminal'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'Files'),
        ],
      ),
    );
  }

  Widget _tabButton(String label, IconData icon, int index) => Expanded(child: InkWell(
    borderRadius: BorderRadius.circular(11), onTap: () => setState(() => tab = index),
    child: Container(padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: tab == index ? const Color(0xFF24352E) : Colors.transparent, borderRadius: BorderRadius.circular(11)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 17, color: tab == index ? const Color(0xFF55E69A) : Colors.white60), const SizedBox(width: 6), Text(label, style: TextStyle(fontWeight: tab == index ? FontWeight.bold : FontWeight.normal))])),
  ));

  Widget _editorView() => Column(children: [
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 14), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: const BoxDecoration(color: Color(0xFF151C24), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      child: Row(children: [const Icon(Icons.circle, color: Color(0xFFFFC857), size: 9), const SizedBox(width: 9), Expanded(child: TextField(
        decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'filename.py'), controller: TextEditingController(text: fileName),
        onChanged: (v) => fileName = v.isEmpty ? 'main.py' : v,
      )), Text('PYTHON', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: .55), letterSpacing: 1.2))]),
    ),
    Expanded(child: Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF10161D), border: Border.all(color: const Color(0xFF26313C)), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
      child: TextField(controller: editor, expands: true, maxLines: null, minLines: null, keyboardType: TextInputType.multiline, style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.55, color: Color(0xFFD6E2EE)), decoration: const InputDecoration(border: InputBorder.none, hintText: '// Start coding...')),
    )),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 12), child: Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: saveFile, icon: const Icon(Icons.save), label: const Text('Save'))),
      const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: () { setState(() => tab = 1); command.text = 'python $fileName'; }, icon: const Icon(Icons.play_arrow), label: const Text('Run'))),
    ])),
  ]);

  Widget _terminalView() => Column(children: [
    Expanded(child: Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10), padding: const EdgeInsets.all(13), width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF05090D), border: Border.all(color: const Color(0xFF26313C)), borderRadius: BorderRadius.circular(12)),
      child: ListView(children: output.map((line) => Padding(padding: const EdgeInsets.only(bottom: 7), child: SelectableText(line, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: line.startsWith('$') ? const Color(0xFF55E69A) : const Color(0xFFD1DBE5)))).toList()),
    )),
    Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: Row(children: [
      const Text('$', style: TextStyle(color: Color(0xFF55E69A), fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(width: 9),
      Expanded(child: TextField(controller: command, onSubmitted: (_) => runCommand(), style: const TextStyle(fontFamily: 'monospace'), decoration: const InputDecoration(hintText: 'Enter command...', isDense: true, border: OutlineInputBorder()))),
      const SizedBox(width: 8), IconButton.filled(onPressed: busy ? null : runCommand, icon: const Icon(Icons.arrow_upward)),
    ])),
  ]);

  Widget _projectsView() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('WORKSPACE', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Color(0xFF55E69A))),
    const SizedBox(height: 12),
    Card(color: const Color(0xFF151C24), child: ListTile(leading: const Icon(Icons.folder, color: Color(0xFFFFC857)), title: const Text('StromX Workspace'), subtitle: const Text('App-private project directory'), trailing: const Icon(Icons.chevron_right), onTap: () {})),
    Card(color: const Color(0xFF151C24), child: ListTile(leading: const Icon(Icons.description_outlined), title: Text(fileName), subtitle: const Text('Current editor buffer'), trailing: const Icon(Icons.edit), onTap: () => setState(() => tab = 0))),
    const SizedBox(height: 16),
    const Text('Coming in next milestones', style: TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const _FeatureTile(icon: Icons.source, title: 'Git & GitHub', detail: 'Clone, commit, push and pull repositories'),
    const _FeatureTile(icon: Icons.extension, title: 'Language toolchains', detail: 'Install supported runtimes and compilers'),
    const _FeatureTile(icon: Icons.android, title: 'APK Builder', detail: 'Build Android APKs with a reproducible build pipeline'),
    const _FeatureTile(icon: Icons.smart_toy_outlined, title: 'Strom AI', detail: 'AI code generation, refactoring and debugging'),
  ]);
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.title, required this.detail});
  final IconData icon; final String title; final String detail;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: const Color(0xFF55E69A)), title: Text(title), subtitle: Text(detail));
}
