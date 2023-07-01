// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../model/ponto.dart';

class DistanciaPage extends StatefulWidget {
  final double distance;
  // final double distance;

  const DistanciaPage({Key? key, required this.distance}) : super(key: key);
  @override
  _DistanciaPageState createState() => _DistanciaPageState();
}

class _DistanciaPageState extends State<DistanciaPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distância do Ponto'),
      ) ,
      body: _criaBody() ,
    );
  }

  Widget _criaBody(){
    return Padding(
        padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          Row(
            children: [
              const Campo(descricao:'Distância: '),
              Valor(valor: widget.distance.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class Campo extends StatelessWidget{
  final String descricao;

  const Campo({Key? key,required this.descricao}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return Expanded(
      flex: 1,
        child: Text(descricao,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        ),
    );
  }
}

class Valor extends StatelessWidget{
  final String valor;

  const Valor({Key? key,required this.valor}) : super(key: key);

  @override
  Widget build (BuildContext context){
    return Expanded(
      flex: 3,
      child: Text(valor),
    );
  }
}