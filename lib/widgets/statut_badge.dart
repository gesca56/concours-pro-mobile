import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatutBadge extends StatelessWidget {
  final String statut;

  const StatutBadge({super.key, required this.statut});

  static const _labels = {
    'en_attente': 'En attente',
    'eligible': 'Éligible',
    'inelegible': 'Inéligible',
    'validee': 'Validée',
    'rejetee': 'Rejetée',
    'admise': 'Admise',
    'recalee': 'Recalée',
    'valide': 'Validé',
    'rejete': 'Rejeté',
    'echoue': 'Échoué',
  };

  Color get _couleurTexte {
    if (['validee', 'admise', 'eligible', 'valide'].contains(statut)) return AppColors.emeraude;
    if (statut == 'en_attente') return AppColors.ambre;
    if (['rejetee', 'recalee', 'inelegible', 'rejete', 'echoue'].contains(statut)) {
      return AppColors.rouge;
    }
    return Colors.grey.shade700;
  }

  Color get _couleurFond {
    if (['validee', 'admise', 'eligible', 'valide'].contains(statut)) return AppColors.emeraudeFond;
    if (statut == 'en_attente') return AppColors.ambreFond;
    if (['rejetee', 'recalee', 'inelegible', 'rejete', 'echoue'].contains(statut)) {
      return AppColors.rougeFond;
    }
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _couleurFond, borderRadius: BorderRadius.circular(999)),
      child: Text(
        _labels[statut] ?? statut,
        style: TextStyle(color: _couleurTexte, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
