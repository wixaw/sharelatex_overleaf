# Sharelatex Custom

## Prérequis 

* docker-compose ( https://docs.docker.com/compose/install/ )
* python3-pip 
* mechanize (pip3 install mechanize)


python2 et pip2 fonctionnent mais il faut changer dans manage_compte.sh

## Init du container et de texlive 

```
cd compose
docker-compose up -d 

## Mise à jour de texlive, attendre 90mn
docker exec sharelatex tlmgr update --self
docker exec sharelatex tlmgr install scheme-full
## l'avantage de l'avoir mis dans un volume local, c'est qu'à chaque mise à jour, on a pas besoin de le retelecharger 


```


## Gestion des comptes


### Creation du compte admin, il ne doit pas deja exister
```
docker-compose exec sharelatex /bin/bash -c "cd /var/www/sharelatex; grunt user:create-admin --email=mail@domain.fr"

## apres changement du mdp, il faut le set dans manage_compte.sh 
```
### Creer un compte: 
```
manage_compte.sh creer mail@domain.fr
```

### Information d'un compte
```
./manage_compte.sh info xxx@domain.fr
Compte sharelatex trouvé : xxx@domain.fr (ObjectId("xxxxx"))
  Projet : xxxxxx (ID : xxxxx)  
  Projet : yyyyyy  (ID : xxxxx)  
    Collab : yoann.pitarch@irit.fr (ID : zzzzz) 
Veuillez utiliser les commandes suivantes : 
./manage_compte.sh replace_owner yyyyyy zzzzz #mail.new@domain.fr
./manage_compte.sh supprimer xxx@domain.fr
```

### Supprimer un compte
```
./manage_compte.sh supprimer ophelie.fraisier@irit.fr
 
Tentative de suppression du compte sharelatex : xxx@domain.fr (ObjectId("xxxxx"))
  Projet : xxxxxx (ID : xxxxx)  
  -> Projet supprimé sur la base de donnees
Ok : Le compte a bien été supprimé
Veuillez utiliser les commandes suivantes pour nettoyer les anciens fichiers:
rm -rf /local/sharelatex/data/user_files/xxxxxx*



## On supprime les anciens fichiers : 
rm -rf /local/sharelatex/data/user_files/xxxxxx*

```

## Cron de maintenance

* Nettoyer les logs
```
cp scripts/clean-logs.sh /etc/cron.monthly/
```
* Nettoyer les anciennes compilations
```
cp scripts/clean-compiles.sh /etc/cron.monthly/
```
* Check et kill des vieux process Xlatex
```
crontab -e << scripts/crontab.cron
```

## Rendre accessible le service
dans un vhost apache 
```
 RewriteEngine On
 RewriteCond %{HTTP:Upgrade} =websocket
 RewriteRule /(.*)           ws://wwwap1.irit.fr:5000/$1 [P,L]
 RewriteCond %{HTTP:Upgrade} !=websocket
 RewriteRule /(.*)           http://wwwap1.irit.fr:5000/$1 [P,L]
 ```

## Mise à jour 

## Par exemple pour la derniere mise à jour 2.7.1 avec mongo 3.6 -> 4.0
```
docker-compose exec mongo mongo
 
> db.adminCommand( { setFeatureCompatibilityVersion: "3.6" } )
{ "ok" : 1 }
> exit
bye
 
 
docker-compose stop mongo
vim docker-compose.yml
set mongo:4.0
set sharelatex:2.7.1
docker-compose up -d
```