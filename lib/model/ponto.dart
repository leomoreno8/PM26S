// ignore_for_file: constant_identifier_names

import 'package:intl/intl.dart';

class Ponto {
  static const CAMPO_ID = 'id';
  static const CAMPO_NOME = 'nome';
  static const CAMPO_DESCRICAO = 'descricao';
  static const CAMPO_DIFERENCIAIS = 'diferenciais';
  static const CAMPO_DATA = 'data';
  static const NOME_TABLE = 'pontos';

  int id;
  String nome;
  String descricao;
  String? diferenciais;
  DateTime data;

  Ponto({required this.id, required this.nome, required this.descricao, this.diferenciais, required this.data});

  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
    CAMPO_ID: id,
    CAMPO_NOME: nome,
    CAMPO_DESCRICAO: descricao,
    CAMPO_DIFERENCIAIS: diferenciais,
    CAMPO_DATA: DateFormat("dd/MM/yyyy").format(data),
  };

  factory Ponto.fromMap(Map<String, dynamic> map) => Ponto(
    id: map[CAMPO_ID] is int ? map[CAMPO_ID] : null,
    nome: map[CAMPO_NOME] is String ?  map[CAMPO_NOME] : '',
    descricao: map[CAMPO_DESCRICAO] is String ?  map[CAMPO_DESCRICAO] : '',
    diferenciais: map[CAMPO_DIFERENCIAIS] is String ?  map[CAMPO_DIFERENCIAIS] : '',
    data: DateFormat("dd/MM/yyyy").parse(map[CAMPO_DATA]),
  );
}