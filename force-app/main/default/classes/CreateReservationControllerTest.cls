@IsTest
private class CreateReservationControllerTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            insert new List<Resource__c>{
                new Resource__c(Name = 'A Resource', Type__c = 'Room'),
                new Resource__c(Name = 'B Resource', Type__c = 'Room'),
                new Resource__c(Name = 'Room 1', Type__c = 'Room'),
                new Resource__c(Name = 'Room 2', Type__c = 'Room'),
                new Resource__c(Name = 'Room 3', Type__c = 'Room')
            };
        }

    }

    @IsTest
    static void testGetContact_existingContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Contact c = TestHelper.createContact('Kowalski', 'kowalski@test.pl');

            Test.startTest();
            Id contactId = CreateReservationController.getContact('Kowalski', 'kowalski@test.pl');
            Test.stopTest();

            Assert.areEqual(c.Id, contactId, 'Should return existing contact');
        }
    }

    @IsTest
    static void testGetContact_notFound() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Id contactId = CreateReservationController.getContact('Nowak', 'nowak@test.pl');
            Test.stopTest();

            Assert.isNull(contactId, 'Should return null when the contact doesnt exist. ');
        }
    }

    @IsTest
    static void testGetResources() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            List<CreateReservationHelper.Option> options = CreateReservationController.getResources();
            Test.stopTest();

            Assert.areEqual(5, options.size(), 'Should return all resources');
        }
    }

    @IsTest
    static void testGetBookedDates() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id, Name FROM Resource__c WHERE Name = 'Room 1' LIMIT 1];
            Contact c = TestHelper.createContact('Test', 'test@test.pl');

            TestHelper.createReservation(c.Id, res.Id, Date.today(), Date.today().addDays(2));

            Test.startTest();
            List<Date> bookedDates = CreateReservationController.getBookedDates(res.Id);
            Test.stopTest();

            Assert.isNotNull(bookedDates, 'Booked dates list should not be null');
        }
    }

    @IsTest
    static void testCreateReservation_existingContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c WHERE Name = 'Room 2' LIMIT 1];
            Contact c = TestHelper.createContact('Existing', 'existing@test.pl');

            Test.startTest();
            CreateReservationController.createReservation('Existing', 'existing@test.pl', res.Id, Date.today(), Date.today().addDays(1));
            Test.stopTest();

            Reservation__c r = [
                SELECT Id, Contact__c, Resource__c
                FROM Reservation__c
                WHERE Contact__c = :c.Id
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            Assert.areEqual(res.Id, r.Resource__c, 'Reservation should be created for the existing contact');
        }
    }

    @IsTest
    static void testCreateReservation_newContactCreated() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id FROM Resource__c WHERE Name = 'Room 3' LIMIT 1];

            Test.startTest();
            CreateReservationController.createReservation('NewContact', 'new@test.pl', res.Id, Date.today(), Date.today().addDays(1));
            Test.stopTest();

            Contact c = [
                SELECT Id
                FROM Contact
                WHERE Email = 'new@test.pl'
                LIMIT 1
            ];

            Reservation__c r = [
                SELECT Id, Contact__c
                FROM Reservation__c
                WHERE Contact__c = :c.Id
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            Assert.areEqual(c.Id, r.Contact__c, 'Reservation should be created for the new contact');
        }
    }

    @IsTest
    static void testCreateReservation_invalidResource() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Boolean exceptionThrown = false;

            try {
                CreateReservationController.createReservation('Error', 'error@test.pl', null, Date.today(), Date.today().addDays(1));
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }

            Test.stopTest();
            Assert.isTrue(exceptionThrown, 'Should throw exception when resourceId is null');
        }
    }
}
