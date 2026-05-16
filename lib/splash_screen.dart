import 'package:flutter/material.dart';
import 'package:smartpos/screens/dashboard_screen.dart';
import 'package:smartpos/widget/screen_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2563EB),
      body: ScreenAnimation(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white70,
                  size: 72,
                ),
              ),
              SizedBox(height: 28),
              Text(
                'Smart POS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your Business easily',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),SizedBox(height: 25,),
              Text('..',style: TextStyle(color: Colors.white70,fontSize: 32,letterSpacing: 4),)
            ],
          ),
        ),
      ),
    );
  }
}
