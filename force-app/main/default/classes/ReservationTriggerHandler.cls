public without sharing class ReservationTriggerHandler {
    public static void handleBeforeInsert(List<Reservation__c> newReservations) {
        Set<Id> resourceIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Date minStart, maxEnd;

        for (Reservation__c res : newReservations) {
            if (res.Resource__c != null)
                resourceIds.add(res.Resource__c);
            if (res.Contact__c != null)
                contactIds.add(res.Contact__c);

            if (minStart == null || res.Start_date__c < minStart)
                minStart = res.Start_date__c;
            if (maxEnd == null || res.End_date__c > maxEnd)
                maxEnd = res.End_date__c;
        }

        validateOverlaps(newReservations, resourceIds, minStart, maxEnd);
        setReservationNames(newReservations, resourceIds, contactIds);
    }

    private static void validateOverlaps(List<Reservation__c> newReservations, Set<Id> resourceIds, Date minStart, Date maxEnd) {
        Map<Id, List<Reservation__c>> resourceMap = getResourceToReservationsMap(resourceIds, minStart, maxEnd);

        for (Reservation__c res : newReservations) {
            if (!resourceMap.containsKey(res.Resource__c))
                continue;

            for (Reservation__c existing : resourceMap.get(res.Resource__c)) {
                if (res.Start_date__c <= existing.End_date__c && res.End_date__c >= existing.Start_date__c) {
                    res.addError('The selected dates are not available for the chosen resource.');
                    break;
                }
            }
        }
    }

    private static Map<Id, List<Reservation__c>> getResourceToReservationsMap(Set<Id> resourceIds, Date minStart, Date maxEnd) {
        Map<Id, List<Reservation__c>> resourceMap = new Map<Id, List<Reservation__c>>();

        List<Reservation__c> existingReservations = [
            SELECT Resource__c, Start_date__c, End_date__c
            FROM Reservation__c
            WHERE Resource__c IN :resourceIds AND Start_date__c <= :maxEnd AND End_date__c >= :minStart
        ];

        for (Reservation__c res : existingReservations) {
            if (!resourceMap.containsKey(res.Resource__c)) {
                resourceMap.put(res.Resource__c, new List<Reservation__c>());
            }
            resourceMap.get(res.Resource__c).add(res);
        }
        return resourceMap;
    }

    private static void setReservationNames(List<Reservation__c> newReservations, Set<Id> resourceIds, Set<Id> contactIds) {
        Map<Id, Resource__c> resources = new Map<Id, Resource__c>([SELECT Name FROM Resource__c WHERE Id IN :resourceIds]);
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Name FROM Contact WHERE Id IN :contactIds]);

        for (Reservation__c res : newReservations) {
            String contactName = contacts.containsKey(res.Contact__c) ? contacts.get(res.Contact__c).Name : 'Unknown Contact';
            String resourceName = resources.containsKey(res.Resource__c) ? resources.get(res.Resource__c).Name : 'Unknown Resource';
            String dateRange = '(' + res.Start_date__c.format() + ' to ' + res.End_date__c.format() + ')';

            res.Name = contactName + ' - ' + resourceName + ' ' + dateRange;
        }
    }
}
