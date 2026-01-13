@IsTest
private class CreateReservationControllerTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            TestHelper.createResource('A Resource');
            TestHelper.createResource('B Resource');
            TestHelper.createResource('Room 1');
            TestHelper.createResource('Room 2');
            TestHelper.createResource('Room 3');
            TestHelper.createContact('Test', 'test@test.pl');
        }

    }

    @IsTest
    static void testGetResources() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            List<ReservationService.Option> options = CreateReservationController.getResources();
            Test.stopTest();

            Assert.areEqual(5, options.size(), 'Should return all resources');
        }
    }

    @IsTest
    static void testGetBookedDates() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [SELECT Id, Name FROM Resource__c WHERE Name = 'Room 1' LIMIT 1];
            Contact c = [SELECT Id FROM Contact LIMIT 1];

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
            Contact c = [SELECT Id FROM Contact LIMIT 1];
            Test.startTest();
            CreateReservationController.createReservation('Test', 'test@test.pl', res.Id, Date.today(), Date.today().addDays(1));
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

    @IsTest
    static void testUpdateReservation_success() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c originalRes = [SELECT Id FROM Resource__c WHERE Name = 'Room 1' LIMIT 1];
            Resource__c newRes = [SELECT Id FROM Resource__c WHERE Name = 'Room 2' LIMIT 1];
            Contact c = [SELECT Id FROM Contact LIMIT 1];

            Reservation__c r = TestHelper.createReservation(c.Id, originalRes.Id, Date.today(), Date.today().addDays(1));

            Date newStart = Date.today().addDays(3);
            Date newEnd = Date.today().addDays(5);

            Test.startTest();
            CreateReservationController.updateReservation(r.Id, newRes.Id, newStart, newEnd);
            Test.stopTest();

            Reservation__c updated = [
                SELECT Resource__c, Start_date__c, End_date__c
                FROM Reservation__c
                WHERE Id = :r.Id
            ];

            Assert.areEqual(newRes.Id, updated.Resource__c, 'updateReservation should update the Resource on the reservation');
            Assert.areEqual(newStart, updated.Start_date__c, 'updateReservation should update the Start Date');
            Assert.areEqual(newEnd, updated.End_date__c, 'updateReservation should update the End Date');
        }
    }
}
