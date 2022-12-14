#!/bin/bash

# Deps
# apt install curl jq sqlite3
# pip install sqlite-utils
# npm install -g http-server --no-package-lock

DB=${1-salas}.db

# unidade
sqlite-utils insert $DB unidade unidade.json --replace

# Appending Unidade > {"id": 3, "nome": "Centro Universitário Senac - Santo Amaro"}
curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getCursos.php | jq .cursos | jq --arg val 3 '.[] += {idUnidade: $val}' > curso.json 
sqlite-utils insert $DB curso curso.json --pk=id --replace


CURSO_COUNT=$(cat curso.json | wc -l)
for CURSO_ID in $(cat curso.json | jq -r .[].id | sort -n); do
    echo "Downloading: $CURSO_ID/$CURSO_COUNT"
    curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getHorarios.php?id=$CURSO_ID | jq '.horarios' | jq --arg val $CURSO_ID '.[] += {idCurso: $val}' | sqlite-utils insert $DB horario - --pk=id --replace &
    curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getMensagens.php?id=$CURSO_ID | jq '.mensagens' | jq --arg val $CURSO_ID '.[] += {idCurso: $val}' | sqlite-utils insert $DB mensagem - --pk=id --replace &
done
rm curso.json

# Foreign key
sqlite-utils add-foreign-key $DB horario idCurso curso id
sqlite-utils add-foreign-key $DB mensagem idCurso curso id

# sala
curl -s http://sistemasparainternet.azurewebsites.net/horarios/2.0/getSalas.php | jq .salas | sqlite-utils insert $DB sala - --pk=id --replace

# professor
sqlite-utils insert $DB professor professor.json --replace

echo "Waiting for processes to finish" 
wait $(jobs -p)
echo "All processes finished"

echo "File $DB generated"

# sqlite3 salas.db .tables
