@RestResource(urlMapping='/ReservationService/*')
global with sharing class CreateReservationAPI {
    @HttpPost
    global static ID createReservation(String email, String lastName, String resourceId, String startDt, String endDt) {
        Contact con = new Contact(Email = email, LastName = lastName);

        upsert con Email;

        Reservation__c res = new Reservation__c(
            Contact__c = con.Id,
            Resource__c = resourceId,
            Start_date__c = Date.valueOf(startDt),
            End_date__c = Date.valueOf(endDt)
        );

        insert res;
        return res.Id;
    }
}