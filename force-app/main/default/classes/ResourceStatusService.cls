public class ResourceStatusService {
    public static void updateResourceStatuses(List<Resource__c> scope) {
        Date today = Date.today();
        Set<Id> resourceIds = new Set<Id>();
        for (Resource__c r : scope) {
            resourceIds.add(r.Id);
        }

        Map<Id, Reservation__c> activeReservationsByResource = new Map<Id, Reservation__c>();
        for (Reservation__c res : [
            SELECT Resource__c
            FROM Reservation__c
            WHERE Resource__c IN :resourceIds AND Start_Date__c <= :Date.today() AND End_Date__c >= :Date.today()
        ]) {
            activeReservationsByResource.put(res.Resource__c, res);
        }

        List<Resource__c> bookedResources = new List<Resource__c>();
        List<Resource__c> inUseResources = new List<Resource__c>();

        for (Resource__c r : scope) {
            Boolean hasReservation = activeReservationsByResource.containsKey(r.Id);

            if (r.Status__c == 'Free' && hasReservation) {
                bookedResources.add(r);
            }

            if (r.Status__c == 'In use' && !hasReservation) {
                inUseResources.add(r);
            }
        }

        process(bookedResources, inUseResources);
    }

    public static void process(List<Resource__c> booked, List<Resource__c> inUse) {
        List<Resource__c> toUpdate = new List<Resource__c>();

        for (Resource__c r : booked) {
            r.Status__c = 'In use';
            toUpdate.add(r);
        }

        for (Resource__c r : inUse) {
            r.Status__c = 'Free';
            toUpdate.add(r);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}