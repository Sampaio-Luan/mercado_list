abstract interface class ContratoMapper<T> {
  T doMapa(Map<String, dynamic> mapa);

  Map<String, dynamic> paraMapa(T objeto);

  T daNuvem(Map<String, dynamic> mapa);

  Map<String, dynamic> paraNuvem(T objeto);
}
