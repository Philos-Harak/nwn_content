/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Player OnHeart beat script for PC AI;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("xx_pc_1_hb", "12", GetName(oCreature) + " heartbeat.");
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoAssociateCombatRound(oCreature);
        return;
    }
    if(ai_CheckForCombat(oCreature)) return;
    if(IsInConversation(oCreature)) return;
    if(ai_TryHealing(oCreature, oCreature)) return;
    // When picking up items we also check for traps and locks so if
    // we are not in pickup mode we need to do that here.
    if(!ai_GetAIMode(oCreature, AI_MODE_PICKUP_ITEMS))
    {
        // Seek out and disable traps.
        if(ai_GetAIMode(oCreature, AI_MODE_DISARM_TRAPS))
        {
            object oTrap = GetNearestTrapToObject(oCreature);
            if(oTrap != OBJECT_INVALID &&
               GetDistanceBetween(oCreature, oTrap) < GetLocalFloat(oCreature, AI_TRAP_CHECK_RANGE) &&
               ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
        }
        // Seek out and disable locks.
        if(ai_GetAIMode(oCreature, AI_MODE_PICK_LOCKS) ||
           ai_GetAIMode(oCreature, AI_MODE_BASH_LOCKS))
        {
            object oLock = ai_GetNearestLockedObject(oCreature);
            if(oLock != OBJECT_INVALID &&
               GetDistanceBetween(oCreature, oLock) < GetLocalFloat(oCreature, AI_LOCK_CHECK_RANGE) &&
               ai_AttemptToByPassLock(oCreature, oLock)) return;
        }
    }
    if(ai_AssociateRetrievingItems(oCreature)) return;
    if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
    {
        //ai_Debug("0e_ch_1_hb", "47", "Going into stealth mode!");
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
            //ai_Debug("0e_ch_1_hb", "61", "Going into search mode!");
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
        }
        else SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
     }
    // Finally we check to make sure we are following.
    if(GetCurrentAction(oCreature) != ACTION_FOLLOW)
    {
        // Follow associate.
        object oAssociate = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
        if(oAssociate == OBJECT_INVALID || GetMaster(oAssociate) != oCreature) return;
        if(GetDistanceBetween(oCreature, oAssociate) > ai_GetFollowDistance(oCreature))
        {
            ai_ClearCreatureActions();
            //ai_Debug("XX_pc_1_hb", "75", "Follow master: " +
            //         " Stealth: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
            //         " Search: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
            ActionMoveToObject(oAssociate, TRUE, ai_GetFollowDistance(oCreature));
        }
    }
}
