#!/bin/bash

# shellcheck disable=SC2162,SC2009,SC2006,SC2164

###############################
# Controle des process parent
###############################

ps -o etimes,pid,ppid,args -C perl | grep latexmk | tr -s " " | while read ligne; do

    echo "--- Process en cours :"
    echo "$ligne"

    ProcessTIME=$(echo "$ligne" | cut -f1 -d" ")
    vPID=$(echo "$ligne" | cut -f2 -d" ")
    vPPID=$(echo "$ligne" | cut -f3 -d" ")

    if [ "$ProcessTIME" -ge 6 ]; then
        echo "------ Proccess de +de 60 s: "

        IDpr=$(echo "$ligne" | awk '{print $9}' | awk -F"=" '{print $2}' | awk -F"/" '{print $7}' | awk -F"-" '{print $1}')

        if [ -z "$IDpr" ]; then
            echo "ID projet non trouvé $vPPID $vPID" | mail -b "sharelatex-admin@domain.fr" -r "no-reply@domain.fr" -s "Probleme parsing project" admin@domain.fr
            exit 1
        else
            echo "ID projet = $IDpr "
	    DetailProject=$(bash /local/sharelatex/scripts/core/get_projet_owner.sh $IDpr)
            PNOM=$(echo "$DetailProject" | grep NomProjet | sed -e "s/NomProjet: //")
            echo "$PNOM"
            MAILADDR=$(echo "$DetailProject" | grep Owner | sed -e "s/Owner: //")
            echo "$MAILADDR"
            MAILSUJET="[SHARELATEX] Erreur du projet $PNOM"
        fi

    fi

    if [ "$ProcessTIME" -ge 240 ]; then
        echo "------ Proccess de +de 240 s: "
        echo " KILL -HUP $vPPID $vPID"
        #kill -HUP "$vPPID" "$vPID"
        kill -9 "$vPID"

        echo "Bonjour,

Votre projet '$PNOM' rencontre actuellement un problème à la compilation.
Ce problème a saturé Sharelatex plusieurs fois et bloqué les autres usagers dans leurs compilations.
Nous avons donc supprimé les process de compilation. Mais il faut que lorsque la compilation ne rend pas la main, comprendre ce qui ce passe en local.

Il faut exporter le projet et le compiler sur votre poste de travail

Vous pouvez également consulter https://fr.overleaf.com/learn/Kb/Debugging_Compilation_timeout_errors

Merci d'avance
Le Service Informatique

_______________________________________________

Ceci est un courrier automatique. Les réponses à ce messages ne sont pas traitées.
Si vous avez besoin d'assistance : https://www.domain.fr/assistance/
" | mail -b "sharelatex-admin@domain.fr" -r "no-reply@domain.fr" -s "$MAILSUJET" "$MAILADDR"

    fi

done

###############################
# Controle des process enfant pouvant rester
###############################

KEEPPROCESS=$(ps auxf | grep -E '(_ lualatex|_ latex|_ pdflatex|_ xelatex)' | sed 1d)

if [ -z "$KEEPPROCESS" ]; then
    echo "ok"
else
    #pgrep -P "$vPID" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process restant apres kill" admin@domain.fr
    #echo "$KEEPPROCESS" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process restant apres kill" admin@domain.fr

    ps -o etimes,pid,ppid,args -C lualatex | grep -v ELAPSED | tr -s " " | while read lignelua; do
        ProcessTIMElua=$(echo "$lignelua" | cut -f1 -d" ")
        vPIDlua=$(echo "$lignelua" | cut -f2 -d" ")

        if [ "$ProcessTIMElua" -ge 300 ]; then
            kill -9 "$vPIDlua"
            echo "kill" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process LUA restant apres kill" admin@domain.fr
        fi
    done

    ps -o etimes,pid,ppid,args -C xelatex | grep -v ELAPSED | tr -s " " | while read lignexe; do
        ProcessTIMExe=$(echo "$lignexe" | cut -f1 -d" ")
        vPIDxe=$(echo "$lignexe" | cut -f2 -d" ")

        if [ "$ProcessTIMExe" -ge 300 ]; then
            kill -9 "$vPIDxe"
            echo "kill" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process XE restant apres kill" admin@domain.fr
        fi
    done

    ps -o etimes,pid,ppid,args -C pdflatex | grep -v ELAPSED | tr -s " " | while read lignepdf; do

        ProcessTIMEpdf=$(echo "$lignepdf" | cut -f1 -d" ")
        vPIDpdf=$(echo "$lignepdf" | cut -f2 -d" ")

        if [ "$ProcessTIMEpdf" -ge 300 ]; then
            kill -9 "$vPIDpdf"
            echo "kill" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process PDF restant apres kill" admin@domain.fr
        fi
    done

    ps -o etimes,pid,ppid,args -C latex | grep -v ELAPSED | tr -s " " | while read lignetex; do

        ProcessTIMEtex=$(echo "$lignetex" | cut -f1 -d" ")
        vPIDtex=$(echo "$lignetex" | cut -f2 -d" ")

        if [ "$ProcessTIMEtex" -ge 300 ]; then
            kill -9 "$vPIDtex"
            echo "kill" | mail -r "no-reply@domain.fr" -s "[SHARELATEX] Process LATEX restant apres kill" admin@domain.fr
        fi
    done

fi

###############################
# Exemple type de process possible :
###############################

# 33       15581  0.0  0.1  41392 11744 ?        S    13:42   0:00  |               |       \_ perl /usr/local/texlive/2020/bin/x86_64-linux/latexmk -cd -f -jobname=output -auxdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -outdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -synctex=1 -interaction=batchmode -lualatex /var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418/manuscritThese.tex
# 33       15585  0.0  0.0   4616   660 ?        S    13:42   0:00  |               |           \_ sh -c lualatex  -synctex=1 -interaction=batchmode -recorder -output-directory="/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418" --jobname="output"  "manuscritThese.tex"
# 33       15586  0.0  0.8 111816 87508 ?        R    13:42   0:00  |               |               \_ lualatex -synctex=1 -interaction=batchmode -recorder -output-directory=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 --jobname=output manuscritThese.tex

# 33       15657  9.0  0.1  41656 12156 ?        S    13:42   0:00  |               |       \_ perl /usr/local/texlive/2020/bin/x86_64-linux/latexmk -cd -f -jobname=output -auxdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -outdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -synctex=1 -interaction=batchmode -pdfdvi /var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418/manuscritThese.tex
# 33       15664  0.0  0.0   4616   664 ?        S    13:42   0:00  |               |           \_ sh -c latex  -synctex=1 -interaction=batchmode -recorder -output-directory="/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418" --jobname="output"  "manuscritThese.tex"
# 33       15665 91.0  0.4 119056 41048 ?        R    13:42   0:00  |               |               \_ latex -synctex=1 -interaction=batchmode -recorder -output-directory=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 --jobname=output manuscritThese.tex

# 33       15782  5.0  0.1  41392 11744 ?        S    13:42   0:00  |               |       \_ perl /usr/local/texlive/2020/bin/x86_64-linux/latexmk -cd -f -jobname=output -auxdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -outdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -synctex=1 -interaction=batchmode -pdf /var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418/manuscritThese.tex
# 33       15786  0.0  0.0   4616   664 ?        S    13:42   0:00  |               |           \_ sh -c pdflatex  -synctex=1 -interaction=batchmode -recorder -output-directory="/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418" --jobname="output"  "manuscritThese.tex"
# 33       15787  127  0.5 134032 53464 ?        R    13:42   0:01  |               |               \_ pdflatex -synctex=1 -interaction=batchmode -recorder -output-directory=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 --jobname=output manuscritThese.tex

# 33       15301  5.0  0.1  40984 11460 ?        S    13:41   0:00  |               |       \_ perl /usr/local/texlive/2020/bin/x86_64-linux/latexmk -cd -f -jobname=output -auxdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -outdir=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 -synctex=1 -interaction=batchmode -xelatex /var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418/manuscritThese.tex
# 33       15305  0.0  0.0   4616   660 ?        S    13:41   0:00  |               |           \_ sh -c xelatex -no-pdf -synctex=1 -interaction=batchmode -recorder -output-directory="/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418" --jobname="output"  "manuscritThese.tex"
# 33       15306 19.0  1.7 349144 173920 ?       R    13:41   0:00  |               |               \_ xelatex -no-pdf -synctex=1 -interaction=batchmode -recorder -output-directory=/var/lib/sharelatex/data/compiles/5f4f640c24a8a9007c479bfc-5656e16f58eae9867ae74418 --jobname=output manuscritThese.tex
