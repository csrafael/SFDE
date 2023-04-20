public class OpportunityRepository {

    public static List<Opportunity> getOpenOpportunitiesByUserIds (Set<String> userIds) {
        return [Select Id, OwnerId from Opportunity where isClosed = false and ownerId =: userIds ];
    }
    
    public static AggregateResult[] countOpenOppsByUserIds(Set<String> userIds) {
        return [Select OwnerId, count(Id) counter from Opportunity where isClosed = false and ownerId =: userIds group by OwnerId ];
    }
    
    public static List<Opportunity> getOldestOpenRecordFromTeamA(integer size ) {
        return [Select id from Opportunity where isClosed = false and amount < 10000 order by createdDate ASC limit :size   ];
    }
    
    public static List<Opportunity> getOldestOpenRecordFromTeamB(integer size ) {
        return [Select id from Opportunity where isClosed = false and amount >= 10000 order by createdDate ASC limit :size   ];
    }
}