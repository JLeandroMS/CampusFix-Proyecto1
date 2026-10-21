import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'common.dart';

/// Formulario de acceso/registro. Nunca almacena ni registra la contraseña.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}
class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(), _password = TextEditingController(), _name = TextEditingController();
  bool _register = false, _busy = false, _obscure = true;
  String? _error;
  @override
  void dispose() { _email.dispose(); _password.dispose(); _name.dispose(); super.dispose(); }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final auth = context.read<AuthService>();
      if (_register) { await auth.register(_name.text, _email.text, _password.text); }
      else { await auth.signIn(_email.text, _password.text); }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = switch (e.code) {
        'email-already-in-use' => 'Ese correo ya está registrado.',
        'weak-password' => 'Utilice una contraseña más segura.',
        'network-request-failed' => 'No hay conexión. Intente nuevamente.',
        'too-many-requests' => 'Demasiados intentos. Espere un momento.',
        _ => 'No se pudo iniciar sesión. Verifique correo y contraseña.',
      });
    } catch (_) { if (mounted) setState(() => _error = 'No se completó el acceso. Revise su conexión y la configuración.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Panel(
      child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.other_houses_outlined, size: 48, color: Color(0xff176b5b)),
        const SizedBox(height: 16), Text('CampusFix', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
        const Text('Un campus mejor, reporte a reporte.', textAlign: TextAlign.center),
        const SizedBox(height: 32), Text(_register ? 'Crea tu cuenta' : 'Bienvenido de nuevo', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        if (_register) ...[TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre completo'), validator: (v) => requiredText(v,2,80)), const SizedBox(height: 16)],
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline)),
          validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '') ? null : 'Ingrese un correo válido.'),
        const SizedBox(height: 16), TextFormField(controller: _password, obscureText: _obscure,
          onFieldSubmitted: (_) { if (!_busy) _submit(); },
          decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(tooltip: 'Mostrar u ocultar contraseña', onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
          validator: (v) => (v?.length ?? 0) < (_register ? 8 : 1) ? 'La contraseña requiere ${_register ? 8 : 1} caracteres como mínimo.' : null),
        if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 24), FilledButton(onPressed: _busy ? null : _submit, child: Padding(padding: const EdgeInsets.all(14), child: Text(_busy ? 'Procesando…' : _register ? 'Crear cuenta' : 'Ingresar'))),
        TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }), child: Text(_register ? 'Ya tengo cuenta' : 'Registrarme como reportante')),
        if (!_register) TextButton(onPressed: _busy ? null : () async {
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim())) { message(context, 'Escriba un correo válido primero.'); return; }
          try { await context.read<AuthService>().resetPassword(_email.text); if (context.mounted) message(context,'Si el correo está registrado, recibirá instrucciones.'); }
          catch (_) { if (context.mounted) message(context,'No se pudo enviar la solicitud.'); }
        }, child: const Text('Olvidé mi contraseña')),
      ])),
    )),
  )));
}
