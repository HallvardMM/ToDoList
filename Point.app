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