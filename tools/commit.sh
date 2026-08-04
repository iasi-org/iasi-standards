#!/usr/bin/env bash
#
# ------------------------------------------------------------------------------
# IASI - Ingeniería Asistida por Sistemas Inteligentes
# ------------------------------------------------------------------------------
#
# Script.....: commit.sh
# Descripción: Añade todos los cambios al repositorio, crea un commit y realiza
#              un push al remoto.
#
# Uso........: ./git-push.sh "Mensaje del commit"
# Se ejecuta como /p/iasi/iasi-standrads/tools/commit.sh desde el directorio adecuado
#
# Parámetros.:
#   $1..$n    Mensaje del commit.
#
# Requisitos.:
#   - Git instalado.
#   - Repositorio inicializado.
#   - Rama con remoto configurado.
#
# Autor......: IASI Project
# Licencia...: Apache License 2.0
#
# ------------------------------------------------------------------------------
set -e

if [ $# -eq 0 ]; then
    echo "Uso:  $0 mensaje del commit"
    exit 1
fi

MESSAGE="$*"

echo "==> git add"
git add . -A
if [ $? -ne 0 ] ; then
    echo ERROR añadiendo archivos a stage
    exit 10
fi

echo "==> git commit"
git commit -m "$MESSAGE"
if [ $? -ne 0 ] ; then
    echo ERROR haciendo commit
    exit 10
fi

echo "==> git push"
git push
if [ $? -ne 0 ] ; then
    echo ERROR subiendo a github
    exit 10
fi

echo "✔ Push completado correctamente."