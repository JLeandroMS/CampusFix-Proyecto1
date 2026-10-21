import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:provider/provider.dart';

import '../models/domain.dart';
import '../services/catalog_service.dart';
import '../services/incident_service.dart';
import '../services/evidence_service.dart';
import '../state/incident_form_state.dart';
import 'common.dart';

class IncidentFormPage extends StatefulWidget {
  final UserProfile user;
  final ValueChanged<String?> onDone;
  const IncidentFormPage({required this.user, required this.onDone, super.key});
  @override
  State<IncidentFormPage> createState() => _IncidentFormPageState();
}

class _IncidentFormPageState extends State<IncidentFormPage> {
  final form = GlobalKey<FormState>();
  final submission = IncidentFormState();
  final title = TextEditingController(),
      description = TextEditingController(),
      location = TextEditingController();
  final photos = <XFile>[];
  String? category;
  @override
  void dispose() {
    submission.dispose();
    title.dispose();
    description.dispose();
    location.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final service = context.read<IncidentService>();
    final evidence = context.read<EvidenceService>();
    String? createdId;
    final result = await submission.submit(() async {
      final id = await service.create(
        widget.user,
        title: title.text,
        description: description.text,
        categoryId: category!,
        location: location.text,
      );
      createdId = id;
      // El reporte ya existe: fallar en una foto nunca vuelve a crear la incidencia.
      for (final photo in photos) {
        final path = await evidence.upload(id, widget.user.id, photo);
        await service.comment(
          id,
          widget.user,
          'Fotografía del reporte inicial.',
          evidence: path,
        );
      }
      return id;
    });
    if (!mounted) return;
    if (createdId != null) {
      message(
        context,
        result != null ? 'Incidencia registrada.' : 'Reporte guardado; alguna foto falló. Puede adjuntarla desde el detalle.',
      );
      widget.onDone(createdId);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: submission,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: submission.busy ? null : () => widget.onDone(null),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
              Panel(
                child: Form(
                  key: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Reportar una incidencia',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Describe qué sucede y dónde. El equipo revisará tu solicitud.',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: title,
                        maxLength: 120,
                        decoration: const InputDecoration(labelText: 'Título'),
                        validator: (v) => requiredText(v, 5, 120),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: description,
                        maxLength: 3000,
                        minLines: 4,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        validator: (v) => requiredText(v, 10, 3000),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: location,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación (edificio, aula o referencia)',
                        ),
                        validator: (v) => requiredText(v, 3, 200),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<Category>>(
                        stream: context.read<CatalogService>().categories(),
                        builder: (context, s) {
                          if (s.hasError)
                            return const Text(
                              'No se pudieron cargar las categorías.',
                            );
                          final list = (s.data ?? <Category>[])
                              .where((c) => c.active)
                              .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                initialValue: category,
                                decoration: const InputDecoration(
                                  labelText: 'Categoría',
                                ),
                                items: list
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => category = v,
                                validator: (v) =>
                                    v == null || !list.any((c) => c.id == v)
                                    ? 'Seleccione una categoría activa.'
                                    : null,
                              ),
                              if (list.isEmpty)
                                const Text(
                                  'El administrador debe crear una categoría activa antes de reportar.',
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: submission.busy || photos.length >= 5
                            ? null
                            : () async {
                                try {
                                  final file = await context
                                      .read<EvidenceService>()
                                      .pick();
                                  if (file != null && mounted)
                                    setState(() => photos.add(file));
                                } catch (_) {
                                  if (context.mounted)
                                    message(
                                      context,
                                      'No se pudo abrir la fotografía.',
                                    );
                                }
                              },
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text(
                          'Adjuntar fotografía (máximo 5, 5 MB cada una)',
                        ),
                      ),
                      for (final photo in photos)
                        ListTile(
                          title: Text(photo.name),
                          trailing: IconButton(
                            onPressed: submission.busy
                                ? null
                                : () => setState(() => photos.remove(photo)),
                            tooltip: 'Quitar fotografía',
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      if (submission.error != null)
                        Text(
                          submission.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: submission.busy ? null : save,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            submission.busy
                                ? 'Guardando reporte…'
                                : 'Enviar reporte',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
