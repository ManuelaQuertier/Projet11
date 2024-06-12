@RestResource(urlMapping= '/Contact/*')
global with sharing class MyRestResource {

    @HttpPost
    global static Id createContact(String firstName, String lastName, String email) {

        Contact checkcontact = [SELECT Id, Email FROM Contact WHERE Email = :email];

        if (checkcontact == null){

            Contact newContact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Email = email);
            insert newContact;
            return null;
        } else {
            return checkcontact.Id;
        }
    }
}