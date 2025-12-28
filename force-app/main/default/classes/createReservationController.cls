public with sharing class createReservationController {
    @AuraEnabled(cacheable=true)
    public static Id getContact(String lastName, String email) {
        try {
            return [SELECT Id, lastName, Email FROM Contact WHERE Email = :email AND lastName = :lastName LIMIT 1].Id;
        } catch (QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                return null;
            } else {
                throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving contact: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<createReservationHelper.Option> getResources() {
        try {
            List<createReservationHelper.Option> options = new List<createReservationHelper.Option>();
            for (Resource__c res : [SELECT Id, Name FROM Resource__c WHERE Status__c = 'Free']) {
                options.add(new createReservationHelper.Option(res.Name, res.Id));
            }

            return options;
        } catch (QueryException e) {
            if (e.getMessage().contains('List has no rows for assignment to SObject')) {
                return new List<createReservationHelper.Option>();
            } else {
                throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving resources: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static string methodName() {
        try {
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
