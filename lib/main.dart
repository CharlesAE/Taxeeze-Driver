import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxeeze_driver/splash_screen.dart';

import 'global/app_info.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  runApp(
      Taxeeze(
        child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
          title: 'Taxeeze Driver',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home:  MySplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
        //)
      )

  )
  );
}

class Taxeeze extends StatefulWidget {
  final Widget? child;
  Taxeeze({this.child});

  static  void restarttApp(BuildContext context)
  {
    context.findAncestorStateOfType<_TaxeezeState>()!.restartApp();
  }

  @override
  _TaxeezeState createState() => _TaxeezeState();
}

class _TaxeezeState extends State<Taxeeze> {
  Key key = UniqueKey();
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
