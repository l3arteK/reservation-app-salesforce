public inherited sharing class ReservationService {
    public class Option {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public static List<Date> getBookedDates(Id resourceId) {
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
    }

    public static Id getContact(String lastName, String email) {
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :email AND LastName = :lastName LIMIT 1];
        return contacts.isEmpty() ? null : contacts[0].Id;
    }

    public static void deleteReservation(Id reservationId) {
        delete [SELECT Id FROM Reservation__c WHERE Id = :reservationId LIMIT 1];
    }

    public static List<Resource__c> getResources() {
        return [SELECT Id, Name, Type__c FROM Resource__c ORDER BY Name ASC];
    }

    public static List<Reservation__c> getReservations(String email, String lastName) {
        Id contactId = getContact(lastName, email);
        if (contactId == null) {
            return new List<Reservation__c>();
        }
        return [
            SELECT Id, Contact__r.Name, Resource__r.Name, Start_date__c, End_date__c
            FROM Reservation__c
            WHERE Contact__c = :contactId
            ORDER BY Start_date__c DESC
        ];
    }

    public static List<Reservation__c> getReservations(Id contactId) {
        return [
            SELECT Id, Resource__r.Name, Start_date__c, End_date__c
            FROM Reservation__c
            WHERE Contact__c = :contactId
            ORDER BY Start_date__c DESC
        ];
    }

    public static Id createReservation(String lastName, String email, Id resourceId, Date startDate, Date endDate) {
        Id contactId = getContact(lastName, email);
        if (contactId == null) {
            Contact newContact = new Contact(LastName = lastName, Email = email);
            insert newContact;
            contactId = newContact.Id;
        }
        Reservation__c newReservation = new Reservation__c(
            Contact__c = contactId,
            Resource__c = resourceId,
            Start_date__c = startDate,
            End_date__c = endDate
        );
        insert newReservation;
        return newReservation.Id;
    }
}
