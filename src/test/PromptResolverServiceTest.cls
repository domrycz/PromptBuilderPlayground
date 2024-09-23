@IsTest
private class PromptResolverServiceTest {
    private static final PromptResolverService promptResolverService = new PromptResolverService();

    @IsTest
    private static void getModelResponse_mockedResponseReceived() {
        String response = promptResolverService.getModelResponse('caseId', 'contextType', 'userPrompt');
        Assert.areEqual('Test LLM response', response);
    }

    @IsTest
    private static void hasErrorFromModel_outputRecognizedAsError() {
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = getPromptTemplateErrorOutput();
        Assert.isTrue(promptResolverService.hasErrorFromModel(generationsOutput));
    }

    private static ConnectApi.EinsteinPromptTemplateGenerationsRepresentation getPromptTemplateErrorOutput() {
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        generationsOutput.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>();
        generationsOutput.generationErrors = new List<ConnectApi.EinsteinPromptTemplateGenerationsError>();
        generationsOutput.generationErrors.add(new ConnectApi.EinsteinPromptTemplateGenerationsError());
        return generationsOutput;
    }
}