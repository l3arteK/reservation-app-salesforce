public with sharing class ResourceStatusBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Status__c ' + 'FROM Resource__c ' + 'WHERE  Status__c IN (\'Free\', \'In use\')');
    }

    public void execute(Database.BatchableContext bc, List<Resource__c> scope) {
        ResourceStatusService.updateResourceStatuses(scope);
    }

    public void finish(Database.BatchableContext bc) {
    }
}
