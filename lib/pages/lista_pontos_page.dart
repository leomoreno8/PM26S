// ignore_for_file: constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:turistico/pages/filtro_page.dart';
import '../model/ponto.dart';
import '../widgets/conteudo_form_dialog.dart';

class ListaPontosPage extends StatefulWidget{
  const ListaPontosPage({super.key});


  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';

  final pontos = <Ponto>[

  ];
   int _ultimoId = 0;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirForm,
        tooltip: 'Novo Ponto',
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _criarAppBar() {
    return AppBar(
      title: const Text('Gerenciador de Pontos Turísticos'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro,
            icon: const Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody(){
    if(pontos.isEmpty){
      return const Center(
        child: Text('Nenhuma ponto turístico cadastrado',
       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index){
          final ponto = pontos[index];
          return PopupMenuButton<String>(
            child: ListTile(
              title: Text('${ponto.id} - ${ponto.descricao}'),
              subtitle: Text('${ponto.diferenciais}'),
              trailing: Text('Data - ${ponto.dataFormatada}')
            ),
              itemBuilder: (BuildContext context) => criarItensMenuPopup(),
            onSelected: (String valorSelecionado){
              if (valorSelecionado == ACAO_EDITAR){
                _abrirForm(pontoAtual: ponto, indice: index);
              } else {
                _excluir(index);
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: pontos.length,
    );
  }

  void _abrirPaginaFiltro(){
    final navigator = Navigator.of(context);
    navigator.pushNamed(FiltroPage.routeName).then((alterouValores) {
      if(alterouValores == true){
        ////
      }
    });
  }

  List<PopupMenuEntry<String>> criarItensMenuPopup(){
    return[
      PopupMenuItem<String>(
        value: ACAO_EDITAR,
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                child: Text('Editar'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_EXCLUIR,
          child: Row(
            children: const [
              Icon(Icons.delete, color: Colors.red),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Excluir'),
              )
            ],
          )
      )
    ];
  }

  void _abrirForm({Ponto? pontoAtual, int? indice}){
    final key = GlobalKey<ConteudoFormDialogState>();
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(pontoAtual == null ? 'Novo Ponto Turístico' : ' Alterar o ponto turístico ${pontoAtual.id}'),
            content: ConteudoFormDialog(key: key, pontoAtual: pontoAtual),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  if (key.currentState != null && key.currentState!.dadosValidados()){
                    setState(() {
                      final novoPonto = key.currentState!.novoPonto;
                      if (indice == null){
                        novoPonto.id = ++ _ultimoId;
                        pontos.add(novoPonto);
                      } else {
                        pontos[indice] = novoPonto;
                      }
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Salvar'),
              )
            ],
          );
        }
    );
  }

  void _excluir(int indice){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.red,),
                Padding(
                    padding: EdgeInsets.only(left: 10),
                  child: Text('ATENÇÃO'),
                ),
              ],
            ),
            content: const Text('Esse registro será deletado definitivamente'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar')
              ),
              TextButton(
                  onPressed: () {
                     Navigator.of(context).pop();
                     setState(() {
                       pontos.removeAt(indice);
                     });
                     },
                  child: const Text('OK')
              )
            ],
          );
        }
    );

  }
}