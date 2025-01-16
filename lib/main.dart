import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:windowbuddy/Theme/theme_constants.dart';
import 'package:windowbuddy/Theme/theme_manager.dart';

void main() {
  runApp(MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  @override 
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override 
  void initState() {
    _themeManager.addListener(themeListener);
    super.initState();
  }
  
  themeListener() {
    if(mounted){
      setState(() {

      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WindowBuddy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeManager.themeMode,
      home: MyHomeScreen(),
    );
  }
}

class MyHomeScreen extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final String particleAccessToken = "091e8b9d58a116227a15b6068f0e8ec309674370";
  final String particleDeviceID = "400024001147353138383138";
  bool? windowOpened;
  bool isLoading = false;
  double loadingProgress = 0;
  bool showDeveloperOptions = false;



 
  // HTTP Request for controlling the motor
  Future<void> controlMotor(String action) async {
    setState(() {
      isLoading = true;
      loadingProgress = 0;
    });

    // Simulate loading bar progress
    Timer.periodic(Duration(milliseconds: 75), (timer) {
      setState(() {
        loadingProgress += 1;
        if (loadingProgress >= 100) timer.cancel();
      });
    });

    try {
      final response = await http.post(
        Uri.parse(
            'https://api.particle.io/v1/devices/$particleDeviceID/controlMotor'),
        body: {
          'args': action,
          'access_token': particleAccessToken,
        },
      );
      if (response.statusCode == 200) {
        await checkWindowPosition(); // Refresh window status
      }
    } catch (e) {
      print("Error controlling motor: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check window position
  Future<void> checkWindowPosition() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.particle.io/v1/devices/$particleDeviceID/getWindowPosition'),
        body: {
          'args': 'unused',
          'access_token': particleAccessToken,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          windowOpened = data['return_value'] == 1;
        });
      } else {
        setState(() {
          windowOpened = null; // Unknown state
        });
      }
    } catch (e) {
      setState(() {
        windowOpened = null;
      });
      print("Error fetching window position: $e");
    }
  }

  // Toggle window position manually (developer option)
  Future<void> setWindowPosition(bool opened) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://api.particle.io/v1/devices/$particleDeviceID/setWindowPosition'),
        body: {
          'args': opened.toString().toLowerCase(),
          'access_token': particleAccessToken,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          windowOpened = opened;
        });
      }
    } catch (e) {
      print("Error setting window position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WindowBuddy'),
        centerTitle: true,
        actions: [Switch(value: _themeManager.themeMode == ThemeMode.dark, onChanged: (newValue){
          _themeManager.toggleTheme(newValue);
        },)]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Motor Controls
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Motor Controls',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () => controlMotor('open'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                            ),
                            child: const Text(
                              'Open',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => controlMotor('close'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                            ),
                            child: const Text(
                              'Close',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Loading Bar
                      if (isLoading)
                        LinearProgressIndicator(
                          value: loadingProgress / 100,
                          backgroundColor: Colors.grey[200],
                          color: Colors.teal,
                          minHeight: 10,
                        ),
                      const SizedBox(height: 20),
                      // Window Status
                      Text(
                        'Window Status: ${windowOpened == null ? "Unknown" : (windowOpened! ? "Opened" : "Closed")}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Developer Options
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showDeveloperOptions = !showDeveloperOptions;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Advanced Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              showDeveloperOptions
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ],
                        ),
                      ),
                      if (showDeveloperOptions) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setWindowPosition(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          child: const Text(
                            'Set Opened',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => setWindowPosition(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                          ),
                          child: const Text(
                            'Set Closed',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
