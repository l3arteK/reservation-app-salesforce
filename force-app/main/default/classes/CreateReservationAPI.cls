@RestResource(urlMapping='/ReservationService/*')
global with sharing class CreateReservationAPI {
    
    @HttpPost
    global static ID createReservation(String email, String lastName, String resourceId, String startDt, String endDt) {
        
        Contact con = new Contact(
            Email = email,
            LastName = lastName
        );
    

        upsert con Email;
        
        Reservation__c res = new Reservation__c(
            Contact__c = con.Id,
            Resource__c = resourceId,
            Start_Time__c = DateTime.valueOf(startDt.replace('T', ' ')),
            End_Time__c = DateTime.valueOf(endDt.replace('T', ' '))
        );
        
        insert res; 
        return res.Id;
    }
}