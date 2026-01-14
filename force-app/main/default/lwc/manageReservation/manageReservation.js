import getReservations from "@salesforce/apex/ManageReservationController.getReservations";
import deleteReservation from "@salesforce/apex/ManageReservationController.deleteReservation";
import { LightningElement, api, wire } from "lwc";
import LightningConfirm from "lightning/confirm";
import { refreshApex } from "@salesforce/apex";
import { reduceErrors } from "c/reduceErrors/reduceErrors";
import labels from "./labels";

const actions = [
    { label: labels.EDIT, name: "edit", iconName: "utility:edit" },
    { label: labels.DELETE, name: "delete", iconName: "utility:delete" }
];

const columns = [
    { label: labels.RESOURCE, fieldName: "ResourceName" },
    { label: labels.START_DATE, fieldName: "Start_date__c", type: "date" },
    { label: labels.END_DATE, fieldName: "End_date__c", type: "date" },
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
    labels = labels;

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
            console.error(reduceErrors(error));
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
            message: labels.RESERVATION_CONFIRMATION_MESSAGE.replace("{0}", row.ResourceName)
                .replace("{1}", row.Start_date__c)
                .replace("{2}", row.End_date__c),

            variant: "header",
            theme: "warning",
            label: labels.CONFIRM_DELETION
        }).then((result) => {
            if (result) {
                deleteReservation({ reservationId: row.Id })
                    .then(() => {
                        this.handleRefresh();
                    })
                    .catch((error) => {
                        console.error(reduceErrors(error));
                    });
            }
        });
    }
}
