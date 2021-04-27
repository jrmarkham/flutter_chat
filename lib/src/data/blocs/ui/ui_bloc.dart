import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chat/src/globals.dart';
import './bloc.dart';

class UIBloc extends Bloc<UIEvent, UIState> {
  @override
  UIState get initialState => UIStateInit();

  Nav _nav = Nav.home;

  @override
  Stream<UIState> mapEventToState(
    UIEvent event,
  ) async* {
    if(event is  UIEventInit){
      yield UIStateLoading();
      _nav = event.nav;
      yield UIStateLoaded(_nav);
    }

    if(event is UIEventSetPage){
      yield UIStateLoading();
      _nav = event.nav;
      yield UIStateLoaded(_nav);
    }

    if(event is UIEventLoadGlobalChat){
      yield UIStateLoading();
      yield (UIStateGlobalChat());
      _nav = Nav.chat;
      yield UIStateLoaded(_nav);

    }
    if(event is UIEventLoadChat){
      yield UIStateLoading();
      yield (UIStateChat(event.uid));
      _nav = Nav.chat;
      yield UIStateLoaded(_nav);
    }
  }
}
