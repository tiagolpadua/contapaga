# Conta Paga — plano de implementação e publicação

Data: 16/09/2026. Estado: fase 0 concluída documentalmente; fase 1 em andamento; fases 2–12 pendentes de implementação e validação.

## 1. Objetivo e fontes

Sair do projeto Flutter inicial e entregar o Conta Paga funcional, testado e disponível publicamente na Google Play Store, com processo de atualização e suporte definido.

Fontes locais: [contexto do projeto](CONTEXTO_DO_PROJETO.md), [handoff](handoff/README.md), [protótipo principal](<handoff/Contas Recorrentes.dc.html>), [variações](handoff/Variacoes.dc.html), [tokens visuais](handoff/styles.css), [pubspec.yaml](pubspec.yaml), [código inicial](lib/main.dart) e configurações Android/iOS. Os requisitos externos citados foram consultados para este planejamento e devem ser reconferidos antes da submissão. Não foram executados builds, testes ou consultas às contas das lojas nesta análise.

O handoff orienta os fluxos, conteúdos e regras funcionais. Por decisão do produto, a interface usará os widgets padrão do Flutter Material Design em sua forma original, aplicando somente um tema de cores. Essa decisão substitui a reprodução visual do Industry prevista originalmente no handoff e no contexto. Preservar tipografia, formas, espaçamentos internos, elevações e estados padrão dos componentes Material. Criar widgets personalizados somente quando uma necessidade real não puder ser atendida adequadamente pelos componentes existentes, mantendo a base Material Design.

As simplificações de datas, memória e valores sintéticos do protótipo não são regras adequadas à aplicação final. As decisões da fase 0 estão registradas em [decisões de produto](docs/decisoes/FASE_0_PRODUTO.md) e no [ADR 001](docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md); a diretriz visual Material acima já está definida.

## 2. Diagnóstico do ponto de partida

| Área | Evidência atual | Trabalho necessário |
| --- | --- | --- |
| Produto | Nome Conta Paga; uso pessoal/doméstico; receitas e despesas mensais | Fechar regras e recorte de lançamento |
| Interface | HTML de referência com lista, cadastro, histórico e dois modais | Implementar os fluxos com widgets padrão Flutter Material e tema de cores |
| Código | `lib/main.dart` é o contador Flutter; teste também é do contador | Implementar domínio, persistência, estado e telas |
| Dependências | Flutter e Cupertino Icons; Dart `^3.13.3` | Validar toolchain e selecionar dependências necessárias |
| Dados | Protótipo usa estado em memória e chaves sem ano | Persistência transacional e competências completas |
| Android | `com.example.contapaga`; release usa assinatura debug | Identidade definitiva, assinatura de distribuição e AAB |
| iOS | `com.example.contapaga`; deployment target 15.0; equipe configurada | Confirmar titularidade da equipe, Bundle ID e provisioning |
| Marca | Nome técnico nos manifests e ícones padrão do projeto | Nome exibido, ícones, splash e materiais das lojas |
| Qualidade | Sem testes financeiros ou integração do produto | Cobertura dos riscos de negócio e testes em dispositivos |
| Operação | Sem backend ou processo de release do produto identificado | Decidir armazenamento, suporte, privacidade e distribuição |

A presença de diretórios web e desktop não os inclui no lançamento. Por decisão do titular na fase 1, o lançamento atual é somente Android. iOS/App Store ficam adiados; referências Apple preservadas são planejamento futuro e não bloqueiam este lançamento.

## 3. Recorte aprovado para a versão 1.0

### Escopo funcional do handoff e diretriz visual atual

- Cadastro de receitas e despesas com recorrência diária, semanal, mensal ou anual, intervalo N e término nunca/por data/por quantidade, com valor por ocorrência fixo ou variável, com contraparte e indicação de débito automático.
- Navegação por mês, lista agrupada, resumo e painel mensal; notificações locais com resumo diário global às 9h, horário ajustável e opção de desativar.
- Baixa manual com valor e data editáveis, sem toast ou confirmação extra após salvar.
- Cancelamento de baixa com confirmação e apresentação dos dados registrados.
- Histórico com seis meses, gráfico e distinção entre previsão e realização.
- Previsão variável baseada em meses pagos; data real e navegação além do intervalo da demonstração.
- Widgets padrão do Flutter Material Design, com personalização somente das cores; utilizar tipografia e ícones Material padrão.
- Composição das telas conforme os fluxos do produto, com layout responsivo e dimensões padrão dos componentes; os 394 px e demais medidas do HTML não são requisitos de fidelidade visual.
- Validação de entradas, foco visível, nomes acessíveis e preservação dos alvos de toque acessíveis padrão do Material, sem compactá-los para reproduzir o protótipo.

### Caminho aprovado na fase 0

Aplicativo individual, pt-BR, BRL, offline, local, sem login, gratuito, sem anúncios ou assinatura, distribuído inicialmente no Brasil para celulares Android. Piso técnico Android API 24; iOS foi adiado na fase 1; selecionar dependências compatíveis e validar na fase 2. Tablets/iPad não são alvos desta versão.

Incluídos: edição prospectiva por data, encerramento, exportação/importação de backup por substituição confirmada, backup do sistema quando disponível e ajustes/ajuda/privacidade. Arquitetura preparada para futura Pro com login Google e backup em nuvem, conforme ADR 001; sem implementar esses serviços na v1 ou presumir sincronização.

Ficam fora: transações bancárias, emissão/leitura de boletos, Open Finance, compartilhamento familiar, outras moedas, reprogramação individual, push remoto/e-mail/WhatsApp, publicidade e cobrança por recursos. Recorrências não mensais e notificações locais foram incorporadas ao lançamento e exigem as tarefas adicionais abaixo.

## 4. Sequência, dependências e responsabilidades

| Fase | Resultado | Dependência | Responsável principal |
| --- | --- | --- | --- |
| 0 | Escopo e regras decididos | Nenhuma | Produto + desenvolvimento |
| 1 | Contas e identidade de distribuição encaminhadas | Decisões de titularidade da fase 0 | Titular do app |
| 2 | Base Flutter e verificações automatizadas | Fase 0 | Desenvolvimento |
| 3 | Domínio financeiro correto | Fase 0; integração após fase 2 | Desenvolvimento |
| 4 | Dados persistidos e recuperáveis | Fases 2–3 | Desenvolvimento |
| 5 | Tema de cores Material e navegação | Fases 0 e 2 | Desenvolvimento + design |
| 6 | Fluxos completos do produto | Fases 3–5 | Desenvolvimento |
| 7 | Qualidade, segurança e acessibilidade verificadas | Fase 6 | Desenvolvimento + QA |
| 8 | Privacidade e materiais das lojas prontos | Escopo fechado; finalizar após fases 6–7 | Produto + titular |
| 9 | Builds assinados em canais de teste | Fases 1, 7 e requisitos de 8 | Desenvolvimento + titular |
| 10 | Beta validado e candidato final | Fase 9 | QA + usuários de teste |
| 11 | Aprovação e publicação na Google Play | Fases 8–10 | Titular + desenvolvimento |
| 12 | Operação e primeira atualização preparadas | Fase 11 | Produto + desenvolvimento |

As fases 1 e 8 devem começar cedo para reduzir espera externa. A fase 5 pode avançar com dados de teste enquanto domínio e persistência são construídos. Isso é uma ordem de trabalho, não uma exigência de equipe paralela.

Papéis podem ser exercidos pela mesma pessoa. O titular responde por contas, contratos, custos, informações legais e decisão de lançamento. Desenvolvimento entrega código e builds; QA registra evidências; produto decide regras e aceita a experiência.

## Fase 0 — fechar produto e regras de negócio

**Concluída documentalmente em 16/09/2026.** Responsáveis: titular (decisões aprovadas em conversa) e desenvolvimento (consolidação e diretrizes técnicas). Evidências: [decisões e exemplos](docs/decisoes/FASE_0_PRODUTO.md), [ADR 001](docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md), [contexto](CONTEXTO_DO_PROJETO.md) e [handoff](handoff/README.md).

- [x] Registrar armazenamento local/offline, sem login na v1, Brasil, pt-BR, BRL e gratuidade; arquitetura preparada para futura Pro.
- [x] Definir celulares e piso técnico: decisão inicial Android API 24/iOS 15, revisada pelo titular na fase 1 para somente Android API 24. Seleção e builds dos plugins compatíveis são tarefas da fase 2.
- [x] Manter lista agrupada, baixa 1d, cancelamento 1j e mês por setas 1g.
- [x] Registrar Material padrão com tema de cores no contexto e handoff.
- [x] Aprovar regras de competência, vigência, dias inexistentes, baixa, atraso, automático, saldo, previsão, histórico, edição, encerramento e exclusão.
- [x] Incorporar recorrências diária/semanal/mensal/anual, intervalo N, dias semanais e término por data/quantidade, com valor por ocorrência.
- [x] Aprovar painel mensal com antecedência três dias configurável de um a dez e resumo local global diário às 9h ajustável/desativável.
- [x] Aprovar edição, encerramento, backup manual por substituição e backup do sistema quando disponível.
- [x] Produzir exemplos numéricos de resumo, reversão, média e novas recorrências para orientar testes futuros.
- [x] Atualizar contexto, handoff e decisões de arquitetura.

**Saída:** regras e escopo aprovados, sem perguntas de produto pendentes. Implementação, testes, validação do agendamento local e builds não foram realizados nesta fase. Convenções e critérios detalhados constam no registro de decisões.

## Fase 1 — titularidade, contas e identidade do app

**Objetivo:** antecipar dependências administrativas de publicação.

**Em andamento (16/09/2026):** titular pessoa física, Google Play declarada ativa/verificada e criada após 13/11/2023. Domínio `mutumsoft.com.br` e ID `br.com.mutumsoft.contapaga` escolhidos. Somente Android neste lançamento; iOS adiado. Evidências e pendências no [registro da fase 1](docs/decisoes/FASE_1_DISTRIBUICAO.md); consoles ainda não acessados nesta execução.

- [x] Confirmar titular pessoa física e conta Google ativa/verificada por declaração do usuário.
- [ ] Conferir acesso administrativo, multifator e contratos aplicáveis no Play Console.
- [x] Escolher applicationId `br.com.mutumsoft.contapaga` sob domínio controlado confirmado pelo titular.
- [ ] Verificar identidade e criar/verificar registro Conta Paga no Play Console; registrar evidências e link administrativo.
- [ ] Definir e-mail e URLs públicas de suporte/privacidade; titular providenciará. Brasil e gratuidade já aprovados.
- [x] Identificar exigência de teste fechado pela data declarada da conta; titular confirmou capacidade de reunir participantes.
- [ ] Organizar recrutamento para cumprir 12 participantes/14 dias na fase 10; não confundir capacidade de recrutamento com teste cumprido.
- [x] Definir QA em Android físico disponível, complementado por emuladores; modelo/versão a inventariar antes dos testes.

Apple Developer, equipe Apple, Bundle ID, App Store Connect e iPhone físico ficam adiados e não integram o critério de saída atual.

Contas pessoais Google criadas após 13/11/2023 estão sujeitas ao teste fechado com pelo menos 12 participantes inscritos continuamente por 14 dias antes da solicitação de acesso à produção. Cumprir o período não equivale à aprovação automática. [Requisito oficial de testes](https://support.google.com/googleplay/android-developer/answer/14151465).

**Entrega:** contas aptas, identificadores definidos e dependências externas registradas. **Saída:** titular consegue acessar o Play Console e executar a distribuição de teste quando o build estiver pronto.

## Fase 2 — preparar a base Flutter e o processo de desenvolvimento

- [ ] Executar `flutter doctor -v`, registrar Flutter/Dart, Java, Android SDK e Xcode; resolver incompatibilidades com a restrição Dart atual e fixar uma versão Flutter reproduzível.
- [ ] Executar análise, teste e builds de diagnóstico da base; registrar falhas existentes sem tratá-la como produto funcional.
- [ ] Substituir descrição, título e estrutura padrão do contador por bootstrap do Conta Paga.
- [ ] Organizar código por funcionalidades e separar apresentação, regras de domínio e acesso a dados. Sugestão: `lib/app`, `lib/core`, `lib/features/recorrencias`, `lib/features/mes`, `lib/features/historico` e `lib/features/ajustes`.
- [ ] Escolher uma abordagem única de gerenciamento de estado e navegação, evitando dependências sem necessidade demonstrada.
- [ ] Definir interfaces para repositórios, relógio/data atual e armazenamento; permitir testes sem relógio do dispositivo ou banco real quando apropriado.
- [ ] Fixar piso Android API 24 e selecionar/validar dependências compatíveis; registrar versões e builds.
- [ ] Avaliar plugin de notificações locais e provar agendamento com app fechado, permissão negada e limites de reposição antes de integrar o produto.
- [ ] Selecionar biblioteca de persistência e formatação com suporte Android, manutenção e licenças verificadas; versionar lockfile.
- [ ] Estabelecer análise estática, formatação e testes em CI; builds Android em agentes compatíveis, sem credenciais em texto no repositório.
- [ ] Preparar convenção de versão/build, ambientes de teste e produção, fixtures isoladas e mensagens de erro compreensíveis.
- [ ] Atualizar README com instalação, execução, testes, arquitetura e referência ao handoff; excluir o runtime HTML dos assets de distribuição.

**Entrega:** app Flutter organizado, inicialização própria e pipeline básico. **Saída:** projeto instala em Android e checks básicos são reproduzíveis por outra máquina.

## Fase 3 — implementar e testar o domínio financeiro

- [ ] Implementar entidades de série/revisão, ocorrência, baixa e preferências com IDs estáveis e geração idempotente; permitir várias ocorrências por série/competência, preservando baixas e identidade ao editar.
- [ ] Usar centavos inteiros ou decimal exato; aplicar arredondamento da média definido na fase 0 e impedir cálculos monetários dependentes de ponto flutuante impreciso.
- [ ] Representar datas financeiras como datas civis, sem deslocamentos involuntários por UTC; injetar relógio e recalcular “hoje” ao retomar o app.
- [ ] Gerar ocorrências respeitando vigência, mês/ano, dias inexistentes e política de edição; tornar geração repetida idempotente.
- [ ] Implementar baixa e reversão, garantindo transação única e prevenção de toques duplicados.
- [ ] Implementar classificação e ordenação compartilhadas entre lista, resumo, avisos e histórico.
- [ ] Implementar previsões por ocorrência nas seis competências anteriores, fallback, arredondamento e histórico agregado/detalhado conforme fase 0.
- [ ] Implementar recorrência por intervalo, dias semanais, fim inclusivo e limite total de ocorrências; testar fronteiras de mês/ano, 29/02 e preservação de baixas após revisão da série.
- [ ] Validar nome, valor, dia, competência e data de baixa; tratar parsing pt-BR sem transformar erro em zero.
- [ ] Escrever testes unitários orientados a regras: dezembro/janeiro, fevereiro bissexto, dias 29–31, baixa antecipada/tardia, receita atrasada, automático vencido, reversão e valores pequenos/grandes.

**Entrega:** regras de negócio independentes da UI, com exemplos verificáveis. **Saída:** mesma ocorrência produz status e totais consistentes em todos os consumidores; casos críticos aprovados.

## Fase 4 — persistência, integridade e recuperação

**Caminho aprovado: armazenamento local transacional, preparado para adaptadores futuros conforme ADR 001.**

- [ ] Criar esquema versionado e migrações para recorrências, ocorrências, baixas e preferências; definir índices e restrições de integridade.
- [ ] Implementar repositórios, transações e falhas de gravação; só apresentar confirmação após sucesso da persistência.
- [ ] Persistir as alterações conforme a política aprovada, preservando histórico e evitando que uma edição recalcule baixas antigas.
- [ ] Garantir uso offline, restauração após reinício e comportamento seguro diante de pouco espaço ou erro de leitura.
- [ ] Definir proteção dos arquivos, política de backup automático do sistema e conteúdo que pode sair do dispositivo. Não confundir backup do SO com sincronização entre Android e iOS.
- [ ] Implementar backup manual aprovado: formato versionado, exportação/importação via seletor do sistema, validação, prévia e substituição transacional confirmada, sem mesclagem; avisar sobre sensibilidade do arquivo.
- [ ] Implementar exclusão dos dados locais com confirmação; distinguir limpar dados de encerrar uma recorrência.
- [ ] Testar migração com dados anteriores, importação inválida, restauração, interrupção de gravação e tentativa duplicada de baixa.
- [ ] Garantir primeira instalação vazia; dados fictícios existem apenas em testes/demonstração explícita.

**Se a fase 0 escolher nuvem/login**, substituir ou ampliar esta fase antes de seguir: backend e contrato de API; autenticação e recuperação de acesso; autorização por usuário; transporte seguro; sincronização/conflitos/offline; migrações no servidor; backup e restauração testados; exclusão de conta e dados; ambiente de homologação; custos e monitoramento. Incluir testes de isolamento entre usuários. Essa escolha aumenta prazo e trabalho das fases 7–10.

**Entrega:** dados duráveis com política de recuperação documentada. **Saída:** cadastro → baixa → encerramento do processo → reabertura preserva os dados; migração e restauração não corrompem o histórico.

## Fase 5 — aplicar tema de cores Material e estruturar a navegação

- [ ] Configurar o tema de cores do app com `ThemeData` e `ColorScheme`, mantendo os demais padrões visuais do Flutter Material Design.
- [ ] Usar tipografia e ícones Material padrão; dispensar fontes Barlow, pacote Lucide, molduras blueprint e marcas de canto do Industry.
- [ ] Priorizar componentes existentes: `Scaffold`, `AppBar`, `ListTile`, `Card`, `TextFormField`, botões Material, `IconButton`, `FloatingActionButton`, `AlertDialog` e seletores Material de data, conforme a necessidade de cada fluxo.
- [ ] Compor lista, resumo, formulários e diálogos com esses componentes, preservando suas formas, espaçamentos internos, elevações, estados de interação e comportamento acessível originais. Formatação monetária e validação são lógica do formulário, sem exigir um campo visual próprio.
- [ ] Criar widgets personalizados apenas quando realmente necessários, justificando a lacuna e preferindo composição de widgets Material existentes. Extrações para organizar telas podem reutilizar essa composição sem criar um novo sistema visual. Para o gráfico de histórico, avaliar a solução mínima necessária e alinhá-la às cores e à tipografia do tema.
- [ ] Montar navegação lista → detalhe/cadastro → retorno, além de ajustes/ajuda aprovados; preservar mês selecionado.
- [ ] Adaptar o layout ao espaço disponível, teclado, safe areas, orientação e texto ampliado, mantendo legibilidade em telas maiores. Não fixar largura e padding para imitar o HTML.
- [ ] Preservar foco, semântica e alvos de toque padrão dos componentes; validar contraste do tema de cores e apresentar status também por texto/ícone.
- [ ] Especificar fechamento/retorno dos modais, foco inicial e proteção de dados de formulário não salvos usando os mecanismos dos componentes padrão.
- [ ] Validar telas e estados pelos fluxos do handoff e pela consistência com Material Design; a comparação visual com Industry não é critério de aceite.

**Entrega:** telas compostas com widgets Material padrão, tema de cores e navegação funcional. **Saída:** uso consistente dos componentes originais, legibilidade e interação adequadas em Android; qualquer widget personalizado tem necessidade justificada e mantém a base Material.

## Fase 6 — concluir os fluxos do produto

- [ ] Lista mensal: navegação sem intervalo artificial, títulos com ano, resumo, grupos na ordem definida, totais, sinais e indicação de previsão.
- [ ] Avisos: painel, contagem, vazio, antecedência e critérios de data; atualizar ao mudar mês, dar baixa, reverter e retomar o app.
- [ ] Cadastro: campos funcionais do handoff mais data inicial, frequência, intervalo N, dias semanais, término e valor por ocorrência; prévia da agenda, validação e mensagens claras; salvar uma única vez e retornar à lista correta.
- [ ] Baixa: valor previsto e hoje pré-preenchidos, ajuste pt-BR, confirmação de pagamento/recebimento, tratamento de falha e fechamento após sucesso.
- [ ] Notificações locais: resumo global diário às 9h ajustável, sem aviso vazio, autorização, desativação, abertura de avisos globais e conciliação após alterações; validar janela e reposição com app fechado conforme ADR 001.
- [ ] Reversão: mostrar conta, valor e data; manter baixa ao cancelar; reclassificar ocorrência após confirmação.
- [ ] Histórico: seis competências do período definido, barras previstas/realizadas, tabela e média com explicação do critério.
- [ ] Edição e encerramento aprovados: apresentar impacto temporal, preservar histórico e confirmar ações destrutivas.
- [ ] Ajustes/ajuda: privacidade, suporte, versão, avisos e controles de dados previstos na fase 0.
- [ ] Implementar estados de primeira utilização, lista vazia, carregamento, erro e tentativa de recuperação; não mostrar exemplos como dados reais.
- [ ] Revisar textos de entrada/saída: “Recebida com atraso”, “Manter como recebida” e demais variações.
- [ ] Remover promessas sem fluxo, como reprogramação, e esclarecer que baixa é registro manual, sem execução bancária.

**Entrega:** versão alfa com fluxo ponta a ponta persistido. **Saída:** usuário consegue começar sem assistência, cadastrar, consultar meses, registrar e cancelar baixas e consultar histórico após reabrir o app.

## Fase 7 — qualidade, acessibilidade, segurança e desempenho

- [ ] Substituir o teste do contador por testes úteis do produto: domínio, repositórios, widgets e integração dos fluxos críticos.
- [ ] Executar testes em Android físico; incluir versões mínima e recente suportadas em dispositivos/emuladores disponíveis.
- [ ] Validar navegação nativa de retorno, teclado decimal, toque duplo, background/foreground, virada de data, offline e interrupção do processo.
- [ ] Validar TalkBack/VoiceOver, ordem de foco, leitura de valores/status, fonte ampliada, contraste e telas pequenas; testar tablets/iPad se declarados suportados.
- [ ] Medir em profile/release inicialização, rolagem e histórico com volume representativo — por exemplo, centenas de recorrências e anos de dados — e corrigir travamentos.
- [ ] Inspecionar logs e SDKs para impedir exposição de nomes, valores, backups ou credenciais; revisar permissões e dependências.
- [ ] Testar notificações: app fechado, permissões negadas/revogadas, baixa antes do aviso, fuso, reinício, restauração e limites de agendamento; testar séries diárias volumosas e finitas sem duplicações.
- [ ] Testar instalação limpa, atualização preservando dados, falha de migração e recuperação definida; não considerar reinstalação equivalente a atualização.
- [ ] Manter evidências por build/dispositivo e classificar defeitos por impacto. Bloquear release com perda de dados, cálculo incorreto, crash de fluxo central ou impedimento de uso acessível.

| Cenário mínimo | Resultado esperado |
| --- | --- |
| Nova recorrência com vigência atual | Não aparece antes do início |
| Dezembro → janeiro | Ano e ocorrências corretos, sem colisão de chaves |
| Dia 31 em fevereiro | Política aprovada aplicada e exibida |
| Baixa em mês posterior | Data preservada e atraso identificado |
| Valor inválido ou data impossível | Campo com erro, nenhuma gravação |
| Reversão cancelada/confirmada | Mantém baixa / reabre exatamente uma ocorrência |
| Débito automático vencido sem baixa | Pendência visível, nunca pagamento inferido |
| Histórico sem baixas | Ausência de média realizada e fallback explícito |
| Reinício/atualização | Dados e vínculos preservados |
| Falha de persistência | Erro visível, nenhuma confirmação falsa |

**Entrega:** relatório de QA e evidências de release. **Saída:** zero defeitos bloqueantes abertos, checks automatizados verdes e fluxos críticos aprovados no Android.

## Fase 8 — privacidade, suporte e conteúdo das lojas

- [ ] Inventariar dados efetivamente armazenados/transmitidos e SDKs: dados financeiros, diagnóstico, backup, suporte e autenticação quando houver.
- [ ] Redigir política compatível com o comportamento real, identificando responsável, finalidades, armazenamento, compartilhamento, retenção, exclusão e contato; avaliar obrigações aplicáveis à distribuição escolhida.
- [ ] Publicar URLs públicas e funcionais de privacidade e suporte e disponibilizá-las no app; preparar atendimento básico.
- [ ] Preencher Data safety da Google (App Privacy Apple fica adiado) com base no inventário. Não declarar ausência de coleta sem verificar os SDKs e fluxos externos. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469) e [App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).
- Adiado para iOS: auditar privacy manifests e justificativas de APIs exigidas no iOS, incluindo dependências nativas; preencher declarações de criptografia/export compliance conforme o binário real. [Requisitos Apple](https://developer.apple.com/news/upcoming-requirements/).
- [ ] Se houver criação de conta: implementar exclusão dentro do app e o recurso web exigido pela Google, removendo dados associados conforme política; testar o fluxo antes do beta. [Apple](https://developer.apple.com/support/offering-account-deletion-in-your-app) e [Google](https://support.google.com/googleplay/android-developer/answer/13327111).
- [ ] Se houver monetização, implementar e testar o mecanismo aplicável, restauração e estados de compra; revisar contratos e regras oficiais antes de incluir cobrança. Sem monetização aprovada, não adicionar SDKs de pagamento/anúncios.
- [ ] Criar ícone próprio, splash, screenshots reais do app com dados fictícios, arte promocional exigida pela Play e demais assets nos tamanhos vigentes de cada console.
- [ ] Preparar nome, descrições curta/completa, subtítulo/keywords quando aplicáveis, categoria, classificação etária, copyright, idioma, países, preço e contato.
- [ ] Preencher declarações de anúncios, público-alvo, acesso ao app e funcionalidades financeiras quando solicitadas, refletindo que é organização pessoal com baixa manual.
- [ ] Não anunciar pagamento bancário, notificações push, sincronização ou recursos ainda ausentes. Se login existir, preparar conta de revisão com dados fictícios e acesso funcional.
- [ ] Revisar licenças de fontes, ícones e bibliotecas; disponibilizar atribuições necessárias.

**Entrega:** conteúdo, URLs e declarações coerentes com o candidato final. **Saída:** nenhum placeholder, link quebrado ou discrepância entre anúncio, política e funcionamento.

## Fase 9 — preparar builds assinados e distribuição de teste

### Android / Google Play

- [ ] Substituir `com.example.contapaga` em namespace, application ID, pacote Kotlin e caminhos relacionados; ajustar nome exibido e ícones adaptativos.
- [ ] Retirar assinatura debug do bloco release. Criar/proteger chave de upload, configurar assinatura e Play App Signing; guardar backup e procedimento de recuperação fora do Git.
- [ ] Revisar `.gitignore` e armazenamento de segredos da CI para keystores, senhas, arquivos de configuração e credenciais dos consoles.
- [ ] Conferir `minSdk`, `compileSdk` e valor efetivo de `targetSdk`; não presumir conformidade só porque vêm do Flutter.
- [ ] Atender ao nível alvo vigente. Na consulta deste plano, a referência oficial exige API 36 para novos apps/atualizações móveis; reconferir datas e exceções antes do envio. [Target API](https://developer.android.com/google/play/requirements/target-sdk).
- [ ] Verificar compatibilidade de bibliotecas nativas/Flutter com páginas de memória de 16 KB e testar em ambiente compatível. [Documentação Android](https://developer.android.com/guide/practices/page-sizes).
- [ ] Gerar `flutter build appbundle --release`, conferir versão/build, assinatura, permissões e conteúdo; enviar primeiro à faixa interna e instalar pela Play.
- [ ] Examinar relatórios de pré-lançamento e avisos do console; corrigir bloqueios antes do teste fechado/produção.

### iOS / App Store — adiado, fora do lançamento atual

- Adiado: Configurar Bundle ID definitivo, nome Conta Paga, equipe correta, certificados/perfis de distribuição e capabilities estritamente necessárias.
- Adiado: Ajustar família de dispositivos, orientações, deployment target, ícones e launch screen conforme escopo e QA.
- Adiado: Usar Xcode/SDK aceitos para submissão. A exigência publicada desde 28/04/2026 é Xcode 26 ou superior com SDK iOS 26 ou superior; reconferir no envio. Isso não exige limitar usuários ao iOS 26. [Requisitos oficiais](https://developer.apple.com/news/upcoming-requirements/).
- Adiado: Gerar `flutter build ipa --release`, validar o archive e enviar ao App Store Connect; resolver avisos de assinatura, assets, privacidade e processamento.
- Adiado: Configurar TestFlight e instalar o build distribuído; disponibilizar instruções e contato para testes, cumprindo revisão beta quando aplicável.

### Processo comum

- [ ] Executar format/analyze/test e testes de integração necessários antes de gerar o candidato; usar versão/build exclusivos para novos uploads.
- [ ] Vincular commit, versão, artefatos e evidências de QA; arquivar símbolos de depuração para diagnóstico de crashes.
- [ ] Restringir credenciais de distribuição e documentar passos manuais; automatizar upload apenas quando o processo estiver validado.

Referências de build: [Flutter Android](https://docs.flutter.dev/deployment/android) e [Flutter iOS](https://docs.flutter.dev/deployment/ios).

**Entrega:** builds release instaláveis pelos canais oficiais Google Play. **Saída:** instalação, abertura e fluxo financeiro central funcionam nos binários distribuídos, com assinatura correta e sem bloqueios técnicos dos consoles.

## Fase 10 — beta e estabilização

- [ ] Conduzir teste interno seguido de teste fechado Google com pessoas do público-alvo.
- [ ] Cumprir o período e quantidade mínimos da Google quando aplicáveis; manter evidências de participação e feedback para a solicitação de acesso à produção.
- [ ] Distribuir roteiro: primeiro cadastro, duas competências, valor variável, baixa tardia, cancelamento, histórico e recuperação de dados.
- [ ] Registrar erros, dúvidas e comportamento em dispositivos reais; avaliar compreensão do saldo, previsões e débito automático.
- [ ] Corrigir problemas e repetir testes afetados; revalidar política/screenshots se o funcionamento mudar.
- [ ] Congelar escopo do candidato, conferir ausência de fixtures e aprovar checklist de release.

**Entrega:** candidato estável com feedback tratado. **Saída:** critérios de QA atendidos, beta concluído, acesso à produção Google concedido quando necessário e titular de acordo com o lançamento.

## Fase 11 — submissão, revisão e publicação

- [ ] Revalidar requisitos oficiais, contratos, status das contas, URLs e declarações para a data efetiva de submissão.
- [ ] Selecionar os builds finais no Play Console, preencher notas de versão e instruções de revisão: criar conta recorrente, dar baixa, desfazer e consultar histórico.
- [ ] Explicar nas notas que o app registra compromissos manualmente; fornecer credenciais de teste somente se o produto exigir login.
- [ ] Submeter Google Play à revisão; acompanhar mensagens e responder com informação objetiva e evidências.
- [ ] Se houver rejeição, registrar motivo, corrigir código/metadados, incrementar build quando necessário e repetir verificação pertinente antes de reenviar.
- [ ] Definir liberação manual/gerenciada quando disponível para coordenar data.
- [ ] Publicar nos países aprovados. Usar mecanismos de liberação gradual somente quando disponíveis para aquele tipo de lançamento; não depender de rollout percentual no primeiro lançamento.
- [ ] Verificar páginas públicas, preço, descrição, capturas e instalação por usuários comuns em Android, fora dos grupos de teste.
- [ ] Registrar links públicos, versão, build, data e commit; atualizar README, contexto e este plano com evidências de conclusão.

Referência futura, fora do lançamento: a Apple exige app completo, metadados reais e acesso suficiente para revisão; a utilidade deve estar demonstrável no próprio produto. A referência de avaliação é o app Flutter funcional, não o protótipo. [Orientações de App Review](https://developer.apple.com/app-store/review/).

**Entrega:** app disponível publicamente na Google Play. **Saída:** links públicos acessíveis nos territórios definidos e instalação/uso do fluxo central confirmados. Upload, beta e aprovação sem liberação não contam como publicação concluída.

## Fase 12 — acompanhar o lançamento e preparar atualizações

- [ ] Acompanhar crashes/ANRs e feedback pelos recursos das lojas e canais aprovados; qualquer SDK adicional exige revisão do inventário de dados.
- [ ] Fazer acompanhamento diário na primeira semana e revisão após 30 dias, com responsável por atendimento e correções.
- [ ] Definir resposta a incidentes: perda/corrupção de dados, totais incorretos e falha de abertura são prioridade máxima.
- [ ] Preparar hotfix com número de build novo, testes de regressão e validação de migração; não presumir que uma versão antiga poderá ser reinstalada sobre a nova.
- [ ] Se necessário, interromper distribuição/rollout onde disponível e publicar correção; preservar backups e compatibilidade do esquema.
- [ ] Revisar métricas disponíveis de estabilidade e dúvidas de uso; converter feedback em backlog sem alterar silenciosamente regras financeiras.
- [ ] Agendar renovação de contas/certificados quando aplicável, atualizações de SDK/target API, dependências e políticas das lojas.

**Entrega:** operação mínima e processo de atualização exercitável. **Saída:** responsável de suporte definido, diagnóstico disponível e procedimento de correção documentado.

## 5. Estimativa e caminho crítico

Estimativa inicial de esforço, não compromisso de calendário, para uma pessoa com experiência em Flutter, seguindo o caminho local/offline e escopo controlado:

| Bloco | Faixa indicativa |
| --- | --- |
| Decisões e base técnica (0–2) | 4–7 dias úteis de trabalho; cadastros podem levar mais |
| Domínio e persistência (3–4) | 8–14 dias úteis |
| UI e fluxos (5–6) | 10–16 dias úteis |
| QA e correções (7) | 5–10 dias úteis |
| Materiais e builds (8–9) | 4–8 dias úteis |
| Beta, ajustes e submissão (10–11) | 4–8 dias úteis de trabalho, além de espera externa |

Estimativa histórica do escopo mensal sem notificações: 35–63 dias úteis. Essa faixa não representa compromisso para o escopo ampliado. Reestimar na fase 2 após provar o agendador local e o motor de recorrências. Prazo de calendário inclui verificação de contas, eventual teste fechado obrigatório de 14 dias e revisões das lojas, cujas durações não são garantidas. As recorrências ampliadas e notificações locais já estão no escopo aprovado, mas ainda precisam de estimativa adicional. Pro com nuvem/login e monetização exige planejamento próprio.

Caminho crítico: regras decididas → domínio → persistência → fluxos completos → QA → build assinado → beta/requisitos de produção → revisão → liberação pública. Contas, documentação e materiais avançam em paralelo ao desenvolvimento quando seus pré-requisitos estiverem disponíveis.

## 6. Riscos e respostas

| Risco | Resposta planejada |
| --- | --- |
| Copiar as simplificações de datas/valores do HTML | Regras e testes de domínio antes da integração das telas |
| Perder histórico ao editar ou atualizar | Ocorrências preservadas, transações, migrações e recuperação testadas |
| Escolher nuvem/login tarde | Decisão na fase 0 e replanejamento explícito |
| Contas/identificadores/assinaturas bloquearem publicação | Iniciar fase 1 cedo; distribuir builds reais na fase 9 |
| Dependência nativa incompatível com SDK/16 KB | Verificar toolchain e plugins antes do candidato final |
| Metadados de privacidade não refletirem o binário | Inventário de SDKs/dados e revisão final junto ao build |
| Beta sem participantes suficientes | Recrutar cedo e confirmar requisito da conta Google |
| Customização desnecessária ou layout inacessível em tela pequena | Priorizar widgets Material padrão e validar texto ampliado, leitores de tela e dispositivos reais |
| Rejeição ou demora das lojas | Margem de calendário e ciclo documentado de correção/reenvio |
| App local perder dados após troca de aparelho | Política de backup/recuperação decidida e comunicada antes do lançamento |

## 7. Checklist de conclusão do projeto de lançamento

- [x] Escopo e regras registrados no contexto e no registro da fase 0, sem decisões de produto bloqueantes pendentes; validações técnicas seguem nas fases posteriores.
- [ ] Funcionalidades da versão 1.0 implementadas em Flutter e persistidas.
- [ ] Interface usa widgets Material em sua forma original com tema de cores; widgets personalizados se limitam a necessidades justificadas e preservam a base Material Design.
- [ ] Sem cálculo incorreto, perda de dados ou crash conhecido nos fluxos críticos.
- [ ] Histórico, datas, previsões e cancelamento de baixa cobertos por testes pertinentes.
- [ ] Acessibilidade, responsividade, offline e atualização verificados nos alvos declarados.
- [ ] Marca, identificadores, assinatura e versões de distribuição definitivos.
- [ ] Política de privacidade, suporte, declarações e assets publicados e consistentes.
- [ ] Beta e requisitos de acesso à produção cumpridos.
- [ ] Google Play aprovada e liberada publicamente.
- [ ] Instalação pública e fluxo central confirmados no Android.
- [ ] Links, versões, commit e evidências de publicação registrados.
- [ ] Suporte e procedimento de hotfix definidos.

Ao executar o plano, marcar uma tarefa somente após verificar sua entrega. Registrar fase, evidência, pendência e responsável. O lançamento atual só está concluído quando disponível na Google Play ao público definido. iOS não bloqueia essa conclusão e exige planejamento próprio ao ser retomado.
