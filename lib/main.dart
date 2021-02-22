import 'dart:convert';

import 'package:marvel_api_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    //Trava o app sempre na vertical
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await App.instance.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    App.tema.addListener(() {
      setState(() {});
    });

    if (!App.cache.containsKey('temaAtual'))
      App.cache
          .setString('temaAtual', 'Sistema'); //Por padrão, o tema seguirá o estabelecido nas configurações do sistema

    if (!App.cache.containsKey('comicsCarrinho')) {
      App.cache.setString('comicsCarrinho',
          ''); //Criada a lista de ids de comics no carrinho, mesmo que vazia, para não ter problemas no carregamentos de telas que dependem dessa variável em cache
    } else if (App.cache.containsKey('comicsCarrinho') && App.cache.getString('comicsCarrinho') != '') {
      App.comicsCarrinho = List<DadosComic>.from(json.decode(App.cache.getString('comicsCarrinho')).map((i) =>
          DadosComic.fromJson(
              i))); //Adiciona a lista de itens no carrinho carregada do cache, caso essa lista exista em cache e esteja populada
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARVEL',
      navigatorKey: App.navigator,
      debugShowCheckedModeBanner: false,
      home: _introScreen(),
      themeMode: App.tema.currentTheme(),
      theme: ThemeData(
        primaryColor: Color(0xFFED1922),
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],
    );
  }

  Widget _introScreen() {
    return Stack(
      children: <Widget>[
        SplashScreen(
          seconds: 4,
          backgroundColor: Color(0xFFED1922),
          navigateAfterSeconds: Lista(),
          loaderColor: Colors.white,
        ),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/logo.png"),
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ],
    );
  }
}
