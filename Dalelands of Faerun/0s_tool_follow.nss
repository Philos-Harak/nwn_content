/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script: 0s_tool_follow
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Spell script to follow a player or other creature.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"

void main()
{
    int nCount;
    object oTarget = GetSpellTargetObject ();
    object oUser = OBJECT_SELF;
    object oFollower, oFollowing = GetLocalObject (oUser, "0_Following");
    // If we are following a creature then stop following.
    if (GetIsObjectValid (oFollowing))
    {
       nCount = 1;
       oFollower = GetLocalObject (oFollowing, "0_Follower_" + IntToString (nCount));
       while (oFollower != oUser && nCount <= 10)
       {
          nCount ++;
          oFollower = GetLocalObject (oFollowing, "0_Follower_" + IntToString (nCount));
       }
       DeleteLocalObject (oFollowing, "0_Follower_" + IntToString (nCount));
       DeleteLocalObject (oUser, "0_Following");
       AssignCommand (oUser, ClearAllActions ());
       FloatingTextStringOnCreature ("You have stopped following " + GetName (oFollower), oUser, FALSE);
       if (!GetIsDungeonMaster (oUser)) FloatingTextStringOnCreature (GetName (oUser) + " has stopped following you.", oFollower, FALSE);
    }
    else if (GetIsObjectValid (oTarget))
    {
       // If the target is a player then use the Henchman follow system.
       // Max of 10 followers!
       if (GetIsCharacter (oTarget))
       {
           if (GetIsDungeonMaster (oUser))
           {
                DelayCommand (2.0f, AssignCommand (oUser, ActionForceFollowObject (oTarget, 4.0f)));
                SetLocalObject (oTarget, "0_Follower_" + IntToString (nCount), oUser);
                SetLocalObject (oUser, "0_Following", oTarget);
                FloatingTextStringOnCreature ("Now following " + GetName (oTarget), oUser, FALSE);
           }
           else
           {
               // First check we can only follow players in our party.
               if (!GetFactionEqual (oTarget, oUser))
               {
                   FloatingTextStringOnCreature ("Cannot follow " + GetName (oTarget) + "! Must be in same party.", oUser, FALSE);
                   return;
               }
               nCount = 1;
               oFollower = GetLocalObject (oTarget, "0_Follower_" + IntToString (nCount));
               while (GetIsObjectValid (oFollower) && nCount <= 10)
               {
                  oFollower = GetLocalObject (oTarget, "0_Follower_" + IntToString (nCount));
                  nCount ++;
               }
               if (nCount == 11) FloatingTextStringOnCreature ("Cannot follow " + GetName (oTarget) + "! Too many people following them.", oUser, FALSE);
               else
               {
                    SetLocalObject (oTarget, "0_Follower_" + IntToString (nCount), oUser);
                    SetLocalObject (oUser, "0_Following", oTarget);
                    FloatingTextStringOnCreature ("Now following " + GetName (oTarget), oUser, FALSE);
                    FloatingTextStringOnCreature (GetName (oUser) + " has started following you.", oFollower, FALSE);
               }
           }
       }
       else DelayCommand (2.0f, AssignCommand (oUser, ActionForceFollowObject (oTarget, 4.0f)));
    }
}
