@isTest
private class ContractRestResourceTest {

    @TestSetup
    static void makeData(){

        Id accountId = TestDataFactory.createAccount();
        Id contractId = TestDataFactory.createContract(accountId);
    }
    
    @isTest
    static void createContractTest() {

        Account account = [SELECT Id, Name FROM Account LIMIT 1];

        Test.startTest();
       	    Id contractId = ContractRestResource.createContract(account.Name, '6' , '14/07/2024');
        Test.stopTest();
        //Verify the Contract Creation 
        System.Assert(contractId != null);

        //Select the new Contract with fields
        Contract newContract = [SELECT Id, AccountId, Status, ContractTerm, StartDate FROM Contract WHERE Id = :contractId];
        //Verify the account linked and fields 
        System.AssertEquals(account.Id, newContract.AccountId, 'this contract is not link to the right Account');
        System.Assert(newContract.Status == 'Draft');
        System.AssertEquals(integer.valueOf(6), newContract.ContractTerm, 'The Contract duration is not as expected');
        System.AssertEquals(date.parse('14/07/2024'), newContract.StartDate, 'The StartDate is not as expected');
    }
    
    @isTest
    static void updateContractTest(){
         
        Contract myExistingContract = [SELECT Id, Status FROM Contract LIMIT 1];

        //Create the HTTP request
        RestRequest request = new RestRequest();
        request.requestUri = genericURI() + myExistingContract.Id;
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf('{ "Status" : "Activated"}');
        
        RestContext.request = request;

        //Call the method to test
        Test.startTest();
       	Id contractUpdatedId = ContractRestResource.updateContractFields();
        Test.stopTest();

        //Select the contract updated
        Contract contractUpdated = [SELECT Id, Status FROM Contract WHERE Id = :contractUpdatedId];

        //Verify that the good record is updated and the that the field is updated
        System.AssertEquals(myExistingContract.Id, contractUpdatedId, 'Wrong record on update');
        System.AssertEquals('Activated', contractUpdated.Status);
    }
    // Helper methods

    private static String genericURI(){
        String uri = 'https://akkodis6-dev-ed.my.salesforce.com/services/apexrest/Contract/';
        return uri;
    }
}