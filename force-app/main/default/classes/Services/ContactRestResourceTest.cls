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

        //Create the HTTP request
        RestRequest request = new RestRequest();

        request.requestUri = genericURI();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "firstName" : "Second","lastName" : "Try","email" : "thisemail2@doesntexist.com" }');
        
        RestContext.request = request;

        //call the method to test
        Test.startTest();
       	Id contactId = ContactRestResource.createContact();
        Test.stopTest();
        //Verify that the Id exist
        System.Assert(contactId != null);

        //Verify that the new record is created
        Contact newContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        System.Assert(newContact != null , 'Contact not created');
        }

    @isTest
    static void createExistingContactTest(){
        
        //Select the existing Contact id 
        Id myExistingContact = [SELECT Id FROM Contact WHERE Email = 'thisemail@doesexist.com' LIMIT 1].Id;
        
        //Create HTTP method
        RestRequest request = new RestRequest();
        request.requestUri = genericURI();
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{ "firstName" : "Exemple","lastName" : "Try","email" : "thisemail@doesexist.com" }');
        
        RestContext.request = request;

        //try to insert a Contact with an existing Email
        Test.startTest();
       	Id contactId = ContactRestResource.createContact();
        Test.stopTest();
        
        //Verify that the Id returned is the Id corresponding to the Contact with the existing Email
        System.AssertEquals(contactId, myExistingContact, 'this Contact yet exist');
    }

    @isTest
    static void updateContactTest(){
         
        //Select the existing Contact
        Contact myExistingContact = [SELECT Id, FirstName FROM Contact LIMIT 1];

        //Create HTTP method
        RestRequest request = new RestRequest();
        //Add the Id of the Contact to update
        request.requestUri = genericURI() + myExistingContact.Id;
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf('{ "FirstName" : "Update"}');
        
        RestContext.request = request;

        //call the method to test
        Test.startTest();
       	Id contactUpdatedId = ContactRestResource.updateContactFields();
        Test.stopTest();

        //Select the Contact updated
        Contact contactUpdated = [SELECT Id, FirstName FROM Contact WHERE Id = :contactUpdatedId];

        //Verify that the good Contact is updated with the correct info
        System.AssertEquals(myExistingContact.Id, contactUpdatedId, 'Wrong record on update');
        System.AssertEquals('Update', contactUpdated.FirstName);
    }

    @isTest
    static void deleteContactTest(){

        //Select the existing Contact
        Contact myExistingContact = [SELECT Id, Inactive__c FROM Contact LIMIT 1];
        Id myExistingContactId = myExistingContact.Id;
        //Verify that this Contact is Active
        System.Assert(myExistingContact.Inactive__c == false, 'this Contact should be active');

        Test.startTest();
        //Create HTTP method
        RestRequest request = new RestRequest();
        //Add the Id of the Contact to deactivate
        request.requestUri = genericURI() + myExistingContactId;
        request.httpMethod = 'DELETE';
        RestContext.request = request;
        //Call the method to test
       	String confirmationMessage = ContactRestResource.deactiveContact();
        Test.stopTest();

        //Select the Contact desactivated
        Contact contactDeactivated = [SELECT Id, Inactive__c FROM Contact WHERE Id = :myExistingContactId];
        //Verufy that the method return a message
        System.Assert(confirmationMessage != null);
        //Verify that the Contact has been deactivated
        System.Assert(contactDeactivated.Inactive__c == true, 'This Contact should be deactivated');
    }

    // Helper methods

    private static String genericURI(){
        String uri = 'https://akkodis6-dev-ed.my.salesforce.com/services/apexrest/Contact/';
        return uri;
    }
}