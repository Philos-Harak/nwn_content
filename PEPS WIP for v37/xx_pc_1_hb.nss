/*//////////////////////////////////////////////////////////////////////////////
 Script: xx_pc_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Player OnHeart beat script for PC AI;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_menus"
void ai_ActionFollow(object oCreature, object oTarget)
{
    if(GetLocalInt(OBJECT_SELF, AI_CURRENT_ACTION_MODE) == AI_LAST_ACTION_MOVE)
    {
        float fDistance = GetDistanceBetween(oCreature, oTarget);
        float fFollowDistance = ai_GetFollowDistance(oCreature);
        if(fDistance > fFollowDistance && !ai_GetIsInCombat(oCreature))
        {
            if(fDistance > fFollowDistance * 5.0) AssignCommand(oCreature, JumpToObject(oTarget));
            else
            {
                ClearAllActions();
                ActionMoveToObject(oTarget, TRUE, fFollowDistance);
            }
        }
        DelayCommand(1.0, ai_ActionFollow(oCreature, oTarget));
    }
}
void main()
{
    object oCreature = OBJECT_SELF;
    if(AI_DEBUG) ai_Debug("xx_pc_1_hb", "12", GetName(oCreature) + " heartbeat.");
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        ai_DoAssociateCombatRound(oCreature);
        return;
    }
    if(ai_CheckForCombat(oCreature, FALSE)) return;
    if(IsInConversation(oCreature)) return;
    if(ai_TryHealing(oCreature, oCreature)) return;
    if(ai_CheckNearbyObjects(oCreature)) return;
    if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
    {
        if(AI_DEBUG) ai_Debug("xx_ch_1_hb", "47", "Going into stealth mode!");
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
            if(AI_DEBUG) ai_Debug("xx_ch_1_hb", "61", "Going into search mode!");
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
            if(AI_DEBUG) ai_Debug("XX_pc_1_hb", "75", "Follow master: " +
                         " Stealth: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
                         " Search: " + IntToString(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
            SetLocalInt(oCreature, AI_CURRENT_ACTION_MODE, AI_LAST_ACTION_MOVE);
            ai_ActionFollow(oCreature, oAssociate);
            //ActionMoveToObject(oAssociate, TRUE, ai_GetFollowDistance(oCreature));
        }
    }
}
