@isTest
public class ReservationTriggerHandlerTest {
    @TestSetup
    static void setup() {
        System.runAs(TestHelper.createAdminUser()) {
            insert new List<Resource__c>{
                new Resource__c(Name = 'RoomResource', Type__c = 'Room'),
                new Resource__c(Name = 'EquipmentResource', Type__c = 'Equipment')
            };

            TestHelper.createContact('lastName', 'example@email.com');
        }
    }

    @isTest
    static void shouldPopulateNameOnInsert() {
        System.runAs(TestHelper.getAdminUser()) {
            Contact con = [SELECT Id, Name FROM Contact LIMIT 1];
            Resource__c res = [SELECT Id, Name FROM Resource__c WHERE Name = 'RoomResource' LIMIT 1];

            Reservation__c newReservation = new Reservation__c(
                Contact__c = con.Id,
                Resource__c = res.Id,
                Start_date__c = Date.today(),
                End_date__c = Date.today().addDays(2)
            );
            Test.startTest();

            insert newReservation;

            Test.stopTest();

            Reservation__c updatedRes = [SELECT Name FROM Reservation__c WHERE Id = :newReservation.Id];

            Assert.isTrue(updatedRes.Name.contains('lastName'), 'Name should contain Contact Name');
            Assert.isTrue(updatedRes.Name.contains('RoomResource'), 'Name should contain Resource Name');
        }
    }
}