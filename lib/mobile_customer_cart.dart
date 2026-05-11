import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'mobile_customer_products.dart';
import 'dbfirebase.dart';

class CustomerCart extends StatefulWidget {
  const CustomerCart({super.key});

  @override
  State<CustomerCart> createState() => _CustomerCartState();
}

class _CustomerCartState extends State<CustomerCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("عربة التسوق",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),

      body: cartItems.isEmpty
          ? Center(child: Text("العربة فارغة"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: item["ImageURL"],
                      height: 50,
                      width: 50,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                    ),

                    title: Text(item["Product"], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("السعر: RY${item["Price"]}"),

                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          cartItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            )
          ),

          Padding(
            padding: EdgeInsets.all(16.0),
            child:
            ElevatedButton(
              onPressed: () async {
                if (cartItems.isEmpty) return;

                try {
                  Map<String, dynamic> Confirmed = {
                    "customerEmail": FirebaseAuth.instance.currentUser?.email,
                    "items": cartItems,
                    "status": "Pending",
                    "orderDate": DateTime.now(),
                  };

                  await DatabaseMethods().addOrders(Confirmed);

                  setState(() {
                    cartItems.clear();
                  });

                  Navigator.pop(context);

                  Fluttertoast.showToast(
                      msg: 'تم إرسال الطلب بنجاح!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: 'حدث خطأ: $e',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black45,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                }
              },
              child: Text("تأكيد الطلب"),
            ),
          )
        ],
      ),
    );
  }
}