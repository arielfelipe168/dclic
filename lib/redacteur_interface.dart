import 'package:flutter/material.dart';
import 'database/database_manager.dart';
import 'Modele/redacteur.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Redacteur> _redacteurs = [];

  final DatabaseManager _dbManager = DatabaseManager.instance;

  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _refreshRedacteurs();
  }

  void _refreshRedacteurs() async {
    setState(() {
      _isLoading = true;
    });
    final data = await _dbManager.getAllRedacteurs();
    setState(() {
      _redacteurs = data;
      _isLoading = false;
    });
  }


  Future<void> _ajouterRedacteur() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs !'))
      );
      return;
    }

    final nouveauRedacteur = Redacteur.sansId(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
    );

    await _dbManager.insertRedacteur(nouveauRedacteur);

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    _refreshRedacteurs();
  }

  void _montrerDialogueModification(Redacteur redacteur) {
    final TextEditingController modNomController = TextEditingController(text: redacteur.nom);
    final TextEditingController modPrenomController = TextEditingController(text: redacteur.prenom);
    final TextEditingController modEmailController = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifier le Rédacteur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: modNomController, decoration: const InputDecoration(labelText: 'Nom')),
                TextField(controller: modPrenomController, decoration: const InputDecoration(labelText: 'Prénom')),
                TextField(controller: modEmailController, decoration: const InputDecoration(labelText: 'Email')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Sauvegarder'),
              onPressed: () async {
                if (modNomController.text.isNotEmpty &&
                    modPrenomController.text.isNotEmpty &&
                    modEmailController.text.isNotEmpty) {
                  final redacteurMisAJour = Redacteur(
                    id: redacteur.id,
                    nom: modNomController.text,
                    prenom: modPrenomController.text,
                    email: modEmailController.text,
                  );
                  await _dbManager.updateRedacteur(redacteurMisAJour);
                  Navigator.of(context).pop();
                  _refreshRedacteurs();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _supprimerRedacteur(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la Suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce rédacteur ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _dbManager.deleteRedacteur(id);
                Navigator.of(context).pop();
                _refreshRedacteurs(); // Mettre à jour la liste
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Rédacteurs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _ajouterRedacteur,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text('Ajouter un Rédacteur', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Liste des Rédacteurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _redacteurs.isEmpty
                  ? const Center(child: Text("Aucun rédacteur enregistré."))
                  : ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (context, index) {
                  final redacteur = _redacteurs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey.shade100,
                        child: Text('${redacteur.id}', style: const TextStyle(color: Colors.blueGrey)),
                      ),
                      title: Text('${redacteur.nom} ${redacteur.prenom}'),
                      subtitle: Text(redacteur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _montrerDialogueModification(redacteur),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _supprimerRedacteur(redacteur.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}