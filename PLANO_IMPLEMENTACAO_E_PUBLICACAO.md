# Conta Paga — plano de implementação e publicação

Data: 16/09/2026. Estado: planejamento; nenhuma fase concluída por este documento.

## 1. Objetivo e fontes

Sair do projeto Flutter inicial e entregar o Conta Paga funcional, testado e disponível publicamente na Google Play Store e na App Store, com processo de atualização e suporte definido.

Fontes locais: [contexto do projeto](CONTEXTO_DO_PROJETO.md), [handoff](handoff/README.md), [protótipo principal](<handoff/Contas Recorrentes.dc.html>), [variações](handoff/Variacoes.dc.html), [tokens visuais](handoff/styles.css), [pubspec.yaml](pubspec.yaml), [código inicial](lib/main.dart) e configurações Android/iOS. Os requisitos externos citados foram consultados para este planejamento e devem ser reconferidos antes da submissão. Não foram executados builds, testes ou consultas às contas das lojas nesta análise.

O handoff orienta os fluxos, conteúdos e regras funcionais. Por decisão do produto, a interface usará os widgets padrão do Flutter Material Design em sua forma original, aplicando somente um tema de cores. Essa decisão substitui a reprodução visual do Industry prevista originalmente no handoff e no contexto. Preservar tipografia, formas, espaçamentos internos, elevações e estados padrão dos componentes Material. Criar widgets personalizados somente quando uma necessidade real não puder ser atendida adequadamente pelos componentes existentes, mantendo a base Material Design.

As simplificações de datas, memória e valores sintéticos do protótipo não são regras adequadas à aplicação final. Propostas novas deste plano precisam ser decididas na fase 0 e registradas no contexto; a diretriz visual Material acima já está definida.

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

A presença de diretórios web e desktop não os inclui no lançamento. O caminho deste plano é Android e iOS. O deployment target iOS é distinto da versão do SDK exigida para compilar e enviar o app.

## 3. Recorte proposto para a versão 1.0

### Escopo funcional do handoff e diretriz visual atual

- Cadastro de receitas e despesas recorrentes mensais, fixas ou variáveis, com contraparte e indicação de débito automático.
- Navegação por mês, lista agrupada, resumo e avisos dentro do app.
- Baixa manual com valor e data editáveis, sem toast ou confirmação extra após salvar.
- Cancelamento de baixa com confirmação e apresentação dos dados registrados.
- Histórico com seis meses, gráfico e distinção entre previsão e realização.
- Previsão variável baseada em meses pagos; data real e navegação além do intervalo da demonstração.
- Widgets padrão do Flutter Material Design, com personalização somente das cores; utilizar tipografia e ícones Material padrão.
- Composição das telas conforme os fluxos do produto, com layout responsivo e dimensões padrão dos componentes; os 394 px e demais medidas do HTML não são requisitos de fidelidade visual.
- Validação de entradas, foco visível, nomes acessíveis e preservação dos alvos de toque acessíveis padrão do Material, sem compactá-los para reproduzir o protótipo.

### Proposta de caminho inicial, a decidir na fase 0

Aplicativo individual, em português do Brasil, moeda BRL, uso offline, armazenamento local, sem login, sem anúncios e sem assinatura na primeira versão. Distribuição inicial no Brasil. Essa opção reduz dependências externas, mas exige uma decisão explícita sobre backup e recuperação; não implica sincronização entre dispositivos.

Acrescentar ao lançamento edição controlada de recorrências, encerramento, exportação/importação de backup e uma tela simples de ajustes/ajuda/privacidade. Esses itens ampliam o handoff para evitar que o usuário fique preso a um cadastro errado ou perca o histórico sem alternativa de recuperação. Se forem adiados, documentar o fluxo substituto e as limitações comunicadas ao usuário antes de fechar o escopo.

Ficam fora da proposta inicial: transações bancárias, emissão/leitura de boletos, Open Finance, compartilhamento familiar, outras moedas, recorrências não mensais, notificações externas, publicidade e cobrança por recursos. Uma decisão de incluir qualquer um desses itens exige replanejar suas integrações, testes e declarações das lojas.

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
| 11 | Aprovação e publicação nas duas lojas | Fases 8–10 | Titular + desenvolvimento |
| 12 | Operação e primeira atualização preparadas | Fase 11 | Produto + desenvolvimento |

As fases 1 e 8 devem começar cedo para reduzir espera externa. A fase 5 pode avançar com dados de teste enquanto domínio e persistência são construídos. Isso é uma ordem de trabalho, não uma exigência de equipe paralela.

Papéis podem ser exercidos pela mesma pessoa. O titular responde por contas, contratos, custos, informações legais e decisão de lançamento. Desenvolvimento entrega código e builds; QA registra evidências; produto decide regras e aceita a experiência.

## Fase 0 — fechar produto e regras de negócio

**Objetivo:** tornar o escopo executável sem transportar os erros da demonstração.

- [ ] Registrar a decisão local versus nuvem, login, dispositivos suportados, países, idiomas e modelo comercial.
- [ ] Escolher Android mínimo e iOS mínimo com base na versão Flutter e plugins selecionados; confirmar iPhone apenas ou também iPad e comportamento em tablets Android.
- [ ] Manter lista agrupada, formulário de baixa `1d`, confirmação de cancelamento `1j` e navegação mensal por setas `1g` como referências funcionais, usando componentes Material padrão. Fita/ano inteiro ficam fora salvo decisão expressa.
- [x] Registrar no contexto a decisão visual já tomada: Flutter Material padrão com tema de cores, substituindo as exigências de reprodução do Industry. Evidência (16/09/2026): seção 7 e critérios de validação de `CONTEXTO_DO_PROJETO.md`, alinhados à diretriz vigente em `handoff/README.md`; revisão documental concluída, validação das telas Flutter pendente.
- [ ] Aprovar as regras abaixo com exemplos de entrada e resultado esperado.

| Tema | Proposta para decisão | Critério a documentar |
| --- | --- | --- |
| Competência | Ano e mês; vencimento como data civil completa | Janeiro de anos diferentes não se mistura |
| Vigência | Início explícito, padrão no mês do cadastro; fim opcional | Nenhuma ocorrência anterior ao início |
| Dias 29–31 | Permitir com ajuste para último dia do mês, ou limitar explicitamente a 28 | Nunca alterar o dia digitado silenciosamente |
| Baixa | Uma baixa integral por ocorrência, valor positivo em centavos e data válida | Bloquear duplicidade; definir tratamento de data futura |
| Atraso | Comparar a data completa da baixa com o vencimento | Baixa no mês seguinte continua atrasada |
| Automático | Agendamento é intenção; após vencer sem baixa, sinalizar pendência | Nunca considerar pago automaticamente |
| Saldo | Receitas menos despesas do mês, usando efetivos nas concluídas e previstos nas abertas | Rótulo distingue projeção de saldo bancário |
| Previsão variável | Média de até seis competências anteriores com baixa; fallback no valor base | Arredondamento, poucos dados e exclusão do mês corrente explícitos |
| Histórico | Seis competências terminando no mês selecionado | Média realizada exclui valores em aberto; previsões identificadas |
| Edição | Alteração prospectiva, preservando valores/datas de ocorrências históricas | Definir mês de vigência e efeito nas abertas já existentes |
| Encerramento/exclusão | Encerrar geração futura; preservar baixas existentes | Excluir sem histórico somente com confirmação |
| Avisos | Vinculados ao mês selecionado na v1, com referência clara | Comparação de datas reais, inclusive na virada do mês |
| Reprogramação | Remover “ou reprograme” na v1, salvo inclusão de fluxo próprio | Nenhuma ação prometida sem implementação |

- [ ] Definir antecedência padrão e se o usuário pode configurá-la; não confundir painel interno com notificações do sistema.
- [ ] Aprovar regras de edição, encerramento e backup como escopo adicional ou registrar seu adiamento.
- [ ] Produzir exemplos numéricos do resumo, de reversão e de média; usar os mesmos exemplos nos testes.
- [ ] Atualizar `CONTEXTO_DO_PROJETO.md` com decisões e registrar as escolhas técnicas relevantes em documentos curtos de arquitetura.

**Entrega:** escopo 1.0, tabela de regras e critérios de aceite acordados. **Saída:** armazenamento, vigência, datas, saldo e previsão sem ambiguidades bloqueantes.

## Fase 1 — titularidade, contas e identidade do app

**Objetivo:** antecipar dependências administrativas de publicação.

- [ ] Confirmar titular pessoa física ou organização e disponibilidade das contas Google Play Console e Apple Developer Program; concluir cadastro, verificação e contratos aplicáveis.
- [ ] Conferir exigências de identificação, documentos da organização e custos vigentes nos próprios consoles. Registrar responsáveis e acessos com autenticação multifator.
- [ ] Confirmar que a equipe Apple configurada no projeto pertence ao titular e pode distribuir o app; presença do identificador de equipe não prova acesso ou inscrição ativa.
- [ ] Escolher `applicationId` e Bundle ID definitivos sob domínio controlado pelo titular, verificando disponibilidade antes de criar os registros.
- [ ] Criar os registros do aplicativo nos consoles quando habilitados, com nome Conta Paga e identidade consistente.
- [ ] Definir endereço de suporte, domínio/URLs públicas de suporte e privacidade, regiões e classificação comercial.
- [ ] Verificar se a conta Google está sujeita ao teste fechado obrigatório; recrutar usuários reais com antecedência.
- [ ] Planejar Android físico e iPhone físico para QA e um Mac/toolchain compatível para build iOS.

Contas pessoais Google criadas após 13/11/2023 estão sujeitas ao teste fechado com pelo menos 12 participantes inscritos continuamente por 14 dias antes da solicitação de acesso à produção. Cumprir o período não equivale à aprovação automática. [Requisito oficial de testes](https://support.google.com/googleplay/android-developer/answer/14151465).

**Entrega:** contas aptas, identificadores definidos e dependências externas registradas. **Saída:** titular e equipe conseguem acessar os consoles e executar a distribuição de teste quando o build estiver pronto.

## Fase 2 — preparar a base Flutter e o processo de desenvolvimento

- [ ] Executar `flutter doctor -v`, registrar Flutter/Dart, Java, Android SDK e Xcode; resolver incompatibilidades com a restrição Dart atual e fixar uma versão Flutter reproduzível.
- [ ] Executar análise, teste e builds de diagnóstico da base; registrar falhas existentes sem tratá-la como produto funcional.
- [ ] Substituir descrição, título e estrutura padrão do contador por bootstrap do Conta Paga.
- [ ] Organizar código por funcionalidades e separar apresentação, regras de domínio e acesso a dados. Sugestão: `lib/app`, `lib/core`, `lib/features/recorrencias`, `lib/features/mes`, `lib/features/historico` e `lib/features/ajustes`.
- [ ] Escolher uma abordagem única de gerenciamento de estado e navegação, evitando dependências sem necessidade demonstrada.
- [ ] Definir interfaces para repositórios, relógio/data atual e armazenamento; permitir testes sem relógio do dispositivo ou banco real quando apropriado.
- [ ] Selecionar biblioteca de persistência e formatação com suporte Android/iOS, manutenção e licenças verificadas; versionar lockfile.
- [ ] Estabelecer análise estática, formatação e testes em CI; builds Android e iOS em agentes compatíveis, sem credenciais em texto no repositório.
- [ ] Preparar convenção de versão/build, ambientes de teste e produção, fixtures isoladas e mensagens de erro compreensíveis.
- [ ] Atualizar README com instalação, execução, testes, arquitetura e referência ao handoff; excluir o runtime HTML dos assets de distribuição.

**Entrega:** app Flutter organizado, inicialização própria e pipeline básico. **Saída:** projeto instala em Android/iOS e checks básicos são reproduzíveis por outra máquina.

## Fase 3 — implementar e testar o domínio financeiro

- [ ] Implementar entidades de recorrência, ocorrência mensal, baixa e preferências, com IDs estáveis e unicidade por recorrência/competência.
- [ ] Usar centavos inteiros ou decimal exato; definir arredondamento da média e impedir cálculos monetários dependentes de ponto flutuante impreciso.
- [ ] Representar datas financeiras como datas civis, sem deslocamentos involuntários por UTC; injetar relógio e recalcular “hoje” ao retomar o app.
- [ ] Gerar ocorrências respeitando vigência, mês/ano, dias inexistentes e política de edição; tornar geração repetida idempotente.
- [ ] Implementar baixa e reversão, garantindo transação única e prevenção de toques duplicados.
- [ ] Implementar classificação e ordenação compartilhadas entre lista, resumo, avisos e histórico.
- [ ] Implementar previsões sem função sintética, média realizada e resumos conforme decisões da fase 0.
- [ ] Validar nome, valor, dia, competência e data de baixa; tratar parsing pt-BR sem transformar erro em zero.
- [ ] Escrever testes unitários orientados a regras: dezembro/janeiro, fevereiro bissexto, dias 29–31, baixa antecipada/tardia, receita atrasada, automático vencido, reversão e valores pequenos/grandes.

**Entrega:** regras de negócio independentes da UI, com exemplos verificáveis. **Saída:** mesma ocorrência produz status e totais consistentes em todos os consumidores; casos críticos aprovados.

## Fase 4 — persistência, integridade e recuperação

**Caminho base proposto: armazenamento local transacional.**

- [ ] Criar esquema versionado e migrações para recorrências, ocorrências, baixas e preferências; definir índices e restrições de integridade.
- [ ] Implementar repositórios, transações e falhas de gravação; só apresentar confirmação após sucesso da persistência.
- [ ] Persistir as alterações conforme a política aprovada, preservando histórico e evitando que uma edição recalcule baixas antigas.
- [ ] Garantir uso offline, restauração após reinício e comportamento seguro diante de pouco espaço ou erro de leitura.
- [ ] Definir proteção dos arquivos, política de backup automático do sistema e conteúdo que pode sair do dispositivo. Não confundir backup do SO com sincronização entre Android e iOS.
- [ ] Se aprovada a proposta de backup manual: criar formato versionado, exportação/importação via seletor do sistema, validação, prévia de restauração e regra de substituição/mesclagem; avisar sobre sensibilidade do arquivo.
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
- [ ] Montar navegação lista → detalhe/cadastro → retorno, além de ajustes/ajuda se aprovados; preservar mês selecionado.
- [ ] Adaptar o layout ao espaço disponível, teclado, safe areas, orientação e texto ampliado, mantendo legibilidade em telas maiores. Não fixar largura e padding para imitar o HTML.
- [ ] Preservar foco, semântica e alvos de toque padrão dos componentes; validar contraste do tema de cores e apresentar status também por texto/ícone.
- [ ] Especificar fechamento/retorno dos modais, foco inicial e proteção de dados de formulário não salvos usando os mecanismos dos componentes padrão.
- [ ] Validar telas e estados pelos fluxos do handoff e pela consistência com Material Design; a comparação visual com Industry não é critério de aceite.

**Entrega:** telas compostas com widgets Material padrão, tema de cores e navegação funcional. **Saída:** uso consistente dos componentes originais, legibilidade e interação adequadas em Android/iOS; qualquer widget personalizado tem necessidade justificada e mantém a base Material.

## Fase 6 — concluir os fluxos do produto

- [ ] Lista mensal: navegação sem intervalo artificial, títulos com ano, resumo, grupos na ordem definida, totais, sinais e indicação de previsão.
- [ ] Avisos: painel, contagem, vazio, antecedência e critérios de data; atualizar ao mudar mês, dar baixa, reverter e retomar o app.
- [ ] Cadastro: todos os campos do handoff, vigência, validação e mensagens claras; salvar uma única vez e retornar à lista correta.
- [ ] Baixa: valor previsto e hoje pré-preenchidos, ajuste pt-BR, confirmação de pagamento/recebimento, tratamento de falha e fechamento após sucesso.
- [ ] Reversão: mostrar conta, valor e data; manter baixa ao cancelar; reclassificar ocorrência após confirmação.
- [ ] Histórico: seis competências do período definido, barras previstas/realizadas, tabela e média com explicação do critério.
- [ ] Edição e encerramento, se aprovados: apresentar impacto temporal, preservar histórico e confirmar ações destrutivas.
- [ ] Ajustes/ajuda: privacidade, suporte, versão, avisos e controles de dados previstos na fase 0.
- [ ] Implementar estados de primeira utilização, lista vazia, carregamento, erro e tentativa de recuperação; não mostrar exemplos como dados reais.
- [ ] Revisar textos de entrada/saída: “Recebida com atraso”, “Manter como recebida” e demais variações.
- [ ] Remover promessas sem fluxo, como reprogramação, e esclarecer que baixa é registro manual, sem execução bancária.

**Entrega:** versão alfa com fluxo ponta a ponta persistido. **Saída:** usuário consegue começar sem assistência, cadastrar, consultar meses, registrar e cancelar baixas e consultar histórico após reabrir o app.

## Fase 7 — qualidade, acessibilidade, segurança e desempenho

- [ ] Substituir o teste do contador por testes úteis do produto: domínio, repositórios, widgets e integração dos fluxos críticos.
- [ ] Executar testes em Android e iPhone físicos; incluir versões mínima e recente suportadas em dispositivos/emuladores disponíveis.
- [ ] Validar navegação nativa de retorno, teclado decimal, toque duplo, background/foreground, virada de data, offline e interrupção do processo.
- [ ] Validar TalkBack/VoiceOver, ordem de foco, leitura de valores/status, fonte ampliada, contraste e telas pequenas; testar tablets/iPad se declarados suportados.
- [ ] Medir em profile/release inicialização, rolagem e histórico com volume representativo — por exemplo, centenas de recorrências e anos de dados — e corrigir travamentos.
- [ ] Inspecionar logs e SDKs para impedir exposição de nomes, valores, backups ou credenciais; revisar permissões e dependências.
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

**Entrega:** relatório de QA e evidências de release. **Saída:** zero defeitos bloqueantes abertos, checks automatizados verdes e fluxos críticos aprovados nas duas plataformas.

## Fase 8 — privacidade, suporte e conteúdo das lojas

- [ ] Inventariar dados efetivamente armazenados/transmitidos e SDKs: dados financeiros, diagnóstico, backup, suporte e autenticação quando houver.
- [ ] Redigir política compatível com o comportamento real, identificando responsável, finalidades, armazenamento, compartilhamento, retenção, exclusão e contato; avaliar obrigações aplicáveis à distribuição escolhida.
- [ ] Publicar URLs públicas e funcionais de privacidade e suporte e disponibilizá-las no app; preparar atendimento básico.
- [ ] Preencher Data safety da Google e App Privacy da Apple com base no inventário. Não declarar ausência de coleta sem verificar os SDKs e fluxos externos. [Data safety](https://support.google.com/googleplay/android-developer/answer/10787469) e [App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy).
- [ ] Auditar privacy manifests e justificativas de APIs exigidas no iOS, incluindo dependências nativas; preencher declarações de criptografia/export compliance conforme o binário real. [Requisitos Apple](https://developer.apple.com/news/upcoming-requirements/).
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

### iOS / App Store

- [ ] Configurar Bundle ID definitivo, nome Conta Paga, equipe correta, certificados/perfis de distribuição e capabilities estritamente necessárias.
- [ ] Ajustar família de dispositivos, orientações, deployment target, ícones e launch screen conforme escopo e QA.
- [ ] Usar Xcode/SDK aceitos para submissão. A exigência publicada desde 28/04/2026 é Xcode 26 ou superior com SDK iOS 26 ou superior; reconferir no envio. Isso não exige limitar usuários ao iOS 26. [Requisitos oficiais](https://developer.apple.com/news/upcoming-requirements/).
- [ ] Gerar `flutter build ipa --release`, validar o archive e enviar ao App Store Connect; resolver avisos de assinatura, assets, privacidade e processamento.
- [ ] Configurar TestFlight e instalar o build distribuído; disponibilizar instruções e contato para testes, cumprindo revisão beta quando aplicável.

### Processo comum

- [ ] Executar format/analyze/test e testes de integração necessários antes de gerar o candidato; usar versão/build exclusivos para novos uploads.
- [ ] Vincular commit, versão, artefatos e evidências de QA; arquivar símbolos de depuração para diagnóstico de crashes.
- [ ] Restringir credenciais de distribuição e documentar passos manuais; automatizar upload apenas quando o processo estiver validado.

Referências de build: [Flutter Android](https://docs.flutter.dev/deployment/android) e [Flutter iOS](https://docs.flutter.dev/deployment/ios).

**Entrega:** builds release instaláveis pelos canais oficiais nas duas plataformas. **Saída:** instalação, abertura e fluxo financeiro central funcionam nos binários distribuídos, com assinatura correta e sem bloqueios técnicos dos consoles.

## Fase 10 — beta e estabilização

- [ ] Conduzir teste interno seguido de teste fechado Google e beta TestFlight com pessoas do público-alvo.
- [ ] Cumprir o período e quantidade mínimos da Google quando aplicáveis; manter evidências de participação e feedback para a solicitação de acesso à produção.
- [ ] Distribuir roteiro: primeiro cadastro, duas competências, valor variável, baixa tardia, cancelamento, histórico e recuperação de dados.
- [ ] Registrar erros, dúvidas e comportamento em dispositivos reais; avaliar compreensão do saldo, previsões e débito automático.
- [ ] Corrigir problemas e repetir testes afetados; revalidar política/screenshots se o funcionamento mudar.
- [ ] Congelar escopo do candidato, conferir ausência de fixtures e aprovar checklist de release.

**Entrega:** candidato estável com feedback tratado. **Saída:** critérios de QA atendidos, beta concluído, acesso à produção Google concedido quando necessário e titular de acordo com o lançamento.

## Fase 11 — submissão, revisão e publicação

- [ ] Revalidar requisitos oficiais, contratos, status das contas, URLs e declarações para a data efetiva de submissão.
- [ ] Selecionar os builds finais nos dois consoles, preencher notas de versão e instruções de revisão: criar conta recorrente, dar baixa, desfazer e consultar histórico.
- [ ] Explicar nas notas que o app registra compromissos manualmente; fornecer credenciais de teste somente se o produto exigir login.
- [ ] Submeter Google Play à revisão e Apple App Review; acompanhar mensagens e responder com informação objetiva e evidências.
- [ ] Se houver rejeição, registrar motivo, corrigir código/metadados, incrementar build quando necessário e repetir verificação pertinente antes de reenviar.
- [ ] Definir liberação manual/gerenciada quando disponível para coordenar data; não pressupor aprovação simultânea.
- [ ] Publicar nos países aprovados. Usar mecanismos de liberação gradual somente quando disponíveis para aquele tipo de lançamento; não depender de rollout percentual no primeiro lançamento.
- [ ] Verificar páginas públicas, preço, descrição, capturas e instalação por usuários comuns em Android e iOS, fora dos grupos de teste.
- [ ] Registrar links públicos, versão, build, data e commit; atualizar README, contexto e este plano com evidências de conclusão.

A Apple exige app completo, metadados reais e acesso suficiente para revisão; a utilidade deve estar demonstrável no próprio produto. A referência de avaliação é o app Flutter funcional, não o protótipo. [Orientações de App Review](https://developer.apple.com/app-store/review/).

**Entrega:** app disponível publicamente nas duas lojas. **Saída:** links públicos acessíveis nos territórios definidos e instalação/uso do fluxo central confirmados. Upload, beta e aprovação sem liberação não contam como publicação concluída.

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

Total indicativo: 35–63 dias úteis de esforço. Reestimar após fases 0 e 2. Prazo de calendário inclui verificação de contas, eventual teste fechado obrigatório de 14 dias e revisões das lojas, cujas durações não são garantidas. Nuvem/login, monetização ou notificações externas exigem orçamento próprio; não cabem implicitamente nessa faixa.

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

- [ ] Escopo e regras registrados no contexto, sem decisões bloqueantes pendentes.
- [ ] Funcionalidades da versão 1.0 implementadas em Flutter e persistidas.
- [ ] Interface usa widgets Material em sua forma original com tema de cores; widgets personalizados se limitam a necessidades justificadas e preservam a base Material Design.
- [ ] Sem cálculo incorreto, perda de dados ou crash conhecido nos fluxos críticos.
- [ ] Histórico, datas, previsões e cancelamento de baixa cobertos por testes pertinentes.
- [ ] Acessibilidade, responsividade, offline e atualização verificados nos alvos declarados.
- [ ] Marca, identificadores, assinatura e versões de distribuição definitivos.
- [ ] Política de privacidade, suporte, declarações e assets publicados e consistentes.
- [ ] Beta e requisitos de acesso à produção cumpridos.
- [ ] Google Play e App Store aprovadas e liberadas publicamente.
- [ ] Instalação pública e fluxo central confirmados em ambas as plataformas.
- [ ] Links, versões, commit e evidências de publicação registrados.
- [ ] Suporte e procedimento de hotfix definidos.

Ao executar o plano, marcar uma tarefa somente após verificar sua entrega. Registrar fase, evidência, pendência e responsável. Uma publicação parcial deve indicar qual loja permanece pendente; o objetivo só está concluído quando ambas estiverem disponíveis ao público definido.
