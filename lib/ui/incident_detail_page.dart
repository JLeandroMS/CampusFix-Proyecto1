import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/domain.dart';
import '../models/incident_policy.dart';
import '../services/incident_service.dart';
import '../services/catalog_service.dart';
import '../services/evidence_service.dart';
import '../state/incident_state.dart';
import 'common.dart';

/// Detalle protegido dentro del árbol de sesión; no conserva rutas privadas
/// al cerrar sesión. El historial es de solo lectura para todos los roles.
class IncidentDetailPage extends StatefulWidget {
  final String id;
  final UserProfile user;
  final VoidCallback onBack;
  const IncidentDetailPage({
    required this.id,
    required this.user,
    required this.onBack,
    super.key,
  });
  @override
  State<IncidentDetailPage> createState() => _IncidentDetailPageState();
}

class _IncidentDetailPageState extends State<IncidentDetailPage> {
  final comment = TextEditingController();
  bool busy = false;
  String? uploadedPath;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  Future<void> post() async {
    if (comment.text.trim().length < 3 || comment.text.trim().length > 2000) {
      message(context, 'Escriba de 3 a 2000 caracteres.');
      return;
    }
    setState(() => busy = true);
    try {
      await context.read<IncidentService>().comment(
        widget.id,
        widget.user,
        comment.text,
        evidence: uploadedPath,
      );
      comment.clear();
      uploadedPath = null;
      if (mounted) message(context, 'Seguimiento agregado.');
    } catch (_) {
      if (mounted) {
        message(
          context,
          'No se pudo publicar. Revise conexión y estado de la incidencia.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<IncidentState>();
    final matches = state.items.where((i) => i.id == widget.id);
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('El reporte no está disponible en su bandeja.'),
            TextButton(
              onPressed: widget.onBack,
              child: const Text('Volver al listado'),
            ),
          ],
        ),
      );
    }
    final incident = matches.first;
    final canComment = ![
      IncidentStatus.cerrada,
      IncidentStatus.rechazada,
      IncidentStatus.cancelada,
    ].contains(incident.status);
    final actions = IncidentPolicy.allowed(incident, widget.user);
    final classify =
        widget.user.role == UserRole.administrador &&
        [
          IncidentStatus.enRevision,
          IncidentStatus.reabierta,
        ].contains(incident.status);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy ? null : widget.onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al listado'),
            ),
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      incident.code,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    StatusBadge(incident.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  incident.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                SelectableText(incident.description),
                const SizedBox(height: 20),
                Text('Ubicación: ${incident.location}'),
                Text('Prioridad: ${incident.priority}'),
                StreamBuilder<List<Category>>(
                  stream: context.read<CatalogService>().categories(),
                  builder: (context, s) => Text(
                    'Categoría: ${s.data?.where((c) => c.id == incident.categoryId).firstOrNull?.name ?? incident.categoryId}',
                  ),
                ),
                SelectableText('Reportante: ${incident.creatorId}'),
                SelectableText(
                  'Responsable: ${incident.technicianId ?? 'Sin asignar'}',
                ),
                Text('Creada: ${dateLabel(incident.createdAt)}'),
                Text('Actualizada: ${dateLabel(incident.updatedAt)}'),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (classify)
                      OutlinedButton.icon(
                        onPressed: () => _change(incident, incident.status),
                        icon: const Icon(Icons.tune),
                        label: const Text('Clasificar'),
                      ),
                    for (final target in actions)
                      FilledButton.tonal(
                        onPressed: () => _change(incident, target),
                        child: Text(switch (target) {
                          IncidentStatus.enRevision => 'Revisar',
                          IncidentStatus.asignada => 'Asignar técnico',
                          IncidentStatus.enAtencion => 'Iniciar atención',
                          IncidentStatus.resuelta => 'Registrar solución',
                          IncidentStatus.cerrada => 'Cerrar caso',
                          IncidentStatus.rechazada => 'Rechazar',
                          IncidentStatus.cancelada => 'Cancelar reporte',
                          IncidentStatus.reabierta => 'Reabrir',
                          _ => target.label,
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Seguimiento y evidencias',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (canComment) ...[
                  TextField(
                    controller: comment,
                    minLines: 2,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: const InputDecoration(
                      labelText: 'Avance o comentario',
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: busy || uploadedPath != null
                            ? null
                            : () async {
                                setState(() => busy = true);
                                try {
                                  final service = context
                                      .read<EvidenceService>();
                                  final file = await service.pick();
                                  if (file != null) {
                                    uploadedPath = await service.upload(
                                      widget.id,
                                      widget.user.id,
                                      file,
                                    );
                                  }
                                  if (context.mounted && uploadedPath != null) {
                                    message(
                                      context,
                                      'Fotografía cargada. Publique el comentario para asociarla.',
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    message(
                                      context,
                                      'No se pudo cargar la fotografía: $e',
                                    );
                                  }
                                } finally {
                                  if (mounted) setState(() => busy = false);
                                }
                              },
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(
                          uploadedPath == null
                              ? 'Adjuntar fotografía'
                              : 'Fotografía adjunta',
                        ),
                      ),
                      FilledButton(
                        onPressed: busy ? null : post,
                        child: Text(
                          busy ? 'Procesando…' : 'Publicar seguimiento',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: context.read<IncidentService>().comments(widget.id),
                  builder: (context, s) {
                    if (s.hasError) {
                      return const Text('No se pudo cargar el seguimiento.');
                    }
                    if (!s.hasData) return const LinearProgressIndicator();
                    if (s.data!.docs.isEmpty) {
                      return const Text(
                        'Todavía no hay comentarios ni fotografías.',
                      );
                    }
                    return Column(
                      children: [
                        for (final doc in s.data!.docs) _comment(doc.data()),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial y auditoría',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: context.read<IncidentService>().events(widget.id),
                  builder: (context, s) {
                    if (s.hasError) {
                      return const Text('No se pudo cargar el historial.');
                    }
                    if (!s.hasData) return const LinearProgressIndicator();
                    return Column(
                      children: [
                        for (final doc in s.data!.docs)
                          ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(
                              '${IncidentStatus.values.byName(doc['status'] as String).label} · ${doc['note']}',
                            ),
                            subtitle: Text(
                              '${dateLabel(doc['at'])}\nAutor: ${doc['authorId']}\nResponsable: ${doc['technicianId'] ?? 'Sin asignar'} · Categoría: ${doc['categoryId']} · Prioridad: ${doc['priority']}',
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _comment(Map<String, dynamic> c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(c['text'] as String),
        Text(
          '${dateLabel(c['at'])} · Autor: ${c['authorId']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (c['evidence'] != null) PrivatePhoto(path: c['evidence'] as String),
        const Divider(),
      ],
    ),
  );
  Future<void> _change(Incident i, IncidentStatus target) async {
    final service = context.read<IncidentService>();
    final catalog = context.read<CatalogService>();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeDialog(
        incident: i,
        user: widget.user,
        target: target,
        service: service,
        catalog: catalog,
      ),
    );
    if (mounted && result == true) {
      message(context, 'Cambio registrado en el historial.');
    }
  }
}

/// Descarga autenticada memorizada por widget; evita URLs públicos de Storage.
class PrivatePhoto extends StatefulWidget {
  final String path;
  const PrivatePhoto({required this.path, super.key});
  @override
  State<PrivatePhoto> createState() => _PrivatePhotoState();
}

class _PrivatePhotoState extends State<PrivatePhoto> {
  late Future<Uint8List?> bytes;
  @override
  void initState() {
    super.initState();
    bytes = context.read<EvidenceService>().load(widget.path);
  }

  @override
  void didUpdateWidget(PrivatePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      bytes = context.read<EvidenceService>().load(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    future: bytes,
    builder: (context, s) {
      if (s.hasError) return const Text('No se pudo mostrar la evidencia.');
      if (!s.hasData) return const LinearProgressIndicator();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Image.memory(
          s.data!,
          height: 220,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text('Imagen no válida.'),
        ),
      );
    },
  );
}

class ChangeDialog extends StatefulWidget {
  final Incident incident;
  final UserProfile user;
  final IncidentStatus target;
  final IncidentService service;
  final CatalogService catalog;
  const ChangeDialog({
    required this.incident,
    required this.user,
    required this.target,
    required this.service,
    required this.catalog,
    super.key,
  });
  @override
  State<ChangeDialog> createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  final form = GlobalKey<FormState>();
  final note = TextEditingController();
  late String category = widget.incident.categoryId,
      priority = widget.incident.priority;
  String? technician;
  bool busy = false;
  String? error;
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classify = widget.target == widget.incident.status;
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        title: Text(classify ? 'Clasificar incidencia' : widget.target.label),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (classify) ...[
                    StreamBuilder<List<Category>>(
                      stream: widget.catalog.categories(),
                      builder: (context, s) {
                        final list = (s.data ?? <Category>[])
                            .where((c) => c.active || c.id == category)
                            .toList();
                        return DropdownButtonFormField<String>(
                          key: ValueKey('categories-${list.length}'),
                          initialValue: list.any((c) => c.id == category)
                              ? category
                              : null,
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
                          onChanged: (v) => category = v!,
                          validator: (v) =>
                              v == null ? 'Seleccione categoría.' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Prioridad'),
                      items: ['baja', 'media', 'alta', 'critica']
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => priority = v!,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.target == IncidentStatus.asignada) ...[
                    Text(
                      'Categoría: ${widget.incident.categoryId} · Prioridad: ${widget.incident.priority}\nConfirme la clasificación antes de asignar.',
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<UserProfile>>(
                      stream: widget.catalog.users(),
                      builder: (context, s) {
                        if (s.hasError) {
                          return const Text(
                            'No se pudieron cargar los técnicos.',
                          );
                        }
                        final list = (s.data ?? <UserProfile>[])
                            .where((u) => u.role == UserRole.tecnico)
                            .toList();
                        return DropdownButtonFormField<String>(
                          initialValue: technician,
                          decoration: const InputDecoration(
                            labelText: 'Técnico responsable',
                          ),
                          items: list
                              .map(
                                (u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(u.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => technician = v,
                          validator: (v) =>
                              v == null ? 'Seleccione un técnico.' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: note,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      labelText: widget.target == IncidentStatus.resuelta
                          ? 'Descripción de la solución'
                          : 'Motivo o detalle del cambio',
                    ),
                    validator: (v) => requiredText(v, 10, 2000),
                  ),
                  if (error != null)
                    Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    setState(() {
                      busy = true;
                      error = null;
                    });
                    try {
                      await widget.service.change(
                        widget.incident,
                        widget.user,
                        target: widget.target,
                        note: note.text,
                        technicianId: technician,
                        categoryId: category,
                        priority: priority,
                      );
                      if (context.mounted) Navigator.pop(context, true);
                    } catch (_) {
                      if (mounted) {
                        setState(
                          () => error =
                              'No se pudo guardar. Compruebe permisos, conexión y si otro usuario modificó el reporte.',
                        );
                      }
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(busy ? 'Guardando…' : 'Confirmar'),
          ),
        ],
      ),
    );
  }
}
