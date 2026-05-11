import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'web_admin_orders.dart';
import 'dbfirebase.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isUploading = false;

  Future<void> pickAndUploadExcel() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return;

    setState(() => isUploading = true);

    try {
      final excel = Excel.decodeBytes(result.files.single.bytes!);
      final sheet = excel.tables.values.first;

      if (sheet.maxRows < 2) throw "الملف فارغ";

      final headers = sheet.row(0).map((c) => c?.value?.toString() ?? '').toList();

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        final Map<String, dynamic> data = {};

        for (int j = 0; j < headers.length; j++) {
          if (j < row.length) data[headers[j]] = row[j]?.value?.toString() ?? '';
        }

        if (data.isNotEmpty) await DatabaseMethods().addProducts(data);
      }

      Fluttertoast.showToast(
          msg: 'تم رفع البيانات بنجاح!',
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
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> showEditDialog(String docId, Map<String, dynamic> currentData) async {
    final TextEditingController nameController = TextEditingController(text: currentData['Product']);
    final TextEditingController priceController = TextEditingController(text: currentData['Price']);
    final TextEditingController qtyController = TextEditingController(text: currentData['Quantity']);
    final TextEditingController imageUrlController = TextEditingController(text: currentData['ImageURL']);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تعديل بيانات المنتج"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "اسم المنتج")),
              TextField(controller: priceController, decoration: InputDecoration(labelText: "السعر"), keyboardType: TextInputType.number),
              TextField(controller: qtyController, decoration: InputDecoration(labelText: "الكمية"), keyboardType: TextInputType.number),
              TextField(controller: imageUrlController, decoration: InputDecoration(labelText: "رابط الصورة (GitHub)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              Map<String, dynamic> updatedData = {
                "Product": nameController.text,
                "Price": priceController.text,
                "Quantity": qtyController.text,
                "ImageURL": imageUrlController.text,
              };
              await DatabaseMethods().updateProducts(docId, updatedData);
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: 'تم التحديث بنجاح',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black45,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            },
            child: Text("حفظ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("لوحة تحكم المسؤول",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => AdminOrdersPage()),
            );
          },
        ),
        ],
      ),
      body: Column(
        children: [
          if (isUploading) LinearProgressIndicator(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Products").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return docs.isEmpty
                    ? Center(child: Text("لا يوجد منتجات"))
                    : ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    return Card(
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: data["ImageURL"],
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                        ),

                        title: Text(data['Product'] ?? 'منتج غير معروف'),
                        subtitle: Text('السعر: ${data['Price']} | الكمية: ${data['Quantity']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Color.fromARGB(255, 207, 162, 74)),
                          onPressed: () => showEditDialog(docId, data),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : pickAndUploadExcel,
        label: Text('رفع Excel'),
        icon: Icon(Icons.upload),
      ),
    );
  }
}