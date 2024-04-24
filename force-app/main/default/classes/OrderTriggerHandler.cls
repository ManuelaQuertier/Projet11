public with sharing class OrderTriggerHandler {

    Private List<Order> newList;
    Private List<Order> oldList;
    Private Map<Id, Order> oldMap;

    public OrderTriggerHandler() {
        this.newList = (List<Order>) Trigger.new;
        this.oldMap = (Map <Id, Order>) Trigger.oldMap;
        this.oldList = (List<Order>)Trigger.old;
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

    public void checkActiveOnAccount(){
        List <Order> newOrderList = [SELECT Id, AccountId FROM Order WHERE Id= :this.newList];
        Set<Id> accountIds = new set<Id>();

        for(Order newOrder : newOrderList){
            accountIds.add(newOrder.AccountId);
        }

        List<Account> accountsWithOrders = [SELECT Id, Active__c FROM Account WHERE id IN:accountIds];

        for(Account account :accountsWithOrders){
            account.Active__c = true;
        }
        update accountsWithOrders;

    }

    public void uncheckActiveOnAccount(){
        List <Order> newOrderList = [SELECT Id, AccountId FROM Order WHERE Id= :this.oldList];
        Set<Id> accountIds = new set<Id>();

        for(Order newOrder :newOrderList){
            accountIds.add(newOrder.AccountId);
        }
    
        List<Account> accountWithoutOrder = [SELECT Id, Active__c ,(SELECT id FROM Orders) FROM Account WHERE Id IN:accountIds];
        System.debug(accountWithoutOrder);
    }

    public static Boolean doesAccountHasOrder(Id accountId){

        Boolean accountHasOrder;

        List<Order> accountOrders = [SELECT Id, AccountId FROM Order WHERE AccountId = :accountId];
        //System.debug(accountOrders.size());
        if(accountOrders.size() > 0){
            accountHasOrder = true;
        } else accountHasOrder = false;
        //System.debug(accountHasOrder);
        return accountHasOrder;
    }
}