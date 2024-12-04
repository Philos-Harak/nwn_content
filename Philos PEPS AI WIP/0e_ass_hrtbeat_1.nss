/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ass_hrtbeat_1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate (Summons, Familiar, Companion) heart beat script.

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
/*#include "0i_associates"
#include "0i_traps"
void AssociateRetrieveItems ();
void main()
{
    //Debug ("0e_hen_hrtbeat_1", "25", GetName (OBJECT_SELF) + " Heartbeat!" +
    //       " Busy: " + IntToString (GetIsBusy ()) + " Disabled: " + IntToString (Disabled ()) +
    //       " MODE_FOLLOW: " + IntToString (GetAssociateMode (MODE_FOLLOW)));
    // If we are disabled or busy then we don't need to do the heartbeat checks.
    if (!GetIsBusy () && !Disabled ())
    {
        // If there are enemies near lets attack.
        if (GetNearestEnemy (OBJECT_SELF, 1, 7, 7) != OBJECT_INVALID && AssociateCanAttack ())
        {
            //Debug ("0e_ass_hrtbeat_1", "34", "Heartbeat! We see " + GetName (GetNearestPerceivedEnemy ()) + " so lets attack!");
            DoAssociateCombatRound ();
        }
        // Now we check for traps, loot, or scouting ahead.
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
                    AssociateRetrieveItems ();
                    if (GetAssociateMode (MODE_SCOUT_AHEAD)) ScoutAhead (OBJECT_SELF);
                }
                // Finally we check to make sure we are following our master.
                if (GetCurrentAction (OBJECT_SELF) != ACTION_FOLLOW)
                {
                    // Follow master.
                    if (GetDistanceToObject (oMaster) > GetFollowDistance ())
                    {
                        ClearAllActions ();
                        //Debug ("0e_ass_hrtbeat", "64", "Follow master: " +
                        //       " Stealth: " + IntToString (GetAssociateMode (MODE_AGGRESSIVE_STEALTH)) +
                        //       " Search: " + IntToString (GetAssociateMode (MODE_AGGRESSIVE_SEARCH)));
                        if (GetAssociateMode (MODE_AGGRESSIVE_STEALTH))
                        {
                            //Debug ("0e_ass_hrtbeat_1", "69", "Going into stealth mode!");
                            ActionUseSkill (SKILL_HIDE, OBJECT_SELF);
                            ActionUseSkill (SKILL_MOVE_SILENTLY,OBJECT_SELF);
                        }
                        else if (GetAssociateMode (MODE_AGGRESSIVE_SEARCH))
                        {
                            //Debug ("0e_ass_hrtbeat_1", "75", "Going into search mode!");
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

void CheckLoot (object oObject)
{
    int bPickItUp = FALSE, bPickedItemUp = FALSE, nItemType;
    object oAssociate = OBJECT_SELF;
    object oMaster = GetMaster (oAssociate);
    object oItem = GetFirstItemInInventory (oObject);
    while (oItem != OBJECT_INVALID)
    {
       if (GetResRef (oItem) == "nw_it_gold001")
       {
          SendMessages (GetName (oAssociate) + " has retieved " + IntToString (GetGold (oObject)) + " gold from the " + GetName (oObject)+ ".", COLOR_GRAY, oMaster);
          DelayCommand (0.2f, AssignCommand (oObject, ActionGiveItem (oItem, oMaster)));
          bPickedItemUp = TRUE;
       }
       else if (GetDroppableFlag (oItem))
       {
           if (GetLocalInt (oItem, "0_Important")) bPickItUp = TRUE;
           else if (GetAssociateMode (MODE_PICKUP_GEMS_ITEMS, oAssociate))
           {
               string sResRef = GetStringLeft (GetResRef (oItem), 2);
               if (GetNumberOfProperties (oItem) > 0) bPickItUp = TRUE;
               else if (sResRef == "a_" || sResRef == "g_") bPickItUp = TRUE;
           }
           else if (GetAssociateMode (MODE_PICKUP_MAGIC_ITEMS))
           {
              if (GetNumberOfProperties (oItem) > 0) bPickItUp = TRUE;
           }
           else bPickItUp = TRUE;
           if (bPickItUp)
           {
               bPickedItemUp = TRUE;
               DelayCommand (0.2f, AssignCommand (oObject, ActionGiveItem (oItem, oMaster)));
               if (GetSkillRank (SKILL_KNOWLEDGE, oAssociate, TRUE) > 0) IdentifyItemVsKnowledge (oAssociate, oItem);
               if (GetIdentified (oItem)) SendMessages (GetName (oAssociate) + " has retieved a " + GetName (oItem) + " from the " + GetName (oObject) + ".", COLOR_GRAY, oMaster);
               else
               {
                  string sBaseName = GetStringByStrRef (StringToInt (Get2DAString ("baseitems", "name", GetBaseItemType (oItem))));
                  SendMessages (GetName (oAssociate) + " has retieved a " + sBaseName + " from the " + GetName (oObject) + ".", COLOR_GRAY, oMaster);
               }
           }
       }
       bPickItUp = FALSE;
       oItem = GetNextItemInInventory (oObject);
    }
}

void CheckTreasureObject (object oObject, string sHenchmanName)
{
    if (GetIsTrapped (oObject))
    {
        int nTrapType = GetTrapBaseType (oObject);
        SetTrapDisabled (oObject);
        TriggerTrap (OBJECT_SELF, oObject, nTrapType, GetLocalInt (oObject, "0_AOE_Trap"));
        // We hit a trap! So we havn't looted this yet.
        SetLocalInt (oObject, "0_LOOTED_" + sHenchmanName, FALSE);
    }
    else
    {
        CheckLoot (oObject);
    }
}

void AssociateRetrieveItems ()
{
    if (GetAssociateMode (MODE_PICKUP_ITEMS))
    {
        // Check area for creatures or chests that might have items.
        int nObjectType;
        string sHenchmanName = RemoveIllegalCharacters (GetName (OBJECT_SELF));
        float fDistance = 0.0f;
        location lLocation = GetLocation (OBJECT_SELF);
        object oObject = GetFirstObjectInShape (SHAPE_SPHERE, 20.0f, lLocation, TRUE, OBJECT_TYPE_PLACEABLE);
        while (oObject != OBJECT_INVALID)
        {
            //Debug ("0e_hen_hrtbeat_1", "172", GetName (oObject) + " being checked!" + " sTag: " + GetTag (oObject));
            if (GetHasInventory (oObject) && GetTag (oObject) != "remains")
            {
                // Skip checking if the NPC has already looted this placeable.
                if (!GetLocalInt (oObject, "0_LOOTED_" + sHenchmanName))
                {
                    if (GetTrapDetectedBy (oObject, OBJECT_SELF))
                    {
                        if (!GetLocalInt (oObject, "0_SEE_TRAP_" + sHenchmanName))
                        {
                            PlayVoiceChat (VOICE_CHAT_STOP);
                            SpeakString ("That " + GetName (oObject) + " is trapped!");
                            SetLocalInt (oObject, "0_SEE_TRAP_" + sHenchmanName, TRUE);
                        }
                        if (GetAssociateMode (MODE_DISARM_TRAPS, OBJECT_SELF) &&
                            !GetLocalInt (oObject, "0_DISARM_TRAP_" + sHenchmanName))
                        {
                            SetLocalInt (oObject, "0_DISARM_TRAP_" + sHenchmanName, TRUE);
                            AttemptToDisarmTrap (OBJECT_SELF, oObject, TRUE);
                        }
                        return;
                    }
                    if (GetLocked (oObject))
                    {
                        if (!GetLocalInt (oObject, "0_SEE_LOCK_" + sHenchmanName))
                        {
                            SpeakString ("That " + GetName (oObject) + " is locked!");
                            SetLocalInt (oObject, "0_SEE_LOCK_" + sHenchmanName, TRUE);
                        }
                        if (GetAssociateMode (MODE_OPEN_LOCKS, OBJECT_SELF)) AttemptToByPassLock (OBJECT_SELF, oObject);
                        return;
                    }
                    SetLocalInt (oObject, "0_LOOTED_" + sHenchmanName, TRUE);
                    // If the container has not been rolled and it has a script to roll treasure then roll it.
                    if (!GetLocalInt (oObject, "0_Used") &&
                        GetEventScript (oObject, EVENT_SCRIPT_PLACEABLE_ON_OPEN) == "0e_rolltreasure")
                    {
                        // Setsup the server to check the player on treasure generation.
                        SetLocalObject (oObject, "0_PC", GetMaster ());
                        ExecuteScript ("0e_rolltreasure", oObject);
                    }
                    ClearAllActions ();
                    DoPlaceableObjectAction (oObject, PLACEABLE_ACTION_USE);
                    CheckTreasureObject (oObject, sHenchmanName);
                    AssignCommand (oObject, ActionPlayAnimation (ANIMATION_PLACEABLE_CLOSE));
                    //return;
                }
            }
            oObject = GetNextObjectInShape (SHAPE_SPHERE, 20.0f, lLocation, TRUE, OBJECT_TYPE_PLACEABLE);
        }
    }
}



