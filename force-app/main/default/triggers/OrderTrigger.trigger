trigger OrderTrigger on Order (before update, After insert, after delete) {

    OrderTriggerHandler orderTriggerHandler = new OrderTriggerHandler();

    if(Trigger.isBefore && Trigger.isUpdate){

        orderTriggerHandler.activeStatusCondition();
    }

    if(Trigger.isAfter && Trigger.isInsert){

        orderTriggerHandler.checkActiveOnAccount();
    }

    if(Trigger.isAfter && Trigger.isDelete){

        orderTriggerHandler.uncheckActiveOnAccount();
    }
}