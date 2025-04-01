
class Employee{
  final String name;
  final String password;
  final DateTime createdAt;
  final String role;


  Employee({required this.name,required this.password , required this.createdAt,required this.role});

  Map<String,dynamic> toMap(){
    return{
      'name':name,
      'password':password,
      'created_at':createdAt,
      'role':role,
    };
  }
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      name: map['name'],
      password: map['password'],
      createdAt: DateTime.parse(map['created_at']),
      role: map['role'],
    );
  }
}

