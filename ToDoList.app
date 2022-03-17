application ToDoList

imports mdl
imports User
imports Point
imports PointGroup
imports PointList
imports ToDoListTest

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

rule page imagePage(point:Point){
	(securityContext.principal == point.parentGroup.parentList.owner 
	|| securityContext.principal in point.parentGroup.parentList.writer
	|| securityContext.principal in point.parentGroup.parentList.reader)
}

  // use page rules for services
rule page allUsers(){ securityContext.principal.admin }
rule page fetchAmountOfLists(){securityContext.principal.admin}
rule page getUsersLists(){loggedIn()} //securityContext.principal==user check in function
rule page getList( p: PointList  ){ 
	(p.owner==securityContext.principal 
	|| securityContext.principal in p.writer 
	|| securityContext.principal in p.reader) }
rule page loginservice(){!loggedIn()}
rule page logoutservice( ){loggedIn()} // securityContext.principal == user check in function
rule page createUserService(){!loggedIn()}
rule page createList(){loggedIn()} //securityContext.principal == user check in function
rule page deleteList(listId: PointList){listId.owner==securityContext.principal }
rule page allUsersName(){loggedIn()}
rule page shareList( listId: PointList, user:User, write:Bool ){listId.owner == securityContext.principal}
rule page removeAccess( listId: PointList, user:User){listId.owner == securityContext.principal}
rule page createGroup(listId:PointList,groupName: String){
  	securityContext.principal in listId.writer || securityContext.principal == listId.owner
  }
rule page changeEmail(){ loggedIn()} // securityContext.principal==u && u.password.check(password) in function
rule page changePassword(){loggedIn()} //securityContext.principal==u && u.password.check(oldPassword)
rule page fetchGroup(pgId:PointGroup){
	(securityContext.principal == pgId.parentList.owner 
	|| securityContext.principal in pgId.parentList.writer
	|| securityContext.principal in pgId.parentList.reader)}

//rule page *(*) {true} //For development purposes!

section root 

page root(){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	if(loggedIn()){
		startSite(){}	
	}
	else{
		//authentication //default authentication not used
		logintemplate
	}
}

section root-templates

template startSite(){
	// Main template for root when logged in
	var u:=securityContext.principal
	headerLoggedIn(){
		createList(u)
		listContainer("Owner access lists",u.ownerList,u,true,false)
		listContainer("Writer access lists",u.writeList,u,false,true)
		listContainer("Reader access lists",u.readList,u,false,false)
	}
}

template headerLoggedIn(){
	// Tried to refactor with function but
	// but could not return type [url : String, linktext : String]
	// which fixedHeader needs
	var u:= securityContext.principal
	if(u.admin){
		fixedHeader(
	    "ToDo List",u,
	    [
			(navigate(profilePage(u)), "Profile") ,
			(navigate(adminPage()), "Admin")
		 ]
	  )
	  {elements}
	}else{
		fixedHeader(
	    "ToDo List",u,
	    [ (navigate(profilePage(u)), "Profile")]
	  )
	  {elements}	
	}
}

template listContainer(header:String,lists:{PointList},user:User,owner:Bool,writer:Bool){
	//Container for different todo lists
	div[class="startPagePadding flexColumn"]{
		h3{output(header)}
		for(todolist in lists order by todolist.name asc){
			div[class="listContainer"]{
				navigate(pointListPage(todolist))[class="listLink"]{output(todolist.name)} 
				if(owner){
					submit action{
						deleteList(todolist,user);
			   		}[class="dangerButton"]{"Delete List"}
				}
				else{
					submit action{
						leaveList(todolist,user,writer);
			   		}[class="dangerButton"]{"Leave list"}
				}
			}
		}
	}
}

template createList(u:User){
	// Create a list that is added to owner access
	var list := PointList{}
	div[class="startPagePadding"]{
		form{
		input("Create new list", list.name)[not null] 
		for(todolist in u.ownerList){
			validate(todolist.name != list.name, "Already have a list with same name." )
		}
		submit action{
			list.owner := u;
			list.save();
			u.ownerList.add(list);
		}
		{"Create"}
		}
	}
}

section root-controlls

function deleteList(list: PointList, u:User){
	// Delete list if owner access 
	for(w in list.writer){
		w.writeList.remove(list);
		}
	for(r in list.reader){
		r.readList.remove(list);
	}
	u.ownerList.remove(list);
	list.delete(); 
}

function leaveList(list: PointList, u:User, writer:Bool){
	// Leave a list if read/write access
	if(writer){
		list.writer.remove(u);
		u.writeList.remove(list);
	}else{
		list.reader.remove(u);
		u.readList.remove(list);
	}	
}


section accessDeniedpages
// Based on this repo: https://github.com/webdsl/cs4105-demo @Author: dgroenewegen 

override page accessDenied(){
  mdlHead( "deep_orange", "deep_purple" )
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    submit action{return root();}{"Return To Home Page"}
  }
}


section override default authentication styles
// Based on this repo: https://github.com/webdsl/cs4105-demo @Author: dgroenewegen 

override template logout() {
	// Removes standard logged in text
   	form{ submit action{ securityContext.principal := null;
   		return root(); }{ "Logout" } }
 }

template logintemplate() {
  // Where the user can sign Used instaed of authenticate
  var name: String
  var pass: Secret
  heading("ToDo List"){
  	div[class="startPagePadding"]{
  		h3{"Sign in"}
  		form {
  			grid{
  			  cell(12){ input("Name", name)}
		      cell(12){ input("Password", pass)}
		      cell(1){ div{submit signinAction() { "Login" } }}
		      cell(2){ submit action{return createUser();}{"Create user"}}
  			}
	    }
  	}
  }
  
  action signinAction() {
    validate( authenticate(name,pass), "The login credentials are not valid." );
	/* Tryed to implement stay logged in logic, but did not seem to work
	   Cookie was saved regardles: https://github.com/webdsl/qa/blob/master/authentication.app
		getSessionManager().stayLoggedIn;
	*/
    return root();
  }
}

section authentication services

service loginservice(){
	if(getHttpMethod() == "POST") {
		var json := JSONObject(readRequestBody());
        var name := json.getString("name");
		var password: Secret := json.getString("password");
		var main := JSONObject();
		if(authenticate(name,password)){
			var user := getUniqueUser(name);
			main.put("name",user.name);
			main.put("admin",user.admin);
			return main;
		}
		else{
			main.put("error",true);
			return main;
		}
	}
}

service logoutservice(){
	if(getHttpMethod() == "POST") {
	var main := JSONObject();
	var json := JSONObject(readRequestBody());
    var name := json.getString("name");
    var user := getUniqueUser(name);
    if(securityContext.principal == user){
		//Do the check here since I do not want to send info about who
		// is loging out across the web
		securityContext.principal := null;
		main.put("loggedOut",true);	
		return main;
     }
	}
	
}

