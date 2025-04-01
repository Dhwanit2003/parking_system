import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/blocs/parking_event.dart';
import 'package:parking_system/blocs/parking_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  String?name;
  String? phoneNumber;
  TimeOfDay? entryTime;
  TimeOfDay? exitTime;
  String? vehicle;
  Map<String, dynamic>? vehicleDetails;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmployeeBloc() : super(EmployeeInitial()) {
    on<CreateEmployeeEvent>(_createEmployee);
    on<UpdateEntryTimeEvent>(_updateEntryTime);
    on<UpdateExitTimeEvent>(_updateExitTime);
    on<SignInEvent>(_signIn);
    on<LogoutEvent>(_logout);
    on<ChooseVehicleEvent>(_chooseVehicle);
    on<AddVehicleDetailsEvent>(_addVehicleDetails);
    on<UpdateParkingDetailsEvent>(_updateParkingDetails);
    on<FetchParkingSlotsEvent>(_fetchParkingSlots);
    on<FetchEmployeesEvent>(_fetchEmployees);
    on<ToggleCheckInEvent>(_toggleCheckInStatus);
    on<FetchEmployeeDetailsEvent>(_fetchEmployeeDetailsEvent);
    on<UpdateDetailsEvent>(_updateDetails);
    on<DeleteVehicleEvent>(_deleteVehicle);

  }

  Future<void> _signIn(SignInEvent event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        final String email = event.email;

        final adminDoc = await FirebaseFirestore.instance.collection('Admin').where('email',isEqualTo: email).get();
        if (adminDoc.docs.isNotEmpty) {
          emit(SignInSuccess(role: 'Admin'));
          return;
        }

        final employeeDoc = await FirebaseFirestore.instance.collection('Employee').where('email' ,isEqualTo: email ).get();
        if (employeeDoc.docs.isNotEmpty) {
          emit(SignInSuccess(role: 'Employee'));
          return;
        }

        emit(EmployeeFailure("User not found in any role."));
      } else {
        emit(EmployeeFailure("Sign-in failed. Please try again."));
      }
    } on FirebaseAuthException catch (e) {

      emit(EmployeeFailure(e.message ?? "An error occurred during sign-in."));
    } catch (e) {
      emit(EmployeeFailure("An unexpected error occurred."));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter<EmployeeState> emit) async {
    await _auth.signOut();
    name =null;
    phoneNumber=null;
    entryTime =null;
    exitTime = null;
    vehicleDetails=null;
    vehicle=null;
    emit(EmployeeInitial());
  }

  void _updateEntryTime(UpdateEntryTimeEvent event, Emitter<EmployeeState> emit) {
    entryTime = event.entryTime;
    emit(EmployeeTimeUpdated(entryTime: entryTime, exitTime: exitTime));
  }

  void _updateExitTime(UpdateExitTimeEvent event, Emitter<EmployeeState> emit) {
    exitTime = event.exitTime;
    emit(EmployeeTimeUpdated(entryTime: entryTime, exitTime: exitTime));
  }

  void _chooseVehicle(ChooseVehicleEvent event,Emitter<EmployeeState> emit){
    vehicle = event.vehicle;
    emit(EmployeeVehicleChosen(vehicle: vehicle));
  }

  void _addVehicleDetails(AddVehicleDetailsEvent event , Emitter<EmployeeState> emit){
    vehicleDetails = event.vehicleDetails;
    emit(EmployeeVehicleDetailsAdded(vehicleDetails: vehicleDetails));
  }

  Future<void> _createEmployee(CreateEmployeeEvent event, Emitter<EmployeeState> emit) async {
    name = event.name;
    phoneNumber = event.phoneNumber;
    emit(EmployeeLoading());
    try {
      await FirebaseFirestore.instance.collection(event.role).doc(event.name).set({
        'name': event.name,
        'password': event.password,
        'email': event.email,
        'phoneNumber': event.phoneNumber,
        'createdAt': event.createdAt,
        'role': event.role,
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(event.name); // Update the display name
      }

      emit(EmployeeSuccess());
    } catch (e) {
      emit(EmployeeFailure(e.toString()));
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'N/A';
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a EEEE').format(dateTime);
  }


  Future<void> _updateParkingDetails(UpdateParkingDetailsEvent event, Emitter<EmployeeState> emit) async {
    emit(EmployeeLoading());
    try {
      String status = 'Checked In';
      final Map<String, dynamic> timings = {
        'entryTime': _formatTime(event.entryTime),
      };

      if (event.exitTime != null) {
        timings['exitTime'] = _formatTime(event.exitTime!);
        status = 'Checked Out';
      }

      String docName = event.vehicleDetails['name'] ?? 'Unknown';

      DocumentReference docRef = FirebaseFirestore.instance.collection('Employee').doc(docName);
      DocumentReference HisRef = FirebaseFirestore.instance.collection('History').doc(docName);
      DocumentSnapshot docSnapshot = await docRef.get();
      DocumentSnapshot HisSnapshot = await docRef.get();

      List<Map<String, dynamic>> vehicles = [];

      if (docSnapshot.exists) {
        Map<String, dynamic> existingData = docSnapshot.data() as Map<String, dynamic>;

        if (existingData.containsKey('Details')) {
          dynamic details = existingData['Details'];

          if (details is List) {
            vehicles = List<Map<String, dynamic>>.from(details);
          } else {
            vehicles.add(Map<String, dynamic>.from(details));
          }
        }
      }
      if (HisSnapshot.exists) {
        Map<String, dynamic> existingData = HisSnapshot.data() as Map<String, dynamic>;

        if (existingData.containsKey('Details')) {
          dynamic details = existingData['Details'];

          if (details is List) {
            vehicles = List<Map<String, dynamic>>.from(details);
          } else {
            vehicles.add(Map<String, dynamic>.from(details));
          }
        }
      }
      String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Map<String, dynamic> newVehicle = {
        "status":status,
        "date":date,
        "vehicleType": event.vehicleDetails["vehicleType"],
        "licensePlate": event.vehicleDetails["licensePlate"],
        "vehicleModel": event.vehicleDetails["vehicleModel"],
        'timings':timings,
      };

      vehicles.add(newVehicle);

      await docRef.set({
        'name':event.vehicleDetails["name"],
        'Details': vehicles,
        "number":event.vehicleDetails["number"],

      }, SetOptions(merge: true));

      await HisRef.set({
        'name':event.vehicleDetails["name"],
        'Details': vehicles,
        "number":event.vehicleDetails["number"],

      }, SetOptions(merge: true));

      emit(EmployeeSuccess());
    } catch (e) {
      emit(EmployeeFailure(e.toString()));
    }
  }


  Future<void> _fetchParkingSlots(FetchParkingSlotsEvent event, Emitter<EmployeeState> emit) async {
    try {
      final employeeSnapshot = await FirebaseFirestore.instance.collection("Employee").get();

      int checkedInCount = 0;
      int totalUsers = employeeSnapshot.docs.length;

      for (var doc in employeeSnapshot.docs) {
        List<dynamic> detailsList = doc['Details'] ?? [];

        for (var detail in detailsList) {
          if (detail is Map<String, dynamic> && detail['status'] == 'Checked In') {
            checkedInCount++;
          }
        }
      }

      emit(SlotsState(totalUsers: totalUsers, slots: checkedInCount));
    } catch (e, stackTrace) {
      emit(EmployeeFailure("Error fetching parking slots: ${e.toString()}"));
      debugPrint("FetchParkingSlots Error: $e\nStackTrace: $stackTrace");
    }
  }


  Future<void> _fetchEmployees(FetchEmployeesEvent event, Emitter<EmployeeState> emit) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Employee').get();

      List<Map<String, dynamic>> employees = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        String name = data['name'] ?? 'Unknown';

        List<dynamic>? detailsList = data['Details'] as List<dynamic>?; // Ensure Details is a list
        List<Map<String, dynamic>> licensePlates = [];

        if (detailsList != null && detailsList.isNotEmpty) {
          for (var entry in detailsList) {
            if (entry is Map<String, dynamic>) {
              licensePlates.add({
                'licensePlate': entry['licensePlate'] ?? 'Unknown',
                'status': entry['status'] ?? 'Unknown',
                'timings': entry['timings'] ?? {},
              });
            }
          }
        }

        employees.add({
          'name': name,
          'license_plates': licensePlates, // Store all plates in a list
        });
      }

      emit(EmployeeLoaded(employees: employees));
    } catch (e, s) {
      print("${e.toString()} \n Stacktrace: $s");
      emit(EmployeeFailure(e.toString()));
    }
  }




  Future<void> _toggleCheckInStatus(ToggleCheckInEvent event, Emitter<EmployeeState> emit) async {
    if (state is EmployeeLoaded) {
      try {
        var currentState = state as EmployeeLoaded;
        String formattedTime = DateFormat('h:mm a EEEE').format(DateTime.now());
        String newStatus = event.isCheckedIn ? "Checked Out" : "Checked In";

        List<Map<String, dynamic>> updatedEmployees = currentState.employees.map((employee) {
          if (employee['name'] == event.name) {
            List updatedPlates = (employee['license_plates'] as List)
                .map((plate) {
              if (plate['licensePlate'] == event.licensePlate) {
                Map<String, dynamic> existingTimings = plate['timings'] ?? {};

                return {
                  ...plate,
                  'status': newStatus,
                  'timings': {
                    'entryTime': existingTimings['entryTime'] ?? formattedTime,
                    'exitTime': newStatus == "Checked Out" ? formattedTime : existingTimings['exitTime'],
                  },
                };
              }
              return plate;
            }).toList();

            return {
              ...employee,
              'license_plates': updatedPlates,
            };
          }
          return employee;
        }).toList();

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Employee')
            .where('name', isEqualTo: event.name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var docRef = querySnapshot.docs.first.reference;
          Map<String, dynamic> employeeData = querySnapshot.docs.first.data() as Map<String, dynamic>;

          List<dynamic> detailsList = employeeData['Details'] ?? [];
          List<dynamic> updatedDetailsList = detailsList.map((detail) {
            if (detail is Map<String, dynamic> && detail['licensePlate'] == event.licensePlate) {
              Map<String, dynamic> updatedDetail = {
                ...detail,
                'status': newStatus,
                'timings': {
                  'entryTime': newStatus == "Checked In" ? formattedTime : detail['timings']?['entryTime'],
                  'exitTime': newStatus == "Checked Out" ? formattedTime : null,
                }
              };
              return updatedDetail;
            }
            return detail;
          }).toList();

          await docRef.update({'Details': updatedDetailsList});
          emit(EmployeeLoaded(employees: updatedEmployees));
        }
      } catch (e) {
        emit(EmployeeFailure(e.toString()));
      }
    }
  }

  Future<void> _deleteVehicle(DeleteVehicleEvent event, Emitter<EmployeeState> emit) async {
    if (state is EmployeeLoaded) {
      try {
        var currentState = state as EmployeeLoaded;

        List<Map<String, dynamic>> updatedEmployees = currentState.employees.map((employee) {
          if (employee['name'] == event.name) {
            List updatedPlates = (employee['license_plates'] as List)
                .where((plate) => plate['licensePlate'] != event.licensePlate)
                .toList();

            return {
              ...employee,
              'license_plates': updatedPlates,
            };
          }
          return employee;
        }).toList();

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Employee')
            .where('name', isEqualTo: event.name)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var docRef = querySnapshot.docs.first.reference;
          Map<String, dynamic> employeeData = querySnapshot.docs.first.data() as Map<String, dynamic>;

          List<dynamic> detailsList = employeeData['Details'] ?? [];
          List<dynamic> updatedDetailsList = detailsList
              .where((detail) => detail is Map<String, dynamic> && detail['licensePlate'] != event.licensePlate)
              .toList();

          await docRef.update({'Details': updatedDetailsList});
        }

        emit(EmployeeLoaded(employees: updatedEmployees));
      } catch (e) {
        emit(EmployeeFailure(e.toString()));
      }
    }
  }




  Future<void> _fetchEmployeeDetailsEvent(FetchEmployeeDetailsEvent event, Emitter<EmployeeState> emit) async {
    try {
      DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('Employee').doc(event.employeeName).get();

      if (docSnapshot.exists) {
        Map<String, dynamic>? employeeData = docSnapshot.data() as Map<String, dynamic>?;

        if (employeeData != null) {
          emit(EmployeeDetailsLoaded(employeeData));
        } else {
          emit(EmployeeError("Employee data is empty."));
        }
      } else {
        emit(EmployeeError("Employee not found."));
      }
    } catch (e) {
      emit(EmployeeError("Error fetching employee details: $e"));
    }
  }

  Future<void> _updateDetails(UpdateDetailsEvent event, Emitter<EmployeeState> emit) async {
    try {
      emit(EmployeeLoading());

      DocumentReference employeeRef =
      FirebaseFirestore.instance.collection('Employee').doc(event.employeeName);

      DocumentSnapshot snapshot = await employeeRef.get();
      Map<String, dynamic>? employeeData = snapshot.data() as Map<String, dynamic>?;

      if (employeeData == null) {
        emit(EmployeeError("Employee not found"));
        return;
      }

      List<dynamic> detailsList = employeeData["Details"] ?? [];

      int index = detailsList.indexWhere((detail) =>
      detail is Map<String, dynamic> && detail["licensePlate"] == event.licensePlate);

      if (index == -1) {
        emit(EmployeeError( "Vehicle not found"));
        return;
      }

      detailsList[index] = {
        "date":event.date,
        "licensePlate": event.licensePlate,
        "vehicleType": event.vehicleType,
        "vehicleModel": event.vehicleModel,
        "status": event.status,
        "timings": {
          "entryTime": event.entryTime,
          "exitTime": event.exitTime,
        }
      };

      await employeeRef.update({
        "Details": detailsList,
        "number": event.number,
      });

      await employeeRef.update({"Details": detailsList});

      DocumentSnapshot updatedSnapshot = await employeeRef.get();
      Map<String, dynamic>? updatedEmployeeData =
      updatedSnapshot.data() as Map<String, dynamic>?;

      if (updatedEmployeeData != null) {
        emit(EmployeeDetailsLoaded(updatedEmployeeData));
      } else {
        emit(EmployeeError("Failed to update employee details"));
      }
    } catch (e) {
      emit(EmployeeError( "Update failed: $e"));
    }
  }





}
