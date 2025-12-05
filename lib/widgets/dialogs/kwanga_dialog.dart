import 'package:flutter/material.dart';

Future<String?> showKwangaActionDialog(
    BuildContext context, {
      required String title,
      required String hint,
      String initialValue = '',
    }) {
  return showDialog<String>(
    context: context,
    // Garante que o usuário tem que interagir com os botões
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      // Use um StatefulWidget ou, como aqui, um widget simples que gere o controlador.
      // O StatefulBuilder é ideal para diálogos se precisarmos de setState,
      // mas neste caso, o controlador pode ser gerido dentro de um State/Hook.
      // Vamos usar o StatefulBuilder para demonstrar a gestão correta do controlador.
      return StatefulBuilder(
        builder: (context, setState) {
          final controller = TextEditingController(text: initialValue);

          // O Dialog é envolvido em um StatefulBuilder/StatefulWidget
          // para garantir que o TextEditingController seja descartado (disposed).
          // **ATENÇÃO:** O controlador DEVE ser descartado. No seu código original,
          // ele era criado fora do `builder` do `showDialog` mas não era descartado.
          // Aqui, vamos refatorar para um widget dedicado ou usar um gancho para garantir o dispose.
          // Para a correção rápida e segura, vamos usar um widget que faça o dispose.
          // Como não podemos fazer o dispose dentro do `StatefulBuilder` sem um `initState`/`dispose`,
          // a solução mais robusta é criar um widget que encapsule o diálogo e o controlador.

          // **Correção principal: Uso de um Widget dedicado para gestão do controlador**
          return _KwangaActionDialogContent(
            title: title,
            hint: hint,
            initialValue: initialValue,
          );
        },
      );
    },
  );
}

// Widget auxiliar para gerir o estado do controlador corretamente (dispose)
class _KwangaActionDialogContent extends StatefulWidget {
  final String title;
  final String hint;
  final String initialValue;

  const _KwangaActionDialogContent({
    required this.title,
    required this.hint,
    required this.initialValue,
  });

  @override
  State<_KwangaActionDialogContent> createState() =>
      _KwangaActionDialogContentState();
}

class _KwangaActionDialogContentState extends State<_KwangaActionDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // **CORREÇÃO CRÍTICA**: Dispor o controlador para evitar fugas de memória.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER AZUL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF235E8B),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // TEXTFIELD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF235E8B)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOTÕES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // CANCELAR
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // SALVAR
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, _controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF235E8B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Salvar",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}