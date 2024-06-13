import 'package:bloc/bloc.dart';
import 'package:bloc_get_it/src/bloc_builder.dart';
import 'package:bloc_get_it/src/bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class BlocConsumer<B extends StateStreamable<S>, S> extends StatefulWidget {
  const BlocConsumer({
    required this.builder,
    required this.listener,
    super.key,
    this.buildWhen,
    this.listenWhen,
    this.instanceName,
  });

  final BlocWidgetBuilder<S> builder;

  final BlocWidgetListener<S> listener;

  final BlocBuilderCondition<S>? buildWhen;

  final BlocListenerCondition<S>? listenWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc in the same scope
  final String? instanceName;

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<BlocWidgetBuilder<S>>.has('builder', builder))
      ..add(ObjectFlagProperty<BlocWidgetListener<S>>.has('listener', listener))
      ..add(
        ObjectFlagProperty<BlocBuilderCondition<S>?>.has(
          'buildWhen',
          buildWhen,
        ),
      )
      ..add(
        ObjectFlagProperty<BlocListenerCondition<S>?>.has(
          'listenWhen',
          listenWhen,
        ),
      );
  }
}

class _BlocConsumerState<B extends StateStreamable<S>, S> extends State<BlocConsumer<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    if (_bloc != bloc) _bloc = bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: _bloc,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }
}
