public class OpportunityRepository {

    /*
     * 
     * */
    public static List<Opportunity> getOpenOpportunitiesByUserIds (Set<String> userIds) {
        return [Select Id, OwnerId from Opportunity where isClosed = false and ownerId =: userIds ];
    }
    
    /*
     * get how many open opportunities an Owner has. 
     *  - if he has not an opportunity, it is not shown
     *  - the owner that has the lower number (>0) of opportunities is shown first
     * */
    public static AggregateResult[] countOpenOppsByUserIds(Set<String> userIds) {
        return [Select OwnerId, count(Id) counter from Opportunity where isClosed = false and ownerId =: userIds group by OwnerId Order by count(Id) Asc ];
    }
    
    /*
     * 
     * */
    public static List<Opportunity> getOldestOpenRecordFromTeamA(integer size ) {
        return [Select id from Opportunity where isClosed = false and amount < 10000 order by createdDate ASC limit :size];
    }
    
    /*
     * 
     * */
    public static List<Opportunity> getOldestOpenRecordFromTeamB(integer size ) {
        return [Select id from Opportunity where isClosed = false and amount >= 10000 order by createdDate ASC limit :size];
    }
    
    /*
     * 
     * */
    public static Opportunity getLastOpportunity() {
        return [Select Id, Name, CloseDate, OwnerId, Owner.Name, Amount, StageName from Opportunity order by createdDate Desc Limit 1];
    }
}