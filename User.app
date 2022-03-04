module User

section User-model

entity User{
  name:: String (id, searchable, validate(name.length() > 0, "User needs name." ))
  password:: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  email:: Email
  admin:: Bool
  ownerList <> {PointList} (inverse=PointList.owner)
  writeList -> {PointList} (inverse=PointList.writer)
  readList -> {PointList}  (inverse=PointList.reader)
}

section User-view

page createUser(){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	var newuser := User{}
	var passCheck: Secret
	heading("ToDo List"){
		grid{
			cell(12){h3{ "Create user" }}
			form{
				cell(12){input("Name", newuser.name)}
				cell(12){input("Email", newuser.email)}
				cell(12){input("Password", newuser.password)}
				cell(12){input("Re-enter password", passCheck)}
				//captcha() //Tried to use captcha, but based on talk I skipped it since using GoogleApi was recommended
				validate(newuser.password == passCheck, "The passwords are not the same." )
				cell(12){submit action{
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
			cell(12){submit action{return root();}{"Return To Home Page"}}	
		}	
	}
}

page adminPage(){
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	mainLoggedIn(){
		grid{
			cell(12){h3{ "Admin Page" }}
			cell(12){submit action{return root();}{"Return To Home Page"}}
			}
		
		for (u:User){
			div[class="adminContainer"]{
				form[class="adminContainerForm"]{
					output("Id: "+u.id)
					label("Name: "){input( u.name)}
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
	var pass:Secret
	var passCheck: Secret
	var oldPassword: Secret
	var mailCheck: Email
	var oldPasswordEmail: Secret
	mdlHead( "deep_orange", "deep_purple" )
	includeCSS("ToDoList.css")
	mainLoggedIn(){
		grid{
			cell(12){h3{ "Profile" }}
			cell(12){submit action{return root();}{"Return To Home Page"}}
			cell(12){h5{"Mail change"}}
			form {
				cell(12){input("Email", u.email)}
				cell(12){input("Re-enter email", mailCheck)}
				validate(u.email == mailCheck, "The mailaddresses are not the same." )
				cell(12){input("Old Password", oldPasswordEmail)}
				validate(u.password.check(oldPasswordEmail), "Old password wrong")
				cell(12){submit action{} { "Save" }}
				}
			cell(12){h5{"Password change"}}
			form {
				cell(12){input("Password",pass) }
				validate(pass.length() >= 10, "Minimum password length is 10." )
				cell(12){input("Re-enter password", passCheck)}
				validate( pass == passCheck, "The passwords are not the same." )
				cell(12){input("Old Password", oldPassword)}
				validate(u.password.check(oldPassword), "Old password wrong")
				cell(12){submit action{u.password := pass.digest(); u.save();} { "Save" }}
				}
		}
	}		
}

section User-controller
