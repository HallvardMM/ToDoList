// Material Design Lite components http://www.getmdl.io/
// Based on this repo: https://github.com/webdsl/cs4105-demo @Author: dgroenewegen 

module mdl

section application-specific layout

template maingridcard(cardtitle: String){
  
    grid{
      card(cardtitle){
        elements
      }
     }
  
}

template fixedHeader(title: String, user:User, navs: [url: String, linktext: String]){
  var homejs := "document.location.href = '"+navigate(root())+"';"
  var profilejs := "document.location.href = '"+navigate(profilePage(user))+"';"
  <!-- Always shows a header, even in smaller screens. -->
  <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
    <header class="mdl-layout__header">
      <div class="mdl-layout__header-row">
      <!-- User Name -->
	    <span onclick=profilejs>
	      output("Signed in as: "+user.name)
	    </span>
	    <!-- Add spacer -->
        <div class="mdl-layout-spacer"></div>
        <!-- Title -->
        <span class="mdl-layout-title" onclick=homejs>
          output(title)
        </span>
        <!-- Add spacer -->
        <div class="mdl-layout-spacer"></div>
        <!-- Navigation. We hide it in small screens. -->
        <nav class="mdl-navigation mdl-layout--large-screen-only">
          for(n in navs){
            <a class="mdl-navigation__link" href=n.url>output(n.linktext)</a>
          }
        </nav>
      </div>
    </header>
    <div class="mdl-layout__drawer">
      <span class="mdl-layout-title" onclick=homejs>
        output(title)
      </span>
      <span class="mdl-layout-title" style="line-height:30px; font-size:16px" onclick=profilejs>
        output("Signed in as: "+user.name)
      </span>
      <nav class="mdl-navigation">
        for(n in navs){
          <a class="mdl-navigation__link" href=n.url>output(n.linktext)</a>
        }
       	<div class="navButton">
        	logout() 
      	</div>  
      </nav>
    </div>
    <main class="mdl-layout__content">
      <div class="page-content">
        elements
      </div>
    </main>
  </div>
}

template heading(title: String){
  var homejs := "document.location.href = '"+navigate(root())+"';"
  <!-- Always shows a header, even in smaller screens. -->
  <div class="mdl-layout mdl-js-layout mdl-layout--fixed-header">
    <header class="mdl-layout__header">
      <div class="mdl-layout__header-row">
	    <!-- Add spacer -->
        <div class="mdl-layout-spacer"></div>
        <!-- Title -->
        <span class="mdl-layout-title" onclick=homejs>
          output(title)
        </span>
        <!-- Add spacer -->
        <div class="mdl-layout-spacer"></div>
      </div>
    </header>
    <main class="mdl-layout__content">
      <div class="page-content">
        elements
      </div>
    </main>
  </div>
}

template card(title: String){
  <style>
    .mdl-card {
      margin: 10px;
      min-width: 370px;
      min-height: 100px;
      & > .mdl-card__actions {
        display: flex;
        box-sizing: border-box;
        align-items: center;
      }
      & > .mdl-card__title {
        align-items: flex-start;
        & > h4 {
          margin-top: 0;
        }
      }
      & > .mdl-card__title,
      & > .mdl-card__supporting-text,
      & > .mdl-card__actions,
      & > .mdl-card__actions > .mdl-button {
        color: #fff;
      }
    }
  </style>
  <div class="mdl-card mdl-shadow--4dp mdl-cell mdl-cell--12-col" all attributes>
    <div class="mdl-card__title">
      output(title)
    </div>
    <div class="mdl-card__supporting-text">
      elements
    </div>
  </div>
}

template toggleVisibility( startText: String, toggleText: String){
	//template for hidding/showing and chaning text on button
  <script>
  	function toggleText(e, startText, toggleText){
  		if(e[0].innerHTML == startText){
  			$( "#" + e[0].id).text(toggleText)
  		}
  		else{
  			$( "#" + e[0].id).text(startText)
  		}
  	}
  </script>
 <button onclick="$( '#" + id + "' ).toggle(); toggleText($(this), '~startText','~toggleText'); "class="mdl-button mdl-js-button mdl-button--raised mdl-button--accent" id=id+"button">
    output( startText )
  </button>
  <div id=id style="display:none;">
    elements
  </div>
}


section head

template mdlHead( primaryColor: String, accentColor: String ){
  head{
    <meta name = "viewport" content = "width=device-width, initial-scale=1.0">
    <link rel = "stylesheet" href = "https://fonts.googleapis.com/icon?family=Material+Icons">
    <link rel = "stylesheet" href = "https://code.getmdl.io/1.3.0/material." + primaryColor + "-" + accentColor + ".min.css">
    <script src = "https://code.getmdl.io/1.3.0/material.min.js" defer="true"></script> 
    	//just adding defer was not supported but this should lead to defer be true
  }
}


section grid

htmlwrapper{
  grid div[ class = "mdl-grid" ]
}

template cell( i: Int ){
  div[  class = "mdl-cell mdl-cell--"+i+"-col"
      , all attributes ]{
    elements
  }
}


// section tabs
// 
// template tabs( active: String, elems: [header: String, content: TemplateElements] ){
//   <div class = "mdl-tabs mdl-js-tabs">
//     <div class = "mdl-tabs__tab-bar">
//       for( e in elems ){
//         <a href = "#" + e.header + "-panel" class = "mdl-tabs__tab" + (if( e.header == active ) " is-active" else "")> output( e.header ) </a>
//       }
//     </div>
//     for( e in elems ){
//       <div id = e.header + "-panel" class = "mdl-tabs__panel" + (if( e.header == active ) " is-active" else "")>
//         e.content
//       </div>
//     }
//   </div>
// }


section input

expandtemplate labelinput to Type {
  template input( label: String, s: ref Type ){
    <div class="mdl-textfield mdl-js-textfield mdl-textfield--floating-label">
      input( s )[ class="mdl-textfield__input", id=id, all attributes ]
      <label class="mdl-textfield__label" for=id> output( label ) </label>
    </div>
  }
}

expand 
  String
  Email
  Secret
  WikiText
  Text
  Int
  Float
  Long
  Date
  to labelinput
  
template input( label: String, b: ref Bool ){
  <label class = "mdl-checkbox mdl-js-checkbox" for = id>
	input( b )[ id = id, class = "mdl-checkbox__input" ]
	<span class = "mdl-checkbox__label"> output( label ) </span>
  </label>
}

template switch( label: String, b: ref Bool ){
  <label class = "mdl-switch mdl-js-switch" for = id>
    input( b )[ id = id, class = "mdl-switch__input" ]
    <span class = "mdl-switch__label"> output( label ) </span>
  </label>
}

template iconToggle( icon: String, b: ref Bool ){
  <label class = "mdl-icon-toggle mdl-js-icon-toggle" for = id>
    input( b )[ id = id, class = "mdl-icon-toggle__input" ]
    <span class = "mdl-icon-toggle__label material-icons"> output( icon ) </span>
  </label>
}

override attributes radio{
  class = "mdl-radio mdl-js-radio"
}

override template radio( ent: ref Entity ){
  radio( ent, ent.getAllowed() )[ class = "mdl-radio__button", all attributes ]{ elements }
}

override template outputLabel( e: Entity ){
 <span class = "mdl-radio__label">
   output( e.name )
 </span>
}


section buttons

override attributes submit{
  class = "mdl-button mdl-js-button mdl-button--raised mdl-button--accent"
}

attributes floatingActionButtonColored{
  class = "mdl-button mdl-js-button mdl-button--fab mdl-button--colored"
  ignore submit attributes
}

attributes floatingActionButton{
  class = "mdl-button mdl-js-button mdl-button--fab"
  ignore submit attributes
}

attributes floatingActionButtonDisabled{
  class = "mdl-button mdl-js-button mdl-button--fab"
  disabled = ""
  ignore submit attributes
}

attributes raisedButton{
  class = "mdl-button mdl-js-button mdl-button--raised"
  ignore submit attributes
}

attributes raisedButtonDisabled{
  class = "mdl-button mdl-js-button mdl-button--raised"
  disabled = ""
  ignore submit attributes
}


// section icons
// 
// template iconAdd(){
//   <i class = "material-icons"> "add" </i>
// }