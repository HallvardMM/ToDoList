application ToDoList

imports mdl

section access control

principal is User with credentials username, password

access control rules

rule page root(){ true }
rule page createUser(){ true }
//rule page mainPage(){true }
rule page adminPage(){principal.admin}

//rule page *(*) {true} //For development purposes!

section root 

page root(){
	
	if(loggedIn()){
		mainTemplate(){}
		if(principal.admin){
			navigate(adminPage()) { "Admin Page" } 
		}
		logout()
	}
	else{
		loginOrCreate
	}
}

template loginOrCreate(){
	authentication //default authentication
	navigate(createUser()) { "Create user" } 
}

template mainTemplate(){
	text("HelloWorld")
}

entity Item {
  text : WikiText
}


page adminPage(){
	h1{"ToDoList"}
	h3{ "Admin" }
	
	for (u:User){
		div[style := "display: flex;"]{
			form {
			output("Id: "+u.id)
			label( "Name" ){ input( u.username ) }
		    label( "Email" ){ input( u.email ) }
		    label( "Admin" ){ input( u.admin ) }
		    output("Created: "+u.created)
		    submit action{} { "Save" }
		}
		submit action{u.delete();}{"Delete"}
		}
		
		
	}
	navigate(root) { "Main page" } 
}


page createUser(){
	h1{ "ToDoList" }
	h3{ "Create user" }
	var newuser := User{}
	var passCheck: Secret
	form{
		label("Name"){ input(newuser.username) }
		label("Email"){ input(newuser.email) }
		label("Password"){ input(newuser.password) }
		label("Re-enter password"){ input(passCheck) }
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
	}	
}



override page accessDenied(){
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    navigate root() { "Return To Home Page" }
  }
}


section data model

entity User{
  username: String (id)
  password: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  email: Email
  admin: Bool
}


section override default authentication styles

override template logout() {
  "Logged in as: " output( securityContext.principal.username )
  form{
    submit action{ securityContext.principal := null; }{ "Logout" }
  }
}