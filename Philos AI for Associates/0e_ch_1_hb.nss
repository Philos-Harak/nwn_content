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
    object oMaster = GetMaster(oCreature);
    if(!NuiFindWindow(oMaster, ai_GetAssociateType(oMaster, oCreature) + "_widget"))
    {
        if(!GetLocalInt(oMaster, "AI_ASSOCIATE_WIDGET_OFF")) ai_CreateWidgetNUI(oMaster, oCreature);
    }
    //ai_Debug("0e_ch_1_hb", "18", GetName(oCreature) + " Heartbeat." +
    //         " MODE_FOLLOW: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW)) +
    //         " Action: " + IntToString(GetCurrentAction(oCreature)));
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoAssociateCombatRound(oCreature);
        return;
    }
    if(ai_CheckForCombat(oCreature)) return;
    // If we don't have a master then we exit.
    if(oMaster == OBJECT_INVALID) return;
    // Check and Initialize Henchman modes and magic modes.
    if(!GetLocalInt(oCreature, sAssociateModeVarname))
    {
        // Henchman modes.
        ai_SetAssociateMode(oCreature, AI_MODE_DISTANCE_CLOSE);
        SetLocalInt(oCreature, AI_HEAL_IN_COMBAT_LIMIT, 50);
        SetLocalInt(oCreature, AI_HEAL_OUT_OF_COMBAT_LIMIT, 70);
        // Henchman magic modes.
        ai_SetAssociateMagicMode(oCreature, AI_MAGIC_NORMAL_MAGIC_USE);
    }
    // If follow mode we do not want the NPC doing anything but follow.
    if(!ai_GetAssociateMode(oCreature, AI_MODE_FOLLOW))
    {
        if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND)) return;
        // Lets not interupt conversations.
        if(IsInConversation(oCreature)) return;
        if(!ai_GetAssociateMode(oCreature, AI_MODE_HEALING_OFF)) ai_TryHealingOutOfCombat(oCreature, oCreature);
        // Seek out and disable traps.
        object oTrap = GetNearestTrapToObject(oCreature);
        if(oTrap != OBJECT_INVALID &&
           ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS) &&
           ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
        if(ai_AssociateRetrievingItems(oCreature)) return;
        if(ai_GetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD))
        {
            ai_ScoutAhead(oCreature);
            return;
        }
    }
    // Finally we check to make sure we are following our master.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW)
    {
        // Follow master.
        if(GetDistanceBetween(oCreature, oMaster) > ai_GetFollowDistance(oCreature))
        {
            //ai_ClearCreatureActions(oCreature);
            //ai_Debug("0e_ch_1_hb", "66", "Follow master: " +
            //         " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
            //         " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
            if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
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
                if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
                {
                    //ai_Debug("0e_ch_1_hb", "72", "Going into search mode!");
                    SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
                }
                else SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
            }
            ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
        }
    }
}
