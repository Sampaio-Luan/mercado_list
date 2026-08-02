import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import '../../../core/constants/enums/prioridade.dart';
import '../model/filtro_itens.dart';

extension SituacaoItemApresentacao on SituacaoItem {
  String get rotulo => switch (this) {
        SituacaoItem.todos => 'Todos',
        SituacaoItem.pendentes => 'Pendentes',
        SituacaoItem.marcados => 'Marcados',
      };
}

extension PrioridadeApresentacao on Prioridade {
  String get rotulo => switch (this) {
        Prioridade.neutra => 'Neutra',
        Prioridade.baixa => 'Baixa',
        Prioridade.media => 'Média',
        Prioridade.alta => 'Alta',
      };
}

extension OrdenarPorApresentacao on OrdenarPor {
  String get rotulo => switch (this) {
        OrdenarPor.nome => 'Nome',
        OrdenarPor.preco => 'Preço',
        OrdenarPor.prioridade => 'Prioridade',
        OrdenarPor.data => 'Data',
      };
}

extension OrdemApresentacao on Ordem {
  String get rotulo => switch (this) {
        Ordem.ascendente => 'Crescente',
        Ordem.descendente => 'Decrescente',
      };
}
