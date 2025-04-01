import 'package:flutter/material.dart';

abstract class EmployeeEvent {}

class CreateEmployeeEvent extends EmployeeEvent {

  final String name;
  final String password;
  final String email;
  final String phoneNumber;
  final DateTime createdAt;
  final String role;


  CreateEmployeeEvent({
    required this.name,
    required this.password,
    required this.createdAt,
    required this.role,
    required this.email,
    required this.phoneNumber
  });
}

class UpdateEntryTimeEvent extends EmployeeEvent{
  final TimeOfDay entryTime;
  UpdateEntryTimeEvent({required this.entryTime});
}

class UpdateExitTimeEvent extends EmployeeEvent{
  final TimeOfDay exitTime;
  UpdateExitTimeEvent({required this.exitTime});
}

class ChooseVehicleEvent extends EmployeeEvent{
  final String vehicle;

  ChooseVehicleEvent({required this.vehicle});
}

class AddVehicleDetailsEvent extends  EmployeeEvent{
  final Map<String,dynamic> vehicleDetails;

  AddVehicleDetailsEvent({required this.vehicleDetails});
}

class UpdateParkingDetailsEvent extends EmployeeEvent{
  final TimeOfDay entryTime;
  final TimeOfDay? exitTime;
  final Map<String,dynamic> vehicleDetails;

  UpdateParkingDetailsEvent({required this.entryTime ,required this.exitTime ,required this.vehicleDetails});
}

class UpdateDetailsEvent extends EmployeeEvent {
  final String employeeName;
  final String number;
  final String licensePlate;
  final String vehicleType;
  final String vehicleModel;
  final String status;
  final String entryTime;
  final String exitTime;
  final String date;

  UpdateDetailsEvent({
    required this.date,
    required this.employeeName,
    required this.number,
    required this.licensePlate,
    required this.vehicleType,
    required this.vehicleModel,
    required this.status,
    required this.entryTime,
    required this.exitTime,
  });
}


class ToggleCheckInEvent extends EmployeeEvent{
  final String name;
  final String licensePlate;
  final bool isCheckedIn;

  ToggleCheckInEvent({required this.name,required this.licensePlate ,required this.isCheckedIn});
}

class DeleteVehicleEvent extends EmployeeEvent{
  final String name;
  final String licensePlate;


  DeleteVehicleEvent({required this.name,required this.licensePlate });
}



class SignInEvent extends EmployeeEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class LogoutEvent extends EmployeeEvent {}


class FetchParkingSlotsEvent extends EmployeeEvent{}

class FetchEmployeesEvent extends EmployeeEvent{}

class FetchEmployeeDetailsEvent extends EmployeeEvent {
  final String employeeName;
  FetchEmployeeDetailsEvent(this.employeeName);
}

