/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_hen_hrtbeat_1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Henchmen heart beat script.

  1 - If we are busy or disabled exit out.
  2 - If we perceive an enemy and are free to attack then start combat.
  3 - If we are not in follow or stand ground mode then
  3a - Look for traps and deal with them as appropriate.
  3b - Look for loot on the ground if we are told to pick it up.
  3c - If we are too far away then move to them checking search and sneak modes.
  4 - We don't have a master so lets check for animations.

  Checking for loot:
  When creatures die they turn into "Remains" placeables with no ResRef and the
  tag of BodyBag. We cannot find out what remains goes with what creature so
  to keep henchmen from being looted we have built our own loot system for them.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_faerun"
#include "x2_inc_switches"
void main()
{
    ai_OnAssociateSpawn(OBJECT_SELF);
    ExecuteScript("0e_ch_1_hb");
}
/*#include "0i_henchmen"
void main()
{
    //Debug ("0e_hen_hrtbeat_1", "25", GetName (OBJECT_SELF) + " Heartbeat!" +
    //       " Busy: " + IntToString (GetIsBusy ()) + " Disabled: " + IntToString (Disabled ()) +
    //       " MODE_FOLLOW: " + IntToString (GetAssociateMode (MODE_FOLLOW)));
    // If we are disabled or busy then we don't need to do the heartbeat checks.
    if (!GetIsBusy () && !Disabled ())
    {
        // If there are enemies near that we can see then lets attack.
        if (GetNearestEnemy (OBJECT_SELF, 1, 7, 7) != OBJECT_INVALID &&
            AssociateCanAttack ())
        {
            //Debug ("0e_hen_hrtbeat_1", "34", "Heartbeat! We see " +
            //       GetName (GetNearestEnemy (OBJECT_SELF, 1, 7, 7)) +
            //       " so lets attack!");
            DoHenchmanCombatRound ();
        }
        // Now we check for traps, loot, or scouting ahead as long as we are not following.
        else if (!GetAssociateMode (MODE_FOLLOW) && !GetAssociateMode (MODE_STAND_GROUND))
        {
            object oMaster = GetMaster();
            if (oMaster != OBJECT_INVALID)
            {
                // In civilized areas we don't disarm traps and take stuff.
                if (!GetLocalInt (GetArea (OBJECT_SELF), "0_No_Difficulty"))
                {
                    //Seek out and disable undisabled traps
                    object oTrap = GetNearestTrapToObject ();
                    if (oTrap != OBJECT_INVALID)
                    {
                        if (AttemptToDisarmTrap (OBJECT_SELF, oTrap)) return;
                    }
                    // Check to see if we need to pickup items and gold.
                    HenchmanPickupItems ();
                    if (GetAssociateMode (MODE_SCOUT_AHEAD)) ScoutAhead (OBJECT_SELF);
                }
                // Finally we check to make sure we are following our master.
                if (GetCurrentAction (OBJECT_SELF) != ACTION_FOLLOW)
                {
                    // Follow master.
                    if (GetDistanceToObject (oMaster) > GetFollowDistance ())
                    {
                        ClearAllActions ();
                        //Debug ("0e_hen_hrtbeat", "64", "Follow master (Stealth: " +
                        //       IntToString (GetAssociateMode (MODE_AGGRESSIVE_STEALTH)) +
                        //       " Search: " + IntToString (GetAssociateMode (MODE_AGGRESSIVE_SEARCH)) + ").");
                        if (GetAssociateMode (MODE_AGGRESSIVE_STEALTH))
                        {
                            //Debug ("0e_hen_hrtbeat_1", "69", "Going into stealth mode!");
                            ActionUseSkill (SKILL_HIDE, OBJECT_SELF);
                            ActionUseSkill (SKILL_MOVE_SILENTLY,OBJECT_SELF);
                        }
                        else if (GetAssociateMode (MODE_AGGRESSIVE_SEARCH))
                        {
                            //Debug ("0e_hen_hrtbeat_1", "75", "Going into search mode!");
                            ActionUseSkill (SKILL_SEARCH, OBJECT_SELF);
                        }
                        ActionMoveToObject (oMaster, TRUE, GetFollowDistance ());
                    }
                }
            }
            // We do not have a master so do animations.
            else if (!IsInConversation (OBJECT_SELF)) CheckCreatureAI ();
        }
    }
}

