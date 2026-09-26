class Paiement {
  final int id;
  final String type;
  final double montant;
  final String statut;
  final String referenceTransaction;

  Paiement({
    required this.id,
    required this.type,
    required this.montant,
    required this.statut,
    required this.referenceTransaction,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) => Paiement(
        id: json['id'],
        type: json['type'],
        montant: double.parse(json['montant'].toString()),
        statut: json['statut'],
        referenceTransaction: json['reference_transaction'],
      );
}
