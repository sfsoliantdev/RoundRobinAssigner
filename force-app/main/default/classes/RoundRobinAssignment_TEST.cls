/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* RoundRobinAssignment_Test class that takes in the list of 3000 sObject (Account) records to run 
* the assignment on and the custom setting of Salesforce users to whom the records will be assigned to.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Uriel A. Gutierrez <ugutierrez@soliantconsulting.com>
* @created        2019-04-07
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@IsTest
public class RoundRobinAssignment_TEST {

  @TestSetup
  static void setup() {

    //create the Salesforce users that will also be added to the round robin custom setting
    List<User> sfUsers = TestFactory.createSalesforceUsers(10);
    insert sfUsers;

    //create the custom setting of users with the created Salesforce users
    List<Account_Round_Robin_Users__c> acctRoundRobinUsers = TestFactory.createRoundRobinUsers(sfUsers);
    insert acctRoundRobinUsers;
  }

  @isTest
  static void testRoundRobinAssignment() {

    //query the custom setting in ASC order into a mapto get the oldest created records first
    //this is how we handle the order of priority to assign
    Map<String, Account_Round_Robin_Users__c> roundRobinUserMap = new Map<String, Account_Round_Robin_Users__c>();
    for(Account_Round_Robin_Users__c roundRobinUser : [SELECT Id, User_Username__c, Active__c, 
                                                          CreatedDate__c, Is_Last_Used__c
                                                        FROM Account_Round_Robin_Users__c
                                                        ORDER BY CreatedDate__c ASC])
    {
      //if the User Username is blank or the user has been marked as inactive in the custom
      //setting, let's skip them - Username should be a required field when creating a record
      //this is more to safeguard.
      if(String.isBlank(roundRobinUser.User_Username__c) || !roundRobinUser.Active__c)
        continue;

      //add the users to the map - the User Username is unique across all salesforce orgs
      //since it is the same as their username on their User record
      roundRobinUserMap.put(roundRobinUser.User_Username__c, roundRobinUser);
    }

    List<Account> accts = TestFactory.createAccounts(3000);

    //run the assignment on the 3000 accounts that will be inserted
    //pass in the map of the round robin users
    RoundRobinAssignment rrAssigner = new RoundRobinAssignment(accts, roundRobinUserMap);
    rrAssigner.runRoundRobinAssignment();

    //after the assignment of users is done, let's insert the accts
    insert accts;

    //create a map of owner id to list of accounts
    Map<Id, List<Account>> acctOwnerMap = new Map<Id, List<Account>>();
    for(Account acct : accts) {
      if(acctOwnerMap.containsKey(acct.OwnerId)) {
        acctOwnerMap.get(acct.OwnerId).add(acct);
      } else {
        acctOwnerMap.put(acct.OwnerId, new List<Account>{acct});
      }
    }

    //the size of the keySet should match the number of active Salesforce
    //users in the round robin custom setting
    System.assertEquals(10, acctOwnerMap.keySet().size());

    //if the round robin worked correctly, each of the 10 users should have
    //been assigned Accounts evenly. So each owner should have 300 Accounts
    //assigned to them if 3000 Accounts were inserted.
    for(Id ownerId : acctOwnerMap.keySet()) {
      System.assertEquals(300, acctOwnerMap.get(ownerId).size());
    }
  }
}