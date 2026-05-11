import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  FirebaseFirestore fdb = FirebaseFirestore.instance;

  Future addProducts(Map<String, dynamic> ProductsInfoMap) async {
    return await fdb.collection("Products").add(ProductsInfoMap);
  }

  Future updateProducts(String docId,Map<String, dynamic> newProduct) async {
    return fdb.collection('Orders').doc(docId).update(newProduct);
  }

  Future<Stream<QuerySnapshot>> getProducts() async {
    return fdb.collection("Products").snapshots();
  }

  Future addOrders(Map<String, dynamic> OrdersInfoMap) async {
    return await fdb.collection("Orders").add(OrdersInfoMap);
  }

  Future addUsers(String userid,Map<String, dynamic> UsersInfoMap) async {
    return await fdb.collection("Users").doc(userid).set(UsersInfoMap,SetOptions(merge: true));
  }

  // دالة تحديث الحالة في Firebase
  Future updateStatus(String docId, String newStatus) async {
    return await fdb.collection('Orders').doc(docId).update({"status": newStatus,});
  }
}