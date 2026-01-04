public class ResourceStatusService {
    public static void updateResourceStatuses() {
        Date today = Date.today();

        List<Resource__c> resourcesToUpdate = [
            SELECT Id, Status__c
            FROM Resource__c
            WHERE
                Status__c = 'Booked'
                AND Id IN (
                    SELECT Resource__c
                    FROM Reservation__c
                    WHERE Start_Date__c <= :today AND End_Date__c >= :today
                )
        ];

        for (Resource__c r : resourcesToUpdate) {
            r.Status__c = 'In use';
        }

        if (!resourcesToUpdate.isEmpty()) {
            update resourcesToUpdate;
        }
    }
}
