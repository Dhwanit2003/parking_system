import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/blocs/parking_bloc.dart';
import 'package:parking_system/blocs/parking_event.dart';
import '../../blocs/parking_state.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    int totalSlots = 200;
    int availableSlots = 0;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => EmployeeBloc()..add(FetchParkingSlotsEvent()),
          child: Column(
            children: [
              BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  int totalUsers = 0;
                  if(state is SlotsState){
                    availableSlots = 200 - state.slots;
                    totalUsers = state.totalUsers;
                  }
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people, color: Colors.blue, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  "Active Users",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$totalUsers",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.local_parking, color: Colors.green, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  "Available Slots",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "$availableSlots/$totalSlots",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Parking Usage Graph
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Parking Usage (Last 7 Days)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                left: BorderSide(color: Colors.black, width: 1),
                                bottom: BorderSide(color: Colors.black, width: 1),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 1.0,
                                  getTitlesWidget: (value, meta) {
                                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                    return value.toInt() >= 0 && value.toInt() < days.length
                                        ? Text(
                                      days[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 50,
                                  getTitlesWidget: (value, meta) {
                                    return (value >= 0 && value <= 200)
                                        ? Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    )
                                        : const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                spots: const [
                                  FlSpot(0, 100),
                                  FlSpot(1, 101),
                                  FlSpot(2, 200),
                                  FlSpot(3, 160),
                                  FlSpot(4, 150),
                                  FlSpot(5, 75),
                                  FlSpot(6, 40),
                                ],
                                gradient: const LinearGradient(
                                  colors: [Colors.red, Colors.purpleAccent, Colors.lightBlueAccent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                barWidth: 4,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: const LinearGradient(
                                    colors: [Colors.purpleAccent, Colors.lightBlueAccent],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                            minX: 0,
                            maxX: 7,
                            minY: 0,
                            maxY: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
