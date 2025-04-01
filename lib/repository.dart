import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createEmployee(Employee employee) async {
    await _firestore.collection('employees').doc(employee.name).set(employee.toMap());
  }

  Stream<List<Employee>> getEmployeesStream() {
    return _firestore.collection('employees').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Employee.fromMap(doc.data())).toList();
    });
  }
}