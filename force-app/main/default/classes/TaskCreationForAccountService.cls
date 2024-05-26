public with sharing class TaskCreationForAccountService {
    
    public void taskCreation(List<Account> accountWithNoTask) {

        List<Task> tasksToCreate = new List<Task>();

        for(Account account :accountWithNoTask){
            Task myTask = new Task(
				WhatId= account.id,
                OwnerId = account.OwnerId,
                Subject = 'Call',
                Priority = 'Normal',
                IsReminderSet = true,
                ReminderDateTime = System.now()+5
                );
                tasksToCreate.add(myTask);
        }

        insert tasksToCreate;
    }
}