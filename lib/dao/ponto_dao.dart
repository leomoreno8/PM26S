import 'package:turistico/database/database_provider.dart';
import 'package:turistico/model/ponto.dart';
import 'package:sqflite/sqflite.dart';

class PontoDao{
  final dbProvider = DatabaseProvider.instance;

  Future<bool> salvar(Ponto ponto) async {
    final database = await dbProvider.database;
    final valores = ponto.toMap();
    if (ponto.id == null) {
      ponto.id = await database.insert(Ponto.NOME_TABLE, valores);
      return true;
    } else {
      final registrosAtualizados = await database.update(
        Ponto.NOME_TABLE,
        valores,
        where: '${Ponto.CAMPO_ID} = ?',
        whereArgs: [ponto.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await dbProvider.database;
    final registrosAtualizados = await database.delete(
      Ponto.NOME_TABLE,
      where: '${Ponto.CAMPO_ID} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<Ponto>> listar(
  {String filtro = '',
  String campoOrdenacao = Ponto.CAMPO_ID,
    bool usarOrdemDecrescente = false
  }) async {
    String? where;
    if(filtro.isNotEmpty){
      where = "UPPER(${Ponto.CAMPO_DESCRICAO}) LIKE '${filtro.toUpperCase()}%'";
    }
    var orderBy = campoOrdenacao;

    if(usarOrdemDecrescente){
      orderBy += ' DESC';
    }
    final database = await dbProvider.database;
    final resultado = await database.query(Ponto.NOME_TABLE,
      columns: [Ponto.CAMPO_ID, Ponto.CAMPO_NOME, Ponto.CAMPO_DESCRICAO, Ponto.CAMPO_DIFERENCIAIS],
    where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => Ponto.fromMap(m)).toList();
  }

}