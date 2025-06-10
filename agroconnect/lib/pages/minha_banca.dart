import 'package:agroconnect/models/client_model.dart';
import 'package:agroconnect/services/dummy_client_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MinhaBanca extends StatefulWidget {
  const MinhaBanca({super.key});

  @override
  State<MinhaBanca> createState() => _MinhaBancaState();
}

class _MinhaBancaState extends State<MinhaBanca> {
  late List<ClientModel> clients;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getInitialInfo() async {
    try {
      DummyClientData dummyClients = DummyClientData();
      setState(() {
        clients = dummyClients.getClients();
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
      appBar: appBar_minha_banca(),
      //body: body_minha_banca(),

    );
  }

  AppBar appBar_minha_banca() {
    return AppBar(
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
  Column body_minha_banca() {
    return Column(
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
                  color: Colors.grey,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: null,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color.fromRGBO(84, 157, 115, 1.0),
                            width: 2),
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

                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
