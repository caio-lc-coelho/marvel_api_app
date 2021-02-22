import 'package:marvel_api_app/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App {
  static final App instance = App();
  static final Api api = Api();

  static SharedPreferences cache; //Para que o cache esteja disponível em todo o app
  static List<DadosComic> comics =
      []; //Para que a lista já exista e esteja disponível e só seja populada pela chamada da API
  static List<DadosComic> comicsCarrinho =
      []; //Para que a lista de compras já exista e esteja disponível e só seja populado pelo cache
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
  static BuildContext context =
      navigator.currentState.overlay.context; //Para que o contexto sempre esteja disponível, mesmo em Stateless Widgets

  static Tema tema = Tema();

  Future<void> initializeApp() async {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //Para que a status bar fique transparente
    ));

    cache = await SharedPreferences.getInstance();
    App.comics = await api.buscarComics();
  }
}
