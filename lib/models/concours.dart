class Concours {
  final int id;
  final String nom;
  final String code;
  final String cycle;
  final String filiere;
  final String diplomeRequis;
  final int? ageMin;
  final int? ageMax;
  final double fraisInscription;
  final double fraisVisiteMedicale;
  final String statut;

  Concours({
    required this.id,
    required this.nom,
    required this.code,
    required this.cycle,
    required this.filiere,
    required this.diplomeRequis,
    required this.ageMin,
    required this.ageMax,
    required this.fraisInscription,
    required this.fraisVisiteMedicale,
    required this.statut,
  });

  factory Concours.fromJson(Map<String, dynamic> json) => Concours(
        id: json['id'],
        nom: json['nom'],
        code: json['code'],
        cycle: json['cycle'],
        filiere: json['filiere'],
        diplomeRequis: json['diplome_requis'],
        ageMin: json['age_min'],
        ageMax: json['age_max'],
        fraisInscription: double.parse(json['frais_inscription'].toString()),
        fraisVisiteMedicale: double.parse(json['frais_visite_medicale'].toString()),
        statut: json['statut'],
      );
}
