trigger reservationTrigger on Reservation__c(before insert) {
    ReservationTriggerHandler.handleBeforeInsert(Trigger.new);

}
