import 'package:firstbase/mobile_customer_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'AuthService.dart';

class CustomerSignUp extends StatefulWidget {
  const CustomerSignUp({super.key});

  @override
  State<CustomerSignUp> createState() => _CustomerSignUpState();
}

class _CustomerSignUpState extends State<CustomerSignUp> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 100.0, bottom: 50.0),
              child: Center(
                child: Icon(
                  Icons.person_add_alt_1,
                  color: Color.fromARGB(255, 207, 162, 74),
                  size: 80.0,
                ),
              ),
            ),

            Text('إنشاء حساب', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 207, 162, 74),),
            ),

            SizedBox(height: 40),

            _buildInputField('البريد الإلكتروني', _emailController, false),

            SizedBox(height: 20),

            _buildInputField('كلمة المرور', _passwordController, true),

            SizedBox(height: 20),

            _buildInputField('تأكيد كلمة المرور', _confirmPasswordController, true),

            SizedBox(height: 40.0),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    if (_passwordController.text == _confirmPasswordController.text) {
                      User? user = await _authService.signUp(
                          _emailController.text,
                          _passwordController.text
                      );

                      if (user != null) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => CustomerLogin())
                        );
                      }
                    } else {
                      Fluttertoast.showToast(
                          msg: 'كلمة المرور غير متطابقة',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 207, 162, 74),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'لديك حساب بالفعل؟ سجل الدخول',
                style: TextStyle(
                  color: Color.fromARGB(255, 207, 162, 74),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 40.0),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 207, 162, 74),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 40.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color.fromARGB(255, 207, 162, 74),
                width: 1.0,
              ),
            ),
          ),

          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}