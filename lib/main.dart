import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/responsive/mobile_screen_Layout.dart';
import 'package:instagram_clone/responsive/responsive_Layout.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
      options:  const FirebaseOptions(
          apiKey: "AIzaSyCokh8nRrJqfgw5qFg6Q0b7x7NBxdjiMu0",
          authDomain: "instagram-clone-a29da.firebaseapp.com",
          projectId: "instagram-clone-a29da",
          storageBucket: "instagram-clone-a29da.appspot.com",
          messagingSenderId: "923507061629",
          appId: "1:923507061629:web:3395b4cf429103dc471214",
      )
    );
  }
  else{
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyAhez2TzMj63zgWaaXIY9VPqH0Q4kJwPd8',
          appId: '1:923507061629:android:e39e0c95f1d019e0471214',
          messagingSenderId: '923507061629',
          projectId: 'instagram-clone-a29da',
          storageBucket: 'gs://instagram-clone-a29da.appspot.com',
      )
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram Clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home:
        StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const ResponsiveLayout(
                  mobileScreenLayout: MobileScreenLayout(),
                  webScreenLayout: WebScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

