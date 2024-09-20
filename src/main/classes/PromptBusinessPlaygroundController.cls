public with sharing class PromptBusinessPlaygroundController {
    private static final Integer DEFAULT_MAX_CONTEXT_LENGTH = 122000;

    @AuraEnabled
    public static String getModelResponse(Id caseId, String contextType, String userPrompt) {
        String response = '';

        try {
            Integer caseContextLength =
                    new ContextBuilder().getContextLength(caseId, ContextBuilder.ContextType.valueOf(contextType));

            if(caseContextLength > DEFAULT_MAX_CONTEXT_LENGTH) {
                return 'Context length: ' + caseContextLength + ' characters.\n' +
                        'Case Context is too big for this action.';
            }

            response = new PromptResolverService().getModelResponse(caseId, contextType, userPrompt);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        return response;
    }
}