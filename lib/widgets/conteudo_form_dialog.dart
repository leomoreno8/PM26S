// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.ponto != null) {
      _nomeController.text = widget.ponto!.nome;
      _descricaoController.text = widget.ponto!.descricao;
      _diferenciaisController.text = widget.ponto!.diferenciais;
      _dataController.text = widget.ponto!.dataFormatada;
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = DateTime.now();
      _dataController.text = _dateFormat.format(data);
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
  );
}
