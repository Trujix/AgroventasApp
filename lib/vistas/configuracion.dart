// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';
import 'package:agroventasapp/auxiliares/apifunciones.dart';



// FUNCION INICIAL QUE DEVUELVE EL WIDGET PRINCIPAL DEL MENU CONFIGURACION
class Configuracion extends StatefulWidget {
  Configuracion({Key key}) : super(key: configKey);
  @override
  ConfiguracionEstado createState() => new ConfiguracionEstado();
}

// FUNCION INICIAL QUE DEVUELVE EL ESTADO DEL WIDGET PRINCIPAL DEL MENU CONFIGURACION
class ConfiguracionEstado extends State<Configuracion> {
  // FUNCION QUE MANEJA EL CAMBIO DEL SWITCH
  void cambiarSwitchDatos(bool switchval) async {
    setState(() {
      VGlobales.ejecSwitch = switchval;
    });
    await ConfigMenuDatos().actSincAutomatico(switchval, (sincaut) {
      if (sincaut) {
        btnSincAutomatica(1, false);
      }
    });
  }

  // FUNCION QUE MANEJA LA SINCRONIZACION CON EL SERVIDOR
  void sincroniarServidor() async {
    await ConfigMenuDatos().actSincManual((act) {
      if (act) {
        setState(() {
          btnSincAutomatica(1, false);
        });
      }
    });
  }
  
  // FUNCION QUE CAMBIA EL STATUS DEL BOTON DE ACTUALIZACION AUTOMATICA
  void btnSincAutomatica(int tipo, bool state) {
    if (state) {
      setState(() {
        if (tipo > 0) {
          VGlobales.btnTxtSincServidor = "  Sincronizado con el servidor";
          VGlobales.btnClrSincServidor = Color.fromRGBO(40, 167, 69, 1);
          VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidCheckCircle;
          VGlobales.appSincronizada = true;
        } else {
          VGlobales.btnTxtSincServidor = " Sincronizar con el Servidor";
          VGlobales.btnClrSincServidor = Color.fromRGBO(220, 53, 69, 1);
          VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidTimesCircle;
          VGlobales.appSincronizada = false;
        }
      });
    } else {
      if (tipo > 0) {
        VGlobales.btnTxtSincServidor = "  Sincronizado con el servidor";
        VGlobales.btnClrSincServidor = Color.fromRGBO(40, 167, 69, 1);
        VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidCheckCircle;
        VGlobales.appSincronizada = true;
      } else {
        VGlobales.btnTxtSincServidor = " Sincronizar con el Servidor";
        VGlobales.btnClrSincServidor = Color.fromRGBO(220, 53, 69, 1);
        VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidTimesCircle;
        VGlobales.appSincronizada = false;
      }
    }
  }

  // WIDGET PRINCIPAL
  @override
  Widget build(BuildContext contextConfig) {
    contextGlobal = contextConfig;
    return FutureBuilder<void>(
      future: initConfiguracion(),
      builder: (contextConfig, AsyncSnapshot<void> snapshot) {
        return DefaultTabController(
          length: 3,
          child: new Scaffold(
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: new Container(
                color: GEstilos.agroVerde,
                child: new SafeArea(
                  child: Column(
                    children: <Widget>[
                      new Expanded(child: new Container()),
                      new TabBar(
                        indicatorColor: Colors.white,
                        tabs: [
                          Tab(icon: Icon(FontAwesomeIcons.database)),
                          Tab(icon: Icon(FontAwesomeIcons.infoCircle)),
                          Tab(icon: Icon(FontAwesomeIcons.cog)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: new TabBarView(
              children: <Widget>[
                ConfigMenuDatos().menu(cambiarSwitchDatos, sincroniarServidor), // MENU DATOS
                ConfigMenuAgente().menu(), // MENU AGENTE
                ConfigMenuOtros().menu(), // MENU OTROS
              ],
            ),
          ),
        );
      },
    );
  }
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ----------- [ CONTROLADORES DE FORMULARIO - DATOS ] -----------
TextEditingController desactDispInput = new TextEditingController();
FocusNode desactDispInputF = new FocusNode();
// ------------------------- [ +++ DATOS +++ ] -------------------------
class ConfigMenuDatos {
  // :::::::::::::::::::::::: [ WIDGETS ] ::::::::::::::::::::::::
  // WIDGET QUE DEVUELVE EL MENU DEL DATOS
  Widget menu(Function (bool switchBool)switchAccion, Function sincronizarServidor) {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: ListView(
        children: <Widget>[
          Text(
            'Sincronización Automática\n',
            style: GEstilos.txtTitulo,
          ),
          Text(
            'Nota: Le recomendamos ampliamente mantener esta opción habilitada. De lo contrario, tendría que asegurarse que actualize periodicamente la información nueva con el servidor; ya que es posible que dicha información se pierda, ya sea si, su dispositivo se dañe, extravíe o, desinstale la aplicación.\n',
            style: GEstilos.txtDescripcion,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Sincronizar automáticamente con el servidor',
                  style: GEstilos.txtNDescripcion,
                ),
              ),
              Switch(
                value: VGlobales.ejecSwitch,
                activeColor: GEstilos.agroVerde,
                onChanged: (value) {
                  switchAccion(value);
                },
              )
            ],
          ),
          Text(
            '\n\nSincronización Manual\n',
            style: GEstilos.txtTitulo,
          ),
          Text(
            'Para esta acción requiere conección a Internet.\n',
            style: GEstilos.txtDescripcion,
          ),
          RaisedButton(
            color: VGlobales.btnClrSincServidor,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  VGlobales.btnIcnSincServidor,
                  size: 14,
                ),
                new Text(
                  VGlobales.btnTxtSincServidor,
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () {
              sincronizarServidor();
            },
          ),
          Text(
            '\n\nDescargar Datos del Servidor\n',
            style: GEstilos.txtTitulo,
          ),
          Text(
            'Esta acción es recomendada la primera vez que inicia sesión en un dispositivo nuevo.\nAtención: La información almacenada en este dispositivo será sustituida por la guardada en el servidor.\n',
            style: GEstilos.txtDescripcion,
          ),
          RaisedButton(
            color: GEstilos.btnInfo,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.cloud,
                  size: 14,
                ),
                new Text(
                  '  Actualizar Aplicación',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () async {
              Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
              msgPrimario("titulo", usuarioInfo["sinAutomatico"].toString(), "tn");
            },
          ),
          Text(
            '\n\nDesactivar Dispositivo\n',
            style: GEstilos.txtTitulo,
          ),
          Text(
            'Para esta opción requiere conección a Internet y verificar su contraseña.\nAl desactivar su dispositivo podrá iniciar sesión en uno nuevo. Si 2 o más dispositivos se encuentran simultáneamente usando la misma sesión, la información puede verse corrompida o con errores graves; así que, para su seguridad y mantener la integridad de su información, es recomendable desactivar este dispositivo para comenzar a utilizar otro, o si desea desinstalar la aplicación.\n',
            style: GEstilos.txtDescripcion,
          ),
          TextFormField(
            controller: desactDispInput,
            focusNode: desactDispInputF,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Escriba su contraseña',
              hintStyle: TextStyle(
                color: GEstilos.cMarcador,
              ),
            ),
            style: TextStyle(
              color: GEstilos.agroVerde,
              fontSize: 18
            ),
          ),
          Text(' ',),
          RaisedButton(
            color: GEstilos.btnError,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.powerOff,
                  size: 14,
                ),
                new Text(
                  '  Desactivar Dispositivo',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () async {
              await prevDesactivarDispositivo();
            },
          ),
        ],
      ),
    );
  }
  // :::::::::::::::::::::::: [ FUNCIONES ] ::::::::::::::::::::::::
  // FUNCION QUE ACTUALIZA LA SINCORNIZACION AUTOMATICA (A TRAVES DEL SWITCH)
  Future<void> actSincAutomatico(bool act, Function (bool)sincaut) async {
    if (!VGlobales.iniciarParams) {
      await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET sinAutomatico=? WHERE idString=?", [act, 'u5U4r10+2236']);
      if (act) {
        loadingAbrir("Sincronizando...");
        if (await InertetConn.verificar()) {
          await sincronizarServidor((sinc) {
            loadingCerrar((l) {
              sincaut(sinc);
            });
          });
        } else {
          loadingCerrar((l) {
            sincaut(false);
          });
        }
      }
    }
  }

  // FUNCION QUE ACTUALIZA LA APLICACION (ACCION MANUAL)
  Future<void> actSincManual(Function (bool)act) async {
    if (!VGlobales.appSincronizada) {
      loadingAbrir("Sincronizando...");
      if (await InertetConn.verificar()) {
        await sincronizarServidor((sinc) {
          loadingCerrar((l) {
            act(sinc);
          });
        });
      } else {
        loadingCerrar((l) {
          msgPrimario("Atención!", "Requiere conección a Internet para esta acción.", "Aceptar");
          act(false);
        });
      }
    }
  }

  // FUNCION PREVIA AL DESACTIVAR DISPOSITIVO (CONSULTA SI EXISTEN PENDIENTES DE INFO PARA ENVIAR AL SERVIDOR)
  Future<void> prevDesactivarDispositivo() async {
    if (await VGlobales.dbSqliteCon.verifPendientesBD()) {
      msgPregunta("Advertencia!", "Tiene información pendiente para enviar al servidor y se borrará\n¿Desea continuar?", "Si", "Cancelar", (si) async {
        if (si) {
          await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET sinAutomatico=? WHERE idString=?", [true, 'u5U4r10+2236']);
          await desactivarDispositivo();
        }
      });
    } else {
      await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET sinAutomatico=? WHERE idString=?", [true, 'u5U4r10+2236']);
      await desactivarDispositivo();
    }
  }

  // FUNCION QUE DESACTIVA EL DISPOSITIVO
  Future<void> desactivarDispositivo() async {
    if (validarPassDesacDisp()) {
      loadingAbrir("Desactivando disp...");
      if (await InertetConn.verificar()) {
        verificarLoggin(desactDispInput.text, (loggin) async {
          if (loggin) {
            Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
            Map desactivarData = {
              "SecurityRestablecerID": usuarioInfo["securityRestablecerID"]
            };
            Map dataWS = {
              "Accion": "Desactivar",
              "Tabla": "Usuarios",
              "Data": json.encode(desactivarData)
            };
            await enviarDataWS(dataWS, (ws) async {
              if (ws == "true") {
                await VGlobales.dbSqliteCon.restaurarBD((restbd) {
                  if (restbd == "true") {
                    loadingCerrar((l) {
                      mainKey.currentState.cambiarHomeApp(1);
                    });
                  } else {
                    loadingCerrar((l) {
                      msgPrimario("Error!", "Ocurrió un problema al desactivar dispositivo: - " + restbd, "Aceptar");
                    });
                  }
                });
              }
            });
          } else {
            loadingCerrar((l) {
              msgPrimario("Error!", "La contraseña es incorrecta.", "Aceptar");
            });
          }
        });
      } else {
        loadingCerrar((l) {
          msgPrimario("Atención!", "Requiere conección a Internet para esta acción.", "Aceptar");
        });
      }
    }
  }

  // FUNCION QUE VALIDA LA CONTRASEÑA DEL USUARIO AL DESACTIVAR DISPOSITIVO
  bool validarPassDesacDisp() {
    if (desactDispInput.text == "") {
      msgCorto("Coloque contraseña", 0);
      FocusScope.of(contextGlobal).requestFocus(desactDispInputF);
      return false;
    } else {
      return true;
    }
  }
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ----------- [ CONTROLADORES DE FORMULARIO - AGENTE ] -----------
TextEditingController agenteNombreInput = new TextEditingController();
FocusNode agenteNombreInputF = new FocusNode();
TextEditingController agenteCorreoInput = new TextEditingController();
FocusNode agenteCorreoInputF = new FocusNode();
TextEditingController nuevoPassInput = new TextEditingController();
FocusNode nuevoPassInputF = new FocusNode();
TextEditingController antPassInput = new TextEditingController();
FocusNode antPassInputF = new FocusNode();
TextEditingController comfPassInput = new TextEditingController();
FocusNode comfPassInputF = new FocusNode();
// ------------------------- [ +++ AGENTE +++ ] -------------------------
class ConfigMenuAgente {
  // :::::::::::::::::::::::: [ WIDGETS ] ::::::::::::::::::::::::
  // WIDGET QUE DEVUELVE EL MENU DEL AGENTE
  Widget menu() {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: ListView(
        children: <Widget>[
          Text(
            'Datos del Agente\n',
            style: GEstilos.txtTitulo,
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.solidAddressCard,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text('    '),
              Expanded(
                child: TextFormField(
                  controller: agenteNombreInput,
                  focusNode: agenteNombreInputF,
                  decoration: InputDecoration(
                    hintText: 'Nombre del Agente',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.at,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text('    '),
              Expanded(
                child: TextFormField(
                  controller: agenteCorreoInput,
                  focusNode: agenteCorreoInputF,
                  decoration: InputDecoration(
                    hintText: 'Correo Electrónico',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Text('\n'),
          RaisedButton(
            color: GEstilos.btnInfo,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.save,
                  size: 14,
                ),
                new Text(
                  '  Guardar Info. Agente',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () {
              guardarFormAgente();
            },
          ),
          Text(
            '\n\nCambiar Contraseña\n',
            style: GEstilos.txtTitulo,
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.lock,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text('    '),
              Expanded(
                child: TextFormField(
                  controller: antPassInput,
                  focusNode: antPassInputF,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Antigua Contraseña',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.lockOpen,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text('    '),
              Expanded(
                child: TextFormField(
                  controller: nuevoPassInput,
                  focusNode: nuevoPassInputF,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Nueva Contraseña',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.lockOpen,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text('    '),
              Expanded(
                child: TextFormField(
                  controller: comfPassInput,
                  focusNode: comfPassInputF,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirmar Contraseña',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Text('\n'),
          RaisedButton(
            color: GEstilos.btnAtencion,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.save,
                  size: 14,
                ),
                new Text(
                  '  Cambiar Contraseña',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () {
              cambiarPassAgente();
            },
          ),
          Text(
            '\n\nCerrar Sesión',
            style: GEstilos.txtTitulo,
          ),
          Text(
            '\nAtención: Esta opción solo le permitirá cerrar la sesión, sin eliminar la información actual.',
            style: GEstilos.txtDescripcion,
          ),
          RaisedButton(
            color: GEstilos.btnError,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.powerOff,
                  size: 14,
                ),
                new Text(
                  '  Cerrar Sesión',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () {
              agenteCerrarSesion();
            },
          ),
        ],
      ),
    );
  }  

  // :::::::::::::::::::::::: [ FUNCIONES ] ::::::::::::::::::::::::
  // ------------------- [ MODIFICAR DATOS AGENTE ] -------------------
  // FUNCION QUE GUARDA LA INFO DEL AGENTE
  Future<void> guardarFormAgente() async {
    try {
      if (validarFormAgente()) {
        noFocus();
        loadingAbrir("Guardando...");
        Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
        Map usuarioData = {
          "Nombre": agenteNombreInput.text,
          "Correo": agenteCorreoInput.text
        };
        Map dataWS = {
          "Accion": "Modificar",
          "Tabla": "Usuarios",
          "Data": json.encode(usuarioData)
        };
        await enviarDataWS(dataWS, (ws) async {
          await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET Nombre=?,Correo=? WHERE IdString=?", [ agenteNombreInput.text, agenteCorreoInput.text, "u5U4r10+2236" ]);
          principalKey.currentState.nombreUsuario(agenteNombreInput.text);
          if (usuarioInfo["sinAutomatico"] == 0 || !await InertetConn.verificar()) {
            configKey.currentState.btnSincAutomatica(0, true);
          }
          await loadingCerrar((l) {
            msgPrimario("Éxito!", "Cambios guardados correctamente.", "Aceptar");
          });
        });
      }
    } catch (error) {
      await loadingCerrar((l) {
        msgPrimario("Error!", "Ocurrió un problema al guardar cambios: - " + error.toString(), "Aceptar");
      });
    }
  }
  // FUNCION QUE VALIDA EL FORMULARIO DE INFO DEL AGENTE
  bool validarFormAgente() {
    bool respuesta = true;
    if (agenteNombreInput.text == '') {
      msgCorto("Coloque el Nombre", 0);
      FocusScope.of(contextGlobal).requestFocus(agenteNombreInputF);
      respuesta = false;
    } else if (agenteCorreoInput.text == '') {
      msgCorto("Coloque el Correo", 0);
      FocusScope.of(contextGlobal).requestFocus(agenteCorreoInputF);
      respuesta = false;
    }
    return respuesta;
  }

  // ------------------- [ CAMBIAR CONTRASEÑA ] -------------------
  // FUNCION QUE GUARDA EL CAMBIO DE CONTRASEÑA
  Future<void> cambiarPassAgente() async {
    if (validarFormCambiarPass()) {
      try {
        noFocus();
        loadingAbrir("Actualizando...");
        await verificarLoggin(antPassInput.text, (loggin) async {
          if (loggin) {
            Map usuarioData = {
              "SecurityID": nuevoPassInput.text
            };
            Map cambioPass = {
              "Accion": "Password",
              "Tabla": "Usuarios",
              "Data": json.encode(usuarioData)
            };
            await enviarDataWS(cambioPass, (ws) async {
              if (ws == "true") {
                await loadingCerrar((l) {
                  antPassInput.clear();
                  nuevoPassInput.clear();
                  comfPassInput.clear();
                  msgPrimario("Éxito!", "Contraseña actualizada correctamente.", "Aceptar");
                });
              } else {
                await loadingCerrar((l) {
                  msgPrimario("Atención!", "Ocurrió un problema al actualizar contraseña. Inténtelo más tarde.", "Aceptar");
                });
              }
            });
          } else {
            await loadingCerrar((l) {
              msgPrimario("Error!", "La antigua contraseña es incorrecta.", "Aceptar");
            });
          }
        });
      } catch (error) {
        await loadingCerrar((l) {
          msgPrimario("Error!", "Ocurrió un problema al actualizar la contraseña: - " + error.toString(), "Aceptar");
        });
      }
    }
  }
  // FUNCION QUE VALIDA EL FORMULARIO DE CAMBIO DE CONTRASEÑA
  bool validarFormCambiarPass() {
    bool respuesta = true;
    if (antPassInput.text == '') {
      msgCorto("Coloque antigua contraseña", 0);
      FocusScope.of(contextGlobal).requestFocus(antPassInputF);
      respuesta = false;
    } else if (nuevoPassInput.text == '') {
      msgCorto("Coloque nueva contraseña", 0);
      FocusScope.of(contextGlobal).requestFocus(nuevoPassInputF);
      respuesta = false;
    } else if (comfPassInput.text == '') {
      msgCorto("Coloque confirmar contraseña", 0);
      FocusScope.of(contextGlobal).requestFocus(comfPassInputF);
      respuesta = false;
    } else if (nuevoPassInput.text != comfPassInput.text) {
      msgPrimario("Atención!", "Las contraseñas no coinciden", "Aceptar");
      FocusScope.of(contextGlobal).requestFocus(nuevoPassInputF);
      respuesta = false;
    }
    return respuesta;
  }

  // ------------------- [ CAMBIAR CONTRASEÑA ] -------------------
  // FUNCION QUE CIERRA LA SESIÓN DE LA APLICACIÓN (SOLO CIERRA LOCALMENTE)
  void agenteCerrarSesion() async {
    msgPregunta("Cerar Sesión", "¿Desea continuar?", "Aceptar", "Cancelar", (si) async {
      try {
        if (si) {
          await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET logeado=? WHERE idString=?", [ false, "u5U4r10+2236" ]);
          mainKey.currentState.cambiarHomeApp(1);
        }
      } catch (error) {
        msgPrimario("Error!", "Ocurrió un problema - " + error.toString(), "Aceptar");
      }
    });
  }
}

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ----------- [ CONTROLADORES DE FORMULARIO - OTROS ] -----------
TextEditingController dllCreditoInput = new TextEditingController();
FocusNode dllCreditoInputF = new FocusNode();
TextEditingController dllContadoInput = new TextEditingController();
FocusNode dllContadoInputF = new FocusNode();
// ------------------------- [ +++ OTROS +++ ] -------------------------
class ConfigMenuOtros {
  // WIDGET QUE DEVUELVE EL MENU OTROS
  Widget menu() {
    return new Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.moneyBillAlt,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text(
                '   Dollar Crédito:    ',
                style: GEstilos.txtEtiqueta,
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: dllCreditoInput,
                  focusNode: dllCreditoInputF,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.moneyBillAlt,
                size: 22,
                color: GEstilos.agroVerde,
              ),
              Text(
                '   Dollar Contado:   ',
                style: GEstilos.txtEtiqueta,
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: dllContadoInput,
                  focusNode: dllContadoInputF,
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                ),
              ),
            ],
          ),
          Text('\n'),
          RaisedButton(
            color: GEstilos.btnExito,
            textColor: Colors.white,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Icon(
                  FontAwesomeIcons.save,
                  size: 14,
                ),
                new Text(
                  '  Guardar Información',
                  style: TextStyle(
                    fontSize: 18,
                  )
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20),
            ),
            onPressed: () {
              guardarOtrasConfigs();
            },
          ),
        ]
      ),
    );
  }

  // :::::::::::::::::::::::: [ FUNCIONES ] ::::::::::::::::::::::::
  // FUNCION QUE GUARDA OTRAS CONFIGURACIONES
  Future<void> guardarOtrasConfigs() async {
    if (validarFormOtros()) {
      noFocus();
      loadingAbrir("Guardando...");
      await loadingCerrar((l) {
        VGlobales.dbSqliteCon.insertarDB("UPDATE Usuario SET DollarContado=?,DollarCredito=? WHERE IdString=?", [ double.parse(dllContadoInput.text), double.parse(dllCreditoInput.text), "u5U4r10+2236" ]);
        msgPrimario("Éxito!", "Configuración actualizada", "Aceptar");
      });
    }
  }
  // FUNCION QUE VALIDA EL FORMULARIO DE INFO DEL AGENTE
  bool validarFormOtros() {
    bool respuesta = true;
    if (dllCreditoInput.text == '') {
      msgCorto("Coloque Dollar Crédito", 0);
      FocusScope.of(contextGlobal).requestFocus(dllCreditoInputF);
      respuesta = false;
    } else if (dllContadoInput.text == '') {
      msgCorto("Coloque Dollar Contado", 0);
      FocusScope.of(contextGlobal).requestFocus(dllContadoInputF);
      respuesta = false;
    }
    return respuesta;
  }
}


// -------------------- [ +++ FUNCIONES GENERALES +++ ] --------------------
// FUNCION INICIAL DEL SUBMENU CONFIGURACION
Future<void> initConfiguracion() async {
  if (VGlobales.iniciarParams) {
    Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
    bool verifPendientes = await VGlobales.dbSqliteCon.verifPendientesBD();
    // DATOS
    VGlobales.ejecSwitch = (usuarioInfo["sinAutomatico"] > 0) ? true : false;
    desactDispInput = new TextEditingController(text: "");
    // AGENTE
    agenteNombreInput = new TextEditingController(text: usuarioInfo["nombre"]);
    agenteCorreoInput = new TextEditingController(text: usuarioInfo["correo"]);
    antPassInput = new TextEditingController(text: "");
    nuevoPassInput = new TextEditingController(text: "");
    comfPassInput = new TextEditingController(text: "");
    // OTROS
    dllCreditoInput = new TextEditingController(text: usuarioInfo["dollarCredito"].toStringAsFixed(2));
    dllContadoInput = new TextEditingController(text: usuarioInfo["dollarContado"].toStringAsFixed(2));
    if (verifPendientes) {
      VGlobales.btnTxtSincServidor = " Sincronizar con el Servidor";
      VGlobales.btnClrSincServidor = Color.fromRGBO(220, 53, 69, 1);
      VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidTimesCircle;
      VGlobales.appSincronizada = false;
    }
    VGlobales.iniciarParams = false;
  }
}