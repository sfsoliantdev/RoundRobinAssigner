#Guide to adding the Round Robin Assigner in your org

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

Once created, you can begin adding users to the custom setting. Get the user's username, from their user record in Salesforce, of whom you would like to add.
Add this username to the 'User Username' field. This is ideal since usernames must be unique across orgs.

Example of an Account Round Robin Users Custom setting below.
![account-custom-setting-example](/images/Account-Custom-Setting-Example.png)

