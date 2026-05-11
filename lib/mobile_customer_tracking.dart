import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomerOrderTracking extends StatelessWidget {
  const CustomerOrderTracking({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text("تتبع طلباتي",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orders').where('customerEmail', isEqualTo: userEmail).orderBy('orderDate', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("لم تقم بإجراء أي طلبات بعد."),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var status = order['status'] ?? 'Pending';
              var date = (order['orderDate'] as Timestamp).toDate();
              var items = order['items'] as List;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: _getStatusIcon(status),
                  title: Text("طلب بتاريخ: ${DateFormat('yyyy-MM-dd').format(date)}"),
                  subtitle: Text("الحالة: ${_translateStatus(status)}",
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [

                    Divider(),

                    ...items.map((item) =>
                        ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: item["ImageURL"],
                            height: 50,
                            width: 50,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                          ),
                          title: Text(item['Product']),
                          trailing: Text("RY ${item['Price']}"),
                        )),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("إجمالي المنتجات:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${items.length} منتجات"),
                        ],
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'Accepted': return Icon(Icons.check_circle, color: Colors.green);
      case 'Rejected': return Icon(Icons.cancel, color: Colors.red);
      case 'Pending': return Icon(Icons.hourglass_empty, color: Colors.orange);
      default: return Icon(Icons.help_outline);
    }
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'Accepted': return "تم القبول";
      case 'Rejected': return "تم الرفض";
      case 'Pending': return "قيد الانتظار";
      default: return "غير معروف";
    }
  }
}