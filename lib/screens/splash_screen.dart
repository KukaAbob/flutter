import 'package:flutter/material.dart';
import '../screens/homepage.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          
          // Calculate responsive font sizes with constraints
          final buttonFontSize = (maxWidth * 0.015).clamp(16.0, 24.0);
          
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "assets/main.jpg",
                fit: BoxFit.cover,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(maxWidth * 0.02),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth * 0.3,
                          minWidth: 100,
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF669966),
                            padding: EdgeInsets.symmetric(
                              horizontal: (maxWidth * 0.02).clamp(20.0, 40.0),
                              vertical: (maxHeight * 0.015).clamp(10.0, 20.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
                          child: Text(
                            "Start",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.2),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
