// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../model/ponto.dart';

class ConteudoDialogForm extends StatefulWidget {
  final Ponto? ponto;

  ConteudoDialogForm({Key? key, this.ponto}) : super(key: key);

  void init() {}

  @override
  State<StatefulWidget> createState() => ConteudoDialogFormState();
}

class ConteudoDialogFormState extends State<ConteudoDialogForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _diferenciaisController = TextEditingController();
  final _dataController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  StreamSubscription<Position>? _subscription;
  Position? _ultimaPosicaoConhecida = null;
  double _distanciapercorrida = 0;
  final _linhas = <String>[];

  bool get _monitorandoLocalizacao => _subscription != null;

  @override
  void initState() {
    super.initState();
    _obterAtualizacaoAtual();
    if (widget.ponto != null) {
      _nomeController.text = widget.ponto!.nome;
      _descricaoController.text = widget.ponto!.descricao;
      _diferenciaisController.text = widget.ponto!.diferenciais;
      _dataController.text = widget.ponto!.dataFormatada;
      _longitudeController.text = widget.ponto!.longitude!;
      _latitudeController.text = widget.ponto!.latitude!;
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = DateTime.now();
    // _obterAtualizacaoAtual();
    print(data);
    String coordenadas = _linhas[0];
    String latitude = coordenadas.split("|")[0].substring(10);
    String longitude = coordenadas.split("|")[1].substring(12);

      _dataController.text = _dateFormat.format(data);
      _longitudeController.text = longitude;
      _latitudeController.text = latitude;
      return Form(
        key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _diferenciaisController,
                decoration: const InputDecoration(labelText: 'Diferencais'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe os diferenciais';
                  }
                  return null;
                },
              ),
            ],
          )
      );
  }

  bool dadosValidos() => _formKey.currentState?.validate() == true;

  Ponto get novoPonto => Ponto(
    id: widget.ponto?.id,
    nome: _nomeController.text,
    descricao: _descricaoController.text,
    diferenciais: _diferenciaisController.text,
    data: _dateFormat.parse(_dataController.text),
    longitude: _longitudeController.text,
    latitude: _latitudeController.text,
  );

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
    print(_linhas);
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

}
