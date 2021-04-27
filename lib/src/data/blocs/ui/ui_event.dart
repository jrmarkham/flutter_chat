import 'package:chat/src/globals.dart';
import 'package:equatable/equatable.dart';

abstract class UIEvent extends Equatable {
  const UIEvent();
}


class UIEventInit extends UIEvent{
  final Nav nav;
  UIEventInit(this.nav);

  @override
  List<Object> get props => [nav];
}

class UIEventSetPage extends UIEvent{
  final Nav nav;
  UIEventSetPage(this.nav);

  @override
  List<Object> get props => [nav];
}

class UIEventLoadGlobalChat extends UIEvent{
  @override
  List<Object> get props => [];
}

class UIEventLoadChat extends UIEvent{
  final String uid;
  UIEventLoadChat(this.uid);
  @override
  List<Object> get props => [];
}
