import getContact from "@salesforce/apex/ExperienceSiteController.getContact";
import { LightningElement } from "lwc";

export default class ExperienceSiteComponent extends LightningElement {
    lastName;
    email;

    handleChange(event) {
        const { name, value } = event.target;
        this[name] = value;
    }
    handleSearch() {
        getContact({ lastName: this.lastName, email: this.email }).then((contact) => {
            console.log("Retrieved contact: ", JSON.stringify(contact));
            const manageReservationComponent = this.template.querySelector("c-manage-reservation");
            manageReservationComponent.contactId = contact;
        });
    }
}
