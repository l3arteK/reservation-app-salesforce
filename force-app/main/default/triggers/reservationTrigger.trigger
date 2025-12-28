trigger reservationTrigger on Reservation__c(before insert, after insert) {
    if (Trigger.isBefore) {
        ReservationTriggerHandler.handleBeforeInsert(Trigger.new);
    } else if (Trigger.isAfter) {
        ReservationTriggerHandler.handleAfterInsert(Trigger.new);
    }

}
