#Guide to adding the Round Robin Assignment in your org

Before cloning, or forking the repository, you will want to create a Custom Setting for the users that will be a part of the Round Robin.
These users will be those that you want to assign to the records that are created.

Since this code can be reused for multiple objects, you can create multiple custom settings for users.
Example image below.

![example-custom-settings](/images/Example-Custom-Settings.png)

In each custom setting that you create, you will want to add a couple of fields that are used within the assigner itself. These fields are:

* Active - checkbox default to true
* CreatedDate__c - Date/Time
* Is_Last_Used__c - checkbox default to false
* User_Username__c - Text(255)(Unique Case Insensitive)

Example image below.

![custom-setting-example](/images/Custom-Setting-Example.png)

Once created, you can begin adding users to the custom setting. Get the user's username, from their user record in Salesforce, for whom you would like to add.
Add this username to the 'User Username' field. This is ideal since usernames must be unique across orgs.

Example of an Account Round Robin Users Custom setting.

![account-custom-setting-example](/images/Account-Custom-Setting-Example.png)

Once you have the custom settings created, you can clone, or fork, the repository to access the Round Robin Assignment logic.

#Running the Round Robin Assignment through before insert triggers

The Round Robin Assignment can be run through before insert triggers for the object that you're trying to assign.

Make sure the RoundRobinAssignment.cls and RoundRobinAssignment_TEST.cls Apex classes are in your org.

If you already have triggers in place, all you would need to do is add the following code to your before insert trigger:

* Create a round robin user map - Map<String, Your_Custom_Setting_API_Name_Here> and call the Utils.createRoundRobinUserMap(String customSettingName) method
    * The string parameter is the API Name of the Custom Setting
    * Example - Map<String, Account_Round_Robin_Users__c> roundRobinUserMap = Utils.createRoundRobinUserMap('Account_Round_Robin_Users__c');

* After, instantiate the RoundRobinAssignment class and pass in Trigger.New and the roundRobinUserMap
    * Example - RoundRobinAssignment rrAssigner = new RoundRobinAssignment(Trigger.new, roundRobinUserMap);

* Then, run the assignment method using the .runRoundRobinAssignment();
    * Example - rrAssigner.runRoundRobinAssignment();

After, you should be ready to test out by inserting multiple records and each record should be assigned to the different users in the Round Robin.

If you don't have any triggers in place it gets slightly more difficult. Start off by adding the trigger framework to your org. 
This can be done by adding the TriggerHandler.cls and TriggerHandler_Test.cls Apex classes, which are developed by Kevin O'Hara.
This trigger framework can be reused as well for other objects.

**Special thanks to Kevin O'Hara for creating this awesome trigger framework!**

Note that a screenshot of what the final class will look like is provided below.

Once you have added the trigger framework Apex classes in your org, next you have to create the trigger handler on the object you want to run the Round Robin Assignment on.

* Create a new Apex class - I usually call mine something like AccountTriggerHandler, ContactTriggerHandler, etc.
* After class is created, extend the TriggerHandler class
    * Example - public class AccountTriggerHandler extends TriggerHandler {}

* Inside of this class you can implement the triggers that you would like. The Round Robin Assignment requires before insert trigger. So add that method in.
    * Example - protected override void beforeInsert() {}

* Inside of this beforeInsert() method, we want to add in the same code provided above
    * Create a round robin user map - Map<String, Your_Custom_Setting_API_Name_Here> and call the Utils.createRoundRobinUserMap(String customSettingName) method
      * The string parameter is the API Name of the Custom Setting
      * Example - Map<String, Account_Round_Robin_Users__c> roundRobinUserMap = Utils.createRoundRobinUserMap('Account_Round_Robin_Users__c');

    * After, instantiate the RoundRobinAssignment class and pass in Trigger.New and the roundRobinUserMap
      * Example - RoundRobinAssignment rrAssigner = new RoundRobinAssignment(Trigger.new, roundRobinUserMap);

    * Then, run the assignment method using the .runRoundRobinAssignment();
      * Example - rrAssigner.runRoundRobinAssignment();

Finally, to actually have the trigger run each time a record is inserted, you need to create a trigger on the object itself. Go to your object and find it's triggers. 
There add in these lines of code replacing Account with your object:

```
  trigger AccountTrigger on Account (
    before insert, before update, before delete,
    after insert, after update, after delete, after undelete
  ){
    new AccountTriggerHandler().run();
  }
```

After, you should be ready to test out by inserting multiple records and each record should be assigned to the different users in the Round Robin.

Example of AccountTriggerHandler class calling the Round Robin Assignment.

```
public class AccountTriggerHandler extends TriggerHandler {
  protected override void beforeInsert() {
    Map<String, Account_Round_Robin_Users__c> roundRobinUserMap = Utils.createRoundRobinUserMap('Account_Round_Robin_Users__c');
    RoundRobinAssignment rrAssigner = new RoundRobinAssignment(Trigger.new, roundRobinUserMap);
    rrAssigner.runRoundRobinAssignment();
  }
}
```


#Running the Round Robin Assignment through Process Builder

The Round Robin Assignment can also be run through Process Builder after the code is in your org.

Once the RoundRobinAssignment.cls and RoundRobinAssignment_TEST.cls Apex classes are in your org, you can create a Process Builder on your object when a record is created.
You can also use the ISNEW() function in your criteria to make sure it only runs for new records.

Process Builder Criteria
* Criteria - just execute the actions! - assuming this process builder on runs on create, else use ISNEW().
* Immediate Action - Apex
    * Apex Class - RoundRobinAssignment
  
  * Apex Variables
    * Field : customSettingName
    * Type  : String
    * Value : 'Your_Custom_Setting_API_Name_Here'
      * Example - 'Account_Round_Robin_Users__c'

    * Field : recordId
    * Type  : Field Reference
    * Value : [Object].Id
      * Example - [Account].Id, [Contact.Id] 

Example Process Builder on Account below.

![sample-process-builder](/images/Sample-Process-Builder.png)

