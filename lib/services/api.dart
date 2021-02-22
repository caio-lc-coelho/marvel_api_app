import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:marvel_api_app/index.dart';

const String API_PUBLIC_KEY = '259fb6f11139bf27ac2e75fff9b9fa8f';
const String API_PRIVATE_KEY = '26b7cd6031456c03d9c9023f8aff8f883170adfd';

class Api {
  Future buscarComics({int offset = 0, String order = ''}) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyMMddkkmm').format(now);

    var response = await http.get(
      Uri.https('gateway.marvel.com', 'v1/public/comics', {
        "ts": formattedDate,
        "apikey": API_PUBLIC_KEY,
        "hash": md5.convert(utf8.encode(formattedDate + API_PRIVATE_KEY + API_PUBLIC_KEY)).toString(),
        "offset": offset.toString(),
        "orderBy": order
      }),
    );

    if (response.statusCode == 200) {
      var dados = json.decode(response.body)['data']['results'];
      List<DadosComic> comics = List<DadosComic>.from(dados.map((i) => DadosComic.fromJson(i)));
      return comics;
    } else if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
      throw json.decode(response.body);
    }
  }
}
