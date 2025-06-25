import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/*class AvaliacoesFornecedor extends StatelessWidget {
  const AvaliacoesFornecedor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarAvaliacoes(),
      body: bodyAvaliacoes(),
    );
  }

  AppBar appBarAvaliacoes () {
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
          Text('Feedback da compra'),

        ],
      ),
      leading: GestureDetector(
        onTap: () => null,//Navigator.pop(context),
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

  SingleChildScrollView bodyAvaliacoes() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Classifique a sua venda",
          ),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black
            ),
            child: Column(
              children: [
                Text(
                  "O que achou  "
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}
*/