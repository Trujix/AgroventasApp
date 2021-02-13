// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';
import 'package:agroventasapp/auxiliares/apifunciones.dart';
import 'package:agroventasapp/login.dart';
import 'package:agroventasapp/principal.dart';



// FUNCION MAIN INICIAL QUE ARRANCA LA MATERIALAPP PRINCIPAL (MODO PORTRAIT SOLAMENTE)
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

// CLASE INICIAL QUE DECLARA EL WIDGET PRINCIPAL
class MyApp extends StatefulWidget {
  MyApp({ Key key }) : super(key: mainKey);
  @override
  MyAppEstado createState() => MyAppEstado();
}

// CLASE INICIAL QUE DECLARA EL ESTADO QUE MANIPULA EL WIDGET PRINCIPAL
class MyAppEstado extends State<MyApp> with WidgetsBindingObserver {
  // VARIABLES INCIALES GLOBALES
  InertetConn _vuelveConectividad = InertetConn.instance;
  
  // FUNCION INICIAL DEL WIDGET DE LA APP PRINCIPAL
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _vuelveConectividad.inicializar();
    _vuelveConectividad.myStream.listen((source) async {
      if (VGlobales.sincServidorInicial && source) {
        await sincronizarServidorAuto((estadoAppGlobal == AppLifecycleState.resumed) ? true : false);
      } else {
        Future.delayed(Duration(seconds: 3)).then((v) {
          VGlobales.sincServidorInicial = true;
        });
      }
    });
  }

  // LIBERA LA INSTANCIA DE VERIFICACION SI LA APP ESTA EN BACKGROUND, PAUSA O ABIERTA
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // FUNCION QUE DETECTA EL CAMBIO DE LA APP DE OCULTA / ACTIVA
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() { estadoAppGlobal = state; });
  }

  // FUNCION QUE HACE UN CAMBIO DE ESTADO PARA NAVEGAR SOBRE LAS PAGINAS (LOGIN Y PRINCIPAL)
  void cambiarHomeApp(int homeapp) {
    setState(() {
      VGlobales.usuarioLogeado = homeapp;
    });
  }

  // WIDGET PRINCIPAL
  @override
  Widget build(BuildContext contextApp) {
    contextGlobal = contextApp;
    return MaterialApp(
      title: 'AgroVentas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        future: VGlobales.dbSqliteCon.iniciarDB(),
        builder: (BuildContext context, snapshot) {
          if (VGlobales.usuarioLogeado == 1) {
            return LoginPagina();
          } else if (VGlobales.usuarioLogeado == 2) {
            return PaginaPrincipal();
          } else {
            return LoaderFijo();
          }
        },
      )
    );
  }
}