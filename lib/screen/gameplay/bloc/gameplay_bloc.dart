import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'gameplay_event.dart';
part 'gameplay_state.dart';

class GameplayBloc extends Bloc<GameplayEvent, GameplayState> {
  GameplayBloc() : super(GameplayInitial()) {
    on<GameplayEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
