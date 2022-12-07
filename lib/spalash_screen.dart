import 'package:ai_radio_app/pages/home_page.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash ({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigatetohome();
  }

  _navigatetohome()async{
    await Future.delayed(Duration(milliseconds: 2000),() {});
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context)=>Homepage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
              child:Text(
                'Ai Radio',
              style: TextStyle(fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  ),
              ),
            ),
      ),
      );
  }
}

