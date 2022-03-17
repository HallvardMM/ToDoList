// List of groups and points
// Can be shared with users
// Owner can delete, write, read
// Writer can write, read
// Reader can read

module PointList

section PointList-model

entity PointList{
	name:: String (validate(name.length() > 0, "List needs name"))
	owner -> User
	writer -> {User}
	reader -> {User}
	pointGroups <> {PointGroup} (inverse=PointGroup.parentList)
}

entity ShareAccess{
	name: String
}

init {
	ShareAccess{name:="Write"}.save();
	ShareAccess{name:="Read"}.save();
}

section PointList-view

template AddGroup(p: PointList){
	var pointGroup := PointGroup{}
	div[style := "display: flex;"]{
	form {
			input( "New Group",pointGroup.name )[not null] 
			for(group in p.pointGroups order by group.name asc){
			validate(group.name != pointGroup.name, "Already have a group with same name!" )
			}
			submit action{
				pointGroup.parentList := p;
				pointGroup.save();
				p.pointGroups.add(pointGroup);
			} { "Save" }
		}
	}
}

page pointListPage(p:PointList){
	// Page for a specific list
	// Share, add or delete
	var owner := (securityContext.principal == p.owner)
	var writer := (securityContext.principal in p.writer)
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	headerLoggedIn(){
	   	h3{output(p.name)}
	   	submit action{return root();}{"Back"}
	   	if(owner){
			submit action{
				return accessListPage(p, p.owner);
	   		}{ "Change access" }
		}
		if(owner){
			ajaxShare(p)
		}
	   	if(owner || writer){
	   		AddGroup(p)
	   	}
		for(group in p.pointGroups order by group.name asc){
			PointGroupTemplate(group, (owner || writer), owner)
		}
	}
} 


template ajaxShare(p:PointList){
	// Sharing access uses access to make it easier for
	// the user to share a list with read/write access
	// User can choose whom to share with by selecting
	// from all users. Could have added "friends" functionality
	// to only be able to chose from friends
	// Was not able to style ajaxinout like mdl
	var user : User
	var share : ShareAccess
	toggleVisibility("Share access","Hide share"){
		// Toggle showing using Ajax
		form{
			div[class="shareAccesConatainer flexColumn"]{
				label("User: "){ inputajax(user)[not null]
				// Should remove the option to choose oneself, but
				// this gives a reason to do ajax validation :)
				{ validate(user!=securityContext.principal,"Cannot share with yourself!")}}
				label("Rights: "){ inputajax(share)[not null]
				{ validate(share.name.length()>0,"Choose access!")}}
				submit action{
					if(share.name == "Write"){
						if(user in p.reader){
							user.readList.remove(p);
							p.reader.remove(user);
						}
						p.writer.add(user);
						user.writeList.add(p);
					}
					else{
						if(user in p.writer){
							user.writeList.remove(p);
							p.writer.remove(user);
						}
						p.reader.add(user);
						user.readList.add(p);
					}
				}{"Give access"}
			}
		} 
	}
}

page accessListPage(p: PointList, owner: User){
	// Page to change access rights or remove them
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
		headerLoggedIn(){
		h3{ output("Access to: "+p.name)}
		submit action{return pointListPage(p);}{"Back"}
		h5{ "Write access"}	
		for (u in p.writer order by u.name asc){
			div[class="userListContainer"]{
				div[class="userListName"]{output( u.name )}
			    submit action{
			    	p.writer.remove(u);
			    	p.reader.add(u);
			    	u.writeList.remove(p);
					u.readList.add(p);
			    } { "Read access" }
			    submit action{
			    	p.writer.remove(u);
			    	u.writeList.remove(p);
			    }[class="dangerButton"]{"Remove access"}
			}
		}
		h5{ "Read access"}	
		for (u in p.reader order by u.name asc){
			div[class="userListContainer"]{
				div[class="userListName"]{output( u.name )}
			    submit action{
			    	p.reader.remove(u);
			    	p.writer.add(u);
			    	u.readList.remove(p);
					u.writeList.add(p);} { "Write access" }
			    submit action{
			    	p.reader.remove(u);
			    	u.readList.remove(p);
			    }[class="dangerButton"]{"Remove access"}
			}
		}
	}
}


section PointList-controller

//http://localhost:8080/ToDoList/getList/[listId]

service getList( listId: PointList ){
	if(listId!=null){
		var o := JSONObject();
		  var writerList := List<String>();
		  var readerList := List<String>();
		  var pointList := List<String>();
		  o.put( "id", listId.id );
		  o.put( "name", listId.name);
		  for (l in listId.writer){
		  	writerList.add(l.name);
		  }
		  for (l in listId.reader){
		  	readerList.add(l.name);
		  }
		  for (p in listId.pointGroups){
		  	pointList.add(p.id.toString());
		  }
		  o.put( "owner", listId.owner.name );
		  o.put( "writer",  JSONArray(writerList.toString()));
		  o.put( "reader",  JSONArray(readerList.toString()));
		  o.put("pointGroups", JSONArray(pointList.toString()));
		  return o;	
	}
}

service createList(){
	if(getHttpMethod() == "POST") {
	var json := JSONObject(readRequestBody());
    var name := json.getString("name");
    var listName := json.getString("listName");
    var u := getUniqueUser(name);
    var o := JSONObject();
    if(securityContext.principal == u){
    	var p := PointList{};
		p.name := listName;
		p.owner := u;
		p.save();
		
		o.put("success","List created!");
		return o;
		}
	else{
    	o.put("error","Cannot create list for others!");
		return o;
    }
    }
}

service deleteList(listId: PointList){
	var o := JSONObject();
	deleteList(listId, securityContext.principal);
	o.put("success","List deleted!");
	return o;

}

service shareList( listId: PointList, user:User, write:Bool ){
	var o := JSONObject();
	if(write){
		if(user in listId.reader){
			user.readList.remove(listId);
			listId.reader.remove(user);
		}
		if(!(user in listId.writer)){
			listId.writer.add(user);
			user.writeList.add(listId);
		}
		o.put("success","Added to write list!");
	}
	else{
		if(user in listId.writer){
			user.writeList.remove(listId);
			listId.writer.remove(user);
		}
		if(!(user in listId.reader)){
		listId.reader.add(user);
		user.readList.add(listId);
		}
		o.put("success","Added to read list!");
	}	
	return o;
}

service removeAccess( listId: PointList, user:User){
	var o := JSONObject();
	if(user in listId.reader){
			user.readList.remove(listId);
			listId.reader.remove(user);
		}
	if(user in listId.writer){
			user.writeList.remove(listId);
			listId.writer.remove(user);
		}
	o.put("success","Removed from list!");
	return o;
}
