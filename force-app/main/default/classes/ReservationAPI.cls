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
    global static void getResources() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        ApiResponse response;

        try {
            List<Resource__c> resources = CreateReservationService.getResources();
            res.statusCode = 200;
            response = new ApiResponse(resources);
        } catch (Exception e) {
            res.statusCode = 500;
            String exceptionType = e.getTypeName();
            response = new ApiResponse(exceptionType, e.getMessage());
        }

        res.responseBody = Blob.valueOf(JSON.serialize(response));
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
