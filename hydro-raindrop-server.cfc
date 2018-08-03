/**
 * ColdFusion wrapper for the for the Hydro Server-side Raindrop RESTful API:
 * https://www.hydrogenplatform.com/docs/hydro/v1/#Raindrop
 * 
 * @author Brett Roderick
 * @date 7/1/18
 **/

component output=false extends="hydro-raindrop" hint="Wrapper for the Hydro Server-side Raindrop RESTful API" {

	/**
	* whitelist: function that whitelists an address
	* @returns hydro_address_id in JSON format if successful,
	* @throws an error otherwise
	**/
	public string function whitelist(required string address) {
		var httpService = new http();
		var postdata = {};
		postdata['address'] = arguments.address;
		postdata = serializejson(postdata);

		httpService.setMethod("post");
		httpService.addParam(type="header", name="Content-Type", value="application/json");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.addParam(type="body", value=postdata);
		httpService.setUrl(this.baseUrl & "/whitelist");
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 200) {
			return httpResult.filecontent;
		} else {
			throw (message=httpResult.filecontent);
		}		
	}

	/**
	* challenge: function that requests a challenge string from Hydro
	* @returns amount, challenge, and partner_id in JSON format if successful,
	* @throws an error otherwise
	**/
	public string function challenge(required string hydroAddressId) {
		var httpService = new http();
		var postdata = {};
		postdata['hydro_address_id'] = arguments.hydroAddressId;
		postdata = serializejson(postdata);
		 
		httpService.setMethod("post");
		httpService.addParam(type="header", name="Content-Type", value="application/json");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.addParam(type="body", value=postdata);
		httpService.setUrl(this.baseUrl & "/challenge");
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 200) {
			return httpResult.filecontent;
		} else {
			throw (message=httpResult.filecontent);
		}
	}

	/**
	* authenticate: This function verfies whether or not the hydro_address_id sent has performed a proper raindrop
	* @returns a boolean (in JSON format)
	* @throws an error otherwise
	**/
	public string function authenticate(required string hydroAddressId) {
		var httpService = new http();
		httpService.setMethod("get");
		httpService.addParam(type="header", name="Content-Type", value="application/json");
		httpService.addParam(type="header", name="Authorization", value="Bearer #this.authFields.access_token#");
		httpService.setUrl(this.baseUrl & "/authenticate?hydro_address_id=" & arguments.hydroAddressId);
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 200) {
			return httpResult.filecontent;
		} else {
			throw (message=httpResult.filecontent);
		}		
	}
	
}
