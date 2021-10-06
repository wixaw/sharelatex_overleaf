if (!param2) {
  throw new Error("Erreur: pas d'user defini");
}

// print("Search ID " + param1);
// print("New Owner ID " + param2);

// On cherche le projet
var selectProject = db.projects.find({
  _id: ObjectId(param1)
});

// On le traite 
while (selectProject.hasNext()) {
  var projet = selectProject.next();

  //print("Nom du projet : " + projet.name + " (IDproject : " + "ObjectId(\"" + projet._id + "\"))");

  var oldOwner = db.users.find({
    _id: projet.owner_ref
  })
  while (oldOwner.hasNext()) {
    var user = oldOwner.next();
    //print("Old Owner : " + user.email + " (IDowner : " + "ObjectId(\"" + user._id + "\"))");
  }
  var valid = false;
  var newOwner = db.users.find({
    _id: ObjectId(param2)
  })
  while (newOwner.hasNext()) {
    var user = newOwner.next();
    //print("New Owner : " + user.email + " (IDowner : " + "ObjectId(\"" + user._id + "\"))");
    valid = true;
  }

  if (valid == false) {
    throw new Error("Erreur: Probleme avec le nouvel owner");
  }

  // On execute la modification en BD
  db.projects.updateOne({
    _id: ObjectId(param1)
  }, {
    $set: {
      owner_ref: ObjectId(param2)
    }
  });

  print("Ok: remplacement effectué avec succes");

}