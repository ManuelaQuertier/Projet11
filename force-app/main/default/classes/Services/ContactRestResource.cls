@RestResource(urlMapping= '/Contact/*')
global with sharing class ContactRestResource {

    /**
     * @Description This method run with HTTP Post callout and insert new Contact in salesforce, it verify that the contact to insert is not yet in salesforce
     */
    @HttpPost
    global static Id createContact() {

        RestRequest request = RestContext.request;
        //New Contact initialization
        Contact newContact = new Contact();

        //Create a Map to deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());

        // Iterate through each parameter field and value to set the field and value on the Contact sObject
        for(String fieldName : params.keySet()) {
            newContact.put(fieldName, params.get(fieldName));
        }
        //Verify if the a contact with this email is yet in Salesforce
        String email = newContact.Email;
        List<Contact> checkcontact = [SELECT Id, Email FROM Contact WHERE Email = :email WITH USER_MODE]  ;
  
        //return the value of the new Contact or of the existing Contact 
        if (checkcontact.size() == 0){
            insert newContact;
            return newContact.Id;
        } else {
            return checkcontact[0].Id;
        }
    }

    /**
     * @Description this method run with HTTP PATCH callout, it update the field of an existing Contact based on the Id
     */
    @HttpPatch
    global static Id updateContactFields() {

        RestRequest request = RestContext.request;
        
        //Get the Contact Id to update in the URL
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        //Get the Contact to update
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        
        //Create a Map to deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        
        // Iterate through each parameter field and value to set the field and value on the Contact sObject
        for(String fieldName : params.keySet()) {
            thisContact.put(fieldName, params.get(fieldName));
        }
        // update the Contact and return the Id
        update thisContact;
        return thisContact.Id;
    }

    @HttpDelete
    global static String deactiveContact() {

        RestRequest request = RestContext.request;

        //Get the Contact Id to deactivate in the URL
        String contactId = request.requestURI.substring( request.requestURI.lastIndexOf('/')+1);

        //Get the Contact to deactivate and set the fied Inactive__c to "true"
        Contact thisContact = [SELECT Id, Inactive__c FROM Contact WHERE Id = :contactId];
        thisContact.Inactive__c = true;

        //Update the Contact and return a message to confirm the deactivation
        update thisContact;
        return 'Contact is deactivated';
    }
}