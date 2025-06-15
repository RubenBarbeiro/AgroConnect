import 'package:agroconnect/models/client_model.dart';
import 'package:agroconnect/models/product_model.dart';
import 'package:agroconnect/services/dummy_client_data.dart';
import 'package:agroconnect/services/dummy_product_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class MinhaBanca extends StatefulWidget {
  const MinhaBanca({super.key});

  @override
  State<MinhaBanca> createState() => _MinhaBancaState();
}

class _MinhaBancaState extends State<MinhaBanca> {
  late List<ClientModel> clients;
  late List<ProductModel> products;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getInitialInfo() async {
    try {
      DummyClientData dummyClients = DummyClientData();
      DummyProductData dummyProducts = DummyProductData();
      setState(() {
        clients = dummyClients.getClients();
        products = dummyProducts.getProducts();
        isLoading = false; // Set loading to false when data is ready
      });
      //dummyClients.saveClientsToFirebase();
    } catch (e) {
      print('Error loading clients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: appBar_minha_banca(),
      body: body_minha_banca(),

    );
  }

  AppBar appBar_minha_banca() {
    return AppBar(
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/shop_header_icon.svg',
            height: 20,
            width: 20,
          ),
          SizedBox(width: 8), //adiciona espaço entre icon e texto
          Text('Minha Banca')
        ],
      ),
      leading: GestureDetector(
        onTap: () {
        //## completar com código para voltar pag anterior
          //Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/icons/back_arrow_appbar.svg',
            height: 20,
            width: 20,
          ),
        ),
      ),
    );

  }

  //@override
  SingleChildScrollView body_minha_banca() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 150,
            child: ListView.separated(
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(
                  left: 20,
                  right: 20
              ),
              separatorBuilder: (context, index) => SizedBox(width: 25,),
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    //color: Colors.grey,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: null,
                              shape: BoxShape.circle,
                              border: Border.all(color: Color.fromRGBO(84, 157, 115, 1.0),
                                  width: 2),
                              boxShadow:[
                                BoxShadow(color: Colors.grey,
                                  blurRadius: 5,
                                  spreadRadius: 0,
                                ),
                              ]
                          ),
                          child: ClipOval(
                            child: Image(
                                image: AssetImage(clients[index].imagePath),
                                fit: BoxFit.cover
                            ),
                          )
                      ),
                      Text(
                          clients[index].name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            color: Color.fromRGBO(84, 157, 115, 1.0),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      Text(
                          'nr de vendas',
                          style: GoogleFonts.kanit(
                              color: Color.fromRGBO(184, 228, 170, 1.0),
                              fontSize: 12,
                              fontWeight: FontWeight.bold
                          )
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Os seus produtos',
                    style: GoogleFonts.kanit(
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Container(
                height: 400,
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(84, 157, 115, 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow:[
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    // Products ListView with margin
                    Container(
                      height: 350, // Fixed height for products area
                      margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: ListView.separated(
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => SizedBox(width: 25,),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: 200,
                            height: 150,
                            margin: EdgeInsets.all(10), // Add margin around each product
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(217, 217, 217, 1.0),
                              borderRadius: BorderRadius.circular(8), // Optional: rounded corners
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 150,
                                  height: 180,
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      products[index].productImage,
                                      fit: BoxFit.cover,

                                    ),
                                  )

                                ),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    products[index].productName,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.kanit(
                                        color: Color.fromRGBO(84, 157, 115, 1.0),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                Text(
                                  products[index].quantity.toString(),
                                  style: GoogleFonts.kanit(
                                      color: Color.fromRGBO(84, 157, 115, 1.0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${products[index].getExpirationDate().difference(DateTime.now()).inDays} dias até o anúncio expirar.',
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.kanit(
                                        color: Color.fromRGBO(84, 157, 115, 1.0),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,

                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      'Informações Importantes',
                      style: GoogleFonts.kanit(
                          color: Color.fromRGBO(84, 157, 115, 1.0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    "Visualizações diárias dos produtos",
                    style: GoogleFonts.kanit(
                        color: Color.fromRGBO(84, 157, 115, 1.0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0, top: 20),
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 0),
                              FlSpot(1, 1),
                              FlSpot(2, 1),
                              FlSpot(3, 4),
                              FlSpot(4, 5),
                              FlSpot(5, 2),
                            ],
                            color: Color.fromRGBO(184, 228, 170, 1.0),
                            barWidth: 8,
                            isCurved: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Color.fromRGBO(184, 228, 170, 1.0).withOpacity(0.3),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (FlSpot spot,
                                double xPercentage,
                                LineChartBarData bar,
                                int index, {double? size,
                                }) {
                                  return FlDotCirclePainter(
                                    strokeWidth: 3,
                                    color: Color.fromRGBO(84, 157, 115, 1.0),
                                  );
                                }
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: const SideTitles(
                              showTitles: false,
                            ),
                            /*axisNameWidget: Container(
                              margin: EdgeInsets.all(1),
                              child: Text(
                                'Visualizações diárias dos produtos',
                                style: GoogleFonts.kanit(
                                  color: Color.fromRGBO(84, 157, 115, 1.0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),*/
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              )
                          )
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        gridData: FlGridData(
                          getDrawingHorizontalLine: (value) {
                            return const FlLine(
                              color: Color.fromRGBO(184, 228, 170, 1.0),
                              dashArray: [5, 10],
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return const FlLine(
                              color: Color.fromRGBO(184, 228, 170, 1.0),
                              dashArray: [5, 10],
                              strokeWidth: 1,
                            );
                          },
                        )
                        // read about it in the LineChartData section
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

