@IsTest
private class ResourceStatusServiceTest {
    @IsTest
    static void testUpdateStatuses() {
        Resource__c r = new Resource__c(Name = 'Test', Status__c = 'Booked', Type__c = 'Room');
        Contact c = new Contact(LastName = 'Test Contact');
        insert c;
        insert r;

        Reservation__c res = new Reservation__c(
            Contact__c = c.Id,
            Resource__c = r.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1)
        );
        insert res;

        Test.startTest();
        ResourceStatusService.updateResourceStatuses();
        Test.stopTest();

        r = [SELECT Status__c FROM Resource__c WHERE Id = :r.Id];
        System.assertEquals('In use', r.Status__c);
    }
}
