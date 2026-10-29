import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'models/tarefa.dart';

void main() {
  runApp(const TodoApp());
}

// Widget raiz: define o tema e qual é a primeira tela.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E6B5E)),
        useMaterial3: true,
      ),
      home: const TelaTarefas(),
    );
  }
}

// A tela é Stateful porque muda: a lista atualiza quando adicionamos,
// marcamos ou excluímos uma tarefa.
class TelaTarefas extends StatefulWidget {
  const TelaTarefas({super.key});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final _db = DatabaseHelper.instance;

  // Controla o texto digitado no TextField.
  final _controller = TextEditingController();

  // O "pedido" ao banco que o FutureBuilder vai acompanhar.
  late Future<List<Tarefa>> _tarefasFuture;

  @override
  void initState() {
    super.initState();
    // Assim que a tela abre, busca as tarefas no banco.
    _tarefasFuture = _db.listarTarefas();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Busca a lista de novo e manda a tela se redesenhar.
  void _recarregar() {
    if (!mounted) return;
    setState(() {
      _tarefasFuture = _db.listarTarefas();
    });
  }

  // INSERT: pega o texto do TextField e salva no banco.
  Future<void> _adicionarTarefa() async {
    final titulo = _controller.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o nome da tarefa antes de adicionar.')),
      );
      return;
    }

    await _db.inserirTarefa(Tarefa(titulo: titulo));
    _controller.clear();
    _recarregar();
  }

  // UPDATE: inverte o "concluída" (feita <-> pendente).
  Future<void> _alternarConcluida(Tarefa tarefa) async {
    await _db.atualizarTarefa(tarefa.copyWith(concluida: !tarefa.concluida));
    _recarregar();
  }

  // DELETE: apaga a tarefa e avisa na parte de baixo da tela.
  Future<void> _excluirTarefa(Tarefa tarefa) async {
    await _db.excluirTarefa(tarefa.id!);
    _recarregar();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarefa "${tarefa.titulo}" excluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tarefas')),
      body: Column(
        children: [
          // ===== Campo de texto + botão (inserção via TextField) =====
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Nova tarefa',
                      hintText: 'Ex.: Estudar Flutter',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    // Apertar "Enter" no teclado também adiciona.
                    onSubmitted: (_) => _adicionarTarefa(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _adicionarTarefa,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),

          // ===== Lista de tarefas (listagem com FutureBuilder) =====
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefasFuture,
              builder: (context, snapshot) {
                // 1) Ainda carregando (primeira vez): mostra a rodinha.
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2) Deu erro ao ler o banco.
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar as tarefas: ${snapshot.error}'),
                  );
                }

                // 3) Carregou, mas não tem nenhuma tarefa.
                final tarefas = snapshot.data ?? [];
                if (tarefas.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma tarefa ainda.\nDigite uma acima e toque em Adicionar.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // 4) Carregou com tarefas: monta a lista.
                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];

                    return ListTile(
                      // Checkbox = marcar/desmarcar como concluída (Update)
                      leading: Checkbox(
                        value: tarefa.concluida,
                        onChanged: (_) => _alternarConcluida(tarefa),
                      ),
                      title: Text(
                        tarefa.titulo,
                        style: TextStyle(
                          decoration: tarefa.concluida
                              ? TextDecoration.lineThrough
                              : null,
                          color: tarefa.concluida ? Colors.grey : null,
                        ),
                      ),
                      // Lixeira = excluir (Delete)
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Excluir tarefa',
                        onPressed: () => _excluirTarefa(tarefa),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
