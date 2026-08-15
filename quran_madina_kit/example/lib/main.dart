import 'package:flutter/material.dart';
import 'package:quran_madina_kit/quran_madina_kit.dart';

void main() => runApp(const ExampleApp());

/// The five fonts with pre-built databases. Only Hafs ships bundled by default;
/// the others need their `assets/db/<stem>/` folders declared in pubspec.yaml.
const _fonts = [
  'Hafs',
  'Uthman',
  'Amiri Quran',
  'Amiri Quran Colored',
  'me_quran',
];

enum Demo { page, verse, words, marks }

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  Demo _demo = Demo.page;
  String _font = 'Hafs';
  double _fontSize = 16;
  MadinaStretchMode _stretch = MadinaStretchMode.stored;
  int _page = 106;
  bool _dark = false;

  Widget get _view => switch (_demo) {
    Demo.page => QuranMadinaView(page: _page, headless: true),
    Demo.verse => const QuranMadinaView(sura: 2, aya: '8-10'),
    Demo.words => const QuranMadinaView(sura: 1, aya: '7', words: '1-14'),
    Demo.marks => const QuranMadinaView(
      sura: 1,
      aya: '1',
      highlight: '2-3',
      error: '5',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: _dark ? Brightness.dark : Brightness.light),
      home: MadinaScope(
        config: MadinaConfig(
          font: _font,
          fontSize: _fontSize,
          stretchMode: _stretch,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('quran_madina_kit'),
            actions: [
              IconButton(
                icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => setState(() => _dark = !_dark),
              ),
            ],
          ),
          body: Column(
            children: [
              _controls(),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFFF5F5DC).withValues(alpha: 0.35),
                      child: _view,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controls() => Padding(
    padding: const EdgeInsets.all(12),
    child: Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<Demo>(
          segments: const [
            ButtonSegment(value: Demo.page, label: Text('page')),
            ButtonSegment(value: Demo.verse, label: Text('sura/aya')),
            ButtonSegment(value: Demo.words, label: Text('words')),
            ButtonSegment(value: Demo.marks, label: Text('highlight')),
          ],
          selected: {_demo},
          onSelectionChanged: (s) => setState(() => _demo = s.first),
        ),
        DropdownButton<String>(
          value: _font,
          items: [
            for (final f in _fonts) DropdownMenuItem(value: f, child: Text(f)),
          ],
          onChanged: (v) => setState(() => _font = v!),
        ),
        SizedBox(
          width: 260,
          child: Row(
            children: [
              Text('${_fontSize.toStringAsFixed(0)}px'),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 6,
                  max: 40,
                  divisions: 34,
                  onChanged: (v) => setState(() => _fontSize = v),
                ),
              ),
            ],
          ),
        ),
        SegmentedButton<MadinaStretchMode>(
          segments: const [
            ButtonSegment(
              value: MadinaStretchMode.stored,
              label: Text('stored'),
            ),
            ButtonSegment(
              value: MadinaStretchMode.measured,
              label: Text('measured'),
            ),
          ],
          selected: {_stretch},
          onSelectionChanged: (s) => setState(() => _stretch = s.first),
        ),
        if (_demo == Demo.page)
          SizedBox(
            width: 220,
            child: Row(
              children: [
                Text('p$_page'),
                Expanded(
                  child: Slider(
                    value: _page.toDouble(),
                    min: 1,
                    max: 604,
                    onChanged: (v) => setState(() => _page = v.round()),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
