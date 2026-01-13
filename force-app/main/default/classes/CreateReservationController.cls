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
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of resources: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            return ReservationService.getBookedDates(resourceId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of booked dates: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving booked dates: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createReservation(String lastName, String email, Id resourceId, Date startDate, Date endDate) {
        try {
            ReservationService.createReservation(lastName, email, resourceId, startDate, endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during creation of reservation: ' + e.getMessage());
            throw new AuraHandledException('An error occurred during creation of reservation: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateReservation(Id reservationId, Id resourceId, Date startDate, Date endDate) {
        try {
            ReservationService.updateReservation(reservationId, resourceId, startDate, endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during update of reservation: ' + e.getMessage());
            throw new AuraHandledException('An error occurred during update of reservation: ' + e.getMessage());
        }
    }
}
