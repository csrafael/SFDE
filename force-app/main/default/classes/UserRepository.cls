public class UserRepository {

    public static User getDefaultUser() {
        return [ Select Id from User where isActive = true and Profile.Name = 'System Administrator' Order by CreatedDate ASC Limit 1];
    }
}