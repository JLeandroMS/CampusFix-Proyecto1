import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain.dart';
import '../state/incident_state.dart';
import '../state/dashboard_state.dart';
import '../services/catalog_service.dart';
import 'common.dart';

/// Indicadores derivados de la suscripción, sin duplicar datos persistidos.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final incidents = context.watch<IncidentState>();
    if (incidents.loading) return const Center(child: CircularProgressIndicator());
    if (incidents.error != null) return Center(child: Text(incidents.error!));
    final data = DashboardState(incidents.items);
    return SingleChildScrollView(padding: const EdgeInsets.all(24),child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
      Text('El campus, en perspectiva',style: Theme.of(context).textTheme.headlineMedium),const SizedBox(height: 8),
      const Text('Indicadores actualizados en tiempo real. Incluyen todas las incidencias.'),const SizedBox(height: 24),
      Wrap(spacing: 12,runSpacing: 12,children: [for (final entry in {
        'Total': data.total,'Abiertas': data.open,'En atención': data.count(IncidentStatus.enAtencion),
        'Resueltas': data.count(IncidentStatus.resuelta),'Cerradas': data.count(IncidentStatus.cerrada),
      }.entries) SizedBox(width: 185,child: Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text(entry.key),const SizedBox(height: 12),Text('${entry.value}',style: Theme.of(context).textTheme.displaySmall)])))]),
      const SizedBox(height: 24),Panel(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
        Text('Incidencias por categoría',style: Theme.of(context).textTheme.titleLarge),const SizedBox(height: 20),
        StreamBuilder<List<Category>>(stream: context.read<CatalogService>().categories(),builder: (context,s) {
          final names = {for(final c in s.data ?? <Category>[]) c.id:c.name};
          final entries = data.byCategory.entries.toList()..sort((a,b) => b.value.compareTo(a.value));
          return Column(children: [if (entries.isEmpty) const Text('Aún no hay datos.'),for(final e in entries) Padding(padding: const EdgeInsets.only(bottom: 20),child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,children: [
            Text('${names[e.key] ?? e.key} · ${e.value}'),const SizedBox(height: 8),
            LinearProgressIndicator(value: data.total == 0 ? 0 : e.value/data.total,minHeight: 10,borderRadius: BorderRadius.circular(8)),
          ]))]);
        }),
      ])),const SizedBox(height: 12),const Text('Abiertas: reportadas, en revisión, asignadas, en atención y reabiertas. Resueltas y cerradas se contabilizan por separado.'),
    ]));
  }
}
