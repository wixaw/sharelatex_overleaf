// print("##########################################################################");
// print("use : sh user_projets_collab.sh MailOwner");
// print("##########################################################################");

// On cherche l'utilisateur
var users = db.users.find({
  email: param1
})

var listCollab = []

while (users.hasNext()) {
  var userDetail = users.next();
  print("Compte sharelatex trouvé : " + userDetail.email + " (" + "ObjectId(\"" + userDetail._id + "\"))");
  // On cherche ses projets
  var projectsList = db.projects.find({
    "owner_ref": userDetail._id
  });
  var listCmd = [];
  while (projectsList.hasNext()) {
    projet = projectsList.next();
    if (projet.archived == true) {
      var archived = "--> Archivé";
    } else {
      var archived = "";
    }
    print("  Projet : " + projet.name.slice(0, 50) + " (ID : " + projet._id + ") ", archived);
    for (var collab in projet.collaberator_refs) {
      var emailcollab = db.users.find({
        "_id": projet.collaberator_refs[collab]
      });
      while (emailcollab.hasNext()) {
        unemail = emailcollab.next();
        print("    Collab : " + unemail.email + " (ID : " + unemail._id + ") ");
        listCollab.push("./manage_compte.sh replace_owner " + projet._id + " " + unemail._id + " #" + unemail.email );
      }
    }
     
  }
  print("Veuillez utiliser les commandes suivantes : ");
  for (val of listCollab) {
    print(val);
  }

  print("./manage_compte.sh supprimer "+userDetail.email)
}


