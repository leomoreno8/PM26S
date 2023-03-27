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
    final prazoController = TextEditingController();
    final _dateFormat = DateFormat('dd/MM/yyy');

    @override
    void initState(){
      super.initState();
      if ( widget.pontoAtual != null){
        descricaoController.text = widget.pontoAtual!.descricao;
        prazoController.text = widget.pontoAtual!.prazoFormatado;
      }
    }

    Widget build(BuildContext context){
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
                controller: prazoController,
                decoration: InputDecoration(labelText: 'Prazo',
                prefixIcon: IconButton(
                    onPressed: _mostraCalendario,
                    icon: Icon(Icons.calendar_today),
                ),
                  suffixIcon: IconButton(
                      onPressed: () => prazoController.clear(),
                      icon: Icon(Icons.close),
                  ),
                ),
                readOnly: true,
              )
            ],
          )
      );
    }
    void _mostraCalendario(){
      final dataFormatada = prazoController.text;
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
            prazoController.text = _dateFormat.format(dataSelecionada);
          });
        }
      });
    }

    bool dadosValidados() => formKey.currentState!.validate() == true;

    Ponto get novoPonto => Ponto(
        id: widget.pontoAtual?.id ?? 0,
        descricao: descricaoController.text,
      prazo: prazoController.text.isEmpty ? null : _dateFormat.parse(prazoController.text),
    );
}