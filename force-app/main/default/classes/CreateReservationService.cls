public inherited sharing class CreateReservationService {
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

    public static List<CreateReservationService.Option> getResources() {
        List<CreateReservationService.Option> options = new List<CreateReservationService.Option>();
        for (Resource__c res : [SELECT Id, Name FROM Resource__c ORDER BY Name ASC]) {
            options.add(new CreateReservationService.Option(res.Name, res.Id));
        }
        return options;
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
