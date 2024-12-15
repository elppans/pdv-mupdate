#!/bin/bash

# Variáveis: atulibver
USR="pdvtec"
PWD="I37#P84G0qx@"
ATULIB_DIR="/Zanthus/Zeus/pdvJava/ATULIB"
PDVJ_DIR="/Zanthus/Zeus/pdvJava"
PDV_ZMAN="PDV_ZMAN_1_X_X_732_CZ_L.ZTA"
LIB_ZLIB="LIB_ZLIB_1_0_115_L64.ZTA"
FPDV_ZMAN="ftp://ftp.zanthus.com.br:2142/pub/Zeus_Frente_de_Loja/v_1_X_X/$PDV_ZMAN"
FLIB_ZLIB="ftp://ftp.zanthus.com.br:2142/pub/Zeus_Frente_de_Loja/_Complementares/libs/$LIB_ZLIB"
ETIQUETL="/Zanthus/Zeus/pdvJava/ETIQUETL.TXT"
ATUVER="/Zanthus/Zeus/pdvJava/ATUVER_0.TXT"
# FIM Variáveis: atulibver

# 1ª parte: 7z-lnx_install
# https://github.com/ip7z/7zip/releases

# Verifica se o comando 7z existe
if ! command -v 7z &> /dev/null; then
    echo "O comando '7z' não foi encontrado. Iniciando a instalação..."

    # Define o diretório de instalação e a URL de download
    INSTALL_DIR="/opt/7zip"
    URL="https://github.com/ip7z/7zip/releases/download/24.09/7z2409-linux-x64.tar.xz"
    TAR_FILE="7z2409-linux-x64.tar.xz"

    # Cria o diretório de instalação
    mkdir -p "$INSTALL_DIR"

    # Navega para o diretório de instalação
    cd "$INSTALL_DIR" || exit 1

    # Faz o download do arquivo usando curl
    echo "Baixando o 7-Zip..."
    curl -JOLk "$URL"

    # Extrai o arquivo baixado
    echo "Extraindo o pacote..."
    tar -xJf "$TAR_FILE"

    # Cria o link simbólico para o comando 7z
    echo "Criando link simbólico para /usr/local/bin/7z..."
    ln -sf "$INSTALL_DIR/7zz" /usr/local/bin/7z

    echo "Instalação concluída! O comando '7z' está disponível."
# else
    # echo "O comando '7z' já está instalado."

fi
# Fim: 7z-lnx_install

# 2ª parte: atulibver
# Cria o diretório, se necessário
mkdir -p "$ATULIB_DIR"

# Função para verificar e remover apenas o arquivo relacionado
verify_and_clean_file() {
    local dir="$1"
    local expected_file="$2"

    # Caminho completo do arquivo esperado
    local file_path="$dir/$expected_file"

    # Se o arquivo existe e não corresponde ao esperado, remova-o
    if [ -f "$file_path" ]; then
        echo "Arquivo esperado encontrado: $expected_file."
    else
        echo "Removendo arquivos antigos relacionados a $expected_file..."
        find "$dir" -type f -name "$(basename "$expected_file" | cut -d'_' -f1)*" -exec rm -f {} +
    fi
}

# Verifica e limpa apenas para PDV_ZMAN
echo "Verificando $PDV_ZMAN no diretório $ATULIB_DIR..."
verify_and_clean_file "$ATULIB_DIR" "$PDV_ZMAN"

# Baixa o arquivo PDV_ZMAN
echo "Baixando $PDV_ZMAN para $ATULIB_DIR..."
if curl -u "$USR:$PWD" "$FPDV_ZMAN" -o "$ATULIB_DIR/$PDV_ZMAN"; then
    echo "$PDV_ZMAN baixado com sucesso."
else
    echo "Erro ao baixar $PDV_ZMAN." >&2
fi

# Verifica e limpa apenas para LIB_ZLIB
echo "Verificando $LIB_ZLIB no diretório $ATULIB_DIR..."
verify_and_clean_file "$ATULIB_DIR" "$LIB_ZLIB"

# Baixa o arquivo LIB_ZLIB
echo "Baixando $LIB_ZLIB para $ATULIB_DIR..."
if curl -u "$USR:$PWD" "$FLIB_ZLIB" -o "$ATULIB_DIR/$LIB_ZLIB"; then
    echo "$LIB_ZLIB baixado com sucesso."
else
    echo "Erro ao baixar $LIB_ZLIB." >&2
fi

#echo "Processo concluído!"
# Fim: atulibver

# 3ª parte: pdvJava2, atualização via Manager, ATULIB_0.TXT
CONF_UPDATE_MODE='Manager'
export CONF_UPDATE_MODE

source /Zanthus/Zeus/pdvJava/ATULIB_0.TXT
# ATUAL=
# JA_TENTOU=NAO
# PERMITIDO=SIM
# PURO_ZTAR=LIB_ZLIB_1_0_59_L64.ZTA
# VERSAO=LIB_ZLIB_1_0_59_
# ZTAR=/Zanthus/Zeus/pdvJava/ATULIB/LIB_ZLIB_1_0_59_L64.ZTA

# source /Zanthus/Zeus/pdvJava/ATUVER_0.TXT
# ATUAL=ZMAN_1_11_33_207

if [ "$CONF_UPDATE_MODE" == 'Manager' ]; then
	if [ -n "$VERSAO" ] || [ -n "$PURO_ZTAR" ] || [ -n "$ZTAR" ]; then
		cd /Zanthus/Zeus/pdvJava/
		./zantarlb.xz ATULIB_0.TXT /Zanthus/Zeus/lib_inter |grep "Ja esta com versao atualizada"
		if [ "$?" != "0" ];then
			# Descompactando so_u64 e copiando para pasta Zanthus/Zeus/so_u64
			if [ -n "$(ls -A /Zanthus/Zeus/lib_inter)" ]; then
				# Compactar Pasta so_u64 para backup
				echo -e "[Backup das Bibliotecas (lib_u64) realizada com sucesso!]\n"
				find /Zanthus/Zeus/lib_u64_* -type f -mtime +15 -exec rm -rf {} \;
				cd /Zanthus/Zeus/
				tar -czf lib_u64_$(date +%Y-%m-%d_%H-%M-%S).tar.gz lib_u64
				cd lib_u64
				rm -rf *.*

				cd /Zanthus/Zeus/lib_inter/
				tar -xf ExecLibs.tar*
				cp -f * /Zanthus/Zeus/lib_u64/
                                cd /Zanthus/Zeus/
                                rm -rf /lib_inter/*
			fi
			echo -e "[Atualizacao das Bibliotecas via Manager (lib_u64) realizada com sucesso!]\n"
		else
			echo -e "[Nao existem atualizacoes de (lib_u64) a serem realizadas.!]\n"
		fi
	fi

fi
# Fim: pdvJava2, atualização via Manager, ATULIB_0.TXT

# 4ª parte: Atualização via Manager, local. atuver
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
    7z x "$ATULIB_DIR/$PDV_ZMAN" -o"$PDVJ_DIR" -aoa -y -bb0 > /dev/null 2>&1

    # Verifica se o arquivo extraído existe e tem o nome correto
    if [ -f "$PDVJ_DIR/$PDV_ZMAN_EX" ]; then
        # Se o arquivo foi extraído corretamente, tenta extrair como .tar
        tar -xf "$PDVJ_DIR/$PDV_ZMAN_EX" -C "$PDVJ_DIR"
    else
        echo "Arquivo extraído não encontrado: $PDV_ZMAN_EX"
        exit 1
    fi

    # Atualizar o arquivo ATUVER_0.TXT com a nova versão
    sed -i "s/^ATUAL=.*/ATUAL=ZMAN_$VERSAO_ZMAN/" "$ATUVER"
else
    echo "A versão do ZMAN já está atualizada no arquivo ATUVER_0.TXT. Nenhuma ação necessária."
fi
# Fim: Atualização via Manager, local. atuver
