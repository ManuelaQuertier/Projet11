trigger OrderTrigger on Order (before update) {

    if(Trigger.isBefore && Trigger.isUpdate){
        OrderTriggerHandler instance = new OrderTriggerHandler();

        instance.activeStatusCondition();
    }
}