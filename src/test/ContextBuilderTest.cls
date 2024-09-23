@IsTest
private class ContextBuilderTest {
    private static final String TEST_CASE_SUBJECT = 'Problem with Service';
    private static final String TEST_OLD_EMAIL_BODY = 'I have a problem with my service';
    private static final String TEST_NEW_EMAIL_BODY = 'Please escalate this issue';

    @TestSetup
    private static void setup() {
        //JSON.deserialize workaround applied for setting CreatedDate (Test.setCreatedDate has a Known Issue)
        String threeDaysAgo = DateTime.now().addDays(-3).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        String caseJson = '{"createdDate" : "' + threeDaysAgo + '",' +
                '"subject" : "' + TEST_CASE_SUBJECT + '",' +
                '"origin" : "Email",' +
                '"type" : "Problem"' +
                '}';
        Case caseRecord = (Case) JSON.deserialize(caseJson, Case.class);
        insert caseRecord;

        String emailOldJson = '{"createdDate" : "' + threeDaysAgo + '",' +
                '"subject" : "Problem with Service",' +
                '"parentId" : "' + caseRecord.Id + '",' +
                '"fromAddress" : "from@example.com",' +
                '"toAddress" : "support@example.com",' +
                '"textBody" : "' + TEST_OLD_EMAIL_BODY + '"' +
                '}';
        EmailMessage emailOld = (EmailMessage) JSON.deserialize(emailOldJson, EmailMessage.class);

        EmailMessage emailNew = new EmailMessage(
                Subject = 'Problem with Service',
                ParentId = caseRecord.Id,
                FromAddress = 'from@example.com',
                ToAddress = 'support@example.com',
                TextBody = TEST_NEW_EMAIL_BODY);

        insert new List<EmailMessage>{emailOld, emailNew};
    }

    @IsTest
    private static void getCaseContext_fullContext() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        String context = new ContextBuilder().getCaseContext(caseRecord.Id, ContextBuilder.ContextType.Full);

        Assert.isFalse(String.isBlank(context));
        Assert.isTrue(context.contains(TEST_OLD_EMAIL_BODY));
        Assert.isTrue(context.contains(TEST_NEW_EMAIL_BODY));
    }

    @IsTest
    private static void getCaseContext_todayContext() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        String context = new ContextBuilder().getCaseContext(caseRecord.Id, ContextBuilder.ContextType.Today);

        Assert.isFalse(String.isBlank(context));
        Assert.isFalse(context.contains(TEST_OLD_EMAIL_BODY));
        Assert.isTrue(context.contains(TEST_NEW_EMAIL_BODY));
    }

    @IsTest
    private static void getContextLength_todayContext() {
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        Integer contextLength = new ContextBuilder().getContextLength(caseRecord.Id, ContextBuilder.ContextType.Today);

        Assert.isNotNull(contextLength);
        Assert.isTrue(contextLength > 0);
    }
}