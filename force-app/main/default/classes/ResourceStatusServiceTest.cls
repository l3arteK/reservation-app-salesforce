@IsTest
private class ResourceStatusServiceTest {
    @IsTest
    static void testUpdateStatuses_BookedToInUse_And_InUseToFree() {
        Contact c = new Contact(LastName = 'Test Contact');
        insert c;

        Resource__c bookedResource = new Resource__c(Name = 'Booked Resource', Status__c = 'Free', Type__c = 'Room');
        Resource__c inUseResource = new Resource__c(Name = 'In Use Resource', Status__c = 'In use', Type__c = 'Room');

        insert new List<Resource__c>{ bookedResource, inUseResource };
        Reservation__c activeReservation = new Reservation__c(
            Contact__c = c.Id,
            Resource__c = bookedResource.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(1)
        );

        Reservation__c pastReservation = new Reservation__c(
            Contact__c = c.Id,
            Resource__c = inUseResource.Id,
            Start_Date__c = Date.today().addDays(-3),
            End_Date__c = Date.today().addDays(-1)
        );

        insert new List<Reservation__c>{ activeReservation, pastReservation };

        Test.startTest();
        ResourceStatusService.updateResourceStatuses();
        Test.stopTest();

        Map<Id, Resource__c> resources = new Map<Id, Resource__c>(
            [
                SELECT Status__c
                FROM Resource__c
                WHERE Id IN :new List<Id>{ bookedResource.Id, inUseResource.Id }
            ]
        );

        Assert.areEqual('In use', resources.get(bookedResource.Id).Status__c, 'Booked resource with active reservation should be In Use');

        Assert.areEqual('Free', resources.get(inUseResource.Id).Status__c, 'In Use resource without active reservation should be Free');
    }
}
