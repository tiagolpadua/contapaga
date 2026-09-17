# Fase de Qualidade

**Data:** 16/09/2026

## Decisões Tomadas
1. **Lint**: Migramos do `flutter_lints` básico para o pacote mais rigoroso `very_good_analysis`, desativando regras de formatação excessivamente estritas para o contexto atual (`public_member_api_docs`, `lines_longer_than_80_chars` e `avoid_catches_without_on_clauses`). Isso adiciona segurança (como checagem de tipos mais forte) reduzindo manutenção própria de lints.
2. **Cobertura de Código**: Estabeleceu-se uma meta mínima global de cobertura de código em 80% (medição inicial: 91.1%). O domínio de negócios (pasta `domain`) tem gate próprio de 90% no CI, aplicado sobre um `lcov.info` extraído apenas de `lib/features/*/domain`; enquanto essa pasta não tiver linhas executáveis (hoje só há uma interface abstrata, já que as fases 3+ ainda não implementaram regras financeiras), o gate é pulado automaticamente e passa a valer assim que houver código de domínio testável.
3. **CI**: As checagens de coverage e `gitleaks` foram incorporadas ao GitHub Actions. O relatório de coverage é salvo como artefato interno da pipeline.
4. **Dependências**: Implementado `dependabot.yml` para atualizações semanais, centralizadas e agrupadas.
5. **Git Hooks e Padrões**: Configurado um hook de pre-commit e documentado as regras de contribuição (`CONTRIBUTING.md`) baseadas em Conventional Commits.
