import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:marvel_api_app/index.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Lista extends StatefulWidget {
  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State<Lista> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String dropdownTema = 'Sistema'; //Por padrão, o tema seguirá o estabelecido nas configurações do sistema
  String orderComics = '';

  int _offset = 0;

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('MARVEL'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                orderComics = value;
                App.comics = [];
              });
              buscarDados();
            },
            itemBuilder: (BuildContext context) {
              //Seleciona o filtro e salva na variável enviada para a chamada da API
              return [
                PopupMenuItem(
                  child: Text('Data'),
                  value: 'modified', //Algumas datas retornam com o ano 0001 na api da MARVEL
                ),
                PopupMenuItem(
                  child: Text('Título'),
                  value: 'title',
                ),
              ];
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Container(),
                    decoration: BoxDecoration(
                      color: Color(0xFFED1922),
                      image: DecorationImage(
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text('Mudar Tema do sistema'),
                    subtitle: Text('Tema atual: ${App.cache.getString('temaAtual')}'),
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.settings_brightness),
                    ),
                    onTap: () async {
                      await Dialogs.showDialogTema();
                      setState(() {}); //Recarrega a tela para aplicar o novo tema
                    },
                  ),
                  ListTile(
                    dense: true,
                    title: App.cache.getString('comicsCarrinho') != ''
                        ? Text('Carrinho de Compras:')
                        : Text('Carrinho de Compras vazio'),
                    subtitle:
                        App.cache.getString('comicsCarrinho') != '' ? Text('Toque para finalizar a compra') : null,
                    leading: Container(
                      height: double.infinity,
                      child: Icon(Icons.shopping_cart),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      final snackBar = SnackBar(content: Text('Aqui viria a tela de pagamento, se fosse um app real'));
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    },
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: ListView.builder(
                      itemCount: App.comicsCarrinho.length,
                      itemBuilder: (BuildContext context, index) {
                        DadosComic carregado = App.comicsCarrinho[index]; //Dados caregados pela API

                        return Dismissible(
                          background: Container(
                            color: Color(0xFFED1922),
                          ),
                          direction: DismissDirection.endToStart,
                          key: Key(carregado.id.toString()),
                          onDismissed: (direction) {
                            App.comicsCarrinho.remove(carregado);
                            App.cache.setString('comicsCarrinho', json.encode(App.comicsCarrinho));
                          },
                          child: ListTile(
                            isThreeLine: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 10.0,
                            ),
                            leading: CachedNetworkImage(
                              imageUrl: carregado.thumbnail,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  CircularProgressIndicator(value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                            title: Text(
                              carregado.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            subtitle: Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      carregado.price == 0 ? 'Preço não informado' : '\$' + carregado.price.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  Text(
                                    carregado.modified,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (App.cache.getString('comicsCarrinho') != '')
                    ListTile(
                      dense: true,
                      title: Text('Limpar Carrinho'),
                      leading: Container(
                        height: double.infinity,
                        child: Icon(Icons.remove_shopping_cart),
                      ),
                      onTap: () {
                        setState(() {
                          App.comicsCarrinho = [];
                          App.cache.setString('comicsCarrinho', '');
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          App.comics = [];
          App.comics = await App.api.buscarComics();
        },
        child: ListView.separated(
          controller: scrollController,
          itemCount: App.comics.length + 1, //Evita repetição do Widget CircularProgressIndicator
          separatorBuilder: (context, index) {
            return Divider(
              height: 1,
              thickness: 1,
            );
          },
          itemBuilder: (context, index) {
            if (index == App.comics.length - 5) {
              buscarDados(offset: _offset += 20);
            }

            if (index == App.comics.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            DadosComic carregado = App.comics[index]; //Dados caregados pela API

            return Container(
              child: ListTile(
                isThreeLine: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 10.0,
                ),
                leading: CachedNetworkImage(
                  imageUrl: carregado.thumbnail,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(
                  carregado.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          carregado.price == 0 ? 'Preço não informado' : '\$' + carregado.price.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ),
                      Text(
                        carregado.modified,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
                onTap: () async => Dialogs.showComicDialog(context, carregado,
                    this), //O state do widget pai é passado ao widget filho para que o mesmo possa recarregar o state do pai quando for selecionada a opção de marcar como lido/não lido
              ),
            );
          },
        ),
      ),
    );
  }

  void buscarDados({int offset = 0}) async {
    try {
      List<DadosComic> retorno = await App.api.buscarComics(offset: offset, order: orderComics);
      if (offset > 0) {
        App.comics.addAll(retorno);
      } else {
        App.comics = retorno;
      }
      setState(() {});
    } catch (e) {
      Dialogs.showErrorDialog(e.toString());
    }
  }
}
