# Fase 2 — base Flutter Android

Data: 16/09/2026. Implementação e verificações concluídas nesta execução, exceto Android físico (pendente de inventário do titular). Escopo Android; iOS adiado.

## Ambiente verificado

`flutter doctor -v`: sem problemas. Flutter 3.47.4 stable (9584c6713b), Dart 3.13.3, JDK 17.0.6, Android SDK/build-tools 36.0.0, licenças aceitas; Xcode 26.6 disponível mas fora do alvo. Emulador Pixel_9 com Android 16/API 36. Android físico não conectado nesta execução.

A base anterior passou `flutter analyze`, teste do contador e `flutter build apk --debug` antes das mudanças. Isso comprova apenas a compilação do template anterior.

## Decisões técnicas

- Flutter fixado em `.fvmrc` e workflow de CI. Lockfile versionado; CI usa `--enforce-lockfile`.
- `ChangeNotifier` com injeção por construtor; `Navigator` com rotas Material. Sem pacote adicional de estado/roteamento nesta escala.
- SQLite por `sqflite`, isolado em adaptador de armazenamento; repositório do mês selecionado depende de contrato. Banco inicial contém apenas preferências; esquema financeiro e migrações nas fases 3–4.
- `Clock` substituível; domínio financeiro futuro deve usar datas civis, sem inferir UTC do relógio.
- `intl` e `flutter_localizations` para pt-BR. Tema altera somente cores Material.
- Ambientes development/production com bancos distintos, sem login/backend. Fakes ficam em testes; diagnóstico de notificações possui entrada própria e não executa em release.
- Application ID/namespace Android aplicados: `br.com.mutumsoft.contapaga`; nome Conta Paga; minSdk explícito 24. Isso não reserva a identidade na Play.
- Assinatura release de produção continua pendente na fase 9. Nenhuma credencial incluída na CI.

## Dependências e licenças

Versões resolvidas: `sqflite` 2.4.4 (BSD-2-Clause), `intl` 0.20.3 (BSD-3-Clause), `flutter_local_notifications` 22.3.1 (BSD-3-Clause), `timezone` 0.11.1 (BSD-2-Clause), `path` 1.9.1 (BSD-3-Clause); Flutter/localizações/testes fornecidos pelo SDK. Lockfile registra as transitivas. Plugins Android e dependências selecionadas serão validados pelo build; monitorar manutenção e releases nas atualizações.

Fontes oficiais dos pacotes consultadas: [sqflite](https://pub.dev/packages/sqflite), [intl](https://pub.dev/packages/intl), [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications). API do plugin também conferida no código da versão instalada. Atualização da restrição timezone para 0.11.1 resolveu a exigência do plugin 22.3.1.

## Notificações: avaliação antes de integrar o produto

Adaptador atrás de `NotificationScheduler`, inicialização separada de autorização. Nenhuma autorização é solicitada no bootstrap do app normal. A entrada `tool/notification_probe.dart` agenda aviso sintético após 20 segundos somente se a permissão já estiver concedida; negativa retorna false sem agendar.

Usa `inexactAllowWhileIdle`, sem permissão de alarme exato. Horário desejado sujeito ao Android. Datas do adaptador representam instantes; a conversão de data civil + fuso do aparelho para o resumo diário será responsabilidade da integração da fase 6. UTC no agendador não é usado como data financeira.

Plano de reposição: janela móvel limitada a 30 resumos diários, reconciliada ao abrir/retomar e após alterações; cancelar ou substituir IDs estáveis para não acumular alarmes. Não usar agendamento infinito de conteúdo financeiro estático. A reposição sem reabrir o app exige validação específica de execução em segundo plano; não está resolvida pela existência do plugin. Antes da fase 6, definir comportamento após esgotar a janela e validar no Android físico do titular. Documentação do plugin registra restrições de fabricantes e limites de alarmes; emulador não comprova entrega em todos os dispositivos.

## Evidências finais

Comandos executados nesta sessão, ambiente Flutter 3.47.4/Dart 3.13.3, emulador Pixel_9 (API 36):

- `flutter pub get --enforce-lockfile`: resolvido sem alterar o lockfile.
- `dart format --output=none --set-exit-if-changed lib test integration_test tool`: sem alterações (19 arquivos conformes).
- `flutter analyze`: nenhum problema encontrado.
- `flutter test`: 5 testes aprovados (domínio do controller do mês e widget de navegação/ajustes).
- `flutter test integration_test/storage_test.dart -d emulator-5554`: aprovado; SQLite preserva a seleção de mês após fechar/reabrir.
- `flutter build apk --debug --dart-define=APP_ENV=development`: gerado com sucesso.
- `tool/notification_probe.dart -d emulator-5554`: executado duas vezes.
  - Sem permissão concedida: `enabled=false scheduled=false pending=0` — nenhum agendamento ocorre sem autorização.
  - Após `pm grant ... POST_NOTIFICATIONS`: `NOTIFICATION_WINDOW count=30` (janela de reposição agenda e cancela os 30 IDs de teste) e `enabled=true scheduled=true pending=1` (dois agendamentos com o mesmo ID estável não duplicam pendências).
  - App desinstalado do emulador ao final para não deixar resíduo.

Pendente: execução em Android físico (inventário de aparelho ainda não feito pelo titular, fase 1) e execução remota da CI (depende de push ao GitHub). Nenhum bloqueio técnico identificado nesta verificação local.
