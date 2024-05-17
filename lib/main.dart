import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Wattage Wizard'),
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

  num _priceBeforeRebate = 0.0;
  num _priceAfterRebate = 0.0;
  num _rebateAmount = 0.0;
  String _formattedPriceAfterRebate = '';
  String _formattedPriceBeforeRebate = '';
  String _formattedRebateAmount = '';



  int currentPageIndex = 0;

  bool _isRebatePresent = false;


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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // Colors.amber,
        title: Text(
          widget.title,
          style: const TextStyle(
              fontFamily: 'Roboto'
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.info),
            icon: Icon(Icons.info_outline),
            label: 'About')
        ],
      ),
      body: <Widget>[
        _buildHomePage(),
        _buildAboutPage(),
      ][currentPageIndex],
    );
  }

  Widget _buildHomePage(){
    return SingleChildScrollView(
        child: Center(
        child: Form(
          key: _wattageKey,
          child: Column(
            children: <Widget>[
              PriceDonutChart(
                priceBeforeRebate: _priceAfterRebate.toDouble(), // Replace with your actual values
                priceAfterRebate: _rebateAmount.toDouble(),
              ),
              Text('Amount to pay: RM$_formattedPriceAfterRebate'),
              Text('Before rebate: RM$_formattedPriceBeforeRebate'),
              Text('Rebate amount: RM$_formattedRebateAmount'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter wattage (kWh)',
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Rebate Eligibility',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Radio<bool>(
                        value: false,
                        groupValue: _isRebatePresent,
                        onChanged: (bool? value) {
                          setState(() {
                            _isRebatePresent = value!;
                            if (!value) {
                              rebateController.text = '';
                            }
                          });
                        },
                      ),
                      const Text('No'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: true,
                        groupValue: _isRebatePresent,
                        onChanged: (bool? value) {
                          setState(() {
                            _isRebatePresent = value!;
                            if (!value) {
                              rebateController.text = '';
                            }
                          });
                        },
                      ),
                      const Text('Yes'),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter rebate (0% - 5%)',
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
                      Fluttertoast.showToast(msg: 'Rebate value can\'t be more than 5%',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.blueGrey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return 'Rebate value can\'t be more than 5%';
                    }
                    return null;
                  },
                  controller: rebateController,
                  enabled: _isRebatePresent,
                ),
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0), // Set your desired padding
                  child: ElevatedButton(
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

                        _rebateAmount = _priceBeforeRebate * (_rebate/100);

                        _formattedPriceAfterRebate = _priceAfterRebate.toStringAsFixed(2);
                        _formattedPriceBeforeRebate = _priceBeforeRebate.toStringAsFixed(2);
                        _formattedRebateAmount = _rebateAmount.toStringAsFixed(2);

                        // Update the state to reflect the new price
                        setState(() {});
                      }
                    },
                    child: const Text('Submit'),

              )
              ),
            ],
          ),
        )
    )
    );
  }

  Widget _buildAboutPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'About Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto', // Use a consistent font family
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 240, // Adjust the size as needed
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/wattage_wizard_logo.jpeg', // Adjust the asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 64),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white, // Customize the background color
              borderRadius: BorderRadius.circular(32), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Group: RCDCS251 5B\n'
                      'Student Number: 2023376281\n'
                      'Programme Code: CDCS251\n'
                      'Information: Wattage rates calculator\n'
                      '© 2024 Aieman Nur Hakim Roslan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto', // Use a consistent font family
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await launchUrlString('https://github.com/FlyingTrowel/wattage-wizard');
                    } catch (err) {
                      debugPrint('Something bad happened');
                    }
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('View on GitHub'), // Clear label for the link
                ),
              ],
            ),
          ),
          // You can add more widgets or customize further as needed
        ],
      ),
    );
  }


}

class PriceDonutChart extends StatelessWidget {
  final double priceBeforeRebate;
  final double priceAfterRebate;

  const PriceDonutChart({
    super.key,
    required this.priceBeforeRebate,
    required this.priceAfterRebate,
  });


  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    String formattedPriceBeforeRebate = priceBeforeRebate.toStringAsFixed(2);
    String formattedPriceAfterRebate = priceAfterRebate.toStringAsFixed(2);
    return [
      PieChartSectionData(
        color: Colors.lightBlueAccent,
        value: priceBeforeRebate,
        title: 'RM $formattedPriceBeforeRebate',
        radius: 70.0,
        titleStyle: const TextStyle(
          fontSize: 16.0,
          shadows: [Shadow(color: Colors.black, blurRadius: 1)],
        ),
      ),
      PieChartSectionData(
        color: Colors.greenAccent,
        value: priceAfterRebate,
        title: 'RM $formattedPriceAfterRebate',
        radius: 70.0,
        titleStyle: const TextStyle(
          fontSize: 16.0,
          shadows: [Shadow(color: Colors.black, blurRadius: 1)],
        ),
      ),
    ];
  }
}




