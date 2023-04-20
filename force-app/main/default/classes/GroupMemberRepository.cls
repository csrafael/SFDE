public class GroupMemberRepository {

    public static List<GroupMember> getGroupMembers() {
        return [Select Id, GroupId, Group.Id, Group.DeveloperName, UserOrGroupId from GroupMember];
    }
    
    public static Map<String,GroupMember> getMapOfUserIdByGroupMembers() {
        Map<String,GroupMember> mapGroupMember = new Map<String,GroupMember>();
        
        for (GroupMember gm : getGroupMembers() ) {
            mapGroupMember.put(gm.UserOrGroupId, gm);
        }
        
        return mapGroupMember;
    }
}