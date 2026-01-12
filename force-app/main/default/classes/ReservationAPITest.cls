@isTest
private class ReservationAPITest {
    @isTest
    static void testCreateReservationSuccess() {
        Resource__c testResource = new Resource__c(Name = 'Test Room', Type__c = 'Room');
        insert testResource;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ReservationService/';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ReservationAPI.createReservation('test@example.com', 'Kowalski', testResource.Id, '2026-02-01', '2026-02-05');
        Test.stopTest();

        Assert.areEqual(200, res.statusCode, 'Status code should be 200 for successful reservation creation');
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areEqual(true, responseMap.get('success'), 'The response success property should be true');
    }

    @isTest
    static void testCreateReservationDmlError() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ReservationService/';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ReservationAPI.createReservation('test@example.com', 'Kowalski', null, '2026-02-01', '2026-02-05');
        Test.stopTest();

        Assert.areEqual(400, res.statusCode, 'Status code should be 400 when resourceId is missing');
    }

    @isTest
    static void testGetReservationsSuccess() {
        Contact testContact = new Contact(LastName = 'Kowalski', Email = 'test@example.com');
        insert testContact;

        Resource__c testResource = new Resource__c(Name = 'Test Room', Type__c = 'Room');
        insert testResource;

        insert new Reservation__c(
            Contact__c = testContact.Id,
            Resource__c = testResource.Id,
            Start_date__c = Date.today(),
            End_date__c = Date.today().addDays(1)
        );

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ReservationService/';
        req.httpMethod = 'GET';
        req.addParameter('email', 'test@example.com');
        req.addParameter('lastName', 'Kowalski');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ReservationAPI.getReservations();
        Test.stopTest();

        Assert.areEqual(200, res.statusCode, 'Status code should be 200 for successful GET request');
        String responseJson = res.responseBody.toString();
        Assert.isTrue(responseJson.contains('Kowalski'), 'The response should contain the last name');
    }

    @isTest
    static void testGetReservationsMissingParams() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/ReservationService/';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ReservationAPI.getReservations();
        Test.stopTest();

        Assert.areEqual(400, res.statusCode, 'Status code should be 400 when required GET parameters are missing');
    }
}
