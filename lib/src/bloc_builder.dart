import 'package:bloc/bloc.dart';
import 'package:bloc_get_it/src/bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

class BlocBuilder<B extends StateStreamable<S>, S> extends StatefulWidget {
  const BlocBuilder({
    required this.builder,
    super.key,
    this.buildWhen,
    this.instanceName,
  });

  final BlocWidgetBuilder<S> builder;

  final BlocCondition<S>? buildWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc of same type in the same scope
  final String? instanceName;

  @override
  State<BlocBuilder<B, S>> createState() => _BlocBuilderBaseState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<BlocWidgetBuilder<S>>.has('builder', builder))
      ..add(ObjectFlagProperty<BlocCondition<S>?>.has('buildWhen', buildWhen));
  }
}

class _BlocBuilderBaseState<B extends StateStreamable<S>, S> extends State<BlocBuilder<B, S>> {
  late B _bloc;
  late S _state;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    _state = _bloc.state;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = _bloc.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      instanceName: widget.instanceName,
      listenWhen: widget.buildWhen,
      listener: (context, state) => setState(() => _state = state),
      child: widget.builder(context, _state),
    );
  }
}
