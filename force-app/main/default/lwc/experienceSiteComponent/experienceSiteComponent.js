import getContact from "@salesforce/apex/ExperienceSiteController.getContact";
import { LightningElement } from "lwc";
import labels from "./labels";

export default class ExperienceSiteComponent extends LightningElement {
    lastName;
    email;
    viewMode = "create";
    contactId;
    contactProvided = false;
    initialData;
    labels = labels;

    handleChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }
    handleConfirm() {
        getContact({ lastName: this.lastName, email: this.email }).then((contact) => {
            this.contactId = contact;
            this.contactProvided = true;
        });
    }

    handleResetContact() {
        this.contactId = null;
        this.contactProvided = false;
        this.lastName = null;
        this.email = null;
        this.initialData = null;
    }

    get isCreateView() {
        return this.viewMode === "create";
    }

    showCreateView(event) {
        this.viewMode = "create";
        event.target.blur();
    }

    showManageView(event) {
        this.viewMode = "manage";
        event.target.blur();
    }
    handleEditReservation(event) {
        this.viewMode = "create";
        this.initialData = event.detail;
    }

    get NewReservationButtonClass() {
        const base = "custom-button slds-col slds-size_1-of-2 slds-align_absolute-center";
        return this.isCreateView ? base + " active-tab" : base;
    }

    get ManageReservationsButtonClass() {
        const base = "custom-button slds-col slds-size_1-of-2 slds-align_absolute-center";
        return this.isCreateView ? base : base + " active-tab";
    }
}
