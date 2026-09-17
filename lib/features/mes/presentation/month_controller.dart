import 'package:flutter/foundation.dart';

import '../../../core/time/clock.dart';
import '../domain/month_repository.dart';

final class MonthController extends ChangeNotifier {
  MonthController({required this.repository, required Clock clock})
    : _selectedMonth = _monthOf(clock.now());

  static DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);
  final MonthRepository repository;
  DateTime _selectedMonth;
  DateTime get selectedMonth => _selectedMonth;
  bool _busy = false;
  bool get busy => _busy;
  String? _error;
  String? get error => _error;

  Future<void> restore() async {
    _selectedMonth = await repository.loadSelectedMonth() ?? _selectedMonth;
  }

  Future<void> move(int offset) async {
    if (_busy) return;
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
    if (next.year < 1 || next.year > 9999) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await repository.saveSelectedMonth(next);
      _selectedMonth = next;
    } catch (_) {
      _error = 'Não foi possível salvar o mês selecionado. Tente novamente.';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
