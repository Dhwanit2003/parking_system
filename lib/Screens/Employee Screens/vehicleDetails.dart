import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_system/blocs/parking_bloc.dart';

import '../../blocs/parking_event.dart';
import '../../blocs/parking_state.dart';

class vehicleDetails extends StatefulWidget {
  const vehicleDetails({super.key});

  @override
  State<vehicleDetails> createState() => _DetailsState();
}

class _DetailsState extends State<vehicleDetails> {
  String? _name = "";
  String? _number = "";
  String? _licensePlate = "";
  String? _vehicleModel = "";
  final List<String> vehicleTypes = ["Motorbike","Car","Cover Van","Bus"];
  String? selectedVehicle;
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details",
        style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<EmployeeBloc,EmployeeState>(
        builder: (context,state) {

          if (state is EmployeeVehicleChosen) {
            selectedVehicle = state.vehicle;
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Vehicle Icon
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                          Icons.directions_car, size: 50, color: Colors.blue),
                    ),
                    SizedBox(height: 20),
              
                  DropdownButtonFormField<String>(
                    value: selectedVehicle,
                    decoration: InputDecoration(
                      labelText: "Type of Vehicle",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: vehicleTypes.map((vehicle) {
                      return DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedVehicle = value;
                      });
                    },
                    validator: (value) => value == null ? "Please select a vehicle type" : null,
                  ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value){
                        _name = value;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value){
                        _number = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number is required";
                        }
                        if (!RegExp(r'^(?:\+91)?[6-9]\d{9}$').hasMatch(value)) {
                          return "Enter a valid phone number";
                        }
                        return null; // No error
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Vehicle License Plate",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value){
                        _licensePlate = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "License plate is required";
                        }
                        if (!RegExp(r'^(?!.*(?:([A-Z0-9])\1{1,}))[A-Z0-9- ]{5,10}$').hasMatch(value)) {
                          return "Invalid license plate format";
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                    ),
                    SizedBox(height: 16),
                    // Vehicle Model Input
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Vehicle Model",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value){
                        _vehicleModel = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vehicle model is required";
                        }
                        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
                          return "Only alphabets are allowed";
                        }
                        return null; // No error
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius
                              .circular(8)),
                        ),
                        onPressed: () {
                          if (_licensePlate == null || _licensePlate!.isEmpty ||
                              _vehicleModel == null || _vehicleModel!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill all fields!")),
                            );
                            return;
                          }

                          if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
                            return;
                          }

                          Map<String, dynamic> details = {
                            "name": _name,
                            "number": _number,
                            "vehicleType": selectedVehicle,
                            "licensePlate": _licensePlate,
                            "vehicleModel": _vehicleModel,
                          };

                          if (selectedVehicle != null) {
                            context.read<EmployeeBloc>().add(ChooseVehicleEvent(vehicle: selectedVehicle!));
                          }

                          context.read<EmployeeBloc>().add(AddVehicleDetailsEvent(vehicleDetails: details),);

                          context.push('/parkingDetails');
                        }
                        ,
                        child: Text("ADD VEHICLE",
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
