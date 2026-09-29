import 'package:flutter/material.dart';
import 'package:toast_kit/toast_kit.dart';

void main() => runApp(const ToastKitExampleApp());

class ToastKitExampleApp extends StatefulWidget {
  const ToastKitExampleApp({super.key});

  @override
  State<ToastKitExampleApp> createState() => _ToastKitExampleAppState();
}

class _ToastKitExampleAppState extends State<ToastKitExampleApp> {
  final _toastKey = GlobalKey<ToastHostState>();
  TextDirection _direction = TextDirection.ltr;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      builder: (context, child) => Directionality(
        textDirection: _direction,
        child: ToastHost(key: _toastKey, child: child!),
      ),
      home: ExampleHomePage(
        onToggleDirection: () => setState(() {
          _direction = _direction == TextDirection.ltr
              ? TextDirection.rtl
              : TextDirection.ltr;
        }),
        direction: _direction,
        show: (request) => _toastKey.currentState!.show(request),
        dismissAll: () => _toastKey.currentState!.dismissAll(),
      ),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({
    super.key,
    required this.onToggleDirection,
    required this.direction,
    required this.show,
    required this.dismissAll,
  });

  final VoidCallback onToggleDirection;
  final TextDirection direction;
  final ToastHandle Function(ToastRequest request) show;
  final VoidCallback dismissAll;

  static const _layoutKeys = [
    'flat',
    'filled',
    'outlined',
    'minimal',
    'banner'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('toast_kit example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Toggle LTR/RTL',
            onPressed: onToggleDirection,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Direction: ${direction.name}',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 16),
          const _SectionLabel('By tone (flat layout, top center)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tone in ToastTone.values)
                ElevatedButton(
                  onPressed: () => show(
                    ToastRequest(
                      title:
                          '${tone.name[0].toUpperCase()}${tone.name.substring(1)} toast',
                      message: 'This is a $tone-toned notification.',
                      tone: tone,
                    ),
                  ),
                  child: Text(tone.name),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel('By layout'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in _layoutKeys)
                OutlinedButton(
                  onPressed: () => show(
                    ToastRequest(
                      title: '$key layout',
                      message: 'Rendered with the "$key" layout.',
                      tone: ToastTone.info,
                      layoutKey: key,
                      placement: key == 'banner'
                          ? ToastPlacement.topCenter
                          : ToastPlacement.bottomCenter,
                    ),
                  ),
                  child: Text(key),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Placements'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final edge in ToastVerticalEdge.values)
                for (final anchor in ToastHorizontalAnchor.values)
                  OutlinedButton(
                    onPressed: () => show(
                      ToastRequest(
                        title: '${edge.name}/${anchor.name}',
                        placement: ToastPlacement(edge: edge, anchor: anchor),
                      ),
                    ),
                    child: Text('${edge.name} · ${anchor.name}'),
                  ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionLabel('Behaviors'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => show(
                  const ToastRequest(
                    title: 'Item deleted',
                    action: ToastAction(label: 'Undo', onPressed: _noop),
                  ),
                ),
                child: const Text('With action'),
              ),
              ElevatedButton(
                onPressed: () => show(
                  const ToastRequest(
                    title: 'Sticky notice',
                    message: 'Stays until you close it.',
                    duration: null,
                  ),
                ),
                child: const Text('Sticky (no timeout)'),
              ),
              ElevatedButton(
                onPressed: dismissAll,
                child: const Text('Dismiss all'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
