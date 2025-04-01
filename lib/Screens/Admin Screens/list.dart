import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key});

  @override
  _EmployeeListState createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  String selectedFilter = 'Today';

  Future<List<Map<String, dynamic>>> fetchEmployees() async {
    final snapshot = await FirebaseFirestore.instance.collection('Employee').get();

    List<Map<String, dynamic>> employees = [];

    DateTime now = DateTime.now();

    for (var doc in snapshot.docs) {
      List<dynamic> detailsList = doc['Details'] ?? [];
      for (var detail in detailsList) {
        Map<String, dynamic> timings = detail['timings'] ?? {};
        String date = detail['date'] ?? DateFormat('yyyy-MM-dd').format(now);

        DateTime entryDate = DateFormat('yyyy-MM-dd').parse(date);

        if (_isDateInFilter(entryDate)) {
          employees.add({
            'name': doc.id,
            'date':detail['date'] ?? 'N/A',
            'licensePlate': detail['licensePlate'] ?? 'N/A',
            'status': detail['status'] ?? 'N/A',
            'timings': timings,
          });
        }
      }
    }
    return employees;
  }


  bool _isDateInFilter(DateTime entryDate) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    DateTime lastWeek = now.subtract(const Duration(days: 7));
    DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);

    switch (selectedFilter) {
      case 'Today':
        return entryDate.day == now.day && entryDate.month == now.month && entryDate.year == now.year;
      case 'Yesterday':
        return entryDate.day == yesterday.day && entryDate.month == yesterday.month && entryDate.year == yesterday.year;
      case 'Last 7 Days':
        return entryDate.isAfter(lastWeek) && entryDate.isBefore(now);
      case 'This Month':
        return entryDate.isAfter(lastMonth) && entryDate.isBefore(now);
      case 'This Year':
        return entryDate.isAfter(DateTime(now.year,1,1).subtract(Duration(days: 1))) && entryDate.isBefore(now);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Employee List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEmployees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0), // Reduced padding
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12), // Inner padding
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8), // Smaller border radius
                        ),
                        child: DropdownButton<String>(
                          value: selectedFilter,
                          isExpanded: true,
                          underline: const SizedBox(), // Removes default underline
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Custom dropdown icon
                          style: const TextStyle(fontSize: 14, color: Colors.black), // Smaller text
                          items: ['Today', 'Yesterday', 'Last 7 Days', 'This Month','This Year']
                              .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    const Center(child: Text("No employees found", style: TextStyle(fontSize: 18, color: Colors.grey))),
                  ],
                )
            );
          }
          final employees = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0), // Reduced padding
                  child: DropdownButtonFormField<String>(
                    value: selectedFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8), // Smaller border radius
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontSize: 14, color: Colors.black), // Smaller text
                    items: ['Today', 'Yesterday', 'Last 7 Days', 'This Month','This Year']
                        .map(
                          (filter) => DropdownMenuItem(
                        value: filter,
                        child: Text(
                          filter,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      Expanded(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      Expanded(child: Text("License Plate", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      Expanded(child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      Expanded(child: Text("Entry Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      Expanded(child: Text("Exit Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Employee List
                Expanded(
                  child: ListView.builder(
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      final name = employee['name'];
                      final date = employee['date'];
                      final licensePlate = employee['licensePlate'];
                      final timings = employee['timings'];
                      final entryTime = timings['entryTime'] ?? 'N/A';
                      final exitTime = timings['exitTime']?.toString() ?? 'N/A';
                      final status = employee['status'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: status == "Checked In"
                                      ? const Icon(Icons.login, color: Colors.green)
                                      : status == "Checked Out"
                                      ? const Icon(Icons.logout, color: Colors.red)
                                      : const SizedBox(),
                                ),
                              ),
                              Expanded(
                                child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              ),
                              Expanded(
                                child: Text(licensePlate, style: const TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.w600)),
                              ),

                              Expanded(child: Text(date, style: const TextStyle(color: Colors.grey,fontSize: 10))),

                              Expanded(
                                child: Text(entryTime, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.green,fontSize: 11)),
                              ),
                              Expanded(
                                child: Text(exitTime, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.red,fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
