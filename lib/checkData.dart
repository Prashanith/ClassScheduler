
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DataState extends Equatable{}
class Init extends DataState{
  @override
  List<Object> get props => null;
}


class Current extends DataState{
  final String name;

  Current(this.name);

  @override
  List<Object> get props =>[name];

}

class NewState extends DataState{
  final String name;
  NewState(this.name);

  @override
  List<Object> get props => [name];
}

abstract class DataEvent{}

class InitialDataLoaded extends DataEvent{
  InitialDataLoaded();
}

class NewDataAdded extends DataEvent{
  String name;
  NewDataAdded({@required name});
}

class DataBloc extends Bloc<DataEvent,DataState>{
  DataBloc(DataState initialState) : super(initialState);

  EmitData emitData;
  StreamSubscription<QuerySnapshot> tickerSubscription;

  @override
  Future<void> close() {
    tickerSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<DataState> mapEventToState(DataEvent event)async* {
    if(event is InitialDataLoaded){
      print('Initial Data loaded');
      yield Current(null);

      // tickerSubscription=emitData.dataMethod().listen((event){
      //   Map<String, dynamic> documentFields =event.docs[0].data();
      //   NewDataAdded(name: documentFields['val']);
      // });
    }
    if(event is NewDataAdded){
      tickerSubscription=FirebaseFirestore.instance.collection('Example').snapshots().listen((event) async*{

        Future<String> x;
        await FirebaseFirestore.instance.collection('Example').doc('info').get().then((value) => x=value.data()['link']);
        print('Process About to start');

        yield Current(x.toString());
      });
      yield Current(event.name);
    }
  }
}

class EmitData{
  Stream<QuerySnapshot> dataMethod(){
    return FirebaseFirestore.instance.collection('Example').snapshots();
  }
}