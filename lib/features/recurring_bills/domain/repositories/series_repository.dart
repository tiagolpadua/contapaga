import 'package:contapaga/features/recurring_bills/domain/civil_date.dart';
import 'package:contapaga/features/recurring_bills/domain/recurring_series.dart';

abstract interface class SeriesRepository {
  Future<List<RecurringSeries>> listActive();
  Future<List<RecurringSeries>> listAll();
  Future<RecurringSeries?> findById(String id);
  Future<void> save(RecurringSeries series);
  Future<void> close(String id, CivilDate closedAt);
}
