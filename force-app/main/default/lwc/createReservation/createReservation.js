import { LightningElement, track, wire } from "lwc";
import getContact from "@salesforce/apex/createReservationController.getContact";
import getResources from "@salesforce/apex/createReservationController.getResources";
import createReservation from "@salesforce/apex/createReservationController.createReservation";
import getBookedDates from "@salesforce/apex/createReservationController.getBookedDates";

export default class CreateReservation extends LightningElement {
    @track isSubmitting = false;
    contactId;
    lastName;
    email;
    startDate;
    endDate;
    message;
    messageVariant;
    resources;
    resource;

    @wire(getResources)
    wireResources({ error, data }) {
        if (data) {
            this.resources = data;
        } else if (error) {
            console.error("Error retrieving resources: ", error);
        }
    }

    handleSearchContact() {
        if (this.lastName && this.email) {
            getContact({ lastName: this.lastName, email: this.email })
                .then((result) => {
                    if (result) {
                        this.contactId = result;
                        this.showBanner("Contact found.", "success");
                    } else {
                        this.showBanner("No contact found with the provided details.", "error");
                    }
                })
                .catch((error) => {
                    this.showBanner("An error occurred. Error details: " + error, "error");
                });
        }
    }
    handleChange(event) {
        const { name, value } = event.target;
        this[name] = value;
        if (name === "resource") {
            getBookedDates({ resourceId: value })
                .then((dates) => {
                    const datePicker = this.template.querySelector("c-custom-date-picker");
                    if (datePicker) {
                        datePicker.disabledDates = dates;
                    }
                })
                .catch((error) => {
                    console.error("Error retrieving booked dates: ", error);
                });
        }
    }

    handleDateChange(event) {
        const { startDate, endDate } = event.detail;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    handleSubmit() {
        if (!this.validateForm()) {
            this.showBanner("Please correct the errors on the form.", "error");
        } else {
            createReservation({
                contactId: this.contactId,
                resourceId: this.resource,
                startDate: this.startDate,
                endDate: this.endDate
            })
                .then(() => {
                    this.resetForm();
                    this.showBanner("Reservation created successfully.", "success");
                })
                .catch((error) => {
                    this.showBanner(error.body.message, "error");
                });
        }
    }

    showBanner(message, variant) {
        this.message = message;
        this.messageVariant = variant;
    }

    handleReset() {
        this.resetForm();
        this.contactId = null;
    }

    resetForm() {
        this.template.querySelectorAll("lightning-input, lightning-combobox").forEach((el) => {
            el.value = null;
        });
        this.showBanner(null, null);
    }

    get messageClass() {
        return this.messageVariant === "success"
            ? "slds-notify slds-notify_alert slds-theme_success"
            : "slds-notify slds-notify_alert slds-theme_error";
    }

    validateForm() {
        let isValid = true;

        this.template.querySelectorAll("lightning-input, lightning-combobox, c-custom-date-picker").forEach((el) => {
            if (!el.checkValidity()) {
                el.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    get searchContactDisabled() {
        return this.contactId !== undefined && this.contactId !== null;
    }
}
