import 'concours.dart';
import 'document.dart';
import 'paiement.dart';

class Candidature {
  final int id;
  final String? diplomeCandidat;
  final String statut;
  final String? numeroAnonymat;
  final bool aConvocation;
  final double? noteTotale;
  final Concours concours;
  final List<DocumentPiece> documents;
  final List<Paiement> paiements;

  Candidature({
    required this.id,
    required this.diplomeCandidat,
    required this.statut,
    required this.numeroAnonymat,
    required this.aConvocation,
    required this.noteTotale,
    required this.concours,
    required this.documents,
    required this.paiements,
  });

  factory Candidature.fromJson(Map<String, dynamic> json) => Candidature(
        id: json['id'],
        diplomeCandidat: json['diplome_candidat'],
        statut: json['statut'],
        numeroAnonymat: json['numero_anonymat'],
        aConvocation: json['jeton_convocation'] != null,
        noteTotale: json['note_totale'] != null ? double.parse(json['note_totale'].toString()) : null,
        concours: Concours.fromJson(json['concours']),
        documents: (json['documents'] as List<dynamic>? ?? [])
            .map((d) => DocumentPiece.fromJson(d))
            .toList(),
        paiements: (json['paiements'] as List<dynamic>? ?? [])
            .map((p) => Paiement.fromJson(p))
            .toList(),
      );
}
