import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmacaoVendaFornecedor extends StatefulWidget {
  const ConfirmacaoVendaFornecedor({super.key});

  @override
  State<ConfirmacaoVendaFornecedor> createState() => _ConfirmacaoVendaFornecedorState();
}

class _ConfirmacaoVendaFornecedorState extends State<ConfirmacaoVendaFornecedor> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 15), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: confirmacaoVenda()
    );
  }

  Center confirmacaoVenda () {
    return Center(
      child:
        Container(
        height: 500,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/conf_sale_supplier.svg'),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'A sua venda foi concluída com sucesso!',
                textAlign: TextAlign.center,
                style: GoogleFonts.kanit(
                  color: Color.fromRGBO(84, 157, 115, 1.0),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'A aguardar confirmação do cliente...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                      color: Color.fromRGBO(84, 157, 115, 1.0),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SvgPicture.asset('assets/icons/confirmacao_venda_prof_icon.svg')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
