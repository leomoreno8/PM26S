// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ponto.dart';

class FiltroPage extends StatefulWidget {
  static const routeName = '/filtro';
  static const chaveCampoOrdenacao = 'campoOrdenacao';
  static const chaveUsarOrdemDecrescente = 'usarOrdemDecrescente';
  static const chaveFiltroDescricao = 'filtroDescricao';

  const FiltroPage({super.key});

  @override
  _FiltroPageState createState() => _FiltroPageState();
}

class _FiltroPageState extends State<FiltroPage> {
  final _camposParaOrdenacao = {
    Ponto.CAMPO_ID: 'Código',
    Ponto.CAMPO_DESCRICAO: 'Descrição',
    Ponto.CAMPO_DIFERENCIAIS: 'Diferencias',
    Ponto.CAMPO_DATA: 'Data'
  };
  late final SharedPreferences _prefs;
  final _descricaoController = TextEditingController();
  String _campoOrdenacao = Ponto.CAMPO_ID;
  bool _usarOrdemDecrescente = false;
  bool _alterouValores = false;

  @override
  void initState() {
    super.initState();
    _carregarSharedPreferences();
  }

  void _carregarSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _campoOrdenacao =
          _prefs.getString(FiltroPage.chaveCampoOrdenacao) ?? Ponto.CAMPO_ID;
      _usarOrdemDecrescente =
          _prefs.getBool(FiltroPage.chaveUsarOrdemDecrescente) == true;
      _descricaoController.text =
          _prefs.getString(FiltroPage.chaveFiltroDescricao) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onVoltarClick,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filtro e Ordenação'),
        ),
        body: _criarBody(),
      ),
    );
  }

  Widget _criarBody() => ListView(
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
        child: Text('Campo para ordenação'),
      ),
      for (final campo in _camposParaOrdenacao.keys)
        Row(
          children: [
            Radio(
              value: campo,
              groupValue: _campoOrdenacao,
              onChanged: _onCampoOrdenacaoChanged,
            ),
            Text(_camposParaOrdenacao[campo]!),
          ],
        ),
      const Divider(),
      Row(
        children: [
          Checkbox(
            value: _usarOrdemDecrescente,
            onChanged: _onUsarOrdemDecrescenteChanged,
          ),
          const Text('Usar ordem decrescente'),
        ],
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Descrição começa com',
          ),
          controller: _descricaoController,
          onChanged: _onFiltroDescricaoChanged,
        ),
      ),
    ],
  );

  void _onCampoOrdenacaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveCampoOrdenacao, valor!);
    _alterouValores = true;
    setState(() {
      _campoOrdenacao = valor;
    });
  }

  void _onUsarOrdemDecrescenteChanged(bool? valor) {
    _prefs.setBool(FiltroPage.chaveUsarOrdemDecrescente, valor!);
    _alterouValores = true;
    setState(() {
      _usarOrdemDecrescente = valor;
    });
  }

  void _onFiltroDescricaoChanged(String? valor) {
    _prefs.setString(FiltroPage.chaveFiltroDescricao, valor ?? '');
    _alterouValores = true;
  }

  Future<bool> _onVoltarClick() async {
    Navigator.of(context).pop(_alterouValores);
    return true;
  }
}