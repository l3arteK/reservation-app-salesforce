public with sharing class createReservationHelper {
    public class Option {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }

        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
