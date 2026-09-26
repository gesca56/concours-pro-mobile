import 'package:flutter/material.dart';
import '../models/concours.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'candidature_detail_screen.dart';

class NouvelleCandidatureScreen extends StatefulWidget {
  const NouvelleCandidatureScreen({super.key});

  @override
  State<NouvelleCandidatureScreen> createState() => _NouvelleCandidatureScreenState();
}

class _NouvelleCandidatureScreenState extends State<NouvelleCandidatureScreen> {
  final _api = ApiService();
  late Future<List<Concours>> _concoursOuverts;

  int _etape = 0;
  Concours? _concoursChoisi;
  final _diplomeController = TextEditingController();
  bool _envoi = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _concoursOuverts = _api.concoursOuverts().then((l) => l.map((c) => Concours.fromJson(c)).toList());
  }

  Future<void> _soumettre() async {
    setState(() {
      _envoi = true;
      _erreur = null;
    });

    try {
      final data = await _api.creerCandidature(
        concoursId: _concoursChoisi!.id,
        diplomeCandidat: _diplomeController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CandidatureDetailScreen(candidatureId: data['id'])),
      );
    } on ApiException catch (e) {
      setState(() {
        _erreur = e.errors?.values.first?.first ?? e.message;
      });
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S'inscrire à un concours")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilEtapes(etapeActuelle: _etape),
              const SizedBox(height: 24),
              Expanded(child: _construireEtape()),
              const SizedBox(height: 16),
              _bouton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireEtape() {
    if (_etape == 0) {
      return FutureBuilder<List<Concours>>(
        future: _concoursOuverts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snapshot.data ?? [];
          if (liste.isEmpty) {
            return const Center(child: Text('Aucun concours ouvert pour le moment.'));
          }

          return ListView.separated(
            itemCount: liste.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final c = liste[i];
              final selectionne = _concoursChoisi?.id == c.id;
              return Card(
                color: selectionne ? AppColors.institutionnel.withValues(alpha: 0.06) : null,
                child: ListTile(
                  title: Text(c.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${c.cycle} · ${c.filiere}\nDiplôme requis : ${c.diplomeRequis} · Âge ${c.ageMin}-${c.ageMax} ans',
                  ),
                  isThreeLine: true,
                  trailing: selectionne ? const Icon(Icons.check_circle, color: AppColors.institutionnel) : null,
                  onTap: () => setState(() => _concoursChoisi = c),
                ),
              );
            },
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Concours choisi : ${_concoursChoisi!.nom}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        TextField(
          controller: _diplomeController,
          decoration: const InputDecoration(labelText: 'Votre diplôme'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Doit correspondre exactement au diplôme requis : ${_concoursChoisi!.diplomeRequis}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        if (_erreur != null) ...[
          const SizedBox(height: 12),
          Text(_erreur!, style: const TextStyle(color: AppColors.rouge, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _bouton() {
    if (_etape == 0) {
      return ElevatedButton(
        onPressed: _concoursChoisi == null ? null : () => setState(() => _etape = 1),
        child: const Text('Suivant'),
      );
    }
    return ElevatedButton(
      onPressed: _envoi || _diplomeController.text.trim().isEmpty ? null : _soumettre,
      child: _envoi
          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Soumettre la candidature'),
    );
  }
}

class _FilEtapes extends StatelessWidget {
  final int etapeActuelle;

  const _FilEtapes({required this.etapeActuelle});

  @override
  Widget build(BuildContext context) {
    final labels = ['Concours', 'Diplôme'];
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final passe = (i ~/ 2) < etapeActuelle;
          return Expanded(child: Container(height: 2, color: passe ? AppColors.emeraude : Colors.grey.shade300));
        }
        final index = i ~/ 2;
        final actif = index == etapeActuelle;
        final passe = index < etapeActuelle;
        return Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: passe
                  ? AppColors.emeraude
                  : (actif ? AppColors.institutionnel : Colors.grey.shade300),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(height: 4),
            Text(labels[index], style: const TextStyle(fontSize: 11)),
          ],
        );
      }),
    );
  }
}
