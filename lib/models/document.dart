class DocumentPiece {
  final int id;
  final String type;
  final String nomOriginal;
  final String statutVerification;
  final String? motifRejet;

  DocumentPiece({
    required this.id,
    required this.type,
    required this.nomOriginal,
    required this.statutVerification,
    this.motifRejet,
  });

  factory DocumentPiece.fromJson(Map<String, dynamic> json) => DocumentPiece(
        id: json['id'],
        type: json['type'],
        nomOriginal: json['nom_original'],
        statutVerification: json['statut_verification'],
        motifRejet: json['motif_rejet'],
      );
}
