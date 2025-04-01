import 'package:flutter/material.dart';
import '../models/employee_model.dart';

abstract class EmployeeState{}

class EmployeeInitial extends EmployeeState{
    final TimeOfDay? entryTime;
    final TimeOfDay? exitTime;

   EmployeeInitial({this.entryTime, this.exitTime});
}

class EmployeeLoading extends EmployeeState{}

class EmployeeSuccess extends EmployeeState {}

class EmployeeFailure extends EmployeeState {
  final String error;
  EmployeeFailure(this.error);
}

class EmployeesLoaded extends EmployeeState {
  final List<Employee> employees;
  EmployeesLoaded(this.employees);
}

class EmployeeTimeUpdated extends EmployeeState {
  final TimeOfDay? entryTime;
  final TimeOfDay? exitTime;

  EmployeeTimeUpdated({this.entryTime, this.exitTime});
}

class EmployeeVehicleChosen extends EmployeeState{
  final String? vehicle;

  EmployeeVehicleChosen({required this.vehicle});
}

class EmployeeVehicleDetailsAdded extends EmployeeState{
  final Map<String,dynamic>? vehicleDetails;

    EmployeeVehicleDetailsAdded({required this.vehicleDetails});
}



class SlotsState extends EmployeeState {
  final int totalUsers;
  final int slots;
  SlotsState({required this.totalUsers,required this.slots});

}

class EmployeeLoaded extends EmployeeState{
  final List<Map<String,dynamic>> employees;


  EmployeeLoaded({required this.employees});
}

class SignInSuccess extends EmployeeState {
  final String role;

   SignInSuccess({required this.role});
}

class EmployeeDetailsLoaded extends EmployeeState {
  final Map<String, dynamic> employee;
  EmployeeDetailsLoaded(this.employee);
}

class EmployeeError extends EmployeeState {
  final String message;
  EmployeeError(this.message);
}

class UpdateDetails extends EmployeeState {
  final String employeeName;
  final String number;
  final String licensePlate;
  final String vehicleType;
  final String vehicleModel;
  final String status;
  final String entryTime;
  final String exitTime;

  UpdateDetails({
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