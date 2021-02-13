// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';



// +++++++++++++++ ::::::::::::::::::: [] ::::::::::::::::::: +++++++++++++++
// ---------------------- [ OPERACION INICIAL SQLITE ] ----------------------
class SqliteDB {
  // VARIABLE GLOBAL DE LA BASE DE DATOS
  Database dbGlobal;

  // INICIALIZACION DE LA BASE DE DATOS Y LA CONECCIÓN
  iniciarDB() async {
    dbGlobal = await openDatabase(
      'agroventas.db',
      version: 1,
      onCreate: (Database db, int version) {
        db.execute("CREATE TABLE AppConfiguracion (id INTEGER PRIMARY KEY AUTOINCREMENT, notificacionID TEXT NOT NULL DEFAULT '--')");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[0] + " (Id INTEGER PRIMARY KEY AUTOINCREMENT, Data TEXT NOT NULL DEFAULT '--', Accion TEXT NOT NULL DEFAULT '--', Tabla TEXT NOT NULL DEFAULT '--')");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[1] + " (id INTEGER PRIMARY KEY AUTOINCREMENT, idString INTEGER NOT NULL DEFAULT 0, idUsuario INTEGER NOT NULL DEFAULT 0, usuarioNombre TEXT NOT NULL DEFAULT '--', securityID TEXT NOT NULL DEFAULT '--', securityRestablecerID TEXT NOT NULL DEFAULT '--', correo TEXT NOT NULL DEFAULT '--', nombre TEXT NOT NULL DEFAULT '--', logeado NUMERIC NOT NULL DEFAULT 0, bdSincronizada NUMERIC NOT NULL DEFAULT 0, sinAutomatico NUMERIC NOT NULL DEFAULT 0, tipoUsuario TEXT NOT NULL DEFAULT '--', dollarCredito REAL NOT NULL DEFAULT 0, dollarContado REAL NOT NULL DEFAULT 0)");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[2] + " (Id INTEGER PRIMARY KEY NOT NULL, RazonSocial TEXT NOT NULL DEFAULT '--', RFC TEXT NOT NULL DEFAULT '--', Calle TEXT NOT NULL DEFAULT '--', NumInt TEXT NOT NULL DEFAULT '--', NumExt TEXT NOT NULL DEFAULT '--', Colonia TEXT NOT NULL DEFAULT '--', Localidad TEXT NOT NULL DEFAULT '--', Municipio TEXT NOT NULL DEFAULT '--', Estado TEXT NOT NULL DEFAULT '--', Pais TEXT NOT NULL DEFAULT '--', CP INTEGER NOT NULL DEFAULT 0, NombreContacto TEXT NOT NULL DEFAULT '--', Telefono REAL NOT NULL DEFAULT 0, UsoCFDI TEXT NOT NULL DEFAULT '--', MetodoPago TEXT NOT NULL DEFAULT '--', FormaPago TEXT NOT NULL DEFAULT '--', DiasCredito INTEGER NOT NULL DEFAULT 0, LineaCredito REAL NOT NULL DEFAULT 0, Estatus INTEGER NOT NULL DEFAULT 0)");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[3] + " (IdCliente INTEGER NOT NULL, NombreCampo TEXT NOT NULL DEFAULT '--', Ubicacion TEXT NOT NULL DEFAULT '--')");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[4] + " (IdCliente INTEGER NOT NULL, Correo TEXT NOT NULL DEFAULT '--')");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[5] + " (Id INTEGER PRIMARY KEY NOT NULL, NombreRepartidor TEXT NOT NULL DEFAULT '--', Correo TEXT NOT NULL DEFAULT '--', Estatus INTEGER NOT NULL DEFAULT 0)");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[6] + " (Id INTEGER PRIMARY KEY NOT NULL, NombreProducto TEXT NOT NULL DEFAULT '--', Estatus INTEGER NOT NULL DEFAULT 0)");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[7] + " (IdProducto INTEGER NOT NULL, NombrePresentacion TEXT NOT NULL DEFAULT '--', Precio REAL NOT NULL DEFAULT 0, IVA INTEGER NOT NULL DEFAULT 0, IEPS INTEGER NOT NULL DEFAULT 0, Moneda INTEGER NOT NULL DEFAULT 0)");
        db.execute("CREATE TABLE " + VGlobales.sqliteTablas[8] + " (Id INTEGER PRIMARY KEY NOT NULL, NumeroOrden INTEGER NOT NULL DEFAULT 0, IdTipoDocumento INTEGER NOT NULL DEFAULT 0, TipoDocumento TEXT NOT NULL DEFAULT '--', IdTipoCliente INTEGER NOT NULL DEFAULT 0, TipoCliente TEXT NOT NULL DEFAULT '--', IdCliente INTEGER NOT NULL DEFAULT 0, Cliente TEXT NOT NULL DEFAULT '--', Campo TEXT NOT NULL DEFAULT '--', Ubicacion TEXT NOT NULL DEFAULT '--', Total REAL NOT NULL DEFAULT 0, Estatus INTEGER NOT NULL DEFAULT 0, FechaEntrega TEXT NOT NULL DEFAULT '--')");
      }
    );
    // VERIFICACION INICIAL DE LOGGIN
    var verifLogeoInicial = await dbGlobal.rawQuery("SELECT * FROM Usuario WHERE idString = 'u5U4r10+2236'");
    if (verifLogeoInicial.length > 0) {
      verifLogeoInicial.forEach((loggeo) {
        VGlobales.usuarioLogeado = (loggeo["logeado"] > 0) ? 2 : 1;
        VGlobales.nombreUsuario = loggeo["nombre"];
        VGlobales.bdSincronizada = loggeo["bdSincronizada"];
      });
    } else {
      VGlobales.usuarioLogeado = 1;
    }
    // FUNCION QUE GENERA LA CONFIGURACION INICIAL DE LA APP
    var verifAppConfig = await dbGlobal.rawQuery("SELECT * FROM AppConfiguracion");
    if (verifAppConfig.length == 0) {
      dbGlobal.rawInsert("INSERT INTO AppConfiguracion (notificacionID) VALUES (?)", [ cadenaAleatoria(20) ]);
    }
  }

  // ---------------------- [ QUERYS DE USO GENERAL ] ----------------------
  // FUNCION QUE EJECUTA UN QUERY TIPO  --:: CONSULTA ::--
  Future<List<Map<String, dynamic>>> consultarDB(String query) async {
    var resultadoQuery = await dbGlobal.rawQuery(query);
    return resultadoQuery;
  }

  // FUNCION QUE EJECUTA UN QUERY TIPO --:: INSERT ::--
  insertarDB(String query, List<dynamic> valores) async {
    dbGlobal.transaction((txn) async {
      txn.rawInsert(query, valores);
    });
  }

  // FUNCION QUE EJECUTA UN QUERY TIPO --:: UPDATE ::--
  actualizarDB(String query, List<dynamic> valores) async {
    dbGlobal.transaction((txn) async {
      txn.rawUpdate(query, valores);
    });
  }

  // FUNCION QUE EJECUTA UN QUERY TIPO --:: DELETE ::--
  eliminarDB(String query, List<dynamic> valores) async {
    dbGlobal.transaction((txn) async {
      txn.rawDelete(query, valores);
    });
  }
  // ---------------------- [ QUERYS DE USO GENERAL ] ----------------------

  // ---------------------- [ QUERYS DE USO ESPECIFICO ] ----------------------
  // FUNCION QUE DEVUELVE SI EL USUARIO ESTA LOGGEADO
  Future<bool> verificarLoggeo() async {
    var queryLoggeo = await dbGlobal.rawQuery("SELECT * FROM Usuario WHERE idString = 'u5U4r10+2236'");
    if (queryLoggeo.length > 0) {
      bool estaLoggeado = false;
      queryLoggeo.forEach((loggeo) {
        estaLoggeado = (loggeo["logeado"] > 0) ? true : false;
      });
      return estaLoggeado;
    } else {
      return false;
    }
  }

  // FUNCION QUE DEVUELVE SI EXISTE UNA ESTRUCTURA DE USUARIO EN LA BD
  Future<bool> verificarDataUsuario() async {
    var queryLoggeo = await dbGlobal.rawQuery("SELECT * FROM Usuario");
    if (queryLoggeo.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  // FUNCION QUE DEVUELVE LA INFO DEL USUARIO LOGEADO (u5U4r10+2236 <- USUARIO UNICO)
  Future<Map<String, dynamic>> usuarioLogInfo() async {
    var usuarioInfo = await dbGlobal.rawQuery("SELECT * FROM Usuario WHERE idString = 'u5U4r10+2236'");
    Map<String, dynamic> usuarioData = new Map<String, dynamic>();
    usuarioInfo.forEach((info) {
      usuarioData = info;
    });
    return usuarioData;
  }

  // FUNCION QUE DEVUELVE LA INFO LA LA CONFIGURACION DE LA APP (DE MOMENTO SOLO EL ID DE NOTIFICACIONES)
  Future<Map<String, dynamic>> appConfigInfo() async {
    var usuarioInfo = await dbGlobal.rawQuery("SELECT * FROM AppConfiguracion");
    Map<String, dynamic> appData = new Map<String, dynamic>();
    usuarioInfo.forEach((app) {
      appData = app;
    });
    return appData;
  }

  // FUNCION QUE DEVUELVE EL MAXIMO ID DE UNA TABLA CON SU ID DE BUSQUEDA
  Future<int> obtenerMaxId(String tabla, String id) async {
    var maxIdInfo = await dbGlobal.rawQuery("SELECT MAX(" + id + ") AS Max FROM " + tabla);
    int idMax = 0;
    maxIdInfo.forEach((max) {
      if (max["Max"] != null) {
        idMax = max["Max"];
      }
    });
    return idMax + 1;
  }

  // FUNCION QUE VERIFICA SI EXISTEN PENDIENTES DE SUBIR INFO AL SERVIDOR
  Future<bool> verifPendientesBD() async {
    var bdPendientes = await dbGlobal.rawQuery("SELECT COUNT(Id) AS Contar FROM BDPendientes");
    int contBD = 0;
    bdPendientes.forEach((pendiente) {
      contBD = pendiente["Contar"];
    });
    if (contBD > 0) {
      return true;
    } else {
      return false;
    }
  }

  // FUNCION QUE SINCRONIZA LA BD DE LA APLICACION CON LA INFORMACION DEL SERVIDOR
  Future<void> sincronizarBD(Map<String, dynamic> dataWS, Function (String)respBD) async {
    try {
      await dbGlobal.transaction((txn) async {
        List<dynamic> clientes = dataWS["Clientes"];
        List<dynamic> campos = dataWS["Campos"];
        List<dynamic> correos = dataWS["CorreosClientes"];
        /*List<dynamic> repartidores = dataWS["Repartidores"];
        List<dynamic> productos = dataWS["Productos"];
        List<dynamic> presentaciones = dataWS["Presentaciones"];*/
        clientes.forEach((cliente) {
          txn.rawInsert("INSERT INTO Clientes (Id,RazonSocial,RFC,Calle,NumInt,NumExt,Colonia,Localidad,Municipio,Estado,Pais,CP,NombreContacto,Telefono,UsoCFDI,MetodoPago,FormaPago,DiasCredito,LineaCredito,Estatus) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [
              cliente["Id"],
              cliente["RazonSocial"],
              cliente["RFC"],
              cliente["Calle"],
              cliente["NumInt"],
              cliente["NumExt"],
              cliente["Colonia"],
              cliente["Localidad"],
              cliente["Municipio"],
              cliente["Estado"],
              cliente["Pais"],
              cliente["CP"],
              cliente["NombreContacto"],
              cliente["Telefono"],
              cliente["UsoCFDI"],
              cliente["MetodoPago"],
              cliente["FormaPago"],
              cliente["DiasCredito"],
              cliente["LineaCredito"],
              cliente["Estatus"]
            ]
          );
        });
        campos.forEach((campo) {
          txn.rawInsert("INSERT INTO Campos (IdCliente,NombreCampo,Ubicacion) VALUES (?,?,?)",[ campo["IdCliente"], campo["NombreCampo"], campo["Ubicacion"] ]);
        });
        correos.forEach((correo) {
          txn.rawInsert("INSERT INTO CorreosClientes (IdCliente,Correo) VALUES (?,?)",[ correo["IdCliente"], correo["Correo"] ]);
        });

        txn.rawUpdate("UPDATE Usuario SET bdSincronizada=? WHERE idString=?", [ true, "u5U4r10+2236" ]);
      }).catchError((onError) {
        throw new Exception(onError.toString());
      }).then((_) {
        respBD("true");
      });
    } catch (error) {
      respBD(error.toString());
    }
  }

  // FUNCION QUE RESTAURA TODA LA BD DE LA APLICACION (LIMPIAR)
  Future<void> restaurarBD(Function (String)restBD) async {
    try {
      dbGlobal.transaction((txn) async {
        for(var i = 0; i < VGlobales.sqliteTablas.length; i++) {
          txn.rawDelete("DELETE FROM " + VGlobales.sqliteTablas[i]);
        }
      });
      restBD("true");
    } catch (error) {
      restBD(error.toString());
    }
  }
  // ---------------------- [ QUERYS DE USO GENERAL ] ----------------------
}
// --------------------------------------------------------------------------
// +++++++++++++++ ::::::::::::::::::: [] ::::::::::::::::::: +++++++++++++++