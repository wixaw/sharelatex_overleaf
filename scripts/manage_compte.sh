#!/bin/bash
#############################
## Description : Gestion des comptes sharelatex
## Utilisation :
##  chmod +x ./manage_compte.sh
##  ./manage_compte.sh creer "AdresseMail"
##  ./manage_compte.sh supprimer "AdresseMail" ( inactif !)
#############################

#########################
## Variables
type=$1
destMail="sharelatex-admin@domain.fr"
logFile="/local/sharelatex/scripts/manage_compte.log"
date=$(date)
mail=$2
idproject=$2
idnewowner=$3

#########################
## Fonctions
# display_help
function display_help {
    echo "#############################################################"
    echo "############## AIDE SCRIPT DE GESTION DE CPT ################"
    echo "# Suppression de compte "
    echo "#    # On obtient les informations du compte (dont les collaborations à migrer)"
    echo "#    ./manage_compte.sh info mail@utilisateur"
    echo "#    # On execute les commandes indiquées"
    echo "#    ./manage_compte.sh replace_owner idprojet idnewowner"
    echo "#    # Une fois toutes les collaborations migrées, on peux supprimer le compte"
    echo "#    ./manage_compte.sh supprimer mail@utilisateur"
    echo "#    # On supprime les anciens fichiers si demandé"
    echo "#    rm -rf /local/sharelatex/data/user_files/IDprojet*"
    echo "#############################################################"
    echo "# Creation de compte "
    echo "#    ./manage_compte.sh creer prenom.nom@domain.fr"
    echo "#############################################################"
}

# check mail
function validator {
  regex="^([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]?)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$" 
  if [[ $1 =~ ${regex} ]]; then
    printf "* %-48s \e[1;32m[mail ok]\e[m\n" "${1}"
  else
    printf "* %-48s \e[1;31m[mail nok]\e[m\n" "${1}"
    exit
  fi
}
# create cookie
function create_cookie {
    cooktmp=$(python3 << EOF
import re
# pip3 install mechanize
from mechanize import Browser
login = "cpt-admin@domain.fr"
password = "setPasswdAdmin"
br = Browser()
br.set_handle_robots(False)
br.open("https://sharelatex.domain.fr/login")
br.select_form('loginForm')
br.form['email'] = login
br.form['password'] = password
br.submit()
# if successful we have some cookies now
cookies = br._ua_handlers['_cookies'].cookiejar
# convert cookies into a dict usable by requests
cookie_dict = {}
for c in cookies:
    if c.name == "sharelatex.sid":
        print(c.value)
    cookie_dict[c.name] = c.value
#print(cookie_dict)
EOF
)
    cookie="Cookie: sharelatex.sid="$cooktmp
}

#########################
## Main
if [ "$type" = "creer" ]; then
	echo "Creation de compte"

    # On test le mail en argument
    validator "$mail"

    # Creation du cookie
    create_cookie

    # Creation du token de sécu
    CSRF=$(curl 'https://sharelatex.domain.fr/admin/register' -s --compressed  -H "$cookie"| xmllint --html --xpath 'string(/html/head/meta[@name="ol-csrfToken"]/@content)' - 2>/dev/null)

    # # Creation de l'utilisateur
    result=$(curl "https://sharelatex.domain.fr/admin/register" \
    -H 'Connection: keep-alive' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'DNT: 1' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36' \
    -H 'Content-Type: application/json;charset=UTF-8' \
    -H 'Origin: https://sharelatex.domain.fr' \
    -H 'Referer: https://sharelatex.domain.fr/admin/register' \
    -H 'Accept-Language: fr' \
    --compressed  -s -H "$cookie" --data-binary '{"email":"'$mail'","_csrf":"'$CSRF'"}')

    echo "$date - $type - $mail " >> $logFile

    prefixMail="[ressources][sharelatex-compte] Creation"
    footer="\n\n"
    echo -e "Creation du compte sharelatex $mail ok . \n $result $footer" | mail -s "$prefixMail de $mail" $destMail

elif [ "$type" = "info" ]; then

    scriptuser=/local/sharelatex/scripts/core/js/user_projets_collab.js
    cd /local/sharelatex/compose/ || exit; docker-compose exec -T mongo mongo sharelatex --quiet --eval "var param1='$mail'" $scriptuser

elif [ "$type" = "supprimer" ]; then

    #cd /local/sharelatex-local/Scripts/
    #mongo sharelatex --quiet --eval "var param1='$mail'" core/js/delete_user_and_project.js
    scriptuserdel=/local/sharelatex/scripts/core/js/delete_user_and_project.js
    cd /local/sharelatex/compose/ || exit ; docker-compose exec -T mongo mongo sharelatex --quiet --eval "var param1='$mail'" $scriptuserdel


    echo "$date - $type - $mail " >> $logFile

elif [ "$type" = "replace_owner" ]; then


    scriptprojrep=/local/sharelatex/scripts/core/js/replace_projets_owner.js
    cd /local/sharelatex/compose/ || exit ; docker-compose exec -T mongo mongo sharelatex --quiet --eval "var param1='$idproject';param2='$idnewowner'" $scriptprojrep


    #cd /local/sharelatex-local/Scripts/
    #mongo sharelatex --quiet --eval "var param1='$idproject';param2='$idnewowner'" core/js/replace_projets_owner.js
    echo "$date - $type - projet $idproject to $idnewowner " >> $logFile

elif [ "$type" = "help" ]; then

    display_help;

else
    display_help;
    echo "$date - $type - error " >> $logFile
    exit;

fi

exit;
