import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MinhaBanca extends StatelessWidget {
  const MinhaBanca({super.key});

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
