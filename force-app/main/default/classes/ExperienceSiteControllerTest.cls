@IsTest
private class ExperienceSiteControllerTest {
    @TestSetup
    static void setupData() {
        System.runAs(TestHelper.createAdminUser()) {
            TestHelper.createContact('Existing', 'existing@test.pl');
        }
    }

    @IsTest
    static void testGetContact_existingContact() {
        System.runAs(TestHelper.getAdminUser()) {
            Test.startTest();
            Id contactId = ExperienceSiteController.getContact('Existing', 'existing@test.pl');
            Test.stopTest();

            Assert.isNotNull(contactId, 'getContact should return Contact Id when a matching contact exists');
        }
    }
}
