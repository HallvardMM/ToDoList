// Users creates lists, can be admin, 
// shares list with other users and is
// used for the access control

module User

section User-model

entity User{
  name:: String (id,validate(isUniqueUser(this), "User needs name." ), validate(name.length() > 0, "User needs name." ))
  password:: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  email:: Email (not null)
  admin:: Bool
  ownerList <> {PointList} (inverse=PointList.owner)
  writeList -> {PointList} (inverse=PointList.writer)
  readList -> {PointList}  (inverse=PointList.reader)
}

section User-view

page createUser(){
	// Could have added mail to user when create
	// https://webdsl.org/page/Manual#SendEmail
	// Skipped because of time 
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	var newuser := User{}
	var passCheck: Secret
	heading("ToDo List"){
		div[class="startPagePadding"]{
			h3{ "Create user" }
			form{
				div[class="flexColumn"]{
				input("Name", newuser.name)
				input("Email", newuser.email)
				input("Password", newuser.password)
				input("Re-enter password", passCheck)
				//captcha() //Tried to use captcha, but based on talk I skipped it since using GoogleApi was recommended
				validate(newuser.password == passCheck, "The passwords are not the same." )
				submit action{
					if( (select count(*) from User) == 0 ){
					newuser.admin := true;
					}
					newuser.password := newuser.password.digest(); 
					newuser.save();
					// securityContext.principal := newuser; // Logs the user in directly
					return root();}[style:="width:100px"]
				{"Create"}
				}
			}
			submit action{return root();}[style:="width:100px"]{"Return To Home Page"}		
		}
	}
}

page adminPage(){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	headerLoggedIn(){
		grid{
			cell(12){h3{ "Admin Page" }}
			cell(12){submit action{return root();}{"Return To Home Page"}}
			}
		for (u:User order by u.name asc){
			div[class="adminContainer"]{
				form[class="adminContainerForm"]{
					// Use standard elements not mdl because it 
					// created a cleaner list view
					output("Id: "+u.id)
					label("Name: "){input(u.name)[not null]}
					label("Email: "){input(u.email)}
					label("Admin: "){input(u.admin)}
					output("Created: "+u.created)
				    submit action{} { "Save" }
				    }    
				submit action{u.delete();}[class="dangerButton"]{"Delete"}
			}
		}
	}
}


page profilePage(u: User){
	// Could have added mail to user when change
	// https://webdsl.org/page/Manual#SendEmail
	// Skipped because of time 
	var pass:Secret
	var passCheck: Secret
	var oldPassword: Secret
	var mailCheck: Email
	var oldPasswordEmail: Secret
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	headerLoggedIn(){
	h3{ "Profile" }
	submit action{return root();}{"Return To Home Page"}
	h5{"Change mail"}
	form [class="flexColumn"]{
		input("Email", u.email)
		input("Re-enter email", mailCheck)
		validate(u.email == mailCheck, "The mailaddresses are not the same." )
		input("Password", oldPasswordEmail)
		validate(u.password.check(oldPasswordEmail), "Password wrong")
		submit action{}[style:="width:300px"] { "Save" }
		}
	h5{"Change password"}
	form [class="flexColumn"]{
		input("Password",pass) 
		validate(pass.length() >= 10, "Minimum password length is 10." )
		input("Re-enter password", passCheck)
		validate( pass == passCheck, "The passwords are not the same." )
		input("Old Password", oldPassword)
		validate(u.password.check(oldPassword), "Old password wrong")
		submit action{u.password := pass.digest(); u.save();}[style:="width:300px"]{ "Save" }
		}
	}		
}

section User-controller


//Used for the adminPage of the application
service allUsers(){
  var main := JSONObject();
  var a := JSONArray();
  for( u: User order by u.name){
    var o := JSONObject();
    o.put( "id", u.id );
    o.put( "name", u.name );
    o.put( "email", u.email );
    o.put( "admin", u.admin );
    o.put( "created", u.created.toString() );
    a.put( o );
  }
  main.put("users",a);
  return main;
}

service fetchAmountOfLists(asker: User){
	var main := JSONObject();
	var a := JSONArray();
	for( u: User order by u.name){
	    var o := JSONObject();
	    var data := JSONArray();
	    data.put(u.ownerList.length);
	    o.put( "name", u.name );
	    o.put( "data", data );
	    a.put( o );
	  }
	main.put("users",a);
	return main;
}


//Used for the adminPage of the application
service allUsersName(){
  var main := JSONObject();
  main.put("numberOfUsers", select count(*) from User);
  var a := JSONArray();
  for( u: User order by u.name){
    var o := JSONObject();
    o.put( "name", u.name );
    a.put( o );
  }
  main.put("users",a);
  return main;
}

// GET parameters can be provided in the URL with:
// servicename/arg1/arg2 or servicename?param1=arg1&param2=arg2
// test with: curl http://localhost:8080/ToDoList/getUser/[name]
// Have to make sure that the user matches the logged in user

service getUser( user: User ){
  var o := JSONObject();
  var ol := List<String>();
  var wl := List<String>();
  var rl := List<String>();
  o.put( "id", user.id );
  o.put( "name", user.name );
  o.put( "email", user.email );
  o.put("admin",user.admin);
   for (pl:PointList in user.ownerList){
	  	ol.add(pl.id.toString());
	  }
	  
	  for (l:PointList in user.writeList){
	  	wl.add(l.id.toString());
	  }
	
	  for (l:PointList in user.readList){
	  	rl.add(l.id.toString());
	  }
	  o.put("ownerList",JSONArray(ol.toString()));
	  o.put("writeList",JSONArray(wl.toString()));
	  o.put("readList",JSONArray(rl.toString()));
  return o;
}

service getUsersLists( user: User ){
  var o := JSONObject();
  var ol := JSONArray();
  var wl := JSONArray();
  var rl := JSONArray();
   for (l:PointList in user.ownerList order by l.name asc){
   		var tmp := JSONObject();
   		tmp.put("name",l.name);
   		tmp.put("owner",l.owner.name.toString());
   		tmp.put("id",l.id.toString());
	  	ol.put(tmp);
	  }
	  
	  for (l:PointList in user.writeList order by l.name asc){
	  	var tmp := JSONObject();
   		tmp.put("name",l.name);
   		tmp.put("owner",l.owner.name.toString());
   		tmp.put("id",l.id.toString());
	  	wl.put(tmp);
	  }
	
	  for (l:PointList in user.readList order by l.name asc){
	  	var tmp := JSONObject();
   		tmp.put("name",l.name);
   		tmp.put("owner",l.owner.name.toString());
   		tmp.put("id",l.id.toString());
	  	rl.put(tmp);
	  }
	  o.put("ownerList",ol);
	  o.put("writeList",wl);
	  o.put("readList",rl);
  return o;
}

service createUserService(name: String,email: String,password: Secret){
	//email and password length should be validated on client side
	if(!isUniqueUserId(name)){
		var o := JSONObject();
		o.put("error","User exists!");
		return o;
	}else{
	var u := User{};
	u.name := name;
	u.email := email;
	if( (select count(*) from User) == 0 ){
					u.admin := true;
					}
	u.password := password.digest(); 
	u.save();
	var o := JSONObject();
		o.put("success","User created!");
	return o;
	}
}

service changeEmail(name: User,email: Email,password: Secret){
	var o := JSONObject();
	if(authenticate(name.name,password)){
		name.email := email;
		o.put("success","Email changed!");
	}else{
		o.put("error","Wrong password");
	}
	return o;
}

service changePassword(name: User,newPassword: Secret, oldPassword: Secret){
	var o := JSONObject();
	if(authenticate(name.name,oldPassword)){
		name.password := newPassword.digest();
		o.put("success","Password changed!");
	}else{
		o.put("error","Wrong password");
	}
	return o;
}