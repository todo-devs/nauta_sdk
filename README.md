# Nauta SDK

```dart
import 'dart:io';

import 'package:nauta_sdk/nauta_sdk.dart';

void main(List<String> args) async {
  var client = NautaClient();

  await client.preLogin();
  await client.saveCaptcha(filePath: 'captcha.png');

  print('CAPTCHA: ');
  String captcha = stdin.readLineSync();

  try {
    await client.login('usuario@nauta.com.cu', 'Contraseña', captcha);
    print('Usuario: ${client.user}');
    print('Fecha de bloqueo: ${client.blockDate}');
    print('Fecha de eliminación: ${client.delDate}');
    print('Tipo de cuenta: ${client.accountType}');
    print('Tipo de servicio: ${client.serviceType}');
    print('Saldo disponible: ${client.credit}');
    print('Tiempo disponible: ${client.time}');
    print('Cuenta de correo: ${client.mailAccount}');
  } catch (e) {
    print(e);
  }
}
```

Basado en la lib [selibrary](https://github.com/marilasoft/selibrary) de [marilasoft](https://github.com/marilasoft)
