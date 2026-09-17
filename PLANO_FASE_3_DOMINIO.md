# Plano detalhado — Fase 3: domínio financeiro

Data: 16/09/2026. Detalha a execução da [Fase 3](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md#fase-3--implementar-e-testar-o-domínio-financeiro) do plano de implementação. Escopo: regras de negócio em Dart puro, independentes de Flutter/SQLite/UI (ADR 001), cobrindo os exemplos de aceite de [FASE_0_PRODUTO.md](docs/decisoes/FASE_0_PRODUTO.md). Não inclui persistência real (fase 4) nem telas (fases 5–6) — os repositórios usados aqui são interfaces, implementadas por fakes em memória nos testes.

## 1. Objetivo e critério de saída

Produzir um pacote de domínio (`lib/features/recorrencias/domain/`) testável sem dispositivo, tal que a mesma ocorrência produza status e totais consistentes para qualquer consumidor futuro (lista, resumo, avisos, histórico, notificações). Saída: todos os exemplos numéricos da fase 0 convertidos em testes automatizados verdes, mais os cenários de fronteira listados abaixo.

Fora do escopo desta fase: SQLite, `ChangeNotifier`/controllers de tela, agendamento de notificações real (apenas o contrato consumido por elas), formulários e navegação.

## 2. Modelo de dados

Local: `lib/features/recorrencias/domain/`.

### 2.1 `Money` (`money.dart`)

- Envolve um `int` de centavos (BRL). Nunca usar `double` para valores monetários — conforme CLAUDE.md e ADR 001.
- Operações: `+`, `-`, comparação, `isNegative`, `isZero`, formatação pt-BR delegada à camada de apresentação (o domínio não formata string, só expõe `cents`).
- Construtor de validação: rejeita valores negativos onde a regra de negócio exigir positivo (baixa), mas o tipo em si aceita negativos porque totais/saldos podem ser negativos.
- Arredondamento de média: método estático `Money.averageRoundedHalfUp(List<Money> values)` — soma em centavos, divide, arredonda meio-centavo para cima (regra explícita da fase 0: empate arredonda para cima). Implementar com aritmética inteira (`(sum * 2 + count) ~/ (count * 2)` ou equivalente testado), nunca `double`.

### 2.2 `CivilDate` (`civil_date.dart`)

- Wrapper sobre `DateTime` que força meia-noite local e bloqueia qualquer operação que dependa de UTC. Construtor a partir de `year/month/day`; método `Clock.now()` (interface já existente em `lib/core/time/clock.dart`) é a única fonte de "hoje", nunca `DateTime.now()` direto dentro do domínio.
- Métodos: `addMonths(int n)` com ajuste de dia inexistente (regra dos dias 29–31, ver 2.4), `addDays(int n)`, `addYears(int n)` com regra 29/02, comparação (`isBefore`, `isAfter`, `isSameOrBefore`), `weekday` (convenção segunda=1..domingo=7 para bater com a âncora semanal da fase 0).
- `compareTo`/`Comparable<CivilDate>` para ordenação estável em listas.

### 2.3 `Competencia` (`competencia.dart`)

- Par `(ano, mes)` — nunca mês isolado (o protótipo usava mês sem ano; é a simplificação a não repetir). Deriva de `CivilDate` (`Competencia.fromDate`), suporta `previous()`, `next()`, comparação e um método `precedentes(int n)` que gera as N competências imediatamente anteriores (usado na previsão de 6 meses).

### 2.4 `RegraRecorrencia` (`regra_recorrencia.dart`)

- `enum Frequencia { diaria, semanal, mensal, anual }`.
- Campos: `frequencia`, `intervalo` (int positivo, "a cada N unidades"), `diasSemana` (`Set<int>`, só relevante para semanal, vazio caso contrário — validar não-vazio na construção quando `frequencia == semanal`), `dataInicial` (`CivilDate`), `terminoTipo` (`enum TerminoTipo { nunca, data, quantidade }`), `terminoData` (`CivilDate?`), `terminoQuantidade` (`int?`).
- Validações no construtor (lançam `ArgumentError` com mensagem clara, nunca silenciam para zero): intervalo ≥ 1; `diasSemana` não vazio quando semanal; exatamente um de `terminoData`/`terminoQuantidade` presente conforme `terminoTipo`; quantidade ≥ 1.
- Regra de ajuste de dia inexistente (mensal/anual): método `diaEfetivoNoMes(ano, mes)` que retorna o dia da série ajustado ao último dia do mês quando necessário, preservando o dia original da série para os meses seguintes (não "desliza" a âncora — cada geração recalcula a partir do dia original de `dataInicial`).
- Regra anual 29/02: se `dataInicial.day == 29 && dataInicial.month == 2`, anos comuns geram 28/02, bissextos geram 29/02 (não desloca para março).
- Convenção semanal: semana de segunda a domingo ancorada na semana de `dataInicial`; dias anteriores ao início são filtrados; a primeira data elegível é a ocorrência 1 (contagem começa aí, não em "semana 1" abstrata).

### 2.5 `SerieRecorrente` (`serie_recorrente.dart`)

- Entidade principal: `id` (String estável, gerado uma vez na criação — `Uuid` ou equivalente, nunca derivado de série+mês), `descricao`, `tipo` (`enum TipoLancamento { receita, despesa }`), `contraparte` (String?), `debitoAutomatico` (bool), `valorBase` (`Money`, "por ocorrência", nunca valor total dividido), `regra` (`RegraRecorrencia`), `revisoes` (lista de `RevisaoSerie`, ver 2.6), `dataEncerramento` (`CivilDate?` — última data inclusiva ativa).
- Nunca mutável in-place: edições criam uma nova `RevisaoSerie`; a série em si é imutável fora do factory de edição (`copyWith` interno controlado, não exposto livremente, para impedir editar campos fora do fluxo de revisão aprovado).

### 2.6 `RevisaoSerie` (`revisao_serie.dart`)

- Suporta a "edição prospectiva" da fase 0: `dataEfeito` (`CivilDate`, hoje ou futura), `regra` (nova `RegraRecorrencia` válida a partir de `dataEfeito`), `valorBase` (`Money?`, se o valor também mudar).
- Uma série tem 0+ revisões ordenadas por `dataEfeito`; a geração de ocorrências (3.1) usa a revisão vigente em cada data consultada, nunca uma revisão só.
- Regra de bloqueio (validada no caso de uso de edição, seção 4.2, não no construtor da entidade): revisão não pode eliminar uma ocorrência já baixada nem reduzir `terminoQuantidade` abaixo da quantidade de ocorrências já preservadas (baixadas ou abertas) antes de `dataEfeito`.

### 2.7 `Ocorrencia` (`ocorrencia.dart`)

- `id` estável e **distinto** do id da série — necessário porque uma série pode ter várias ocorrências na mesma competência (ex.: diária). Gerar como `"$serieId#$dataVencimento#$sequencia"` na primeira materialização e persistir esse id (não recalcular a cada geração — ver 3.1 sobre idempotência).
- Campos: `serieId`, `id`, `dataVencimento` (`CivilDate`), `competencia` (`Competencia`, derivada de `dataVencimento`), `valorPrevisto` (`Money` — valor base da revisão vigente, ou previsão calculada para variável, ver 4.1), `baixa` (`Baixa?`).
- `enum StatusOcorrencia { aberta, baixada, atrasada, pendenteAutomatico }` como getter computado (não campo persistido) a partir de `baixa`, `dataVencimento`, `debitoAutomatico` e a data "hoje" injetada — nunca calculado a partir de `DateTime.now()` direto.
  - `baixada`: `baixa != null`.
  - `atrasada`: `baixa == null && dataVencimento.isBefore(hoje)`.
  - `pendenteAutomatico`: `atrasada && debitoAutomatico` — regra explícita da fase 0: débito automático vencido sem baixa é pendência visível, nunca pagamento inferido. Nunca setar `baixada` automaticamente por causa do flag.
  - `aberta`: nenhum dos anteriores.

### 2.8 `Baixa` (`baixa.dart`)

- `valorPago` (`Money`, > 0 — validar), `dataPagamento` (`CivilDate`, ≤ hoje — bloquear futura), `registradoEm` (timestamp de auditoria, não é regra de negócio de exibição, útil para depuração).
- Baixa é integral, uma por ocorrência (sem parciais) — reforçado pelo caso de uso (4.3), não pela entidade isoladamente.

### 2.9 Passos de Implementação (1 por 1)

> Regra de ouro: Só passe para o próximo passo quando o anterior tiver testes 100% verdes.

- [x] **Passo 1:** Implementar `Money` + testes (ver 2.1).
- [x] **Passo 2:** Implementar `CivilDate` e `Competencia` + testes (ver 2.2 e regra 29/02).
- [x] **Passo 3:** Implementar `RegraRecorrencia` e `Frequencia` + testes (ver 2.3).
- [x] **Passo 4:** Implementar as classes base `SerieRecorrente`, `Baixa`, `Ocorrencia` e `PreferenciasNotificacao` (apenas a estrutura).
- [x] **Passo 5:** Implementar o motor de Geração de Ocorrências (`gerar_ocorrencias`) + testes exaustivos das regras de calendário (ver 3.1).
- [x] **Passo 6:** Implementar `dar_baixa` e `reverter_baixa` + testes.
- [x] **Passo 7:** Implementar `calcular_resumo_mensal` e `calcular_painel` + testes.
- [x] **Passo 8:** Implementar `prever_valor_ocorrencia` + testes.
- [x] **Passo 9:** Implementar `editar_serie` (geração de `RevisaoSerie`) + testes.
- [x] **Passo 10:** Utilitários: Parsing pt-BR seguro e Extensões.

### `PreferenciasNotificacao` (`preferencias_notificacao.dart`)

- `horario` (hora/minuto local), `ativo` (bool), `antecedenciaDias` (int, 1–10, padrão 3) — usado pelo painel interno e pelo resumo diário (consumido pela fase 6/notificações, mas o cálculo do conjunto "vencidas + hoje + próximos" vive no domínio, seção 4.4, para ser compartilhado entre painel e notificação).

## 3. Geração de ocorrências

Local: `lib/features/recorrencias/domain/geracao_ocorrencias.dart`.

### 3.1 Contrato e idempotência

- Função pura `List<Ocorrencia> gerarOcorrencias(SerieRecorrente serie, {required CivilDate desde, required CivilDate ate})` — **intervalo limitado e consultado**, nunca materializa a série inteira (ADR 001: proibido gerar diária infinita).
- Idempotência: chamar duas vezes com o mesmo intervalo produz exatamente as mesmas `Ocorrencia` (mesmo `id`, mesma `dataVencimento`), mesmo que internamente percorra revisões diferentes. Testar explicitamente (gerar duas vezes, comparar listas).
- Reconciliação com o que já existe no repositório é responsabilidade do caso de uso (4.1), não desta função — a função de geração é sem efeitos colaterais e não sabe o que já foi persistido; o caso de uso decide o que é novo vs. já materializado comparando por `id`.
- Respeita `dataEncerramento` (não gera após) e `regra.terminoData`/`terminoQuantidade` (não gera após o término, e a contagem de "quantidade" considera ocorrências geradas — pagas ou abertas — não reinicia após reversão, conforme fase 0).
- Nunca gera antes de `serie.regra.dataInicial` nem antes de `dataEfeito` da revisão vigente em cada trecho do intervalo.

### 3.2 Algoritmo por frequência

- **Diária**: passo de `intervalo` dias a partir de `dataInicial` (ou `dataEfeito` da revisão), truncado por `desde`/`ate`.
- **Semanal**: para cada semana múltipla de `intervalo` a partir da semana-âncora, gera uma ocorrência por dia em `diasSemana` que seja ≥ `dataInicial` (ou `dataEfeito`), respeitando o filtro "dias anteriores ao início são excluídos" da fase 0.
- **Mensal**: para cada mês múltiplo de `intervalo` a partir de `dataInicial.month`, usa `regra.diaEfetivoNoMes(ano, mes)`.
- **Anual**: mesma lógica, com o caso especial 29/02 (2.4).
- Cada ocorrência carrega `sequencia` (índice 1-based na série, consumido para aplicar `terminoQuantidade`).

### 3.3 Cenários de fronteira a testar (mapeados 1:1 aos exemplos da fase 0)

| Cenário | Entrada | Esperado |
| --- | --- | --- |
| Virada dezembro→janeiro | mensal, vencimento 31/12/2026 | próxima ocorrência 31/01/2027, sem colisão de `id`/competência |
| Dia 31 em mês curto | mensal, dia 31, fevereiro | 28/02 (ou 29 se bissexto), preservando dia 31 nos meses de 31 dias seguintes |
| Anual 29/02 | início 29/02/2024 | 28/02/2025, 28/02/2026, 28/02/2027, **29/02/2028** |
| Diária finita | início 30/09/2026, intervalo 1, 3 ocorrências | 30/09, 01/10, 02/10 — previsto R$10 em set, R$20 em out (valor R$10 cada) |
| Semanal com término por data | início 14/09/2026 (segunda), seg+qua, intervalo 2 semanas, término inclusive 28/09 | 14/09, 16/09, 28/09 — **exclui 30/09** mesmo que a quantidade permitisse mais |
| Semanal com quantidade | mesma regra, término por 4 ocorrências | 14/09, 16/09, 28/09, 30/09 |
| Não gerar antes do início | início futuro | lista vazia para `desde` anterior ao início |
| Idempotência | mesma série, mesmo intervalo, 2 chamadas | listas idênticas por id |
| Revisão prospectiva | edição com `dataEfeito` 20/09 | ocorrência de 19/09 preservada com a regra antiga; a partir de 20/09 usa a regra nova |

## 4. Casos de uso (application services do domínio)

Local: `lib/features/recorrencias/domain/casos_uso/`. Cada caso de uso depende só de interfaces (repositórios, `Clock`), nunca de implementação concreta — permite testar com fakes, igual ao padrão já usado em `test/support/fakes.dart` para `mes/`.

### 4.1 Previsão de valor variável (`prever_valor_ocorrencia.dart`)

- Regra fase 0: média das baixas da mesma série nas 6 competências **imediatamente anteriores** à competência da ocorrência (excluindo o próprio mês), sem buscar mais longe se houver menos de 6 baixas disponíveis; sem baixas na janela usa `valorBase`.
- Implementação: `Competencia.precedentes(6)` a partir da competência da ocorrência, filtra baixas dessa série cuja `ocorrencia.competencia` esteja na janela, extrai `baixa.valorPago`, aplica `Money.averageRoundedHalfUp`.
- Testar os exemplos exatos da fase 0: abr R$100 + jun R$120 + ago R$110 → R$110 em setembro; meses sem baixa não contam como zero; baixas de setembro (mês corrente) e anteriores a março (fora da janela de 6) não entram; janela totalmente vazia → valor base; arredondamento de meio-centavo (R$100,00 + R$100,00 + R$100,01 → R$100,00; mas R$100,00 + R$100,01 → R$100,01 no empate de 2 valores).

### 4.2 Editar série (`editar_serie.dart`)

- Recebe `SerieRecorrente` atual, nova `RegraRecorrencia`/`valorBase`, `dataEfeito`.
- Valida: `dataEfeito >= hoje` (Clock injetado); busca ocorrências já baixadas ou abertas geradas a partir de `dataEfeito` que seriam eliminadas pela nova regra — se houver, lança exceção de domínio (`EdicaoBloqueadaException`) sem persistir nada.
- Valida especificamente `terminoQuantidade` novo ≥ quantidade de ocorrências já preservadas antes de `dataEfeito` (contando baixadas e abertas, sem contar revertidas como "consumidas" segundo a regra "reversão não altera a contagem").
- Sucesso: retorna a série com nova `RevisaoSerie` anexada — não decide persistência (isso é fase 4).

### 4.3 Dar baixa / reverter (`dar_baixa.dart`, `reverter_baixa.dart`)

- `darBaixa(Ocorrencia, valorPago, dataPagamento, {required Clock clock})`: valida `dataPagamento <= hoje`, `valorPago > 0`, `ocorrencia.baixa == null` (bloqueia segunda baixa — "duplicidade" da fase 0); retorna `Ocorrencia` copiada com `baixa` preenchida. Não persiste (fase 4 trata a transação).
- `reverterBaixa(Ocorrencia)`: exige `baixa != null`; retorna a ocorrência com `baixa: null`, preservando `id`/`sequencia` (mesma ocorrência reaberta, não uma nova).
- Ambos são funções puras sobre o modelo — sem I/O — para serem testáveis sem fakes de repositório.

### 4.4 Painel de avisos / resumo global (`calcular_painel.dart`)

- Função compartilhada entre o painel mensal (fase 6) e o corpo do resumo de notificação (fase 6/core-notifications): dado um conjunto de ocorrências, `hoje` e `antecedenciaDias`, retorna listas separadas de vencidas, hoje, próximas (até `hoje + antecedenciaDias` inclusive) e pendentes automáticas — todas excluindo baixadas.
- Importante: esta função **não filtra por mês selecionado no app** quando usada pelo resumo global (fase 0: notificação é global, independente do mês aberto); o painel mensal (tela) filtra depois por competência ao consumir o mesmo cálculo. Deixar isso explícito no doc da função para não ser mal usado na fase 6.

### 4.5 Resumo mensal / saldo (`calcular_resumo_mensal.dart`)

- Dado o conjunto de ocorrências de uma competência: `aPagar` = soma das despesas abertas (valor previsto), `aReceber` = soma das receitas abertas, `saldoPrevisto` = receitas (baixadas com valor real + abertas com valor previsto) − despesas (mesma regra).
- Testar o exemplo exato da fase 0: receita aberta R$3.000 + despesa aberta R$200 + despesa baixada R$110 → a receber R$3.000, a pagar R$200, saldo R$2.690. E o ciclo baixa→reversão: baixar despesa de R$200 por R$220 → a pagar 0, saldo R$2.670; cancelar reversão mantém; confirmar restaura a pagar R$200 e saldo R$2.690.

## 5. Validação de entrada

Local: `lib/features/recorrencias/domain/validacao/`.

- `ValidadorFormularioSerie`: nome não vazio, valor > 0 (formulário nunca aceita valor "base" zero/negativo — distinto de saldo, que pode ser negativo), dia/data coerente com a frequência, competência de início válida, data de baixa não futura.
- Parsing pt-BR de moeda (`R$ 1.234,56` → centavos) e de data (`dd/mm/aaaa`) como funções puras testáveis isoladamente, retornando `Result`-like (sucesso/erro tipado) — **nunca** convertendo erro de parsing em zero silencioso (regra explícita do plano macro).
- Essas funções serão consumidas pelos formulários da fase 6, mas moram no domínio porque a regra ("o que é um valor válido") é de negócio, não de widget.

## 6. Estrutura de arquivos proposta

```
lib/features/recorrencias/
  domain/
    money.dart
    civil_date.dart
    competencia.dart
    regra_recorrencia.dart
    serie_recorrente.dart
    revisao_serie.dart
    ocorrencia.dart
    baixa.dart
    preferencias_notificacao.dart
    geracao_ocorrencias.dart
    casos_uso/
      prever_valor_ocorrencia.dart
      editar_serie.dart
      dar_baixa.dart
      reverter_baixa.dart
      calcular_painel.dart
      calcular_resumo_mensal.dart
    validacao/
      validador_formulario_serie.dart
      parsing_pt_br.dart
    repositorios/
      serie_repository.dart        # interface, implementação real só na fase 4
      ocorrencia_repository.dart   # interface, implementação real só na fase 4
test/domain/
  money_test.dart
  civil_date_test.dart
  competencia_test.dart
  regra_recorrencia_test.dart
  geracao_ocorrencias_test.dart
  prever_valor_ocorrencia_test.dart
  editar_serie_test.dart
  dar_baixa_test.dart
  calcular_painel_test.dart
  calcular_resumo_mensal_test.dart
  validacao_test.dart
```

As interfaces de repositório entram nesta fase (contrato), mas **sem implementação SQLite** — isso é fase 4. Os testes desta fase usam fakes em memória, seguindo o padrão de `test/support/fakes.dart`.

## 7. Ordem de implementação sugerida

1. `Money` + testes (base de tudo, sem dependências).
2. `CivilDate` + `Competencia` + testes (fronteiras de mês/ano/bissexto isoladas antes de entrar na recorrência).
3. `RegraRecorrencia` + validações + testes de `diaEfetivoNoMes`/29-02 isolados da geração.
4. `SerieRecorrente` / `RevisaoSerie` / `Ocorrencia` / `Baixa` (modelos, sem lógica pesada).
5. `geracao_ocorrencias.dart` + toda a tabela da seção 3.3 — é o núcleo de maior risco, fazer com cobertura alta antes de seguir.
6. `dar_baixa` / `reverter_baixa` (mais simples, valida o modelo de `Ocorrencia`/`Baixa`).
7. `calcular_resumo_mensal` + `calcular_painel` (consomem geração + baixa já prontos).
8. `prever_valor_ocorrencia` (depende de `Competencia.precedentes` e `Money.averageRoundedHalfUp`, já prontos).
9. `editar_serie` (o mais dependente de estado — precisa de geração + baixa funcionando para validar bloqueios).
10. Validação de formulário/parsing pt-BR (independente do resto, pode ser feito em paralelo por outra pessoa se houver).

Cada item só avança para o próximo quando `flutter test test/domain/<arquivo>_test.dart` está verde — não acumular dívida de teste entre os passos, dado que o item 5 é o de maior risco de regressão silenciosa.

## 8. Definição de pronto (Definition of Done) desta fase

- [ ] Todas as entidades/regras da seção 2 implementadas em Dart puro, sem import de `package:flutter/*` nem `package:sqflite/*` em `lib/features/recorrencias/domain/`.
- [ ] `gerarOcorrencias` cobre todos os cenários da tabela 3.3, incluindo o teste explícito de idempotência.
- [ ] Todos os exemplos numéricos da seção "Exemplos de aceite já definidos" de [FASE_0_PRODUTO.md](docs/decisoes/FASE_0_PRODUTO.md) viraram testes automatizados e passam.
- [ ] `editar_serie` bloqueia os dois casos de eliminação de histórico descritos na fase 0 (ocorrência baixada e redução de quantidade abaixo do preservado), com teste que comprova o bloqueio (exceção lançada, nada mutado).
- [ ] `dar_baixa`/`reverter_baixa` cobrem: baixa dupla bloqueada, data futura bloqueada, reversão preserva `id`, reversão após confirmação recalcula status corretamente quando combinada com `calcular_resumo_mensal`.
- [ ] Parsing pt-BR nunca retorna zero silencioso em entrada inválida — testado com entradas malformadas.
- [ ] `dart format`, `flutter analyze` e `flutter test` (incluindo o novo `test/domain/`) passam limpos, mantendo o gate de cobertura de `domain/` do CI (ver [PLANO_MELHORIA_QUALIDADE.md](PLANO_MELHORIA_QUALIDADE.md)) — esta fase é o primeiro código real que populará esse gate de 90%.
- [ ] Nenhuma dependência nova adicionada ao `pubspec.yaml` sem necessidade demonstrada (o modelo acima não exige pacote externo além de, opcionalmente, `uuid` para geração de IDs — avaliar se `Object.hash`/timestamp+contador bastam antes de adicionar dependência).

## 9. Riscos específicos desta fase

| Risco | Mitigação |
| --- | --- |
| Geração de ocorrências não idempotente ao reconciliar com o que já foi persistido (fase 4) | Testar explicitamente "gerar duas vezes → mesma lista" nesta fase, antes de existir persistência para mascarar o problema |
| Arredondamento de média usar `double` por engano | `Money.averageRoundedHalfUp` só com aritmética inteira; revisar em code review dedicado |
| `CivilDate` vazando UTC por conversão implícita do `DateTime` do Dart | Encapsular todo acesso a `DateTime` dentro de `civil_date.dart`; nunca expor o `DateTime` bruto para fora do domínio |
| Edição de série permitir apagar histórico por descuido | `editar_serie` testado com os dois exemplos de bloqueio da fase 0 como casos obrigatórios, não opcionais |
| Escopo desta fase crescer para dentro da fase 4/6 (persistência, telas) | Repositórios ficam só como interface; nenhuma implementação SQLite ou widget nesta fase |
