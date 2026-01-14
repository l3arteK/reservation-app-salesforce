public without sharing class ExperienceSiteController {
    @AuraEnabled(cacheable=true)
    public static Id getContact(String lastName, String email) {
        try {
            return ReservationService.getContact(lastName, email);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, System.Label.EXPERIENCE_SITE_ERROR_CONTACT_RETRIEVAL + ': ' + e.getMessage());
            throw new AuraHandledException(System.Label.EXPERIENCE_SITE_ERROR_CONTACT_RETRIEVAL);
        }
    }
}
