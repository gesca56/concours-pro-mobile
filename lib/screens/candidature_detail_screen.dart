import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../models/candidature.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/statut_badge.dart';

class CandidatureDetailScreen extends StatefulWidget {
  final int candidatureId;

  const CandidatureDetailScreen({super.key, required this.candidatureId});

  @override
  State<CandidatureDetailScreen> createState() => _CandidatureDetailScreenState();
}

class _CandidatureDetailScreenState extends State<CandidatureDetailScreen> {
  final _api = ApiService();
  late Future<Candidature> _candidature;
  bool _action = false;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    _candidature = _api.candidature(widget.candidatureId).then((json) => Candidature.fromJson(json));
  }

  void _rafraichir() => setState(_charger);

  void _snack(String message, {bool erreur = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: erreur ? AppColors.rouge : AppColors.emeraude),
    );
  }

  Future<void> _payer(int candidatureId, String type) async {
    final controller = TextEditingController();
    final numero = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paiement — ${type == 'inscription' ? 'Inscription' : 'Visite médicale'}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Numéro Mobile Money'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Payer')),
        ],
      ),
    );

    if (numero == null || numero.trim().isEmpty) return;

    setState(() => _action = true);
    try {
      await _api.payer(candidatureId: candidatureId, type: type, numeroTelephone: numero.trim());
      _snack('Paiement effectué avec succès.');
      _rafraichir();
    } on ApiException catch (e) {
      _snack(e.message, erreur: true);
    } finally {
      if (mounted) setState(() => _action = false);
    }
  }

  Future<void> _deposerDocument(int candidatureId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final type = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Type de document'),
        children: [
          for (final entry in {
            'acte_naissance': "Acte de naissance",
            'diplome': 'Diplôme',
            'photo_identite': "Photo d'identité",
            'certificat_medical': 'Certificat médical',
            'piece_identite': "Pièce d'identité",
            'autre': 'Autre',
          }.entries)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, entry.key),
              child: Text(entry.value),
            ),
        ],
      ),
    );
    if (type == null) return;

    setState(() => _action = true);
    try {
      await _api.deposerDocument(
        candidatureId: candidatureId,
        type: type,
        fichierBytes: result.files.single.bytes!,
        nomFichier: result.files.single.name,
      );
      _snack('Document déposé avec succès.');
      _rafraichir();
    } on ApiException catch (e) {
      _snack(e.message, erreur: true);
    } finally {
      if (mounted) setState(() => _action = false);
    }
  }

  Future<void> _ouvrirPdf(Future<List<int>> Function() telecharger, String nomFichier) async {
    setState(() => _action = true);
    try {
      final bytes = await telecharger();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$nomFichier');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);
    } on ApiException catch (e) {
      _snack(e.message, erreur: true);
    } finally {
      if (mounted) setState(() => _action = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la candidature')),
      body: FutureBuilder<Candidature>(
        future: _candidature,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final c = snapshot.data!;
          final typesRestants = <String, double>{};
          if (!c.paiements.any((p) => p.type == 'inscription' && p.statut == 'valide')) {
            typesRestants['inscription'] = c.concours.fraisInscription;
          }
          if (!c.paiements.any((p) => p.type == 'visite_medicale' && p.statut == 'valide')) {
            typesRestants['visite_medicale'] = c.concours.fraisVisiteMedicale;
          }

          return AbsorbPointer(
            absorbing: _action,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(c.concours.nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            StatutBadge(statut: c.statut),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Diplôme déclaré : ${c.diplomeCandidat ?? '—'}'),
                        Text("Numéro d'anonymat : ${c.numeroAnonymat ?? '—'}"),
                        if (c.noteTotale != null) Text('Note : ${c.noteTotale}/20'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          children: [
                            TextButton.icon(
                              onPressed: () => _ouvrirPdf(() => _api.telechargerFiche(c.id), 'fiche-${c.id}.pdf'),
                              icon: const Icon(Icons.description_outlined, size: 18),
                              label: const Text('Fiche'),
                            ),
                            if (c.aConvocation)
                              TextButton.icon(
                                onPressed: () => _ouvrirPdf(() => _api.telechargerConvocation(c.id), 'convocation-${c.id}.pdf'),
                                icon: const Icon(Icons.qr_code_2, size: 18),
                                label: const Text('Convocation'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Pièces justificatives', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (c.documents.isEmpty) const Text('Aucun document déposé.'),
                for (final d in c.documents)
                  Card(
                    child: ListTile(
                      title: Text(d.nomOriginal),
                      subtitle: d.motifRejet != null ? Text('Motif : ${d.motifRejet}') : null,
                      trailing: StatutBadge(statut: d.statutVerification),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _deposerDocument(c.id),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Déposer un document'),
                ),
                const SizedBox(height: 24),
                Text('Paiements', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (c.paiements.isEmpty) const Text('Aucun paiement enregistré.'),
                for (final p in c.paiements)
                  Card(
                    child: ListTile(
                      title: Text('${p.type == 'inscription' ? 'Inscription' : 'Visite médicale'} — ${p.montant.toStringAsFixed(0)} FCFA'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (p.statut == 'valide')
                            IconButton(
                              icon: const Icon(Icons.receipt_long, size: 20),
                              tooltip: 'Reçu',
                              onPressed: () => _ouvrirPdf(() => _api.telechargerRecu(p.id), 'recu-${p.id}.pdf'),
                            ),
                          StatutBadge(statut: p.statut),
                        ],
                      ),
                    ),
                  ),
                for (final entry in typesRestants.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _payer(c.id, entry.key),
                      icon: const Icon(Icons.payment),
                      label: Text(
                        'Payer ${entry.key == 'inscription' ? "l'inscription" : 'la visite médicale'} (${entry.value.toStringAsFixed(0)} FCFA)',
                      ),
                    ),
                  ),
                if (_action) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
