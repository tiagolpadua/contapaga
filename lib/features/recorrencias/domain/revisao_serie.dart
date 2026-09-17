import 'package:contapaga/features/recorrencias/domain/civil_date.dart';
import 'package:contapaga/features/recorrencias/domain/money.dart';
import 'package:contapaga/features/recorrencias/domain/regra_recorrencia.dart';

class RevisaoSerie {
  final CivilDate dataEfeito;
  final RegraRecorrencia regra;
  final Money valorBase;

  const RevisaoSerie({
    required this.dataEfeito,
    required this.regra,
    required this.valorBase,
  });
}
