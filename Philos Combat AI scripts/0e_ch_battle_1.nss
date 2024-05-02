/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_battle_1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate on heartbeat script when in combat.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_Assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_ch_battle_1", "12", GetName(oCreature) + " Heartbeat in combat!");
    if (ai_GetIsBusy (oCreature) || ai_Disabled (oCreature)) return;
    // Lets see if there are enemies near by since we are not in combat.
    object oEnemy = ai_GetNearestEnemy (oCreature, 1, 7, 7, -1, -1, TRUE);
    if (oEnemy != OBJECT_INVALID && GetDistanceBetween(oEnemy, oCreature) <= AI_RANGE_PERCEPTION)
    {
        ai_DoAssociateCombatRound (oCreature);
        return;
    }
    // We need to check for invisible creatures.
    else if(ai_SearchForInvisibleCreature(oCreature)) return;
    // ***************************** END OF COMBAT *****************************
    ai_ClearCombatState (oCreature);
    //ai_Debug ("0e_ch_battle_1", "25", GetName (oCreature) + "'s combat has ended!");
    //ai_Debug("0e_ch_battle_1", "26", "Follow master: " +
    //       " Stealth: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH)) +
    //       " Search: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH)));
    if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
    {
        //ai_Debug("0e_ch_battle_1", "31", "Going into stealth mode!");
        ActionUseSkill(SKILL_HIDE, oCreature);
        ActionUseSkill(SKILL_MOVE_SILENTLY, oCreature);
    }
        else if(ai_GetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
    {
        //ai_Debug("0e_ch_battle_1", "37", "Going into search mode!");
        ActionUseSkill(SKILL_SEARCH, oCreature);
    }
    ActionMoveToObject(GetMaster(oCreature), TRUE, ai_GetFollowDistance(oCreature));
}
