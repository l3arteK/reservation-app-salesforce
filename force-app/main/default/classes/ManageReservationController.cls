public without sharing class ManageReservationController {
    @AuraEnabled(cacheable=true)
    public static List<Reservation__c> getReservations(Id contactId) {
        if (contactId == null)
            return new List<Reservation__c>();
        try {
            return ReservationService.getReservations(contactId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of reservations: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving reservations: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteReservation(Id reservationId) {
        try {
            ReservationService.deleteReservation(reservationId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during deletion of reservation: ' + e.getMessage());
            throw new AuraHandledException('Error deleting reservation: ' + e.getMessage());
        }
    }
}
