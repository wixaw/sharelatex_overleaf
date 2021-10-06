#!/bin/sh

script_get_projet_owner=/local/sharelatex/scripts/core/js/get_projet_owner.js

idProject=$1

cd /local/sharelatex/compose/ ; docker-compose exec -T mongo mongo sharelatex --eval "var param1='$idProject'" $script_get_projet_owner
