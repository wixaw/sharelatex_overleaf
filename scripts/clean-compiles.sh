#!/bin/bash

# Ce script nettoie tous les fichiers compiler qui ont plus d'un mois

find /usr/local/data-sharelatex/data-prod/data/compiles/ -maxdepth 1 -name "*" -type d -mtime +30 -exec rm -rf {} \;



