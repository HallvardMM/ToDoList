module PointGroup

imports Point

section PointGroup-model

entity PointGroup{
	name:: String (validate(name.length() > 0, "Group needs name"))
	parentList -> PointList
	points <> {Point} (inverse=Point.parentGroup)// <> should cascade delete
}

section PointGroup-view

section PointGroup-controller

template PointGroupTemplate(pg: PointGroup, writeAccess: Bool, owner: Bool){
	div[style := "display: flex;"]{
		h3{output(pg.name)}
		if(writeAccess){
			submit action{
					return addPoint(pg,writeAccess,owner);
		   		}{ "Add point" }
		}		
		if(owner){
			submit action{
				pg.parentList.pointGroups.remove(pg);
	   			pg.delete();
	   		}{"Delete group"}
		}
	}
	for(point in pg.points){
		div[style := "display: flex;"]{
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
				}{"Delete Point"}
			}
		}	
	}
}


