public with sharing class OpportunityTriggerHandler implements TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    
    private OpportunityService opportunityService;
    
    public OpportunityTriggerHandler(boolean triggerIsExecuting, integer triggerSize) {
        this.triggerIsExecuting = triggerIsExecuting;
        this.triggerSize = triggerSize;
        this.opportunityService = new OpportunityService();
    }
    
    public void run(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap){
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                beforeInsert( (List<Opportunity>) newRecords );
                return;
            }
            when BEFORE_UPDATE {
               return;
            }
            when BEFORE_DELETE {
                return;
            }
            when AFTER_INSERT {
                return;
            }
            when AFTER_UPDATE {
                afterUpdate((List<Opportunity>) oldRecords,(List<Opportunity>) newRecords, (Map<ID, Opportunity>) oldRecordMap,(Map<ID, Opportunity>) newRecordMap);
                return;
            }
            when AFTER_DELETE {
                return;
            }
            when AFTER_UNDELETE {
                return;
            }
        }
    }
    
    private void beforeInsert(List<Opportunity> newRecords){       
        opportunityService.assignNewRecords(newRecords);
    }
    
    private void afterUpdate(List<Opportunity> oldRecords, List<Opportunity> newRecords, Map<ID, Opportunity> oldRecordMap, Map<ID, Opportunity> newRecordMap){
        opportunityService.closedOpportunities(oldRecords,newRecords, oldRecordMap,newRecordMap);
    }
    
}