@IsTest
private class BusinessPlaygroundPromptActionTest {
    @IsTest
    private static void getCaseContextInvocable_requestProvided() {
        Case caseRecord = new Case(Subject = 'Problem with Service', Origin = 'Email', Type = 'Problem');
        insert caseRecord;

        BusinessPlaygroundPromptAction.Request request = new BusinessPlaygroundPromptAction.Request();
        request.ContextCase = caseRecord;
        request.ContextType = 'Full';
        request.UserPrompt = 'Give me summary of this Case';

        List<BusinessPlaygroundPromptAction.Response> response =
                BusinessPlaygroundPromptAction.getCaseContextInvocable(new List<BusinessPlaygroundPromptAction.Request>{request});

        Assert.isFalse(response.isEmpty());
        Assert.isNotNull(response[0].Prompt);
    }

    @IsTest
    private static void getCaseContextInvocable_requestEmpty() {
        List<BusinessPlaygroundPromptAction.Response> response =
                BusinessPlaygroundPromptAction.getCaseContextInvocable(new List<BusinessPlaygroundPromptAction.Request>());

        Assert.isNull(response);
    }
}