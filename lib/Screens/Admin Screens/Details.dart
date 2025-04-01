import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/blocs/parking_bloc.dart';
import 'package:parking_system/blocs/parking_event.dart';
import 'package:parking_system/blocs/parking_state.dart';

class Details extends StatefulWidget {
  final String employeeName;

  const Details({super.key, required this.employeeName});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  late TextEditingController _licensePlateController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _statusController;
  late TextEditingController _entryTimeController;
  late TextEditingController _exitTimeController;
  late TextEditingController _numberController;
  late TextEditingController _dateController;
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _licensePlateController = TextEditingController();
    _vehicleModelController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _statusController = TextEditingController();
    _entryTimeController = TextEditingController();
    _exitTimeController = TextEditingController();
    _numberController = TextEditingController();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleTypeController.dispose();
    _statusController.dispose();
    _entryTimeController.dispose();
    _exitTimeController.dispose();
    _numberController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeBloc()..add(FetchEmployeeDetailsEvent(widget.employeeName)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Employee Details",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            if (state is EmployeeDetailsLoaded) {
              final employee = state.employee;
              final String number = employee['number'];
              final List<Map<String, dynamic>> details =
                  (employee['Details'] as List?)?.cast<Map<String, dynamic>>() ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.employeeName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (details.isNotEmpty) ...[
                      const Text(
                        "Employee Details:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(thickness: 2),
                      ...details.map((detail) {
                        final String date = detail['date'] ?? 'N/A';
                        final String licensePlate = detail['licensePlate'] ?? 'N/A';
                        final String vehicleModel = detail['vehicleModel'] ?? 'N/A';
                        final String status = detail['status'] ?? 'N/A';
                        final String vehicleType = detail['vehicleType'] ?? 'N/A';
                        final Map<String, dynamic> timings = detail['timings'] as Map<String, dynamic>? ?? {};
                        final String entryTime = timings['entryTime'] ?? 'N/A';
                        final String exitTime = timings['exitTime'] ?? 'N/A';

                        if (_isEditing) {
                          _licensePlateController.text = licensePlate;
                          _vehicleModelController.text = vehicleModel;
                          _vehicleTypeController.text = vehicleType;
                          _statusController.text = status;
                          _entryTimeController.text = entryTime;
                          _exitTimeController.text = exitTime;
                          _numberController.text = number;
                          _dateController.text = date;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$vehicleModel ($licensePlate)",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  vehicleType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildDetailRow("Date", date, _dateController),
                                _buildDetailRow("Phone Number", number, _numberController),
                                _buildDetailRow("Status", status, _statusController),
                                _buildDetailRow("Entry Time", entryTime, _entryTimeController),
                                _buildDetailRow("Exit Time", exitTime, _exitTimeController),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: _isEditing
                                        ? () {
                                      context.read<EmployeeBloc>().add(
                                        UpdateDetailsEvent(
                                          date : _dateController.text,
                                          employeeName: widget.employeeName,
                                          number: _numberController.text,
                                          licensePlate: _licensePlateController.text,
                                          vehicleType: _vehicleTypeController.text,
                                          vehicleModel: _vehicleModelController.text,
                                          status: _statusController.text,
                                          entryTime: _entryTimeController.text,
                                          exitTime: _exitTimeController.text,
                                        ),
                                      );
                                      _toggleEditing();
                                    }
                                        : _toggleEditing,
                                    child: Text(
                                      _isEditing ? "Save" : "Edit",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              );
            } else if (state is EmployeeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: _isEditing
                ? TextField(
              controller: controller,
              textAlign: TextAlign.right,
            )
                : Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}