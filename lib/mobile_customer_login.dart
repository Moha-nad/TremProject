import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthService.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'mobile_customer_products.dart';
import 'mobile_customer_signup.dart';

class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Color.fromARGB(255, 207, 162, 74),
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(Icons.shopping_bag, color: Colors.white, size: 80.0),
              Text('متجر العميل', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),),

              SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),

              SizedBox(height: 15),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'كلمة المرور',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () async {
                    User? user = await _authService.signIn(_emailController.text, _passwordController.text);
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerProducts()));
                    }else{
                      Fluttertoast.showToast(
                          msg: 'البريد أو كلمة مرور خاطئة',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  child: Text('تسجيل الدخول', style: TextStyle(color: Color.fromARGB(255, 207, 162, 74))),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white)),
                  icon: const Icon(Icons.login),
                  label: const Text('تسجيل الدخول مع قوقل'),
                  onPressed: () async {
                    User? user = await _authService.signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CustomerProducts()));
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerSignUp())),
                child: Text('لايوجد لديك حساب؟ إنشاء حساب', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}