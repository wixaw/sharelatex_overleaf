#!/bin/sh

script_rep_projet_owner=/local/sharelatex/scripts/core/js/replace_projets_owner.js

idUser=$1
idProject=$2

cd /local/sharelatex/compose/ ; docker-compose exec -T mongo mongo sharelatex --eval "var param1='$idUser';param2='$idProject'" $script_rep_projet_owner

