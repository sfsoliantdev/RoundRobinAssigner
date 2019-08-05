/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* TestFactory class - handles the creation of data that is used in the test classes we create
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Uriel A. Gutierrez <ugutierrez@soliantconsulting.com>
* @created        2019-04-07
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class TestFactory {

  public static List<Account> createAccounts(Integer numRecords) {
    List<Account> accts = new List<Account>();
    for(Integer i = 0; i < numRecords; i++) {
      Account acct = new Account();
      acct.Name = 'Tester ' + i;
      accts.add(acct);
    }

    return accts;
  }

  public static List<Account_Round_Robin_Users__c> createRoundRobinUsers(List<User> users) {
    List<Account_Round_Robin_Users__c> rrUsers = new List<Account_Round_Robin_Users__c>();
    Integer ctr = 0;
    Integer dateCtr = 1;
    for(User u : users) {
      Date myDate = Date.newInstance(2019, 11, dateCtr);
      Time myTime = Time.newInstance(3, 3, 3, 0);
      DateTime dt = DateTime.newInstance(myDate, myTime);
      Account_Round_Robin_Users__c rrUser = new Account_Round_Robin_Users__c();
      rrUser.Active__c = true;
      rrUser.Is_Last_Used__c = false;
      rrUser.CreatedDate__c = dt;
      rrUser.User_Username__c = 'testuser' + ctr + '@salesforce.com.developer';
      rrUser.SetupOwnerId = u.Id;
      rrUsers.add(rrUser);
      ctr++;
      dateCtr++;
    }

    return rrUsers;
  }

  public static List<Lead> createLeads(Integer numRecords) {
    List<Lead> leads = new List<Lead>();
    for(Integer i = 0; i < numRecords; i++) {
      Lead lead = new Lead();
      lead.LastName = 'Tester' + i;
      lead.Company = 'Tester Company ' + i;
      lead.Status = 'Open - Not Contracted';
      leads.add(lead);
    }

    return leads;
  }

  public static List<User> createSalesforceUsers(Integer numRecords) {
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    List<User> users = new List<User>();
    for(Integer i = 0; i < numRecords; i++) {
      User u = new User();
      u.Alias = 'standard';
      u.EmailEncodingKey='UTF-8';
      u.IsActive = true;
      u.Email = 'testuser' + i + '@salesforce.com';
      u.Username = 'testuser' + i + '@salesforce.com.developer';
      u.FirstName = 'Test FirstName ' + i;
      u.LastName = 'Test LastName ' + i;
      u.LanguageLocaleKey='en_US';
      u.LocaleSidKey='en_US';
      u.ProfileId = p.Id;
      u.TimeZoneSidKey='America/Chicago';
      users.add(u);
    }
    
    return users;
  }
}