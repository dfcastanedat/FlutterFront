import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List eventData;
  String _event, _about, _toerase;
  final _formKey = GlobalKey<FormState>();


  Future<List> getData() async {
    http.Response response =
        await http.get("http://192.168.0.15:8000/api/Events/");
    return json.decode(response.body);
  }

  Future listing() async {
    List __events = await getData();
    setState(() {
      eventData = __events;
    });
  }


  void initState() {
    super.initState();
    listing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuestra Aplicación"),
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: eventData == null ? 0 : eventData.length,
        itemBuilder: (BuildContext context, int index) {
          return
            Center(
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                   ListTile(
                    title: Text("${eventData[index]["event"]}",
                      style: TextStyle(
                        fontSize: 20.0
                      )),
                    subtitle: Text("${eventData[index]["about"]}",
                      style: TextStyle(
                        fontSize: 17.0
                      )),
                  ),
                  ButtonTheme.bar( // make buttons use the appropriate styles for cards
                    child: ButtonBar(
                      children: <Widget>[
                        Text("Añadido por: " + "${eventData[index]["name"]}",
                            style: TextStyle(
                                fontSize: 15.0
                            )),
                        FlatButton(
                          child: Text('Eliminar'),
                          onPressed:(){
                            _toerase = eventData[index]["id"].toString();
                            __delete1();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: new InputDecoration(
                              focusColor: Colors.pink,
                              hintText: 'Nombre del evento a agregar',
                              labelText: 'Evento',
                              labelStyle: TextStyle(
                                color: Colors.pink,
                              ),
                            ),
                            validator: (input) => input.length <= 0 ? 'Introduce un nombre de evento' : null,
                            onSaved: (input) => _event = input,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: new InputDecoration(
                              labelText: 'Info',
                              labelStyle: TextStyle(
                                color: Colors.pink,
                              ),
                              hintText: 'Información del evento a agregar',
                              focusColor: Colors.pink,
                            ),
                            validator: (input) => input.length <= 0 ? 'Introduce información para el evento' : null,
                            onSaved: (input) => _about = input,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RaisedButton(
                            textColor: Colors.white,
                            color: Colors.pink,
                            child: Text("Crear Evento"),
                            onPressed: __submit,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
  void __submit(){
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      debugPrint(_about);
      debugPrint(_event);
    }
    __create_event();
    Navigator.pop(context);
  }

  void __create_event() async {
    String event = _event;
    String about = _about;
    Map data = {
      'name': 'Daniel',
      'event': _event,
      'about': _about
    };
    var body = json.encode(data);
    http.Response response =
    await http.post("http://192.168.0.15:8000/api/Events/",headers:{"Content-Type": "application/json"}, body: body);
    getData();
    listing();
  }

  void __delete1(){
    debugPrint(_toerase);
    __delete2(_toerase);
  }

  void __delete2(toerase) async {
    http.Response response =
    await http.delete("http://192.168.0.15:8000/api/Events/"+toerase+"/");
    debugPrint(response.toString());
    getData();
    listing();
  }
}
