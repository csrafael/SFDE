/*
 * Test Class to validate all business logic (Global scenarios)
 **/
@IsTest
public class OpportunityIntegrationTest {

    @TestSetup
    public static void setup() {
        //setup new users and groupMembers to Team A and Team B
        List<User> userList = TestUserData.getInstance().generateUserList(5);
        
        //create groupMembers with test users 
        
    }
    
    @IsTest
    public static void createOpportunityTeamA () {
        TestUserData userData = new TestUserData();
    	User defaultUser = userData.generateNewUser();
        Opportunity opp = TestOpportunityData.generate();
        opp.Amount = 10;
        
        Test.startTest();
        system.runAs(defaultUser) { 
            insert opp;
        }
        Test.stopTest();
        
        Opportunity createdOpp = OpportunityRepository.getLastOpportunity();
    }
    
    @IsTest
    public static void createOpportunityTeamB () {
        TestUserData userData = new TestUserData();
    	User defaultUser = userData.generateNewUser();
        Opportunity opp = TestOpportunityData.generate();
        opp.Amount = 1000000;
        
        Test.startTest();
        system.runAs(defaultUser) { 
            insert opp;
        }
        Test.stopTest();
        
        Opportunity createdOpp = OpportunityRepository.getLastOpportunity();
    }
    
    @IsTest
    public static void createOpportunityWithoutAvailableTeamMember() {
		
    }
    
    @IsTest
    public static void closeOpportunityWithoutOppWaitList () {
        TestUserData userData = new TestUserData();
    	User defaultUser = userData.generateNewUser();
        Opportunity opp = TestOpportunityData.generate();
        opp.Amount = 10;
        insert opp;
        
        Test.startTest();
        Opportunity createdOpp = OpportunityRepository.getLastOpportunity();
        createdOpp.StageName = 'Closed Lost';
        update createdOpp;
        Test.stopTest();
    }
    
    @IsTest
    public static void closeOpportunityWithOppWaitList () {
		//
    }
    
    @IsTest
    public static void deleteOpportuntity() {
        TestUserData userData = new TestUserData();
        User defaultUser = userData.generateNewUser();
        Opportunity opp = TestOpportunityData.generate();
        opp.Amount = 10;
        insert opp;
        
        Test.startTest();
        Opportunity createdOpp = OpportunityRepository.getLastOpportunity();
        delete createdOpp;
        Test.stopTest();

    }
}