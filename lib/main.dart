import 'package:flutter/material.dart';
import 'package:turistico/pages/filtro_page.dart';
import 'package:turistico/pages/lista_pontos_page.dart';

void main() {
  runApp(const CadastroApp());
}

class CadastroApp extends StatelessWidget {
  const CadastroApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Tarefas',
      theme: ThemeData(
        primaryColor: Colors.amber,
        primarySwatch: Colors.purple,
      ),
      home: ListaPontosPage(),
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
      },
    );
  }
}