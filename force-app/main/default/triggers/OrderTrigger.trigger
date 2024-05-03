trigger OrderTrigger on Order (before update, After insert, after delete) {

    if(Trigger.isBefore && Trigger.isUpdate){
        OrderTriggerHandler instance = new OrderTriggerHandler();

        instance.activeStatusCondition();
    }

    if(Trigger.isAfter && Trigger.isInsert){
        OrderTriggerHandler instance = new OrderTriggerHandler();

        instance.checkActiveOnAccount();
    }

    if(Trigger.isAfter && Trigger.isDelete){
        OrderTriggerHandler instance = new OrderTriggerHandler();

        instance.uncheckActiveOnAccount();
    }
}