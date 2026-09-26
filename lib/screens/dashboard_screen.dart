import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/candidature.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/statut_badge.dart';
import 'candidature_detail_screen.dart';
import 'nouvelle_candidature_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _api = ApiService();
  late Future<List<Candidature>> _candidatures;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    _candidatures = _api.mesCandidatures().then(
          (liste) => liste.map((c) => Candidature.fromJson(c)).toList(),
        );
  }

  Future<void> _rafraichir() async {
    setState(_charger);
    await _candidatures;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes candidatures'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => context.read<AuthProvider>().deconnexion(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _rafraichir,
        child: FutureBuilder<List<Candidature>>(
          future: _candidatures,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(child: Text('Erreur : ${snapshot.error}')),
                ],
              );
            }

            final candidatures = snapshot.data ?? [];

            if (candidatures.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Bonjour ${user?['name'] ?? ''},',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text("Vous n'avez pas encore de candidature en cours."),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => const NouvelleCandidatureScreen()))
                        .then((_) => _rafraichir()),
                    child: const Text("S'inscrire à un concours"),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: candidatures.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = candidatures[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(c.concours.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('${c.concours.cycle} · ${c.concours.filiere}',
                          style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    trailing: StatutBadge(statut: c.statut),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (_) => CandidatureDetailScreen(candidatureId: c.id)))
                        .then((_) => _rafraichir()),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.institutionnel,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle inscription'),
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const NouvelleCandidatureScreen()))
            .then((_) => _rafraichir()),
      ),
    );
  }
}
