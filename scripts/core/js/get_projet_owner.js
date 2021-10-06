print("##########################################################################");
print("use : sh get_projets_owner.sh IDProject ");
print("##########################################################################");


print("Search ID " + param1);

// On cherche le projet
var selectProject = db.projects.find({
  _id: ObjectId(param1)
});

// On le traite 
while (selectProject.hasNext()) {
  var projet = selectProject.next();
  print();
  print("*******************************************");
  print("NomProjet: " + projet.name  );
  print("(IDproject: " + "ObjectId(\"" + projet._id + "\"))");

  var oldOwner = db.users.find({ _id: projet.owner_ref });
  while (oldOwner.hasNext()) {
    var user = oldOwner.next();
    print("Owner: " + user.email );
    print("IDowner : " + "ObjectId(\"" + user._id + "\"))");
  }

  //print("collab: " + projet.collaberator_refs + " ");

  
  //projet.collaberator_refs.foreach(print( "user: " + element ); });
  //var collab = db.users.find({ _id: projet.collaberator_refs });
  //while (collab.hasNext()) {
  //  var usercollab = collab.ext();
  //  print("collab: " + usercollab.email + " ");
  //}


  print("*******************************************");
  print()
}
