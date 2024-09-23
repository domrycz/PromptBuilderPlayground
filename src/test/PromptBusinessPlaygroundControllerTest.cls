@IsTest
private class PromptBusinessPlaygroundControllerTest {
    private static String TEST_CASE_SUBJECT = 'Problem with Service';

    @TestSetup
    private static void setup() {
        Case caseRecord = new Case(Subject = TEST_CASE_SUBJECT, Origin = 'Email', Type = 'Problem');
        insert caseRecord;

        EmailMessage email = new EmailMessage(
                Subject = 'Problem with Service',
                ParentId = caseRecord.Id,
                FromAddress = 'from@example.com',
                ToAddress = 'support@example.com',
                TextBody = 'This is a test email body');
        insert email;
    }

    @IsTest
    private static void getModelResponse_mockedResponseReturned() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        String response = PromptBusinessPlaygroundController.getModelResponse(
                caseRecord.Id, 'Full', 'Give me a brief summary of this Case:');

        Assert.isFalse(String.isBlank(response));
    }

    @IsTest
    private static void getModelResponse_contextTooBig() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        EmailMessage longEmail = new EmailMessage(
                Subject = 'Problem with Service',
                ParentId = caseRecord.Id,
                FromAddress = 'from@example.com',
                ToAddress = 'support@example.com',
                TextBody = 'X'.repeat(122000));
        insert longEmail;

        String response;
        Boolean hasException = false;

        try {
            response = PromptBusinessPlaygroundController.getModelResponse(
                caseRecord.Id, 'Full', 'Give me a brief summary of this Case:');
        } catch (AuraHandledException ex) {
            hasException = true;
        }

        Assert.isFalse(hasException);
        Assert.isFalse(String.isBlank(response));
        Assert.isTrue(response.contains('Context is too big'));
    }
}