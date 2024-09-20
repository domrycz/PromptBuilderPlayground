public with sharing class BusinessPlaygroundPromptAction {

    @InvocableMethod(CapabilityType='FlexTemplate://PromptBusinessPlayground')
    public static List<Response> getCaseContextInvocable(List<Request> requests) {
        if(requests.isEmpty()) {
            return null;
        }

        Request request = requests[0];

        Response output = new Response();
        output.Prompt = getCaseContext(request.ContextCase.Id, request.ContextType);

        return new List<Response>{output};
    }

    private static String getCaseContext(Id caseId, String contextType) {
        return new ContextBuilder().getCaseContext(caseId, ContextBuilder.ContextType.valueOf(contextType));
    }

    public class Request {
        @InvocableVariable(Required=true)
        public Case ContextCase;
        @InvocableVariable(Required=true)
        public String UserPrompt;
        @InvocableVariable(Required=true)
        public String ContextType;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}