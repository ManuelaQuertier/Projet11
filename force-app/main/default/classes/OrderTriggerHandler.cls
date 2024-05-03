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
        List <Order> newOrderList = [SELECT Id, AccountId FROM Order WHERE Id in:this.newList];
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
        List<Order> ordersDeleted = [SELECT Id, AccountId FROM Order WHERE Id in:this.oldList ALL ROWS];
        Set<Id> accountIds = new Set<Id>();

        for(Order orderDeleted:ordersDeleted){
            if (!accountIds.contains(orderDeleted.AccountId)){
                accountIds.add(orderDeleted.AccountId);
            }
        }
        List<Account> accountsToVerify = [SELECT Id, Active__c , (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountIds];

        for (Account accountToVerify :accountsToVerify){
            if (accountToVerify.Orders.size() == 0){
                accountToVerify.Active__c = false;
            }
        }
        update accountsToVerify;
        }
    }