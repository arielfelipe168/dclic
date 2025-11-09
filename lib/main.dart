import 'package:flutter/material.dart';
import 'redacteur_interface.dart';

void main() {
  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Magazine Infos - Gestion',
      debugShowCheckedModeBanner: false,

      home: RedacteurInterface(),
    );
  }
}