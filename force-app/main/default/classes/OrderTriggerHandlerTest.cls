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
    static void orderWithoutOrderItemTest() {

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

        System.assertEquals(true, myAccountToVerify.Active__c, 'If Account as Orders he must be actif');
    }

    @isTest
    static void activeWithOneOrderOnAccountTest(){

        List<Order> ordersCreated = [SELECT Id, AccountId FROM Order];

        Id accountId = [SELECT Id FROM Account].Id;

        ordersCreated.remove(ordersCreated.size()-1); // enlève un seul Order de la liste à supprimer

        Test.startTest();
        delete ordersCreated;// supprime les orders de la liste
        Test.stopTest();

        Account myTestAccountActive = [SELECT Id, Active__c FROM Account WHERE Id = :accountId];
        System.debug(myTestAccountActive.Active__c);
        System.assertEquals(true, myTestAccountActive.Active__c,'If Account as Orders he must be active');
 
    }

    @isTest
    static void activeFalseOnAccountTest(){

        List<Order> ordersCreated = [SELECT Id, AccountId FROM Order];

        Id accountId = [SELECT Id FROM Account].Id;

        Test.startTest();
        delete ordersCreated;
        
        Test.stopTest();
        Account myTestAccountInactive = [SELECT Id, Active__c FROM Account WHERE Id = :accountId];
        System.assertEquals(false,myTestAccountInactive.Active__c,'If the Account has no Order, he must be inactive');
 
    }

}