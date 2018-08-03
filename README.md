# coldfusion-hydro-raindrop
ColdFusion wrapper for the for the Hydro Raindrop RESTful API
https://www.hydrogenplatform.com/docs/hydro/v1/#Raindrop

## Server-Side Example Code:
* create component
```
try {
	hydro = CreateObject("component", "hydro-raindrop-server").init(username:username, key:key, production:false);
	writeDump(hydro);
}
catch(any excpt) {
	writeDump(excpt);
}
```

* whitelist (may take 30 seconds)
```
try {
	result = hydro.whitelist(address);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}
```	
	
* challenge
```
try {
	result = hydro.challenge(hydroAddressId);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}
```

* authenticate
```
try {
	result = hydro.authenticate(hydroAddressId);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}
```

## Client-Side Example Code:
* create component
```
try {
	hydro = CreateObject("component", "hydro-raindrop-client").init(username:username, key:key, production:false, application_id:applicationId);
	writeDump(hydro);
}
catch(any excpt) {
	writeDump(excpt);
}
```

* register user
```
try {
	result = hydro.registerUser(hydro_id:hydroId);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}
```	
	
* generate random message
```
result = hydro.generateMessage();
writeDump(result);
```

* verify signature
```
try {
	result = hydro.verifySignature(hydro_id:hydroId, message: msg);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}
```

* unregister user
```
try {
	result = hydro.unregisterUser(hydro_id:hydroId);
	writeDump(result);
}
catch(any excpt) {
	writeDump(excpt);
}

* A demo client-side application is available at demo/index.cfm
