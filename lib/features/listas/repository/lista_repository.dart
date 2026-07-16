import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../../../core/contracts/contrato_repository.dart';
import '../model/lista_model.dart';
import '../screen/lista_ui.dart';

class ListaRepository implements ContratoRepository<Lista> {
  late Database dbLocal;
  List<Lista> listas = [];
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

  ListaRepository() {
    _iniciarRepositorio();
  }

  void _iniciarRepositorio() async {
    if (listas.isEmpty) {
      await recuperarTodos();
      log(
        name: LogId.listaRepository,
        '_iniciarRepositorio(): precisou iniciar o repositorio ',
      );
    }
  }

  String titulobyid(int id) {
    return listasTeste
        .firstWhere((element) => element.lista.id == id)
        .lista
        .titulo;
  }

  @override
  Future<Lista> criar(Lista objeto) {
    throw UnimplementedError();
  }

  @override
  Future<Lista> editar(Lista objeto) {
    throw UnimplementedError();
  }

  @override
  Future<bool> excluir(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Lista> recuperar(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Lista>> recuperarTodos() {
    throw UnimplementedError();
  }
}
