#!/bin/bash

# Definir as variáveis
ATULIB_DIR="/Zanthus/Zeus/pdvJava/ATULIB"
PDV_ZMAN="PDV_ZMAN_1_X_X_732_CZ_L.ZTA"
PDVJ_DIR="/Zanthus/Zeus/pdvJava"
ETIQUETL="/Zanthus/Zeus/pdvJava/ETIQUETL.TXT"
ATUVER="/Zanthus/Zeus/pdvJava/ATUVER_0.TXT"

# Carregar o arquivo ATUVER_0.TXT para acessar a variável ATUAL
source "$ATUVER"

# Extrair a versão do ZMAN de ETIQUETL.TXT
VERSAO_ZMAN=$(grep 'ZMAN' "$ETIQUETL" | sed -e 's/\./_/g' | head -n1 | awk '{print $2}')
VERSAO_ATUAL=$(echo "$ATUAL" | cut -d'=' -f2)

# Verifica se a versão no ATUVER_0.TXT já é a mesma da versão extraída
if [ "$VERSAO_ATUAL" != "ZMAN_$VERSAO_ZMAN" ]; then
    echo "Versão do ZMAN no ATUVER_0.TXT diferente da versão extraída. Atualizando..."

    # Nome do arquivo extraído sem a extensão .ZTA
    PDV_ZMAN_EX="$(basename "$PDV_ZMAN" .ZTA)"

    # Extração do arquivo .ZTA
    7z x "$ATULIB_DIR/$PDV_ZMAN" -o"$PDVJ_DIR" -aoa

    # Verifica se o arquivo extraído existe e tem o nome correto
    if [ -f "$PDVJ_DIR/$PDV_ZMAN_EX" ]; then
        # Se o arquivo foi extraído corretamente, tenta extrair como .tar
        tar -xvf "$PDVJ_DIR/$PDV_ZMAN_EX" -C "$PDVJ_DIR"
    else
        echo "Arquivo extraído não encontrado: $PDV_ZMAN_EX"
        exit 1
    fi

    # Atualizar o arquivo ATUVER_0.TXT com a nova versão
    sed -i "s/^ATUAL=.*/ATUAL=ZMAN_$VERSAO_ZMAN/" "$ATUVER"
else
    echo "A versão do ZMAN já está atualizada no arquivo ATUVER_0.TXT. Nenhuma ação necessária."
fi
