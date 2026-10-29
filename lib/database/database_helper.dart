import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tarefa.dart';

// Classe que cuida de TUDO que envolve o banco de dados.
// A tela nunca mexe no SQL direto: ela só chama os métodos daqui.
class DatabaseHelper {
  // "Singleton": existe uma única instância dessa classe no app inteiro.
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  // Devolve o banco. Se ainda não foi aberto, abre agora (só uma vez).
  Future<Database> get database async {
    _database ??= await _abrirBanco();
    return _database!;
  }

  Future<Database> _abrirBanco() async {
    final pasta = await getDatabasesPath();
    final caminho = join(pasta, 'tarefas.db');

    return openDatabase(
      caminho,
      version: 1,
      // onCreate roda só na PRIMEIRA vez que o app abre.
      // REQUISITO 1: criação da tabela tarefas (id, titulo, concluida).
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            concluida INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // REQUISITO 2 (CREATE): insere uma nova tarefa.
  Future<int> inserirTarefa(Tarefa tarefa) async {
    final db = await database;
    return db.insert('tarefas', tarefa.toMap());
  }

  // REQUISITO 3 (READ): busca todas as tarefas.
  // Pendentes aparecem primeiro; dentro de cada grupo, as mais novas no topo.
  Future<List<Tarefa>> listarTarefas() async {
    final db = await database;
    final linhas = await db.query(
      'tarefas',
      orderBy: 'concluida ASC, id DESC',
    );
    return linhas.map((linha) => Tarefa.fromMap(linha)).toList();
  }

  // REQUISITO 4 (UPDATE): salva a tarefa alterada (ex.: marcada como concluída).
  Future<int> atualizarTarefa(Tarefa tarefa) async {
    final db = await database;
    return db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  // REQUISITO 4 (DELETE): apaga a tarefa pelo id.
  Future<int> excluirTarefa(int id) async {
    final db = await database;
    return db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
