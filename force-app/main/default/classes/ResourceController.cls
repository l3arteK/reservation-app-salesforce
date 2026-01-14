public with sharing class ResourceController {
    @AuraEnabled(cacheable=true)
    public static List<Date> getBookedDates(Id resourceId) {
        try {
            return ReservationService.getBookedDates(resourceId);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.RESOURCE_ERROR_BOOKED_DATES_RETRIEVAL + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.RESOURCE_ERROR_BOOKED_DATES_RETRIEVAL);
        }
    }
}
