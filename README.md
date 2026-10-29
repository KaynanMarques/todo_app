# Lista de Tarefas (Todo App)

App Flutter com **sqflite** feito para o desafio prático da aula.

## O que o app faz

1. Cria a tabela `tarefas (id, titulo, concluida)` no SQLite
2. Insere uma nova tarefa digitada no `TextField`
3. Lista as tarefas usando `FutureBuilder`
4. Marca a tarefa como concluída (Update) e exclui (Delete)

## Estrutura

```
lib/
  main.dart                     -> tela do app (TextField, FutureBuilder, lista)
  models/tarefa.dart            -> modelo da tarefa (id, titulo, concluida)
  database/database_helper.dart -> banco: criar tabela, inserir, listar, atualizar, excluir
test/
  widget_test.dart              -> teste simples do modelo
```

## Como rodar no Android Studio

Precisa ter o Flutter instalado e os plugins **Flutter** e **Dart** no Android Studio.

1. Baixe o projeto: no Android Studio, use **File → New → Project from Version Control** com o link deste repositório, ou baixe pelo botão **Code → Download ZIP** aqui no GitHub e extraia.
2. Abra a pasta do projeto no Android Studio (**File → Open**).
3. No **Terminal** do Android Studio, rode:

   ```bash
   flutter create --project-name todo_app .
   flutter pub get
   ```

   Esse comando gera as pastas de plataforma (como `android/`) na versão do Flutter instalada na máquina. Ele não altera o código do app.
4. Abra um emulador Android no **Device Manager**, selecione ele na barra de cima e clique em **Run ▶**.

## Rodando pelo terminal

```bash
flutter create --project-name todo_app .
flutter pub get
flutter run
```

> O sqflite funciona no **Android** e no **iOS** (emulador ou celular). Ele não funciona no Chrome nem no Windows.
