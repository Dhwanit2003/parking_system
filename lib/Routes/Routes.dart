import 'package:go_router/go_router.dart';
import 'package:parking_system/Screens/Admin%20Screens/Details.dart';
import 'package:parking_system/Screens/Admin%20Screens/adminView.dart';
import 'package:parking_system/Screens/Admin%20Screens/history.dart';
import 'package:parking_system/Screens/createUser.dart';
import 'package:parking_system/Screens/Employee%20Screens/employeeView.dart';
import 'package:parking_system/Screens/myAccount.dart';
import 'package:parking_system/Screens/Employee%20Screens/parkingDetails.dart';
import '../Screens/Admin Screens/Auth.dart';
import '../Screens/Employee Screens/chooseVehicle.dart';
import '../Screens/Employee Screens/vehicleDetails.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AuthRedirect(),
    ),
    GoRoute(
      path: '/createUser',
      builder: (context, state) => CreateUser(),
    ),
    GoRoute(
      path: '/employeeView',
      builder: (context, state) => EmployeeView(),
    ),
    GoRoute(
      path: '/adminView',
      builder: (context, state) => AdminView(),
    ),
    GoRoute(
      path: '/myAccount',
      builder: (context, state) => MyAccount(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => History(),
    ),
    GoRoute(
      name: 'vehicle',
      path: '/chooseVehicle',
      builder: (context, state) => chooseVehicle(),
    ),
    GoRoute(
      path: '/vehicleDetails',
      builder: (context, state) => vehicleDetails(),
    ),
    GoRoute(
      path: '/parkingDetails',
      builder: (context, state) => ParkingDetails(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) {
        final employee = state.extra as Map<String, dynamic>;
        return Details(employeeName: employee['name']);

      },
    ),
  ],
);
