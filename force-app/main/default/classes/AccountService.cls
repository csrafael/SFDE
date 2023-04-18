public with sharing class AccountService {

    public static void createContacts (String accountId) {
        List<Contact> contacts = new List<Contact>();

        if (!Schema.sObjectType.Contact.isCreateable()) {
            return;
        }

        for (Integer i = 0; i < 10; i++) {
            Contact newContact = new Contact();
            newContact.AccountId = accountId;
            newContact.LastName = 'TEST0'+i;
            contacts.add(newContact);
        }
        
        insert contacts;
    }
}