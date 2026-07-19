import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tema_app.dart';
import '../../../shared/widgets/menu_contexto/acao_menu_de_contexto.dart';
import '../../../shared/widgets/menu_contexto/menu_de_contexto.dart';
import '../../../shared/widgets/menu_contexto/tema_menu_de_contexto.dart';
import '../../categoria/screen/categorias_screen.dart';
import '../../preferencias_usuario/preferencias_provider.dart';
import '../model/lista_model.dart';

import 'lista_ui.dart';

class ListaDeListasScreen extends StatefulWidget {
  const ListaDeListasScreen({super.key});

  @override
  State<ListaDeListasScreen> createState() => _ListaDeListasScreenState();
}

class _ListaDeListasScreenState extends State<ListaDeListasScreen> {
  final List<ListaUi> listasTeste = [
    ListaUi(
      lista: Lista(
        id: 1,
        titulo: 'Compras do Mês',
        descricao: 'Supermercado e itens básicos',
        dataCriacao: DateTime.now().subtract(const Duration(days: 30)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 2)),
      ),
      quantidadeItens: 45,
      quantidadeItensComprados: 32,
    ),
    ListaUi(
      lista: Lista(
        id: 2,
        titulo: 'Churrasco de Domingo',
        descricao: 'Itens para churrasco da família',
        dataCriacao: DateTime.now().subtract(const Duration(days: 20)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 1)),
      ),
      quantidadeItens: 0,
      quantidadeItensComprados: 0,
    ),
    ListaUi(
      lista: Lista(
        id: 3,
        titulo: 'Material Escolar',
        descricao: 'Volta às aulas',
        dataCriacao: DateTime.now().subtract(const Duration(days: 60)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 15)),
      ),
      quantidadeItens: 22,
      quantidadeItensComprados: 22,
    ),
    ListaUi(
      lista: Lista(
        id: 4,
        titulo: 'Reforma da Casa',
        descricao: 'Tintas, cimento e ferramentas',
        dataCriacao: DateTime.now().subtract(const Duration(days: 12)),
        dataAlteracao: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      quantidadeItens: 35,
      quantidadeItensComprados: 8,
    ),
    ListaUi(
      lista: Lista(
        id: 5,
        titulo: 'Farmácia',
        descricao: 'Medicamentos e higiene',
        dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
        dataAlteracao: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      quantidadeItens: 12,
      quantidadeItensComprados: 4,
    ),
    ListaUi(
      lista: Lista(
        id: 6,
        titulo: 'Festa de Aniversário',
        descricao: 'Doces, salgados e decoração',
        dataCriacao: DateTime.now().subtract(const Duration(days: 25)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 3)),
      ),
      quantidadeItens: 50,
      quantidadeItensComprados: 20,
      selecionado: true,
    ),
    ListaUi(
      lista: Lista(
        id: 7,
        titulo: 'Viagem para Praia',
        descricao: 'Itens para as férias',
        dataCriacao: DateTime.now().subtract(const Duration(days: 40)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 10)),
      ),
      quantidadeItens: 17,
      quantidadeItensComprados: 7,
    ),
    ListaUi(
      lista: Lista(
        id: 8,
        titulo: 'Pet Shop',
        descricao: 'Ração e acessórios',
        dataCriacao: DateTime.now().subtract(const Duration(days: 8)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 1)),
      ),
      quantidadeItens: 9,
      quantidadeItensComprados: 2,
    ),
    ListaUi(
      lista: Lista(
        id: 9,
        titulo: 'Natal',
        descricao: 'Presentes e decoração',
        dataCriacao: DateTime.now().subtract(const Duration(days: 180)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 120)),
      ),
      quantidadeItens: 40,
      quantidadeItensComprados: 15,
    ),
    ListaUi(
      lista: Lista(
        id: 10,
        titulo: 'Ferramentas',
        descricao: 'Oficina e manutenção',
        dataCriacao: DateTime.now().subtract(const Duration(days: 70)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 18)),
      ),
      quantidadeItens: 25,
      quantidadeItensComprados: 5,
    ),
    ListaUi(
      lista: Lista(
        id: 11,
        titulo: 'Tecnologia',
        descricao: 'Peças e periféricos',
        dataCriacao: DateTime.now().subtract(const Duration(days: 14)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 2)),
      ),
      quantidadeItens: 14,
      quantidadeItensComprados: 1,
    ),
    ListaUi(
      lista: Lista(
        id: 12,
        titulo: 'Academia',
        descricao: 'Suplementos e acessórios',
        dataCriacao: DateTime.now().subtract(const Duration(days: 9)),
        dataAlteracao: DateTime.now().subtract(const Duration(hours: 18)),
      ),
      quantidadeItens: 11,
      quantidadeItensComprados: 9,
    ),
    ListaUi(
      lista: Lista(
        id: 13,
        titulo: 'Café da Empresa',
        descricao: 'Reposição da copa',
        dataCriacao: DateTime.now().subtract(const Duration(days: 3)),
        dataAlteracao: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      quantidadeItens: 16,
      quantidadeItensComprados: 10,
    ),
    ListaUi(
      lista: Lista(
        id: 14,
        titulo: 'Mudança',
        descricao: 'Caixas e organização',
        dataCriacao: DateTime.now().subtract(const Duration(days: 90)),
        dataAlteracao: DateTime.now().subtract(const Duration(days: 30)),
      ),
      quantidadeItens: 28,
      quantidadeItensComprados: 18,
    ),
    ListaUi(
      lista: Lista(
        id: 15,
        titulo: 'Compras Rápidas',
        descricao: 'Itens urgentes',
        dataCriacao: DateTime.now().subtract(const Duration(days: 1)),
        dataAlteracao: DateTime.now(),
      ),
      quantidadeItens: 5,
      quantidadeItensComprados: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasProvider>();
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.15,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/padrao2.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 20),
                    child: Text(
                      'Mercado List',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: Theme.of(
                          context,
                        ).textTheme.titleLarge?.fontSize,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0, // Nível de desfoque da sombra
                            color:
                                Theme.of(context).colorScheme.primary.withAlpha(
                                      100,
                                    ), // Cor da sombra com transparência
                            offset: Offset(1, 1), // Deslocamento no eixo X e Y
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(60),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        final atual = preferencias.preferencias.tema;

                        preferencias.alterarTema(
                          atual == TemaApp.claro
                              ? TemaApp.escuro
                              : TemaApp.claro,
                        );
                      },
                      icon: Theme.of(context).brightness == Brightness.dark
                          ? Icon(PhosphorIcons.cloudSunFill, size: 40)
                          : Icon(PhosphorIcons.moonStarsFill, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listasTeste.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Divider(
                      height: 0,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(30),
                      thickness: 0.5,
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2.0,
                          vertical: 0,
                        ),
                        child: ListaWidget(listaUi: listasTeste[index]),
                      ),
                      onTap: () {
                        setState(() {
                          preferencias.alterarUltimaLista(
                            listasTeste[index].lista.id!,
                          );
                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          BotaoAddNovaLista(),
          MenuDeContexto(
            // gatilho: Gatilho.toque,
            tema: const TemaMenuContexto(
              glassmorphism: true,
              blurFundo: 15,
            ),
            acoes: [
              AcaoMenuContexto(
                titulo: 'Editar',
                icone: PhosphorIcons.pencilLine,
                aoSelecionar: () {},
              ),
              AcaoMenuContexto(
                titulo: 'Duplicar',
                icone: PhosphorIcons.copy,
                aoSelecionar: () {},
              ),
              AcaoMenuContexto(
                titulo: 'Excluir',
                icone: PhosphorIcons.trash,
                destrutivo: true,
                aoSelecionar: () {},
              ),
            ],

            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              width: 350,
              child: Text('Lista de Compras'),
            ),
          ),
          BotaoDrawer(
            icone: PhosphorIcons.stackPlusBold,
            titulo: 'Gerenciar Categorias',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      CategoriasScreen(), //CategoriasScreen(),
                ),
              );
            },
            cor: Colors.green,
          ),
          BotaoDrawer(
            icone: PhosphorIcons.clockCounterClockwiseBold,
            titulo: 'Histórico de Compras',
            onPressed: () {},
            // (){
            //   Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (context) => const HistoricoScreen(),
            //     ),
            //   );
            // },
            cor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class BotaoDrawer extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final Color? background;
  final Color cor;
  final Function() onPressed;
  const BotaoDrawer({
    super.key,
    required this.icone,
    required this.titulo,
    this.background,
    required this.cor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 0.3,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(10),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          color: cor.withAlpha(20),
          child: InkWell(
            onTap: onPressed,
            child: Row(
              spacing: 15,
              children: [
                Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: cor.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icone, color: cor, size: 23),
                ),
                Text(
                  titulo,
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BotaoAddNovaLista extends StatelessWidget {
  const BotaoAddNovaLista({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Icon(
                PhosphorIcons.notePencil,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              Text(
                'Nova Lista',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaWidget extends StatelessWidget {
  final ListaUi listaUi;
  const ListaWidget({super.key, required this.listaUi});

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferenciasProvider>();
    final bool selecionada =
        prefs.preferencias.ultimaListaAberta == listaUi.lista.id;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: selecionada
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.surface.withAlpha(0),
      ),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IndicadorDeItens(
            qtdTotal: listaUi.quantidadeItens,
            qtdComprado: listaUi.quantidadeItensComprados,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 3,
              children: [
                Text(
                  listaUi.lista.titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMd().format(listaUi.lista.dataCriacao!),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                        fontSize: 10,
                      ),
                    ),
                    Text('|', style: TextStyle(fontSize: 10)),
                    Text(
                      DateFormat.yMd().format(listaUi.lista.dataAlteracao!),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(150),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 25,
            onPressed: () {},
            icon: Icon(PhosphorIcons.pencilThin),
          ),
        ],
      ),
    );
  }
}

class IndicadorDeItens extends StatelessWidget {
  final int qtdTotal;
  final int qtdComprado;
  const IndicadorDeItens({
    super.key,
    required this.qtdTotal,
    required this.qtdComprado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        qtdTotal == qtdComprado && qtdTotal != 0
            ? CircleAvatar(
                radius: 13,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withAlpha(200),
                child: Center(
                  child: Icon(
                    PhosphorIconsBold.check,
                    color: Theme.of(context).colorScheme.inverseSurface,
                    size: 16,
                  ),
                ),
              )
            : CircularPercentIndicator(
                radius: 13,
                lineWidth: 5.0,
                percent:
                    qtdTotal == 0 ? 0 : (qtdComprado / qtdTotal) * 100 / 100,
                progressColor: Theme.of(context).colorScheme.inverseSurface,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha(50),
              ),
        Text('$qtdComprado/$qtdTotal', style: TextStyle(fontSize: 10)),
      ],
    );
  }
}
