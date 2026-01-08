public inherited sharing class ReservationHelper {
    public static List<Date> getBookedDates(Id resourceId) {
        List<Date> bookedDates = new List<Date>();
        for (Reservation__c res : [
            SELECT Start_date__c, End_date__c
            FROM Reservation__c
            WHERE Resource__c = :resourceId AND End_date__c >= TODAY
        ]) {
            Date currentDate = res.Start_date__c;
            while (currentDate <= res.End_date__c) {
                bookedDates.add(currentDate);
                currentDate = currentDate.addDays(1);
            }
        }
        return bookedDates;
    }
}
