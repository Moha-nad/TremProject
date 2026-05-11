import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dbfirebase.dart';
import 'mobile_customer_cart.dart';
import 'mobile_customer_profile.dart';
import 'mobile_customer_tracking.dart';


List<Map<String, dynamic>> cartItems = [];

class CustomerProducts extends StatefulWidget {
  const CustomerProducts({super.key});

  @override
  State<CustomerProducts> createState() => _CustomerProductsState();
}

class _CustomerProductsState extends State<CustomerProducts> {

  Stream? productStream;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  loadProducts() async {
    productStream = await DatabaseMethods().getProducts();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المنتجات",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomerCart()),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
          builder: (context, snapshot) {
            String userName = "جاري التحميل...";
            String userEmail = FirebaseAuth.instance.currentUser?.email ?? "لا يوجد بريد";

            if (snapshot.hasData && snapshot.data!.exists) {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              userName = userData['name'] ?? "بدون اسم";
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Color.fromARGB(255, 207, 162, 74)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Color.fromARGB(255, 207, 162, 74)),
                      ),

                      SizedBox(height: 10),

                      Text(userName,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.white),),
                      Text(userEmail,style: TextStyle(fontSize: 12, color: Colors.white70),),
                    ],
                  ),
                ),

                ListTile(
                  leading: Icon(Icons.account_box, color: Color.fromARGB(255, 207, 162, 74)),
                  title: Text('الملف الشخصي'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerProfile()),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(Icons.history, color: Color.fromARGB(255, 207, 162, 74)),
                  title: Text('طلباتي'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerOrderTracking())
                    );
                  },
                ),

                Divider(),

                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('تسجيل الخروج'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                ),
              ],
            );
          },
        ),
      ),

      body: StreamBuilder(
        stream: productStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return Card(
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    CachedNetworkImage(
                      imageUrl: ds["ImageURL"],
                      height: 80,
                      width: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                    ),

                    SizedBox(height: 8),

                    Text(ds["Product"], style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("RY ${ds["Price"]}", style: TextStyle(color: Colors.green)),
                    Text("الكمية: ${ds["Quantity"]}"),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          cartItems.add({
                            "Product": ds["Product"],
                            "Price": ds["Price"],
                            "ImageURL": ds["ImageURL"],
                            "Quantity": 1,
                          });
                        });

                        Fluttertoast.showToast(
                            msg: ' تم إضافة ${ds["Product"]} إلى العربة',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black45,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 207, 162, 74),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        minimumSize: Size(60, 30),
                      ),
                      child: Text("إضافة إلى العربة", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}