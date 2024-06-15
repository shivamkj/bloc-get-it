import 'package:bloc/bloc.dart';
import 'package:bloc_get_it/src/bloc_builder.dart';
import 'package:bloc_get_it/src/bloc_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class BlocConsumer<B extends StateStreamable<S>, S> extends StatelessWidget {
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

  final BlocCondition<S>? buildWhen;

  final BlocCondition<S>? listenWhen;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc of same type in the same scope
  final String? instanceName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: builder,
      instanceName: instanceName,
      buildWhen: (previous, current) {
        if (listenWhen?.call(previous, current) ?? true) {
          listener(context, current);
        }
        return buildWhen?.call(previous, current) ?? true;
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<BlocWidgetBuilder<S>>.has('builder', builder))
      ..add(ObjectFlagProperty<BlocWidgetListener<S>>.has('listener', listener))
      ..add(ObjectFlagProperty<BlocCondition<S>?>.has('buildWhen', buildWhen))
      ..add(ObjectFlagProperty<BlocCondition<S>?>.has('listenWhen', listenWhen));
  }
}
