import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'web_admin_dashboard.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('متجر المسؤول',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.admin_panel_settings, size: 64, color: Color.fromARGB(255, 207, 162, 74)),
              SizedBox(height: 16),
              Text(
                'إدارة الأعمال',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 207, 162, 74)),
              ),

              SizedBox(height: 32),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني للمسؤول',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 207, 162, 74)),
                  onPressed: () async {
                    User? user = await _authService.signIn(_emailController.text, _passwordController.text);
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard()));
                    }else{
                      Fluttertoast.showToast(
                          msg: 'البريد أو كلمة مرور خاطئة',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black45,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  child: Text('تسجيل الدخول إلى لوحة التحكم', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}