import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

class BlocInstances<T extends StateStreamableSource<Object?>> {
  const BlocInstances({
    required this.factoryFunc,
    this.instanceName,
  });

  /// A Function which returns the instance of [Bloc]
  final FactoryFunc<T> factoryFunc;

  /// [instanceName] if you provided is used for registering and getting bloc instance from [GetIt].
  /// This will be required for using 2 bloc of same type in the same scope
  final String? instanceName;

  void register() {
    GetIt.I.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      dispose: (b) => b.close(),
    );
  }

  void unregister() {
    GetIt.I.unregister<T>(instanceName: instanceName);
  }
}

class BlocMultiInject extends StatefulWidget {
  const BlocMultiInject({
    required this.blocs,
    this.child,
    super.key,
  });

  final List<BlocInstances> blocs;

  /// Widget which will be placed below this widget in widget tree
  final Widget? child;

  @override
  State<BlocMultiInject> createState() => _BlocMultiInjectState();
}

class _BlocMultiInjectState extends State<BlocMultiInject> {
  @override
  void initState() {
    for (final bloc in widget.blocs) {
      bloc.register();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final bloc in widget.blocs) {
      bloc.unregister();
    }
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
