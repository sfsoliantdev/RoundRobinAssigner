/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* AccountTriggerHandler class - sample class to call the RoundRobinAssignment class.
* Pass in the List of SObjects in the trigger and the queried Map of the Round Robin Users.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Uriel A. Gutierrez <ugutierrez@soliantconsulting.com>
* @created        2019-04-06
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

public class AccountTriggerHandler extends TriggerHandler {
  protected override void beforeInsert() {
    Map<String, Account_Round_Robin_Users__c> roundRobinUserMap = AccountTriggerHelper.getRoundRobinUsers();
    RoundRobinAssignment rrAssigner = new RoundRobinAssignment(Trigger.new, roundRobinUserMap);
    rrAssigner.runRoundRobinAssignment();
  }
}