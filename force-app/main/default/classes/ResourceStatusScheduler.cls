global class ResourceStatusScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ResourceStatusService.updateResourceStatuses();
    }
}
