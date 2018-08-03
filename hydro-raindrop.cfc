/**
 * ColdFusion wrapper for the for the Hydro Raindrop RESTful API:
 * https://www.hydrogenplatform.com/docs/hydro/v1/#Raindrop
 * 
 * use hydro-raindrop-server.cfc for Server-side Raindrop
 * use hydro-raindrop-client.cfc for Client-side Raindrop
*  * 
 * @author Brett Roderick
 * @date 7/1/18
 **/

component output=false  {

	/**
	* init: function that initializes the component
	* @returns instance of the component
	**/
	public any function init(required string username, required string key, string application_id = "", boolean production = false) {
		var clientCredentials = ToBase64("#arguments.username#:#arguments.key#");
		this.application_id = arguments.application_id;
		
		if (arguments.production) {
			this.baseUrl = "https://api.hydrogenplatform.com/hydro/v1";
			this.authUrl = "https://api.hydrogenplatform.com/authorization/v1/oauth/token?grant_type=client_credentials";
		} else {
			this.baseUrl = "https://sandbox.hydrogenplatform.com/hydro/v1";
			this.authUrl = "https://sandbox.hydrogenplatform.com/authorization/v1/oauth/token?grant_type=client_credentials";
		} 

		var httpService = new http();
		httpService.setMethod("post");
		httpService.addParam(type="header", name="Authorization", value="Basic #clientCredentials#");
		httpService.setUrl(this.authUrl);
		var httpResult = httpService.send().getPrefix();

		if (httpResult.responseHeader.status_code EQ 200) {
			this.authFields = {};
			this.authFields = deserializejson(httpResult.filecontent);
	   	return this;
		} else {
			throw (message=httpResult.filecontent);
		}
   
	}

}
