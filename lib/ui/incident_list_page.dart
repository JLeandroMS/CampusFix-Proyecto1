import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain.dart';
import '../services/catalog_service.dart';
import '../services/export_service.dart';
import '../state/incident_state.dart';
import 'common.dart';
import 'incident_form_page.dart';
import 'incident_detail_page.dart';

/// Listado en vivo; reportantes ven propios y técnicos únicamente asignados.
class IncidentListPage extends StatefulWidget {
  final UserProfile user;
  const IncidentListPage({required this.user, super.key});
  @override
  State<IncidentListPage> createState() => _IncidentListPageState();
}
class _IncidentListPageState extends State<IncidentListPage> {
  String? selected;
  bool creating = false;
  @override
  Widget build(BuildContext context) {
    if (creating) return IncidentFormPage(user: widget.user, onDone: (id) => setState(() { creating = false; selected = id; }));
    if (selected != null) return IncidentDetailPage(id: selected!, user: widget.user, onBack: () => setState(() => selected = null));
    final state = context.watch<IncidentState>();
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 20, runSpacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cuidemos nuestro campus', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8), Text(widget.user.role == UserRole.tecnico ? 'Tus incidencias asignadas y su seguimiento.' : 'Cada reporte es el inicio de una mejora.')]),
        FilledButton.icon(onPressed: () => setState(() => creating = true), icon: const Icon(Icons.add), label: const Text('Nueva incidencia')),
      ]), const SizedBox(height: 24),
      Panel(child: Column(children: [
        TextFormField(initialValue: state.search, decoration: const InputDecoration(labelText: 'Buscar por consecutivo o texto', prefixIcon: Icon(Icons.search)),
          onChanged: (v) { state.search = v; state.refreshFilters(); }), const SizedBox(height: 16),
        StreamBuilder<List<Category>>(stream: context.read<CatalogService>().categories(), builder: (context, snapshot) {
          final categories = snapshot.data ?? <Category>[];
          return Wrap(spacing: 12, runSpacing: 12, children: [
            _filter('Categoría', state.category, {'': 'Todas', for (final c in categories) c.id: c.name}, (v) { state.category = v; state.refreshFilters(); }),
            _filter('Estado', state.status, {'': 'Todos', for (final s in IncidentStatus.values) s.name: s.label}, (v) { state.status = v; state.refreshFilters(); }),
            _filter('Prioridad', state.priority, const {'': 'Todas', 'baja': 'Baja','media':'Media','alta':'Alta','critica':'Crítica'}, (v) { state.priority = v; state.refreshFilters(); }),
            if (widget.user.role == UserRole.administrador)
              StreamBuilder<List<UserProfile>>(stream: context.read<CatalogService>().users(), builder: (context,s) => _filter('Responsable',state.technician,
                {'': 'Todos', for (final u in s.data ?? <UserProfile>[]) u.id: u.name}, (v) { state.technician = v; state.refreshFilters(); })),
          ]);
        }),
      ])), const SizedBox(height: 20),
      Wrap(spacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [Text('${state.filtered.length} reportes'),
        OutlinedButton.icon(onPressed: state.loading ? null : () => ExportService.incidents(state.filtered), icon: const Icon(Icons.download_outlined), label: const Text('Exportar JSON'))]),
      if (state.loading) const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
      if (state.error != null) Panel(child: Text(state.error!)),
      if (!state.loading && state.error == null && state.filtered.isEmpty) const Panel(child: Text('No hay incidencias que coincidan. Cree un reporte o cambie los filtros.')),
      for (final i in state.filtered) Card(elevation: 0, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() => selected = i.id), child: Padding(
        padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 16, crossAxisAlignment: WrapCrossAlignment.center, children: [Text(i.code, style: const TextStyle(fontWeight: FontWeight.bold)), StatusBadge(i.status), Text('Prioridad ${i.priority}')]),
          const SizedBox(height: 8), Text(i.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8), Text('${i.location} · ${dateLabel(i.createdAt)}'),
        ]),
      ))),
    ]));
  }
  Widget _filter(String label, String value, Map<String,String> entries, ValueChanged<String> change) => SizedBox(width: 210,
    child: DropdownButtonFormField<String>(key: ValueKey('$label-$value-${entries.length}'), initialValue: entries.containsKey(value) ? value : '', isExpanded: true,
      decoration: InputDecoration(labelText: label), items: entries.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, overflow: TextOverflow.ellipsis))).toList(), onChanged: (v) => change(v ?? '')));
}
