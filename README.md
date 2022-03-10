# ToDo-List 
For course CS4275 Web Programming Languages at TU Delft

## Author
Hallvard Molin Morstøl

## Info
Need to setup mysql database:
- Database name: **todolistdb**
- Can be changed in application.ini-file

This repo contains a webdsl site for creating "To Do"-list. 
Lists have three access modes:
 - Owner
	- Can share, delete, edit and read
 - Writer
	- Can edit and read
 - Reader
	- Can just read

There is also an admin access that can change name, mail address and admin-rights for users.

## Commands to run:

To run: `webdsl run`

If on windows need to run between runs: `taskkill /f /im java.exe`

To clean auto created files: `webdsl clean`

## Changes from the proposal:

- Did not implement i18n:
	- Could have been solved by creating function like l(key, language) and stored the values in the database.
	- Seemed like a lot of work after talking with professor.
- Did not implement email logic:
	- Did not do it because of time issues
	- Was not a main part of application
	- However it seemed relatively okay on the site: [Send mail](https://webdsl.org/page/Manual#SendEmail)
- More complex sorting:
	- Everything is sorted based on name ascending.
- Used [MATERIAL DESIGN LITE](https://getmdl.io/) instead of Bootstrap since it was partly implemented in [CS4105-demo-repo](https://github.com/webdsl/cs4105-demo)
- Added Ajax logic:
	- Added Ajax-validation
	- Added Ajax-input (Was nice to checkoff lists)
- Change color theme:
	- Took to much time just to style
	- Did not find a good way to do this
	perhaps a template would have worked like
	template colorTemplate(color){
		div[style:="color:~color;"]
		elements
	}
- Did a more thorough access control then planned since Webdsl had good support.
- Added tests which is good code practice:
	- Did it mostly to test out webdsl's test solution
	- Added some test to check the functions

## The project
An brief explenation of the most relevant files for the project

.
??? README.md 			// This file containing info about the project
??? Point.app			// An entity for a single point in a list to represent a task/work
??? PointGroup.app		// An entity for collecting points
??? PointList.app		// An entity for a ToDo list
??? ToDoList.app		// The main file containt the main page and root
??? ToDoListTest.app	// A file containing the test for the application
??? User.app			// A file for the user entity and logic
??? application.ini		// File for configuring the project 
??? stylesheets			
    ??? ToDoList.css	// The css added for this project
    ??? common_.css		// The default css for every webdsl project


