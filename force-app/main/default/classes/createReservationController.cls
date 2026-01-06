public without sharing class createReservationController {
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
            for (Resource__c res : [SELECT Id, Name FROM Resource__c ORDER BY Name ASC]) {
                options.add(new createReservationHelper.Option(res.Name, res.Id));
            }
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of resources: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            List<Date> bookedDates = new List<Date>();
            for (Reservation__c res : [
                SELECT Start_date__c, End_date__c
                FROM Reservation__c
                WHERE Resource__c = :resourceId AND End_date__c >= TODAY
            ]) {
                Date currentDate = res.Start_date__c;
                while (currentDate <= res.End_date__c) {
                    bookedDates.add(currentDate);
                    currentDate = currentDate.addDays(1);
                }
            }
            return bookedDates;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of booked dates: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving booked dates: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createReservation(String lastName, String email, Id resourceId, Date startDate, Date endDate) {
        try {
            Id contactId = getContact(lastName, email);
            if (contactId == null) {
                Contact newContact = new Contact(LastName = lastName, Email = email);
                insert newContact;
                contactId = newContact.Id;
            }

            insert new Reservation__c(Contact__c = contactId, Resource__c = resourceId, Start_date__c = startDate, End_date__c = endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during creation of reservation: ' + e.getMessage());
            throw new AuraHandledException('An error occurred during creation of reservation: ' + e.getMessage());
        }
    }
}
