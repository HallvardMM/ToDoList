module User

section User-model

entity User{
  name:: String (id, searchable)
  password:: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  email:: Email
  admin:: Bool
  ownerList <> {PointList} (inverse=PointList.owner)
  writeList -> {PointList} (inverse=PointList.writer)
  readList -> {PointList}  (inverse=PointList.reader)
}

section User-view

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
		//captcha() //Tried to use captcha, but based on talk I skipped it since using GoogleApi was recommended
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
	submit action{return root();}{"Return To Home Page"}
}

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


page profilePage(u: User){
	var pass:Secret
	var passCheck: Secret
	var oldPassword: Secret
	var mailCheck: Email
	var oldPasswordEmail: Secret
	h1{"ToDo List"}
	h3{ "Profile" }
	submit action{return root();}{"Return To Home Page"}	
	div[style := "display: flex;"]{
		h5{"Mail change"}
		break
		form {
	    label( "Email: " ){ input( u.email ) }
		label("Re-enter email: "){ input(mailCheck)}
		label("Old Password: "){ input(oldPasswordEmail)}
		validate(u.email == mailCheck, "The mailaddresses are not the same." )
		validate(u.password.check(oldPasswordEmail), "Old password wrong")
	    submit action{} { "Save" }
		}
	}
	div[style := "display: flex;"]{
		h5{"Password change"}
		break
		form {
	    label("Password: "){ input(pass) }
		label("Re-enter password: "){ input(passCheck)}
		label("Old Password: "){ input(oldPassword)}
		validate( pass == passCheck, "The passwords are not the same." )
		validate(u.password.check(oldPassword), "Old password wrong")
	    submit action{
	    	u.password := pass.digest();
	    	u.save();
	    } { "Save" }
		}
	}	
}

section User-controller
