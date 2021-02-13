// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agroventasapp/auxiliares/varsglobales.dart';
import 'package:agroventasapp/auxiliares/alertas.dart';


// --------------- [ FUNCIONES CON HTTP ] ---------------------
// FUNCION [ POST ]
Future<void> apiPOST (String url, Map body, Function (String)callback) async {
  try {
    body['Seguridad'] = VGlobales.SEGURIDAD_TOKEN;
    return await http.post(Uri.encodeFull(VGlobales.URL_SERVIDOR + url), headers: {"Content-Type": "application/json"}, body: json.encode(body)).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error al consumir API");
      }
      callback(/*cadenaJSONAPI(*/json.decode(response.body)/*)*/);
    });
  } catch (error) {
    callback(error.toString());
  }
}

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// --------------- [ FUNCIONES DE ACCION CON API REST ] ---------------------
// FUNCION QUE VERIFICA UN INICIO DE SESION CORRECTO
Future<void> verificarLoggin(String pass, Function (bool)esLoggin) async {
  Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
  Map bodyLogin = {
    'Usuario' : usuarioInfo["usuarioNombre"],
    'Password' : pass,
    'SecurityID': usuarioInfo["securityID"],
    'NotificacionID': usuarioInfo["notificacionID"]
  };
  await apiPOST("/api/applogin/iniciarsesion", bodyLogin, (respuesta) async {
    Map loginRespuesta = json.decode(respuesta);
    esLoggin(loginRespuesta["Respuesta"]);
  });
}

// FUNCION QUE ENVIA LOS DATOS A LA API
Future<void> enviarDataWS(Map dataWS, Function (String)enviarws) async {
  Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
  List<dynamic> dataPendiente = [ dataWS["Data"], dataWS["Accion"], dataWS["Tabla"] ];
  if (usuarioInfo["sinAutomatico"] > 0) {
    if (await InertetConn.verificar()) {
      List<Map<String, dynamic>> pendientesWS = List<Map<String, dynamic>>.from(await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM BDPendientes"));
      if (pendientesWS.length > 0) {
        int idMaxPendientes = await VGlobales.dbSqliteCon.obtenerMaxId("BDPendientes", "Id");
        pendientesWS.add({
          "Id": idMaxPendientes,
          "Accion": dataWS["Accion"],
          "Tabla": dataWS["Tabla"],
          "Data": dataWS["Data"]
        });
        Map bodyDataApp1 = {
          "IdUsuario": usuarioInfo["idUsuario"],
          "DataApp": json.encode(pendientesWS)
        };
        await apiPOST("/api/appdata/procesardata", bodyDataApp1, (respuesta) async {
          if (respuesta == "true") {
            await VGlobales.dbSqliteCon.eliminarDB("DELETE FROM BDPendientes WHERE Accion <> ?", [ "l1Mp14Rd474" ]);
            enviarws(respuesta);
          } else {
            await VGlobales.dbSqliteCon.insertarDB("INSERT INTO BDPendientes (Data,Accion,Tabla) VALUES (?,?,?)", dataPendiente);
            enviarws(respuesta);
          }
        });
      } else {
        dataWS["Id"] = 1;
        List sinPendienteWS = new List();
        sinPendienteWS.add(dataWS);
        Map bodyDataApp2 = {
          "IdUsuario": usuarioInfo["idUsuario"],
          "DataApp": json.encode(sinPendienteWS)
        };
        await apiPOST("/api/appdata/procesardata", bodyDataApp2, (respuesta) async {
          if (respuesta == "true") {
            enviarws(respuesta);
          } else {
            await VGlobales.dbSqliteCon.insertarDB("INSERT INTO BDPendientes (Data,Accion,Tabla) VALUES (?,?,?)", dataPendiente);
            enviarws(respuesta);
          }
        });
      }
    } else {
      await VGlobales.dbSqliteCon.insertarDB("INSERT INTO BDPendientes (Data,Accion,Tabla) VALUES (?,?,?)", dataPendiente);
      enviarws("true");
    }
  } else {
    await VGlobales.dbSqliteCon.insertarDB("INSERT INTO BDPendientes (Data,Accion,Tabla) VALUES (?,?,?)", dataPendiente);
    enviarws("true");
  }
}

// FUNCION QUE ACTUALIZA SOLAMENTE LOS PENDIENTES
Future<void> sincronizarServidor(Function (bool)sinc) async {
  Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
  List<Map<String, dynamic>> pendientesWS = List<Map<String, dynamic>>.from(await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM BDPendientes"));
  Map bodyDataApp = {
    "IdUsuario": usuarioInfo["idUsuario"],
    "DataApp": json.encode(pendientesWS)
  };
  await apiPOST("/api/appdata/procesardata", bodyDataApp, (respuesta) async {
    if (respuesta == "true") {
      await VGlobales.dbSqliteCon.eliminarDB("DELETE FROM BDPendientes WHERE Accion <> ?", [ "l1Mp14Rd474" ]);
      sinc(true);
    } else {
      sinc(false);
    }
  });
}

// FUNCION EXCLUSIVA QUE SINCRONIZA LOS PENDIENTES CUANDO SE ACTIVA/DESACTIVA WIFI/DATOS
Future<void> sincronizarServidorAuto(bool abierto) async {
  if (await VGlobales.dbSqliteCon.verificarDataUsuario()) {
    Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
    if (usuarioInfo["sinAutomatico"] > 0) {
      if (abierto) {
        loadingAbrir("Sincronizando app..");
      }
      List<Map<String, dynamic>> pendientesWS = List<Map<String, dynamic>>.from(await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM BDPendientes"));
      Map bodyDataApp = {
        "IdUsuario": usuarioInfo["idUsuario"],
        "DataApp": json.encode(pendientesWS)
      };
      await apiPOST("/api/appdata/procesardata", bodyDataApp, (respuesta) async {
        if (respuesta == "true") {
          await VGlobales.dbSqliteCon.eliminarDB("DELETE FROM BDPendientes WHERE Accion <> ?", [ "l1Mp14Rd474" ]);
          loadingCerrar((l) { });
        } else {
          loadingCerrar((l) { });
        }
      });
    }
  }
}

// ---------------- [ SINCRONIZAR APLICACION ] ----------------
Future<void> sincronizarAplicacionBD(Function (String)data) async {
  Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
  Map bodyWS = {
    "IdUsuario" : usuarioInfo["idUsuario"]
  };
  await apiPOST("/api/appdata/enviardata", bodyWS, (respuesta) async {
    try {
      await VGlobales.dbSqliteCon.sincronizarBD(json.decode(respuesta), (respBD) {
        data(respBD);
      });
    } catch (error) {
      data(error.toString());
    }
  });
}
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// --------------- [ FUNCIONES GLOBALES ] ---------------------
// FUNCION QUE PREPARA LA CADENA PARA QUE SE PUEDA CODIFICAR LA STRING A UN JSON
String cadenaJSONAPI(String cadena) {
  cadena = cadena.substring(0, cadena.length - 1);
  cadena = cadena.substring(1);
  return cadena.replaceAll('\\', '');
}