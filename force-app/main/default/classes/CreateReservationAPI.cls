@RestResource(urlMapping='/ReservationService/*')
global with sharing class CreateReservationAPI {
    
    @HttpPost
    global static ID createReservation(String email, String lastName) {
        
        Contact con = new Contact(
            Email = email,
            LastName = lastName
        );
    

        upsert con Email;
        return con.Id;
        
        // // 2. Tworzenie rezerwacji
        // Reservation__c res = new Reservation__c(
        //     Contact__c = con.Id,
        //     Resource__c = resourceId,
        //     Start_Time__c = DateTime.valueOf(startDt.replace('T', ' ')),
        //     End_Time__c = DateTime.valueOf(endDt.replace('T', ' '))
        // );
        
        // insert res; // Tutaj odpali się Twój Trigger sprawdzający kolizje!
        // return res.Id;
    }
}