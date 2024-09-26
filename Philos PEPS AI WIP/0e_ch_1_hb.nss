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
    //ai_Debug("0e_ch_1_hb", "18", GetName(oCreature) + " Heartbeat." +
    //         " MODE_FOLLOW: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_FOLLOW)) +
    //         " Action: " + IntToString(GetCurrentAction(oCreature)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // If we don't have a master then we exit.
    object oMaster = GetMaster(oCreature);
    if(oMaster == OBJECT_INVALID) return;
    if(GetIsPC(oMaster))
    {
        string sAssociateType = ai_GetAssociateType(oMaster, oCreature);
        // We have to wait for a heartbeat to get our master so we can pull up our menu.
        if(!NuiFindWindow(oMaster, sAssociateType + "_widget"))
        {
            // If this associate has no data then lets create some and maybe setup our widget.
            // We do this here since they have to be an associate of a player.
            json jGeometry = ai_GetAssociateDbJson(oMaster, sAssociateType, "locations");
            if(JsonGetType(JsonObjectGet(jGeometry, "x")) == JSON_TYPE_NULL)
            {
                ai_CheckDataAndInitialize(oMaster, sAssociateType);
                ai_GetAssociateDataFromDB(oMaster, oCreature);
            }
            if(!ai_GetWidgetButton(oMaster, BTN_WIDGET_OFF, oCreature, sAssociateType))
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
        if(ai_CheckForCombat(oCreature)) return;
        // Lets not interupt conversations.
        if(IsInConversation(oCreature)) return;
        if(ai_TryHealing(oCreature, oCreature)) return;
        // In command mode we let the player tell us what to do.
        if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
        {
            // When picking up items we also check for traps and locks so if
            // we are not in pickup mode we need to do that here.
            if(!ai_GetAIMode(oCreature, AI_MODE_PICKUP_ITEMS))
            {
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
            }
            if(ai_AssociateRetrievingItems(oCreature)) return;
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
        //         " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
        //         " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
        if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
        {
            //ai_Debug("0e_ch_1_hb", "67", "Going into stealth mode!");
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
                //ai_Debug("0e_ch_1_hb", "72", "Going into search mode!");
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
