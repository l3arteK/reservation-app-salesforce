global class ResourceStatusScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new ResourceStatusBatch());
    }
}
