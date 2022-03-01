module PointList

section PointList-model

entity PointList{
	name:: String (validate(name.length() > 0, "List needs name"))
	owner -> User
	writer -> {User}
	reader -> {User}
	pointGroups <> {PointGroup} (inverse=PointGroup.parentList)
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

template PointListTemplate(p: PointList){
	var owner := (securityContext.principal == p.owner)
	var writer := (securityContext.principal in p.writer)
	var reader := (securityContext.principal in p.reader)
	if(owner || writer || reader){
	   	h2{output(p.name)}
	   	if(owner){
	   		submit action{
	   			p.owner.ownerList.remove(p);
	   			p.delete();
	   		}{"Delete List"}
	   	}
	   	if(owner){
	   		submit action{
	   			
	   		}{"Share list"}
	   	}
	   	if(owner || reader){
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