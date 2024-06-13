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
    this.instanceName,
  });

  final BlocWidgetBuilder<T> builder;

  final BlocWidgetSelector<S, T> selector;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc in the same scope
  final String? instanceName;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<BlocWidgetBuilder<T>>.has('builder', builder))
      ..add(
        ObjectFlagProperty<BlocWidgetSelector<S, T>>.has(
          'selector',
          selector,
        ),
      );
  }
}

class _BlocSelectorState<B extends StateStreamable<S>, S, T> extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    _state = widget.selector(_bloc.state);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = GetIt.I.get<B>(instanceName: widget.instanceName);
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = widget.selector(_bloc.state);
    }
  }

  @override
  Widget build(BuildContext context) {
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
