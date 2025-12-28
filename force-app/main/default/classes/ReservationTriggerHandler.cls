public with sharing class ReservationTriggerHandler {
    public static void handleBeforeInsert(List<Reservation__c> newReservations) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> resourceIds = new Set<Id>();

        for (Reservation__c res : newReservations) {
            if (res.Contact__c != null) {
                contactIds.add(res.Contact__c);
            }
            if (res.Resource__c != null) {
                resourceIds.add(res.Resource__c);
            }
        }

        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);

        Map<Id, Resource__c> resources = new Map<Id, Resource__c>([SELECT Id, Name FROM Resource__c WHERE Id IN :resourceIds]);

        for (Reservation__c res : newReservations) {
            Contact c = contacts.get(res.Contact__c);
            Resource__c r = resources.get(res.Resource__c);

            res.Name =
                (c != null ? c.Name : 'Unknown Contact') +
                ' - ' +
                (r != null ? r.Name : 'Unknown Resource') +
                ' ' +
                res.Start_time__c.format('yyyy-MM-dd HH:mm') +
                ' to ' +
                res.End_time__c.format('yyyy-MM-dd HH:mm');
        }
    }

    public static void handleAfterInsert(List<Reservation__c> newReservations) {
        Set<Id> resourceIds = new Set<Id>();

        for (Reservation__c res : newReservations) {
            if (res.Resource__c != null) {
                resourceIds.add(res.Resource__c);
            }
        }

        List<Resource__c> resources = [
            SELECT Id, Status__c
            FROM Resource__c
            WHERE Id IN :resourceIds
        ];

        for (Resource__c r : resources) {
            r.Status__c = 'Booked';
        }

        update resources;
    }
}
