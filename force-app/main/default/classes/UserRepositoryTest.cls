@IsTest
public class UserRepositoryTest {

    @isTest
    public static void getDefaultUser() {
        TestUserData userData = new TestUserData();
    	User defaultUser = userData.generateNewUser();
        User user;
        Test.startTest();
        system.runAs(defaultUser) { 
	        user = UserRepository.getDefaultUser(); 
        }
        Test.stopTest();
        
        Assert.areEqual(user.Profile.Name, 'System Administrator', 'Profiles not expected');
    }
}