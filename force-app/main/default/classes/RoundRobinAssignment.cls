/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* RoundRobinAssignment class that takes in the list of sObject records to run the assignment on and
* the custom setting of Salesforce users to whom the records will be assigned to.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Uriel A. Gutierrez <ugutierrez@soliantconsulting.com>
* @created        2019-04-06
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class RoundRobinAssignment {

  List<SObject> records = new List<SObject>();
  Map<String, SObject> roundRobinUserMap = new Map<String, SObject>();
  RoundRobinUser prevUser = new RoundRobinUser();
  RoundRobinUser nextUser = new RoundRobinUser();
  
  public RoundRobinAssignment(List<SObject> records, Map<String, SObject> roundRobinUserMap) {
    this.records = records;
    this.roundRobinUserMap = roundRobinUserMap;
  }

  public void runRoundRobinAssignment() {
    Map<String, User> sfUsersMap = getActiveUsers(this.roundRobinUserMap);

    //check to see if a user was previously assigned
    this.prevUser = this.checkPreviouslyAssignedUser(this.roundRobinUserMap, sfUsersMap);

    for(SObject record : this.records) {
      this.nextUser = this.assignNextUser(this.prevUser, this.roundRobinUserMap, sfUsersMap);
      record.put('OwnerId',  this.nextUser.userId);

      //set the previous user to the next user that was returned
      this.prevUser = this.nextUser;
    }

    update roundRobinUserMap.values();
  }

  //create a map of unique usernames to active salesforce user records
  private Map<String, User> getActiveUsers(Map<String, SObject> roundRobinUserMap) {
    Map<String, User> sfUsersMap = new Map<String, User>();
    for(User sfUser : [SELECT Id, IsActive, Username FROM User WHERE Username IN :roundRobinUserMap.keySet()])
    {
      //we only want active users
      if(!sfUser.IsActive) {

        //if the user exists in the round robin, let's remove them
        //maybe even delete them?
        if(roundRobinUserMap.containsKey(sfUser.Username)) {
          roundRobinUserMap.remove(sfUser.Username);
        }
        continue;
      }

      sfUsersMap.put(sfUser.Username, sfUser);
    }

    return sfUsersMap;
  }

  //go through the user map and set inner class variables
  //to the last user that was used in the round robin
  private RoundRobinUser checkPreviouslyAssignedUser(Map<String, SObject> roundRobinUserMap, Map<String, User> sfUsersMap) {
    for(Integer i = 0; i < roundRobinUserMap.values().size(); i++) {
      if((Boolean) roundRobinUserMap.values().get(i).get('Is_Last_Used__c')) {
        this.prevUser.username = (String) roundRobinUserMap.values().get(i).get('User_Username__c');
        this.prevUser.userId = sfUsersMap.get(this.prevUser.username).Id;
        this.prevUser.lastUserIndex = i;
        this.prevUser.isLastUsed = true;
      }
    }

    return prevUser;
  }

  //if the previous user is null that means no user has been used
  //in the round robin. Let's set it to the first one.
  //otherwise let's use the last user index to get the next one
  //while also checking to see if we have to go back to the start 
  private RoundRobinUser assignNextUser(RoundRobinUser prevUser, Map<String, SObject> roundRobinUserMap, Map<String, User> sfUsersMap) {
    if(this.prevUser.userId == null) {
      this.nextUser.username = (String) roundRobinUserMap.values().get(0).get('User_Username__c');
      this.nextUser.userId = sfUsersMap.get(this.nextUser.username).Id;
      this.nextUser.lastUserIndex = 0;
      this.nextUser.isLastUsed = true;
    } else {
      this.updateRoundRobinMap(roundRobinUserMap, this.prevUser.username);
      Integer nextIndex = this.prevUser.lastUserIndex + 1;
      if(nextIndex >= roundRobinUserMap.values().size()) {
        nextIndex = 0;
        this.nextUser.username = (String) roundRobinUserMap.values().get(nextIndex).get('User_Username__c');
        this.nextUser.userId = sfUsersMap.get(this.nextUser.username).Id;
        this.nextUser.lastUserIndex = 0;
        this.nextUser.isLastUsed = true;
      } else {
        this.nextUser.username = (String) roundRobinUserMap.values().get(nextIndex).get('User_Username__c');
        this.nextUser.userId = sfUsersMap.get(this.nextUser.username).Id;
        this.nextUser.lastUserIndex = nextIndex;
        this.nextUser.isLastUsed = true;
      }

      // this.updateRoundRobinMap(roundRobinUserMap, this.nextUser.username);
    }

    this.updateRoundRobinMap(roundRobinUserMap, this.nextUser.username);
    return nextUser;
  }

  //since we have to update the Is_Last_Used__c value, let's clone the sobject
  //then reassign it to the user with the new value
  private void updateRoundRobinMap(Map<String, SObject> roundRobinUserMap, String user) {
    SObject clonedObj = roundRobinUserMap.get(user).clone(true, false, true, true);

    if((Boolean) clonedObj.get('Is_Last_Used__c')) {
      clonedObj.put('Is_Last_Used__c', false);
    } else {
      clonedObj.put('Is_Last_Used__c', true);
    }

    roundRobinUserMap.put(user, clonedObj);
  }

  @InvocableMethod
  public static void runRoundRobinAssignment(List<RRUser> roundRobinSettings) {

    //since we can't pass in a generic sobject in invocable methods, let's use the id to get the SObjectType
    //and then create a new sobject
    SObject objRec = roundRobinSettings.get(0).recordId.getSObjectType().newSObject(roundRobinSettings.get(0).recordId);

    //get the map of round robin users from the Utils class
    Map<String, SObject> roundRobinUserMap = Utils.createRoundRobinUserMap(roundRobinSettings.get(0).customSettingName);

    //since the instantiation of the assinger class is expecting a list
    //of sObjects, let's add the one record above to a list of sobjects
    List<SObject> createdObjects = new List<SObject>();
    createdObjects.add(objRec);

    RoundRobinAssignment rrAssigner = new RoundRobinAssignment(createdObjects, roundRobinUserMap);
    rrAssigner.runRoundRobinAssignment();
  }

  public class RRUser {
    @InvocableVariable(required=true)
    public Id recordId;

    @InvocableVariable(required=true)
    public String customSettingName;
  }

  public class RoundRobinUser {
    Id userId;
    String username;
    Integer lastUserIndex;
    Boolean isLastUsed;
  }
}