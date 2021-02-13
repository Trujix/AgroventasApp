// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'sqlitedb.dart';
import 'dart:core';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:agroventasapp/main.dart';
import 'package:agroventasapp/principal.dart';
import 'package:agroventasapp/vistas/catalogoclientes.dart';
import 'package:agroventasapp/vistas/configuracion.dart';



// ---------------- [ FINALS GLOBALES ] ----------------
final GlobalKey<MyAppEstado> mainKey = GlobalKey<MyAppEstado>();
final GlobalKey<PaginaPrincipalEstado> principalKey = GlobalKey<PaginaPrincipalEstado>();
final GlobalKey<ConfiguracionEstado> configKey = GlobalKey<ConfiguracionEstado>();
final GlobalKey<CatalogoClientesEstado> catClientesKey = GlobalKey<CatalogoClientesEstado>();
ProgressDialog loaderGlobal = new ProgressDialog(contextGlobal, type: ProgressDialogType.Normal, isDismissible: false);
BuildContext contextGlobal;
AppLifecycleState estadoAppGlobal = AppLifecycleState.resumed;

// ---------------- [ CLASES GLOBALES ] ----------------
class VGlobales {
  // MAIN Y UNIVERSALES
  static final SqliteDB dbSqliteCon = SqliteDB();
  static int usuarioLogeado = 0;
  static int bdSincronizada = 0;
  static String nombreUsuario = "--";
  static const charsFAleatoria = "abcdefghijklmnopqrstuvwxyz0123456789";
  static bool sincServidorInicial = false;
  // API FUNCIONES - DART
  static const String URL_SERVIDOR = 'http://agropruebas2236.somee.com';
  static const String SEGURIDAD_TOKEN = '3xbFzx;g4jUbJR6/%%+{AKy_g/w2qHy)24x}A4eyy_&iGm4Yc5G';
  // SQLITE MODULO
  static List<String> sqliteTablas = [ "BDPendientes", "Usuario", "Clientes", "Campos", "CorreosClientes", "Repartidores", "Productos", "Presentaciones", "OrdenesPedido" ];
  // ---------- [ MENUS ] ----------
  static bool iniciarParams = true;
  // [ MENU CONFIGURACION ] - DATOS
  static bool ejecSwitch = false;
  static bool appSincronizada = true;
  static String btnTxtSincServidor = "  Sincronizado con el servidor";
  static Color btnClrSincServidor = Color.fromRGBO(40, 167, 69, 1);
  static IconData btnIcnSincServidor = FontAwesomeIcons.solidCheckCircle;
  // [ MENU CATALOGO CLIENTES ]
  static List<Widget> emailsClienteLista = new List<Widget>();
  static List<Widget> camposUbicClienteLista = new List<Widget>();
  static List<TextEditingController> emailsClienteInputs = new List<TextEditingController>();
  static List<TextEditingController> camposClienteInputs = new List<TextEditingController>();
  static List<TextEditingController> ubicacionCClienteInputs = new List<TextEditingController>();
  static GlobalKey<AutoCompleteTextFieldState<Map<String, dynamic>>> clienteACKey = new GlobalKey();
  static int idClienteGlobal = 0;
  static String razonSocialGlobal = "";
  static List<Map<String, dynamic>> clientesLista = new List<Map<String, dynamic>>();
  static Map<String, dynamic> clientesAltaServidor = new Map<String, dynamic>();
  static List<Map<String, dynamic>> correosAltaServidor = new List<Map<String, dynamic>>();
  static List<Map<String, dynamic>> camposAltaServidor = new List<Map<String, dynamic>>();
}

// ---------------- [ VARIABLES DE ESTILOS GLOBALES ] ----------------
class GEstilos {
  // COLORES GENERALES
  static const Color agroVerde = Color.fromRGBO(0, 105, 92, 1);
  // BOTONES
  static const Color btnExito = Color.fromRGBO(40, 167, 69, 1);
  static const Color btnPrimario = Color.fromRGBO(0, 123, 255, 1);
  static const Color btnSegundo = Color.fromRGBO(108, 117, 125, 1);
  static const Color btnInfo = Color.fromRGBO(23, 162, 184, 1);
  static const Color btnAtencion = Color.fromRGBO(255, 193, 7, 1);
  static const Color btnError = Color.fromRGBO(220, 53, 69, 1);
  static const Color btnOscuro = Color.fromRGBO(52, 58, 64, 1);
  // TEXTOS
  static const Color cMarcador = Color.fromRGBO(171, 178, 185, 1);
  static const TextStyle txtTitulo = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color.fromRGBO(125, 125, 125, 1),
  );
  static const TextStyle txtEtiqueta = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Color.fromRGBO(0, 105, 92, 1),
  );
  static const TextStyle txtDescripcion = TextStyle(
    color: Color.fromRGBO(125, 125, 125, 1),
  );
  static const TextStyle txtNDescripcion = TextStyle(
    fontWeight: FontWeight.bold,
    color: Color.fromRGBO(125, 125, 125, 1),
  );
  // OTROS
  static const Color lineaDivisor = Color.fromRGBO(174, 174, 174, 1);
}

// --------------- [ CLASE QUE CONTIENE LAS FUNCIONES DE CONSULTA TIPO GOOGLE ] -------------
class GoogleConsultas {
  // CONSULTA SUGERIDA PARA LOS COMBOS AUTO - ++ CLIENTES ++
  static Future<List<Map<String, dynamic>>> clientes(String query) async {
    VGlobales.idClienteGlobal = 0;
    VGlobales.razonSocialGlobal = "";
    List<Map<String, dynamic>> listaConsulta = new List<Map<String, dynamic>>();
    VGlobales.clientesLista.forEach((cliente) {
      if (cliente["RazonSocial"].toString().toLowerCase().indexOf(query.toLowerCase()) >= 0) {
        listaConsulta.add({
          "RazonSocial": cliente["RazonSocial"],
          "Id": cliente["Id"]
        });
      }
    });
    return listaConsulta;
  }
}

// :::::::::::::::::::::::::::: [ CLASE DE MANEJO DE CONECCION DE INTERNET ] ::::::::::::::::::::::::::::
class InertetConn {
  // VARIABLES Y PARAMETROS DE CONECCION
  InertetConn._internal();
  static final InertetConn _instance = InertetConn._internal();
  static InertetConn get instance => _instance;
  Connectivity conectividad = Connectivity();
  StreamController controlador = StreamController.broadcast();
  Stream get myStream => controlador.stream;
  // FUNCION QUE INICIALIZA EL STREAM PARA VERFICIAR EL ESTATUS DE CONECCION
  void inicializar() async {
    ConnectivityResult result = await conectividad.checkConnectivity();
    _verifStatus(result);
    conectividad.onConnectivityChanged.listen((result) {
      _verifStatus(result);
    });
  }
  // FUNCION QUE VERIFICA EL ESTATUS DE CONECCION
  void _verifStatus(ConnectivityResult result) async {
    bool estaOnline = false;
    if (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile) {
      estaOnline = true;
    }
    controlador.sink.add(estaOnline);
  }
  void disposeStream() => controlador.close();
  // FUNCION QUE VERIFICA LA CONECCION DE INTERNET
  static Future<bool> verificar() async {
    var coneccionResultado = await (Connectivity().checkConnectivity());
    if (coneccionResultado == ConnectivityResult.mobile) {
      return true;
    } else if (coneccionResultado == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}


// :::::::::::::::::: [ FUNCIONES MISCELANEAS ] ::::::::::::::::::
// FUNCION QUE GENERA UNA CADENA ALEATORIA (MULTIUSOS)
String cadenaAleatoria(int longitud) {
  Random cad = new Random(new DateTime.now().millisecondsSinceEpoch);
  String cadAleatoria = "";
  for (var i = 0; i < longitud; i++) {
    cadAleatoria += VGlobales.charsFAleatoria[cad.nextInt(VGlobales.charsFAleatoria.length)];
  }
  return cadAleatoria;
}
/*
flutter clean
flutter pub cache repair
flutter config --android-sdk
flutter build appbundle --target-platform android-arm,android-arm64
https://www.youtube.com/watch?v=F19CDDfXKko
http://www.coderzheaven.com/2019/01/11/flutter-tutorials-autocomplete-textfield/
*/