// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';
import 'package:agroventasapp/auxiliares/apifunciones.dart';
import 'package:agroventasapp/auxiliares/reportes.dart';



// FUNCION INICIAL QUE DEVUELVE EL WIDGET PRINCIPAL DEL MENU CATALOGO DE CLIENTES
class CatalogoClientes extends StatefulWidget {
  CatalogoClientes({Key key}) : super(key: catClientesKey);
  @override
  CatalogoClientesEstado createState() => CatalogoClientesEstado();
}

// FUNCION INICIAL QUE DEVUELVE EL ESTADO DEL WIDGET PRINCIPAL DEL MENU CONFIGURACION
class CatalogoClientesEstado extends State<CatalogoClientes> {
  // FUNCION QUE AGREGA LOS ELEMENTOS WIDGETS DINAMICOS
  void agregarWidget(int tipo, String cadena) {
    if (tipo == 1) {
      setState(() {
        agregarMailWidget(cadena);
      });
    } else if (tipo == 2) {
      setState(() {
        agregarCamposWidget(cadena);
      });
    }
  }

  // FUNCION QUE QUITA LOS ELEMENTOS WIDGET DINAMICOS
  void limpiarWidget(int tipo) {
    if (tipo == 1) {
      setState(() {
        quitarMailWidget();
      });
    } else if (tipo == 2) {
      setState(() {
        quitarCamposWidget();
      });
    }
  }

  // -- FUNCIONES DE COMBO DE AUTOCOMPLETADO
  // FORMULARIO DE ALTA
  Widget acAlta(Map item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "\n" + item["RazonSocial"].toString(),
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  // FUNCION QUE ASIGNA EL TEXTO SELECCIONADO DEL AUTOCOMPLETADO
  // CONSULTA  DE CLIENTE
  void acTxtConsulta(Map item) {
    VGlobales.idClienteGlobal = item["Id"];
    VGlobales.razonSocialGlobal = item["RazonSocial"].toString();
    String nombre = item["RazonSocial"].toString();
    setState(() {
      clienteConsultaInput.text = nombre;
    });
  }
  // FORMULARIO ALTA
  void acTxtAlta(Map item) {
    String nombre = item["RazonSocial"].toString();
    setState(() {
      razonSocialInput.text = nombre;
      msgPrimario("Advertencia!", "Las opciones mostradas son solo informativas.\nNo repita los nombres de los clientes.", "Aceptar");
    });
  }

  // RECARGAR PARAMETROS DE WIDGET
  void widgetParams() {
    setState(() { });
  }

  // WIDGET PRINCIPAL
  @override
  Widget build(BuildContext contextCatClientes) {
    contextGlobal = contextCatClientes;
    return FutureBuilder<void>(
      future: initCatalogoClientes(),
      builder: (contextCatClientes, AsyncSnapshot<void> snapshot) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: ListView(
            children: <Widget>[
              Text(
                'Ajuste de Clientes',
                style: GEstilos.txtTitulo,
              ),
              SizedBox(height: 20.0,),
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: clienteConsultaInput,
                  style: TextStyle(
                    color: GEstilos.agroVerde,
                    fontSize: 18
                  ),
                  decoration: InputDecoration(
                    hintText: "- Consultar Cliente -",
                    hintStyle: TextStyle(
                      color: GEstilos.cMarcador,
                    ),
                  ),
                ),
                itemBuilder: (contextCatClientes, suggestion) {
                  return ListTile(
                    leading: Icon(FontAwesomeIcons.solidUser),
                    title: Text(suggestion['RazonSocial'].toString()),
                  );
                },
                suggestionsCallback: (pattern) async {
                  return await GoogleConsultas.clientes(pattern);
                },
                onSuggestionSelected: (suggestion) {
                  acTxtConsulta(suggestion);
                },
              ),
              SizedBox(height: 5.0,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: GEstilos.btnPrimario,
                      textColor: Colors.white,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Icon(
                            FontAwesomeIcons.plus,
                            size: 14,
                          ),
                          new Text(
                            ' Nuevo',
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
                        await ClientesCRUD().nuevo();
                      },
                    ),
                  ),
                  Text(" "),
                  Expanded(
                    child: RaisedButton(
                      color: GEstilos.btnAtencion,
                      textColor: Colors.white,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Icon(
                            FontAwesomeIcons.solidEdit,
                            size: 14,
                          ),
                          new Text(
                            ' Editar',
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
                        await ClientesCRUD().editar();
                      },
                    ),
                  ),
                  Text(" "),
                  Expanded(
                    child: RaisedButton(
                      color: GEstilos.btnError,
                      textColor: Colors.white,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Icon(
                            FontAwesomeIcons.trash,
                            size: 14,
                          ),
                          new Text(
                            ' Borrar',
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
                        await ClientesCRUD().borrar();
                      },
                    ),
                  ),
                ],
              ),
              RaisedButton(
                color: GEstilos.btnOscuro,
                textColor: Colors.white,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Icon(
                      FontAwesomeIcons.print,
                      size: 14,
                    ),
                    new Text(
                      '  Imprimir Ficha Cliente',
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
                  await PDFs.fichaCliente();
                },
              ),
              SizedBox(height: 15.0,),
              Divider(
                color: GEstilos.lineaDivisor,
              ),
              Text(
                '\nFicha de Cliente\n',
                style: GEstilos.txtTitulo,
              ),
              Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.solidAddressCard,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: AutoCompleteTextField<Map<String, dynamic>>(
                      key: VGlobales.clienteACKey,
                      controller: razonSocialInput,
                      suggestions: VGlobales.clientesLista,
                      itemFilter: (item, query) {
                        return item["RazonSocial"].toString().toLowerCase().startsWith(query.toLowerCase());
                      },
                      clearOnSubmit: false,
                      itemSubmitted: (item) {
                        acTxtAlta(item);
                      },
                      itemBuilder: (contextCatClientes, item) {
                        return acAlta(item);
                      },
                      itemSorter: (a, b) {
                        return a["RazonSocial"].toString().compareTo(b["RazonSocial"].toString());
                      },
                      decoration: InputDecoration(
                        hintText: 'Razón Social',
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
                    FontAwesomeIcons.qrcode,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: rfcInput,
                      decoration: InputDecoration(
                        hintText: 'RFC',
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
                    FontAwesomeIcons.home,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: calleInput,
                      decoration: InputDecoration(
                        hintText: 'Calle',
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
                    FontAwesomeIcons.hashtag,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: numExtInput,
                      decoration: InputDecoration(
                        hintText: 'Número Ext',
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
                  Icon(
                    FontAwesomeIcons.hashtag,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: numIntInput,
                      decoration: InputDecoration(
                        hintText: 'Número Int',
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
                    FontAwesomeIcons.solidAddressBook,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: coloniaInput,
                      decoration: InputDecoration(
                        hintText: 'Colonia',
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
                    FontAwesomeIcons.solidMap,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: localidadInput,
                      decoration: InputDecoration(
                        hintText: 'Localidad',
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
                    FontAwesomeIcons.mapMarkerAlt,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: municipioInput,
                      decoration: InputDecoration(
                        hintText: 'Municipio',
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
                    FontAwesomeIcons.mapMarkerAlt,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: estadoInput,
                      decoration: InputDecoration(
                        hintText: 'Estado',
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
                    FontAwesomeIcons.globeAmericas,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: paisInput,
                      decoration: InputDecoration(
                        hintText: 'País',
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
                  Icon(
                    FontAwesomeIcons.solidEnvelope,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: cpInput,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'C.P.',
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
                    FontAwesomeIcons.solidUser,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: nombreContactoInput,
                      decoration: InputDecoration(
                        hintText: 'Nombre Contacto',
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
                    FontAwesomeIcons.phone,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: telefonoInput,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Teléfono',
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
              Text("\n"),
              Row(
                children: <Widget>[
                  Text(
                    'Email(s) del Cliente',
                    style: GEstilos.txtTitulo,
                  ),
                  Expanded(
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      buttonPadding: EdgeInsets.all(0),
                      children: <Widget>[
                        MaterialButton(
                          color: GEstilos.btnError,
                          textColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.trash,
                            size: 13,
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            limpiarWidget(1);
                          },
                        ),
                        MaterialButton(
                          color: GEstilos.btnSegundo,
                          textColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.plusCircle,
                            size: 13,
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            agregarWidget(1, "");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: VGlobales.emailsClienteLista,
              ),
              Text("\n"),
              Row(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.solidFile,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: usoCFDIInput,
                      decoration: InputDecoration(
                        hintText: 'Uso de CFDI',
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
                    FontAwesomeIcons.creditCard,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: metodoPagoInput,
                      decoration: InputDecoration(
                        hintText: 'Método Pago',
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
                  Icon(
                    FontAwesomeIcons.moneyBillAlt,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: formaPagoInput,
                      decoration: InputDecoration(
                        hintText: 'Forma Pago',
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
                    FontAwesomeIcons.calendar,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: diasCreditoInput,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Días Crédito',
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
                  Icon(
                    FontAwesomeIcons.dollarSign,
                    size: 20,
                    color: GEstilos.agroVerde,
                  ),
                  Text('   '),
                  Expanded(
                    child: TextFormField(
                      controller: lineaCreditoInput,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Línea Crédito',
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
              Text("\n"),
              Row(
                children: <Widget>[
                  Text(
                    'Campo(s) del Cliente',
                    style: GEstilos.txtTitulo,
                  ),
                  Expanded(
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      buttonPadding: EdgeInsets.all(0),
                      children: <Widget>[
                        MaterialButton(
                          color: GEstilos.btnError,
                          textColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.trash,
                            size: 13,
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            limpiarWidget(2);
                          },
                        ),
                        MaterialButton(
                          color: GEstilos.btnSegundo,
                          textColor: Colors.white,
                          child: Icon(
                            FontAwesomeIcons.plusCircle,
                            size: 13,
                          ),
                          shape: CircleBorder(),
                          onPressed: () {
                            agregarWidget(2, "");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: VGlobales.camposUbicClienteLista,
              ),
              Text("\n"),
              Divider(
                color: GEstilos.lineaDivisor,
              ),
              Text("\n"),
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
                      '  Guardar Cliente',
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
                  await ClientesCRUD().guardar();
                },
              ),
              Text("\n"),
            ],
          ),
        );
      },
    );
  }
}

// ----------- [ CONTROLADORES DE FORMULARIO DE CLIENTES ] -----------
//TEXT TIPO CONSULTA
TextEditingController clienteConsultaInput = new TextEditingController();
// TEXTINPUTS
TextEditingController razonSocialInput = new TextEditingController();
TextEditingController rfcInput = new TextEditingController();
TextEditingController calleInput = new TextEditingController();
TextEditingController numExtInput = new TextEditingController();
TextEditingController numIntInput = new TextEditingController();
TextEditingController coloniaInput = new TextEditingController();
TextEditingController localidadInput = new TextEditingController();
TextEditingController municipioInput = new TextEditingController();
TextEditingController estadoInput = new TextEditingController();
TextEditingController paisInput = new TextEditingController();
TextEditingController cpInput = new TextEditingController();
TextEditingController nombreContactoInput = new TextEditingController();
TextEditingController telefonoInput = new TextEditingController();
TextEditingController usoCFDIInput = new TextEditingController();
TextEditingController metodoPagoInput = new TextEditingController();
TextEditingController formaPagoInput = new TextEditingController();
TextEditingController diasCreditoInput = new TextEditingController();
TextEditingController lineaCreditoInput = new TextEditingController();
// FOCUS
FocusNode razonSocialInputF = new FocusNode();


// ********************* [ +++++++++++++++++++  ] *********************
// FUNCION QUE CARGA LOS PARAMETROS INICIALES DEL CATALOGO DE CLIENTES
Future<void> initCatalogoClientes() async {
  if (VGlobales.iniciarParams) {
    await ClientesForm().limpiar(true);
    VGlobales.clientesLista = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM Clientes WHERE Estatus > 0");
    VGlobales.iniciarParams = false;
  }
}
// ********************* [ +++++++++++++++++++  ] *********************

// ------------ [ FUNCIONES DE WIDGETS DINAMICOS ] ------------
// FUNCION QUE AGREGA LOS WIDGETS DE EMAILS PARA EL CLIENTE
void agregarMailWidget(String cadena) {
  TextEditingController emailController = new TextEditingController();
  if (cadena != "") {
    emailController.text = cadena;
  }
  VGlobales.emailsClienteLista.add(
    Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.at,
              size: 20,
              color: GEstilos.agroVerde,
            ),
            Text('   '),
            Expanded(
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
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
      ],
    ),
  );
  VGlobales.emailsClienteInputs.insert(0, emailController);
}
// FUNCION QUE QUITA LOS WIDGETS DE EMAILS CLIENTE
void quitarMailWidget() {
  VGlobales.emailsClienteLista = new List<Widget>();
  VGlobales.emailsClienteInputs = new List<TextEditingController>();
}

// FUNCION QUE AGREGA LOS WIDGETS DE CAMPOS Y UBICACIONES DEL CLIENTE
void agregarCamposWidget(String cadena) {
  TextEditingController campoController = new TextEditingController();
  TextEditingController ubicacionController = new TextEditingController();
  if (cadena != "") {
    List<String> campoUbic = cadena.split("ƒøƒ");
    campoController.text = campoUbic[0].toString();
    ubicacionController.text = campoUbic[1].toString();
  }
  VGlobales.camposUbicClienteLista.add(
    Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.warehouse,
              size: 20,
              color: GEstilos.agroVerde,
            ),
            Text('   '),
            Expanded(
              child: TextFormField(
                controller: campoController,
                decoration: InputDecoration(
                  hintText: 'Campo',
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
            Icon(
              FontAwesomeIcons.mapMarkerAlt,
              size: 20,
              color: GEstilos.agroVerde,
            ),
            Text('   '),
            Expanded(
              child: TextFormField(
                controller: ubicacionController,
                decoration: InputDecoration(
                  hintText: 'Ubicación',
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
      ],
    ),
  );
  VGlobales.camposClienteInputs.insert(0, campoController);
  VGlobales.ubicacionCClienteInputs.insert(0, ubicacionController);
}
// FUCNION QUE QUITA LOS WIDGETS DE CAMPOS Y UBICACIONES DEL CLIENTE
void quitarCamposWidget() {
  VGlobales.camposUbicClienteLista = new List<Widget>();
  VGlobales.camposClienteInputs = new List<TextEditingController>();
  VGlobales.ubicacionCClienteInputs = new List<TextEditingController>();
}

// ---------------------- [ FUNCIONES -CRUD- CON FORMULARIO CLIENTE ] ----------------------
class ClientesCRUD {
  // CARGAR CLIENTES
  Future<void> cargar() async {
    VGlobales.clientesLista = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM Clientes WHERE Estatus > 0");
    catClientesKey.currentState.widgetParams();
  }

  // NUEVO CLIENTE
  Future<void> nuevo() async {
    await ClientesForm().limpiar(true);
    catClientesKey.currentState.limpiarWidget(1);
    catClientesKey.currentState.limpiarWidget(2);
    msgCorto("Formulario listo", 0);
  }

  // GUARDAR CLIENTE
  Future<void> guardar() async {
    if (ClientesForm().validar()) {
      noFocus();
      loadingAbrir("Guardando...");
      List<dynamic> clientesInfo = await ClientesForm().crearData();
      Map clienteDataWS = {
        "ClienteData" : json.encode(VGlobales.clientesAltaServidor),
        "CorreosData" : json.encode(VGlobales.correosAltaServidor),
        "CamposData" : json.encode(VGlobales.camposAltaServidor)
      };
      Map dataWS = {
        "Tabla" : "Clientes",
        "Accion" : "Nuevo",
        "Data" : json.encode(clienteDataWS)
      };
      String query = "INSERT INTO Clientes (Id,RazonSocial,RFC,Calle,NumInt,NumExt,Colonia,Localidad,Municipio,Estado,Pais,CP,NombreContacto,Telefono,UsoCFDI,MetodoPago,FormaPago,DiasCredito,LineaCredito,Estatus) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      if (VGlobales.idClienteGlobal > 0) {
        query = "UPDATE Clientes SET RazonSocial=?,RFC=?,Calle=?,NumInt=?,NumExt=?,Colonia=?,Localidad=?,Municipio=?,Estado=?,Pais=?,CP=?,NombreContacto=?,Telefono=?,UsoCFDI=?,MetodoPago=?,FormaPago=?,DiasCredito=?,LineaCredito=? WHERE Id=?";
        dataWS["Accion"] = "Editar";
        await VGlobales.dbSqliteCon.eliminarDB("DELETE FROM CorreosClientes WHERE IdCliente=?", [ VGlobales.idClienteGlobal ]);
        await VGlobales.dbSqliteCon.eliminarDB("DELETE FROM Campos WHERE IdCliente=?", [ VGlobales.idClienteGlobal ]);
      }

      try {
        (VGlobales.idClienteGlobal > 0) ? await VGlobales.dbSqliteCon.actualizarDB(query, clientesInfo) : await VGlobales.dbSqliteCon.insertarDB(query, clientesInfo);
        VGlobales.correosAltaServidor.forEach((correo) async {
          await VGlobales.dbSqliteCon.insertarDB("INSERT INTO CorreosClientes (IdCliente,Correo) VALUES (?,?)", [ correo["IdCliente"], correo["Correo"] ]);
        });
        VGlobales.camposAltaServidor.forEach((campos) async {
          await VGlobales.dbSqliteCon.insertarDB("INSERT INTO Campos (IdCliente,NombreCampo,Ubicacion) VALUES (?,?,?)", [ campos["IdCliente"], campos["NombreCampo"], campos["Ubicacion"] ]);
        });
        
        await enviarDataWS(dataWS, (ws) async {
          await ClientesForm().limpiar(true);
          await cargar();
          loadingCerrar((l) {
            msgPrimario("Éxito!", "Cliente almacenado correctamente.", "Aceptar");
          });
        });
      } catch (error) {
        loadingCerrar((l) {
          msgPrimario("Error!", "Ocurrió un  problema al guardar cliente: - " + error.toString(), "Aceptar");
        });
      }
    }
  }

  // EDITAR CLIENTE
  Future<void> editar() async {
    if (VGlobales.idClienteGlobal > 0) {
      loadingAbrir("Cargando cliente...");
      await ClientesForm().limpiar(false);
      List<Map<String, dynamic>> clientesData = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM Clientes WHERE Id = " + VGlobales.idClienteGlobal.toString());
      List<Map<String, dynamic>> correosClienteData = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM CorreosClientes WHERE IdCliente = " + VGlobales.idClienteGlobal.toString());
      List<Map<String, dynamic>> camposClienteData = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM Campos WHERE IdCliente = " + VGlobales.idClienteGlobal.toString());
      
      clientesData.forEach((cliente) {
        razonSocialInput.text = cliente["RazonSocial"].toString();
        rfcInput.text = cliente["RFC"].toString();
        calleInput.text = cliente["Calle"].toString();
        numIntInput.text = cliente["NumInt"].toString();
        numExtInput.text = cliente["NumExt"].toString();
        coloniaInput.text = cliente["Colonia"].toString();
        localidadInput.text = cliente["Localidad"].toString();
        municipioInput.text = cliente["Municipio"].toString();
        estadoInput.text = cliente["Estado"].toString();
        paisInput.text = cliente["Pais"].toString();
        cpInput.text = cliente["CP"].toString();
        nombreContactoInput.text = cliente["NombreContacto"].toString();
        telefonoInput.text = cliente["Telefono"].toString();
        usoCFDIInput.text = cliente["UsoCFDI"].toString();
        metodoPagoInput.text = cliente["MetodoPago"].toString();
        formaPagoInput.text = cliente["FormaPago"].toString();
        diasCreditoInput.text = cliente["DiasCredito"].toString();
        lineaCreditoInput.text = cliente["LineaCredito"].toString();
      });
      correosClienteData.forEach((correo) {
        catClientesKey.currentState.agregarWidget(1, correo["Correo"].toString());
      });
      camposClienteData.forEach((campos) {
        catClientesKey.currentState.agregarWidget(2, campos["NombreCampo"].toString() + "ƒøƒ" + campos["Ubicacion"].toString());
      });

      await loadingCerrar((l) { });
    } else {
      msgPrimario("Atención!", "Consulte y seleccione un cliente para editar", "Aceptar");
    }
  }

  // BORRAR CLIENTE
  Future<void> borrar() async {
    if (VGlobales.idClienteGlobal > 0) {
      msgPregunta("Atención!", "¿Desea borrar a " + VGlobales.razonSocialGlobal + "?", "Si", "Cancelar", (si) async {
        if (si) {
          loadingAbrir("Borrando cliente...");
          Map clienteBorrar = {
            "Id" : VGlobales.idClienteGlobal,
            "Estatus" : 0
          };
          Map dataWS = {
            "Tabla" : "Clientes",
            "Accion" : "Borrar",
            "Data" : json.encode(clienteBorrar)
          };
          try {
            await VGlobales.dbSqliteCon.eliminarDB("UPDATE Clientes SET Estatus=? WHERE Id=?", [0 , VGlobales.idClienteGlobal]);
            await enviarDataWS(dataWS, (ws) async {
              await ClientesForm().limpiar(true);
              await cargar();
              loadingCerrar((l) {
                msgPrimario("Éxito!", "Cliente eliminado correctamente.", "Aceptar");
              });
            });
          } catch (error) {
            loadingCerrar((l) {
              msgPrimario("Éxito!", "Ocurrió un error al eliminar cliente: - " + error.toString(), "Aceptar");
            });
          }
        }
      });
    } else {
      msgPrimario("Atención!", "Consulte y seleccione un cliente para borrar", "Aceptar");
    }
  }
}

// ------------------- [ ACCIONES COM FORMULARIO CLIENTES ] -------------------
class ClientesForm {
  // FUNCION QUE LIMPIA EL FORMULARIO DE CLIENTES
  Future<void> limpiar(bool nuevo) async {
    if (nuevo) {
      VGlobales.idClienteGlobal = 0;
      VGlobales.razonSocialGlobal = "";
      clienteConsultaInput.text = "";
    }

    razonSocialInput.text = "";
    rfcInput = new TextEditingController(text: "");
    calleInput = new TextEditingController(text: "");
    numExtInput = new TextEditingController(text: "");
    numIntInput = new TextEditingController(text: "");
    coloniaInput = new TextEditingController(text: "");
    localidadInput = new TextEditingController(text: "");
    municipioInput = new TextEditingController(text: "");
    estadoInput = new TextEditingController(text: "");
    paisInput = new TextEditingController(text: "");
    cpInput = new TextEditingController(text: "");
    nombreContactoInput = new TextEditingController(text: "");
    telefonoInput = new TextEditingController(text: "");
    usoCFDIInput = new TextEditingController(text: "");
    metodoPagoInput = new TextEditingController(text: "");
    formaPagoInput = new TextEditingController(text: "");
    diasCreditoInput = new TextEditingController(text: "");
    lineaCreditoInput = new TextEditingController(text: "");
    razonSocialInputF = new FocusNode();

    catClientesKey.currentState.limpiarWidget(1);
    catClientesKey.currentState.limpiarWidget(2);
  }

  // CREAR DATA DE FORMULARIO
  Future<List<dynamic>> crearData() async {
    int maxIdClientes = await VGlobales.dbSqliteCon.obtenerMaxId("Clientes", "Id");
    String razonSocialAlta = razonSocialInput.text.toUpperCase().trim().replaceAll("Á", "A").replaceAll("É", "E").replaceAll("Í", "I").replaceAll("Ó", "O").replaceAll("Ú", "U");
    
    VGlobales.clientesAltaServidor = new Map<String, dynamic>();
    VGlobales.clientesAltaServidor = {
      "RazonSocial" : (razonSocialInput.text == "") ? "--" : razonSocialAlta,
      "RFC" : (rfcInput.text == "") ? "--" : rfcInput.text.toUpperCase().trim(),
      "Calle" : (calleInput.text == "") ? "--" : calleInput.text.toUpperCase().trim(),
      "NumInt" : (numIntInput.text == "") ? "--" : numIntInput.text.toUpperCase().trim(),
      "NumExt" : (numExtInput.text == "") ? "--" : numExtInput.text.toUpperCase().trim(),
      "Colonia" : (coloniaInput.text == "") ? "--" : coloniaInput.text.toUpperCase().trim(),
      "Localidad" : (localidadInput.text == "") ? "--" : localidadInput.text.toUpperCase().trim(),
      "Municipio" : (municipioInput.text == "") ? "--" : municipioInput.text.toUpperCase().trim(),
      "Estado" : (estadoInput.text == "") ? "--" : estadoInput.text.toUpperCase().trim(),
      "Pais" : (paisInput.text == "") ? "--" : paisInput.text.toUpperCase().trim(),
      "CP" : (cpInput.text == "") ? 0 : int.parse(cpInput.text),
      "NombreContacto" : (nombreContactoInput.text == "") ? "--" : nombreContactoInput.text.toUpperCase().trim(),
      "Telefono" : (telefonoInput.text == "") ? 0 : double.parse(telefonoInput.text),
      "UsoCFDI" : (usoCFDIInput.text == "") ? "--" : usoCFDIInput.text.toUpperCase().trim(),
      "MetodoPago" : (metodoPagoInput.text == "") ? "--" : metodoPagoInput.text.toUpperCase().trim(),
      "FormaPago" : (formaPagoInput.text == "") ? "--" : formaPagoInput.text.toUpperCase().trim(),
      "DiasCredito" : (diasCreditoInput.text == "") ? 0 : int.parse(diasCreditoInput.text),
      "LineaCredito" : (lineaCreditoInput.text == "") ? 0 : double.parse(lineaCreditoInput.text),
      "Estatus": 1
    };

    VGlobales.correosAltaServidor = new List<Map<String, dynamic>>();
    VGlobales.camposAltaServidor = new List<Map<String, dynamic>>();
    VGlobales.emailsClienteInputs.forEach((email) {
       VGlobales.correosAltaServidor.insert(0, {
         "IdCliente" : (VGlobales.idClienteGlobal > 0) ? VGlobales.idClienteGlobal : maxIdClientes,
         "Correo" : email.text.toString().trim()
       });
    });
    for (var i = 0; i < VGlobales.camposClienteInputs.length; i++) {
      VGlobales.camposAltaServidor.insert(0, {
         "IdCliente" : (VGlobales.idClienteGlobal > 0) ? VGlobales.idClienteGlobal : maxIdClientes,
         "NombreCampo" : VGlobales.camposClienteInputs[i].text.toUpperCase().trim(),
         "Ubicacion" : VGlobales.ubicacionCClienteInputs[i].text.toUpperCase().trim()
       });
    }

    if (VGlobales.idClienteGlobal > 0) {
      VGlobales.clientesAltaServidor["Id"] = VGlobales.idClienteGlobal;
      return [
        (razonSocialInput.text == "") ? "--" : razonSocialAlta,
        (rfcInput.text == "") ? "--" : rfcInput.text.toUpperCase().trim(),
        (calleInput.text == "") ? "--" : calleInput.text.toUpperCase().trim(),
        (numIntInput.text == "") ? "--" : numIntInput.text.toUpperCase().trim(),
        (numExtInput.text == "") ? "--" : numExtInput.text.toUpperCase().trim(),
        (coloniaInput.text == "") ? "--" : coloniaInput.text.toUpperCase().trim(),
        (localidadInput.text == "") ? "--" : localidadInput.text.toUpperCase().trim(),
        (municipioInput.text == "") ? "--" : municipioInput.text.toUpperCase().trim(),
        (estadoInput.text == "") ? "--" : estadoInput.text.toUpperCase().trim(),
        (paisInput.text == "") ? "--" : paisInput.text.toUpperCase().trim(),
        (cpInput.text == "") ? 0 : int.parse(cpInput.text),
        (nombreContactoInput.text == "") ? "--" : nombreContactoInput.text.toUpperCase().trim(),
        (telefonoInput.text == "") ? 0 : double.parse(telefonoInput.text),
        (usoCFDIInput.text == "") ? "--" : usoCFDIInput.text.toUpperCase().trim(),
        (metodoPagoInput.text == "") ? "--" : metodoPagoInput.text.toUpperCase().trim(),
        (formaPagoInput.text == "") ? "--" : formaPagoInput.text.toUpperCase().trim(),
        (diasCreditoInput.text == "") ? 0 : int.parse(diasCreditoInput.text),
        (lineaCreditoInput.text == "") ? 0 : double.parse(lineaCreditoInput.text),
        VGlobales.idClienteGlobal
      ];
    } else {
      VGlobales.clientesAltaServidor["Id"] = maxIdClientes;
      return [
        maxIdClientes,
        (razonSocialInput.text == "") ? "--" : razonSocialAlta,
        (rfcInput.text == "") ? "--" : rfcInput.text.toUpperCase().trim(),
        (calleInput.text == "") ? "--" : calleInput.text.toUpperCase().trim(),
        (numIntInput.text == "") ? "--" : numIntInput.text.toUpperCase().trim(),
        (numExtInput.text == "") ? "--" : numExtInput.text.toUpperCase().trim(),
        (coloniaInput.text == "") ? "--" : coloniaInput.text.toUpperCase().trim(),
        (localidadInput.text == "") ? "--" : localidadInput.text.toUpperCase().trim(),
        (municipioInput.text == "") ? "--" : municipioInput.text.toUpperCase().trim(),
        (estadoInput.text == "") ? "--" : estadoInput.text.toUpperCase().trim(),
        (paisInput.text == "") ? "--" : paisInput.text.toUpperCase().trim(),
        (cpInput.text == "") ? 0 : int.parse(cpInput.text),
        (nombreContactoInput.text == "") ? "--" : nombreContactoInput.text.toUpperCase().trim(),
        (telefonoInput.text == "") ? 0 : double.parse(telefonoInput.text),
        (usoCFDIInput.text == "") ? "--" : usoCFDIInput.text.toUpperCase().trim(),
        (metodoPagoInput.text == "") ? "--" : metodoPagoInput.text.toUpperCase().trim(),
        (formaPagoInput.text == "") ? "--" : formaPagoInput.text.toUpperCase().trim(),
        (diasCreditoInput.text == "") ? 0 : int.parse(diasCreditoInput.text),
        (lineaCreditoInput.text == "") ? 0 : double.parse(lineaCreditoInput.text),
        1
      ];
    }
  }

  // VALIDAR FORMULARIO
  bool validar() {
    bool correcto = true;
    String msg = "";
    int tipoMsg = 1;
    if (razonSocialInput.text == "") {
      correcto = false;
      msg = "Coloque Razón Social";
    } else {
      tipoMsg = 2;
      bool inputs = true;
      VGlobales.emailsClienteInputs.forEach((email) {
        if (email.text == "") {
          correcto = false;
          inputs = false;
          msg = "No deje espacios de Correos sin asignar.";
        }
      });
      if (inputs) {
        VGlobales.camposClienteInputs.forEach((campo) {
          if (campo.text == "") {
            correcto = false;
            inputs = false;
            msg = "No deje espacios de Campos sin asignar.";
          }
        });
      }
      if (inputs) {
        VGlobales.ubicacionCClienteInputs.forEach((ubicacion) {
          if (ubicacion.text == "") {
            correcto = false;
            msg = "No deje espacios de Ubicaciones sin asignar.";
          }
        });
      }
    }
    if (!correcto) {
      if (tipoMsg == 1) {
        msgCorto(msg, 0);
      } else if (tipoMsg == 2) {
        msgPrimario("Atención!", msg, "Aceptar");
      }
    }
    return correcto;
  }
}