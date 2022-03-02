application ToDoList

imports mdl
imports Point
imports PointGroup
imports PointList

section access control

principal is User with credentials name, password

access control rules

rule page root(){ true }
rule page createUser(){ true }
rule page adminPage(){principal.admin}
rule page pointListPage(p:PointList){
	(p.owner==securityContext.principal || securityContext.principal in p.writer || securityContext.principal in p.reader)
}

rule page ownerAccessLists(u:User){
	u==principal
}
rule page writerAccessLists(u:User){
	u==principal
}
rule page readerAccessLists(u:User){
	u==principal
}
rule page addPoint(pg: PointGroup, writeAccess: Bool, owner: Bool){
	(principal == pg.parentList.owner || principal in pg.parentList.writer) && writeAccess==true
}
rule page editPoint(point: Point,writeAccess: Bool,owner:Bool){
	(principal == point.parentGroup.parentList.owner || principal in point.parentGroup.parentList.writer) && writeAccess==true
}
rule page accessListPage(p: PointList, owner: User){
	owner == principal
}

//rule page *(*) {true} //For development purposes!

section ToDoList-model

entity User{
  name:: String (id, searchable)
  password:: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  email:: Email
  admin:: Bool
  ownerList <> {PointList} (inverse=PointList.owner)
  writeList -> {PointList} (inverse=PointList.writer)
  readList -> {PointList}  (inverse=PointList.reader)
}

section ToDoList-view

section ToDoList-controller

section root 

page root(){
	h1{"ToDo List"}
	if(loggedIn()){
		mainTemplate(){}
	}
	else{
		//authentication //default authentication not used
		logintemplate
		navigate(createUser()) { "Create user" } 
	}
}

template mainTemplate(){
	logout()
	if(principal.admin){
		submit action{
			return adminPage();
			}{ "Admin Page"  }
		}
	div[style := "display: flex; flex-direction: column;"]{
		navigate(ownerAccessLists(securityContext.principal)){"Owner accsess lists"}
		navigate(writerAccessLists(securityContext.principal)){"Writer accsess lists"}
		navigate(readerAccessLists(securityContext.principal)){"Reader accsess lists"}
	}
}


section pages

page adminPage(){
	h1{"ToDo List"}
	h3{ "Admin" }
	navigate root() { "Return To Home Page" }	
	for (u:User){
		div[style := "display: flex;"]{
			form {
			output("Id: "+u.id)
			label( "Name: " ){ input( u.name ) }
		    label( "Email: " ){ input( u.email ) }
		    label( "Admin: " ){ input( u.admin ) }
		    output("Created: "+u.created)
		    submit action{} { "Save" }
		}
		submit action{u.delete();}{"Delete"}
		}
	}
}


page createUser(){
	h1{ "ToDoList" }
	h3{ "Create user" }
	var newuser := User{}
	var passCheck: Secret
	form{
		label("Name"){ input(newuser.name) }
		label("Email"){ input(newuser.email) }
		label("Password"){ input(newuser.password) }
		label("Re-enter password"){ input(passCheck)}
		//captcha() //why does this not work?
		validate(newuser.password == passCheck, "The passwords are not the same." )
		submit action{
			if( (select count(*) from User) == 0 ){
			newuser.admin := true;
			}
			newuser.password := newuser.password.digest(); 
			newuser.save();
			// securityContext.principal := newuser; // Logs the user in directly
			return root();}
		{"Create"}
	navigate root() { "Return To Home Page" }	
	}	
}

page ownerAccessLists(user: User){
	h1{"ToDo List"}
	h3{"Owner access lists"}
	var list := PointList{}
	form{
		label("Create new list: "){ input(list.name)[not null] }
		for(todolist in securityContext.principal.ownerList){
			validate(todolist.name != list.name, "Already have a list with same name." )
		}
		submit action{
			//Seems to work
			list.owner := securityContext.principal;
			list.save();
			securityContext.principal.ownerList.add(list);
			securityContext.principal.save();
		}
		{"Create"}
	}	
	for(todolist in user.ownerList){
		PointListTemplate(todolist)
	}
	navigate root() { "Return To Home Page" }
}


page writerAccessLists(user: User){
	h1{"ToDo List"}
	h3{"Writer access lists"}
	
	for(todolist in user.writeList){
		PointListTemplate(todolist)
		submit action{
				todolist.writer.remove(user);
				securityContext.principal.writeList.remove(todolist);
				todolist.save();
				securityContext.principal.save();
	   		}{"Leave list"}
	}
	navigate root() { "Return To Home Page" }	
}

page readerAccessLists(user: User){
	h1{"ToDo List"}
	h3{"Read accsess lists"}
	for(todolist in securityContext.principal.readList){
		PointListTemplate(todolist)
		submit action{
				todolist.reader.remove(user);
				securityContext.principal.readList.remove(todolist);
				todolist.save();
				securityContext.principal.save();
	   		}{"Leave list"}
	}
	navigate root() { "Return To Home Page" }	
}

override page accessDenied(){
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    navigate root() { "Return To Home Page" }
  }
}


page addPoint(pg: PointGroup, writeAccess:Bool, owner: Bool){
	h1{"ToDoList"}
	h3{"Create point"}
	var point := Point{}
	if(owner){
		navigate(ownerAccessLists(securityContext.principal)) { "Back" } 
	}
	else{
		navigate(writerAccessLists(securityContext.principal)) { "Back" } 
	}
	
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
			if(owner){
			return ownerAccessLists(securityContext.principal);
			}
			else{
				return writerAccessLists(securityContext.principal);
			}
		} { "Save" }}
	}
}

page editPoint(point: Point,writeAccess: Bool, owner: Bool){
	h1{"ToDoList"}
	h3{text("Edit point"+point.name)}
	if(owner){
		navigate(ownerAccessLists(securityContext.principal)) { "Back" } 
	}
	else{
		navigate(writerAccessLists(securityContext.principal)) { "Back" } 
	}
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
					if(owner){
						return ownerAccessLists(securityContext.principal);
						}
						else{
							return writerAccessLists(securityContext.principal);
						}
				} { "Save" }
			}
		}
	}
}

section override default authentication styles

override template logout() {
  div[style := "display: flex; flex-direction: column;"]{
   	"Logged in as: " output( securityContext.principal.name ) 
   	form{ submit action{ securityContext.principal := null; }{ "Logout" } }
   	}
 }

template logintemplate() {
  var name: String
  var pass: Secret
  var stayLoggedIn := false
  form {
    grid{
      cell(12){ label( "Name: " ){ input(name)}}
      cell(12){ label( "Password: " ){ input(pass)}}
      cell(12){ label( "Stay logged in: " ){input(stayLoggedIn)}}
      cell(12){ submit signinAction() { "Login" }}
    }
  }
  action signinAction() {
    validate( authenticate(name,pass), "The login credentials are not valid." );
    getSessionManager().stayLoggedIn := stayLoggedIn;
    return root();
  }
}
