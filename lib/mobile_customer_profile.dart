import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dbfirebase.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({super.key});

  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSaving = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  _loadCurrentUserData() async {
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc['name'] ?? '';
          _addressController.text = doc['address'] ?? '';
          _phoneController.text = doc['phone'] ?? '';
        });
      }
    }
  }

  _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      Map<String, dynamic> Saving = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': user!.email,
        'lastUpdated': DateTime.now(),
    };
      await DatabaseMethods().addUsers(user!.uid, Saving);

      Fluttertoast.showToast(
          msg: 'تم حفظ البيانات الشخصية بنجاح',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'حدث خطأ أثناء الحفظ: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الملف الشخصي",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [

            CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 207, 162, 74),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),

            SizedBox(height: 10),

            Text(user?.email ?? "البريد الإلكتروني",
                style: TextStyle(color: Colors.grey)),

            SizedBox(height: 30),

            _buildTextField("الاسم الكامل", Icons.person_outline, _nameController),

            SizedBox(height: 15),

            _buildTextField("العنوان (المدينة - الشارع)", Icons.location_on_outlined, _addressController),

            SizedBox(height: 15),

            _buildTextField("رقم الهاتف", Icons.phone_android, _phoneController, isNumber: true),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 207, 162, 74),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("حفظ التعديلات", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 207, 162, 74)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 207, 162, 74), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}