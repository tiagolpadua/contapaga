#!/bin/sh
# Roda a suite de testes com cobertura e exibe a taxa de cobertura atual.
set -e

cd "$(dirname "$0")"

FLUTTER=flutter
if command -v fvm >/dev/null 2>&1; then
  FLUTTER="fvm flutter"
fi

rm -rf coverage
$FLUTTER test --coverage
echo

LCOV_FILE=coverage/lcov.info

if [ ! -f "$LCOV_FILE" ]; then
  echo "Nenhum arquivo de cobertura gerado em $LCOV_FILE."
  exit 1
fi

if command -v lcov >/dev/null 2>&1; then
  lcov --summary "$LCOV_FILE" 2>/dev/null | grep -E "lines|functions" || true
else
  # Fallback sem lcov instalado: soma manual das linhas DA:<linha>,<hits> do lcov.info.
  awk -F',' '
    /^DA:/ {
      total++
      if ($2 > 0) covered++
    }
    END {
      if (total == 0) {
        print "Nenhuma linha rastreada encontrada."
        exit 1
      }
      pct = (covered / total) * 100
      printf "Cobertura de linhas: %d/%d (%.2f%%)\n", covered, total, pct
    }
  ' "$LCOV_FILE"
fi
