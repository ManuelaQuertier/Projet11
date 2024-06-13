@RestResource(urlMapping= '/Contact/*')
global with sharing class MyRestResource {

    @HttpPost
    global static Id createContact(String firstName, String lastName, String email) {

        List<Contact> checkcontact = [SELECT Id, Email FROM Contact WHERE Email = :email];

        if (checkcontact.size() == 0){

            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email);
            insert newContact;
            return newContact.Id;
        } else {
            return checkcontact[0].Id;
        }
    }

    @HttpPatch
    global static Id updateContactFields() {

        RestRequest request = RestContext.request;
        
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        System.debug('id: '+ contactId);
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Deserialize the JSON string into name-value pairs
      
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
        // Set the field and value on the Case sObject
        thisContact.put(fieldName, params.get(fieldName));
        }
        update thisContact;
        return thisContact.Id;
    }

    @HttpDelete
    global static String deactiveContact() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id, Inactive__c FROM Contact WHERE Id = :contactId];
        thisContact.Inactive__c = true;
        update thisContact;
        return 'Contact is deactivated';
    }
}