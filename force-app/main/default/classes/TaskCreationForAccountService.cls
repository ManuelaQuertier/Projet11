public with sharing class TaskCreationForAccountService {
    
    public void taskCreation(List<Account> accountWithNoTask) {

        List<Task> tasksToCreate = new List<Task>();
		List<Account> accountsToCreateTask = [SELECT Id, OwnerId FROM Account WHERE Id IN :accountWithNoTask];

        for(Account account :accountsToCreateTask){
            Task myTask = new Task(
				WhatId= account.id,
                OwnerId = account.OwnerId,
				ActivityDate = System.today(),
                Subject = 'Call',
                Priority = 'Normal',
                IsReminderSet = true,
                ReminderDateTime = System.today()+5
                );
                tasksToCreate.add(myTask);
        }

        insert tasksToCreate;
    }
}