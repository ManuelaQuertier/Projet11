public with sharing class OrderTriggerHandler {

    Private List<Order> newList;
    Private Map<Id, Order> oldMap;

    public OrderTriggerHandler() {
        this.newList = (List<Order>) Trigger.new;
        this.oldMap = (Map <Id, Order>) Trigger.oldMap;
    }

    public void activeStatusCondition(){

        newList = this.newList;
        oldMap = this.oldMap;
		Set<Id> OrderWithproductsIds = new Set<Id>();
        
        List<OrderItem> products = [SELECT Id, OrderId FROM OrderItem where OrderId in :newList];

        for(OrderItem product :products){
            OrderWithproductsIds.add(product.OrderId);
        }
		
        for( Order newOrder :newList){

            if (oldMap.get(newOrder.Id).Status == 'Draft' && !OrderWithproductsIds.contains(newOrder.Id)  && newOrder.StatusCode == 'Activated'){
                newOrder.addError('Thanks to add products before activate an order');
            }else {
                continue;
            }
        }
    }
}