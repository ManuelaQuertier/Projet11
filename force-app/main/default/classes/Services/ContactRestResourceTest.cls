@isTest
private class ContactRestResourceTest {

    @TestSetup
    static void makeData(){
       Contact testContact = new Contact(
       		FirstName = 'TestContact',
       		LastName = 'ContactTest',
			Email = 'thisemail@doesexist.com');
        insert testContact;
    }
    
    @isTest
    static void createContactTest() {

        RestRequest request = new RestRequest();

        request.requestUri = genericURI();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "firstName" : "Second","lastName" : "Try","email" : "thisemail2@doesntexist.com" }');
        
        RestContext.request = request;
       	Id contactId = ContactRestResource.createContact();

        Id newContactid = [SELECT id FROM Contact WHERE Email = 'thisemail2@doesntexist.com' LIMIT 1].Id;
        
        System.AssertEquals(contactId, newContactId, 'Error on Contact insertion');
        }

    @isTest
    static void createExistingContactTest(){
        
        Id myExistingContact = [SELECT Id FROM Contact WHERE Email = 'thisemail@doesexist.com' LIMIT 1].Id;
        
        RestRequest request = new RestRequest();
        request.requestUri = genericURI();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "firstName" : "Exemple","lastName" : "Try","email" : "thisemail@doesexist.com" }');
        
        RestContext.request = request;
       	Id contactId = ContactRestResource.createContact();
        
        System.AssertEquals(contactId, myExistingContact, 'this Contact doesnt exist but insertion fail');
    }
    // Helper methods

    private static String genericURI(){
        String uri = 'https://akkodis6-dev-ed.my.salesforce.com/services/apexrest/Contact/';
        return uri;
    }
}