@isTest
public class TaskCreationForAccountServiceTest {
    
    @testSetup
    static void testData(){
    	Id accountId = TestDataFactory.createAccount();
    	Id contractId = TestDataFactory.createContract(accountId);

    	Contract newContract = [ SELECT Id, status FROM Contract ];
    	newContract.status = 'Activated';
    	update newContract;
    }
    
    @isTest
    static void taskCreationTest(){
        Account accountCreated = [SELECT Id, OwnerId FROM Account];
        
        Test.startTest();
    	Id batchId = Database.executeBatch(new TaskCreationForAccount_Batch());
    	Test.stopTest();

        Task newTask = [SELECT Id, OwnerId, AccountId, ActivityDate, Subject, Priority, IsReminderSet, ReminderDateTime FROM Task];

        System.assertEquals(accountCreated.OwnerId, newTask.OwnerId, 'The Owner of the Task should be the same as the Account owner');
        System.assertEquals(accountCreated.Id, newTask.AccountId, 'The AccountId of the Task should be the same as the Account Id');
        System.assertEquals(System.today(), newTask.ActivityDate, 'The Date expected is the scheduled date of the batch');
        System.assertEquals('Call', newTask.Subject, 'The Subject should be Call');
        System.assertEquals('Normal', newTask.Priority, 'The Priority should be Normal');
        System.assertEquals(true, newTask.IsReminderSet, 'The Reminder Set should be true');
        System.assertEquals(newTask.ActivityDate + 5, newTask.ReminderDateTime, 'The Reminder DateTime Should be Due date +5 days');
    }

    
  @isTest 
  static void testSchedulerMethod() {

    String timeToSchedule = '0 0 0 6 5 ? 2042';
    System.debug(timeToSchedule);

    Test.startTest();
    String jodId = System.schedule('ExecuteBatchTest', timeToSchedule, new TaskCreationForAccount_Batch());
    Test.stopTest();

    List<AsyncApexJob> jobsScheduled = [
      select Id, ApexClassID, ApexClass.Name, Status,
      JobType from AsyncApexJob where JobType = 'ScheduledApex'
    ];
    System.assertEquals(1, jobsScheduled.size(), 'expecting one apex batch job');
  }
}