import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_system/blocs/parking_bloc.dart';
import 'package:parking_system/blocs/parking_event.dart';
import 'package:parking_system/blocs/parking_state.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  bool _see = true, _ree = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _selectedOption;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _createEmployee() async {
    if (_passwordController.text != _retypePasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }


    try {
      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        context.read<EmployeeBloc>().add(
          CreateEmployeeEvent(
            name: _nameController.text,
            password: _passwordController.text,
            email: _emailController.text,
            phoneNumber: _phoneNumberController.text,
            createdAt: DateTime.now(),
            role: "Admin",
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Unfocused when tapping outside
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create an account",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Enter Your Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Enter Your Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    prefixIcon: const Icon(Icons.mail, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: "Enter Your Phone Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.grey),
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
                      icon: Icon(
                        _see ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _see = !_see;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _retypePasswordController,
                  obscureText: _ree,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ree ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _ree = !_ree;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _createEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 20),
                    ),
                    child: const Text(
                      "Create an Account",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<EmployeeBloc, EmployeeState>(
                  builder: (context, state) {
                    if (state is EmployeeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EmployeeSuccess) {
                      Future.delayed(const Duration(seconds: 1), () {
                          context.go('/adminView');
                      });

                      return Center(
                        child: Column(
                          children: [
                            if (_selectedOption == 'Employee')
                              const Text(
                                "Signing up as an Employee...!",
                                style: TextStyle(color: Colors.green),
                              ),
                            if (_selectedOption != 'Employee')
                              const Text(
                                "Signing up as an Admin...",
                                style: TextStyle(color: Colors.green),
                              ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      );
                    } else if (state is EmployeeFailure) {
                      return Center(
                        child: Text(
                          "Error: ${state.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

