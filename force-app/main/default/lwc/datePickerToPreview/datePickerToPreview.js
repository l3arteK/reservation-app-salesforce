import { LightningElement, api, wire } from "lwc";
import getBookedDates from "@salesforce/apex/ResourceController.getBookedDates";

export default class DatePickerToPreview extends LightningElement {
    @api recordId;
    bookedDates = [];
    @wire(getBookedDates, { resourceId: "$recordId" })
    wiredBookedDates({ error, data }) {
        if (data) {
            this.bookedDates = data;
        } else if (error) {
            console.error("Error fetching booked dates:", error);
        }
    }
}
