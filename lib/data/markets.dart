
import 'package:cloud_firestore/cloud_firestore.dart';

class Market {
  final String id;
  final int idMarket;
  final GeoPoint location;
  

  Market({required this.id, required this.location, required this.idMarket});

  factory Market.fromMap(Map<String, dynamic> map, String id) {
    return Market(
      id: id,
      idMarket: map['id'],
      location: map['location'],
    );
  }
}
