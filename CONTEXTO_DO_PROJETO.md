# Contexto do projeto — Conta Paga

> Revisão de escopo na fase 1 (16/09/2026): lançamento somente em celulares Android/Google Play. iOS, App Store e respectivos requisitos foram adiados; referências ao lançamento conjunto abaixo representam a decisão inicial superada. Titular pessoa física, domínio `mutumsoft.com.br` e applicationId escolhido `br.com.mutumsoft.contapaga`. Ver [registro de distribuição](docs/decisoes/FASE_1_DISTRIBUICAO.md).

Atualizado em 16/09/2026 a partir do pacote `handoff/`, da base Flutter e da decisão visual registrada no plano de implementação e publicação.

## 1. Objetivo deste documento

Consolidar as definições do handoff e o estado do projeto para orientar sua implementação. Este documento distingue requisitos explícitos do handoff, comportamentos do protótipo, limitações e recomendações; sugestões adicionais não representam requisitos aprovados.

A análise foi feita pela leitura do README do handoff, do HTML, da lógica JavaScript, do CSS e dos arquivos principais do projeto Flutter. Não houve validação visual no navegador nem execução do app ou de testes nesta revisão documental.

## Decisões vigentes da fase 0

As respostas do titular aprovaram a v1 individual, local/offline, gratuita, sem login, para celulares Android e iPhone, no Brasil, em pt-BR e BRL; backup manual por substituição e backup do sistema quando disponível; edição, encerramento e ajustes/ajuda/privacidade. Preparar a arquitetura para Pro com login Google e backup em nuvem.

O escopo foi ampliado para recorrências diárias, semanais, mensais e anuais, com quantidade fixa de ocorrências, e notificações no celular. O modelo exclusivamente mensal e a ausência de notificações descritos no protótipo não limitam mais a v1. Intervalos N, dias semanais, término por data/quantidade, valores por ocorrência e resumo local diário às 9h ajustável estão aprovados. Mínimos definidos: Android API 24 e iOS 15; integração de dependências e builds serão verificados na fase 2.

Decisões, pendências e exemplos: [registro da fase 0](docs/decisoes/FASE_0_PRODUTO.md). Arquitetura: [ADR 001](docs/decisoes/ADR_001_BASE_LOCAL_E_EVOLUCAO_PRO.md). As seções de experiência e código abaixo descrevem a demonstração; lacunas históricas resolvidas devem ser interpretadas conforme esse registro vigente.

## Distribuição — fase 1 em andamento

Inventário e dependências estão no [registro da fase 1](docs/decisoes/FASE_1_DISTRIBUICAO.md). Somente Android neste lançamento. Titular pessoa física, conta Google ativa/verificada e posterior a 13/11/2023, domínio `mutumsoft.com.br` e applicationId `br.com.mutumsoft.contapaga` confirmados pelo usuário. Código ainda usa o ID de exemplo; disponibilidade/registro no Play Console não verificados. Contatos públicos serão providenciados; Android físico e capacidade de reunir testadores confirmados. iOS adiado.

## 2. Visão do produto

O handoff apresenta **Conta Paga**, uma interface móvel para acompanhar contas recorrentes a pagar e a receber, organizada por mês. O projeto e o pacote Dart se chamam `contapaga`; o cabeçalho do protótipo usa “CONTA PAGA”.

A proposta central é permitir que a pessoa identifique vencimentos e atrasos, consulte valores previstos e registre o pagamento ou recebimento efetivamente realizado. Contas variáveis podem ter o valor ajustado na baixa.

O público está explicitado no handoff: pessoa física / casa que organiza finanças pessoais ou domésticas, como água, energia, internet, telefone, gás, aluguel, salário e aluguel de garagem. Não há personas detalhadas ou definição de compartilhamento entre usuários.

O protótipo trata de compromissos financeiros em geral. Não há emissão, leitura ou pagamento bancário de boletos. “Dar baixa” significa registrar manualmente que um pagamento ou recebimento ocorreu.

## 3. Materiais de referência

| Arquivo | Papel |
| --- | --- |
| [handoff/README.md](handoff/README.md) | Referência funcional de telas e interações, com diretriz visual Flutter Material vigente. |
| [Contas Recorrentes.dc.html](<handoff/Contas Recorrentes.dc.html>) | Protótipo principal, com telas, formulários, dados de exemplo e lógica de interação. |
| [Variacoes.dc.html](handoff/Variacoes.dc.html) | Alternativas de baixa, cancelamento e navegação mensal. |
| [handoff/styles.css](handoff/styles.css) | Tokens e componentes Industry do protótipo histórico, sem obrigação de reprodução no app. |
| [CSS referenciado pelos HTMLs](handoff/_ds/industry-873cda80-4c77-4324-a744-775e806bc163/styles.css) | Cópia idêntica do CSS da raiz do handoff nesta revisão. |
| [support.js](handoff/support.js) e `_ds/.../_ds_bundle.js` | Runtime e suporte da exportação; não são a arquitetura da aplicação. |
| [pubspec.yaml](pubspec.yaml), [lib/main.dart](lib/main.dart) e [test/widget_test.dart](test/widget_test.dart) | Base Flutter existente e teste padrão do contador. |

O pacote atual não contém `readme.md`, `_ds_manifest.json` ou `_adherence.oxlintrc.json` dentro do design system; referências anteriores a esses arquivos foram removidas. Não foram encontrados backend, banco de dados ou testes do domínio financeiro.

O README do handoff orienta implementar os fluxos em Flutter Material, sem portar o runtime ou suas tags para a aplicação. Os HTMLs ficam como referências funcionais, com aparência histórica Industry. A diretriz visual vigente e as propostas funcionais pendentes estão no [plano de implementação e publicação](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md).

## 4. Experiência demonstrada

### Visão mensal

- Cabeçalho com a marca e acesso aos avisos de vencimento.
- Seletor de mês com setas; existe também uma fita de meses configurável no protótipo.
- Resumo com “A pagar”, “A receber” e “Saldo”.
- Faixa de destaque para contas vencidas.
- Agrupamento, nesta ordem: vencidas, vencendo hoje, a vencer, agendadas e concluídas. Grupos vazios não aparecem.
- Linhas com identificação, nome, status, referência de data, valor e ação de baixa ou desfazer baixa.
- Valores de saída com sinal negativo e de entrada com sinal positivo; valores variáveis em aberto recebem a indicação “previsto”.
- Acesso ao detalhe da conta e ao cadastro de uma nova recorrência.

### Cadastro de recorrência

Campos demonstrados: nome, quem cobra/paga, tipo (a pagar ou a receber), valor previsto, dia do vencimento, valor fixo ou variável e indicação de débito automático.

Ao salvar, a conta passa a compor as listas mensais. O protótipo não registra início ou fim da recorrência: uma conta recém-criada também aparece em meses anteriores. Não há edição, exclusão, pausa ou encerramento.

### Baixa e reversão

Ao tocar no quadradinho de uma conta aberta, um modal apresenta o valor previsto e a data de hoje (parametrizada na demonstração). A pessoa pode alterar ambos e confirmar o pagamento ou recebimento. A baixa altera o status e usa o valor efetivo na lista. A confirmação fecha o modal e recalcula lista e resumo, sem confirmação adicional nem toast.

O check verde de uma conta concluída abre um **modal de cancelamento**, com nome, valor e data da baixa, sem campos editáveis. A baixa só é removida após “Sim, cancelar o pagamento/recebimento”; “Manter como paga” fecha sem alteração. A conta retorna ao grupo correspondente ao vencimento, podendo voltar a ficar vencida.

O modal orienta a incluir juros ou multa no valor total. Não existem campos separados para esses componentes, pagamento parcial, anexos ou múltiplas baixas da mesma ocorrência.

### Detalhe e histórico

O detalhe exibe identificação da conta, contraparte, dia de vencimento, média de seis meses, gráfico de barras e tabela com valores e datas de baixa. O intervalo demonstrado é abril a setembro, fixo no código. A média inclui valores previstos quando não existe baixa; portanto, não equivale à média de pagamentos efetivos.

### Avisos

O painel reúne atrasos, vencimentos do dia e alguns vencimentos próximos. A antecedência é uma propriedade do protótipo, com padrão de três dias e configuração de um a dez dias. Não existe tela de preferências do usuário nem envio externo de notificações.

## 5. Regras observadas no código

| Tema | Comportamento atual |
| --- | --- |
| Recorrência | Mensal, com um dia de vencimento por conta. |
| Identificação da ocorrência | Chave composta por mês e ID da conta, sem ano. |
| Valor aberto | Valor base para contas fixas; variação sintética calculada com seno para contas variáveis. Não há previsão estatística real. |
| Valor concluído | Valor informado na baixa. |
| A pagar / A receber | Somam somente ocorrências em aberto do respectivo tipo. |
| Saldo | Soma receitas menos despesas de todo o mês, incluindo abertas e concluídas. Não representa saldo bancário nem somente a diferença entre os dois indicadores anteriores. |
| Atraso em aberto | Vencimento anterior à referência atual, sem baixa e sem indicação de débito automático. |
| Baixa com atraso | Comparação apenas entre o dia informado na baixa e o dia de vencimento; ignora mês e ano. |
| Débito automático | Sinaliza agendamento, sem executar ou confirmar transação bancária. |
| Histórico | Seis meses fixos; mistura valores efetivos e previstos. |
| Persistência | Cadastros e baixas ficam no estado em memória do componente. |

O conjunto inicial possui oito contas. Há baixas de exemplo para todas em agosto e para aluguel e salário em setembro. A referência padrão é 15/09/2026, o mês inicial é setembro, a navegação vai de julho a novembro e o ano do cabeçalho está fixado em 2026. Esses limites caracterizam a demonstração, não uma definição de escopo permanente.

## 6. Alternativas de interface

O arquivo de variações é uma referência comparativa. Seus exemplos estáticos não devem ser interpretados como funcionalidades adicionais prontas ou decisões aprovadas.

| Área | Base definida no handoff | Alternativas |
| --- | --- | --- |
| Lista | Linhas agrupadas por status; escolha já definida. | As antigas opções `1a`, `1b` e `1c` foram removidas do arquivo. |
| Baixa | `1d`: modal com formulário. | `1e`: folha inferior com teclado numérico; `1f`: confirmação rápida com ajuste opcional. |
| Cancelamento | `1j`: confirmação antes de desfazer a baixa. | Já presente no protótipo principal. |
| Mês | `1g`: navegação por setas, padrão. | `1h`: fita com pendências; `1i`: visão dos doze meses. |

A fita `1h` também possui lógica no protótipo principal, ativada pela propriedade `monthPicker`. A continuidade deve seguir a lista definida e as opções `1d`, `1j` e `1g`, salvo nova decisão.

## 7. Direção visual

**Decisão aprovada em 16/09/2026:** a aplicação usará os widgets padrão do Flutter Material Design em sua forma original, personalizando somente as cores com `ThemeData` e `ColorScheme`, conforme o [plano de implementação e publicação](PLANO_IMPLEMENTACAO_E_PUBLICACAO.md). Essa decisão substitui a reprodução visual do Industry prevista originalmente no handoff.

Preservar tipografia, ícones, formas, espaçamentos internos, elevações e estados de interação padrão do Material. Compor lista, resumo, formulários e diálogos com componentes existentes. Widgets personalizados ficam restritos a necessidades não atendidas adequadamente por esses componentes; extrações para organizar sua composição são permitidas. Para o gráfico de histórico, avaliar a solução mínima necessária e alinhá-la às cores e à tipografia do tema.

O handoff permanece como referência de fluxos, campos, textos, agrupamentos e comportamentos, observando as decisões e pendências funcionais do plano. Os HTML/CSS preservam o visual Industry apenas como referência histórica: Barlow, Lucide, cantos retos, molduras blueprint, dimensões de 394 px e demais medidas não são requisitos de implementação ou aceite. A paleta antiga pode orientar o tema de cores, sem exigir reprodução literal dos valores hexadecimais.

Adaptar a composição à largura disponível, ao teclado e ao texto ampliado. Preservar os alvos de toque e estados de foco acessíveis padrão do Material, sem compactá-los para reproduzir o protótipo; fornecer nomes acessíveis aos botões de ícone. Usar moeda e datas em pt-BR e status distinguíveis por texto além da cor. Validar a composição e a acessibilidade diretamente nas telas Flutter; essa validação ainda não foi executada.

## 8. Estado técnico

O material utiliza HTML com elementos `x-dc`, `sc-if` e `sc-for`, expressões `{{ ... }}` e uma classe `Component extends DCLogic`. O arquivo `support.js` fornece o runtime e referencia React, React DOM e Babel via CDN.

Isso descreve apenas a exportação. **A base de implementação existente é Flutter/Dart**, com pacote `contapaga`, restrição de SDK Dart `^3.13.3` e dependências declaradas Flutter e `cupertino_icons`. Há diretórios para Android, iOS, web, macOS, Linux e Windows; isso não confirma plataformas de lançamento ou builds validados.

`lib/main.dart` ainda contém o contador padrão (`Flutter Demo`), com `MaterialApp`, tema roxo e estado local via `setState`. `test/widget_test.dart` testa esse contador; o README da raiz também é o padrão do Flutter. Nenhuma tela financeira do handoff foi implementada. Não há fontes Barlow ou pacote Lucide declarados no `pubspec.yaml`.

Roteamento, gerenciamento de estado e biblioteca de persistência ainda dependem de seleção técnica. Armazenamento local sem autenticação/backend na v1 já está aprovado; a evolução Pro segue o ADR 001. Mapear as três telas (`list`, `detail`, `new`) e os dois modais (baixa e cancelamento) para widgets e estado Flutter, sem incorporar React, Babel ou `support.js` à aplicação.

### Diretrizes explícitas para a aplicação

Além da aparência, o handoff determina usar a data real, permitir qualquer mês, validar valores inválidos com erro no campo e calcular previsões variáveis pela média dos últimos meses pagos. Esses comportamentos **ainda não existem na base Flutter** e diferem das simplificações do protótipo. A regra mensal aprovada usa as seis competências imediatamente anteriores e o valor base quando não há baixas; a média é por ocorrência baixada dessa série na janela, e o histórico agrega totais mensais com detalhamento. O gráfico demonstrado cobre seis meses.

## 9. Avaliação e lacunas

A proposta tem um fluxo central consistente: identificar uma pendência, confirmar seu valor e sua data, registrar a baixa e consultar o histórico. A separação entre previsão e valor efetivo é especialmente útil para contas variáveis. O controle conjunto de entradas e saídas amplia o uso para além de lembretes de boletos.

Os principais pontos a resolver antes de transportar a lógica para uma aplicação são:

1. **Datas completas e competência:** substituir meses isolados e aproximações de 30 dias por datas reais. Suportar virada de ano, fevereiro e baixas em mês diferente do vencimento. O cadastro limita silenciosamente o dia a 1–28, sem política definida para dias 29–31.
2. **Débito automático vencido:** uma conta automática passada continua rotulada “Agendada”, mas seu indicador interno `scheduled` fica falso e ela pode entrar no grupo “A vencer”. Definir quando exigir confirmação ou sinalizar pendência.
3. **Significado do saldo:** o indicador combina valores previstos e efetivos, enquanto os outros dois mostram apenas pendências. O README descreve “previsto − a pagar”, sem esclarecer a composição, enquanto o código soma todas as receitas menos todas as despesas. Resolver essa divergência e definir rótulo e fórmula compreensíveis.
4. **Avisos:** a seleção depende do mês aberto; o cálculo de próximos vencimentos compara dias sem considerar adequadamente o mês e não inclui agendadas futuras. Definir se os avisos são globais ou vinculados à competência consultada.
5. **Estimativas e histórico:** substituir a variação artificial pela média dos últimos meses pagos, conforme o handoff. Definir janela, tratamento de meses sem baixa e valor inicial quando não houver histórico; separar essa previsão da média demonstrada, que hoje inclui valores em aberto.
6. **Validação:** hoje valores inválidos podem virar zero, datas são texto e a baixa descarta o ano. Nome vazio apenas impede o cadastro sem mensagem. Definir validação e feedback para entradas inválidas.
7. **Ciclo da recorrência:** estabelecer início, encerramento e efeito de alterações sobre meses anteriores e futuros. Evitar criação retroativa involuntária.
8. **Reprogramação:** o aviso sugere “Dê baixa ou reprograme”, mas não há ação de reprogramar. Implementar o fluxo após definição da regra ou adequar o texto.
9. **Consistência da linguagem:** mensagens genéricas de atraso usam termos de pagamento mesmo em situações de recebimento. Ajustar os textos por tipo de conta, inclusive “Manter como paga” para recebimentos. O código já usa “Recebida com atraso”, embora a tabela resumida do README mencione apenas “Paga com atraso”.
10. **Uso real:** persistência, recuperação após recarga, isolamento de dados quando aplicável, estados vazios e de erro, navegação por teclado e comportamento do modal ainda precisam ser definidos e verificados.

## 10. Modelo conceitual sugerido

Esta separação é uma recomendação para a futura implementação, não uma estrutura existente de banco de dados.

| Entidade | Responsabilidade e dados principais |
| --- | --- |
| Conta recorrente | Nome, contraparte, direção financeira, valor base, modo fixo/variável, débito automático, início, frequência e término; detalhes conforme decisões da fase 0. |
| Ocorrência | ID estável, referência à série/revisão, vencimento completo, competência derivada e valor previsto; várias ocorrências por série no mesmo mês são permitidas. |
| Baixa | Referência à ocorrência, data completa e valor efetivo do pagamento ou recebimento. |
| Preferência de aviso | Antecedência e, se houver notificações externas, canal escolhido. |

Separar a recorrência de suas ocorrências permite preservar o histórico quando o cadastro muda. Valores monetários devem usar representação exata, como centavos inteiros ou decimal apropriado. Status e totais devem derivar das mesmas regras de domínio para evitar divergência entre lista, avisos e resumo.

## 11. Recorte aprovado e pendências da primeira versão

O recorte vigente está no [registro da fase 0](docs/decisoes/FASE_0_PRODUTO.md). Inclui persistência local, backup, edição/encerramento, novas frequências e notificações locais no celular. Integração bancária, execução de pagamentos, boletos, compartilhamento familiar, outras moedas, push remoto e reprogramação individual permanecem fora.

A fase 0 está concluída documentalmente. As fases seguintes devem implementar e validar as decisões, incluindo notificações em dispositivos reais e dependências compatíveis com Android API 24/iOS 15. A versão Pro futura não altera a operação offline e sem login da v1.

## 12. Critérios sugeridos para validar a evolução

- Cadastro de uma recorrência respeita sua vigência e gera cada ocorrência prevista uma única vez, permitindo várias da mesma série na mesma competência.
- Baixa preserva valor e data completos; reversão exige confirmação, reabre a ocorrência e atualiza totais e avisos. Cancelar o modal mantém a baixa intacta.
- Virada de ano, fevereiro e baixa após o mês de vencimento produzem status corretos.
- Contas automáticas pendentes permanecem visíveis com um estado coerente.
- Indicadores possuem fórmulas documentadas e distinguem previsão de realização.
- Histórico acompanha o período definido, sem fabricar valores apresentados como realizados; previsão variável usa meses pagos e uma regra explícita para ausência de histórico.
- Dados persistem após recarga conforme a estratégia escolhida.
- Formulários rejeitam entradas inválidas com mensagens claras e funcionam por teclado e em telas pequenas.
- Interface Flutter usa widgets Material padrão com personalização somente das cores; componentes personalizados têm necessidade justificada. Layout se adapta à largura disponível e ao texto ampliado, preservando alvos de toque e foco padrão do Material, nomes acessíveis nos botões de ícone e status distinguíveis por texto.

Ao atualizar este contexto, registrar quais decisões foram efetivamente aprovadas e manter explícita a diferença entre comportamento do protótipo, limitação conhecida e requisito do produto.
