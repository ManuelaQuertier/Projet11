public with sharing class OrderTriggerHandler {

    Private List<Order> newList;
    Private List<Order> oldList;
    Private Map<Id, Order> oldMap;

    public OrderTriggerHandler() {
        this.newList = (List<Order>) Trigger.new;
        this.oldMap = (Map <Id, Order>) Trigger.oldMap;
        this.oldList = (List<Order>)Trigger.old;
    }

    /**
     * @Description Les Orders dont le Status passe de Draft à un Status considéré comme "Actif" doivent contenir des produits
     *              Dans le cas contraire le changement de status est bloqué et un message d'erreur invite à ajouter des produits
     */
    public void activeStatusCondition(){

        newList = this.newList;
        oldMap = this.oldMap;
		Set<Id> OrderWithproductsIds = new Set<Id>();//Orders avec des produits
        
        List<OrderItem> products = [SELECT Id, OrderId FROM OrderItem where OrderId in :newList];//Selection des produits liée aux order qui déclanchens le trigger

        for(OrderItem product :products){
            OrderWithproductsIds.add(product.OrderId);
        }
		
        for( Order newOrder :newList){

            //Si le Status passe de Draft à un status code Activated et que l'order n'est pas dans la liste des Order contenant des produits=> message d'erreur
            if (oldMap.get(newOrder.Id).Status == 'Draft' && !OrderWithproductsIds.contains(newOrder.Id)  && newOrder.StatusCode == 'Activated'){
                newOrder.addError('Thanks to add products before activate an order');
            }else {
                continue;
            }
        }
    }

    /**
     * @Description Lors de l'insertion d'un nouvel Order, si l'Account lié n'est pas encore acif on passe son champ Active__c à "true"
     *              Valeur pas défaut = false
     */
    public void checkActiveOnAccount(){
        List <Order> newOrderList = [SELECT Id, AccountId FROM Order WHERE Id in:this.newList];
        Set<Id> accountIds = new set<Id>();

        for(Order newOrder : newOrderList){
            accountIds.add(newOrder.AccountId);
        }
        //récupération des Accounts lié aux nouveaux Orders 
        List<Account> accountsWithOrders = [SELECT Id, Active__c FROM Account WHERE id IN:accountIds];

        for(Account account :accountsWithOrders){
            if(account.Active__c == false){ //si l'Account pas encore actif = on passe le Champs Active à true
                account.Active__c = true;
            }
        }
        update accountsWithOrders;

    }

    /**
     * @Description Lors de la Suppression d'un Order,si l'Account lié ne possède plus d'Order son champ Active__c passe à "False"
     */
    public void uncheckActiveOnAccount(){
        List<Order> ordersDeleted = [SELECT Id, AccountId FROM Order WHERE Id in:this.oldList ALL ROWS];//Selection des Orders Supprimés
        Set<Id> accountIds = new Set<Id>();

        for(Order orderDeleted:ordersDeleted){
            if (!accountIds.contains(orderDeleted.AccountId)){
                accountIds.add(orderDeleted.AccountId);
            }
        }
        //Selection des Accounts et de leur Orders liés
        List<Account> accountsToVerify = [SELECT Id, Active__c , (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountIds];

        //Si aucun Order lié Active__s = false
        for (Account accountToVerify :accountsToVerify){
            if (accountToVerify.Orders.size() == 0){
                accountToVerify.Active__c = false;
            }
        }
        update accountsToVerify;
        }
    }