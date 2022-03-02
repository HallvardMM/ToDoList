module PointList

section PointList-model

entity PointList{
	name:: String (validate(name.length() > 0, "List needs name"))
	owner -> User
	writer -> {User}
	reader -> {User}
	pointGroups <> {PointGroup} (inverse=PointGroup.parentList)
}

entity ShareAccess {
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
			label( "New Group: " ){ input( pointGroup.name )[not null] }
			for(group in p.pointGroups){
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
	var reader := (securityContext.principal in p.reader)
	var user : User
	var share : ShareAccess
	
	if(owner || writer || reader){
	   	h2{output(p.name)}
	   	if(owner){
	   		submit action{
	   			for(w in p.writer){
	   				w.writeList.remove(p);
	   			}
	   			for(r in p.reader){
	   				r.readList.remove(p);
	   			}
	   			p.owner.ownerList.remove(p);
	   			p.delete();
	   		}{"Delete List"}
   			submit action{
				return accessListPage(p, p.owner);
	   		}{ "Change access" }
	   		toggleVisibility("Share list"){
				form{
					// TODO: User should not see themselves
					div[style := "display: flex;"]{
						label("User: "){ inputajax(user){ validate(user!=securityContext.principal,"Cannot share with yourself!")}}
						label("Rights: "){ inputajax(share){ validate(share.name.length()>0,"Choose access!")}}
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
		for(group in p.pointGroups){
			PointGroupTemplate(group, (owner || writer), owner)
		}
	}
	else{
		h2{"Access Denied"}
	}
}

// template PointListTemplate(p: PointList){
// 	var owner := (securityContext.principal == p.owner)
// 	var writer := (securityContext.principal in p.writer)
// 	var reader := (securityContext.principal in p.reader)
// 	var user : User
// 	var share : ShareAccess
// 	
// 	if(owner || writer || reader){
// 	   	h2{output(p.name)}
// 	   	if(owner){
// 	   		submit action{
// 	   			for(w in p.writer){
// 	   				w.writeList.remove(p);
// 	   			}
// 	   			for(r in p.reader){
// 	   				r.readList.remove(p);
// 	   			}
// 	   			p.owner.ownerList.remove(p);
// 	   			p.delete();
// 	   		}{"Delete List"}
//    			submit action{
// 				return accessListPage(p, p.owner);
// 	   		}{ "Change access" }
// 	   		toggleVisibility("Share list"){
// 				form{
// 					// TODO: User should not see themselves
// 					div[style := "display: flex;"]{
// 						label("User: "){ inputajax(user){ validate(user!=securityContext.principal,"Cannot share with yourself!")}}
// 						label("Rights: "){ inputajax(share){ validate(share.name.length()>0,"Choose access!")}}
// 						submit action{
// 							if(share.name == "Write"){
// 								if(user in p.reader){
// 									user.readList.remove(p);
// 									p.reader.remove(user);
// 								}
// 								p.writer.add(user);
// 								user.writeList.add(p);
// 							}
// 							else{
// 								if(user in p.writer){
// 									user.writeList.remove(p);
// 									p.writer.remove(user);
// 								}
// 								p.reader.add(user);
// 								user.readList.add(p);
// 							}
// 						}{"Give access"}
// 					}
// 				}
// 			}	 
// 		}
// 	   	if(owner || writer){
// 	   		AddGroup(p)
// 	   	}
// 		for(group in p.pointGroups){
// 			PointGroupTemplate(group, (owner || writer), owner)
// 		}
// 	}
// 	else{
// 		h2{"Access Denied"}
// 	}
// } 

page accessListPage(p: PointList, owner: User){
	h1{"ToDo List"}
	h3{ output("Access: "+p.name)}
	navigate ownerAccessLists(owner) { "Go back" }
	h5{ "Write access"}	
	for (u in p.writer){
		div[style := "display: flex;"]{
			output( u.name )
		    submit action{
		    	p.writer.remove(u);
		    	p.reader.add(u);
		    	u.writeList.remove(p);
				u.readList.add(p);
		    } { "Read access" }
		    submit action{
		    	p.writer.remove(u);
		    	u.writeList.remove(p);
		    }{"Remove access"}
		}
	}
	h5{ "Read access"}	
	for (u in p.reader){
		div[style := "display: flex;"]{
			output( u.name )
		    submit action{
		    	p.reader.remove(u);
		    	p.writer.add(u);
		    	u.readList.remove(p);
				u.writeList.add(p);} { "Write access" }
		    submit action{
		    	p.reader.remove(u);
		    	u.readList.remove(p);
		    }{"Remove access"}
		}
	}
}