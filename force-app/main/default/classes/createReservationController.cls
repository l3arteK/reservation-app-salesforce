public with sharing class createReservationController {
    @AuraEnabled(cacheable=true)
    public static Id getContact(String lastName, String email) {
        try {
            return [SELECT Id, lastName, Email FROM Contact WHERE Email = :email AND lastName = :lastName LIMIT 1].Id;
        } catch (QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                return null;
            } else {
                System.debug(LoggingLevel.ERROR, 'Error retrieving contact: ' + e.getMessage());
                throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error retrieving contact: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<createReservationHelper.Option> getResources() {
        try {
            List<createReservationHelper.Option> options = new List<createReservationHelper.Option>();
            for (Resource__c res : [SELECT Id, Name FROM Resource__c WHERE Status__c = 'Free']) {
                options.add(new createReservationHelper.Option(res.Name, res.Id));
            }
            return options;
        } catch (QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                return new List<createReservationHelper.Option>();
            } else {
                System.debug(LoggingLevel.ERROR, 'Error during retrieval of resources: ' + e.getMessage());
                throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of resources: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createReservation(Id contactId, Id resourceId, Date startDate, Date endDate) {
        try {
            insert new Reservation__c(Contact__c = contactId, Resource__c = resourceId, Start_date__c = startDate, End_date__c = endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during creation of reservation: ' + e.getMessage());
            throw new AuraHandledException('An error occurred during creation of reservation: ' + e.getMessage());
        }
    }

    public static Map<Id, List<createReservationHelper.ReservationRange>> getReservationRanges() {
        Map<Id, List<createReservationHelper.ReservationRange>> reservationMap = new Map<Id, List<createReservationHelper.ReservationRange>>();
        for (Reservation__c res : [SELECT Id, Resource__c, Start_date__c, End_date__c FROM Reservation__c]) {
            if (!reservationMap.containsKey(res.Resource__c)) {
                reservationMap.put(res.Resource__c, new List<createReservationHelper.ReservationRange>());
            }
            reservationMap.get(res.Resource__c).add(new createReservationHelper.ReservationRange(res.Start_date__c, res.End_date__c));
        }
        return reservationMap;
    }
}
