String normalizeListType(String value) {
  final v = value.toLowerCase().trim();

  const actionVariants = {
    'acção',
    'accao',
    'acções',
    'acoes',
    'ações',
    'acao',
    'action',
    'lista de accao',
    'lista de acção',
    'lista de accoes',
    'lista de acções',
  };

  const entryVariants = {
    'entrada',
    'entradas',
    'entry',
    'lista de entradas',
    'lista de entrada',
  };

  if (actionVariants.contains(v)) return 'action';
  if (entryVariants.contains(v)) return 'entry';

  return v;
}
