@isTest
public class OrderTriggerHandlerTest {

    @TestSetup
    static void TestDatas(){
        
    Id accountId = TestDataFactory.createAccount();

    Id contractId = TestDataFactory.createContract(accountId);
    Contract newContract = [ SELECT Id, status FROM Contract ];
    newContract.status = 'Activated';
    update newContract;

    TestDataFactory.createOrders(accountId, contractId, 5);
    }

    @isTest
    static void OrderWithOrderItemTest() {

        Order myNewOrder = [ SELECT Id, Status from Order LIMIT 1 ];

        try{

            Test.startTest();
            myNewOrder.Status = 'Activated';
            update myNewOrder;
            Test.stopTest();

            System.assert(false, 'Exeption Expected');

        } catch (DmlException e) {

            System.assert(e.getMessage().contains('Thanks to add products before activate an order'), 'message=' + e.getMessage());
        }

    }

    @isTest
    static void checkActiveOnAccountTest(){

        Order myNewOrder = [SELECT Id, AccountId from Order LIMIT 1 ];
        Account myAccountToVerify = [SELECT Id, Active__c FROM Account WHERE Id = :myNewOrder.AccountId];

        System.assertEquals('account.active = true', 'get the account active');
    }
}