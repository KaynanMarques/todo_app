// MODELO: representa UMA tarefa do app.
// Cada campo aqui corresponde a uma coluna da tabela "tarefas".
class Tarefa {
  final int? id; // Pode ser nulo antes de salvar (o banco gera o id sozinho)
  final String titulo; // O texto da tarefa
  final bool concluida; // true = feita, false = pendente

  const Tarefa({
    this.id,
    required this.titulo,
    this.concluida = false,
  });

  // Converte a Tarefa em um Map para SALVAR no banco.
  // O SQLite não tem tipo bool, então guardamos 1 (sim) ou 0 (não).
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'concluida': concluida ? 1 : 0,
    };
  }

  // Faz o caminho inverso: pega uma linha do banco e vira uma Tarefa.
  factory Tarefa.fromMap(Map<String, Object?> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      concluida: map['concluida'] == 1,
    );
  }

  // Cria uma cópia da tarefa mudando só o que for informado.
  // Usado para marcar/desmarcar como concluída.
  Tarefa copyWith({int? id, String? titulo, bool? concluida}) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      concluida: concluida ?? this.concluida,
    );
  }
}
