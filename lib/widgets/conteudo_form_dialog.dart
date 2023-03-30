import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/ponto.dart';

class ConteudoFormDialog extends StatefulWidget{
  final Ponto? pontoAtual;

  ConteudoFormDialog({Key? key, this.pontoAtual}) : super(key: key);

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
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (String? valor){
                  if(valor == null || valor.isEmpty){
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: diferenciaisController,
                decoration: InputDecoration(labelText: 'Diferencais'),
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
    void _mostraCalendario(){
      final dataFormatada = dataController.text;
      var data = DateTime.now();
      if (dataFormatada.isNotEmpty){
        data = _dateFormat.parse(dataFormatada);
      }
      showDatePicker(
          context: context,
          initialDate: data,
          firstDate: data.subtract(Duration(days: 365 * 5)),
          lastDate: data.add(Duration(days: 365 * 5)),
      ).then((DateTime? dataSelecionada){
        if (dataSelecionada != null){
          setState(() {
            dataController.text = _dateFormat.format(dataSelecionada);
          });
        }
      });
    }

    bool dadosValidados() => formKey.currentState!.validate() == true;
    
    Ponto get novoPonto => Ponto(
        id: widget.pontoAtual?.id ?? 0,
        descricao: descricaoController.text,
        diferenciais: diferenciaisController.text,
        data: _dateFormat.parse(dataController.text),
    );
}