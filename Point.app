module Point


section Point-model

entity Priority {
	name: String
}

init {
	Priority{name:="High"}.save();
	Priority{name:="Medium"}.save();
	Priority{name:="Low"}.save();
}

entity Point{
	name:: String (validate(name.length() > 0, "Point needs name"))
	parentGroup -> PointGroup
	description:: Text
	done:: Bool
	url:: URL
	dueTime:: DateTime
	assigned -> User // -> should just delete link
	img:: Image
	priority -> Priority
	function toggleDone(){ 
    	done := !done;
    	save();
  	}
}

section Point-view

template showView(point: Point,writeAccess: Bool){
	// Template for viewing a point
	div[style := "display: flex;"]{
		output( "Name: " + point.name )
		output( "Assigned: " + point.assigned.name )
		output( "Priority: " + point.priority.name)
		output( "Description: " + point.description ) 
		output( "URL: " + point.url ) 
		output( "Due: " + point.dueTime ) 
		label( "Image: " ){ output(point.img)}
		if(writeAccess){
			output("Done: ")
			input(point.done)[onclick := action{
				point.toggleDone();
				}]
		} 
		else{
			output( "Done: " + point.done)
		}
	}
}

page addPoint(pg: PointGroup, writeAccess:Bool, owner: Bool){
	h1{"ToDoList"}
	h3{"Create point"}
	var point := Point{}
	submit action{return root();}{"Back"}
	form {
		div[style := "display: flex; flex-direction: column;"]{
		label( "Name: " ){ input( point.name )}
		label( "Assigned: " ){ input( point.assigned ) }
		label( "Priority: "){ input(point.priority) }
		label( "Description: " ){ input( point.description ) }
		label( "URL: " ){ input( point.url ) }
		label( "Due: " ){ input( point.dueTime ) }
		label( "Image: "){ input(point.img) }
		submit action{
			point.parentGroup := pg;
			point.save();
			pg.points.add(point);
			return pointListPage(pg.parentList);
		} { "Save" }}
	}
}

page editPoint(point: Point,writeAccess: Bool, owner: Bool){
	h1{"ToDoList"}
	h3{text("Edit point"+point.name)}
	navigate(pointListPage(point.parentGroup.parentList)) { "Back" } 
	form {
		div[style := "display: flex; flex-direction: column;"]{	
				label( "Name: " ){ input( point.name )[not null] }
				label( "Assigned: " ){ input( point.assigned ) }
				label( "Priority: "){ input(point.priority) }
				label( "Done: "){ input(point.done) 
				label( "Description: " ){ input( point.description ) }
				label( "URL: " ){ input( point.url ) }
				label( "Due: " ){ input( point.dueTime ) }
				label( "Image: "){ input(point.img) }
				submit action{
					point.save();
					return pointListPage(point.parentGroup.parentList);
				} { "Save" }
			}
		}
	}
}