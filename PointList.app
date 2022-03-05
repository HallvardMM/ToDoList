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

section PointList-controller

page pointListPage(p:PointList){
	var owner := (securityContext.principal == p.owner)
	var writer := (securityContext.principal in p.writer)
	var user : User
	var share : ShareAccess
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	mainLoggedIn(){
	   	h3{output(p.name)}
	   	submit action{return root();}{"Back"}
	   	if(owner){
			submit action{
				return accessListPage(p, p.owner);
	   		}{ "Change access" }
	   		toggleVisibility("Share access","Hide share"){
				form{
					// TODO: User should not see themselves
					div[class="shareAccesConatainer"]{
						label("User: "){ inputajax(user)[not null]{ validate(user!=securityContext.principal,"Cannot share with yourself!")}}
						label("Rights: "){ inputajax(share)[not null]{ validate(share.name.length()>0,"Choose access!")}}
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
	   	if(owner || writer){
	   		AddGroup(p)
	   	}
		for(group in p.pointGroups order by group.name asc){
			PointGroupTemplate(group, (owner || writer), owner)
		}
	}
} 

page accessListPage(p: PointList, owner: User){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
		mainLoggedIn(){
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