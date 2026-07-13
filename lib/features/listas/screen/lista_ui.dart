import '../model/lista_model.dart';

class ListaUi {
  Lista lista;
  bool selecionado;
  int quantidadeItens;
  int quantidadeItensComprados;

  ListaUi({
    required this.lista,
    this.selecionado = false,
    this.quantidadeItens = 0,
    this.quantidadeItensComprados = 0,
  });

  void setAddItens() {
    quantidadeItens++;
  }

  void setAddItensComprados() {
    quantidadeItensComprados++;
  }

  void setRemoveItensComprados() {
    quantidadeItensComprados--;
  }

  void setRemoveItens() {
    quantidadeItens--;
  }

  void setSelecionado() {
    selecionado = !selecionado;
  }
}
