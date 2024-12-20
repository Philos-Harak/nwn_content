/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
void main()
{
    object oCreature = OBJECT_SELF;
    if(AI_DEBUG) ai_Debug("0e_ch_1_hb", "12", GetName(oCreature) + " Heartbeat." +
                 " MODE_FOLLOW: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_FOLLOW)) +
                 " Action: " + IntToString(GetCurrentAction(oCreature)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // If we are an associate and don't have a master then exit.
    object oMaster = GetMaster(oCreature);
    if(oMaster == OBJECT_INVALID) return;
    // ***** Code for Henchman data and menus *****
    if(ai_GetIsCharacter(oMaster))
    {
        string sAssociateType = ai_GetAssociateType(oMaster, oCreature);
        // We need to have a master to setup our database and if our follow
        // range is not set then we need to either initialize or pull our info.
        if(JsonGetType(ai_GetAssociateDbJson(oMaster, sAssociateType, "locations")) == JSON_TYPE_NULL)
        {
            // If the player doesn't have data saved on them then create or get.
            // We do this here since they have to be an associate of the player.
            ai_CheckDataAndInitialize(oMaster, sAssociateType);
            ai_GetAssociateDataFromDB(oMaster, oCreature);
        }
        // Widget code.
        if(!ai_GetWidgetButton(oMaster, BTN_WIDGET_OFF, oCreature, sAssociateType))
        {
            if(!NuiFindWindow(oMaster, sAssociateType + "_widget"))
            {
                ai_CreateWidgetNUI(oMaster, oCreature);
            }
        }
    }
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAIMode(oCreature, AI_MODE_FOLLOW))
    {
        if(ai_GetAIMode(oCreature, AI_MODE_STAND_GROUND)) return;
        if(ai_GetIsInCombat(oCreature))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        if(ai_CheckForCombat(oCreature, FALSE)) return;
        if(IsInConversation(oCreature)) return;
        // In command mode we let the player tell us what to do.
        if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
        {
            if(ai_TryHealing(oCreature, oCreature)) return;
            // When picking up items we also check for traps and locks so if
            // we are not in pickup mode we need to do that here.
            if(ai_AssociateRetrievingItems(oCreature)) return;
            // Seek out and disable traps.
            if(ai_GetAIMode(oCreature, AI_MODE_DISARM_TRAPS))
            {
                object oTrap = GetNearestTrapToObject(oCreature);
                if(oTrap != OBJECT_INVALID &&
                   GetDistanceBetween(oMaster, oTrap) < GetLocalFloat(oCreature, AI_TRAP_CHECK_RANGE) &&
                   ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
            }
            // Seek out and disable locks.
            if(ai_GetAIMode(oCreature, AI_MODE_PICK_LOCKS) ||
               ai_GetAIMode(oCreature, AI_MODE_BASH_LOCKS))
            {
                object oLock = ai_GetNearestLockedObject(oCreature);
                if(oLock != OBJECT_INVALID &&
                   GetDistanceBetween(oMaster, oLock) < GetLocalFloat(oCreature, AI_LOCK_CHECK_RANGE) &&
                   ai_AttemptToByPassLock(oCreature, oLock)) return;
            }
            if(ai_GetAIMode(oCreature, AI_MODE_SCOUT_AHEAD))
            {
                ai_ScoutAhead(oCreature);
                return;
            }
        }
    }
    // Finally we check to make sure we are following our master.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW)
    {
        //ai_Debug("0e_ch_1_hb", "66", "Follow master: " +
        //         " Stealth: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
        //         " Search: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
        if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
        {
            if(AI_DEBUG) ai_Debug("0e_ch_1_hb", "94", "Going into stealth mode!");
            int nStealth = GetSkillRank(SKILL_HIDE, oCreature);
            nStealth += GetSkillRank(SKILL_MOVE_SILENTLY, oCreature);
            if(nStealth / 2 >= ai_GetCharacterLevels(oCreature))
            {
                SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
            }
        }
        else
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
            {
                if(AI_DEBUG) ai_Debug("0e_ch_1_hb", "108", "Going into search mode!");
                SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            }
            else SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
        }
        // Follow master.
        if(GetDistanceBetween(oCreature, oMaster) > ai_GetFollowDistance(oCreature))
        {
            if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
            {
                object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
                if(oTarget == OBJECT_INVALID) oTarget = oMaster;
                ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oCreature));
            }
        }
    }
}
