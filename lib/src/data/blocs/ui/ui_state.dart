import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';

abstract class UIState extends Equatable {
  const UIState();
}

class UIStateInit extends UIState {
  @override
  List<Object> get props => [];
}


class UIStateLoading extends UIState {
  @override
  List<Object> get props => [];
}


class UIStateLoaded extends UIState {
  final Nav nav;
  UIStateLoaded(this.nav);
  @override
  List<Object> get props => [nav];
}


class UIStateGlobalChat extends UIState {

  @override
  List<Object> get props => [];
}

class UIStateChat extends UIState {
  final String uid;
  UIStateChat(this.uid);
  @override
  List<Object> get props => [];
}


