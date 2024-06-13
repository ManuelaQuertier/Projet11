@RestResource(urlMapping= '/Contract/*')
global with sharing class ContractRestResource {

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

    
    @HttpPatch
    global static Id updateContractFields() {

        RestRequest request = RestContext.request;
        
        String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
        // Deserialize the JSON string into name-value pairs
      
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
        // Set the field and value on the Case sObject
        thisContract.put(fieldName, params.get(fieldName));
        }
        update thisContract;
        return thisContract.Id;
    }
}
