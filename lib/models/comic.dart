import 'dart:convert';
import 'package:intl/intl.dart';

class DadosComic {
  int id;
  String title;
  int pageCount;
  double price;
  String thumbnailPath;
  String thumbnailExtension;
  String thumbnail;
  String rawModified;
  String modified;
  String description;
  String jsonCache;

  DadosComic({
    this.id,
    this.title,
    this.pageCount,
    this.price,
    this.thumbnailPath,
    this.thumbnailExtension,
    this.thumbnail,
    this.rawModified,
    this.modified,
    this.description,
    this.jsonCache,
  });

  factory DadosComic.from(DadosComic comic) {
    return DadosComic(
      id: comic.id,
      title: comic.title,
      pageCount: comic.pageCount,
      price: comic.price,
      thumbnailPath: comic.thumbnailPath,
      thumbnailExtension: comic.thumbnailExtension,
      thumbnail: comic.thumbnail,
      rawModified: comic.rawModified,
      modified: comic.modified,
      description: comic.description,
      jsonCache: comic.jsonCache,
    );
  }

  factory DadosComic.fromJson(Map<String, dynamic> response) {
    return DadosComic(
      id: response["id"],
      title: response['title'],
      pageCount: response['pageCount'],
      price: response['prices'][0]['price'] is int
          ? response['prices'][0]['price'].toDouble()
          : response['prices'][0]['price'],
      thumbnailPath: response['thumbnail']['path'],
      thumbnailExtension: response['thumbnail']['extension'],
      thumbnail: response['thumbnail']['path'] + '/portrait_xlarge.' + response['thumbnail']['extension'],
      rawModified: response['modified'],
      modified: DateFormat('dd/MM/yyyy H:mm ')
          .format(DateTime.parse(response['modified'])), //ALgumas datas vem da api com o ano 0001
      description: response['description'] ?? 'Nenhuma descrição informada pela API.',
      jsonCache: json.encode(response),
    );
  }

  Map toJson() => {
        'id': id,
        'title': title,
        'pageCount': pageCount,
        'prices': json.decode(jsonCache)['prices'],
        'thumbnail': json.decode(jsonCache)['thumbnail'],
        'modified': rawModified,
        'description': description,
      };
}
