global class TaskCreationForAccount_Batch implements Database.Batchable<sObject>,
    Schedulable {

  global Database.QueryLocator start(Database.BatchableContext info) {
   
    Set<Id> accountWithTaskId = new Set<Id>();
    for (Task task:[SELECT AccountId FROM Task]){
        accountWithTaskId.add(task.AccountId);
    }
    return Database.getQueryLocator(
        'Select Id, OwnerId FROM Account WHERE Id NOT IN(SELECT AccountId FROM Order) AND Id NOT IN :accountWithTaskId');
  }

  global void execute(Database.BatchableContext info, List<Account> scope) {

    TaskCreationForAccountService instance = new TaskCreationForAccountService();

    instance.taskCreation(scope);
  }

  global void finish(Database.BatchableContext info) {}

  global void execute(schedulableContext context) {

    TaskCreationForAccount_Batch batch = new TaskCreationForAccount_Batch();
    Database.executebatch(batch);
  }
}