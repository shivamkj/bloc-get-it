## Bloc (GetIt Implementation)

By default BLoC package in Flutter uses provider for dependency injection (for adding BLoC in widget tree & lifecycle). Although provider added a good start but it has some shortcoming. Major issue with provider to start this project was, provider depends upon type of class to find BLoC up in the widget tree, that means only one BLoC can be used in a screen without any hack. This makes it difficult to work with reusable BLoCs. This packages uses GetIt for dependency injection instead of provider with almost same APIs, for using BLoC inside Flutter.

## Features

- Ability to reuse same Bloc multiple times.
- Access Bloc without using context.
- No need for extra nested widget to get correct context.

## Getting started

BlocProvider/MultiBlocProvider have their equivalent BlocInject/BlocMultiInject. Rest classes - BlocListener, BlocBuilder, BlocConsumer, BlocSelector have same signature, just one extra optional parameter instanceName, so same class type can be reused multiple times. RepositoryProvider/MultiRepositoryProvider is missing for now.
