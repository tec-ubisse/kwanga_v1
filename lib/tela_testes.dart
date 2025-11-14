import 'package:flutter/material.dart';

class TelaTestes extends StatefulWidget {
  const TelaTestes({super.key});

  @override
  State<TelaTestes> createState() => _TelaTestesState();
}

class _TelaTestesState extends State<TelaTestes> {
  int value = 0;
  bool enableIncreaseButton = true;
  bool enableDecreaseButton = true;

  void increase() {
    setState(() {
      if (value < 10) {
        value++;
      } else {
        enableIncreaseButton = false;
      }
    });
  }

  void decrease() {
    setState(() {
      if (value <= 10 && value >= 0) {
        value--;
      } else {
        enableDecreaseButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tela de Testes")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: value/10,
              ),
              Text("$value"),
            ],
          ),
          ElevatedButton(
            onPressed: increase,
            autofocus: enableIncreaseButton,
            child: Text("Subir"),
          ),
          ElevatedButton(
            onPressed: decrease,
            child: Text("Baixar"),
          ),
        ],
      ),
    );
  }
}
