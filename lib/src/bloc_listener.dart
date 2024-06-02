import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

typedef BlocListenerCondition<S> = bool Function(S previous, S current);

abstract class BlocListenerBase<B extends StateStreamable<S>, S>
    extends StatefulWidget {
  const BlocListenerBase({
    required this.listener,
    required this.child,
    super.key,
    this.bloc,
    this.listenWhen,
    this.instanceName,
  });

  final Widget child;

  final B? bloc;

  final BlocWidgetListener<S> listener;

  final BlocListenerCondition<S>? listenWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc in the same scope
  final String? instanceName;

  @override
  State<BlocListenerBase<B, S>> createState() => _BlocListenerBaseState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(ObjectFlagProperty<BlocWidgetListener<S>>.has('listener', listener))
      ..add(
        ObjectFlagProperty<BlocListenerCondition<S>?>.has(
          'listenWhen',
          listenWhen,
        ),
      );
  }
}

class BlocListener<B extends StateStreamable<S>, S>
    extends BlocListenerBase<B, S> {
  const BlocListener({
    required super.listener,
    required super.child,
    super.key,
    super.bloc,
    super.listenWhen,
    super.instanceName,
  });
}

class _BlocListenerBaseState<B extends StateStreamable<S>, S>
    extends State<BlocListenerBase<B, S>> {
  StreamSubscription<S>? _subscription;
  late B _bloc;
  late S _previousState;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
    _previousState = _bloc.state;
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocListenerBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc =
        oldWidget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
        _bloc = currentBloc;
        _previousState = _bloc.state;
      }
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc =
        widget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
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
  Widget build(BuildContext context) {
    return widget.child;
  }
}
