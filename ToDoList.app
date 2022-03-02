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
		submit action{return createUser();}{"Create user"}
	}
}

template mainTemplate(){
	logout()
	if(principal.admin){
		submit action{
			return adminPage();
			}{ "Admin Page"  }
		}
	var list := PointList{}
	form{
		label("Create new list: "){ input(list.name)[not null] }
		for(todolist in securityContext.principal.ownerList){
			validate(todolist.name != list.name, "Already have a list with same name." )
		}
		submit action{
			list.owner := securityContext.principal;
			list.save();
			securityContext.principal.ownerList.add(list);
			securityContext.principal.save();
		}
		{"Create"}
	}	
		h3{"Owner accsess lists"}
		div[style := "display: flex; flex-direction: column;"]{
			for(todolist in securityContext.principal.ownerList){
				div[style := "display: flex; flex-direction: row;"]{ label( todolist.name+": " ){ 
					submit action{return pointListPage(todolist);}{"To list"}
					}
					submit action{
						for(w in todolist.writer){
							w.writeList.remove(todolist);
							}
			   			for(r in todolist.reader){
			   				r.readList.remove(todolist);
			   			}
			   			securityContext.principal.ownerList.remove(todolist);
			   			todolist.delete();
			   		}{"Delete List"}
			   	}
			}
		}
		h3{"Writer accsess lists"}
		div[style := "display: flex; flex-direction: column;"]{
			for(todolist in securityContext.principal.writeList){
				div[style := "display: flex; flex-direction: row;"]{label( todolist.name+": " ){ 
					submit action{return pointListPage(todolist);}{"To list"}  
					}
				submit action{
						todolist.writer.remove(securityContext.principal);
						securityContext.principal.writeList.remove(todolist);
						todolist.save();
						securityContext.principal.save();
			   		}{"Leave list"}
			   	}
			}
		}
		h3{"Reader accsess lists"}
		div[style := "display: flex; flex-direction: column;"]{
			for(todolist in securityContext.principal.readList){
				div[style := "display: flex; flex-direction: row;"]{label( todolist.name+": " ){ 
					submit action{return pointListPage(todolist);}{"To list"}  
					}
				submit action{
						todolist.reader.remove(securityContext.principal);
						securityContext.principal.readList.remove(todolist);
						todolist.save();
						securityContext.principal.save();
			   		}{"Leave list"}
			   	}
			}
		}
}


section pages

page adminPage(){
	h1{"ToDo List"}
	h3{ "Admin" }
	submit action{return root();}{"Return To Home Page"}	
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
	submit action{return root();}{"Return To Home Page"}	
	}	
}

override page accessDenied(){
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    submit action{return root();}{"Return To Home Page"}
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
