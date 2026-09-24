# ADR 001 — base local e evolução para Pro

> Revisão de escopo na fase 1 (16/09/2026): lançamento somente em celulares Android/Google Play. iOS, App Store e respectivos requisitos foram adiados; referências ao lançamento conjunto abaixo representam a decisão inicial superada. Titular pessoa física, domínio `mutumsoft.com.br` e applicationId escolhido `br.com.mutumsoft.contapaga`. Ver [registro de distribuição](FASE_1_DISTRIBUICAO.md).

Data: 16/09/2026. Status: diretriz de arquitetura definida para atender ao escopo aprovado; implementação pendente.

## Contexto e decisão

A v1 funciona offline, sem conta de usuário. Uma futura versão Pro poderá oferecer login Google e backup em nuvem. Separar apresentação, casos de uso, domínio e adaptadores para adicionar esses serviços sem reescrever as regras financeiras ou acoplar telas ao banco/provedor.

- Domínio em Dart independente de Flutter, banco, login e rede: recorrências, ocorrências, baixas, cálculos e datas civis. Serviços de relógio e geração de ocorrências substituíveis para testes.
- Casos de uso acessam contratos de repositórios; o adaptador local transacional é a fonte operacional da v1. Apresentação não acessa SQL nem SDKs externos diretamente.
- IDs estáveis independentes do banco e de login, esquema e backups versionados, migrações testáveis. Identidade de uma ocorrência deve suportar várias datas na mesma competência; não usar apenas série + mês. A chave de geração precisa ser idempotente, com política de revisão da série e preservação das baixas.
- Gerar ocorrências por intervalos consultados, de forma limitada e idempotente; não materializar uma série diária infinita. Preservar ocorrências realizadas e referências estáveis ao alterar a agenda.
- Separar serialização/restauração de backup do destino de armazenamento. V1 usa arquivo local; Pro poderá usar um adaptador remoto. Restauração validada antes de substituir a base, com transação e nova conciliação dos agendamentos de notificação.
- Identidade/autenticação, direitos de uso Pro e destino de backup são responsabilidades separadas. Implementar somente os contratos necessários à v1; documentar os pontos de integração futuros, sem criar login fictício, backend ou mecanismo de assinatura agora.
- Notificações atrás de um serviço próprio, alimentado pelo mesmo domínio da lista. Persistir a alteração financeira antes de conciliar agendamentos; falha de permissão/agendamento não desfaz a gravação financeira. Settlement, reversão, edição, encerramento e restauração devem cancelar/atualizar notificações afetadas de forma idempotente.
- Valores financeiros em centavos; datas de vencimento sem conversão UTC. Horários de lembretes usam fuso local do dispositivo e exigem revisão dos agendamentos após alterações relevantes de fuso/hour.

## Limites e trabalho futuro

Backup em nuvem restaura um conjunto de dados; sincronização concilia alterações simultâneas. Não prometer sincronização automática pela mera inclusão de login Google. Na Pro, decidir associação/migração dos dados locais à conta, isolamento por titular, troca/exclusão de conta, segurança do backup e política de restauração. Se sincronização for incluída, projetar conflitos, revisões, exclusões e operação offline especificamente.

Escolha de banco, estado, navegação, biblioteca de notificações e provedor remoto ainda pendente. Verificação local: `flutter --version` retornou Flutter 3.47.4 e Dart 3.13.3 em 16/09/2026; piso adotado de Android API 24 e iOS 15, coerente com o SDK local e a matriz oficial. Dependências selecionadas na fase 2 devem respeitar esse piso. Não foram executados builds nesta decisão.

## Notificações locais: validação necessária

Usar recursos locais do sistema para a v1 offline, sem backend de push. Tratar autorização negada, cancelamento, abertura pelo toque, reinício/atualização, fuso, restrições de bateria e limites de agendamento. Avaliar janela limitada de agendamentos e sua reposição; não assumir execução diária ilimitada em segundo plano nem precisão exata de horário. Provar o comportamento com o app fechado em aparelhos reais e documentar o alcance suportado antes do lançamento.

Referências oficiais consultadas: [agendamento local Apple](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/SchedulingandHandlingLocalNotifications.html), [alarmes Android](https://developer.android.com/develop/background-work/services/alarms). Produto definiu resumo diário às 9h ajustável; alcance e critérios estão no registro da fase 0. Candidato técnico para avaliação: `flutter_local_notifications` 22.3.1, cujo requisito documentado de Flutter 3.38.1 é atendido pelo SDK local; a integração e os builds ainda não foram validados. Fontes: [plataformas Flutter](https://docs.flutter.dev/reference/supported-platforms) e [documentação do plugin](https://pub.dev/packages/flutter_local_notifications). O Android local usa `minSdkVersion = 24`; o projeto iOS já usa deployment target 15.0, mas ainda declara iPad (`TARGETED_DEVICE_FAMILY = "1,2"`), a corrigir na implementação para iPhone.
