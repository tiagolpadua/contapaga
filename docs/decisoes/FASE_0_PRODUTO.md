# Fase 0 — decisões de produto

Registro de 16/09/2026. Origem: respostas do titular às perguntas da fase 0 e ampliação solicitada para recorrências e notificações. Decisões de produto aprovadas, incluindo as quatro respostas complementares sobre recorrências, previsão, notificações e edição. Este documento não comprova implementação.

## Escopo aprovado

- V1 individual, offline, armazenamento local, sem login ou sincronização; gratuita, sem anúncios, assinatura ou compras internas. Brasil, português do Brasil e BRL.
- Celulares Android e iPhone. Tablets e iPad fora do alvo de lançamento. Piso técnico de produto: Android 7.0/API 24 e iOS 15. Selecionar dependências compatíveis e validar builds na fase 2; eventual necessidade de elevar o piso exige registrar a revisão.
- Preparar arquitetura para futura versão Pro com login Google e backup em nuvem. Pro não faz parte da implementação da v1; cobrança, provedor de nuvem e sincronização entre dispositivos ainda não foram definidos.
- Exportação/importação manual de backup versionado, com prévia e confirmação para substituir os dados locais, sem mesclagem. Permitir backup automático do sistema operacional quando disponível; não representa sincronização ou garantia de recuperação.
- Lista agrupada, baixa em formulário (1d), confirmação de reversão (1j), navegação mensal por setas (1g), histórico de seis meses, edição, encerramento e ajustes/ajuda/privacidade.
- Flutter Material padrão, personalizando somente cores.
- Recorrências diárias, semanais, mensais e anuais, incluindo término por número fixo de ocorrências. Esta ampliação substitui o escopo exclusivamente mensal do protótipo.
- Notificações no celular, incluindo contas vencendo no dia. Planejar notificações locais compatíveis com a v1 offline; resumo diário às 9h no horário local, ajustável e desativável, com vencidas, hoje e próximos pela antecedência configurada; inclui receitas e automáticos pendentes, independentemente do mês aberto no app.
- Reprogramação individual de vencimento, integração bancária, execução de pagamentos, boletos, compartilhamento familiar, outras moedas, e-mail/WhatsApp e push remoto fora da v1.

## Regras aprovadas

| Tema | Decisão |
| --- | --- |
| Datas e competência | Datas civis completas; competência pelo ano/mês de vencimento. Baixa posterior permanece na competência original. Uma série pode ter várias ocorrências no mês. |
| Início | Início explícito, padrão no período atual; permitir cadastro retroativo intencional. Não gerar antes do início. Informar data inicial, com hoje como padrão, editável inclusive para o passado. |
| Dias 29–31 | Ajustar ao último dia do mês quando necessário, explicando a regra no cadastro; preservar o dia original da série nos meses seguintes. |
| Baixa | Uma baixa integral por ocorrência, valor positivo em centavos, editável e sem pagamentos parciais. Permitir data passada e antecipação; bloquear data de baixa futura e duplicidade. |
| Reversão | Confirmar antes de desfazer; ao cancelar, manter baixa. Ao confirmar, reabrir a mesma ocorrência e recalcular totais/status. |
| Atraso | Comparar datas completas; pagamento em mês posterior continua em atraso. |
| Débito automático | Apenas intenção de agendamento; exige baixa manual. Após vencer sem baixa, fica pendente em atraso. |
| Resumo | A pagar/a receber somam abertas. Saldo previsto do mês = receitas menos despesas, com valores efetivos nas baixadas e previstos nas abertas. Não é saldo bancário. |
| Previsão mensal | Média das baixas disponíveis nas seis competências imediatamente anteriores, excluindo o mês selecionado; não buscar meses mais antigos para completar seis baixas. Sem baixas, usar valor base; arredondar para centavos. Calcular a média por ocorrência baixada dessa série na janela, não a média dos totais mensais; usar a competência de vencimento para selecionar as baixas. Anual sem baixas na janela usa valor base. |
| Histórico | Seis competências até o mês selecionado; realizados e previstos distintos. Média realizada exclui abertas. Gráfico com totais mensais realizados e previstos separados, detalhamento das ocorrências e média realizada por ocorrência baixada, com rótulo explícito. Mês sem ocorrências tem total zero, mas não adiciona uma baixa zero à média. |
| Edição | Prospectiva, preservando competências anteriores e todas as baixas; atualizar abertas no período de efeito. Data de efeito hoje ou futura; preservar ocorrências anteriores à data e todas as baixas. Bloquear alteração de frequência/início/término que eliminaria ocorrência já baixada. |
| Encerramento | Preservar histórico; bloquear encerramento que eliminaria ocorrências baixadas. Exclusão definitiva somente para cadastro sem baixas, com confirmação. |
| Painel interno | Referente ao mês selecionado, inclui vencidas, hoje e próximos, inclusive automáticos sem baixa. Antecedência padrão de três dias, configurável de um a dez. |

## Recorrências e convenções de implementação

- Frequência diária, semanal, mensal ou anual, com intervalo inteiro positivo N (a cada N unidades). Valor sempre por ocorrência; não dividir automaticamente valor total.
- Semanal permite selecionar um ou mais dias da semana. Convenção: semana de segunda a domingo, ancorada na semana da data inicial; filtrar dias anteriores ao início. A primeira data elegível é a ocorrência 1.
- Término: nunca, em data inclusiva ou após N ocorrências (inclui a primeira), com quantidade inteira positiva. A contagem considera ocorrências geradas, pagas ou abertas; reversão não altera a contagem.
- Mensal/anual ancoram na data original, sem acumular deslocamentos de meses menores. Anual em 29/02 usa 28/02 nos anos comuns e volta a 29/02 nos bissextos; informar ajuste no cadastro.
- Encerramento define a última data inclusiva ativa, hoje ou futura, e preserva histórico. Não eliminar baixas posteriores; bloquear ação incompatível.
- Edição de frequência cria revisão prospectiva da série. Ocorrências anteriores ao corte e baixadas mantêm identidade e dados; abertas afetadas são reconciliadas sem duplicação. Limite por quantidade vale para a série toda: ocorrências preservadas consomem a contagem; ao alterar a quantidade, mostrar total e restantes. Bloquear total menor que a quantidade preservada. Não oferecer exceções do tipo “terceira terça-feira” ou integração Google Calendar nesta v1.
- Arredondar média positiva para o centavo mais próximo; empate exato de meio centavo arredonda para cima. Preservar precisão até o resultado final.

## Notificações e critérios de aceite

- Resumo local diário às 9h, horário ajustável, opção de desativar; solicitar autorização do sistema no contexto da ativação. Negativa mantém o app e painel interno utilizáveis.
- Escopo global pela data real: vencidas, vencimentos de hoje e próximos até hoje + antecedência inclusive; exclui baixadas. Inclui receitas e automáticos. Não emitir resumo vazio.
- Atualizar agendamentos após baixa, reversão, edição, encerramento, importação e alteração de preferências; reconciliar na retomada e em eventos suportados pelo sistema. Evitar duplicações após reinício.
- Ao tocar, abrir a visão de avisos globais com acesso à ocorrência/competência correspondente, sem mudar o significado mensal do painel existente.
- O horário é desejado, sujeito às permissões e políticas do sistema. A implementação precisa validar janela de agendamento e reposição com o app fechado; não prometer execução diária ilimitada em segundo plano. Falha do agendador não desfaz operações financeiras.

## Exemplos de aceite já definidos

Estes exemplos devem alimentar os testes da fase 3; não foram executados como testes nesta etapa.

- Resumo de setembro: receita aberta de R$ 3.000,00; despesa aberta de R$ 200,00; despesa baixada por R$ 110,00. A receber = R$ 3.000,00; a pagar = R$ 200,00; saldo previsto = R$ 2.690,00.
- Baixa e reversão: dar baixa na despesa de R$ 200,00 por R$ 220,00 reduz a pagar para zero e o saldo previsto para R$ 2.670,00. Cancelar a confirmação de reversão mantém esses números. Confirmar a reversão restaura a pagar de R$ 200,00 e saldo de R$ 2.690,00.
- Previsão mensal de setembro: baixas de abril R$ 100,00, junho R$ 120,00 e agosto R$ 110,00 produzem R$ 110,00. Meses sem baixa não entram como zero; baixa de setembro e baixas anteriores a março não entram. Sem baixas entre março e agosto, usar o valor base.
- Arredondamento: baixas de R$ 100,00, R$ 100,00 e R$ 100,01 produzem previsão de R$ 100,00. Em empate, R$ 100,00 e R$ 100,01 produzem R$ 100,01.
- Datas: vencimento em 31/01/2027 gera 28/02/2027 e depois 31/03/2027. Vencimento de 31/12/2026 baixado em 02/01/2027 permanece em dezembro e é classificado em atraso.
- Automático: vencimento em 10/09/2026 sem baixa está pendente em atraso em 11/09/2026, sem inferir pagamento.
- Validação: data de baixa posterior a hoje, valor zero/negativo e segunda baixa da mesma ocorrência não gravam dados.
- Backup: importar arquivo inválido mantém a base intacta; cancelar a restauração mantém a base; confirmar arquivo válido substitui os dados de forma transacional e atualiza os avisos.

- Diária: início em 30/09/2026, intervalo 1 e três ocorrências de R$ 10,00 gera 30/09, 01/10 e 02/10; totais previstos de R$ 10,00 em setembro e R$ 20,00 em outubro.
- Semanal: início 14/09/2026, segunda e quarta, intervalo de duas semanas e quatro ocorrências gera 14/09, 16/09, 28/09 e 30/09. Término em 28/09, em vez de quantidade, inclui essa data e exclui 30/09.
- Mensal: R$ 100,00 com 12 ocorrências resulta em R$ 1.200,00 previstos, com baixa individual em cada ocorrência.
- Anual: início em 29/02/2024 gera 28/02/2025 e volta a 29/02/2028; sem baixas nos seis meses anteriores, previsão é o valor base.
- Média por ocorrência: duas baixas de R$ 10,00 e uma de R$ 40,00 nos seis meses anteriores geram R$ 20,00 por ocorrência futura; quatro ocorrências no mês totalizam R$ 80,00 previstos.
- Edição: alteração com efeito em 20/09 preserva ocorrência de 19/09 e qualquer baixa de 21/09; mudança que removeria a ocorrência baixada de 21/09 é bloqueada.
- Notificação: hoje 30/09 e antecedência três dias inclui pendências de 01/10 a 03/10, além de hoje e vencidas, mesmo com agosto aberto no app; uma baixa antes do aviso retira a ocorrência do resumo agendado.

## Situação

Fase 0 concluída como definição de produto e arquitetura. Evidências: este registro, ADR 001, contexto e plano atualizados. Implementação, resolução final de versões de dependências, builds e testes de dispositivos pertencem às fases seguintes; nenhum código de produto foi implementado nesta etapa.
