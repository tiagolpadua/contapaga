# Contribuindo com o Conta Paga

Obrigado pelo interesse em contribuir! Siga as diretrizes abaixo para manter o código saudável.

## Configuração Local

1. Instale o Flutter SDK (`>=3.47.4`).
2. Rode `flutter pub get`.
3. Configure o pre-commit hook:
   ```bash
   git config core.hooksPath tool/githooks
   ```

## Regras de Commit

Usamos [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `chore:` Tarefas de manutenção, dependências
- `docs:` Alterações na documentação
- `test:` Inclusão ou correção de testes

## Política de Branch
- A branch `main` é protegida.
- Crie branches a partir da `main` no formato `feat/nome-da-feature` ou `fix/nome-do-bug`.
- Faça PRs curtos e focados.

## Antes de abrir um PR
Certifique-se de rodar localmente e que tudo passe:
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```
A cobertura mínima exigida pelo CI é de 80% no geral e 90% para regras de negócio (`lib/features/*/domain`). O gate de domain é pulado automaticamente enquanto essa pasta não tiver código executável (situação atual, pré-fase 3) e passa a valer assim que houver lógica de domínio testável.
