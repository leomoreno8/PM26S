// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ponto.dart';

class ConteudoFormDialogView extends StatefulWidget{
  final Ponto? pontoAtual;

  const ConteudoFormDialogView({Key? key, this.pontoAtual}) : super(key: key);

  @override
  ConteudoFormDialogViewState createState() => ConteudoFormDialogViewState();
}

class ConteudoFormDialogViewState extends State<ConteudoFormDialogView>{
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    final diferenciaisController = TextEditingController();
    final dataController = TextEditingController();
    final _dateFormat = DateFormat('dd/MM/yyy');

    @override
    void initState(){
      super.initState();
      if ( widget.pontoAtual != null){
        nomeController.text = widget.pontoAtual!.nome;
        descricaoController.text = widget.pontoAtual!.descricao;
        diferenciaisController.text = widget.pontoAtual!.diferenciais!;
        dataController.text = widget.pontoAtual!.dataFormatada;
      }
    }

    Widget build(BuildContext context){
      var data = DateTime.now();
      dataController.text = _dateFormat.format(data);
      return Form(
        key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                enabled: false,
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                enabled: false,
                controller: descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                enabled: false,
                controller: diferenciaisController,
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

    bool dadosValidados() => formKey.currentState!.validate() == true;
    
    Ponto get novoPonto => Ponto(
        id: widget.pontoAtual?.id ?? 0,
        nome: nomeController.text,
        descricao: descricaoController.text,
        diferenciais: diferenciaisController.text,
        data: _dateFormat.parse(dataController.text),
    );
}