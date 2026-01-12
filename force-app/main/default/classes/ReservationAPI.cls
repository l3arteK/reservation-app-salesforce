@RestResource(urlMapping='/ReservationService/*')
global with sharing class ReservationAPI {
    @HttpPost
    global static void createReservation(String email, String lastName, String resourceId, String startDt, String endDt) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        ApiResponse response;

        try {
            Id reservationId = CreateReservationService.createReservation(
                lastName,
                email,
                (Id) resourceId,
                Date.valueOf(startDt),
                Date.valueOf(endDt)
            );

            res.statusCode = 200;
            response = new ApiResponse(new Map<String, String>{ 'reservationId' => reservationId });
        } catch (DmlException e) {
            res.statusCode = 400;
            String salesforceErrorCode = String.valueOf(e.getDmlType(0));
            String errorMessage = e.getDmlMessage(0);

            response = new ApiResponse(salesforceErrorCode, errorMessage);
        } catch (Exception e) {
            res.statusCode = 500;
            String exceptionType = e.getTypeName();
            response = new ApiResponse(exceptionType, e.getMessage());
        }

        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    @HttpGet
    global static void getReservations() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        res.addHeader('Content-Type', 'application/json');
        ApiResponse response;

        String email = req.params.get('email');
        String lastName = req.params.get('lastName');

        try {
            if (email == null || lastName == null) {
                res.statusCode = 400;
                response = new ApiResponse('BadRequest', 'Both email and lastName parameters are required.');
                return;
            }
            List<Reservation__c> reservations = CreateReservationService.getReservations(email, lastName);
            res.statusCode = 200;
            response = new ApiResponse(reservations);
        } catch (Exception e) {
            res.statusCode = 500;
            String exceptionType = e.getTypeName();
            response = new ApiResponse(exceptionType, e.getMessage());
        } finally {
            res.responseBody = Blob.valueOf(JSON.serialize(response));
        }
    }

    public class ApiResponse {
        public Boolean success;
        public Object data;
        public List<ApiError> errors;

        public ApiResponse(Object data) {
            this.success = true;
            this.data = data;
            this.errors = new List<ApiError>();
        }

        public ApiResponse(String code, String message) {
            this.success = false;
            this.errors = new List<ApiError>{ new ApiError(code, message) };
        }
    }

    public class ApiError {
        public String errorCode;
        public String message;
        public ApiError(String code, String msg) {
            this.errorCode = code;
            this.message = msg;
        }
    }
}
