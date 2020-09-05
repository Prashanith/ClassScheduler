import 'package:bloc/bloc.dart';
import 'package:scheduler/Launch%20Bloc/launchevent.dart';
import 'package:scheduler/Launch%20Bloc/launchstate.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchBloc extends Bloc<LaunchEvent,LaunchState>{
  LaunchBloc(LaunchState initialState) : super(initialState);

  @override
  Stream<LaunchState> mapEventToState(LaunchEvent event) async*{
    if(event is LaunchInitial){
      yield InitialState();
    }
    if(event is LaunchEvent){
      yield LaunchZoom();
      if (await canLaunch(event.props[0])) {
        await launch(event.props[0]);
        yield LaunchSuccess();
        yield InitialState();
      } else {
        yield LaunchFailure();
      }
    }
  }

}