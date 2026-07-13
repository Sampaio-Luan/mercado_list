import '../../core/constants/enums/tema_app.dart';
import '../../core/constants/enums/tipo_visualizacao_itens.dart';

class PreferenciasUsuario {
  final TemaApp tema;
  final TipoVisualizacaoItens tipoVisualizacao;
  final int? ultimaListaAberta;
  final bool mostrarItensComprados;

  const PreferenciasUsuario({
    required this.tema,
    required this.tipoVisualizacao,
    this.ultimaListaAberta,
    required this.mostrarItensComprados,
  });

  factory PreferenciasUsuario.padrao() {
    return const PreferenciasUsuario(
      tema: TemaApp.escuro,
      tipoVisualizacao: TipoVisualizacaoItens.lista,
      ultimaListaAberta: null,
      mostrarItensComprados: true,
    );
  }

  PreferenciasUsuario copyWith({
    TemaApp? tema,
    TipoVisualizacaoItens? tipoVisualizacao,
    int? ultimaListaAberta,
    bool? mostrarItensComprados,
  }) {
    return PreferenciasUsuario(
      tema: tema ?? this.tema,
      tipoVisualizacao: tipoVisualizacao ?? this.tipoVisualizacao,
      ultimaListaAberta: ultimaListaAberta ?? this.ultimaListaAberta,
      mostrarItensComprados:
          mostrarItensComprados ?? this.mostrarItensComprados,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tema': TemaApp.obterRotulo(tema: tema),
      'tipoVisualizacao': TipoVisualizacaoItens.obterRotulo(tipo: tipoVisualizacao),
      'ultimaListaAberta': ultimaListaAberta,
      'mostrarItensComprados': mostrarItensComprados,
    };
  }

  factory PreferenciasUsuario.fromJson(
    Map<String, dynamic> json,
  ) {
    return PreferenciasUsuario(
      tema: TemaApp.obterPorRotulo(rotulo: json['tema']),
      tipoVisualizacao:
          TipoVisualizacaoItens.obterPorRotulo(rotulo: json['tipoVisualizacao']),
      ultimaListaAberta: json['ultimaListaAberta'],
      mostrarItensComprados:
          json['mostrarItensComprados'] ?? true,
    );
  }
}