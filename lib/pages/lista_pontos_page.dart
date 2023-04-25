// ignore_for_file: constant_identifier_names, use_key_in_widget_constructors, library_private_types_in_public_api, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:turistico/pages/filtro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/ponto_dao.dart';
import '../model/ponto.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'datalhes_ponto_page.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_VISUALIZAR = 'visualizar';

  final _pontos = <Ponto>[];
  final _dao = PontoDao();
   var _carregando = false;

   @override
   void initState(){
     super.initState();
     _atualizarLista();
   }

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
      title: const Text('Gerenciador de Pontos Turísiticos'),
      actions: [
        IconButton(
            onPressed: _abrirPaginaFiltro,
            icon: const Icon(Icons.filter_list)),
      ],
    );
  }

  Widget _criarBody(){
     if(_carregando){
       return Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Align(
             alignment: AlignmentDirectional.center,
             child: CircularProgressIndicator(),
           ),
           Align(
             alignment: AlignmentDirectional.center,
             child: Padding(
               padding: const EdgeInsets.only(top: 10),
               child: Text('Carregando seus Pontos',
               style: TextStyle(
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
                 color: Theme.of(context).primaryColor,
               ),
               ),
             ),
           )
         ],
       );
     }
    if(_pontos.isEmpty){
      return const Center(
        child: Text('Nenhuma ponto cadastrado',
       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index){
          final ponto = _pontos[index];
          return PopupMenuButton<String>(
            child: ListTile(
              title: Text('${ponto.id} - ${ponto.nome}'),
              subtitle: Text('${ponto.descricao} - ${ponto.diferenciais}'),
              trailing: Text('Data - ${ponto.dataFormatada}')
            ),
              itemBuilder: (BuildContext context) => criarItensMenuPopup(),
            onSelected: (String valorSelecionado){
              if (valorSelecionado == ACAO_EDITAR){
                _abrirForm(ponto: ponto);
              }else if (valorSelecionado == ACAO_VISUALIZAR){
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DetalhesPontoPage(ponto: ponto),
                ));
              }
              else{
                _excluir(ponto);
              }
            },
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: _pontos.length,
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
              Icon(Icons.edit, color: Colors.black),
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
      ),
      PopupMenuItem<String>(
          value: ACAO_VISUALIZAR,
          child: Row(
            children: const [
              Icon(Icons.info, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Visualizar'),
              )
            ],
          )
      )
    ];
  }
  void _atualizarLista() async {
     setState(() {
       _carregando = true;
     });

    final prefs = await SharedPreferences.getInstance();
    final campoOrdenacao =
        prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? Ponto.campoId;
    final usarOrdemDecrescente =
        prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
    final filtroDescricao =
        prefs.getString(FiltroPage.chaveFiltroDescricao) ?? '';
    final pontos = await _dao.listar(
      filtro: filtroDescricao,
      campoOrdenacao: campoOrdenacao,
      usarOrdemDecrescente: usarOrdemDecrescente,
    );
    setState(() {
      _pontos.clear();
      if (pontos.isNotEmpty) {
        _pontos.addAll(pontos);
      }
    });
    setState(() {
      _carregando = false;
    });
  }

  void _abrirForm({Ponto? ponto}) {
    final key = GlobalKey<ConteudoDialogFormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          ponto == null ? 'Novo Ponto' : 'Alterar Ponto ${ponto.id}',
        ),
        content: ConteudoDialogForm(
          key: key,
          ponto: ponto,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () {
              if (key.currentState?.dadosValidos() != true) {
                return;
              }
              Navigator.of(context).pop();
              final novoPonto = key.currentState!.novoPonto;
              _dao.salvar(novoPonto).then((success) {
                if (success) {
                  _atualizarLista();
                }
              });
              _atualizarLista();
            },
          ),
        ],
      ),
    );
  }

  void _excluir(Ponto ponto){
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
                     if(ponto.id == null){
                       return;
                     }
                     _dao.remover(ponto.id!).then((sucess) {
                       if (sucess)
                         _atualizarLista();
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