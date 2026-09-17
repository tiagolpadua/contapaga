# Handoff: Conta Paga — contas recorrentes a pagar e a receber

## Overview
App mobile para uma pessoa física / casa controlar contas recorrentes (água, luz, telefone, internet, gás, aluguel) e recebimentos (salário, aluguel de garagem). O usuário escolhe o mês, vê o que está pago e o que está a pagar com as vencidas em destaque, e dá baixa numa conta através de uma modal que já vem preenchida com o valor previsto e a data de hoje.

Fluxo central: **escolher mês → ler a lista agrupada por status → tocar no quadradinho da conta → confirmar valor e data na modal → conta passa a "Paga" (ou "Paga com atraso")**.

## About the Design Files
Os arquivos deste pacote são **protótipos HTML de referência funcional**, não código de produção. A aplicação será implementada em Flutter/Dart. Preservar os fluxos, campos, textos, agrupamentos e comportamentos, observando as decisões e pendências do [plano de implementação e publicação](../PLANO_IMPLEMENTACAO_E_PUBLICACAO.md).

`Contas Recorrentes.dc.html` e `Variacoes.dc.html` usam um runtime de prototipagem próprio (`support.js`, tags `<sc-for>` / `<sc-if>` / `<x-import>`). Esses arquivos permanecem como documentação; o runtime não deve integrar os assets ou o código da aplicação Flutter.

## Diretriz visual vigente — Flutter Material
**Decisão registrada em 16/09/2026:** usar os widgets padrão do Flutter Material Design em sua forma original, personalizando somente as cores por meio de `ThemeData` e `ColorScheme`, conforme o plano. Essa decisão substitui a exigência anterior de alta fidelidade ao Industry.

- Preservar tipografia, ícones, formas, espaçamentos internos, elevações, estados de interação e alvos de toque acessíveis padrão do Material.
- Compor as telas com componentes existentes, como `Scaffold`, `AppBar`, `ListTile`, `Card`, `TextFormField`, botões Material, `IconButton`, `FloatingActionButton`, `AlertDialog` e seletores Material de data.
- Criar widgets personalizados somente quando houver uma necessidade não atendida adequadamente pelos componentes existentes. Extrações para organizar a composição das telas não constituem um novo sistema visual. Avaliar a solução mínima necessária para o gráfico de histórico, alinhada ao tema.
- Adaptar a composição à largura disponível, ao teclado e ao texto ampliado; validar a aparência diretamente nas telas Flutter.

**Como ler as especificações abaixo:** medidas em pixels, classes CSS, cores literais, fontes Barlow, ícones Lucide, cantos retos e molduras blueprint descrevem apenas o protótipo antigo. Não são requisitos de fidelidade visual nem critérios de aceite do app. Os HTML/CSS serão mantidos como referência funcional, sem redesenho nesta etapa.

As simplificações funcionais do protótipo também não definem o domínio final: chaves sem ano, comparação apenas de dias, valores sintéticos e limitações de navegação devem ser substituídas conforme o plano. Regras ainda propostas na fase 0, incluindo saldo, datas, débito automático vencido e previsão, continuam pendentes de decisão; esta atualização registra somente a decisão visual já tomada.

---

## Screens / Views

O protótipo tem **três telas** dentro de um container de 394px de largura (mobile), com 18px de padding e a moldura blueprint com as quatro marcas de canto.

### 1. Lista do mês (tela inicial)
**Purpose:** ver o que vence, o que já foi pago e dar baixa.

**Layout** (de cima para baixo, coluna única):
1. **Cabeçalho** — flex, space-between, margin-bottom 14px.
   - Título "CONTA PAGA": Barlow Condensed 600, 19px, letter-spacing .03em, caixa alta.
   - Botão de avisos: 38×38px, `.btn.btn-secondary`, ícone de campainha Lucide 17px stroke 1.5. Badge no canto superior direito (top −6px, right −6px): min-width 17px, height 17px, fundo `--color-accent-900` (#1d2d3d), texto `--color-bg`, 10px bold, com a contagem de avisos.
2. **Painel de avisos** (colapsável, fechado por padrão) — border 1px `--color-divider`, padding 12px. Kicker "AVISOS DE VENCIMENTO" 10px, letter-spacing .1em, caixa alta, cor `--color-accent-700` (#416180). Uma linha por aviso: quadradinho 6×6px `--color-accent-800` + texto 12.5px. Rodapé: "Você é avisado {n} dias antes de cada vencimento."
3. **Seletor de mês** — ver "Seletor de mês" abaixo.
4. **Resumo do mês** — grid de 3 colunas iguais, border 1px `--color-divider`, divisórias verticais hairline, padding 9px 10px 10px por célula.
   - Rótulos: 10px, letter-spacing .1em, caixa alta, texto a 55% de opacidade.
   - Valores: Barlow Condensed 600, 16px, `font-variant-numeric: tabular-nums`.
   - Colunas: "A pagar" (soma dos a pagar em aberto), "A receber" (soma dos a receber em aberto, em `--color-accent-700`), "Saldo" (previsto − a pagar, com sinal + ou −).
5. **Faixa de vencidas** (só quando existe alguma) — fundo **#8f3d3d**, texto `--color-bg`, padding 11px 13px, ícone relógio Lucide 18px, texto 13px: "2 contas vencidas — R$ 313,10. Dê baixa ou reprograme."
6. **Grupos de contas**, nesta ordem, só os não vazios: **Vencidas · n**, **Vence hoje · n**, **A vencer · n**, **Agendadas · n**, **Concluídas · n**.
   - Cabeçalho do grupo: flex space-between; título Barlow Condensed 600, 12px, letter-spacing .08em, caixa alta, 60% de opacidade; à direita o total do grupo em 11px tabular-nums, 45% de opacidade.
   - **Linha de conta** (altura ~58px): flex, gap 10px, padding 10px 0, border-top 1px `--color-divider`.
     - Barra de vencida: só nas vencidas — 3px de largura, altura total da linha, **#8f3d3d**, recuada 6px para fora do padding.
     - Sigla: botão 38×38px, border 1px `--color-divider`, Barlow Condensed 600 12px letter-spacing .06em ("ÁGU", "LUZ", "NET", "TEL", "GÁS", "ALU", "SAL", "GAR"). Abre o histórico.
     - Miolo (flex:1, clicável, abre o histórico): nome em Barlow Condensed 600 16px; abaixo, em linha, a tag de status + o meta em 11px a 55% de opacidade.
     - Valor (direita): Barlow Condensed 600 16px tabular-nums, prefixado por "−" (a pagar) ou "+" (a receber, na cor `--color-accent-700`). Sob ele, quando o valor é estimado, "PREVISTO" em 10px letter-spacing .08em caixa alta a 45%.
     - Ação: 34×34px. Em aberto — `.btn.btn-secondary` com um quadrado vazio 14×14px de borda hairline. Pago — botão preenchido **#3f6b48** (verde) com check Lucide branco stroke 1.8, que abre a modal de cancelamento.
7. **FAB "nova conta recorrente"** — botão flutuante 56×56px, `position: fixed`, canto inferior direito da coluna (`right: max(18px, calc(50vw - 179px))`, `bottom: 26px`), fundo `--color-accent`, cantos retos + as quatro marcas de registro, ícone "+" Lucide 22px stroke 1.5, `--shadow-lg`, `aria-label="Nova conta recorrente"`. Um espaçador de 56px no fim da lista evita que ele cubra a última linha.

**Mapa de status → tag → meta do protótipo** (cores ilustrativas; regras finais sujeitas às decisões da fase 0 do plano):

| Situação | Status exibido | Tom da tag (fundo / tinta / borda) | Meta |
|---|---|---|---|
| Não paga, sem débito automático, vencimento < hoje | "Vencida" (a receber: "Em atraso") | **vermelho** #f4e6e6 / #8f3d3d / #8f3d3d a 35% | "há 10 dias · venc. 05/09" |
| Não paga, vencimento == hoje | "Vence hoje" | **amarelo** #f6efdc / #7d6220 / #7d6220 a 35% | "15/09" |
| Não paga, vencimento > hoje | "A vencer" | neutro (`.tag-neutral`) | "vence em 20/09" |
| Não paga, débito automático | "Agendada" | neutro (`.tag-neutral`) | "débito automático em 15/09" |
| Paga, dia da baixa <= dia do vencimento | "Paga" (a receber: "Recebida") | **verde** #e7f0e8 / #3f6b48 / #3f6b48 a 35% | "baixa em 04/09" |
| Paga, dia da baixa > dia do vencimento | "Paga com atraso" | **verde** (mesmo tom) | "baixa em 21/08" |

No protótipo Industry, os três tons de status são versões dessaturadas fora do acento steel. No app, definir as cores no tema e distinguir os estados também por texto, sem obrigação de reproduzir estes valores hexadecimais. Eles aparecem em três lugares: na tag, na barra de 3px da linha vencida (#8f3d3d) e na faixa de alerta do topo (fundo #8f3d3d).

### 2. Modal de confirmação de pagamento
**Purpose:** confirmar valor e data ao dar baixa. É o centro do app.

Abre ao tocar no quadradinho de uma conta em aberto. `.dialog-backdrop` (overlay escuro, centralizado) + `.dialog.blueprint`, largura `min(342px, 100%)`, fundo `--color-bg`, cantos retos, quatro marcas de registro.

Conteúdo, em coluna:
1. Kicker 10px letter-spacing .1em caixa alta `--color-accent-700`: "CONFIRMAR PAGAMENTO" (a receber: "CONFIRMAR RECEBIMENTO").
2. `.dialog-title` com o nome da conta.
3. Linha 12px a 55%: "{quem cobra} · vence em {dd/mm}".
4. Campo **"Valor pago"** (a receber: "Valor recebido") — prefixo "R$" numa caixa de 0 10px com fundo `--color-surface` e borda hairline sem borda direita, colado ao `.input`. **Pré-preenchido com o valor previsto** em formato pt-BR ("214,70"), editável, `inputmode="decimal"`. Dica abaixo, 11px a 50%: "Previsto: R$ 214,70. Ajuste se veio diferente."
5. Campo **"Data"** — `.input` pré-preenchido com **a data de hoje** em "dd/mm/aaaa".
6. Aviso de atraso (só se a conta está vencida): fundo `--color-accent-100` (#eef6ff), texto `--color-accent-800` (#2c455d), padding 8px 10px, 12px: "Vencida em 10/09. Se pagou juros ou multa, some no valor — a conta fica como "paga com atraso"."
7. `.dialog-actions`: "Cancelar" (`.btn-secondary`, fecha sem salvar) e "Confirmar pagamento" / "Confirmar recebimento" (`.btn-primary`).

Ao confirmar: faz o parse do valor pt-BR (remove pontos de milhar, troca a vírgula por ponto), guarda `{ dia/mês da baixa, valor }` na chave `{mês}:{idDaConta}`, fecha a modal. A conta muda de grupo na hora e o resumo recalcula. **Nenhuma confirmação extra, nenhum toast.**

### 3. Modal de cancelamento de pagamento
**Purpose:** desfazer uma baixa sem risco de toque acidental.

Abre ao tocar no check verde de uma conta já paga. Mesmo `.dialog-backdrop` + `.dialog.blueprint`, largura `min(330px, 100%)`, gap `--space-2`. É uma confirmação de um toque — **sem campos**:
1. Pergunta em Barlow Condensed 600 19px: "Cancelar o pagamento de Aluguel?" (a receber: "Cancelar o recebimento de …").
2. Bloco de leitura entre duas réguas hairline, padding 10px 0, space-between:
   - Esquerda: valor da baixa em Barlow Condensed 600 28px tabular-nums + rótulo "valor pago" / "valor recebido" em 11px a 55%.
   - Direita: data da baixa em Barlow Condensed 600 17px + rótulo "data da baixa" em 11px a 55%.
3. Nota em 12px a 60%: "A conta volta para a lista de a pagar, com vencimento em 05/09."
4. `.btn.btn-primary.btn-block` de 44px: "Sim, cancelar o pagamento" / "Sim, cancelar o recebimento".
5. `.btn.btn-secondary.btn-block`: "Manter como paga".

Ao confirmar: remove a chave `{mês}:{idDaConta}` de `paid`, fecha a modal; a conta volta ao grupo correspondente ao seu vencimento (podendo reaparecer como vencida) e o resumo recalcula. "Manter como paga" fecha sem mudar nada.

### 4. Histórico da conta
**Purpose:** entender quanto essa conta costuma custar antes de pagar.

Abre ao tocar na sigla ou no nome de uma conta. Estrutura:
1. `.btn-ghost` "← Voltar ao mês".
2. **Ficha** — border 1px `--color-divider`, padding 13px. Kicker "CONTA A PAGAR · MENSAL" (ou "A RECEBER · MENSAL") em `--color-accent-700`; nome em Barlow Condensed 600 25px; quem cobra em 12px a 55%; sigla num quadrado 44×44px hairline à direita. Abaixo, grid de 2 colunas separadas por 1px de `--color-divider`: "MÉDIA 6 MESES" e "VENCIMENTO" ("dia 10").
3. **Gráfico de barras** — 6 meses, altura 96px, gap 7px, border-bottom hairline. Barra = `--color-accent` quando houve baixa, `--color-accent` a 30% quando é previsão. Valor arredondado acima da barra em 9.5px tabular-nums; sigla do mês abaixo em 10px caixa alta.
4. **Tabela** `.table` (mais recente primeiro): Mês / Valor / Baixa ("04/08" ou "em aberto").

### 5. Cadastro de conta recorrente
**Purpose:** criar uma conta que passa a aparecer todo mês.

`.btn-ghost` "← Cancelar", `<h3>` "Nova conta recorrente", subtítulo 12.5px a 60%: "Ela aparece todos os meses na lista, com o valor previsto." Campos (`.field` + `label` + `.input`), gap 12px:
- **Nome** (placeholder "Ex.: Condomínio") — obrigatório; salvar sem nome não faz nada.
- **Quem cobra / paga** (placeholder "Ex.: Síndico") — vazio vira "—".
- **Tipo** — `.seg` de duas opções: "Conta a pagar" / "A receber".
- **Valor previsto (R$)** + **Dia** (numérico, 2 dígitos, limitado a 1–28) em grid `1fr 100px`.
- **O valor muda todo mês?** — `.radio`: "Sim, é variável" / "É fixo".
- **Débito automático** — `.radio`: "Sim — entra como agendada" / "Pago à mão".
- `.btn.btn-primary.btn-block.blueprint` (com as quatro marcas): "Salvar conta recorrente".

A sigla de 3 letras é derivada das 3 primeiras letras do nome em caixa alta.

### Seletor de mês (duas variantes — a "setas" é a padrão)
- **Setas:** faixa com border-top e border-bottom hairline, padding 8px 0. Chevrons Lucide em botões 34×34px `.btn-secondary` nas pontas; no centro o mês em Barlow Condensed 600 23px letter-spacing .06em caixa alta e o ano abaixo em 11px letter-spacing .18em a 50%.
- **Fita:** grid de 5 colunas, um mês por célula (sigla 13px caixa alta + nota 9.5px). O mês ativo é preenchido com `--color-accent` e texto `--color-bg`. A nota mostra "3 abertas" para meses passados/atual e "previsto" para meses futuros.

`Variacoes.dc.html` guarda as alternativas ainda abertas: **1d** (modal em formulário — é a implementada), **1e** (folha inferior com teclado numérico), **1f** (confirmação de um toque), **1j** (cancelamento de pagamento — é a implementada) e **1g / 1h / 1i** (seletor de mês em setas, fita de meses e ano inteiro). As variações de layout da lista já foram decididas e removidas.

---

## Interactions & Behavior
- Tocar no quadradinho de uma conta em aberto → abre a modal, já com valor previsto e data de hoje.
- Tocar no check verde de uma conta paga → abre a modal de cancelamento; a baixa só é desfeita após a confirmação.
- Tocar na sigla ou no nome → tela de histórico.
- Chevrons / célula da fita → troca o mês; a lista, o resumo e os avisos recalculam.
- Botão de campainha → alterna o painel de avisos.
- FAB "+" → tela de cadastro; salvar volta para a lista com a conta já presente.
- **Animações:** o protótipo não tem animações; no app, preservar as transições padrão dos componentes Material.
- **Estados de erro/validação:** só um — nome vazio bloqueia o salvamento. Valor inválido na modal cai para 0 no parse; no app real, valide e mostre erro no campo.
- **Responsivo:** adaptar a composição Flutter à largura disponível e ao texto ampliado. A coluna de 394px é uma medida do protótipo, não um requisito do app.
- **Acessibilidade:** preservar os alvos de toque e estados de foco padrão do Material, sem compactá-los para reproduzir o HTML. Fornecer nomes acessíveis aos botões de ícone ("Marcar como pago", "Desfazer baixa", "Mês anterior", "Próximo mês", "Avisos") e distinguir status por texto além da cor. Validar leitores de tela e texto ampliado no Flutter.

## State Management
Estado demonstrativo do protótipo (não copiar suas limitações para o domínio e a persistência do app; seguir as decisões do plano):
- `month` — mês selecionado (7–11 no protótipo; no app, qualquer mês).
- `screen` — `"list" | "detail" | "new"`; `detail` guarda o id da conta.
- `alertsOpen` — boolean.
- `bills[]` — as contas recorrentes: `{ id, code, name, org, kind: "pay"|"rec", due (dia 1–28), base (valor previsto), est (valor variável?), vary (amplitude da variação), auto (débito automático?) }`.
- `paid{}` — **as baixas**, indexadas por `"{mês}:{idDaConta}"` → `{ d: "dd/mm", v: número }`. É a única fonte de verdade sobre estar pago.
- `modal` — a conta em confirmação de pagamento (ou null); `mv` (valor digitado) e `md` (data digitada).
- `undo` — a conta em confirmação de cancelamento (ou null): `{ key, name, org, due, kind, paidDate, value }`.
- `nf` — o formulário de nova conta.

**Data de "hoje"** é um parâmetro (`"15/09/2026"` no protótipo) — no app, é a data real, e toda a classificação de status depende dela.

**Valores previstos:** as contas variáveis (água, luz, gás) geram o previsto a partir do `base` com uma oscilação determinística. **No app real isso deve vir da média dos últimos meses pagos**, não de uma função sintética.

**Dados que o app precisa buscar:** as contas recorrentes do usuário, as baixas por mês, e o histórico de 6 meses por conta (para o gráfico e a média).

## Design Tokens — referência histórica do protótipo
Os tokens Industry abaixo documentam o HTML existente. Não portar escalas, formas, fontes ou sombras para o Flutter. A paleta pode orientar o tema de cores, sem exigir reprodução literal; os demais padrões são os do Material.

**Cores** — bg #f2f2f3 · surface #e9e9ea · text #1d1f20 · accent #5980a6 · divider `color-mix(in srgb, #1d1f20 16%, transparent)`
Rampa accent: 100 #eef6ff · 200 #d6ebff · 300 #b5d9fd · 400 #94bce3 · 500 #749dc4 · 600 #597ea3 · 700 #416180 · 800 #2c455d · 900 #1d2d3d
Rampa neutra: 100 #f5f5f8 · 200 #e7e7ea · 300 #d4d4d7 · 400 #b7b7ba · 500 #98989b · 600 #7a7a7d · 700 #5d5d60 · 800 #424244 · 900 #2b2b2d

**Tons de status do protótipo** (referência histórica, sem obrigação de manter estes hexes):
- Vencida — tinta #8f3d3d, fundo da tag #f4e6e6, barra e faixa de alerta #8f3d3d
- Vence hoje — tinta #7d6220, fundo da tag #f6efdc
- Paga / concluída — tinta #3f6b48, fundo da tag #e7f0e8, botão de baixa preenchido #3f6b48

**Papéis do acento:** tinta do a receber = accent-700 · fundo do aviso de atraso na modal = accent-100 · FAB e mês ativo = accent · textos secundários = `color-mix(in srgb, var(--color-text) 45–60%, transparent)`.

**Tipografia** — headings "Barlow Condensed" peso 600; corpo "Barlow". Escala usada: 25px (nome no histórico) · 23px (mês) · 19px (título do app, nome na modal) · 16px (nome e valor da conta) · 13px (faixa de alerta) · 12.5px (avisos) · 12px (cabeçalho de grupo, caixa alta) · 11px (meta, rótulos) · 10px (kickers, caixa alta, letter-spacing .1em) · 9.5px (rótulos do gráfico). Todo valor monetário em `font-variant-numeric: tabular-nums`.

**Espaçamento** — 3.4 / 6.8 / 10.2 / 13.6 / 20.4 / 27.2px (`--space-1..8`). Padding do container 18px; linhas de conta 10px 0; gap entre elementos da linha 10px.

**Raio** — 2 / 4 / 7px existem nos tokens, mas **este sistema é de cantos retos**: cards, botões, modais e quadros usam 0.

**Sombras** — sm `0 1px 2px` / md `0 3px 10px` / lg `0 12px 32px`, todas com #2b2b2d a 14/16/22%. Só a modal usa elevação; cards e linhas são desenhos de linha.

**Moeda e data** — sempre pt-BR: "R$ 1.850,00", datas "dd/mm" na lista e "dd/mm/aaaa" na modal.

## Assets
Nenhuma imagem no protótipo. O HTML usa ícones Lucide; na aplicação Flutter, usar ícones Material padrão. Não adicionar fontes Barlow ou pacote Lucide para reproduzir o protótipo.

## Files
- `Contas Recorrentes.dc.html` — o protótipo completo (lista, modal, histórico, cadastro).
- `Variacoes.dc.html` — as variações de modal (1d, 1e, 1f, 1j) e de seletor de mês (1g, 1h, 1i).
- `styles.css` — a folha do design system Industry: todos os tokens e as classes `.btn`, `.tag`, `.field`, `.input`, `.radio`, `.seg`, `.card`, `.table`, `.dialog`, `.blueprint`.
- `support.js` — runtime do protótipo. **Não portar.** Está aqui só para os arquivos HTML abrirem no navegador.

## Nota sobre o repositório
A base existente é Flutter/Dart e ainda contém o contador inicial. Mapear as telas e os diálogos para a navegação e o estado definidos na implementação. Consultar o [contexto do projeto](../CONTEXTO_DO_PROJETO.md) para o diagnóstico e o [plano](../PLANO_IMPLEMENTACAO_E_PUBLICACAO.md) para a diretriz vigente e as decisões funcionais pendentes.
