import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../blocs/parking_bloc.dart';
import '../../blocs/parking_event.dart';

class ParkingDetails extends StatelessWidget {
  const ParkingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final employeeBloc = BlocProvider.of<EmployeeBloc>(context);

    final entryTime = employeeBloc.entryTime;
    final exitTime = employeeBloc.exitTime;
    final vehicle = employeeBloc.vehicle;
    final vehicleDetails = employeeBloc.vehicleDetails;

    String qrData = "Vehicle Type: ${vehicle ?? 'N/A'}\n"
        "Entry: ${entryTime?.format(context) ?? 'N/A'}\n"
        "Exit: ${exitTime?.format(context) ?? 'N/A'}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Code"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Code
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200,
              gapless: false,
            ),
            const SizedBox(height: 20),

            // Parking Details
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( vehicleDetails?['name'] ?? 'N/A'),
                Text(vehicleDetails?['number']?? 'N/A'),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Vehicle Type", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vehicleDetails?['vehicleType'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Vehicle Model", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Vehicle Plate", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vehicleDetails?['vehicleModel'] ?? 'N/A'),
                Text(vehicleDetails?['licensePlate'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Entry", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Exit", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entryTime?.format(context) ?? 'N/A'),
                Text(exitTime?.format(context) ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if(entryTime!=null && vehicleDetails!=null){
                  context.read<EmployeeBloc>().add(UpdateParkingDetailsEvent(
                    entryTime:entryTime,
                    exitTime:exitTime,
                    vehicleDetails :vehicleDetails,
                  ),
                  );
                }
                context.go('/adminView'); // Go back
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "PARKING FINISH",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

