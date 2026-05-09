abstract class ContratoModelo<T> {
  Map<String, dynamic> paraBd(T objeto);
  T doBd(Map<String, dynamic> map);
  Map<String, dynamic> paraNuvem(T objeto);
  T daNuvem(Map<String, dynamic> map);
  T copia();
}
