import 'package:intl/intl.dart';

class Ponto {
  static const nomeTabela = 'ponto';
  static const campoId = '_id';
  static const campoNome = 'nome';
  static const campoDescricao = 'descricao';
  static const campoDiferenciais = 'diferenciais';
  static const campoData = 'data';

  int? id;
  String nome;
  String descricao;
  String diferenciais;
  DateTime data;

  Ponto({
    this.id,
    required this.nome,
    required this.descricao,
    required this.diferenciais,
    required this.data
  });

  String get dataFormatada {
    return DateFormat('yyyy-MM-dd').format(data);
  }

  Map<String, dynamic> toMap() => {
    campoId: id,
    campoNome: nome,
    campoDescricao: descricao,
    campoDiferenciais: diferenciais,
    campoData: DateFormat("yyyy-MM-dd").format(data),
  };

  factory Ponto.fromMap(Map<String, dynamic> map) => Ponto(
    id: map[campoId] is int ? map[campoId] : null,
    nome: map[campoNome] is String ? map[campoNome] : '',
    descricao: map[campoDescricao] is String ? map[campoDescricao] : '',
    diferenciais: map[campoDiferenciais] is String ? map[campoDiferenciais] : '',
    data: DateFormat("yyyy-MM-dd").parse(map[campoData])
  );
}