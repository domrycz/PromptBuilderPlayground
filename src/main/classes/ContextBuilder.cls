public with sharing class ContextBuilder {

    public enum ContextType { Full, Today }

    public String getCaseContext(Id caseId, ContextType context) {
        Case caseRecord = [SELECT Id, Subject, Origin, Type, Contact.Name, CreatedDate FROM Case WHERE Id = :caseId];

        List<EmailMessageWrapper> emailMessages = getEmailsForContext(caseRecord.Id, context);

        CaseContextWrapper caseContext = populateWrapperWithData(caseRecord, emailMessages);

        return JSON.serialize(caseContext);
    }

    public Integer getContextLength(Id caseId, ContextType context) {
        return getCaseContext(caseId, context).length();
    }

    private CaseContextWrapper populateWrapperWithData(Case caseRecord, List<EmailMessageWrapper> emails) {
        CaseContextWrapper caseWrapper = new CaseContextWrapper();
        caseWrapper.subject = caseRecord.Subject;
        caseWrapper.origin = caseRecord.Origin;
        caseWrapper.type = caseRecord.Type;
        caseWrapper.contactName = caseRecord.Contact.Name;
        caseWrapper.createdDate = caseRecord.CreatedDate.format();
        caseWrapper.emails = emails;
        return caseWrapper;
    }

    private List<EmailMessageWrapper> getEmailsForContext(Id caseId, ContextType context) {
        String query = 'SELECT Id, ParentId, ToAddress, FromAddress, Incoming, Subject, TextBody, CreatedDate' +
                ' FROM EmailMessage WHERE ParentId = :caseId ';
        if(context == ContextType.Today) {
            query += 'AND CreatedDate = TODAY';
        }
        List<EmailMessage> emailsFromCase = Database.query(query);

        List<EmailMessageWrapper> contextEmails = new List<EmailMessageWrapper>();
        for(EmailMessage email : emailsFromCase) {
            contextEmails.add(new EmailMessageWrapper(email));
        }

        return contextEmails;
    }

    public class CaseContextWrapper {
        public String externalId;
        public String subject;
        public String origin;
        public String type;
        public String contactName;
        public String createdDate;
        public List<EmailMessageWrapper> emails;
    }

    public class EmailMessageWrapper {
        public String subject;
        public String type;
        public String createdDate;
        public String fromAddress;
        public String toAddress;
        public String body;
        public EmailMessageWrapper(EmailMessage email) {
            this.subject = email.Subject;
            this.createdDate = email.CreatedDate.format();
            this.fromAddress = email.FromAddress;
            this.toAddress = email.ToAddress;
            this.type = getEmailType(email.Incoming);
            this.body = email.TextBody;
        }
    }

    private static String getEmailType(Boolean incoming) {
        if(incoming == true) {
            return 'Inbound';
        } else {
            return 'Outbound';
        }
    }
}