# Conta Paga

Aplicativo Flutter para organização pessoal de contas a pagar e receber. Lançamento inicial: celulares Android, Brasil, pt-BR. iOS adiado.

## Estado

Fase 2 concluída (verificação local; Android físico e CI remota pendentes): inicialização própria, tema Material, navegação mensal em português, ajustes/sobre e persistência local do mês selecionado. Cadastro, motor de recorrências, baixas, histórico financeiro e backup serão implementados nas fases 3–6. Nenhum dado financeiro fictício é carregado no app.

## Ambiente

- Flutter **3.47.4**, Dart **3.13.3**; versão também registrada em `.fvmrc` e CI. Com FVM instalado: `fvm install` e prefixar comandos com `fvm`.
- JDK 17, Android SDK 36, licenças Android aceitas. Android mínimo: API 24 (7.0).
- Executar `flutter doctor -v` antes de configurar um novo ambiente. Não versionar `android/local.properties`.

```sh
flutter pub get --enforce-lockfile
flutter run --dart-define=APP_ENV=development
```

Sem `APP_ENV`, o app usa `production`. Os ambientes usam arquivos SQLite separados (`contapaga_development.db` e `contapaga.db`). Não são configurações de backend nem credenciais. Testes usam fakes ou banco próprio, sem tocar nos dados de produção.

## Verificação

```sh
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
flutter test integration_test/storage_test.dart -d emulator-5554
flutter build apk --debug --dart-define=APP_ENV=development
```

Trocar `emulator-5554` pelo ID retornado por `flutter devices`. O teste de integração usa exclusivamente `contapaga_integration_test.db` e remove esse arquivo ao terminar.

A CI em `.github/workflows/flutter.yml` executa formatação, análise, testes e APK debug. A execução remota depende de envio ao GitHub; não é publicação. Assinatura de distribuição e AAB da Play permanecem na fase 9. O bloco release ainda usa a configuração debug herdada e não é artefato apto a publicar.

## Arquitetura

- `lib/app`: composição de dependências, ambiente, tema e localização.
- `lib/core`: contratos de relógio, armazenamento e notificações; adaptadores SQLite/Android.
- `lib/features/mes`: contrato de repositório, adaptador local, controller e tela mensal.
- `lib/features/ajustes`: ajustes e informações do aplicativo.
- `test/support`: fakes restritos aos testes.
- `integration_test`: verificações com plugins reais em Android.
- `tool/notification_probe.dart`: entrada isolada de diagnóstico, bloqueada em release; não usada pelo app normal.

Estado com `ChangeNotifier` e navegação com `Navigator`/`MaterialPageRoute`. Dependências injetadas por construtor, sem service locator. Repositórios financeiros tipados serão definidos com o domínio na fase 3; preferências não devem receber entidades financeiras serializadas.

## Versão e distribuição

Usar `major.minor.patch+build` em `pubspec.yaml`; incrementar build a cada upload. `APP_VERSION` pode ser passado ao build para identificar a versão no diálogo Sobre, acompanhando a versão do pubspec. Identidade Android: `br.com.mutumsoft.contapaga`; escolher esse identificador no código não o reserva no Play Console.

Antes de gerar uma versão de distribuição, concluir contratos/registro da fase 1, assinatura da fase 9 e inventário de privacidade. Segredos e keystores ficam fora do Git.

## Referências

- [Plano](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md)
- [Decisões de produto](docs/decisoes/FASE_0_PRODUTO.md)
- [Distribuição](docs/decisoes/FASE_1_DISTRIBUICAO.md)
- [Arquitetura local e futura Pro](docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md)
- [Base técnica e evidências](docs/decisoes/FASE_2_BASE_TECNICA.md)
- [Handoff funcional](handoff/README.md)

HTML, CSS e runtime do handoff são documentação e não constam dos assets Flutter.

## Contribuindo

Consulte o [CONTRIBUTING.md](CONTRIBUTING.md) para saber como configurar o pre-commit hook e seguir nossos padrões de commit e PR.
