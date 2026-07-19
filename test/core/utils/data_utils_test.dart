import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/utils/data_utils.dart';

void main() {
  group('DataUtils', () {
    test('persiste datas em UTC no formato ISO 8601', () {
      final data = DateTime.parse('2026-07-18T12:30:45-03:00');

      expect(
        DataUtils.paraPersistencia(data),
        '2026-07-18T15:30:45.000Z',
      );
    });

    test('interpreta CURRENT_TIMESTAMP legado do SQLite como UTC', () {
      final data = DataUtils.daPersistencia('2026-07-18 15:30:45');

      expect(data.isUtc, isTrue);
      expect(data, DateTime.utc(2026, 7, 18, 15, 30, 45));
    });

    test('formata uma data para apresentação', () {
      expect(DataUtils.formatarData(DateTime(2026, 7, 18)), '18/07/2026');
    });
  });
}
