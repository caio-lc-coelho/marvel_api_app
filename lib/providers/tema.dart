import 'package:marvel_api_app/index.dart';
import 'package:flutter/material.dart';

class Tema with ChangeNotifier {
  static bool _isDark = false;
  static bool _isSystem = true;

  Tema() {
    if (App.cache.containsKey('temaAtual')) {
      switch (App.cache.getString('temaAtual')) {
        case 'Claro':
          _isDark = false;
          _isSystem = false;
          break;
        case 'Escuro':
          _isDark = true;
          _isSystem = false;
          break;
        default:
          _isDark = false;
          _isSystem = true;
      }
    } else {
      App.cache.setString('temaAtual',
          'Sistema'); //Por padrão, o tema seguirá o estabelecido nas configurações do sistema
    }
  }

  ThemeMode currentTheme() {
    return _isSystem
        ? ThemeMode.system
        : _isDark
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  void setTheme({bool temaEscuro}) {
    if (temaEscuro == null) {
      _isSystem = true;
      _isDark = false;
      App.cache.setString('temaAtual', 'Sistema');
    } else {
      _isDark = temaEscuro;
      _isSystem = false;
      App.cache.setString('temaAtual', temaEscuro ? 'Escuro' : 'Claro');
    }
    notifyListeners();
  }
}
