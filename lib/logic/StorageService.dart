import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:markets_data_inserting/data/markets.dart';

class StorageService {
  //final FirebaseStorage _storage = FirebaseStorage.instance;
  final storageRef = FirebaseStorage.instance.ref();
  final CollectionReference marketsCollection = FirebaseFirestore.instance.collection('markets');

 Future<List<Market>> getMarkets() async {
    try {
      QuerySnapshot snapshot = await marketsCollection.get();
      return snapshot.docs.map((doc) => Market.fromMap(doc.data() as Map<String, dynamic> , doc.id)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting Markets: $e');
      }
      return [];
    }
  }

  Future<void> addMarket(int id, GeoPoint location) async {
  try {
    CollectionReference marketCollection = FirebaseFirestore.instance.collection('markets');
    
    await marketCollection.add({
      'id': id,
      'location': location,
      // Add other fields as needed
    });

    if (kDebugMode) {
      print('Market added successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error adding Market: $e');
    }
  }
}
}
