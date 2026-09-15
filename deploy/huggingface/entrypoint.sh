#!/bin/sh
# MoneyPrinterTurbo — entrypoint para Hugging Face Spaces.
#
# O armazenamento do HF Spaces é efêmero: a cada reinicialização do contêiner
# o config.toml (com as chaves de API salvas pela WebUI) é perdido. Para não
# precisar redigitar as chaves, o conteúdo completo do config.toml pode ser
# fornecido via Secret "MPT_CONFIG_TOML" nas Settings do Space; ele é
# restaurado aqui, antes de subir o servidor.
set -e

if [ -n "$MPT_CONFIG_TOML" ]; then
    printf '%s\n' "$MPT_CONFIG_TOML" > /MoneyPrinterTurbo/config.toml
    echo "[entrypoint] config.toml restaurado a partir do Secret MPT_CONFIG_TOML"
elif [ -f /MoneyPrinterTurbo/config.toml ]; then
    echo "[entrypoint] usando config.toml existente na imagem"
else
    echo "[entrypoint] MPT_CONFIG_TOML nao definido; o app criara um config.toml padrao"
fi

# Mesmos parâmetros do CMD oficial da imagem (docker-compose.release.yml),
# apenas agrupados aqui para caber no ENTRYPOINT.
exec streamlit run ./webui/Main.py \
    --server.address=0.0.0.0 \
    --server.port=8501 \
    --browser.serverAddress=127.0.0.1 \
    --server.enableCORS=True \
    --browser.gatherUsageStats=False \
    --client.toolbarMode=minimal \
    --logger.hideWelcomeMessage=True \
    --server.showEmailPrompt=False
