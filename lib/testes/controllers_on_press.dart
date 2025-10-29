import 'package:flutter/material.dart';

class Item {
  final int id;
  final String content;
  bool isSelected;

  Item(this.id, this.content, {this.isSelected = false});
}

class ContextualAppBarExample extends StatefulWidget {
  const ContextualAppBarExample({super.key});

  @override
  State<ContextualAppBarExample> createState() => _ContextualAppBarExampleState();
}

class _ContextualAppBarExampleState extends State<ContextualAppBarExample> {
  final List<Item> _items = List.generate(
    6,
        (index) => Item(index, 'Mensagem número ${index + 1}'),
  );

  bool get _isSelectionMode => _selectedItemsCount > 0;

  int get _selectedItemsCount => _items.where((item) => item.isSelected).length;

  void _toggleSelection(Item item) {
    setState(() {
      item.isSelected = !item.isSelected;
      if (_selectedItemsCount == 0) {
      }
    });
  }

  void _clearSelection() {
    setState(() {
      for (var item in _items) {
        item.isSelected = false;
      }
    });
  }

  void _deleteSelectedItems() {
    setState(() {
      _items.removeWhere((item) => item.isSelected);
      _clearSelection();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Itens selecionados apagados!')),
    );
  }

  void _editFirstSelectedItem() {
    if (_selectedItemsCount == 1) {
      final selectedItem = _items.firstWhere((item) => item.isSelected);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Editando: ${selectedItem.content}')),
      );
      _clearSelection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione apenas um item para editar.')),
      );
    }
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _clearSelection,
      ),
      title: Text(
        '$_selectedItemsCount selecionado${_selectedItemsCount > 1 ? 's' : ''}',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        if (_selectedItemsCount == 1)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Editar',
            onPressed: _editFirstSelectedItem,
          ),
        IconButton(
          icon: const Icon(Icons.archive, color: Colors.white),
          tooltip: 'Arquivar',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Arquivando $_selectedItemsCount itens!')),
            );
            _clearSelection();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          tooltip: 'Apagar',
          onPressed: _deleteSelectedItems,
        ),
      ],
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('Itens do Chat/Lista'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];

          return GestureDetector(
            onLongPress: () {
              if (_isSelectionMode) {
                _toggleSelection(item);
              } else {
                setState(() {
                  item.isSelected = true;
                });
              }
            },
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(item);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              color: item.isSelected ? Colors.lightBlue.withOpacity(0.3) : null,
              child: Row(
                children: [
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Icon(
                        item.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: item.isSelected ? Colors.blue : Colors.grey,
                      ),
                    ),
                  // Conteúdo do item
                  Expanded(
                    child: Text(item.content),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}