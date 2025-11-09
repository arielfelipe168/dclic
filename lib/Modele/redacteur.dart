class Redacteur {
  int? id;
  String nom;
  String prenom;
  String email;

  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
    );
  }

  @override
  String toString() {
    return 'Redacteur{id: $id, nom: $nom, prenom: $prenom, email: $email}';
  }
}