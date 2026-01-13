import getContact from "@salesforce/apex/ExperienceSiteController.getContact";
import { LightningElement } from "lwc";

export default class ExperienceSiteComponent extends LightningElement {
    lastName;
    email;
    viewMode = "create";
    handleChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }
    handleSearch() {
        getContact({ lastName: this.lastName, email: this.email }).then((contact) => {
            const manageReservationComponent = this.template.querySelector("c-manage-reservation");
            manageReservationComponent.contactId = contact;
            manageReservationComponent.contactProvided = true;
            const createReservationComponent = this.template.querySelector("c-create-reservation");
            createReservationComponent.contactId = contact;
            createReservationComponent.contactProvided = true;
        });
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

    get NewReservationButtonClass() {
        const base = "custom-button slds-col slds-size_1-of-2 slds-align_absolute-center";
        return this.isCreateView ? base + " active-tab" : base;
    }

    get ManageReservationsButtonClass() {
        const base = "custom-button slds-col slds-size_1-of-2 slds-align_absolute-center";
        return this.isCreateView ? base : base + " active-tab";
    }
}
