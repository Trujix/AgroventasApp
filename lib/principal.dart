// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/apifunciones.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';
import 'package:agroventasapp/vistas/catalogoclientes.dart';
import 'package:agroventasapp/vistas/configuracion.dart';



// FUNCION INICIAL QUE DEVUELVE EL WIDGET PRINCIPAL
class PaginaPrincipal extends StatefulWidget {
  PaginaPrincipal({ Key key }) : super(key: principalKey);
  @override
  PaginaPrincipalEstado createState() => PaginaPrincipalEstado();
}

// FUNCION INICIAL QUE DEVUELVE EL ESTADO DEL WIDGET PRINCIPAL
class PaginaPrincipalEstado extends State<PaginaPrincipal> {
  // FUNCION QUE EJECUTA ACCION AL ELEGIR UNA OPCION DEL MENU DRAWER
  String tituloBarra = "AgroVentas";
  Widget cuerpoMenu = Center(child: Icon(FontAwesomeIcons.mobileAlt, color: Colors.grey, size: 180,),);
  void elegirMenu(titulo, cuerpo) async {
    Navigator.of(this.context).pop();
    noFocus();
    await reiniciarParamsMenu(titulo);
    setState(() {
      tituloBarra = titulo;
      cuerpoMenu = cuerpo;
    });
  }

  // FUNCION QUE COLOCA EL NOMBRE Y TIPO DE USUARIO EN EL MENU
  void nombreUsuario(String nombre) {
    setState(() {
      VGlobales.nombreUsuario = nombre;
    });
  }

  // FUNCION QUE CAMBIA A LA PAGINA PRINCIPAL (SI PREVIAMENTE SE ACTIVÓ SINCRONIZACION DE LA BD)
  void abrirPagPrincipal() {
    setState(() {
      VGlobales.bdSincronizada = 1;
    });
  }

  // WIDGET PRINCIPAL
  @override
  Widget build(BuildContext contextPrincipal) {
    contextGlobal = contextPrincipal;
    return (VGlobales.bdSincronizada > 0) ? WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(tituloBarra),
          backgroundColor: GEstilos.agroVerde,
        ),
        drawer: Drawer(
          child: ListView(
            children: elementosMenu(elegirMenu)
          ),
        ),
        body: cuerpoMenu,
        backgroundColor: Colors.white,
      ),
    ) : WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: GEstilos.agroVerde,
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
          child: ListView(
            children: <Widget>[
              Center(
                child: Icon(FontAwesomeIcons.syncAlt, color: Colors.white, size: 120,),
              ),
              SizedBox(height: 30.0,),
              Container(
                child: Text(
                  "Se requiere conección a Internet para esta acción.\nSe ha detectado información previa sobre este usuario que es necesaria aplicar a este dispositivo. Presione el boton 'Sincronizar Dispositivo' para continuar.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 15.0,),
              RaisedButton(
                color: GEstilos.btnOscuro,
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
                      '  Sincronizar Dispositivo',
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
                  await sincronizarBD();
                },
              ),
            ],
          ),
        ),
      ),
    ); 
  }
}

// ----------------------------- [ CREANDO EL MENU ] -----------------------------
// FUNCION QUE DEVUELVE LOS  ELEMENTOS DEL MENU
List<Widget> elementosMenu(Function funcionMenu) {
  List<Widget> menuElems = new List<Widget>();
  menuElems.add(
    Container(
      height: 120,
      child: UserAccountsDrawerHeader(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imgs/menufondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        accountName: Text(VGlobales.nombreUsuario),
        accountEmail: Text("Agente"),
      ),
    ),
  );
  List<Map> menuElemsLista = [
    { "Icono" : FontAwesomeIcons.shoppingBasket, "Titulo" : "Orden Pedido", "Vista" : new Configuracion() },
    { "Icono" : FontAwesomeIcons.moneyBillAlt, "Titulo" : "Cotización", "Vista" : new Configuracion() },
    { "Icono" : FontAwesomeIcons.truck, "Titulo" : "Entregas", "Vista" : new Configuracion() },
    { "Icono" : FontAwesomeIcons.userAlt, "Titulo" : "Catálogo Clientes", "Vista" : new CatalogoClientes() },
    { "Icono" : FontAwesomeIcons.barcode, "Titulo" : "Catálogo Productos", "Vista" : new Configuracion() },
    { "Icono" : FontAwesomeIcons.solidAddressCard, "Titulo" : "Catálogo Repartidores", "Vista" :new  Configuracion() },
    { "Icono" : FontAwesomeIcons.cog, "Titulo" : "Configuración", "Vista" : new Configuracion() }
  ];
  menuElemsLista.forEach((menuElem) {
    menuElems.add(
      new ListTile(
        onTap: () {
          funcionMenu(menuElem["Titulo"], menuElem["Vista"]);
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              menuElem["Icono"],
              size: 15,
            ),
            new Text(
              '  ' + menuElem["Titulo"],
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.normal,
              ),
            ),
          ],
        ),
      )
    );
  });
  return menuElems;
}

// ------------------- [ FUNCIONES ] -------------------
// FUNCION QUE REESTABLECE PARAMEROS Y VARIABLES INICIALES PARA LOS MENUS
Future<void> reiniciarParamsMenu(String menu) async {
  VGlobales.iniciarParams = true;
  if (menu == "Configuración") {
    VGlobales.appSincronizada = true;
    VGlobales.btnTxtSincServidor = "  Sincronizado con el servidor";
    VGlobales.btnClrSincServidor = Color.fromRGBO(40, 167, 69, 1);
    VGlobales.btnIcnSincServidor = FontAwesomeIcons.solidCheckCircle;
  } else if (menu == "Catálogo Clientes") {
    VGlobales.emailsClienteLista = new List<Widget>();
    VGlobales.emailsClienteInputs = new List<TextEditingController>();
    VGlobales.camposUbicClienteLista = new List<Widget>();
    VGlobales.camposClienteInputs = new List<TextEditingController>();
    VGlobales.ubicacionCClienteInputs = new List<TextEditingController>();
  }
}

// ------------------ [ SINCRONIZACION DE BD ]
// FUNCION QUE SINCRONIZA LA BASE DE DATOS
Future<void> sincronizarBD() async {
  try {
    loadingAbrir("Sincronizando App..");
    if (await InertetConn.verificar()) {
      await sincronizarAplicacionBD((sinc) async {
        if (sinc == "true") {
          await loadingCerrar((l) {
            principalKey.currentState.abrirPagPrincipal();
          });
        } else {
          await loadingCerrar((l) {
            msgPrimario("Error!", "Ocurrió un problema al sincronizar aplicación: - " + sinc, "Aceptar");
          });
        }
        
      });
    } else {
      await loadingCerrar((l) {
        msgPrimario("Atención!", "Requiere conección a internet para esta acción", "Aceptar");
      });
    }
  } catch (error) {
    await loadingCerrar((l) {
      msgPrimario("Error!", "Ocurrió un problema al sincronizar aplicación: - " + error.toString(), "Aceptar");
    });
  }
}