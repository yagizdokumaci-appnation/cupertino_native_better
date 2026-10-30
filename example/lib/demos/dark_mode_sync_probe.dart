import 'dart:async';

import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';

/// Probe for app-theme brightness reaching native views.
///
/// Mounts CNFloatingIsland, CNSearchBar and CNGlassButtonGroup under a dark
/// app theme, flips the theme to light after 3 s, then opens a CNActionSheet
/// under the light theme. Run it with the simulator in dark appearance so the
/// app theme and the system disagree. Each settled phase logs a `CNPROBE`
/// marker for the screenshot script to wait on.
class DarkModeSyncProbePage extends StatefulWidget {
  const DarkModeSyncProbePage({super.key, this.label = ''});

  final String label;

  @override
  State<DarkModeSyncProbePage> createState() => _DarkModeSyncProbePageState();
}

class _DarkModeSyncProbePageState extends State<DarkModeSyncProbePage> {
  bool _dark = true;
  late BuildContext _themedContext;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _timers
      ..add(Timer(const Duration(seconds: 3), () {
        setState(() => _dark = false);
      }))
      ..add(Timer(const Duration(seconds: 6), () {
        debugPrint('CNPROBE widgets');
      }))
      ..add(Timer(const Duration(seconds: 10), _openSheet))
      ..add(Timer(const Duration(seconds: 13), () {
        debugPrint('CNPROBE sheet');
      }));
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _openSheet() {
    CNActionSheet.show<String>(
      context: _themedContext,
      title: 'App theme: light',
      message: 'Simulator appearance: dark',
      actions: const [
        CNActionSheetAction(label: 'Delete', value: 'd', isDestructive: true),
        CNActionSheetAction(label: 'Duplicate', value: 'dup'),
      ],
      cancelLabel: 'Cancel',
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _dark ? Brightness.dark : Brightness.light;
    return CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: Builder(
        builder: (themedContext) {
          _themedContext = themedContext;
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('Dark mode sync ${widget.label}'.trim()),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'App theme: ${brightness.name}',
                    style: CupertinoTheme.of(
                      themedContext,
                    ).textTheme.navTitleTextStyle,
                  ),
                  const SizedBox(height: 24),
                  const Text('CNFloatingIsland'),
                  SizedBox(
                    height: 72,
                    child: CNFloatingIsland(
                      collapsedWidth: 240,
                      collapsedHeight: 52,
                      margin: EdgeInsets.zero,
                      collapsed: const Text('Now Playing'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('CNSearchBar'),
                  const SizedBox(height: 8),
                  const CNSearchBar(
                    expandable: false,
                    placeholder: 'Search',
                    showCancelButton: false,
                  ),
                  const SizedBox(height: 24),
                  const Text('CNGlassButtonGroup'),
                  const SizedBox(height: 8),
                  CNGlassButtonGroup(
                    axis: Axis.horizontal,
                    spacing: 8,
                    buttons: [
                      CNButtonData(
                        label: 'Edit',
                        onPressed: () {},
                        config: const CNButtonDataConfig(
                          style: CNButtonStyle.glass,
                        ),
                      ),
                      CNButtonData(
                        label: 'Share',
                        onPressed: () {},
                        config: const CNButtonDataConfig(
                          style: CNButtonStyle.glass,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
