<html>
<head>
	<title>Client-Side Raindrop Demo Application</title>
</head>
<body align="center">

<h2>Client-Side Raindrop Demo Application</h2>
<hr style="border-top: 2px dashed #cccccc;width: 50%; float: center"/>


<!--- set your Hydro API variables here --->
<cfset VARIABLES.appID = "xxxxxxxxxxxxxxxxxxxx">
<cfset VARIABLES.apiUsername = "xxxxxxxxxxxx">
<cfset VARIABLES.apiKey = "xxxxxxxxxxxx">
<!----------------------------------------->


<!--- default values --->
<cfparam name="SESSION.loggedIn" default="False">
<cfparam name="SESSION.username" default="">
<cfparam name="SESSION.hydroID" default="">
<cfparam name="SESSION.confirmed" default="0">
<cfparam name="SESSION.do2FA" default="false">
<cfparam name="SESSION.message" default="">
<cfparam name="URL.logout" default="0">
<cfparam name="URL.verify" default="0">
<cfparam name="URL.auth" default="0">
<cfparam name="URL.unlink" default="0">
<cfparam name="FORM.action" default="">

<!--- initialize the Hydro raindrop client component --->
<cfset hydro = CreateObject("component", "hydro-raindrop-client").init(	username:VARIABLES.apiUsername,
																								key:VARIABLES.apiKey,
																								production:false,
																								application_id:VARIABLES.appID)>

<!--- handle logout --->
<cfif URL.logout>
	<cfset SESSION.loggedIn = False>
	<cfset SESSION.username = "">
	<cfset SESSION.hydroID = "">
	<cfset SESSION.confirmed = "0">
	<cfset SESSION.do2FA = False>
	<cflocation url="index.cfm" addtoken="False">

<!--- handle initial verification  --->
<cfelseif URL.verify>
	<cftry>
		<cfset hydro.verifySignature(hydro_id:SESSION.hydroID, message: SESSION.message)>
		<cfquery name="setConfirmed" datasource="hydro_demo">
			UPDATE	auth
			SET		confirmed = 1
			WHERE 	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.username#">
		</cfquery>
		<cfset SESSION.confirmed = "1">
		<cfcatch>
			<!--- <cfdump var="#cfcatch#"> --->
			<div style="color:red;padding:10px">Authentification failed</div>
		</cfcatch>
	</cftry>

<!--- handle ongoing verification  --->
<cfelseif URL.auth>
	<cftry>
		<cfset hydro.verifySignature(hydro_id:SESSION.hydroID, message: SESSION.message)>
		<cfset SESSION.do2FA = False>
		<cfset SESSION.loggedIn = True>
		<cfcatch>
			<div style="color:red;padding:10px">Authentification failed</div>
		</cfcatch>
	</cftry>

<!--- handle HydroID unlink from application --->
<cfelseif URL.unlink>
	<cftry>
		<cfset result = hydro.unregisterUser(hydro_id:SESSION.hydroID)>
		<cfif result>
			<cfquery name="unlink" datasource="hydro_demo">
				UPDATE	auth
				SET		hydroID = <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
							confirmed = 0
				WHERE 	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.username#">
			</cfquery>
			<cfset SESSION.hydroID = "">
			<cfset SESSION.confirmed = "0">
		</cfif>
		<cfcatch>
			<cfset err = DeserializeJSON(cfcatch.Message)>
			<div style="color:red;padding:10px">Unlink failed: <cfoutput>#err.message#</cfoutput></div>
		</cfcatch>
	</cftry>
</cfif>


<!--- handle 2fa login --->
<cfif SESSION.do2FA>
	<cfset SESSION.message = hydro.generateMessage()>
	Enter the code below into the Hydro mobile app and the click Authenticate:<br/>
	<h2><cfoutput>#SESSION.message#</cfoutput></h2>
	<a href="index.cfm?auth=1" style="font-weight:bold">Authenticate</a>

	<hr style="border-top: 2px dashed #cccccc;width: 50%; float: center"/>
	
	<a href="index.cfm?logout=1">Log Out</a>
	<cfabort>
</cfif>


<!--- handle standard login --->
<cfif FORM.action EQ "login">
	<cfquery name="checkLogin" datasource="hydro_demo">
		SELECT username, hydroID, confirmed
		FROM	auth
		WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.username#">
				AND password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.password#">
	</cfquery>
	
	<!--- if 2fa is not enabled then skip 2fa login, otherwise go to 2fa login form --->
	<cfif checkLogin.RecordCount>
		<cfset SESSION.username = FORM.username>
		<cfset SESSION.hydroID = checkLogin.hydroID>
		<cfset SESSION.confirmed = checkLogin.confirmed>
		<cfif checkLogin.confirmed>
			<cfset SESSION.do2FA = True>
			<cflocation url="index.cfm" addtoken="False">	
		<cfelse>
			<cfset SESSION.loggedIn = True>
		</cfif>
		
	<!--- failed login --->	
	<cfelse>
		<div style="color:red;padding:10px">Log In Failed!</div>
	</cfif>
	
	
<!--- handle registration --->
<cfelseif FORM.action EQ "register">
	<cfif FORM.password NEQ FORM.password2>
		<div style="color:red;padding:10px">Passwords do not match!</div>
	<cfelse>
		<cfquery name="checkLogin" datasource="hydro_demo">
			SELECT username
			FROM	auth
			WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.username#">
		</cfquery>
		
		<!--- make sure username is not in use --->
		<cfif checkLogin.RecordCount>
			<div style="color:red;padding:10px">Username is already taken!</div>
		<cfelse>
			<cfquery name="register" datasource="hydro_demo">
				INSERT INTO	auth (username, password)
				VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.username#">, <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.password#">)
			</cfquery>
			<cfset SESSION.loggedIn = True>
			<cfset SESSION.username = FORM.username>
		</cfif>
	</cfif>


<!--- handle HydroID link to application --->
<cfelseif FORM.action EQ "link">
	<cftry>
		<cfset result = hydro.registerUser(hydro_id:FORM.hydroID)>
		<cfif result>
			<cfquery name="link" datasource="hydro_demo">
				UPDATE	auth
				SET		hydroID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.hydroID#">
				WHERE 	username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#SESSION.username#">
			</cfquery>
			<cfset SESSION.hydroID = FORM.hydroID>
		</cfif>
		<cfcatch>
			<cfset err = DeserializeJSON(cfcatch.Message)>
			<div style="color:red;padding:10px">Link failed: <cfoutput>#err.message#</cfoutput></div>
		</cfcatch>
	</cftry>
</cfif>


<!--- show login / register page --->
<cfif NOT SESSION.loggedIn>
	<form method="post" name="loginForm">
		<input type="hidden" name="action" value="login">
		<input type="text" name="username" placeholder="Username" required="true" ><br/>
		<input type="password" name="password" placeholder="Password" required="true"><br/>
		<input type="submit" name="login" value="Log In">
	</form>

	<hr style="border-top: 2px dashed #cccccc;width: 50%; float: center"/>
	
	<form method="post" name="registerForm">
		<input type="hidden" name="action" value="register">
		<input type="text" name="username" placeholder="Username" required="true"><br/>
		<input type="password" name="password" placeholder="Password" required="true"><br/>
		<input type="password2" name="password2" placeholder="Repeat Password" required="true"><br/>
		<input type="submit" name="register" value="Register">
	</form>


<!--- pages that require user to be logged in --->
<cfelse>
	<table cellpadding="5" align="center">
		<tr><th>Username</th><th>HydroID</th><th>Confirmed</th></tr>
		<tr><cfoutput><td>#SESSION.username#</td><td>#SESSION.hydroID#</td><td>#SESSION.confirmed#</td></cfoutput></tr>
	</table>
	<hr style="border-top: 2px dashed #cccccc;width: 50%; float: center"/>
	
	
	<!--- form to link HydroID to application --->
	<cfif SESSION.hydroID EQ "">
		To enable Hydro 2FA, enter your HydroID from the app:<br/>
		<form method="post" name="linkForm">
			<input type="hidden" name="action" value="link">
			<input type="text" name="hydroID" placeholder="HydroID" required="true"><br/>
			<input type="submit" name="link" value="Link">
		</form>

	<!--- unlink HydroID from application --->
	<cfelseif SESSION.confirmed>
		<a href="index.cfm?unlink=1">Unlink</a>
		
	<cfelse>
		<cfset SESSION.message = hydro.generateMessage()>
		Enter the code below into the Hydro mobile app and the click Authenticate:<br/>
		<h2><cfoutput>#SESSION.message#</cfoutput></h2>
		<a href="index.cfm?verify=1" style="font-weight:bold">Authenticate</a>
		
	</cfif>

	<hr style="border-top: 2px dashed #cccccc;width: 50%; float: center"/>	
	<a href="index.cfm?logout=1">Log Out</a>
</cfif>

</body>
</html>
