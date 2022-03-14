//A group of points could be "sports" 
// and then have sports related todo points in it
// Owner can delete, write, read
// Writer can write, read
// Reader can read

module PointGroup

imports Point

section PointGroup-model

entity PointGroup{
	name:: String (validate(name.length() > 0, "Group needs name"))
	parentList -> PointList
	points <> {Point} (inverse=Point.parentGroup)// <> should cascade delete
}

section PointGroup-view

template PointGroupTemplate(pg: PointGroup, writeAccess: Bool, owner: Bool){
	div[class="groupContainer"]{
		h5{output(pg.name)}
		if(writeAccess){
			submit action{
					return addPoint(pg,writeAccess,owner);
		   		}{ "Add point" }
		}		
		if(owner){
			submit action{
				pg.parentList.pointGroups.remove(pg);
	   			pg.delete();
	   		}[class="dangerButton"]{"Delete group"}
		}
	}
	for(point in pg.points order by point.name asc){
		div[class="pointWithButtons"]{
			showView(point,writeAccess)
			if(writeAccess){
			submit action{
				return editPoint(point,writeAccess,owner);
				}{ "Edit point"  }
			}	
			if(owner){
				submit action{
					pg.points.remove(point);
					point.delete();
				}[class="dangerButton"]{"Delete Point"}
			}
		}	
	}
}


section PointGroup-controller
service createGroup(listId:PointList,groupName: String,sender: User){
	var pg := PointGroup{};
	pg.name :=groupName;
	pg.parentList := listId;
	listId.pointGroups.add(pg);
	pg.save();
	var o := JSONObject();
		o.put("success","Point Group created!");
	return o;
}

