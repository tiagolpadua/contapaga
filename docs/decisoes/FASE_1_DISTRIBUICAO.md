# Fase 1 — titularidade e identidade de distribuição

Iniciada em 16/09/2026. Status: em andamento, aguardando informações do titular. Nenhum cadastro, contrato, compra ou registro de aplicativo foi realizado nos consoles nesta etapa.

## Decisões herdadas da fase 0

Nome do produto: **Conta Paga**. Lançamento gratuito no Brasil, em português do Brasil, para celulares Android. iOS foi adiado por decisão posterior do titular. Sem publicidade, compras internas ou assinatura na v1. Login Google e backup em nuvem pertencem à evolução Pro futura.

A classificação comercial de gratuidade está definida. Categoria das lojas e classificação etária serão preenchidas conforme o conteúdo efetivo na fase 8; não inferir respostas aos questionários das lojas.

## Respostas recebidas do titular — escopo vigente

- Publicação como **pessoa física**, sob responsabilidade do usuário.
- **Somente Android/Google Play neste lançamento.** iOS/App Store adiados; inscrição Apple, equipe, Bundle ID, Xcode e iPhone físico não bloqueiam esta fase.
- Conta Google Play declarada ativa e verificada, criada **após 13/11/2023**. Acesso administrativo, multifator e pendências contratuais ainda devem ser conferidos no console.
- Domínio controlado confirmado: **mutumsoft.com.br**. Identificador escolhido: **`br.com.mutumsoft.contapaga`** para Android; mesma identidade aceita para eventual iOS futuro. Disponibilidade/registro nos serviços ainda não verificados, e identificador já aplicado ao código Android na fase 2.
- E-mail público e URLs de suporte/privacidade serão providenciados pelo titular.
- Android físico disponível; modelo/versão ainda não informados. Titular consegue reunir os testadores; não significa que já foram recrutados ou inscritos.
- Teste fechado aplicável: pelo menos 12 participantes inscritos continuamente por 14 dias, seguido de solicitação de acesso à produção, conforme referência oficial abaixo. Responsável pelo recrutamento: titular; execução nas fases 9–10.

## Plano de dispositivos e dependências

Usar Android físico para fluxos reais, notificações e instalação via Play, complementando cobertura de versões/tamanhos com emuladores. Registrar modelo/versão na preparação do QA. Acesso a iPhone e testes iOS ficam adiados junto à plataforma, sem bloquear o lançamento Android.

## Inventário verificado no repositório e na máquina

| Item | Evidência em 16/09/2026 | Próxima ação |
| --- | --- | --- |
| Android applicationId/namespace | `br.com.mutumsoft.contapaga`, aplicado na fase 2 | Verificar/registrar no Play Console; código não reserva a identidade |
| iOS Bundle ID | `com.example.contapaga`, em `ios/Runner.xcodeproj/project.pbxproj` | Adiado: identidade proposta aceita, registro Apple futuro |
| Equipe Apple configurada | `Z4R232Y5QA` | Adiado: iOS fora do lançamento atual |
| Nome instalado Android | `Conta Paga`, aplicado na fase 2 | Confirmado no APK de desenvolvimento |
| Nome instalado iOS | `Contapaga` no Info.plist | Aplicar Conta Paga na preparação de identidade/build |
| Ambiente Mac | macOS 26.6.2; Xcode 26.6, build 17F113 | Executar diagnóstico completo na fase 2 e build assinado na fase 9 |
| Xcode selecionado | `/Applications/Xcode.app/Contents/Developer` | Acesso a equipe, certificados e provisioning ainda não verificado |
| Android/iPhone físicos | Titular possui Android; não possui iPhone no momento | Registrar modelo/versão Android; iPhone fora do lançamento |

Domínio e ID Android já foram confirmados pelo titular; aplicação ao código pertence à preparação técnica. Disponibilidade de nome/identificador depende de verificação nos serviços; pesquisa pública ou build local não substitui essa verificação.

## Pendências para concluir a fase

- Conferir acesso às funções de publicação, autenticação multifator e contratos no Play Console.
- Verificar/criar o registro Conta Paga no Play Console e associar o package ID escolhido no fluxo de distribuição; registrar link administrativo e evidência. Não declarar o ID reservado somente pela escolha do nome.
- Titular fornecer e-mail público e URLs planejadas de suporte/privacidade; publicação dessas páginas será feita na fase 8.
- Registrar organização do recrutamento e modelo/versão do Android antes dos testes.

Guardar somente decisões e status no repositório, sem credenciais nem documentos pessoais.

## Requisitos externos consultados

Referências oficiais consultadas em 16/09/2026; situação específica da conta deve ser conferida no console.

- Google Play: inscrição com taxa única de US$ 25; concluir as verificações apresentadas à conta. [Cadastro no Play Console](https://support.google.com/googleplay/android-developer/answer/6112435).
- Referência futura, não aplicável ao titular pessoa física: conta Google de organização normalmente exige D-U-N-S e dados consistentes da entidade. [Tipos de conta](https://support.google.com/googleplay/android-developer/answer/13634885) e [informações de cadastro](https://support.google.com/googleplay/android-developer/answer/13628312).
- Referência futura, fora do escopo atual: Apple Developer Program: US$ 99 por year, ou moeda local quando disponível; Apple Account com autenticação de dois fatores. Conferir requisitos da entidade, autoridade para contratação e documentos no fluxo de inscrição. [Inscrição Apple](https://developer.apple.com/help/account/membership/program-enrollment).
- Google: contas pessoais criadas após 13/11/2023 precisam de teste fechado com ao menos 12 participantes inscritos continuamente por 14 dias antes de solicitar acesso à produção. Aprovação não é automática; registrar feedback e participação real. [Requisito de teste](https://support.google.com/googleplay/android-developer/answer/14151465).

## Sequência para concluir a fase

1. Conferir status, acesso e contratos Google; identidade do titular e domínio já estão confirmados por declaração.
2. Criar/verificar registro Conta Paga no Play Console com idioma pt-BR, type aplicativo e distribuição gratuita; confirmar a identidade Android no fluxo pertinente.
3. Registrar contato e URLs fornecidos pelo titular.
4. Organizar recrutamento do teste fechado e inventário do Android de QA. O teste de 14 dias depende de build testável e não precisa estar executado para concluir a fase 1.

## Critério de conclusão

Titular com acesso apto à distribuição Google Play, identidade/registro Android definidos, suporte/domínio encaminhados e dependências de teste/dispositivos registradas. A inspeção local e a consulta às regras gerais não concluem a fase sem evidências das contas e decisões do titular.
