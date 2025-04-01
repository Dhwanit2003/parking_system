import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/parking_bloc.dart';
import '../blocs/parking_event.dart';
import '../blocs/parking_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _see = true;


  @override
  Widget build(BuildContext context) {
    return BlocListener<EmployeeBloc, EmployeeState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          if (state.role == 'Admin') {
            context.go('/adminView');
          }
        } else if (state is EmployeeFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("ParkIn"),
          backgroundColor: Colors.blueAccent,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/ParkingImage2.jpg',
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Sign into your account",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Enter Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _see,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_see ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _see = !_see;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Trigger the sign-in event
                            context.read<EmployeeBloc>().add(
                              SignInEvent(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 20),
                          ),
                          child: const Text(
                            "SignIn",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/createUser');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                          ),
                          child: const Text(
                            "Create New Account",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

