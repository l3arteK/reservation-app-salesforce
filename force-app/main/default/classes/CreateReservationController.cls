public without sharing class CreateReservationController {
    @AuraEnabled(cacheable=true)
    public static List<ReservationService.Option> getResources() {
        try {
            List<ReservationService.Option> options = new List<ReservationService.Option>();
            for (Resource__c res : ReservationService.getResources()) {
                options.add(new ReservationService.Option(res.Name, res.Id));
            }
            return options;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.CREATE_RESERVATION_ERROR_RETRIEVE_RESOURCES + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.CREATE_RESERVATION_ERROR_RETRIEVE_RESOURCES);
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            return ReservationService.getBookedDates(resourceId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.CREATE_RESERVATION_ERROR_RETRIEVE_BOOKED_DATES + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.CREATE_RESERVATION_ERROR_RETRIEVE_BOOKED_DATES);
        }
    }

    @AuraEnabled
    public static void createReservation(String lastName, String email, Id resourceId, Date startDate, Date endDate) {
        try {
            ReservationService.createReservation(lastName, email, resourceId, startDate, endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.CREATE_RESERVATION_ERROR_CREATE_RESERVATION + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.CREATE_RESERVATION_ERROR_CREATE_RESERVATION);
        }
    }

    @AuraEnabled
    public static void updateReservation(Id reservationId, Id resourceId, Date startDate, Date endDate) {
        try {
            ReservationService.updateReservation(reservationId, resourceId, startDate, endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.CREATE_RESERVATION_ERROR_UPDATE_RESERVATION + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.CREATE_RESERVATION_ERROR_UPDATE_RESERVATION);
        }
    }
}
