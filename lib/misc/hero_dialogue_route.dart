import 'package:flutter/material.dart';

/// Custom [PageRoute] that creates an overlay dialog (popup effect).
/// Best used with a [Hero] animation.

class HeroDialogueRoute<T> extends PageRoute<T> {
  HeroDialogueRoute({
    required WidgetBuilder builder,
  })  : _builder = builder,
        super();

  final WidgetBuilder _builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => const Color.fromARGB(97, 0, 0, 0);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialogue open';
}
