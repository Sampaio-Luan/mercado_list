import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Conjunto de propriedades visuais que permitem customizar totalmente a
/// aparência do `PainelPesquisa`, mantendo o padrão visual
/// do Material 3 como base quando nada é especificado.
///
/// Todas as propriedades são opcionais: quando não informadas, valores
/// sensatos derivados do `Theme` atual são usados automaticamente.
@immutable
class EstiloPainelPesquisa {
  const EstiloPainelPesquisa({
    this.corFundo,
    this.corAlcaArraste,
    this.corIconeFechar,
    this.corIconeTelaCheia,
    this.corBordaCampoPainelPesquisa,
    this.corFundoCampoPainelPesquisa,
    this.corItemSelecionado,
    this.corIconeSelecionado,
    this.raioBordaSuperior = 24.0,
    this.raioBordaCampoPainelPesquisa = 16.0,
    this.estiloTitulo,
    this.estiloTextoItem,
    this.estiloTextoItemDestacado,
    this.estiloTextoSubtitulo,
    this.iconePesquisa = PhosphorIcons.magnifyingGlass,
    this.iconeLimparPesquisa = PhosphorIcons.x,
    this.iconeFechar = PhosphorIcons.x,
    this.iconeExpandir = PhosphorIcons.arrowsOut,
    this.iconeRecolher = PhosphorIcons.arrowsIn,
    this.iconeItemSelecionadoUnico = PhosphorIcons.checkCircle,
    this.iconeItemNaoSelecionadoUnico = PhosphorIcons.circle,
    this.elevacao = 8.0,
  });

  /// Cor de fundo do painel do bottom sheet. Padrão: `colorScheme.surface`.
  final Color? corFundo;

  /// Cor da pequena alça (handle) exibida no topo, usada como indicativo
  /// visual de que o painel é arrastável.
  final Color? corAlcaArraste;

  /// Cor do ícone de fechar (X) no cabeçalho.
  final Color? corIconeFechar;

  /// Cor do ícone de alternância para tela cheia.
  final Color? corIconeTelaCheia;

  /// Cor da borda do campo de pesquisa.
  final Color? corBordaCampoPainelPesquisa;

  /// Cor de fundo do campo de pesquisa.
  final Color? corFundoCampoPainelPesquisa;

  /// Cor de fundo aplicada ao item quando selecionado.
  final Color? corItemSelecionado;

  /// Cor do ícone/indicador de seleção (checkbox ou círculo de seleção).
  final Color? corIconeSelecionado;

  /// Raio de arredondamento dos cantos superiores do bottom sheet.
  final double raioBordaSuperior;

  /// Raio de arredondamento do campo de pesquisa.
  final double raioBordaCampoPainelPesquisa;

  /// Estilo de texto do título no cabeçalho.
  final TextStyle? estiloTitulo;

  /// Estilo de texto base aplicado a cada item da lista.
  final TextStyle? estiloTextoItem;

  /// Estilo de texto aplicado às partes destacadas (coincidentes com a
  /// pesquisa) de cada item da lista.
  final TextStyle? estiloTextoItemDestacado;

  /// Estilo de texto aplicado ao subtítulo opcional de cada item.
  final TextStyle? estiloTextoSubtitulo;

  /// Ícone exibido no início do campo de pesquisa.
  final IconData iconePesquisa;

  /// Ícone exibido para limpar o texto da pesquisa.
  final IconData iconeLimparPesquisa;

  /// Ícone do botão de fechar o bottom sheet.
  final IconData iconeFechar;

  /// Ícone do botão para expandir para tela cheia.
  final IconData iconeExpandir;

  /// Ícone do botão para recolher da tela cheia ao tamanho anterior.
  final IconData iconeRecolher;

  /// Ícone exibido quando um item está selecionado (somente no modo de
  /// seleção única).
  final IconData iconeItemSelecionadoUnico;

  /// Ícone exibido quando um item não está selecionado (somente no modo
  /// de seleção única).
  final IconData iconeItemNaoSelecionadoUnico;

  /// Elevação (sombra) aplicada ao painel do bottom sheet.
  final double elevacao;
}
