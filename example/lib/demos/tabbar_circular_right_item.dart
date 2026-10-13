import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates `CNTabBar(split: true, circularRightItem: true)`: the trailing
/// item renders as a separate circular Liquid Glass button. Here "Scan" acts
/// as an action — tapping it doesn't change the selected tab.
class TabBarCircularRightItemDemoPage extends StatefulWidget {
  const TabBarCircularRightItemDemoPage({super.key});

  @override
  State<TabBarCircularRightItemDemoPage> createState() =>
      _TabBarCircularRightItemDemoPageState();
}

class _TabBarCircularRightItemDemoPageState
    extends State<TabBarCircularRightItemDemoPage> {
  static const _scanIndex = 2;

  int _index = 0;
  int _scanTaps = 0;
  bool _circular = true;

  void _onTap(int i) {
    setState(() {
      if (i == _scanIndex) {
        _scanTaps++;
      } else {
        _index = i;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Circular Right Item'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_index == 0 ? 'Tools' : 'Files'),
                    const SizedBox(height: 8),
                    Text('Scan tapped $_scanTaps times'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('circularRightItem'),
                        const SizedBox(width: 12),
                        CupertinoSwitch(
                          value: _circular,
                          onChanged: (v) => setState(() => _circular = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CNTabBar(
                items: const [
                  CNTabBarItem(label: 'Tools', icon: CNSymbol('printer')),
                  CNTabBarItem(label: 'Files', icon: CNSymbol('folder')),
                  CNTabBarItem(label: 'Scan', icon: CNSymbol('doc.viewfinder')),
                ],
                currentIndex: _index,
                onTap: _onTap,
                split: true,
                circularRightItem: _circular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
