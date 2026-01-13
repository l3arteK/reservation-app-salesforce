@IsTest
private class ResourceControllerTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            Resource__c res = TestHelper.createResource('Resource RC');
            Contact c = TestHelper.createContact('RC', 'rc@test.pl');

            TestHelper.createReservation(c.Id, res.Id, Date.today(), Date.today().addDays(2));
        }
    }

    @IsTest
    static void testGetBookedDates_success() {
        System.runAs(TestHelper.getAdminUser()) {
            Resource__c res = [
                SELECT Id
                FROM Resource__c
                WHERE Name = 'Resource RC'
                LIMIT 1
            ];

            Test.startTest();
            List<Date> bookedDates = ResourceController.getBookedDates(res.Id);
            Test.stopTest();

            Assert.isNotNull(bookedDates, 'getBookedDates should return a non-null list');
            Assert.isTrue(bookedDates.size() > 0, 'getBookedDates should return booked dates for the given resource');
        }
    }
}
