// -------- [ IMPORTACIONES Y PAQUETES GLOBALES ] --------
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:date_format/date_format.dart';
import 'package:agroventasapp/auxiliares/alertas.dart';
import 'package:agroventasapp/auxiliares/varsglobales.dart';



// ---------------- [ CREACION DE DOCUMENTOS PDF ] ----------------
// CLASE PRINCIPAL DE DOCUMENTOS PDF
class PDFs {
  // FUNCION QUE GENERA UN PDF DE FLICHA DE CLIENTE
  static Future<void> fichaCliente() async {
    try {
      if (VGlobales.idClienteGlobal > 0) {
        loadingAbrir("Generando ficha...");
        Map usuarioInfo = await VGlobales.dbSqliteCon.usuarioLogInfo();
        List<Map<String, dynamic>> clientesData = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM Clientes WHERE Id = " + VGlobales.idClienteGlobal.toString());
        List<Map<String, dynamic>> correosClienteData = await VGlobales.dbSqliteCon.consultarDB("SELECT * FROM CorreosClientes WHERE IdCliente = " + VGlobales.idClienteGlobal.toString());
        String correos = "";
        correosClienteData.forEach((correo) {
          if (correos != "") {
            correos += "\n";
          }
          correos += " " + correo["Correo"];
        });
        final Document pdf = Document();
        pdf.addPage(
          MultiPage(
            footer: (Context context) {
              return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: Text(
                  'Página ${context.pageNumber} de ${context.pagesCount}',
                  style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)
                ),
              );
            },
            build: (Context context) => <Widget>[
              Header(
                child: Center(
                  child: Text(
                    'FICHA DE CLIENTE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),  
                ),
                decoration: BoxDecoration(border: null),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: 100,
                    child: Table(
                      border: TableBorder(
                        width: 1.0,
                        color: PdfColors.black
                      ),
                      children: [
                        TableRow(
                          children: [
                            Container(
                              decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                              child: Text(
                                " FOLIO",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Container(
                              decoration: BoxDecoration(border: BoxBorder(width: 1.0)),
                              child: Text(
                                " FC-0014",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0,),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "NOMBRE AGENTE: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,)),
                    TextSpan(text: usuarioInfo["nombre"].toString().toUpperCase(), style: TextStyle(fontSize: 12,)),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "FECHA Y HORA: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,)),
                    TextSpan(text: formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]), style: TextStyle(fontSize: 12,)),
                  ],
                ),
              ),
              SizedBox(height: 8.0,),
              Container(
                child: Center(
                  child: Text(
                    'DATOS DEL CLIENTE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),  
                ),
              ),
              SizedBox(height: 8.0,),
              Table(
                border: TableBorder(
                  width: 1.0,
                  color: PdfColors.black
                ),
                children: [
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "RAZÓN SOCIAL ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                        ),
                        child: Text(" " + clientesData[0]["RazonSocial"]),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "R.F.C. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                        ),
                        child: Text(
                          " " + clientesData[0]["RFC"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "CALLE ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ), 
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                        ),
                        child: Text(
                          " " + clientesData[0]["Calle"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "NUMERO EXT: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["NumExt"]
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "NUMERO INT: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["NumInt"]
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "COLONIA: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["Colonia"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "LOCALIDAD: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["Localidad"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "MUNICIPIO: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["Municipio"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "ESTADO: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["Estado"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "PAÍS: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["Pais"]
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "CÓDIGO POSTAL: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["CP"].toString()
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "NOMBRE CONTACTO: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["NombreContacto"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "TELÉFONO: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["Telefono"].toString()
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "CORREO(S) ELECTRÓNICO(S): ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + correos
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                        child: Text(
                          "USO DE CFDI: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                        child: Text(
                          " " + clientesData[0]["UsoCFDI"]
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "MÉTODO PAGO: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["MetodoPago"]
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "FORMA PAGO: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " " + clientesData[0]["FormaPago"]
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "DÍAS CRÉDITO: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    ' ' + clientesData[0]["DiasCredito"].toString()
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Table(
                          border: TableBorder(
                            width: 1.0,
                            color: PdfColors.black
                          ),
                          children: [
                            TableRow(
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0), color: PdfColors.grey300),
                                  child: Text(
                                    "LÍNEA CRÉDITO: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(border: BoxBorder(width: 1.0, color: PdfColors.black)),
                                  child: Text(
                                    " \$ " + clientesData[0]["LineaCredito"].toStringAsFixed(2)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.0,),
            ],
          ),
        );
        final String dir = (await getApplicationDocumentsDirectory()).path;
        final String ruta = '$dir/reporte.pdf';
        final File file = File(ruta);
        file.writeAsBytesSync(pdf.save());
        loadingCerrar((l) {
          OpenFile.open(ruta);
        });
      } else {
        msgPrimario("Atención!", "Consulte y seleccione un cliente para imprimir ficha", "Aceptar");
      }
    } catch (error) {
      loadingCerrar((l) {
        msgPrimario("Error!", error.toString(), "Aceptar");
      });
    }
  }
  
  // FUNCION QUE GENERA UN PDF DE ORDEN DE PEDIDO
  static Future<void> ordenPedido() async {

  }
}