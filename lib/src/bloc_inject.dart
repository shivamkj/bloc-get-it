import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class BlocInject<T extends StateStreamableSource<Object?>> extends StatefulWidget {
  const BlocInject({
    required this.factoryFunc,
    this.child,
    this.instanceName,
    super.key,
  });

  /// A Function which returns the instance of [Bloc]
  final FactoryFunc<T> factoryFunc;

  /// Widget which will be placed below this widget in widget tree
  final Widget? child;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc in the same scope
  final String? instanceName;

  @override
  State<BlocInject<T>> createState() => _BlocInjectState<T>();
}

class _BlocInjectState<T extends StateStreamableSource<Object?>> extends State<BlocInject<T>> {
  @override
  void initState() {
    GetIt.I.registerLazySingleton<T>(
      widget.factoryFunc,
      instanceName: widget.instanceName,
      dispose: (bloc) => bloc.close(),
    );
    super.initState();
  }

  @override
  void dispose() {
    GetIt.I.unregister<T>(instanceName: widget.instanceName);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    } else {
      return const SizedBox.shrink();
    }
  }
}
