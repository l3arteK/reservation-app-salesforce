public without sharing class ExperienceSiteController {
    @AuraEnabled(cacheable=true)
    public static Id getContact(String lastName, String email) {
        try {
            System.debug('Retrieving contact for email: ' + email + ' and lastName: ' + lastName);
            return ReservationService.getContact(lastName, email);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error during retrieval of contact: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
        }
    }
}
