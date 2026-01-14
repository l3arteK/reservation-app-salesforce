public without sharing class ManageReservationController {
    @AuraEnabled(cacheable=true)
    public static List<Reservation__c> getReservations(Id contactId) {
        if (contactId == null)
            return new List<Reservation__c>();
        try {
            return ReservationService.getReservations(contactId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.MANAGE_RESERVATION_ERROR_RETRIEVE_RESERVATIONS + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.MANAGE_RESERVATION_ERROR_RETRIEVE_RESERVATIONS);
        }
    }

    @AuraEnabled
    public static void deleteReservation(Id reservationId) {
        try {
            ReservationService.deleteReservation(reservationId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.MANAGE_RESERVATION_ERROR_DELETE_RESERVATION + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.MANAGE_RESERVATION_ERROR_DELETE_RESERVATION);
        }
    }
}
