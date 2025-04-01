 import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_system/blocs/parking_state.dart';
import '../../blocs/parking_bloc.dart';
import '../../blocs/parking_event.dart';

class EmployeeView extends StatefulWidget {
  const EmployeeView({super.key});

  @override
  State<EmployeeView> createState() => _EmployeeViewState();
}


class _EmployeeViewState extends State<EmployeeView> {
  late GoogleMapController mapController;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final LatLng _center = const LatLng(28.449856, 77.074981);
    bool entry = true;
    TimeOfDay? entryTime;
    TimeOfDay? exitTime;
    TimeOfDay? picked;
    final User? _currentUser = FirebaseAuth.instance.currentUser;
  late Timer _timer;
  DateTime _lastCheckedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startMidnightChecker();
  }


  void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }

  void _startMidnightChecker() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      DateTime now = DateTime.now();
      if (_lastCheckedDate.day != now.day) {
        setState(() {
          entryTime = null;
          exitTime = null;
          _lastCheckedDate = now;
        });
      }
    });
  }

    Future<void> _selectTime(BuildContext context,bool isEntry) async{
       entryTime = null;
       exitTime = null;
       final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
      );

      if(picked != null){
        setState(() {
          if(entry){
            context.read<EmployeeBloc>().add(UpdateEntryTimeEvent(entryTime: picked));
          }
          else{
            context.read<EmployeeBloc>().add(UpdateExitTimeEvent(exitTime: picked));
          }
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
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
               color: Colors.blueAccent,
             ),
           ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_circle_rounded),
                      title: const Text("My Account"),
                      onTap: () {
                        context.push('/myAccount');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.login_outlined),
                      title: const Text("Log Out"),
                      onTap: () {
                        entryTime = null;
                        exitTime =null;
                        context.read<EmployeeBloc>().add(LogoutEvent());
                        context.go('/');
                      },
                    ),
                  ]
                ),

             )
           ]
          ),
      ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 19.0,
                tilt: 60.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('1'),
                  position: LatLng(28.449856, 77.074981),
                  icon: BitmapDescriptor.defaultMarker,
                ),
                Marker(
                  markerId: MarkerId('2'),
                  position: LatLng(28.49856, 77.074981),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocBuilder<EmployeeBloc,EmployeeState>(
                builder: (context,state) {
                  if (state is EmployeeTimeUpdated) {
                    entryTime = state.entryTime;
                    exitTime = state.exitTime;
                  }
                  return Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.0,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Register !!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Divider(),
                        SizedBox(height: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() {
                                          entry = true;
                                          _selectTime(context, false);
                                        }),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue, width: 1),
                                      ),
                                      child: Column(
                                        children: [
                                          Text('ENTRANCE',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text('Today, ${entryTime?.format(context) ?? "--:--"}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20,),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        entry = false;
                                        _selectTime(context, false);
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:  Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.blue, width: 1),
                                      ),
                                      child: Column(
                                        children: [
                                          Text('EXIT',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.blue,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          Text('Today, ${exitTime?.format(context) ?? "--:--"}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30,),
                            ElevatedButton(
                              onPressed: () {
                                if (entryTime == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Please enter entry time"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  context.pushNamed('vehicle');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      12), // No rounded corners
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 60,
                                    vertical: 20), // Button padding
                              ),
                              child: Text("Confirm",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      );
  }
}





