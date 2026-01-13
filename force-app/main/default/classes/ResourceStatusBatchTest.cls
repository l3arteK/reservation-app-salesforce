@IsTest
private class ResourceStatusBatchTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            Resource__c freeWithReservation = TestHelper.createResource('Free With Reservation', 'Free');
            Resource__c inUseWithoutReservation = TestHelper.createResource('In Use Without Reservation', 'In use');
            Resource__c freeWithoutReservation = TestHelper.createResource('Free Without Reservation', 'Free');

            Contact c = TestHelper.createContact('Batch', 'batch@test.pl');

            TestHelper.createReservation(c.Id, freeWithReservation.Id, Date.today().addDays(-1), Date.today().addDays(1));
        }
    }

    @IsTest
    static void testResourceStatusBatch_withServiceLogic() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Database.executeBatch(new ResourceStatusBatch(), 50);
            Test.stopTest();

            Map<String, Resource__c> resourcesByName = new Map<String, Resource__c>();
            for (Resource__c res : [SELECT Name, Status__c FROM Resource__c]) {
                resourcesByName.put(res.Name, res);
            }

            Assert.areEqual(
                'In use',
                resourcesByName.get('Free With Reservation').Status__c,
                'Resource with status "Free" and an active reservation should be updated to "In use"'
            );

            Assert.areEqual(
                'Free',
                resourcesByName.get('In Use Without Reservation').Status__c,
                'Resource with status "In use" and no active reservation should be updated to "Free"'
            );

            Assert.areEqual(
                'Free',
                resourcesByName.get('Free Without Reservation').Status__c,
                'Resource with status "Free" and no active reservation should remain "Free"'
            );
        }
    }
}
