public class OpportunityService {

    private final Decimal AMOUNT = Decimal.valueOf(10000);
    
    private final String TEAM_A = 'TEAM_A';
    private final String TEAM_B = 'TEAM_B';
    
    private final String DEFAULT_USER_ID;
    
    public OpportunityService() {
        this.DEFAULT_USER_ID = UserRepository.getDefaultUser().Id;
    }
    
    /*
     * this method assign opportunities to a default admin user, 
     * if team members are available to receive an opportunity, 
     * the opportuntiy will be assigned to them
     * */
    public void assignNewRecords(List<Opportunity> newOpportunities) {
        
        //set default admin user - opportunity must have an owner
        setDefaultUser(newOpportunities);
       
        Map<String,GroupMember> mapGroupMembers = GroupMemberRepository.getMapOfUserIdByGroupMembers(); //get all team members
        Map<String, integer> mapOppByUserId = getOpenOpportunitiesByUserIds(mapGroupMembers.keySet()); //count how many opportunities each team member has
        
        //validate if there are available users
        if (!hasAvailableUser(mapOppByUserId)){
            return;
        }
        
        //update opportunities with respect owners
		updateOwner(newOpportunities, mapGroupMembers, mapOppByUserId);
    }
    
    /*
     * 
     * */
    public void closedOpportunities(List<Opportunity> newRecords, Map<ID, Opportunity> oldRecordMap) {
        List<String> closedOppOwnersA = new List<String>();
        List<String> closedOppOwnersB = new List<String>();
        
        //split Opportunity Owners in two list according to each team
        for (Opportunity opp : newRecords) {
            // go to the next opportunity when the opportunity is not closing right now
            if (!isRecentlyClosed(opp, OldRecordMap)) {
                continue;
            }
            
            // if it is closing, check witch team the owner belongs 
            if ( opp.Amount < AMOUNT ) {
                closedOppOwnersA.add(opp.OwnerId);
            }else {
                closedOppOwnersB.add(opp.OwnerId);
            }
        }
        
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        
        oppToUpdate = getTeamOpps(closedOppOwnersA,true);		//get open opportunities from Team A and assign to available owner
        oppToUpdate.addAll(getTeamOpps(closedOppOwnersB,false));//get open opportunities from Team B and assign to available owner
        
        if (oppToUpdate.isEmpty()) {
            return;
        }
        
        update oppToUpdate;
    }
    
    /*
     * 
     * */
    private void updateOwner (List<Opportunity> opportunities, Map<String,GroupMember> mapGroupMembers,  Map<String, integer> mapOppByUserId ) {

        List<String> membersA = getTeamMembers(mapGroupMembers, true); //get list of team A members (normally 2)
        List<String> membersB = getTeamMembers(mapGroupMembers, false);//get list of team B members (normally 3)
        
        integer counterTeamA = 0;
        integer counterTeamB = 0;
        
        for (Opportunity opp : opportunities) {
            //calculate mod to make a round robin assigment according to each team
            integer memberAIndex = Math.mod(counterTeamA, membersA.size());
            integer memberBIndex = Math.mod(counterTeamB, membersB.size());
            
            //get next user to receive an oppportunity
            String currentAUserId = membersA[memberAIndex];
            String currentBUserId = membersB[memberBIndex];
            
            if (opp.Amount < AMOUNT) {
                //check next user is available (how to transform this block in a method?)
                if (isUserAvailable(mapOppByUserId,currentAUserId) ) {
                    opp.OwnerId = currentAUserId;
                    counterTeamA++;
                    mapOppByUserId.put(currentAUserId, mapOppByUserId.get(currentAUserId)+1 );
                }
            }else {
                //check next user is available (how to transform this block in a method?)
                if (isUserAvailable(mapOppByUserId,currentBUserId)) {
                    opp.OwnerId = currentBUserId;
                    counterTeamB++;
                    mapOppByUserId.put(currentBUserId, mapOppByUserId.get(currentBUserId)+1 );
                }
            }
        }
        
    }
    
    /*
     *check next user is available - has less than two open opportunities 
     * */
    private boolean isUserAvailable (Map<String, integer> mapOppByUserId, String userId ) {
        return mapOppByUserId.get(userId) < 2;
    }

    /*
     * check if the opportunity is closing in this moment
     * - isClosed changed to true right now ?
     * */
    private boolean isRecentlyClosed(Opportunity opportunity, Map<ID, Opportunity> oldRecordMap) {
        return opportunity.IsClosed && oldRecordMap.get(opportunity.Id).isClosed != opportunity.IsClosed;
    }
    
    /*
     * 
     * */
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
    
    /*
     * return a map with how many opportunities the users have.
     * */
    private Map<String, integer> getOpenOpportunitiesByUserIds (Set<String> userIds) {
        AggregateResult[] oppByUserIds = OpportunityRepository.countOpenOppsByUserIds(userIds);
        
        return fillMap(oppByUserIds, userIds);
    }
    
    /*
     * 
     * */
    private Map<String, integer> fillMap(AggregateResult[] oppByUserIds, Set<String> userIds) {
        map<String,integer> opportunitiesByOwnerId = new Map<String,integer>();
        
        //fill Map with users that has opportunities
        for (AggregateResult ar : oppByUserIds){
            opportunitiesByOwnerId.put((String)ar.get('OwnerId'),(integer)ar.get('counter'));
        }
        
        //fill Map with user that has not opportunities
        for (String userId : userIds){
            if (!opportunitiesByOwnerId.containsKey(userId)) {
                opportunitiesByOwnerId.put(userId, 0);
            }
        }
        
        return opportunitiesByOwnerId;
    }
    
    /*
     * Check if has at least one available user (with less than 2 opportunities open)
     * */
    private boolean hasAvailableUser ( Map<String, integer> mapOppByUserId) {
        for (integer oppCounter : mapOppByUserId.values()) {
            if (oppCounter < 2) {
                return true;
            }
        }
        
        return false;
    }
    
    /*
     * Set a system admin user as opportunity owner
     * */
    private void setDefaultUser (List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
            opp.ownerId = DEFAULT_USER_ID;
        }
    }
    
    /*
     * 
     * */
    private List<Opportunity> getTeamOpps(List<String> ownerIds, boolean isTeamA) {
        List<Opportunity> opps = isTeamA 
            ? OpportunityRepository.getOldestOpenRecordFromTeamA(ownerIds.size()) 	// get Opportunities relates to Team A (amount < 10000)
            : OpportunityRepository.getOldestOpenRecordFromTeamB(ownerIds.size());  // get Opportunities relates to Team B (amount >= 10000)
        
        //assign the oldest and open opportunity to a teamMember that is available now 
        assignOpportunitiesToOwnerIds(opps,ownerIds);
        return opps;
    }
    
    /*
     * assign ownerList to an Opportunity List (one-to-one)
     * */
    private void assignOpportunitiesToOwnerIds (List<Opportunity> opportunities, List<String> ownerIds ) {
        integer ownerIndex = 0;
        
        for (Opportunity opp : opportunities) {
            opp.OwnerId = ownerIds[ownerIndex];
			ownerIndex++;            
        }
    }
}