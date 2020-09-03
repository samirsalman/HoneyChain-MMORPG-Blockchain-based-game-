import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';
import 'package:honeychain/screens/home_page.dart';
import 'package:honeychain/screens/login.dart';
import 'package:honeychain/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserSessionBloc>(
          create: (context) => UserSessionBloc(Starting())..add(StartApp()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Honey Chain',
        theme: ThemeData(
          backgroundColor: Colors.white,
          textTheme: GoogleFonts.rubikTextTheme(
            Theme.of(context).textTheme,
          ),
          primarySwatch: Colors.amber,
          primaryColor: Colors.amber,
          canvasColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Honey Chain'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      builder: (context, state) {
        if (state is Starting) {
          //SplashScreen
          return SplashScreen();
        }

        if (state is Logged) {
          return HomePageScreen();
        }

        if (state is UnLogged ||
            state is Error ||
            state is RegistrationSuccess) {
          return LoginScreen();
        }

        if (state is Ready) {}

        if (state is Loading) {}
      },
      cubit: BlocProvider.of<UserSessionBloc>(context),
    );
  }
}
