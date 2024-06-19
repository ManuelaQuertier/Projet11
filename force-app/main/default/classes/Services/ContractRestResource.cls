@RestResource(urlMapping= '/Contract/*')
global with sharing class ContractRestResource {

    /**
     * @description : This method run with HTTP Post callout and insert new ContRact in salesforce
     * @param: accountName Name of the account
     * @param: contractTerm Contract duration (in month)
     * @param: contractStartDate start date of the contract
     * @return: Id return the id of the contract created
     */
    @HttpPost
    global static Id createContract(String accountName, String contractTerm, String contractStartDate) {

        Id accountId = [SELECT Id FROM Account WHERE Name = :accountName].Id;

        Contract newContract = new Contract(
            AccountID = accountId,
            Status = 'Draft',
            ContractTerm = integer.valueOf(contractTerm),
            StartDate = date.parse(contractStartDate)
            );

        insert newContract;
        return newContract.Id;
    }

    /**
     * @description: This method run woth HTTP Patch callout and update fields of acontract based on its Id
     */
    @HttpPatch
    global static Id updateContractFields() {

        RestRequest request = RestContext.request;
        //Get the Contract Id to update in the URL
        String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        //Get the Contract to update
        Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];

        //Create a Map to deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());

        // Iterate through each parameter field and value to set the field and value on the Contract sObject
        for(String fieldName : params.keySet()){
            thisContract.put(fieldName, params.get(fieldName));
        }

        update thisContract;
        return thisContract.Id;
    }
}
