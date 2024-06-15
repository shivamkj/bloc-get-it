import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

typedef BlocCondition<S> = bool Function(S previous, S current);

class BlocListener<B extends StateStreamable<S>, S> extends StatefulWidget {
  const BlocListener({
    required this.listener,
    required this.child,
    this.listenWhen,
    this.instanceName,
    super.key,
  });

  final Widget child;

  final BlocWidgetListener<S> listener;

  final BlocCondition<S>? listenWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc of same type in the same scope
  final String? instanceName;

  @override
  State<BlocListener<B, S>> createState() => _BlocListenerState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<BlocWidgetListener<S>>.has('listener', listener))
      ..add(ObjectFlagProperty<BlocCondition<S>?>.has('listenWhen', listenWhen));
  }
}

class _BlocListenerState<B extends StateStreamable<S>, S> extends State<BlocListener<B, S>> {
  StreamSubscription<S>? _subscription;
  late B _bloc;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    _previousState = _bloc.state;
    _subscribe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = bloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.stream.listen((state) {
      if (widget.listenWhen?.call(_previousState, state) ?? true) {
        widget.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
