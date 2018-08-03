/**
 * ColdFusion wrapper for the for the Hydro Client-side Raindrop RESTful API:
 * https://www.hydrogenplatform.com/docs/hydro/v1/#Raindrop
 * 
 * @author Brett Roderick
 * @date 8/3/18
 **/

component output=false extends="hydro-raindrop" hint="Wrapper for the Hydro Client-side Raindrop RESTful API" {
	this.messageLength = 6;

	/**
	* registerUser: function that registers a user with their hydro_id
	* @returns true if successful,
	* @throws an error otherwise
	**/
	public string function registerUser(required string hydro_id) {
		var httpService = new http();
		var postdata = {};
		postdata['hydro_id'] = arguments.hydro_id;
		postdata['application_id'] = this.application_id;
		postdata = serializejson(postdata);

		httpService.setMethod("post");
		httpService.addParam(type="header", name="Content-Type", value="application/json");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.addParam(type="body", value=postdata);
		httpService.setUrl(this.baseUrl & "/application/client");
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 201) {
			return true;
		} else {
			throw (message=httpResult.filecontent);
		}		
	}


	/**
	* generateMessage: function that generates a random message for the user to type in
	* @returns a string (of random digits)
	**/
	public string function generateMessage() {
		var msg = "";
		var i = 0;

		for (i=1; i<=this.messageLength; i++) {
			msg = msg & RandRange(0,9,"SHA1PRNG");
		}

		return msg;	
	}


	/**
	* verifySignature: function that verifies the message entered by the user matches the generated message
	* @returns verification_id, and timestamp in JSON format if successful,
	* @throws an error otherwise
	**/
	public string function verifySignature(required string hydro_id, required string message) {
		var httpService = new http();

		httpService.setMethod("get");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.setUrl(this.baseUrl & "/verify_signature?message=#arguments.message#&hydro_id=#arguments.hydro_id#&application_id=#this.application_id#");
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 200) {
			return httpResult.filecontent;
		} else {
			throw (message=httpResult.filecontent);
		}
	}


	/**
	* unregisterUser: function that unregisters a user which unlinks their hydro_id
	* @returns true if successful,
	* @throws an error otherwise
	**/
	public string function unregisterUser(required string hydro_id) {
		var httpService = new http();

		httpService.setMethod("delete");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.setUrl(this.baseUrl & "/application/client?hydro_id=#arguments.hydro_id#&application_id=#this.application_id#");
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 204) {
			return true;
		} else {
			throw (message=httpResult.filecontent);
		}		
	}
	
}
