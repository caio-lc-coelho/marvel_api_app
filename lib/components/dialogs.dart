import 'dart:convert';

import 'package:marvel_api_app/index.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

bool _isOpenDialog = false;

class Dialogs {
  static void close() {
    Navigator.of(App.context, rootNavigator: true).pop(); //Função que fecha o Dialog sem necessidade do context atual
  }

  static Future<Null> showErrorDialog(String message, {String title}) {
    if (_isOpenDialog) {
      close();
    }

    return showDialog<Null>(
      context: App.context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: title != null ? Text(title) : null,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message ?? 'Ocorreu um erro'),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Fechar'),
            onPressed: () {
              Dialogs.close();
            },
          ),
        ],
      ),
    );
  }

  static Future<Null> showDialogTema() {
    return showDialog<Null>(
      context: App.context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              dense: true,
              title: Text('Padrão do Sistema'),
              leading: Container(
                height: double.infinity,
                child: Icon(Icons.settings),
              ),
              onTap: () {
                App.tema.setTheme();
                Navigator.pop(context);
              },
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              dense: true,
              title: Text('Claro'),
              leading: Container(
                height: double.infinity,
                child: Icon(Icons.wb_sunny),
              ),
              onTap: () {
                App.tema.setTheme(temaEscuro: false);
                Navigator.pop(context);
              },
            ),
            Divider(
              thickness: 1,
            ),
            ListTile(
              dense: true,
              title: Text('Escuro'),
              leading: Icon(Icons.nights_stay),
              onTap: () {
                App.tema.setTheme(temaEscuro: true);
                Dialogs.close();
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showComicDialog(BuildContext context, DadosComic comic, State parent) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: comic.thumbnail,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              ListBody(
                children: <Widget>[
                  Text(
                    comic.title,
                    style: Theme.of(context).textTheme.headline6,
                    overflow: TextOverflow.visible,
                  ),
                  Text(
                    comic.pageCount.toString(),
                    style: Theme.of(context).textTheme.bodyText2,
                    overflow: TextOverflow.visible,
                  ),
                  Container(height: 5.0),
                  Text(
                    comic.modified,
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'id: ' + comic.id.toString(),
                    style: Theme.of(context).textTheme.overline,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Divider(thickness: 2),
              Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyText2,
                        text: comic.title,
                      ),
                      TextSpan(style: Theme.of(context).textTheme.caption, text: '\n\n' + comic.description),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(App.comicsCarrinho.contains(comic) ? 'Remover do carrinho' : 'Adicionar ao carrinho'),
              onPressed: () {
                if (App.comicsCarrinho.contains(comic)) {
                  App.comicsCarrinho.remove(comic);
                  App.cache.setString('comicsCarrinho', json.encode(App.comicsCarrinho));
                } else {
                  App.comicsCarrinho.add(comic);
                  App.cache.setString('comicsCarrinho', json.encode(App.comicsCarrinho));
                }
                Dialogs.close();
                parent.setState(() {}); //Chamada para recarregar widget pai
              }),
          FlatButton(
            child: Text('Fechar'),
            onPressed: () => Dialogs.close(),
          ),
        ],
      ),
    );
  }
}
