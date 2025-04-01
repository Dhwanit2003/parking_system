import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parking_system/Screens/Admin%20Screens/dashboard.dart';
import 'package:parking_system/Screens/Admin%20Screens/checkIn_Out.dart';
import 'package:parking_system/Screens/Employee%20Screens/EmployeeView.dart';
import '../../blocs/parking_bloc.dart';
import '../../blocs/parking_event.dart';
import 'list.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    Dashboard(),
    EmployeeView(),
    CheckInOut(),
    EmployeeList(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text("ParkIn",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
            Icon(Icons.location_on,color: Colors.red,)
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text(
                  _currentUser?.displayName ?? 'User'
                ),
                accountEmail: Text(
                  _currentUser?.email ?? 'No email'
                ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (_currentUser?.displayName?.isNotEmpty ?? false)
                      ? _currentUser!.displayName![0].toUpperCase()
                      : 'U',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
           ),
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: const Text("My Account"),
              onTap: () {
                context.push('/myAccount');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("History"),
              onTap: () {
                context.push('/history');
              },
            ),

            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: const Text("Log Out"),
              onTap: () {
                context.read<EmployeeBloc>().add(LogoutEvent());
                context.go('/');
              },
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'Entry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'CheckIn-Out',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Lists',
            ),

          ],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
