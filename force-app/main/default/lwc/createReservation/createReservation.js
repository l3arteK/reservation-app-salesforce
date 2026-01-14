import { LightningElement, wire, api } from "lwc";
import getResources from "@salesforce/apex/CreateReservationController.getResources";
import createReservation from "@salesforce/apex/CreateReservationController.createReservation";
import getBookedDates from "@salesforce/apex/CreateReservationController.getBookedDates";
import updateReservation from "@salesforce/apex/CreateReservationController.updateReservation";
import { reduceErrors } from "c/reduceErrors/reduceErrors";
import labels from "./labels.js";

export default class CreateReservation extends LightningElement {
    @api lastName;
    @api email;
    @api contactProvided;

    startDate;
    endDate;
    message;
    messageVariant;
    resources;
    resource;
    isSubmitting = false;
    subscription = null;
    isEditMode = false;
    reservationId;
    labels = labels;

    get disabled() {
        return !this.contactProvided;
    }

    @api
    set initialData(value) {
        if (value) {
            this.reservationId = value.Id;
            this.resource = value.ResourceId;
            this.startDate = value.Start_date__c;
            this.endDate = value.End_date__c;
            this.isEditMode = true;
        } else {
            this.isEditMode = false;
            this.reservationId = null;
            this.resource = null;
            this.startDate = null;
            this.endDate = null;
        }
    }

    get initialData() {
        return null;
    }

    @wire(getResources)
    wireResources({ error, data }) {
        if (data) {
            this.resources = data;
        } else if (error) {
            this.showBanner(reduceErrors(error), "error");
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
                    this.showBanner(reduceErrors(error), "error");
                });
        }
    }

    handleDateChange(event) {
        const { startDate, endDate } = event.detail;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    async handleSubmit() {
        if (!this.validateForm()) {
            this.showBanner(labels.PLEASE_CORRECT_ERRORS_ON_FORM, "error");
            return;
        }

        const action = this.isEditMode ? updateReservation : createReservation;
        const params = {
            resourceId: this.resource,
            startDate: this.startDate,
            endDate: this.endDate,
            ...(this.isEditMode ? { reservationId: this.reservationId } : { lastName: this.lastName, email: this.email })
        };

        this.isSubmitting = true;
        try {
            await action(params);
            this.resetForm();
            this.showBanner(this.isEditMode ? labels.RESERVATION_UPDATED_SUCCESSFULLY : labels.RESERVATION_CREATED_SUCCESSFULLY, "success");
        } catch (error) {
            this.showBanner(reduceErrors(error), "error");
        } finally {
            this.isSubmitting = false;
        }
    }

    showBanner(message, variant) {
        this.message = message;
        this.messageVariant = variant;
    }

    handleReset() {
        this.resetForm();
    }

    resetForm() {
        this.template.querySelectorAll("lightning-input, lightning-combobox").forEach((el) => {
            el.value = null;
        });
        this.template.querySelector("c-custom-date-picker").reset();
        this.showBanner(null, null);
    }

    get messageClass() {
        return this.messageVariant === "success"
            ? "slds-notify slds-notify_alert slds-theme_success"
            : "slds-notify slds-notify_alert slds-theme_error";
    }

    get submitButtonLabel() {
        return this.isEditMode ? labels.UPDATE_RESERVATION : labels.CREATE_RESERVATION;
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
}
