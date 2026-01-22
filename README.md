## About the app

Reservation Manager is a lightweight Salesforce package for booking and managing resources (rooms, equipment) with time‑slot availability, both for internal users and Experience Cloud portal.

Key features

- Custom objects: `Resource__c`, `Reservation__c`, with ready layouts, list views and date validations.
- LWC UI: createReservation and manageReservation with a custom date picker and friendly error handling.
- Experience Cloud ready: components and controllers to expose booking externally.
- Business logic: Apex services and controllers; trigger handler on `Reservation__c` to keep logic consistent.
- Automation: Scheduler + Batch to keep resource statuses up to date.
- Integration: ReservationAPI for programmatic access.
- Security: Permission sets (RM_Administrator, RM_Guest_User) and post‑install script.

Architecture (short)

- UI: LWC (SLDS‑aligned).
- Logic: Apex services, controllers, trigger handler.
- Automation: Batch + Scheduler.
- Config: Metadata (objects, layouts, labels, flexipage), permission sets, tests.

## How to Get Started

1. Install the package from the link below
2. Assign the `RM_Administrator` permission set to your admin user
3. Configure your resources and availability settings
4. Customize the LWC components or Experience Cloud pages as needed

[Install Package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tg50000001GltAAE)

## Tech Stack Overview

- **Frontend**: Lightning Web Components (LWC) with SLDS styling
- **Backend**: Apex (services, controllers, triggers)
- **Automation**: Batch Apex, Schedulable Apex
- **Integration**: REST API endpoint (ReservationAPI)
- **Security**: Permission Sets, Field-Level Security
- **Testing**: Comprehensive unit tests for all layers
- **Deployment**: Salesforce DX project structure

## Visual Overview

### Application Screenshots

Below are some screenshots demonstrating the core functionality of the Reservation Manager application:

#### Creating a new reservation
![Creating a new reservation](https://github.com/user-attachments/assets/83426ae4-61a8-4f2c-92ce-cfa4d4e9e66e)

#### Managing users’ existing reservations

![Managing users’ existing reservations](https://github.com/user-attachments/assets/0c2d9136-2202-4b7f-8ce6-426f01d0293e)

#### Custom date picker with the ability to block chosen dates
![Custom date picker with blocked dates](https://github.com/user-attachments/assets/a8b33057-066f-4a79-9029-57998bd9b1e7)

#### Managing existing reservations
![Managing existing reservations](https://github.com/user-attachments/assets/20094ef9-295f-43d1-8ad1-995fecff84fa)

#### Managing existing resources
![Managing existing resources](https://github.com/user-attachments/assets/0a338b2c-990f-4bc5-a195-8153be3b30ee)

#### Resource record type with a custom date picker preview of booked dates
![Resource record type with booked dates preview](https://github.com/user-attachments/assets/a35b5286-0e32-4048-a487-b0498d453005)



### UML Diagram - Custom Objects Structure

The following UML diagram illustrates the core custom objects and their relationships:

#### Object structure
![UML Diagram](https://github.com/user-attachments/assets/4b7c37aa-57cf-412f-910f-5ff57ba32b6b)





