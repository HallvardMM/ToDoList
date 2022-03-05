application ToDoList

imports mdl
imports User
imports Point
imports PointGroup
imports PointList


section access control

principal is User with credentials name, password

access control rules

rule page root(){ true }
rule page createUser(){ !loggedIn() }
rule page profilePage(u:User){u == securityContext.principal}
rule page adminPage(){securityContext.principal.admin}
rule page pointListPage(p:PointList){
	(p.owner==securityContext.principal 
	|| securityContext.principal in p.writer 
	|| securityContext.principal in p.reader)
}
rule page addPoint(pg: PointGroup, writeAccess: Bool, owner: Bool){
	(securityContext.principal == pg.parentList.owner 
	|| securityContext.principal in pg.parentList.writer) 
	&& writeAccess==true //writeAccess==true might be superfluous
}
rule page editPoint(point: Point,writeAccess: Bool,owner:Bool){
	(securityContext.principal == point.parentGroup.parentList.owner 
	|| securityContext.principal in point.parentGroup.parentList.writer)
	 && writeAccess==true //writeAccess==true might be superfluous
}
rule page accessListPage(p: PointList, owner: User){
	owner == securityContext.principal
}

//rule page *(*) {true} //For development purposes!

section root 

page root(){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	if(loggedIn()){
		mainTemplate(){}	
	}
	else{
		//authentication //default authentication not used
		logintemplate
	}
}


template mainLoggedIn(){
	if(securityContext.principal.admin){
		 fixedHeader(
		    "ToDo List",
		    securityContext.principal,
		    [
		      ( navigate(profilePage(securityContext.principal)), "Profile" ),
		      ( navigate(adminPage()), "Admin" )
		      
		    ]
		  ){
		    elements
		  }
	}else{
		fixedHeader(
		    "ToDo List",
		    securityContext.principal,
		    [ 
		      ( navigate(profilePage(securityContext.principal)), "Profile" )
		    ]
		  ){
		    elements
		  }
	}
 
}

template mainTemplate(){
	var list := PointList{}
	mainLoggedIn(){
	form{
		input("Create new list", list.name)[not null] 
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
			for(todolist in securityContext.principal.ownerList order by todolist.name asc){
				div[class="listContainer"]{
					navigate(pointListPage(todolist))[class="listLink"]{output(todolist.name)} 
					submit action{
						for(w in todolist.writer){
							w.writeList.remove(todolist);
							}
			   			for(r in todolist.reader){
			   				r.readList.remove(todolist);
			   			}
			   			securityContext.principal.ownerList.remove(todolist);
			   			todolist.delete();
			   		}[class="dangerButton"]{"Delete List"}
			   	}
			}
		}
		h3{"Writer accsess lists"}
		div[style := "display: flex; flex-direction: column;"]{
			for(todolist in securityContext.principal.writeList order by todolist.name asc){
				div[class="listContainer"]{
					navigate(pointListPage(todolist))[class="listLink"]{output(todolist.name)} 
					submit action{
						todolist.writer.remove(securityContext.principal);
						securityContext.principal.writeList.remove(todolist);
						todolist.save();
						securityContext.principal.save();
			   		}[class="dangerButton"]{"Leave list"}
			   	}
			}
		}
		h3{"Reader accsess lists"}
		div[style := "display: flex; flex-direction: column;"]{
			for(todolist in securityContext.principal.readList order by todolist.name asc){
				div[class="listContainer"]{
					navigate(pointListPage(todolist))[class="listLink"]{output(todolist.name)}  
					submit action{
						todolist.reader.remove(securityContext.principal);
						securityContext.principal.readList.remove(todolist);
						todolist.save();
						securityContext.principal.save();
			   		}[class="dangerButton"]{"Leave list"}
			   	}
			}
		}
	}
}


section pages

override page accessDenied(){
  mdlHead( "deep_orange", "deep_purple" )
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    submit action{return root();}{"Return To Home Page"}
  }
}


section override default authentication styles

override template logout() {
   	form{ submit action{ securityContext.principal := null;
   		return root(); }{ "Logout" } }
   	
 }

template logintemplate() {
  var name: String
  var pass: Secret
  var stayLoggedIn := false
  heading("ToDo List"){
  	grid{
  		cell(12){h3{"Sign in"}}
  		form {
	      cell(12){ input("Name", name)}
	      cell(12){ input("Password", pass)}
	      cell(12){ switch("Stay logged in", stayLoggedIn)}
	      cell(12){ div{submit signinAction() { "Login" } }}
	      cell(12){ submit action{return createUser();}{"Create user"}}
	    }
  	}
  }
  
  action signinAction() {
    validate( authenticate(name,pass), "The login credentials are not valid." );
    getSessionManager().stayLoggedIn := stayLoggedIn;
    return root();
  }
}
