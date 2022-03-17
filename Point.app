//A point to refer to a task/work in a todolist
// Owner can delete, write, read
// Writer can write, read
// Reader can read

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
			//Ajax for smoother checking
			input(point.done)[onclick := action{
				point.toggleDone();
				}]}
		} 
		else{div{output( "Done: " + point.done)}}
		div{text("Description: ")output(point.description)}
		div[style:="overflow-wrap:break-word;"]{output( "URL: " + point.url )}
		div{label("Due: "){output(point.dueTime )}} 
		// Hard to do a null check here However it does not make an issue
		if(point.img == null){
			label( "Image: " ){ "No image" } 
		}else{
			label( "Image: " ){ navigate(imagePage(point)){ output(point.img.fileName()) } }
		}
		
	}
}

page imagePage(point:Point){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	headerLoggedIn(){
		div[class="flexColumn"]{
			h3{text("Image for point"+point.name)}
			submit action{return pointListPage(point.parentGroup.parentList);}[style:="width:90px"]{"Back"}
			div[class="imageWrapper"]{
				output(point.img)
			}
		}
	}
}

template inputPoint(point:Point){
	div[class = "flexColumn"]{
			input("Name", point.name)[not null]
			input("Assigned",point.assigned)
			input("Priority",point.priority)
			input("Description",point.description) 
			input("URL",point.url) 
			input("Due", point.dueTime)
			input("Image", point.img)
			elements
	}
}

page addPoint(pg: PointGroup, writeAccess:Bool, owner: Bool){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	var point := Point{}
	headerLoggedIn(){
		h3{"Create point"}
		submit action{return pointListPage(pg.parentList);}{"Back"}
		form {
				inputPoint(point){
				submit action{
					point.parentGroup := pg;
					point.save();
					pg.points.add(point);
					return pointListPage(pg.parentList);
				}[style:="width:300px"] { "Save" }
			}
		}
	}
}

page editPoint(point: Point,writeAccess: Bool, owner: Bool){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	headerLoggedIn(){
		h3{text("Edit point"+point.name)}
		submit action{
			return pointListPage(point.parentGroup.parentList);
			} { "Back"  }
		form {
			inputPoint(point){
				submit action{
					point.save();
					return pointListPage(point.parentGroup.parentList);
				}[style:="width:300px"] { "Save" }
			}
		}
	}
}