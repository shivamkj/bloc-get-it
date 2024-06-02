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
    this.bloc,
    this.buildWhen,
    this.listenWhen,
  });

  final B? bloc;

  final BlocWidgetBuilder<S> builder;

  final BlocWidgetListener<S> listener;

  final BlocBuilderCondition<S>? buildWhen;

  final BlocListenerCondition<S>? listenWhen;

  @override
  State<BlocConsumer<B, S>> createState() => _BlocConsumerState<B, S>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
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

class _BlocConsumerState<B extends StateStreamable<S>, S>
    extends State<BlocConsumer<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.I.get<B>();
  }

  @override
  void didUpdateWidget(BlocConsumer<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? GetIt.I.get<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) _bloc = currentBloc;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? GetIt.I.get<B>();
    if (_bloc != bloc) _bloc = bloc;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // TODO(anyone): Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      if (!identical(_bloc, GetIt.I.get<B>())) setState(() {});
    }
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
