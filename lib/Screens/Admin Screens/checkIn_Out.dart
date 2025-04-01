import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_system/blocs/parking_bloc.dart';
import '../../blocs/parking_event.dart';
import '../../blocs/parking_state.dart';

class CheckInOut extends StatefulWidget {
  const CheckInOut({super.key});

  @override
  _CheckInOutState createState() => _CheckInOutState();
}

class _CheckInOutState extends State<CheckInOut> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> _selectedIndexes = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeBloc()..add(FetchEmployeesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Check-In & Check-Out",
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search License Plate...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, state) {
                    if (state is EmployeeLoaded) {
                      final employeeWithPlates = state.employees.expand((employee) {
                        return employee['license_plates'].map((plate) {
                          return {
                            'name': employee['name'],
                            'licensePlate': plate['licensePlate'],
                            'status': plate['status'],
                          };
                        }).toList();
                      }).toList();

                      // Filter based on search query
                      final filteredPlates = employeeWithPlates.where((entry) {
                        final licensePlate = entry['licensePlate'].toString().toLowerCase();
                        return licensePlate.contains(_searchQuery);
                      }).toList();

                      if (filteredPlates.isEmpty) {
                        return Center(
                          child: Text(
                            "No vehicles found.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredPlates.length,
                        itemBuilder: (context, index) {
                          var entry = filteredPlates[index];
                          String employeeName = entry['name'];
                          String licensePlate = entry['licensePlate'];
                          String status = entry['status'];
                          bool isCheckedIn = status == "Checked In";
                          bool isSelected = _selectedIndexes.contains(index);


                          return GestureDetector(
                            onLongPress: () => _toggleSelection(index),
                            child: Card(
                              color: isSelected ? Colors.blue.shade200 : Colors.white,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: Colors.blue.withOpacity(0.2),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Icon(Icons.car_repair, color: Colors.blue),
                                ),
                                title: Text(
                                  licensePlate,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Employee: $employeeName",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      "Status: $status",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: isSelected  ?
                                ElevatedButton(
                                    onPressed: (){
                                      context.read<EmployeeBloc>().add(
                                        DeleteVehicleEvent(
                                          name: employeeName,
                                          licensePlate: licensePlate,
                                        ),
                                      );

                                }, child: Text("Delete"))
                                :
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<EmployeeBloc>().add(
                                      ToggleCheckInEvent(
                                        name: employeeName,
                                        licensePlate: licensePlate,
                                        isCheckedIn: isCheckedIn,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCheckedIn ? Colors.red : Colors.green,
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isCheckedIn ? "Check Out" : "Check In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  context.push('/details', extra: {
                                    "name": employeeName,
                                    "license_plate": licensePlate,
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
