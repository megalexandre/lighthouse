# Lighthouse

## Rodar os testes `.feature`

Os cenários de comportamento são arquivos `.feature` (Gherkin). Cada um vira
um `x_test.dart` ao lado dele, gerado pelo build_runner. Há dois tipos:

| Onde | Contra o quê | Precisa de |
| --- | --- | --- |
| `lighthouse/test/scenarios/**/*.feature` | o app com fakes, sem rede | nada |
| `lighthouse/integration_test/features/*.feature` | o app real no Linux, sob Xvfb | o servidor de teste (`$JELLYFIN_TEST_URL`) |

Rode de dentro de `lighthouse/`, no dev container. O script gera os testes a
partir dos `.feature` antes de rodar, então um cenário editado sempre roda como
está escrito.

```bash
cd lighthouse

tool/scenarios.sh                                    # todos os cenários
tool/scenarios.sh test/scenarios                     # só os que rodam com fakes
tool/scenarios.sh integration_test/features          # só os do app real
tool/scenarios.sh test/scenarios/search/search.feature           # um arquivo
tool/scenarios.sh test/scenarios/search/search.feature "Ctrl+F"  # só os cenários com "Ctrl+F" no nome
```

No lugar do `.feature` também serve o `_test.dart` gerado ou qualquer arquivo
do `step/` ou do `hook/` daquele cenário.

### No VS Code

Em **Terminal → Run Task**:

- **lighthouse: scenarios (all features)**: todos os cenários.
- **lighthouse: scenarios (this feature)**: o cenário aberto no editor; pede
  parte do nome de um cenário (vazio roda todos do arquivo).
- **lighthouse: scenarios (regenerate on save)**: deixa o build_runner
  regenerando os testes a cada vez que um `.feature` é salvo, e cria o
  esqueleto de um passo novo em `step/`. Pare-o pela lixeira do terminal.
`