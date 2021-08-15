
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scheduler/Launch%20Bloc/launchbloc.dart';
import 'package:scheduler/Launch%20Bloc/launchevent.dart';
import 'package:scheduler/Launch%20Bloc/launchstate.dart';
import 'package:scheduler/checkData.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider<LaunchBloc>(
            create: (context) {
              return LaunchBloc(InitialState());
            },
          ),
          BlocProvider<DataBloc>(
            create: (context) {
              return DataBloc(Init())..add(InitialDataLoaded());
            },
          ),
        ],
        child:MyApp()
    )
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSE A',
      home: CheckPage(),
    );
  }
}

class CheckPage extends StatefulWidget {
  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.teal,
        child: BlocBuilder<DataBloc,DataState>(
          builder: (context,state){
            if(state is NewState){
             return Center(
                child:Text('New State Data $state'),
              );
            }
            else if(state is Current){
              return Center(
                child: Column(
                  children: [
                    Text('Other state $state'),
                    RaisedButton(
                      onPressed: (){
                        BlocProvider.of<DataBloc>(context).add(NewDataAdded(name: 'null'));

                      },
                    ),
                  ],
                ),

              );
            }
            return Center(
                child: Column(
                  children: [
                    Text('Other state $state'),
                    RaisedButton(
                      onPressed: (){
                        BlocProvider.of<DataBloc>(context).add(NewDataAdded());

                      },
                    ),
                  ],
                ),

            );
          },
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> weekDays=[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  int today;
  PageController dateController, pageController;
  int _checkDate(){
    var today=DateTime.now().weekday;
    return today-1;
  }
  @override
  void initState() {
    setState(() {
      today=_checkDate();
      dateController = PageController(viewportFraction: 0.4, initialPage: today);
      pageController = PageController(viewportFraction: 0.7, initialPage: today);
    });
    super.initState();
  }

  @override
  void dispose() {
    dateController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8,0.0),
                      tileMode: TileMode.repeated,
                      colors: [
                        Colors.white38,
                        Colors.lightBlue[100],
                        Colors.red
                      ],
                      stops: [0.0,5.0,1.0],
                    )
                ),
              ),
              BlocListener<LaunchBloc, LaunchState>(
                  listener: (context, state) {
                    if (state is LaunchFailure){
                      showDialog(
                          context: context,
                          builder: (_){
                            return LaunchFail();
                          },
                          barrierDismissible: false
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 2,
                          child: PageView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            controller: dateController,
                            itemCount: 7,
                            itemBuilder: (context, index) {
                              return Center(
                                child: AnimatedDefaultTextStyle(
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  duration: const Duration(milliseconds: 400),
                                  child:Text(weekDays[index]),
                                ),
                              );
                            },
                          )
                      ),
                      Flexible(
                          flex: 7,
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: 7,
                            onPageChanged: (i) async {
                              today = i;
                              await dateController.animateToPage(i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                            itemBuilder: (context, index) {
                              return AnimatedBuilder(
                                  animation: pageController,
                                  builder: (context, child) {
                                    double scale = 0.85;
                                    if (index == today) scale = 1.0;
                                    return TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.85, end: scale),
                                      duration: const Duration(milliseconds: 250),
                                      builder: (context, double val, child) {
                                        return Transform.scale(
                                            scale: val,
                                            child: child
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: Card(
                                            elevation: 10,
                                            color: Colors.blue,
                                            child: Center(child: DaySchedule(day: weekDays[index]))
                                        ),
                                      ),
                                    );
                                  });
                            },
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
}


class DaySchedule extends StatefulWidget {
  final String day;

  const DaySchedule({@required this.day});
  @override
  _DayScheduleState createState() => _DayScheduleState();
}

class _DayScheduleState extends State<DaySchedule> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(widget.day).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data==null){
          return Center(
              child: CircularProgressIndicator(),
          );
        }
        else if (snapshot.data.docs.length == 0){
          return Text('No Scheduled Subjects', style:
          TextStyle(
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 0.0),
                blurRadius: 0.5,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
            fontWeight: FontWeight.w300,
            color: Colors.grey[500],
            fontSize: 20,
          ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
            itemBuilder:(context,index){
              Map<String, dynamic> documentFields = snapshot.data.docs[index].data();
              return GestureDetector(
                onTap: (){
                  BlocProvider.of<LaunchBloc>(context).add(LaunchClass(link:documentFields['link']));
                },
                child: ListTile(
                  title: Center(
                    child: Text(' ${snapshot.data.docs[index].id}',
                      style: TextStyle(
                          color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                ),
              );
            }
        );
      }
    );
  }
}

class LaunchFail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(20),
      children: [
        Text('Unexpected Error',
          style: TextStyle(
            fontSize: 20
          ),
        ),
        SizedBox(height: 10,),
        Text('failed to launch class',
          style: TextStyle(
              fontSize: 20
          ),
        ),
        SizedBox(height: 10,),
        RaisedButton.icon(
          color: Colors.blue,
            onPressed: (){
              BlocProvider.of<LaunchBloc>(context)..add(LaunchInitial());
              Navigator.pop(context,true);
            },
            label:Text('CLOSE',style: TextStyle(color: Colors.white),),
          icon: Icon(Icons.close,color: Colors.white,),
        )
      ],
    );
  }
}






