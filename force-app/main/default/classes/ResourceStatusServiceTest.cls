@IsTest
private class ResourceStatusServiceTest {
    @TestSetup
    static void setupData() {
        List<Resource__c> resources = new List<Resource__c>{
            new Resource__c(Name = 'Free With Reservation', Status__c = 'Free', Type__c = 'Room'),
            new Resource__c(Name = 'In Use Without Reservation', Status__c = 'In use', Type__c = 'Room'),
            new Resource__c(Name = 'Free Without Reservation', Status__c = 'Free', Type__c = 'Room'),
            new Resource__c(Name = 'In Use With Reservation', Status__c = 'In use', Type__c = 'Room')
        };
        insert resources;

        Contact testContact = new Contact(LastName = 'Test User', Email = 'test@example.com');
        insert testContact;

        Date today = Date.today();

        List<Reservation__c> reservations = new List<Reservation__c>{
            new Reservation__c(
                Contact__c = testContact.Id,
                Resource__c = resources[0].Id,
                Start_Date__c = today.addDays(-1),
                End_Date__c = today.addDays(1)
            ),
            new Reservation__c(
                Contact__c = testContact.Id,
                Resource__c = resources[3].Id,
                Start_Date__c = today.addDays(-1),
                End_Date__c = today.addDays(1)
            )
        };
        insert reservations;
    }

    @IsTest
    static void testUpdateResourceStatuses() {
        List<Resource__c> resources = [
            SELECT Id, Status__c, Name
            FROM Resource__c
        ];

        Test.startTest();
        ResourceStatusService.updateResourceStatuses(resources);
        Test.stopTest();

        Map<String, Resource__c> resourcesByName = new Map<String, Resource__c>();
        for (Resource__c r : [
            SELECT Name, Status__c
            FROM Resource__c
        ]) {
            resourcesByName.put(r.Name, r);
        }

        Assert.areEqual('In use', resourcesByName.get('Free With Reservation').Status__c, 'Free + reservation should become In use');
        Assert.areEqual(
            'Free',
            resourcesByName.get('In Use Without Reservation').Status__c,
            'In use without reservation should become Free'
        );
        Assert.areEqual('Free', resourcesByName.get('Free Without Reservation').Status__c, 'Free without reservation should stay Free');
        Assert.areEqual('In use', resourcesByName.get('In Use With Reservation').Status__c, 'In use with reservation should stay In use');
    }

    @IsTest
    static void testProcessDirectly() {
        Resource__c r1 = new Resource__c(Name = 'Booked', Status__c = 'Free', Type__c = 'Room');
        Resource__c r2 = new Resource__c(Name = 'InUse', Status__c = 'In use', Type__c = 'Room');
        insert new List<Resource__c>{ r1, r2 };

        Test.startTest();
        ResourceStatusService.process(new List<Resource__c>{ r1 }, new List<Resource__c>{ r2 });
        Test.stopTest();

        Map<Id, Resource__c> refreshed = new Map<Id, Resource__c>(
            [SELECT Status__c FROM Resource__c WHERE Id IN :new List<Id>{ r1.Id, r2.Id }]
        );

        Assert.areEqual('In use', refreshed.get(r1.Id).Status__c, 'Booked resource should become In use');
        Assert.areEqual('Free', refreshed.get(r2.Id).Status__c, 'In use resource without reservation should become Free');
    }
}
