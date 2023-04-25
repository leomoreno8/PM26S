// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../model/ponto.dart';

class DetalhesPontoPage extends StatefulWidget {
  final Ponto ponto;

  const DetalhesPontoPage({Key? key, required this.ponto}) : super(key: key);

  @override
  _DetalhesPontoPageState createState() => _DetalhesPontoPageState();
}

class _DetalhesPontoPageState extends State<DetalhesPontoPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Ponto'),
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
              const Campo(descricao:'Código: '),
              Valor(valor: '${widget.ponto.id}'),
            ],
          ),
          Row(
            children: [
              const Campo(descricao:'Nome: '),
              Valor(valor: widget.ponto.nome),
            ],
          ),
          Row(
            children: [
              const Campo(descricao:'Descrição: '),
              Valor(valor: widget.ponto.descricao),
            ],
          ),
          Row(
            children: [
              const Campo(descricao:'Diferenciais: '),
              Valor(valor: widget.ponto.diferenciais),
            ],
          ),
          Row(
            children: [
              const Campo(descricao:'Data: '),
              Valor(valor: '${widget.ponto.data}'),
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