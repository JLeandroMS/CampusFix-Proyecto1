import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/domain.dart';
import '../services/auth_service.dart';
import '../state/theme_state.dart';
import 'incident_list_page.dart';
import 'dashboard_page.dart';
import 'admin_page.dart';
import 'profile_page.dart';

/// Navegación según rol con lateral en escritorio y menú en tablet.
class Shell extends StatefulWidget {
  final UserProfile user;
  const Shell({required this.user, super.key});
  @override
  State<Shell> createState() => _ShellState();
}
class _ShellState extends State<Shell> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final admin = widget.user.role == UserRole.administrador;
    final labels = ['Incidencias', if (admin) 'Dashboard', if (admin) 'Administración', 'Mi perfil'];
    final icons = [Icons.inbox_outlined, if (admin) Icons.dashboard_outlined, if (admin) Icons.tune, Icons.person_outline];
    final views = <Widget>[IncidentListPage(user: widget.user), if (admin) const DashboardPage(), if (admin) const AdminPage(), ProfilePage(user: widget.user)];
    Widget navigation(bool drawer) => Column(children: [
      const SizedBox(height: 28), const ListTile(leading: Icon(Icons.other_houses_outlined), title: Text('CampusFix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)), subtitle: Text('Servicios del campus')),
      const SizedBox(height: 24),
      for (var i = 0; i < labels.length; i++) Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), selected: i == page,
        selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Icon(icons[i]), title: Text(labels[i]), onTap: () { setState(() => page = i); if (drawer) Navigator.pop(context); })),
      const Spacer(), ListTile(title: Text(widget.user.name), subtitle: Text(widget.user.role.name)), const SizedBox(height: 16),
    ]);
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      appBar: AppBar(title: Text(labels[page]), actions: [
        IconButton(tooltip: 'Cambiar tema', onPressed: context.read<ThemeState>().toggle, icon: const Icon(Icons.contrast)),
        IconButton(tooltip: 'Cerrar sesión', onPressed: context.read<AuthService>().signOut, icon: const Icon(Icons.logout)), const SizedBox(width: 16),
      ]),
      drawer: wide ? null : Drawer(child: navigation(true)),
      body: Row(children: [if (wide) SizedBox(width: 250, child: navigation(false)), Expanded(child: views[page])]),
    );
  }
}
