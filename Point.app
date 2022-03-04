//A point to refer to a task/work in a todolist

module Point

section Point-model

//Arrange the priority of points
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
	div[class="pointContainer"]{
		div{label("Name: "){output(point.name)}}
		div{text("Assigned: ")output(point.assigned.name)}
		div{text("Priority: ")output( point.priority.name)}	
		if(writeAccess){
			div{output("Done: ")
			input(point.done)[onclick := action{
				point.toggleDone();
				}]}
		} 
		else{div{output( "Done: " + point.done)}}
		div{text("Description: ")output(point.description)}
		div[style:="overflow-wrap:break-word;"]{output( "URL: " + point.url )}
		div{label("Due: "){output(point.dueTime )}} 
		div[class="imageContainer"]{label( "Image: " ){ output(point.img)}
		}
	}
}

page addPoint(pg: PointGroup, writeAccess:Bool, owner: Bool){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	var point := Point{}
	mainLoggedIn(){
		h3{"Create point"}
		submit action{return pointListPage(pg.parentList);}{"Back"}
		form {
			div[style := "display: flex; flex-direction: column;"]{
			input("Name", point.name)[not null]
			input("Assigned",point.assigned)
			input("Priority",point.priority)
			input("Description",point.description) 
			input("URL",point.url) 
			input("Due", point.dueTime)
			div[style:="width:80px"]{
					input("Image",point.img )
			submit action{
				point.parentGroup := pg;
				point.save();
				pg.points.add(point);
				return pointListPage(pg.parentList);
			} { "Save" }}
			}
		}
	}
}

page editPoint(point: Point,writeAccess: Bool, owner: Bool){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	mainLoggedIn(){
		h3{text("Edit point"+point.name)}
		submit action{
					return pointListPage(point.parentGroup.parentList);
				} { "Back"  }
		form {
			div[style := "display: flex; flex-direction: column;"]{
				input("Name", point.name)[not null]
				input("Assigned",point.assigned)
				input("Priority",point.priority)
				input("Done", point.done)
				input("Description",point.description) 
				input("URL",point.url) 
				input("Due", point.dueTime)
				div[style:="width:80px"]{
					input("Image",point.img )
				submit action{
					point.save();
					return pointListPage(point.parentGroup.parentList);
				} { "Save" }
				}
			}
		}
	}
}