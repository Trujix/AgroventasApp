// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:toast/toast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';


// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// ---------------- [ MENSAJES DE ALERTA ] ----------------

// -------------- [ MENSAJES RAPIDOS ] --------------
// MENSAJE CORTO
void msgCorto(String contenido, int posicion) {
  Toast.show(contenido, contextGlobal, duration: Toast.LENGTH_SHORT, gravity: (posicion > 0) ? Toast.BOTTOM : Toast.TOP);
}

// MENSAJE LARGO
void msgLargo(String contenido, int posicion) {
  Toast.show(contenido, contextGlobal, duration: Toast.LENGTH_LONG, gravity: (posicion > 0) ? Toast.BOTTOM : Toast.TOP);
}

// -------------- [ MENSAJES COMPLEJOS ] --------------
// MENSAJE PRIMARIO Y SIMPLE (CONTIENE TITULO, CUERPO Y FINAL)
void msgPrimario(String titulo, String cuerpo, btn) {
  // CONTROLA EL BOTON DE CIERRE
  Widget okBoton = FlatButton(
    child: Text(btn),
    onPressed: () {
      Navigator.of(contextGlobal).pop();
    },
  );
  // WIDGET QUE CONSTRUYE EL DIALOGO DE ALERTA
  AlertDialog alerta = AlertDialog(
    title: Text(titulo),
    content: Text(cuerpo),
    actions: [
      okBoton,
    ],
  );
  // MUESTRA EL DIALOGO DE ALERTA
  showDialog(
    context: contextGlobal,
    builder: (BuildContext contextAlertaInt) {
      return alerta;
    },
  );
}

// ---------------- [ MENSAJES DE PREGUNTA ]
void msgPregunta(String titulo, String cuerpo, String btnSi, String btnNo, Function(bool) respuesta) {
  // CONTROLA EL BOTON DE CANCELAR
  Widget cancelarBoton = FlatButton(
    child: Text(btnNo),
    onPressed:  () {
      Navigator.of(contextGlobal).pop();
      respuesta(false);
    },
  );
  // CONTROLA EL BOTON DE ACEPTAR
  Widget aceptarBoton = FlatButton(
    child: Text(btnSi),
    onPressed:  () {
      Navigator.of(contextGlobal).pop();
      respuesta(true);
    },
  );
  // WIDGET QUE CONSTRUYE EL DIALOGO DE ALERTA
  AlertDialog alerta = AlertDialog(
    title: Text(titulo),
    content: Text(cuerpo),
    actions: [
      cancelarBoton,
      aceptarBoton,
    ],
  );
  // MUESTRA EL DIALOGO
  showDialog(
    context: contextGlobal,
    builder: (BuildContext context) {
      return alerta;
    },
  );
}

// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// ------------------ [ VISTA PARA EL TRANZA ] ------------------
class Tranza extends StatelessWidget {
  @override
  Widget build(BuildContext contextPrincipal) {
    contextGlobal = contextPrincipal;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(148, 49, 38, 1),
        body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Center(
                child: Icon(FontAwesomeIcons.exclamationTriangle, color: Color.fromRGBO(247, 220, 111, 1), size: 180,),
              ),
              SizedBox(height: 30.0,),
              Container(
                padding: EdgeInsets.all(10),
                color: Color.fromRGBO(0, 0, 0, 1),
                child: Text(
                  "\nAtención!: Se ha detectado un problema al intentar iniciar sesión con este usuario. Las 2 posibles causas de este error son las siguientes:\n1 - El usuario con el que intenta ingresar, ya está siendo usado en otro dispositivo:\nDeberá 'Desactivar' el antiguo dispositivo en el menú 'Configuracion' en la pestaña 'Datos'; si ya no posee el antiguo dispositivo y no puede realizar esta recomendación, o su problema es distinto, comuniquese con el administrador de la aplicación.\n\n2 - Está intentando ingresar con un usuario CLANDESTINO o NO VÁLIDO:\nDebe saber que por la ilegitimidad de la acción y por medidas de seguridad, dicho usuario con el que intentó acceder ha sido ELIMINADO de nuestros servicios.\nSi su problema es ajeno a cualquiera de estos 2 apartados, le recomendamos ponerse en contacto con el administrador de la aplicación.\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// ---------------- [ LOADING SPINNER MULTIUSO ] ----------------

// CLASE QUE DEVUELVE EL WIDGET DE LOADING FIJO - EVITAR QUE EL STATELESS SE ACTUALIZE DINAMICAMENTE
class LoaderFijo extends StatelessWidget {
  @override
  Widget build(BuildContext contextLoader) {
    return Container(
      color: Color.fromRGBO(0, 105, 92, 1),
      child: Center(
        child: SpinKitCircle(
          color: Colors.white, 
          size: 50.0,
        ),
      ),
    );
  }
}

// CLASE QUE DEVUELVE EL WIDGET DEL LOADING
class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext contextLoader) {
    return Container(
      color: GEstilos.agroVerde,
      child: Center(
        child: crearLoader(),
      ),
    );
  }
}

// WIDGET QUE DEVUELVE LA ESTRUCTURA DEL TIPO DE LOADER DE FORMA ALEATORIA (4 TIPOS)
Widget crearLoader() {
  var rNum = new Random();
  int num = rNum.nextInt(4);
  if (num == 1) {
    return SpinKitDualRing(color: Colors.white, size: 50.0,);
  } else  if (num == 2) {
    return SpinKitFadingCircle(color: Colors.white, size: 50.0,);
  } else  if (num == 3) {
    return SpinKitRing(color: Colors.white, size: 50.0,);
  } else  if (num == 4) {
    return SpinKitWave(color: Colors.white, size: 50.0,);
  } else {
    return SpinKitCircle(color: Colors.white, size: 50.0,);
  }
}

// ++++++++++++++++++++++++++++----------------++++++++++++++++++++++++++++++++
// ::::::::::::::::::::::::::: [ MISCELANEAS ] :::::::::::::::::::::::::::
// FUNCION QUE DESENFOCA TODOS LOS ELEMENTOS DE UN FORMULARIO Y/O VISTA
void noFocus() {
  FocusScopeNode currentFocus = FocusScope.of(contextGlobal);
  if (!currentFocus.hasPrimaryFocus && currentFocus != null) {
    currentFocus.unfocus();
  }
}

// FUNCION QUE ABRE UN LOADING
void loadingAbrir(String mensaje) {
  loaderGlobal = new ProgressDialog(contextGlobal, type: ProgressDialogType.Normal, isDismissible: false);
  loaderGlobal.style(
    message: mensaje,
  );
  loaderGlobal.show();
}

// FUNCION QUE CIERRA EL LOADING
Future<void> loadingCerrar(Function (bool)loading) async {
  Future.delayed(Duration(seconds: 1)).then((v){
    loaderGlobal.hide();
    loading(true);
  });
}