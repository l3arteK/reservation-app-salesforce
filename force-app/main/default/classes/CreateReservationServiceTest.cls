@isTest
private class CreateReservationServiceTest {
    @TestSetup
    static void setup() {
        System.runAs(TestHelper.createAdminUser()) {
            TestHelper.createContact('Kowalski', 'kowalski@test.pl');
            TestHelper.createResource('Room A');
            TestHelper.createResource('Room B');
        }
    }

    @IsTest
    static void testGetContact_existingContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Id contactId = CreateReservationService.getContact('Kowalski', 'kowalski@test.pl');
            Test.stopTest();

            Assert.isNotNull(contactId, 'Should return existing contact');
        }
    }

    @IsTest
    static void testGetContact_notFound() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Id contactId = CreateReservationService.getContact('Nowak', 'nowak@test.pl');
            Test.stopTest();

            Assert.isNull(contactId, 'Should return null when the contact doesnt exist. ');
        }
    }

    @IsTest
    static void testGetBookedDates_singleReservation() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c LIMIT 1];
            Contact c = [SELECT Id FROM Contact LIMIT 1];

            TestHelper.createReservation(c.Id, res.Id, Date.today(), Date.today().addDays(2));

            Test.startTest();
            List<Date> dates = CreateReservationService.getBookedDates(res.Id);
            Test.stopTest();

            Assert.areEqual(3, dates.size(), 'Should return 3 days');
        }
    }

    @IsTest
    static void testGetBookedDates_multipleReservations() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c LIMIT 1];
            Contact c = [SELECT Id FROM Contact LIMIT 1];

            TestHelper.createReservation(c.Id, res.Id, Date.today(), Date.today());
            TestHelper.createReservation(c.Id, res.Id, Date.today().addDays(2), Date.today().addDays(3));

            Test.startTest();
            List<Date> dates = CreateReservationService.getBookedDates(res.Id);
            Test.stopTest();

            Assert.areEqual(3, dates.size(), 'Should return all days from both reservations');
        }
    }

    @IsTest
    static void testGetBookedDates_noReservations() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c LIMIT 1];

            Test.startTest();
            List<Date> dates = CreateReservationService.getBookedDates(res.Id);
            Test.stopTest();

            Assert.areEqual(0, dates.size(), 'Should return empty list when there are no reservations');
        }
    }

    @IsTest
    static void testGetResources_sortedAndMapped() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c r1 = [SELECT Id FROM Resource__c WHERE Name = 'Room A' LIMIT 1];
            Resource__c r2 = [SELECT Id FROM Resource__c WHERE Name = 'Room B' LIMIT 1];

            Test.startTest();
            List<CreateReservationService.Option> options = CreateReservationService.getResources();
            Test.stopTest();

            Assert.areEqual(2, options.size(), 'getResources should return exactly 2 resource options');
            Assert.areEqual(
                'Room A',
                options[0].label,
                'The first option label should be "A Resource" (resources must be sorted by Name ascending)'
            );
            Assert.areEqual(r1.Id, options[0].value, 'The first option value should contain the Id of the "A Resource" record');
        }
    }

    @IsTest
    static void testCreateReservation_existingContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c LIMIT 1];
            Contact c = [SELECT Id FROM Contact LIMIT 1];

            Test.startTest();
            CreateReservationService.createReservation('Kowalski', 'kowalski@test.pl', res.Id, Date.today(), Date.today().addDays(1));
            Test.stopTest();

            Reservation__c r = [
                SELECT Contact__c, Resource__c
                FROM Reservation__c
                WHERE Contact__c = :c.Id
                LIMIT 1
            ];

            Assert.areEqual(res.Id, r.Resource__c, 'The reservation should be linked to the provided Resource');
        }
    }

    @IsTest
    static void testCreateReservation_newContactCreated() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c LIMIT 1];

            Test.startTest();
            CreateReservationService.createReservation('New', 'new@test.pl', res.Id, Date.today(), Date.today());
            Test.stopTest();

            Contact c = [
                SELECT Id
                FROM Contact
                WHERE Email = 'new@test.pl'
                LIMIT 1
            ];

            Reservation__c r = [
                SELECT Contact__c
                FROM Reservation__c
                WHERE Contact__c = :c.Id
                LIMIT 1
            ];

            Assert.areEqual(c.Id, r.Contact__c, 'The reservation should be linked to the newly created Contact');
        }
    }
}