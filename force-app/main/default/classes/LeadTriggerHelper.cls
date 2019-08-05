/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* LeadTriggerHelper class - used to remove clutter from the LeadTriggerHandler.
* Here we query the users that were added to the custom settings in ASC order to prioritize the first
* user entered as being the first one to get assigned.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Uriel A. Gutierrez <ugutierrez@soliantconsulting.com>
* @created        2019-04-07
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class LeadTriggerHelper {

  //get a map of active user usernames to the custom setting to query for their user record
  public static Map<String, Lead_Round_Robin_Users__c> getRoundRobinUsers() {
    
    //get a map of active user usernames to the custom setting to query for their user record
    Map<String, Lead_Round_Robin_Users__c> roundRobinUserMap = new Map<String, Lead_Round_Robin_Users__c>();
    for(Lead_Round_Robin_Users__c roundRobinUser : [SELECT Id, User_Username__c, Active__c, 
                                                          CreatedDate__c, Is_Last_Used__c
                                                        FROM Lead_Round_Robin_Users__c
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

    return roundRobinUserMap;
  }
}