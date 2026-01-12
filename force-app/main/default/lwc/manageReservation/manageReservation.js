import getReservations from "@salesforce/apex/ManageReservationController.getReservations";
import deleteReservation from "@salesforce/apex/ManageReservationController.deleteReservation";
import { LightningElement, api, wire } from "lwc";

const actions = [
    { label: "Edit", name: "edit", iconName: "utility:edit" },
    { label: "Delete", name: "delete", iconName: "utility:delete" }
];

const columns = [
    { label: "Resource", fieldName: "ResourceName" },
    { label: "Start Date", fieldName: "Start_date__c", type: "date" },
    { label: "End Date", fieldName: "End_date__c", type: "date" },
    {
        type: "action",
        typeAttributes: { rowActions: actions }
    }
];

export default class ManageReservation extends LightningElement {
    @api contactId;
    reservations = [];
    columns = columns;

    @wire(getReservations, { contactId: "$contactId" })
    wiredReservations({ data, error }) {
        if (data) {
            this.reservations = data.map((reservation) => ({
                Id: reservation.Id,
                Start_date__c: reservation.Start_date__c,
                End_date__c: reservation.End_date__c,
                ResourceName: reservation.Resource__r.Name
            }));
        } else if (error) {
            console.error("Error fetching reservations:", error);
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.Id;

        if (actionName === "edit") {
            this.handleEdit(rowId);
        } else if (actionName === "delete") {
            this.handleDelete(rowId);
        }
    }

    handleEdit(rowId) {
        // Implement edit functionality here
        console.log("Editing reservation: ", rowId);
    }
    handleDelete(rowId) {
        console.log("Deleting reservation: ", rowId);
        deleteReservation({ reservationId: rowId })
            .then(() => {
                this.reservations = this.reservations.filter((reservation) => reservation.Id !== rowId);
            })
            .catch((error) => {
                console.error("Error deleting reservation: ", error);
            });
    }
}
