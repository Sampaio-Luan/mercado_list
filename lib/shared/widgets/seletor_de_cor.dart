import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/constants/enums/cor.dart';

class SeletorDeCor extends StatefulWidget {
  final Cor corSelecionada;
  final ValueChanged<Cor> onCorSelecionada;

  const SeletorDeCor({
    super.key,
    required this.corSelecionada,
    required this.onCorSelecionada,
  });

  @override
  State<SeletorDeCor> createState() => _SeletorDeCorState();
}

class _SeletorDeCorState extends State<SeletorDeCor> {
  final ScrollController _controladorRolagem = ScrollController();
  final GlobalKey _chaveCorSelecionadaInicial = GlobalKey();
  late final Cor _corSelecionadaInicial;

  @override
  void initState() {
    super.initState();
    _corSelecionadaInicial = widget.corSelecionada;
    _agendarExibicaoDaCorSelecionadaInicial();
  }

  @override
  void dispose() {
    _controladorRolagem.dispose();
    super.dispose();
  }

  void _agendarExibicaoDaCorSelecionadaInicial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controladorRolagem.hasClients) return;
      final objetoRenderizado =
          _chaveCorSelecionadaInicial.currentContext?.findRenderObject();
      if (objetoRenderizado == null) return;

      _controladorRolagem.position.ensureVisible(
        objetoRenderizado,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(190),
        ),
      ),
      child: SingleChildScrollView(
        controller: _controladorRolagem,
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 5,
          children: [
            for (final cor in Cor.values)
              _OpcaoCor(
                key: ValueKey('cor-${cor.name}'),
                cor: cor,
                selecionada: widget.corSelecionada == cor,
                chaveCorSelecionadaInicial: cor == _corSelecionadaInicial
                    ? _chaveCorSelecionadaInicial
                    : null,
                aoSelecionar: widget.onCorSelecionada,
              ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoCor extends StatelessWidget {
  final Cor cor;
  final bool selecionada;
  final Key? chaveCorSelecionadaInicial;
  final ValueChanged<Cor> aoSelecionar;

  const _OpcaoCor({
    super.key,
    required this.cor,
    required this.selecionada,
    required this.chaveCorSelecionadaInicial,
    required this.aoSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    final corExibida = Theme.of(context).brightness == Brightness.light
        ? Cor.obterCor(cor: cor)
        : Cor.obterCor(cor: cor).withAlpha(200);

    return SizedBox.square(
      dimension: 45,
      child: Semantics(
        label: 'Cor ${cor.name}',
        selected: selecionada,
        button: true,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () => aoSelecionar(cor),
          child: Container(
            key: chaveCorSelecionadaInicial,
            decoration: BoxDecoration(
              color: selecionada ? corExibida.withAlpha(45) : corExibida,
              border:
                  selecionada ? Border.all(width: 3, color: corExibida) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: selecionada
                ? PhosphorIcon(
                    PhosphorIcons.sealCheckFill,
                    color: corExibida,
                    size: 30,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
