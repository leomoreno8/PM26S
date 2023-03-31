// ignore_for_file: annotate_overrides

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ponto.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Ponto? pontoAtual;

  const ConteudoFormDialog({Key? key, this.pontoAtual}) : super(key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}

class ConteudoFormDialogState extends State<ConteudoFormDialog>{
    final formKey = GlobalKey<FormState>();
    final descricaoController = TextEditingController();
    final diferenciaisController = TextEditingController();
    final dataController = TextEditingController();
    final _dateFormat = DateFormat('dd/MM/yyy');

    @override
    void initState(){
      super.initState();
      if ( widget.pontoAtual != null){
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
        descricao: descricaoController.text,
        diferenciais: diferenciaisController.text,
        data: _dateFormat.parse(dataController.text),
    );
}