import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  //const SignUpScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final List<String> aufgabenList = [
  'Schnibbeln',
  'Aufräumen',
  'Einkaufen',
  'Grillen',
  ];

  String? selectedValueTask;

  final List<String> veggieList = [
  'Veggie',
  'Fleisch',
  'Wurst',
  'Fleisch und Wurst',
  ];

  String? selectedValueVeggie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor.withOpacity(.1),
        title: const Text('Veggieday Anmeldung'),
      ),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Enter your name here
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text){
                      print(text);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Bitte deinen Namen eingeben';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  // veggie or meat
                  DropdownButtonFormField(
                    items: veggieList.map((item) =>
                      DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )
                    )
                    .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Veggie oder Fleisch?',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedValueTask,
                    onChanged: (value) {
                      print(value);
                      // setState(() {
                      //   selectedValue = value as String;
                      // });
                    },),
                  SizedBox(height: 20),
                  // task
                  DropdownButtonFormField(
                    items: aufgabenList.map((item) =>
                      DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      )
                    )
                    .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Aufgabe',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedValueVeggie,
                    onChanged: (value) {
                      print(value);
                      // setState(() {
                      //   selectedValue = value as String;
                      // });
                    },),
                  SizedBox(height: 20),
                  //Zurück Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: const Icon(Icons.arrow_back),
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate back to first route when tapped.
                        },
                        // child: const Text('Zurück!'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: () {
                          //TODO animation sign up successfull

                        },
                        child: const Text('Anmelden!'),
                      ),
                    ],
                  ),
                ],
              )
            )
          )
        ),
    );
  }
}
