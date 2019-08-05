public class Utils {
  
  public static Map<String, SObject> createRoundRobinUserMap(String customSettingName) {
    Map<String, SObject> roundRobinUserMap = new Map<String, SObject>();

    String customSettingStr = 'SELECT Id, User_Username__c, Active__c, CreatedDate__c, Is_Last_Used__c FROM ' + customSettingName + ' ORDER BY CreatedDate__c ASC'; 
    List<SObject> roundRobinUsers = Database.query(customSettingStr);

    for(SObject record : roundRobinUsers) {
      roundRobinUserMap.put((String) record.get('User_Username__c'), record);
    }

    return roundRobinUserMap;
  }
}