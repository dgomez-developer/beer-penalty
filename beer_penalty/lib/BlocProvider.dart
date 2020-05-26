import 'package:flutter/widgets.dart';
import 'IBloc.dart';

class BlocProvider<T extends IBloc> extends StatefulWidget {
  final Widget child;
  final T bloc;

  const BlocProvider({Key key, @required this.bloc, @required this.child})
      : super(key: key);

  static T of<T extends IBloc>(BuildContext context) {
    final type = _providerType<BlocProvider<T>>();
    final BlocProvider<T> provider = findAncestorWidgetOfExactType(type);
    return provider.bloc;
  }

  static Type _providerType<T>() => T;

  @override
  State createState() => _BlocProviderState();
}

class _BlocProviderState extends State<BlocProvider> {

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }
}