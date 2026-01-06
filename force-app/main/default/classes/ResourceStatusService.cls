public class ResourceStatusService {
    public static void updateResourceStatuses() {
        Date today = Date.today();

        List<Resource__c> resourcesToUpdate = new List<Resource__c>();

        List<Resource__c> bookedResources = [
            SELECT Id, Status__c
            FROM Resource__c
            WHERE
                Status__c = 'Free'
                AND Id IN (
                    SELECT Resource__c
                    FROM Reservation__c
                    WHERE Start_Date__c <= :today AND End_Date__c >= :today
                )
        ];

        for (Resource__c r : bookedResources) {
            r.Status__c = 'In use';
        }
        resourcesToUpdate.addAll(bookedResources);

        List<Resource__c> inUseResources = [
            SELECT Id, Status__c, Name
            FROM Resource__c
            WHERE
                Status__c = 'In use'
                AND Id NOT IN (
                    SELECT Resource__c
                    FROM Reservation__c
                    WHERE Start_Date__c <= :today AND End_Date__c >= :today
                )
        ];

        for (Resource__c r : inUseResources) {
            r.Status__c = 'Free';
        }
        resourcesToUpdate.addAll(inUseResources);

        if (!resourcesToUpdate.isEmpty()) {
            update resourcesToUpdate;
        }
    }
}
