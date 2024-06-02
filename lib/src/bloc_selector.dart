import 'package:bloc/bloc.dart';
import 'package:bloc_get_it/src/bloc_builder.dart';
import 'package:bloc_get_it/src/bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

typedef BlocWidgetSelector<S, T> = T Function(S state);

class BlocSelector<B extends StateStreamable<S>, S, T> extends StatefulWidget {
  const BlocSelector({
    required this.selector,
    required this.builder,
    super.key,
    this.bloc,
  });

  final B? bloc;

  final BlocWidgetBuilder<T> builder;

  final BlocWidgetSelector<S, T> selector;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<B?>('bloc', bloc))
      ..add(ObjectFlagProperty<BlocWidgetBuilder<T>>.has('builder', builder))
      ..add(
        ObjectFlagProperty<BlocWidgetSelector<S, T>>.has(
          'selector',
          selector,
        ),
      );
  }
}

class _BlocSelectorState<B extends StateStreamable<S>, S, T>
    extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? GetIt.I.get();
    _state = widget.selector(_bloc.state);
  }

  @override
  void didUpdateWidget(BlocSelector<B, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? GetIt.I.get();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? GetIt.I.get();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      if (!identical(_bloc, GetIt.I.get())) setState(() {});
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder(context, _state),
    );
  }
}
