import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markets_data_inserting/data/markets.dart';

import '../logic/StorageService.dart';
import '../widgets/HomeAppBar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool startAnimation = false;
  final CollectionReference _marketsCollection =
      FirebaseFirestore.instance.collection('markets');
  final TextEditingController _textFieldController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Market> markets = [];

  late int insertedMarketId;
  late GeoPoint insertedLocation;
  Stream<QuerySnapshot> getMarketsCountStream() {
    return _marketsCollection.snapshots();
  }

  @override
  void initState() {
    super.initState();
    _getMarkets();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        startAnimation = true;
      });
    });
  }

  Future<void> _getMarkets() async {
    List<Market> marketList = await StorageService().getMarkets();
    setState(() {
      markets = marketList;
    });
  }

  Stream<int> collectionSizeStream(CollectionReference collection) {
    return collection.snapshots().map((snapshot) => snapshot.size);
  }

  Future<void> _getLengthOfMarkets() async {
    int collectionSize = await collectionSizeStream(_marketsCollection).first;
    if (kDebugMode) {
      print("Collection size is $collectionSize");
    }

    insertedMarketId = collectionSize;
  }

  Future<void> _addMarket(int id, GeoPoint location) async {
    await StorageService().addMarket(id, location);
    if (kDebugMode) {
      print("$id ,${location.longitude};,${location.latitude}");
    }
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add a new Market'),
            content: TextField(
              onSubmitted: (value) {
                setState(() {
                  List<String> coordinates = value.split(',');
                  double latitude = double.parse(coordinates[0]);
                  double longitude = double.parse(coordinates[1]);
                  // Create a GeoPoint object using the extracted values
                  insertedLocation = GeoPoint(latitude, longitude);
                  _getLengthOfMarkets();
                });
              },
              controller: _textFieldController,
              decoration:
                  const InputDecoration(hintText: "Text Field in Dialog"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('ADD'),
                onPressed: () {
                  setState(() {
                    _addMarket(insertedMarketId, insertedLocation);
                    Navigator.pop(context);
                    //codeDialog = valueText;
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      appBar: HomeAppBar(auth: _auth),
      body: StreamBuilder<QuerySnapshot>(
          stream: _marketsCollection.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Markets available.'));
            }
            List<DocumentSnapshot> documents = snapshot.data!.docs;
            documents.sort((a, b) => b['id'].compareTo(a['id']));
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  var marketData =
                      documents[index].data() as Map<String, dynamic>;
                  int id = marketData['id'];
                  GeoPoint location = marketData['location'];
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Theme.of(context).indicatorColor,
                        ),
                        borderRadius: BorderRadius.circular(50), //<-- SEE HERE
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(id.toString()),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child:
                            Text("${location.latitude},${location.longitude}"),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
