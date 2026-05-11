import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dbfirebase.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("إدارة طلبات العملاء",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          return orders.isEmpty
              ? Center(child: Text("لا يوجد طلبات"))
              : ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var items = order['items'] as List;

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text("طلب من: ${order['customerEmail']}"),
                  subtitle: Text("الحالة: ${order['status']}"),
                  children: [
                    // عرض تفاصيل المنتجات داخل الطلب
                    ...items.map((item) => ListTile(
                      title: Text(item['Product']),
                      trailing: Text("السعر: ${item['Price']}"),
                      leading: CachedNetworkImage(
                        imageUrl: item["ImageURL"],
                        height: 50,
                        width: 50,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                      ),
                    )).toList(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            DatabaseMethods().updateStatus(order.id, "Accepted");
                            Fluttertoast.showToast(
                                msg: 'تم قبول الطلب',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text("قبول الطلب"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            DatabaseMethods().updateStatus(order.id, "Rejected");
                            Fluttertoast.showToast(
                                msg: 'تم رفض الطلب',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                            },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: Text("رفض الطلب"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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