trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
	OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    handler.run(Trigger.old, Trigger.new, trigger.oldMap, trigger.newMap);
}