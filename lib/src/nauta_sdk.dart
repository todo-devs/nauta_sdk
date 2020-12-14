import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:nauta_sdk/src/constants.dart';

class NautaClient {
  Dio get httpClient {
    cookies.removeWhere((cookie) {
      if (cookie.expires != null) {
        return cookie.expires.isBefore(DateTime.now());
      }
      return false;
    });

    var http = Dio();
    http.options.headers[HttpHeaders.cookieHeader] = _getCookies();
    return http;
  }

  List<Element> get m6 {
    return homePage.querySelector("div.card-panel").querySelectorAll("div.m6");
  }

  String get user {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Usuario") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get blockDate {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Fecha de bloqueo") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get delDate {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Fecha de eliminación") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get accountType {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Tipo de cuenta") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get serviceType {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Tipo de servicio") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get credit {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Saldo disponible") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get mailAccount {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() == "Cuenta de correo") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String get time {
    for (var element in m6) {
      if (element.querySelector("h5").text.trim() ==
          "Tiempo disponible de la cuenta") {
        return element.querySelector("p").text;
      }
    }
    return null;
  }

  String csrf = '';
  List<int> captcha;
  var page = Document();
  var homePage = Document();
  List<Cookie> cookies = [];

  Future login(String username, String password, String captchaCode) async {
    var formData = FormData.fromMap({
      'btn_submit': '',
      'captcha': captchaCode,
      'csrf': csrf,
      'login_user': username,
      'password_user': password
    });

    var res = await httpClient.post(
      UP_LOGIN_URL,
      data: formData,
      options: Options(validateStatus: (status) {
        return status < 500;
      }),
    );
    _saveCookies(res);

    if (res.headers['location'] != null) {
      res = await httpClient.get(res.headers['location'].first);

      homePage = parse(res.data);

      return [];
    } else {
      page = parse(res.data);

      var err = page.querySelectorAll('script').last;
      var txt = err.text.replaceAll("toastr.error('", '').replaceAll("');", '');
      var error =
          parse(txt).querySelectorAll('li').map((e) => e.text).toList().last;

      throw Exception(error);
    }
  }

  Future preLogin() async {
    var res = await httpClient.get(UP_LOGIN_URL);
    _saveCookies(res);

    page = parse(res.data);

    _getCSRF();
    await _getCaptcha();
  }

  Future<File> saveCaptcha({String filePath: 'captcha.png'}) async {
    var file = File(filePath);
    return await file.writeAsBytes(captcha);
  }

  Future _getCaptcha() async {
    Response<List<int>> res = await httpClient.get(UP_CAPTCHA_URL,
        options: Options(responseType: ResponseType.bytes));

    _saveCookies(res);

    captcha = res.data;
  }

  _getCSRF() {
    final input = page.querySelector('input[name="csrf"]');
    csrf = input.attributes['value'];
  }

  _saveCookies(Response response) {
    if (response != null && response.headers != null) {
      List<String> resCookies = response.headers[HttpHeaders.setCookieHeader];
      if (resCookies != null) {
        cookies.addAll(
            resCookies.map((str) => Cookie.fromSetCookieValue(str)).toList());
      }
    }
  }

  String _getCookies() {
    return cookies.map((cookie) => "${cookie.name}=${cookie.value}").join('; ');
  }
}
