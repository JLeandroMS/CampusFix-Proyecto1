import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusfix/ui/auth_page.dart';
void main(){
 for(final size in [const Size(768,1024),const Size(1440,900)]) {
  testWidgets('acceso responsivo y validación ${size.width}',(tester) async {
   tester.view.physicalSize=size;tester.view.devicePixelRatio=1;
   addTearDown(tester.view.resetPhysicalSize);addTearDown(tester.view.resetDevicePixelRatio);
   await tester.pumpWidget(const MaterialApp(home:AuthPage()));
   await tester.tap(find.text('Ingresar'));await tester.pump();
   expect(find.text('Ingrese un correo válido.'),findsOneWidget);
   expect(tester.takeException(),isNull);
  });
 }
}
