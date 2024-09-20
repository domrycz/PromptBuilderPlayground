public with sharing class PromptResolverService {
    private static final String PLAYGROUND_TEMPLATE_DEV_NAME = 'PromptBusinessPlayground';

    public String getModelResponse(String caseId, String contextType, String userPrompt) {
        return prepareEinsteinLLMGenerationOutput(caseId, contextType, userPrompt);
    }

    private String prepareEinsteinLLMGenerationOutput(String caseId, String contextType, String userPrompt) {
        Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();

        Map<String, String> mainCaseMap = new Map<String, String>();
        mainCaseMap.put('id', caseId);

        ConnectApi.WrappedValue mainCaseWrappedValue = new ConnectApi.WrappedValue();
        mainCaseWrappedValue.value = mainCaseMap;

        valueMap.put('Input:ContextCase', mainCaseWrappedValue);

        ConnectApi.WrappedValue userPromptWrappedValue = new ConnectApi.WrappedValue();
        userPromptWrappedValue.value = userPrompt;

        valueMap.put('Input:UserPrompt', userPromptWrappedValue);

        ConnectApi.WrappedValue contextTypeWrappedValue = new ConnectApi.WrappedValue();
        contextTypeWrappedValue.value = contextType;

        valueMap.put('Input:ContextType', contextTypeWrappedValue);

        ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        executeTemplateInput.isPreview = false;
        executeTemplateInput.inputParams = valueMap;

        executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';

        if(Test.isRunningTest()) {
            return 'Test LLM response';
        }

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(PLAYGROUND_TEMPLATE_DEV_NAME, executeTemplateInput);

        if(hasErrorFromModel(generationsOutput)) {
            throw new LLMException(generationsOutput.generationErrors[0].localizedErrorMessage);
        }

        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];

        return response.text;
    }

    @TestVisible
    private Boolean hasErrorFromModel(ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput) {
        return generationsOutput.generations.isEmpty() && generationsOutput.generationErrors != null && !generationsOutput.generationErrors.isEmpty();
    }

    public class LLMException extends Exception {}
}