
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class LaunchEvent extends Equatable{}

class LaunchInitial extends LaunchEvent{
  @override
  List<Object> get props => [];

}

class LaunchClass extends LaunchEvent{
  final String link;
  LaunchClass( {@required this.link});

  @override
  List<Object> get props =>[link];
}