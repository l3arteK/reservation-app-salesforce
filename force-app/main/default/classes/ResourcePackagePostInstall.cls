global class ResourcePackagePostInstall implements InstallHandler {
    global void onInstall(InstallContext context) {
        if (!isJobScheduled()) {
            System.schedule('Resource Status Daily Update', '0 5 0 * * ?', new ResourceStatusScheduler());
        }
    }

    private static Boolean isJobScheduled() {
        return [
                SELECT COUNT()
                FROM CronTrigger
                WHERE CronJobDetail.Name = 'Resource Status Daily Update'
            ] > 0;
    }
}