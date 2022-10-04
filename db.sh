#!/bin/bash

# Deps
# apt install curl jq sqlite3
# pip install sqlite-utils

DB=${1-salas}.db

curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getCursos.php | jq .cursos > curso.json 
sqlite-utils insert $DB curso curso.json --pk=id --replace

CURSO_COUNT=$(cat curso.json | wc -l)
for CURSO_ID in $(cat curso.json | jq -r .[].id | sort -n); do
    echo "Downloading: $CURSO_ID/$CURSO_COUNT"
    curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getHorarios.php?id=$CURSO_ID | jq .horarios | sqlite-utils insert $DB horario - --pk=id --replace &
    curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getMensagens.php?id=$CURSO_ID | jq .mensagens | sqlite-utils insert $DB mensagem - --pk=id --replace &
done
rm curso.json

curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getSalas.php | jq .salas | sqlite-utils insert $DB sala - --pk=id --replace


echo "Waiting for processes to finish" 
wait $(jobs -p)
echo "All processes finished"

echo "File $DB generated"

# sqlite3 salas.db .tables
