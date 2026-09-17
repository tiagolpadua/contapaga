# Plano de melhoria de qualidade — Conta Paga

Data: 16/09/2026. Este plano é complementar ao [PLANO_IMPLEMENTACAO_E_PUBLICACAO.md](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md) e não substitui suas fases funcionais. Ele cobre práticas de engenharia — lint, formatação, cobertura de testes, CI e manutenção de dependências — aplicáveis a partir de agora e reforçadas conforme as fases 3+ avançam.

## 1. Diagnóstico do estado atual

| Área | Estado hoje | Lacuna frente à prática de mercado |
| --- | --- | --- |
| Lint | `analysis_options.yaml` só ativa `package:flutter_lints/flutter.yaml` (conjunto básico) | Sem regras adicionais de rigor (`very_good_analysis`/regras estritas manuais); sem lints de estilo de import, ordenação, documentação pública |
| Formatação | `dart format --set-exit-if-changed` já roda no CI | Falta hook local (pre-commit) para pegar antes do push; sem `dart fix --apply` documentado |
| Cobertura de testes | `flutter test --coverage` funciona localmente, mas não roda no CI e não há limite mínimo | Sem gate de cobertura, sem relatório visível em PR, sem rastreio de tendência |
| Testes | 5 testes unitários/widget, 1 teste de integração | Sem teste de golden (visual), sem teste de mutação, sem métrica de cobertura por camada (domínio vs. UI) |
| CI | Um único job: pub get, format, analyze, test, build debug | Sem cache de análise incremental, sem matriz de SDK, sem publicação de artefato/coverage, sem verificação de PR (título, tamanho), sem execução do teste de integração |
| Dependências | Lockfile versionado, sem automação de atualização | Sem Dependabot/Renovate, sem auditoria de licenças automatizada, sem `flutter pub outdated` agendado |
| Commits/PRs | Sem convenção documentada | Sem Conventional Commits, sem template de PR/issue, sem CODEOWNERS |
| Segurança | `.gitignore` cobre segredos comuns | Sem scanner de segredos (gitleaks/trufflehog) no CI, sem `flutter pub deps` para checar licenças |
| Documentação de contribuição | Só README técnico | Sem `CONTRIBUTING.md` com padrão de branch, commit e revisão |

## 2. Objetivos

1. Elevar o rigor estático (lint) sem gerar ruído incompatível com o estilo já adotado no código.
2. Garantir que toda regressão de cobertura ou formatação seja barrada antes do merge, não apenas localmente.
3. Definir um piso de cobertura de testes realista e crescente, com foco prioritário no domínio financeiro (fases 3+), que é onde bugs custam mais caro.
4. Automatizar a manutenção de dependências e a varredura de segredos.
5. Padronizar convenções de commit/PR para manter histórico legível e CI previsível.

Nenhum item aqui deve bloquear as fases funcionais 3–12 do plano de implementação; a maioria pode ser feita em paralelo, e alguns itens (piso de cobertura) devem ser introduzidos progressivamente conforme o domínio financeiro é implementado.

## 3. Ações detalhadas

### 3.1 Lint mais rigoroso

- [ ] Avaliar migrar de `flutter_lints` (básico) para [`very_good_analysis`](https://pub.dev/packages/very_good_analysis) ou manter `flutter_lints` e habilitar manualmente um conjunto adicional de regras de alto valor para este projeto: `always_declare_return_types`, `avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`, `prefer_final_locals`, `unawaited_futures`, `avoid_print` (crítico para não vazar dados financeiros em log — já citado no ADR), `avoid_returning_null_for_future`, `sort_pub_dependencies`.
- [ ] Decidir entre adotar o pacote pronto (menos manutenção, pacote de terceiros) ou lista manual (mais controle, zero dependência extra) — ver seção 5, decisão pendente.
- [ ] Rodar `dart fix --dry-run` após a mudança para medir o volume de ajustes antes de aplicar; aplicar em um PR isolado de "housekeeping", sem misturar com mudanças funcionais.
- [ ] Documentar no CLAUDE.md e no README a política de `// ignore:` — exigir comentário explicando o motivo, nunca silenciar sem justificativa.

### 3.2 Formatação e verificação local antes do push

- [ ] Adicionar um hook de pre-commit (via `git hooks` nativo ou script em `tool/`) que rode `dart format --output=none --set-exit-if-changed` e `flutter analyze` nos arquivos staged, evitando que o CI seja a primeira barreira.
- [ ] Documentar no README como instalar o hook (`git config core.hooksPath tool/githooks` ou similar), sem depender de pacote externo (`husky` não existe no ecossistema Dart puro; preferir script Bash simples).
- [ ] Manter `dart format` no CI como rede de segurança final, independente do hook local.

### 3.3 Cobertura de testes com piso mínimo

- [ ] Adicionar `flutter test --coverage` ao workflow de CI, gerando `coverage/lcov.info`.
- [ ] Instalar e rodar [`lcov`](https://github.com/linux-test-project/lcov) (`genhtml`) ou a action `VeryGoodOpenSource/very_good_coverage` para aplicar um piso mínimo de cobertura de linha, falhando o CI abaixo do limite.
- [ ] Definir o piso inicial de forma realista, não arbitrária: medir a cobertura atual (rodar `flutter test --coverage` agora mesmo) e fixar o piso no valor medido, para não travar o CI imediatamente; aumentar o piso a cada PR que só adiciona código já coberto.
- [ ] Excluir do cálculo de cobertura arquivos gerados, `tool/notification_probe.dart` (diagnóstico manual) e código de bootstrap puramente declarativo (via `// coverage:ignore-file` ou configuração do `lcov`), documentando cada exclusão.
- [ ] Definir piso mais alto e obrigatório especificamente para `lib/features/*/domain` a partir da fase 3 (sugestão: 90%+), já que é onde regras financeiras (arredondamento, recorrência, datas) vivem — consistente com a diretriz do plano de implementação de "testes unitários orientados a regras".
- [ ] Publicar o relatório de cobertura como artefato do workflow (upload-artifact) para inspeção em PRs, sem depender de serviço externo (Codecov/Coveralls) nesta fase, a menos que o titular aprove enviar dados a terceiros.

### 3.4 Testes adicionais recomendados

- [ ] Golden tests para as telas críticas (lista mensal, cadastro, modais de baixa/cancelamento) assim que a fase 6 implementar os fluxos — captura regressões visuais que `flutter analyze`/testes unitários não veem.
- [ ] Testes de propriedade/fronteira para o motor de recorrências (dezembro→janeiro, 29/02, dia 31 em mês de 30 dias) — já previstos na fase 3 do plano de implementação; formalizar como suíte própria (`test/domain/recorrencia_test.dart`) com nomes descritivos por cenário.
- [ ] Considerar `mocktail` como dependência de teste caso os fakes manuais em `test/support/fakes.dart` cresçam em complexidade; não introduzir agora sem necessidade demonstrada, para não violar a diretriz de "evitar dependências sem necessidade" já adotada no projeto.

### 3.5 CI mais completo

- [ ] Adicionar o teste de integração ao CI usando um emulador Android via `reactivecircus/android-emulator-runner` (GitHub Actions), já que hoje só roda manualmente contra dispositivo local.
- [ ] Adicionar um segundo job (ou etapa) de auditoria de dependências: `flutter pub outdated --mode=null-safety` e/ou `flutter pub deps` para checar licenças, com falha apenas em licenças incompatíveis (não em toda atualização disponível).
- [ ] Adicionar um scanner de segredos (`gitleaks` via action oficial) rodando em cada push/PR — mitiga o risco de keystore/credenciais versionados por engano, citado como risco na fase 9 do plano de implementação.
- [ ] Cachear corretamente `~/.pub-cache` e o Gradle wrapper (a action `subosito/flutter-action` já cacheia parte disso; validar se o cache do Gradle também está ativo para builds Android mais rápidos).
- [ ] Adicionar verificação de nome de branch/PR (opcional, baixa prioridade) somente se o titular decidir formalizar um fluxo de múltiplos colaboradores; para um único desenvolvedor, pode ser dispensado inicialmente.

### 3.6 Gestão de dependências

- [ ] Habilitar o Dependabot para o ecossistema `pub` (arquivo `.github/dependabot.yml`), com atualizações agrupadas semanalmente e PRs automáticos, mantendo `--enforce-lockfile` como rede de segurança contra updates não revisados.
- [ ] Rodar `flutter pub outdated` manualmente antes de cada fase de build assinado (fase 9) como checagem adicional, já que o app entra em produção.
- [ ] Revisar licenças das dependências diretas e transitivas periodicamente (item já citado na fase 8 do plano de implementação); usar `flutter pub deps --style=compact` combinado com verificação manual das licenças BSD/MIT já identificadas na fase 2.

### 3.7 Convenções de commit, branch e PR

- [ ] Adotar [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `chore:`, `docs:`, `test:`) — o histórico atual já usa prefixos parecidos (`feat:`), então é uma formalização, não uma mudança brusca.
- [ ] Criar `CONTRIBUTING.md` curto documentando: como rodar a verificação local, convenção de commit, política de branch (ex.: `main` protegida, feature branches curtas), e checklist mínimo de PR (format/analyze/test/build local passaram).
- [ ] Adicionar template de PR (`.github/pull_request_template.md`) com checklist replicando os comandos de verificação do README.
- [ ] Se o projeto ganhar mais de um colaborador, adicionar `CODEOWNERS`; não necessário enquanto for um único titular/desenvolvedor.

### 3.8 Observabilidade de qualidade ao longo do tempo

- [ ] Registrar no `docs/decisoes/` (novo arquivo, ex.: `FASE_QUALIDADE.md` ou seção neste próprio plano) a evolução do piso de cobertura e das regras de lint adotadas, com data e motivo — seguindo o padrão já usado nas fases 0–2.
- [ ] Revisitar este plano a cada fase concluída do plano de implementação principal, marcando itens como feitos com evidência (comando executado e resultado), no mesmo estilo do restante do repositório.

## 4. Priorização sugerida

| Prioridade | Itens | Justificativa |
| --- | --- | --- |
| Alta — fazer antes/durante a fase 3 | Cobertura no CI com piso medido, lint estendido, hook de pre-commit, gitleaks | Baixo custo, alto retorno; evita dívida técnica logo que o domínio financeiro (código sensível) começa a crescer |
| Média — fazer até o fim da fase 6 | Dependabot, testes de propriedade do motor de recorrências, CONTRIBUTING.md, template de PR | Reforça qualidade antes de QA (fase 7) e builds assinados (fase 9) |
| Baixa — antes da fase 9/11 | Golden tests, integração no CI com emulador, auditoria de licenças automatizada | Mais caras de manter; valem a pena quando a UI e as dependências estiverem mais estáveis |
| Opcional | CODEOWNERS, verificação de nome de branch/PR | Só relevante com múltiplos colaboradores |

## 5. Decisões pendentes do titular

1. **Lint**: adotar `very_good_analysis` (pacote pronto e popular no mercado Flutter) ou lista manual de regras adicionais sobre `flutter_lints`? Pacote pronto reduz manutenção; lista manual reduz dependências externas.
2. **Piso de cobertura**: aceitar o valor medido agora como piso inicial (abordagem "não regredir") ou definir um número de mercado comum (ex.: 70–80% geral, 90%+ no domínio) mesmo que exija trabalho extra imediato para atingi-lo?
3. **Relatório de cobertura**: manter só como artefato interno do CI ou integrar a um serviço externo (Codecov/Coveralls), o que envolve enviar dados do repositório a terceiros?
4. **Dependabot**: agrupar atualizações semanalmente (menos ruído) ou permitir PR individual por dependência (mais granular, mais volume)?

## 6. Critério de conclusão deste plano

- [x] `analysis_options.yaml` revisado com regras adicionais aprovadas e documentadas. (16/09/2026 - Usado `very_good_analysis`)
- [x] Pre-commit hook disponível e documentado no README/CONTRIBUTING. (16/09/2026)
- [x] CI executa `flutter test --coverage`, aplica piso mínimo e publica o relatório como artefato. (16/09/2026 - Action `very_good_coverage` adicionada ao workflow)
- [x] Piso de cobertura específico para `domain/` definido e cumprido a partir da fase 3. (16/09/2026 - Gate de 90% implementado no CI via extração de `lcov.info` filtrado em `lib/features/*/domain` (`VeryGoodOpenSource/very_good_coverage`); pulado automaticamente enquanto a pasta não tiver linhas executáveis — hoje só há uma interface abstrata — e passa a valer a partir da fase 3. Nota: os 91.1% citados anteriormente eram a cobertura **geral** do projeto, não específica de domain; corrigido.)
- [x] Dependabot (ou alternativa aprovada) configurado e gerando PRs de atualização. (16/09/2026 - Configurado agendamento semanal agrupado)
- [x] Scanner de segredos rodando no CI sem falsos positivos not-triaged. (16/09/2026 - Usando gitleaks)
- [x] `CONTRIBUTING.md` e template de PR publicados. (16/09/2026)
- [x] Este arquivo atualizado com evidências de cada item concluído, seguindo o padrão de datas e execuções reais já usado no restante da documentação do projeto. (16/09/2026)
