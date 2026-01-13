@IsTest
private class ManageReservationControllerTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            Resource__c res = TestHelper.createResource('Room MR');
            Contact c = TestHelper.createContact('Manage', 'manage@test.pl');

            TestHelper.createReservation(c.Id, res.Id, Date.today(), Date.today().addDays(1));
        }
    }
    @IsTest
    static void testGetReservations_nullContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            List<Reservation__c> reservations = ManageReservationController.getReservations(null);
            Test.stopTest();

            Assert.areEqual(0, reservations.size(), 'getReservations should return an empty list when contactId is null');
        }
    }

    @IsTest
    static void testGetReservations_success() {
        System.runAs(TestHelper.getAdminUser()) {
            Contact c = [
                SELECT Id
                FROM Contact
                LIMIT 1
            ];

            Test.startTest();
            List<Reservation__c> reservations = ManageReservationController.getReservations(c.Id);
            Test.stopTest();

            Assert.areEqual(1, reservations.size(), 'getReservations should return reservations for the given contact');
        }
    }

    @IsTest
    static void testDeleteReservation_success() {
        System.runAs(TestHelper.getAdminUser()) {
            Reservation__c r = [
                SELECT Id
                FROM Reservation__c
                LIMIT 1
            ];

            Test.startTest();
            ManageReservationController.deleteReservation(r.Id);
            Test.stopTest();

            Integer countAfterDelete = [
                SELECT COUNT()
                FROM Reservation__c
                WHERE Id = :r.Id
            ];

            Assert.areEqual(0, countAfterDelete, 'deleteReservation should remove the reservation record');
        }
    }
}
