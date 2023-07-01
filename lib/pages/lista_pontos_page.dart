// ignore_for_file: constant_identifier_names, use_key_in_widget_constructors, library_private_types_in_public_api, curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:turistico/pages/distancia_page.dart';
import 'package:turistico/pages/filtro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/ponto_dao.dart';
import '../model/ponto.dart';
import '../widgets/conteudo_form_dialog.dart';
import 'datalhes_ponto_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:turistico/pages/mapas_page.dart';

class ListaPontosPage extends StatefulWidget{

  @override
  _ListaPontosPageState createState() => _ListaPontosPageState();
}

class _ListaPontosPageState extends State<ListaPontosPage>{

  static const ACAO_EDITAR = 'editar';
  static const ACAO_EXCLUIR = 'excluir';
  static const ACAO_MAPA_EXTERNO = 'mapa1';
  static const ACAO_MAPA_INTERNO = 'mapa2';
  static const ACAO_VISUALIZAR = 'visualizar';
  static const ACAO_CALCULAR_DISTANCIA = 'calcular';
  
  final _linhas = <String>[];
  final _pontos = <Ponto>[];
  final _dao = PontoDao();
  var _carregando = false;
  StreamSubscription<Position>? _subscription;
  Position? _ultimaPosicaoConhecida = null;
  double _distanciapercorrida = 0;
  Position? _localizacaoAtual;
  bool get _monitorandoLocalizacao => _subscription != null;
  String get _textoLocalizacao => _localizacaoAtual == null ? '' :
   'Latitude:  ${_localizacaoAtual!.latitude}  |  Logetude:  ${_localizacaoAtual!.longitude}';

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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _abrirForm,
            tooltip: 'Novo Ponto',
            child: const Icon(Icons.add),
          ),
          SizedBox(width: 16), // Espaçamento entre os botões
          FloatingActionButton(
            onPressed: _obterAtualizacaoAtual,
            tooltip: 'Retornar a ultima Localização Conhecida',
            child: const Icon(Icons.person),
          ),
          SizedBox(width: 16), // Espaçamento entre os botões
          FloatingActionButton(
            onPressed: _monitorandoLocalizacao ? _pararMonitoramento : _monitorar,
            tooltip: 'Retornar a ultima Localização Conhecida',
            child: const Icon(Icons.person),
          ),
        ],
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
        itemBuilder: (BuildContext context, int index) {
          final ponto = _pontos[index];
          return PopupMenuButton<String>(
            child: ListTile(
              title: Text('${ponto.id} - ${ponto.nome}'),
              subtitle: Text('${ponto.descricao} - ${ponto.diferenciais} - long: ${ponto.longitude} - lat: ${ponto.latitude}'),
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
              } else if (valorSelecionado == ACAO_MAPA_EXTERNO) {
                _abrirMapaExterno(ponto.longitude, ponto.latitude);
              } else if (valorSelecionado == ACAO_MAPA_INTERNO) {
                _abrirMapaInterno(ponto.longitude, ponto.latitude);
              } else if (valorSelecionado == ACAO_CALCULAR_DISTANCIA) {
                _abrirCalcularDistancia(ponto.longitude, ponto.latitude);
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
      ),
      PopupMenuItem<String>(
          value: ACAO_MAPA_EXTERNO,
          child: Row(
            children: const [
              Icon(Icons.map, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Mapa externo'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_MAPA_INTERNO,
          child: Row(
            children: const [
              Icon(Icons.map_outlined, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Mapa interno'),
              )
            ],
          )
      ),
      PopupMenuItem<String>(
          value: ACAO_CALCULAR_DISTANCIA,
          child: Row(
            children: const [
              Icon(Icons.social_distance, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Calcular Distância'),
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

  void _limparLog(){
    setState(() {
      _linhas.clear();
    });
  }

  void _ultimaLocalizacaoConhecida() async {
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    Position? position = await Geolocator.getLastKnownPosition();

      setState(() {
      if(position == null){
        _linhas.add('Nenhuma localização registrada');
      }else{
      _linhas.add('Latitude: ${position.latitude} | Longitude: ${position.longitude}');
      }
      });
  }

  void _obterAtualizacaoAtual() async{
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _linhas.add('Latitude: ${position.latitude} | Longitude: ${position.longitude}');
    });
  }

  void _obterLocalizacaoAtual() async{
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {

    });
  }

void _monitorar(){
  final LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high,
      distanceFilter: 100);
  _subscription = Geolocator.getPositionStream(
    locationSettings: locationSettings).listen((Position position) {
      setState(() {
        _linhas.add('Latitude: ${position.latitude} | Longitude: ${position.longitude}');
      });
      if(_ultimaPosicaoConhecida != null){
        final distancia = Geolocator.distanceBetween(
            _ultimaPosicaoConhecida!.latitude, _ultimaPosicaoConhecida!.longitude,
            position.latitude, position.longitude);
        _distanciapercorrida += distancia;
        _linhas.add('Distancia total percorrida: ${_distanciapercorrida.toInt()}M');
      }
      _ultimaPosicaoConhecida = position;
    });
  }

  void _pararMonitoramento(){
    _subscription!.cancel();
    setState(() {
      _subscription = null;
      _ultimaPosicaoConhecida = null;
      _distanciapercorrida = 0;
    });
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recurso '
                        'por falta de permissão');
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá acessar '
        'as configurações do app para permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado){
      await _mostrarDialogMensagem('Para utilizar esse recurso, você deverá habilitar o serviço'
                                  ' de localização');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Atenção'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK')
            )
          ],
        ),
    );
  }

  void _abrirMapaExterno(long, lat){
    var longitude = double.parse(long);
    var latitude = double.parse(lat);
    MapsLauncher.launchCoordinates(latitude, longitude);
  }

  void _abrirMapaInterno(long, lat){
    var longitude = double.parse(long);
    var latitude = double.parse(lat);

    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => MapasPage(
            latitude: latitude,
            longetude: longitude,
        ),
      ),
    );
  }

  Future<void> _abrirCalcularDistancia(long, lat) async {
    stderr.writeln('print me');

    Position position = await Geolocator.getCurrentPosition();
    var longitudeAtual = position.longitude;
    var latitudeAtual = position.latitude;
    var longitude = double.parse(long);
    var latitude = double.parse(lat);

    const double earthRadius = 6371; // Raio médio da Terra em quilômetros

    // Converter as coordenadas de latitude/longitude para radianos
    double dLat = _degreesToRadians(latitude - latitudeAtual);
    double dLon = _degreesToRadians(longitude - longitudeAtual);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(latitude)) *
            cos(_degreesToRadians(latitudeAtual)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Calcular a distância em quilômetros
    double distance = earthRadius * c;

    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DistanciaPage(distance: distance),
    ));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

}