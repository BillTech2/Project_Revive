public without sharing class Eins_EinsteinServiceController {


    private final string  apiRoot = 'https://api.einstein.ai/v2/';
    private string apiOauth = apiRoot + 'oauth2/token';
    private string apiGetIntentPrediction = apiRoot + 'language/intent';

    private string accessToken;
    private string authToken;

    @testVisible static List<eins_EinsteinPlatformSetting__mdt> einsSettings {
        get {
            if (einsSettings == null)
            einsSettings =  [select ID, Label, eins_LanguageCodes__c, Email_login__c, PEM_Data__c, ModelId_en__c, ModelId_fr__c, ModelId_dutch__c
                from eins_EinsteinPlatformSetting__mdt where Label = 'Default']; 
            return einsSettings;
        } set; 
    }

    public static Eins_EinsteinSettings getPlatformSettings() {
        Eins_EinsteinSettings result = new Eins_EinsteinSettings();
        for(eins_EinsteinPlatformSetting__mdt item : einsSettings) {
            if (item.Label == 'Default') {
                result.emailLogin = item.Email_login__c;

                result.pemData = item.PEM_Data__c;
                if (string.isNotEmpty(item.eins_LanguageCodes__c)) {
                    List<string> languages = item.eins_LanguageCodes__c.split(';');
                    if (string.isNotEmpty(item.ModelId_en__c) && languages.size()>= 1) {
                        result.models.put( languages[0], item.ModelId_en__c);
                    }
                    if (string.isNotEmpty(item.ModelId_fr__c)  && languages.size()>= 2) {
                        result.models.put(languages[1],  item.ModelId_fr__c);
                    }
                    if (string.isNotEmpty(item.ModelId_dutch__c)  && languages.size()>= 3) {
                        result.models.put(languages[2],  item.ModelId_dutch__c);
                    }                                 
                }

            }
        }
        return result;
    }

    public String getAccessToken() {
        Eins_EinsteinSettings settings =   Eins_EinsteinServiceController.getPlatformSettings();
        
        String loginName =  (settings!= null  &&  string.isNotBlank(settings.emailLogin))? settings.emailLogin
                                : 'alexander.chesnokov@vrpconsulting.com';
        String pem = (settings!= null  &&  string.isNotBlank(settings.pemData))? settings.pemData
        :'-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAh/CVtGenDr16G3y5OBn2I9AstwGSR5JfCftnsXa41W2e5PDW\nrx+6zPX9B9M83/ciS+dOp1vXLACo0OZGxMjVHE3dACZO94CvY9UFuz1aWTEENnjx\n3jjdQk5H2h7lwbfgtgeJP5MCKLZXnyjNzltIkJ0NMGCz6mTwFF1w/hd2D2yWd3TO\nFv5oTIhyqVs6gJx5SvBYcahFe4zhy5/CXTh/Bh8VGtdoBNuU4gOL6jdNOJtqB8DH\nbT9Ahx80dva8PF05bE0xVssrUdMeJYlIZUKI0Yh/p0aMFj6fxbiUwq8xY/N/slMj\nCQbfYtfboeTJGuTOydP7Rv5RmguQHa2WD9RwjQIDAQABAoIBAAK9dbcKM9LXPOPa\n8rzPwSddpdkWfgVVTPcdiyyHkRg0OnSw6hLjl9dTygLjXiHBkH5pLiuvbTnk1YJI\ncfq7dZg5dY/wNb1FacOgYpowlWag103lyDJLgSI6A7bA0q7B7xScOEcAxpVdf4yk\nvOlA68iGceKcwGOkHza533IvtOCAry0EbfNAglXzpSooqwjarVO/T9z2yK92lnc7\nw8QkIc9r+bn126qj4q2BEDf94KrFmyRZOYx2dIrd67FNDmMNaTTMHa28N+nh9YeH\nFo9fbUJlVjK720ReYJ7PKvkouY6v8MLxOM+vaUvj6GPphssZGXYInZSKwjDOlRYw\nXn5TSeECgYEA4LywL2N5dcY7vpYOHY1Gu9mNn3H9GxmhZ5YgbenkS7lsmN+xHgGm\nYQ/U2LXiwyIBJbR/OUFHRj7jaXBbYr2VbQ8ZdjYgVlI+4gPhNdqda+njj9SpHi6+\n7PO64h1vPvvWgxY63GRRePgrQhvXKgrksf6pQnph+S140CdIosUCMdUCgYEAmtmo\nVR8t0hJqVMR1xaSEaKxeV0YVboyx70tZ7ZCcfpPcUNV9LjQhX7yHH4YXj5UYoueh\nTw5RUKa2782uNTwnrO3nFzU6sbVhkz5pdd4sEFe8E6kh+7eB1RXcBSNGAmlfkH8H\ndrjR5CEv78vVrB6OP3TqEenOyIU6mEeBTj1959kCgYARyJygg1yfJzqfEDy5te48\n+zArx9dhh5uwGL8kM3fvThL73eekGjlSQPB03Z++FTjGBQx0OWgsdNmGBHAW1i22\n3ZUEN7BDZGq5c9kka9I9MdriDM/9JXHSSk8liXK+JyuIX//0ZLPVwL2bk5xpJUeH\nlkFKk2ihUSnYPuOOjcxoqQKBgEWKqkZQEkvdaVNYR2vTToOTpWqcVtOm6+IDfQdr\nglx2GuNSfT1avAI6sJQ/rCUXWFEQpSjTzUDjHhTj0fCma0sGLFoH1awpQQDXbpU4\niaFtRVGvC0v4RZ5kisLj7HT4zaoe4kM3DUvee6C9ceAyeL+WyefxkKQM8RuiQTfZ\n9clBAoGBALWfb6YZ8E/lk+dS+1ZOE0TWFONVbNOQXiYuRlFMg9ZBv68W4sXzc9ez\nrpMyQ/adkcsP/qCbz5iMxtZPBofa8t87AJeEXnFBPs0KXUm9t+VmwqeSDsiKG1uC\nOi1YEmo2Gf2OzZG2YyaqRdQWBy46+tqUfzff3wtgWA2wBrgPdyew\n-----END RSA PRIVATE KEY-----\n';
        pem = pem.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        pem = pem.replace('-----END RSA PRIVATE KEY-----', '');
        pem = pem.replace('\n', '');
        // Get a new token
        Eins_JWT jwt = new Eins_JWT(loginName);
      
        jwt.iss = 'developer.force.com';
        jwt.aud =  apiOauth;
        jwt.exp = '3600';
        jwt.pkcs8 = pem; 
        this.accessToken = Eins_JWTBearerProcess.getAccessToken(apiOauth, jwt);
        this.authToken = 'Bearer ' + this.accessToken;
        return accessToken;
    }

    private void setAuthorizationHeader(HttpRequest httpRequest) {
        if (string.isBlank(this.accessToken) && string.isBlank(this.authToken)){
            getAccessToken();
        }
        Map<string, string> headers = new Map<string, string> { 'Authorization' => this.authToken, 'Cache-Control' => 'no-cache'};
        if(headers!=null && headers.size()>0) {
            for(String key :headers.keySet()){
                string val=headers.get(key);
                httpRequest.setHeader(key,val);
            }
        }
    }

    public Eins_IntentModel getIntent(string stringForIntent, string modelId) {
        HttpRequest req = new HttpRequest();
        Eins_EinsteinSettings settings = getPlatformSettings();
        setAuthorizationHeader(req);
        // String modelId = (settings != null && string.isNotBlank(settings.modelIdEn))?  settings.modelIdEn
        // : '5RWM7MBDQIIQOTPVXNFA76T5KU';
        Eins_IntentRequestModel body = new Eins_IntentRequestModel(modelId);
        body.document = stringForIntent;
        
        req.setMethod('POST');
        req.setEndpoint(apiGetIntentPrediction);
        req.setHeader('Content-type', 'application/json');
        req.setBody(JSON.serialize( body));
        Http http = new Http();
        Eins_IntentModel model = new Eins_IntentModel();
        try{
            HTTPResponse res = http.send(req);
            if ( res.getStatusCode() == 200 ) {
                model = (Eins_IntentModel)JSON.deserialize(res.getBody(), Eins_IntentModel.class);

            }else{
                System.debug('Eins_EinsteinServiceController Error Occurred '+res.getBody());
            }
        }catch(Exception ex){
            if(String.valueOf(ex).startsWith('Unauthorized endpoint')){
                System.debug('Eins_EinsteinServiceController Please check Setup->Security->Remote site settings and add '+ apiGetIntentPrediction);
            }else{
                System.debug('Eins_EinsteinServiceController  '+ex.getStackTraceString());
                System.debug('Eins_EinsteinServiceController '+ex);
            }
        }
        return model; 
    }


}