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

  @override
  void initState() {
    super.initState();
    _getInitialInfo();
  }

  void _getInitialInfo() async {
    DummyClientData dummyClients = DummyClientData();
    clients = dummyClients.getClients();
    dummyClients.saveClientsToFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar_minha_banca(),
      body: body_minha_banca(),

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
  body_minha_banca() {
    return Column(
      children: [
        Container(
          height: 150,
          color: Colors.green,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Container();
            },
          ),
        )
      ],
    );
  }
}
