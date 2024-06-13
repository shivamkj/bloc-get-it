import 'package:bloc/bloc.dart';
import 'package:bloc_get_it/src/bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

abstract class BlocBuilderBase<B extends StateStreamable<S>, S> extends StatefulWidget {
  const BlocBuilderBase({
    super.key,
    this.bloc,
    this.buildWhen,
    this.instanceName,
  });

  final B? bloc;

  final BlocBuilderCondition<S>? buildWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc in the same scope
  final String? instanceName;

  Widget build(BuildContext context, S state);

  @override
  State<BlocBuilderBase<B, S>> createState() => _BlocBuilderBaseState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ObjectFlagProperty<BlocBuilderCondition<S>?>.has(
          'buildWhen',
          buildWhen,
        ),
      )
      ..add(DiagnosticsProperty<B?>('bloc', bloc));
  }
}

class BlocBuilder<B extends StateStreamable<S>, S> extends BlocBuilderBase<B, S> {
  const BlocBuilder({
    required this.builder,
    super.key,
    super.bloc,
    super.buildWhen,
    super.instanceName,
  });

  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context, S state) => builder(context, state);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<BlocWidgetBuilder<S>>.has('builder', builder),
    );
  }
}

class _BlocBuilderBaseState<B extends StateStreamable<S>, S> extends State<BlocBuilderBase<B, S>> {
  late B _bloc;
  late S _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
    _state = _bloc.state;
  }

  @override
  void didUpdateWidget(BlocBuilderBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = _bloc.state;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? GetIt.I.get<B>(instanceName: widget.instanceName);
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      if (!identical(
        _bloc,
        GetIt.I.get<B>(instanceName: widget.instanceName),
      )) {
        setState(() {});
      }
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.build(context, _state),
    );
  }
}
