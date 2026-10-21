import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain.dart';
import '../services/auth_service.dart';
import 'common.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile user;
  const ProfilePage({required this.user, super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late final name = TextEditingController(text: widget.user.name);
  final form = GlobalKey<FormState>();
  bool busy = false;
  @override
  void dispose() { name.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: Align(
    alignment: Alignment.topLeft, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: Panel(child: Form(key: form, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tus datos', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 24),
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => requiredText(v,2,80)),
        const SizedBox(height: 16), Text('Correo: ${widget.user.email}'), Text('Rol: ${widget.user.role.name}'),
        const SizedBox(height: 24), FilledButton(onPressed: busy ? null : () async {
          if (!form.currentState!.validate()) return;
          setState(() => busy = true);
          try { await context.read<AuthService>().updateName(name.text); if (context.mounted) message(context, 'Perfil actualizado.'); }
          catch (_) { if (context.mounted) message(context, 'No se pudo guardar el perfil.'); }
          finally { if (mounted) setState(() => busy = false); }
        }, child: Text(busy ? 'Guardando…' : 'Guardar cambios')),
      ],
    )))),
  ));
}
