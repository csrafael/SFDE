public class OpportunityService {

    private final Decimal AMOUNT = Decimal.valueOf(10000);
    
    private final String TEAM_A = 'TEAM_A';
    private final String TEAM_B = 'TEAM_B';
    
    private final String DEFAULT_USER_ID;
    
    public OpportunityService() {
        this.DEFAULT_USER_ID = UserRepository.getDefaultUser().Id;
    }
    
    public void assignNewRecords(List<Opportunity> newOpportunities) {
        
        setDefaultUser(newOpportunities);
        
        Map<String,GroupMember> mapGroupMembers = GroupMemberRepository.getMapOfUserIdByGroupMembers();
        Map<String, integer> mapOppByUserId = getOpenOpportunitiesByUserIds(mapGroupMembers.keySet());
        
        if (!hasAvailableUser(mapOppByUserId)){
            return;
        }
        
		updateOwner(newOpportunities, mapGroupMembers, mapOppByUserId);
    }
    
    public void closedOpportunities(List<Opportunity> oldRecords, List<Opportunity> newRecords, Map<ID, Opportunity> oldRecordMap, Map<ID, Opportunity> newRecordMap) {
        List<String> closedOppOwnersA = new List<String>();
        List<String> closedOppOwnersB = new List<String>();
        
        for (Opportunity opp : newRecords) {
            if (opp.IsClosed && oldRecordMap.get(opp.Id).isClosed != opp.IsClosed  && opp.Amount < AMOUNT ) {
                closedOppOwnersA.add(opp.OwnerId);
            }
            
            else if (opp.IsClosed && oldRecordMap.get(opp.Id).isClosed != opp.IsClosed  && opp.Amount >= AMOUNT ) {
                closedOppOwnersB.add(opp.OwnerId);
            }
        }
    }
        
    private void updateOwner (List<Opportunity> opportunities, Map<String,GroupMember> mapGroupMembers,  Map<String, integer> mapOppByUserId ) {

        List<String> membersA = getTeamMembers(mapGroupMembers, true);
        List<String> membersB = getTeamMembers(mapGroupMembers, false);
        
        integer counterTeamA = 0;
        integer counterTeamB = 0;
        
        for (Opportunity opp : opportunities) {
            integer memberAIndex = Math.mod(counterTeamA, membersA.size());
            integer memberBIndex = Math.mod(counterTeamB, membersB.size());
            String currentAUserId = membersA[memberAIndex];
            String currentBUserId = membersB[memberBIndex];
            
            if (opp.Amount < AMOUNT) {
                if (mapOppByUserId.get(currentAUserId) < 2) {
                    opp.OwnerId = currentAUserId;
                    counterTeamA++;
                    mapOppByUserId.put(currentAUserId, mapOppByUserId.get(currentAUserId)+1 );
                }
            }else {
                if (mapOppByUserId.get(currentBUserId) < 2) {
                    opp.OwnerId = currentBUserId;
                    counterTeamB++;
                    mapOppByUserId.put(currentBUserId, mapOppByUserId.get(currentBUserId)+1 );
                }
            }
        }
        
    }
    
    private List<String> getTeamMembers( Map<String,GroupMember> mapGroupMembers, boolean isTeamA) {
        list<String> members = new List<String>();
        for (GroupMember gm : mapGroupMembers.values()) {
            if (isTeamA && gm.Group.DeveloperName.equals(TEAM_A)){
                members.add(gm.UserOrGroupId);
            }else if (!isTeamA && gm.Group.DeveloperName.equals(TEAM_B)) {
                 members.add(gm.UserOrGroupId);
            }
        }
        return members;
    }
    
    private Map<String, integer> getOpenOpportunitiesByUserIds (Set<String> userIds) {
        map<String,integer> opportunitiesByOwnerId = new Map<String,integer>();
        
        AggregateResult[] oppByUserIds = OpportunityRepository.countOpenOppsByUserIds(userIds);
        
        for (AggregateResult ar : oppByUserIds){
        	opportunitiesByOwnerId.put((String)ar.get('OwnerId'),(integer)ar.get('counter'));
        }
  
        for (String userId : userIds){
            if (!opportunitiesByOwnerId.containsKey(userId)) {
                opportunitiesByOwnerId.put(userId, 0);
            }
        }
        
        return opportunitiesByOwnerId;
    }
    
    private boolean hasAvailableUser ( Map<String, integer> mapOppByUserId) {
        for (integer oppCounter : mapOppByUserId.values()) {
            if (oppCounter < 2) {
                return true;
            }
        }
        
        return false;
    }
    
    private void setDefaultUser (List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.ownerId = DEFAULT_USER_ID;
        }
    }
}