public without sharing class CreateReservationController {
    @AuraEnabled(cacheable=true)
    public static List<CreateReservationHelper.Option> getResources() {
        try {
            return CreateReservationHelper.getResources();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of resources: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            return CreateReservationHelper.getBookedDates(resourceId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of booked dates: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving booked dates: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void createReservation(String lastName, String email, Id resourceId, Date startDate, Date endDate) {
        try {
            CreateReservationHelper.createReservation(lastName, email, resourceId, startDate, endDate);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during creation of reservation: ' + e.getMessage());
            throw new AuraHandledException('An error occurred during creation of reservation: ' + e.getMessage());
        }
    }
}
