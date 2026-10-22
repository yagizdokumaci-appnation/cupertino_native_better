import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';

class _TestSheetRoute extends PageRoute<void> {
  @override
  bool get opaque => false;
  @override
  bool get maintainState => true;
  @override
  Color? get barrierColor => null;
  @override
  String? get barrierLabel => null;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);
  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is PageRoute;
  @override
  Widget buildPage(BuildContext context, Animation<double> a, Animation<double> s) =>
      const SizedBox();
}

void main() {
  testWidgets(
    'CNTabBar recreated behind a closing sheet refreshes labels once painted',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <String>[];

      messenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (call) async => null,
      );
      for (var id = 0; id < 20; id++) {
        messenger.setMockMethodCallHandler(
          MethodChannel('CupertinoNativeTabBar_$id'),
          (call) async {
            calls.add(call.method);
            if (call.method == 'getIntrinsicSize') {
              return {'width': 400.0, 'height': 63.0};
            }
            return null;
          },
        );
      }

      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        WidgetsApp(
          navigatorKey: navKey,
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [CNTabBarRouteObserver()],
          onGenerateRoute: (_) => PageRouteBuilder<void>(
            pageBuilder: (_, _, _) => Align(
              alignment: Alignment.bottomCenter,
              child: CNTabBar(
                items: const [
                  CNTabBarItem(label: 'Home', icon: CNSymbol('house')),
                  CNTabBarItem(label: 'Profile', icon: CNSymbol('person')),
                ],
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      navKey.currentState!.push(_TestSheetRoute());
      await tester.pumpAndSettle();

      navKey.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 401));
      calls.clear();
      await tester.pump(const Duration(milliseconds: 300));

      expect(calls, contains('refresh'));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 300));
      debugDefaultTargetPlatformOverride = null;
    },
    skip: !PlatformVersion.shouldUseNativeGlass,
  );

  testWidgets(
    'CNTabBar recreated after a sheet pushes props changed since first mount',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <MethodCall>[];

      messenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      for (var id = 0; id < 20; id++) {
        messenger.setMockMethodCallHandler(
          MethodChannel('CupertinoNativeTabBar_$id'),
          (call) async {
            calls.add(call);
            if (call.method == 'getIntrinsicSize') {
              return {'width': 400.0, 'height': 63.0};
            }
            return null;
          },
        );
      }

      final badge = ValueNotifier<String?>(null);
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        WidgetsApp(
          navigatorKey: navKey,
          color: const Color(0xFFFFFFFF),
          navigatorObservers: [CNTabBarRouteObserver()],
          onGenerateRoute: (_) => PageRouteBuilder<void>(
            pageBuilder: (_, _, _) => Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<String?>(
                valueListenable: badge,
                builder: (_, value, _) => CNTabBar(
                  items: [
                    CNTabBarItem(
                      label: 'Home',
                      icon: const CNSymbol('house'),
                      badge: value,
                    ),
                    const CNTabBarItem(
                      label: 'Profile',
                      icon: CNSymbol('person'),
                    ),
                  ],
                  currentIndex: 0,
                  onTap: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      badge.value = '3';
      await tester.pump(const Duration(milliseconds: 300));

      navKey.currentState!.push(_TestSheetRoute());
      await tester.pumpAndSettle();
      navKey.currentState!.pop();
      await tester.pumpAndSettle();

      final lastCreate = calls.lastIndexWhere((c) => c.method == 'create');
      final pushedBadges = calls
          .skip(lastCreate + 1)
          .where((c) => c.method == 'setBadges' || c.method == 'setItems')
          .map((c) => (c.arguments as Map)['badges']);
      expect(pushedBadges, contains(equals(['3', ''])));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 300));
      debugDefaultTargetPlatformOverride = null;
    },
    skip: !PlatformVersion.shouldUseNativeGlass,
  );
}
