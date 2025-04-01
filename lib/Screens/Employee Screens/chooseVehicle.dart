import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/parking_bloc.dart';
import '../../blocs/parking_event.dart';

class chooseVehicle extends StatefulWidget {
  const chooseVehicle({super.key});

  @override
  State<chooseVehicle> createState() => _chooseVehicleState();
}

class _chooseVehicleState extends State<chooseVehicle> {
  int _selectedIndex = -1;
  final List<Map<String, dynamic>> _vehicles = [
    {"icon": Icons.directions_bike, "label": "Motorbike"},
    {"icon": Icons.car_rental, "label": "Car"},
    {"icon": Icons.directions_bus, "label": "Cover Van"},
    {"icon": Icons.directions_bus_filled, "label": "Bus"},
  ];

  void _onVehicleSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Choose your vehicle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () => _onVehicleSelected(index),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                        child: Icon(
                          _vehicles[index]['icon'],
                          size: 30,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_vehicles[index]['label']),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              onPressed: _selectedIndex != -1
                  ? () {
                String selectedVehicle = _vehicles[_selectedIndex]['label'];
                context.read<EmployeeBloc>().add(ChooseVehicleEvent(vehicle: selectedVehicle));

                context.push('/vehicleDetails');
              }
                  : null,
              child: const Text("CONFIRM YOUR VEHICLE",style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
