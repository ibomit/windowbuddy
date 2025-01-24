import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:windowbuddy/Theme/theme_manager.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final String particleAccessToken = "091e8b9d58a116227a15b6068f0e8ec309674370"; //TODO: Replace with your Particle access token
  final String particleDeviceID = "400024001147353138383138"; //TODO: Replace with your Particle device ID
  bool? windowOpened;
  bool isLoading = false;
  double loadingProgress = 0;
  bool showDeveloperOptions = false;

  Future<void> controlMotor(String action) async {
    setState(() {
      isLoading = true;
      loadingProgress = 0;
    });

    // Simulate loading progress
    Timer.periodic(const Duration(milliseconds: 75), (timer) {
      if (loadingProgress >= 100) {
        timer.cancel();
      } else {
        setState(() {
          loadingProgress += 1.2;
        });
      }
    });

    // Show an alert if the action is not allowed
    if ((action == 'open' && windowOpened == true) || (action == 'close' && windowOpened == false)) {
      _showActionNotAllowedDialog(action);
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.particle.io/v1/devices/$particleDeviceID/controlMotor'),
        body: {
          'args': action,
          'access_token': particleAccessToken,
        },
      );
      if (response.statusCode == 200) {
        await checkWindowPosition(); // Refresh window status
      }
    } catch (e) {
      debugPrint("Error controlling motor: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkWindowPosition() async {
    try {
      final response = await http.post(
        Uri.parse('https://api.particle.io/v1/devices/$particleDeviceID/getWindowPosition'),
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
      debugPrint("Error fetching window position: $e");
    }
  }

  Future<void> setWindowPosition(bool opened) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.particle.io/v1/devices/$particleDeviceID/setWindowPosition'),
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
      debugPrint("Error setting window position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(themeManager),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildMotorControls(),
                    const SizedBox(height: 20),
                    _buildDeveloperOptions(),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(context), // Add the logout button here
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeManager themeManager) {
    return Container(
      decoration: BoxDecoration(
        color: themeManager.themeMode == ThemeMode.dark
            ? Colors.deepOrange
            : Colors.teal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'lib/img/logo.png',
            height: 50,
            width: 50,
          ),
          Row(
            children: [
              Icon(
                themeManager.themeMode == ThemeMode.light
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
              Switch(
                value: themeManager.themeMode == ThemeMode.dark,
                onChanged: themeManager.toggleTheme,
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotorControls() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Motor Controls',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAnimatedButton(
                  label: 'Open',
                  icon: Icons.arrow_upward,
                  color: Colors.teal,
                  onPressed: () => controlMotor('open'),
                ),
                _buildAnimatedButton(
                  label: 'Close',
                  icon: Icons.arrow_downward,
                  color: Colors.redAccent,
                  onPressed: () => controlMotor('close'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoading)
              LinearProgressIndicator(
                value: loadingProgress / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.teal,
                minHeight: 8,
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Window Status: ${windowOpened == null ? "Unknown" : (windowOpened! ? "Opened" : "Closed")}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    checkWindowPosition(); // Refresh the window status
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperOptions() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text(
                'Advanced Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(showDeveloperOptions
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onTap: () {
                setState(() {
                  showDeveloperOptions = !showDeveloperOptions;
                });
              },
            ),
            if (showDeveloperOptions)
              Column(
                children: [
                  const Text(
                    'Override window position ',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(
                        child: Switch(
                          value: windowOpened ?? false,
                          onChanged: (value) {
                            setWindowPosition(value);
                          },
                          activeColor: Colors.teal,
                          inactiveThumbColor: Colors.redAccent,
                          inactiveTrackColor: Colors.grey,
                        ),
                      ),
                      const Text(
                        'Open',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  void _showActionNotAllowedDialog(String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Action Not Allowed'),
          content: Text(
            'The window is already ${action == 'open' ? 'opened' : 'closed'}. You cannot ${action == 'open' ? 'open' : 'close'} it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
