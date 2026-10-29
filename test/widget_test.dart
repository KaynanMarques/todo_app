import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/tarefa.dart';

// Teste simples do modelo Tarefa (não precisa de celular nem de banco).
// Para rodar: flutter test
void main() {
  test('Tarefa vira Map e volta sem perder dados', () {
    const tarefa = Tarefa(id: 1, titulo: 'Estudar Flutter', concluida: true);

    final mapa = tarefa.toMap();
    expect(mapa['concluida'], 1); // bool vira 1 no banco

    final copia = Tarefa.fromMap(mapa);
    expect(copia.id, 1);
    expect(copia.titulo, 'Estudar Flutter');
    expect(copia.concluida, true);
  });

  test('copyWith muda só o campo informado', () {
    const tarefa = Tarefa(id: 2, titulo: 'Lavar louça');
    final marcada = tarefa.copyWith(concluida: true);

    expect(marcada.concluida, true);
    expect(marcada.titulo, 'Lavar louça');
    expect(marcada.id, 2);
  });
}
