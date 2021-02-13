// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/apifunciones.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';



// ----------------- [ CLASE PRINCIPAL QUE RETORNA LA VISTA DE LOGIN ] -----------------
class LoginPagina extends StatefulWidget {
  @override
  LoginEstado createState() => new LoginEstado();
}

// ----------------- [ CLASE PRINCIPAL EXTIENDE LA VISTA DE LOGIN ] -----------------
class LoginEstado extends State<LoginPagina> {
  // FUNCION INCIAL DEL ESTADO DEL WIDGET DE LOGIN
  @override
  void initState() {
    super.initState();
    loginInicio();
  }

  // FUNCION QUE INICIA SESIÓN (INCLUIDA VARIABLE DE LOADING)
  bool loader = false;
  void iniciarSesion() async {
    if(validarLoginForm()) {
      try {
        noFocus();
        setState(() { loader = true; });
        await iniciarSesionAccion((fin) => setState(() { loader = false; }));
      } catch(error) {
        setState(() { loader = false; });
        msgPrimario("Error!", "Ocurió un problema: - " + error.toString(), "Aceptar");
      }
    }
  }

  // WIDGET PRINCIPAL
  @override
  Widget build(BuildContext contextLogin) {
    contextGlobal = contextLogin;
    return new WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: loader ? Loader() : Scaffold(
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: GEstilos.agroVerde,
            image: DecorationImage(
              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
              image: AssetImage(
                'assets/imgs/fondologin.png'
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            children: <Widget>[
              logoLogin(), // IMAGEN LOGO
              usuarioInputLogin(), // USUARIO INPUT
              passwordInputLogin(), // PASSWORD INPUT
              botonLogin(iniciarSesion/*agregarTexto*/), // BOTON LOGIN
              txtRecuperarPass(), // TEXTO DE RECUPERAR PASS
            ]
          )
        ),
      ),
    );
  }
}

// ----------- [ WIDGETS Y CONTROLADORES POR SEPARADO - (ICONO, INPUT USUARIO, INPUT CONTRASEÑA Y BOTON) ] -----------
// --------------- [ CONTROLADORES DE FORMULARIO DE LOGIN ] ---------------------
TextEditingController usuarioInput = new TextEditingController();
FocusNode usuarioInputF = new FocusNode();
TextEditingController passwordInput = new TextEditingController();
FocusNode passwordInputF = new FocusNode();

// -------------- [ CREACION DE WIDGETS ] --------------
// CREAR WIDGET PARA LA IMAGEN
Widget logoLogin() {
  return Padding(
    padding: const EdgeInsets.only(top: 80),
    child: Image.asset(
      'assets/imgs/icono.png',
      width: 100,
      height: 100,
    ),
  );
}

// CREAR WIDGET TIPO TEXTFIELD DE USUARIO
Widget usuarioInputLogin() {
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: TextFormField(
      controller: usuarioInput,
      focusNode: usuarioInputF,
      decoration: InputDecoration(
        hintText: 'Usuario',
        hintStyle: TextStyle(
          color: GEstilos.cMarcador,
        ),
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 18
      ),
    ),
  );
}

// CREAR WIDGET TIPO TEXTFIELD DE CONTRASEÑA
Widget passwordInputLogin() {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: TextFormField(
      controller: passwordInput,
      focusNode: passwordInputF,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: TextStyle(
          color: GEstilos.cMarcador,
        ),
      ),
      style: TextStyle(
        color: Colors.white,
        fontSize: 18
      ),
    )
  );
}

// CREAR WIDGET TIPO BOTON DE INICIO DE SESIÓN
Widget botonLogin(void funcionBtn()) {
  return Container(
    padding: const EdgeInsets.only(top: 20),
    child: RaisedButton(
      color: GEstilos.btnExito,
      textColor: Colors.white,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Icon(
            FontAwesomeIcons.user,
            size: 14,
          ),
          new Text(
            '  Iniciar Sesión',
            style: TextStyle(
              fontSize: 18,
            )
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(20),
      ),
      onPressed: funcionBtn,
    ),
  );
}

// CREAR WIDGET DE TEXTO QUE PERMITE RECUPERAR LA CONTRASEÑA
Widget txtRecuperarPass(/*void funcionLink()*/) {
  return Container(
    padding: const EdgeInsets.only(top: 20),
    child: GestureDetector(
      child: Text(
        '¿Olvidó su contraseña?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      onTap: () {

      },
    ),
  );
}

// ------------- [ FUNCIONES FUERA DEL SETSTATE ] -------------
// FUNCION INICIAL DEL LOGIN (DENTRO DEL INITSTATE)
void loginInicio() {
  usuarioInput.clear();
  passwordInput.clear();
}

// FUNCION PARA INICIAR SESIÓN (FUERA DEL SETSTATE)
Future<void> iniciarSesionAccion(Function (bool)fin) async {
  try {
    Map appConfigInfo = await VGlobales.dbSqliteCon.appConfigInfo();
    Map usuarioInfo;
    String securityId = "--";
    if (await VGlobales.dbSqliteCon.verificarDataUsuario()) {
      usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
      securityId = usuarioInfo["securityID"];
    }
    Map bodyLogin = {
      'Usuario' : usuarioInput.text,
      'Password' : passwordInput.text,
      'SecurityID': securityId,
      'NotificacionID': appConfigInfo["notificacionID"]
    };
    await apiPOST("/api/applogin/iniciarsesion", bodyLogin, (respuesta) async {
      try {
        Map loginRespuesta = json.decode(respuesta);
        if (loginRespuesta["Respuesta"]) {
          if (await VGlobales.dbSqliteCon.verificarDataUsuario()) {
            List<dynamic> registrarUsuario = [ true, "u5U4r10+2236" ];
            await VGlobales.dbSqliteCon.actualizarDB("UPDATE Usuario SET logeado=? WHERE idString=?", registrarUsuario);
          } else {
            Map usuarioInfo = loginRespuesta["UsuarioInfo"][0];
            List<dynamic> registrarUsuario = [ usuarioInfo["IdString"], usuarioInfo["IdUsuario"], usuarioInfo["UsuarioNombre"], usuarioInfo["SecurityID"], usuarioInfo["SecurityRestablecerID"], usuarioInfo["Correo"], usuarioInfo["Nombre"], true, usuarioInfo["BDSincronizada"], true, "agente", 0, 0 ];
            await VGlobales.dbSqliteCon.insertarDB("INSERT INTO Usuario (idString,idUsuario,usuarioNombre,securityID,securityRestablecerID,correo,nombre,logeado,bdSincronizada,sinAutomatico,tipoUsuario,dollarCredito,dollarContado) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)", registrarUsuario);
          }
          mainKey.currentState.cambiarHomeApp(2);
          fin(true);
        } else {
          if (loginRespuesta["RespuestaTexto"] == "false") {
            fin(false);
            msgPrimario("Error!", "Usuario y/o contraseña incorrectos.", "Aceptar");
          } else if (loginRespuesta["RespuestaTexto"] == "errUsuario") {
            Navigator.push(contextGlobal, MaterialPageRoute(builder: (context) => new Tranza()));
            fin(false);
          }
        }
      } catch (errorInt) {
        fin(false);
        msgPrimario("Error!", "Ocurrió un error en parametros de Inicio de Sesión: - " + errorInt.toString(), "Aceptar");
      }
    });
  } catch (error) {
    fin(false);
    msgPrimario("Error!", "Ocurríó un problema al iniciar sesión: - " + error.toString(), "Aceptar");
  }
}

// FUNCION QUE VALIDA EL FORMULARIO DE LOGIN
bool validarLoginForm() {
  if (usuarioInput.text == '') {
    msgCorto("Coloque el Usuario", 0);
    FocusScope.of(contextGlobal).requestFocus(usuarioInputF);
    return false;
  } else if (passwordInput.text == '') {
    msgCorto("Coloque la Contraseña", 0);
    FocusScope.of(contextGlobal).requestFocus(passwordInputF);
    return false;
  } else {
    return true;
  }
}