public with sharing class ReservationTriggerHandler {
    public static void handleBeforeInsert(List<Reservation__c> newReservations) {
        for (Reservation__c res : newReservations) {
            if (res.End_time__c <= res.Start_time__c) {
                res.addError('End time must be after start time.');
            }

            res.Name =
                res.Contact__r.Name +
                ' - ' +
                res.Resource__r.Name +
                ' ' +
                String.valueOf(res.Start_time__c.format('yyyy-MM-dd HH:mm')) +
                ' to ' +
                String.valueOf(res.End_time__c.format('yyyy-MM-dd HH:mm'));
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
