@IsTest
public inherited sharing class TestHelper {
    public static User createAdminUser() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User u = new User(
            Alias = 'tadmin',
            Email = 'admin@test.pl',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestAdmin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Username = 'admin' + System.currentTimeMillis() + '@test.pl'
        );

        insert u;

        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'RM_Administrator'
            LIMIT 1
        ];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        return u;
    }

    public static User getAdminUser() {
        return [
            SELECT Id, ProfileId
            FROM User
            WHERE Alias = 'tadmin'
            LIMIT 1
        ];
    }

    public static Contact createContact(String lastName, String email) {
        Contact c = new Contact(LastName = lastName, Email = email);
        insert c;
        return c;
    }

    public static Resource__c createResource(String name) {
        return createResource(name, 'Room');
    }

    public static Resource__c createResource(String name, String type) {
        Resource__c res = new Resource__c(Name = name, Type__c = type);
        insert res;
        return res;
    }

    public static Reservation__c createReservation(Id contactId, Id resourceId, Date startDate, Date endDate) {
        Reservation__c r = new Reservation__c(
            Contact__c = contactId,
            Resource__c = resourceId,
            Start_date__c = startDate,
            End_date__c = endDate
        );
        insert r;
        return r;
    }
}
