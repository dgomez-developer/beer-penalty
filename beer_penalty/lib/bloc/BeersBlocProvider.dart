import 'package:beer_penalty/bloc/BeersBloc.dart';
import 'package:flutter/material.dart';

class BeersBlocProvider extends InheritedWidget {
  final BeersBloc bloc;
  final Widget child;

  BeersBlocProvider({this.bloc, this.child}) : super(child: child);
  static BeersBlocProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType(aspect: BeersBlocProvider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}