public with sharing class ResourceController {
    @AuraEnabled(cacheable=true)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            return ReservationHelper.getBookedDates(resourceId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of booked dates: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving booked dates: ' + e.getMessage());
        }
    }
}
