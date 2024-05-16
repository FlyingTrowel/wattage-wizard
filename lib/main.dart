import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wattage Wizard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Wattage Wizard Home Page'),
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
  final _wattageKey = GlobalKey<FormState>();

  num _wattage = 0;
  num _rebate = 0;

  final wattageController = TextEditingController();
  final rebateController = TextEditingController();

  num _priceBeforeRebate = 0;
  num _priceAfterRebate = 0;
  String _formattedPriceAfterRebate = '';
  String _formattedPriceBeforeRebate = '';


  @override
  void dispose() {
    wattageController.dispose();
    rebateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        //Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _wattageKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Wattage (kWh)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Please enter the wattage';
                    }
                    // Check if the value is a valid number and not negative
                    if (double.tryParse(value) == null || double.parse(value) < 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  controller: wattageController,
                ),

              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Rebate (%)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  validator: (value){
                    // Check if the value is a valid number and not negative
                    final inputValue = value?.isEmpty ?? true ? '0' : value!; // Provide a default value
                    final parsedValue = double.tryParse(inputValue);
                    if (parsedValue == null || parsedValue < 0) {
                      return 'Please enter a valid number between 0 and 5';
                    }
                    if (parsedValue > 5) {
                      return 'Rebate value can\'t be more than 5';
                    }
                    return null;
                  },
                  controller: rebateController,
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  if (_wattageKey.currentState!.validate()) {
                    _wattage = double.parse(wattageController.text);
                    _rebate = double.tryParse(rebateController.text) ?? 0;
                    
                    if (_wattage <= 200) {
                      _priceBeforeRebate = _wattage * 0.218; // Rate for 1 - 200 kWh
                    } else if (_wattage <= 300) {
                      _priceBeforeRebate = 200 * 0.218 + (_wattage - 200) * 0.334; // Rate for 201 - 300 kWh
                    } else if (_wattage <= 600) {
                      _priceBeforeRebate = 200 * 0.218 + 100 * 0.334 + (_wattage - 300) * 0.516; // Rate for 301 - 600 kWh
                    } else {
                      _priceBeforeRebate = 200 * 0.218 + 100 * 0.334 + 300 * 0.516 + (_wattage - 600) * 0.546; // Rate for 601 kWh and above
                    }

                    _priceAfterRebate = _priceBeforeRebate * (1 - _rebate / 100);

                    _formattedPriceAfterRebate = _priceAfterRebate.toStringAsFixed(2);
                    _formattedPriceBeforeRebate = _priceBeforeRebate.toStringAsFixed(2);
                    // Update the state to reflect the new price
                    setState(() {});
                  }
                },
                child: const Text('Submit'),
              ),
              Text('Price after rebate: RM$_formattedPriceAfterRebate'),
              Text('Before rebate: RM$_formattedPriceBeforeRebate')
            ],
          ),
        )
      ),
    );
  }
}
