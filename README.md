# coldfusion-hydro-raindrop
ColdFusion wrapper for the for the Hydro Raindrop RESTful API
https://www.hydrogenplatform.com/docs/hydro/v1/#Raindrop

## Example code:
* create component
```
try {
	hydro = CreateObject("component", "hydro-raindrop").init(username:username, key:key, production:false);
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
