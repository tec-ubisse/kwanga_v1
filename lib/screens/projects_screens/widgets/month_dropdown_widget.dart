import 'package:flutter/material.dart';

// O nome do seu DropdownButton (substitua pelo nome real se for um widget customizado)
typedef KwangaDropdownButton<T> = DropdownButton<T>;

class MonthDropdown extends StatefulWidget {
  // A função que será chamada quando um novo mês for selecionado
  final ValueChanged<int?> onChanged;

  const MonthDropdown({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MonthDropdownState createState() => _MonthDropdownState();
}

class _MonthDropdownState extends State<MonthDropdown> {
  // 1. Lista de nomes de meses para exibição
  final List<String> _monthNames = const [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  // 2. Estado interno para o mês selecionado (começa em Janeiro = 1)
  int? _selectedMonth = 1;

  @override
  Widget build(BuildContext context) {
    // 3. Constrói o KwangaDropdownButton
    return KwangaDropdownButton<int>(
      // 4. Mapeia a lista de 1 a 12 para DropdownMenuItems
      items: List.generate(12, (i) => i + 1).map((monthNumber) {
        final monthIndex = monthNumber - 1;

        return DropdownMenuItem(
          value: monthNumber,
          child: Text(_monthNames[monthIndex]),
        );
      }).toList(),

      // 5. O valor que o DropdownButton deve exibir
      value: _selectedMonth,

      // 6. Lógica de mudança de estado e notificação do widget pai
      onChanged: (int? newMonth) {
        if (newMonth != null) {
          setState(() {
            _selectedMonth = newMonth; // Atualiza o estado interno
          });
          // Notifica o widget pai através do callback
          widget.onChanged(newMonth);
        }
      },
    );
  }
}