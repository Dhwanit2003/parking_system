import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String selectedFilter = 'Today';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEmployees() async {
    final snapshot = await FirebaseFirestore.instance.collection('History').get();

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
            'date': detail['date'] ?? 'N/A',
            'licensePlate': detail['licensePlate'] ?? 'N/A',
            'status': detail['status'] ?? 'N/A',
            'timings': timings,
          });
        }
      }
    }

    setState(() {
      _employees = employees;
      _filteredEmployees = employees;
    });
  }

  void _filterEmployees() {
    setState(() {
      _filteredEmployees = _employees
          .where((employee) => employee['licensePlate']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  bool _isDateInFilter(DateTime entryDate) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    DateTime lastWeek = now.subtract(const Duration(days: 7));
    DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);

    switch (selectedFilter) {
      case 'Today':
        return entryDate.day == now.day &&
            entryDate.month == now.month &&
            entryDate.year == now.year;
      case 'Yesterday':
        return entryDate.day == yesterday.day &&
            entryDate.month == yesterday.month &&
            entryDate.year == yesterday.year;
      case 'Last 7 Days':
        return entryDate.isAfter(lastWeek) && entryDate.isBefore(now);
      case 'This Month':
        return entryDate.isAfter(lastMonth) && entryDate.isBefore(now);
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search License Plate...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),

            // Filter Dropdown
            DropdownButtonFormField<String>(
              value: selectedFilter,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              items: ['Today', 'Yesterday', 'Last 7 Days', 'This Month']
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
                  fetchEmployees();
                });
              },
            ),
            const SizedBox(height: 10),
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
              child: _filteredEmployees.isEmpty
                  ? const Center(
                child: Text(
                  "No employees found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = _filteredEmployees[index];
                  final name = employee['name'];
                  final date = employee['date'];
                  final licensePlate = employee['licensePlate'];
                  final timings = employee['timings'];
                  final entryTime = timings['entryTime'] ?? 'N/A';
                  final exitTime =
                      timings['exitTime']?.toString() ?? 'N/A';
                  final status = employee['status'];


                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: status == "Checked In"
                                  ? const Icon(Icons.login,
                                  color: Colors.green)
                                  : status == "Checked Out"
                                  ? const Icon(Icons.logout,
                                  color: Colors.red)
                                  : const SizedBox(),
                            ),
                          ),
                          Expanded(
                            child: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                          Expanded(
                            child: Text(licensePlate,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                              child: Text(date,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 10))),
                          Expanded(
                            child: Text(entryTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                    fontSize: 11)),
                          ),
                          Expanded(
                            child: Text(exitTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                    fontSize: 11)),
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
      ),
    );
  }
}
