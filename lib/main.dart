import 'package:flutter/material.dart';
import 'package:local_storage/utils/DatabaseHelper.dart';

import 'models/car.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DataBaseHelper dbHelper = DataBaseHelper.instance;
  // DataBaseHelper.instance
  List<Car> cars = [];
  List<Car> carsByName = [];
  var isTextCleared = false;

  // for Insert tab
  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();

  // For Query by Car name Tab
  var nameQueryController = TextEditingController();
  var idUpdateController = TextEditingController();
  var nameUpdateController = TextEditingController();
  var milesUpdateController = TextEditingController();

  // for deleting car by id
  var idDeletedController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Insert',),
                Tab(text: 'View',),
                Tab(text: 'View By',),
                Tab(text: 'Update',),
                Tab(text: 'Delete',)
              ],
            ),
            title: Text('Local Storage'),
          ),
          body: TabBarView(
            children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                              ),
                              labelText: 'Car name'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextField(
                          controller: milesController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car Miles'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: (){
                              var name = nameController.text;
                              int miles = int.parse(milesController.text);
                              _insert(name, miles);
                            },
                            child: const Text('Insert'
                          )
                        )
                      ],
                    ),
                  )
                ),
                Center(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: cars.length + 1,
                      itemBuilder: (context, index){
                        if(index == cars.length){
                          return ElevatedButton(
                              onPressed: (){
                                _queryAll();
                              }, child: Text('Refresh'));
                        }
                        var car = cars[index];
                        return Text('Name: ${car.name} '
                            '-- Miles: ${car.miles}'
                            ' -- with Id: ${car.id}');
                        // return Text('heloo');
                      }),
                ),
                Center(
                  child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        controller: nameQueryController,
                        decoration:  const InputDecoration(
                          labelText: 'Car name',
                          border: UnderlineInputBorder()
                        ),
                        onChanged: (text){
                          if(text.length >= 2){
                            print('on changed invoked');
                            _queryByCarName(nameQueryController.text);
                          }else{
                            setState(() {
                              carsByName.clear();
                              isTextCleared = true;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 200,
                        child: ListView.builder(
                            itemCount: carsByName.length,
                            itemBuilder: (context, index){
                              var car = carsByName[index];
                              return Text('Name: ${car.name}, Miles: ${car.miles}, ID: ${car.id}');
                            }),
                      ),
                    )
                  ],
                ),),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: idUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car id'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextField(
                          controller: nameUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name to update'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        TextField(
                          controller: milesUpdateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Miles to update'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: (){
                              // get value from all TextField
                              var id = int.parse(idUpdateController.text);
                              var updatedName = nameUpdateController.text;
                              var updatedMiles = int.parse(milesUpdateController.text);
                               _updateCarById(id, updatedName, updatedMiles);
                            },
                            child: const Text('Update'))
                      ],
                    ),
                  )
                  ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: idDeletedController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Car id'
                          ),
                        ),
                        const SizedBox(height: 20,),
                        ElevatedButton(
                            onPressed: (){
                              _deleteCarById(int.parse(idDeletedController.text));
                            },
                            child: const Text('Delete'))
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      );
  }

  _showToastMessage(String message){
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _insert(String name, int miles) async{

    Map<String, dynamic> row = {
      DataBaseHelper.columnName : name,
      DataBaseHelper.columnMiles : miles
    };

    Car car = Car.fromMap(row);
    final id = await dbHelper!.insert(car);
    _showToastMessage('insert successfully from $id');
  }

  void _queryAll() async{
    final allRows = await dbHelper.queryAllRows();
    // prevent duplicate data
    cars.clear();
    for(var row in allRows!){
      cars.add(Car.fromMap(row));
    }
    setState(() {

    });
    // print('length ' + cars.length.toString());
    _showToastMessage("Successfully Fetch Data");
  }

  void _queryByCarName(name) async {
    final allRowsByName = await dbHelper.queryByCarName(name);
    // clear carsByName before adding to prevent duplicate result
    carsByName.clear();
    // print('car length ${carsByName.length}');
    for(var car in allRowsByName!){
      carsByName.add(Car.fromMap(car));
    }
    setState(() {});
    _showToastMessage('Query Success');
  }

  // update car by id
  void _updateCarById(id, updatedName, updatedMiles) async {
    final affectedRowUpdated = await dbHelper.updateCarById(Car(id: id, name: updatedName, miles: updatedMiles));
    _showToastMessage('updated success on $affectedRowUpdated rows');
  }

  // delete car by id
  void _deleteCarById(id) async {
    final deletedRow = await dbHelper.deleteCarById(id);
    _showToastMessage('deleted $deletedRow row');
  }
}
