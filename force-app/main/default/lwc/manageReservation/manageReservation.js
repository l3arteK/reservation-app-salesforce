import getReservations from "@salesforce/apex/ManageReservationController.getReservations";
import deleteReservation from "@salesforce/apex/ManageReservationController.deleteReservation";
import { LightningElement, api, wire } from "lwc";
import LightningConfirm from "lightning/confirm";
import { refreshApex } from "@salesforce/apex";

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
    @api contactProvided;
    reservations = [];
    columns = columns;
    wiredReservationsResult;

    @wire(getReservations, { contactId: "$contactId" })
    wiredReservations(result) {
        this.wiredReservationsResult = result;
        const { data, error } = result;
        if (data) {
            this.reservations = data.map((reservation) => ({
                Id: reservation.Id,
                Start_date__c: reservation.Start_date__c,
                End_date__c: reservation.End_date__c,
                ResourceName: reservation.Resource__r.Name,
                ResourceId: reservation.Resource__c
            }));
        } else if (error) {
            console.error("Error fetching reservations:", error);
        }
    }

    handleRefresh() {
        return refreshApex(this.wiredReservationsResult);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === "edit") {
            this.handleEdit(row);
        } else if (actionName === "delete") {
            this.handleDelete(row);
        }
    }

    handleEdit(row) {
        this.dispatchEvent(
            new CustomEvent("editreservation", {
                detail: row
            })
        );
    }

    handleDelete(row) {
        LightningConfirm.open({
            message:
                "Are you sure you want to delete " +
                row.ResourceName +
                " from " +
                row.Start_date__c +
                " to " +
                row.End_date__c +
                " reservation? ",

            variant: "header",
            theme: "warning",
            label: "Confirm Deletion"
        }).then((result) => {
            if (result) {
                deleteReservation({ reservationId: row.Id })
                    .then(() => {
                        this.handleRefresh();
                    })
                    .catch((error) => {
                        console.error("Error deleting reservation: ", error);
                    });
            }
        });
    }
}
