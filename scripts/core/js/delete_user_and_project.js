var listFileRM = []

// On cherche l'utilisateur
var users = db.users.find({
  email: param1
})
if (users.hasNext()) {
  while (users.hasNext()) {
    var userDetail = users.next();
    print("Tentative de suppression du compte sharelatex : " + userDetail.email + " (ID : " + "ObjectId(\"" + userDetail._id + "\"))");
    // On cherche ses projets
    var projectsList = db.projects.find({
      "owner_ref": userDetail._id
    });
    while (projectsList.hasNext()) {
      projet = projectsList.next();
      if (projet.archived == true) {
        var archived = "--> Archivé";
      } else {
        var archived = "";
      }
      print("  Projet : " + projet.name + " (ID : " + projet._id + ") ", archived);
      for (var collab in projet.collaberator_refs) {
        var emailcollab = db.users.find({
          "_id": projet.collaberator_refs[collab]
        });
        // On vérifie qu'il n'y a pas de projet avec des collabs, auquel cas on stop
        while (emailcollab.hasNext()) {
          unemail = emailcollab.next();
          print("    Collab : " + unemail.email + " (ID : " + unemail._id + ")");
          throw new Error("Impossible de supprimer le compte, il a encore des projets partagés");
        }

      }
      listFileRM.push("rm -rf /local/sharelatex/data/user_files/" + projet._id + "*");
      // On supprime le projet
      db.projects.deleteOne({ _id: projet._id });
      print("  -> Projet supprimé sur la base de donnees")
    }
    // On supprime le compte
    db.users.deleteOne({ _id: userDetail._id });
    print("Ok : Le compte a bien été supprimé");
    if (listFileRM) {
    print("Veuillez utiliser les commandes suivantes pour nettoyer les anciens fichiers: ");
    }
    for (val of listFileRM) {
      print(val);
    }
  }
}else{
  print("Erreur: Le compte n'existe pas");
}  