import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/domain.dart';
import '../services/catalog_service.dart';
import '../state/auth_state.dart';
import 'common.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final name = TextEditingController();
  bool busy = false;
  int roleVersion = 0;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> perform(Future<void> Function() work) async {
    setState(() => busy = true);
    try {
      await work();
      if (mounted) message(context, 'Cambios guardados.');
    } catch (_) {
      if (mounted) message(context, 'No se pudieron guardar los cambios.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<CatalogService>();
    final me = context.watch<AuthState>().profile!.id;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catálogo de categorías',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Nueva categoría',
                  ),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () {
                          if (requiredText(name.text, 2, 80) != null) {
                            message(context, 'Ingrese de 2 a 80 caracteres.');
                            return;
                          }
                          perform(() async {
                            await service.saveCategory(null, name.text, true);
                            name.clear();
                          });
                        },
                  child: const Text('Crear categoría'),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<Category>>(
                  stream: service.categories(),
                  builder: (context, s) {
                    if (s.hasError)
                      return const Text('No se pudo cargar el catálogo.');
                    if (!s.hasData) return const LinearProgressIndicator();
                    return Column(
                      children: [
                        for (final c in s.data!)
                          ListTile(
                            title: Text(c.name),
                            subtitle: Text(
                              c.active
                                  ? 'Activa'
                                  : 'Inactiva · conserva historial',
                            ),
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  tooltip: 'Renombrar',
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          final controller =
                                              TextEditingController(
                                                text: c.name,
                                              );
                                          final updated =
                                              await showDialog<String>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Renombrar categoría',
                                                      ),
                                                      content: TextField(
                                                        controller: controller,
                                                        maxLength: 80,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                              ),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        FilledButton(
                                                          onPressed: () {
                                                            if (requiredText(
                                                                  controller
                                                                      .text,
                                                                  2,
                                                                  80,
                                                                ) ==
                                                                null)
                                                              Navigator.pop(
                                                                context,
                                                                controller.text
                                                                    .trim(),
                                                              );
                                                          },
                                                          child: const Text(
                                                            'Guardar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                          // El controlador del diálogo se libera al terminar su animación.
                                          Future<void>.delayed(
                                            const Duration(milliseconds: 350),
                                            controller.dispose,
                                          );
                                          if (updated != null && mounted)
                                            perform(
                                              () => service.saveCategory(
                                                c.id,
                                                updated,
                                                c.active,
                                              ),
                                            );
                                        },
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                Switch(
                                  value: c.active,
                                  onChanged: busy
                                      ? null
                                      : (v) => perform(
                                          () => service.saveCategory(
                                            c.id,
                                            c.name,
                                            v,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
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
                  'Usuarios y roles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Los nuevos usuarios son reportantes. No puedes cambiar tu propio rol.',
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<UserProfile>>(
                  stream: service.users(),
                  builder: (context, s) {
                    if (s.hasError)
                      return const Text('No se pudieron cargar los usuarios.');
                    if (!s.hasData) return const LinearProgressIndicator();
                    return Column(
                      children: [
                        for (final u in s.data!)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        u.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(u.email),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 220,
                                  child: DropdownButtonFormField<UserRole>(
                                    key: ValueKey(
                                      '${u.id}-${u.role}-$roleVersion',
                                    ),
                                    initialValue: u.role,
                                    decoration: const InputDecoration(
                                      labelText: 'Rol',
                                    ),
                                    items: UserRole.values
                                        .map(
                                          (r) => DropdownMenuItem(
                                            value: r,
                                            child: Text(r.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: busy || u.id == me
                                        ? null
                                        : (role) async {
                                            if (role == null || role == u.role)
                                              return;
                                            final confirmed = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Cambiar permisos',
                                                ),
                                                content: Text(
                                                  '¿Asignar el rol ${role.name} a ${u.name}? Si deja de ser técnico, reasigne primero sus casos pendientes.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Confirmar',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirmed == true && mounted)
                                              perform(
                                                () =>
                                                    service.setRole(u.id, role),
                                              );
                                            if (mounted)
                                              setState(() => roleVersion++);
                                          },
                                  ),
                                ),
                              ],
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
}
