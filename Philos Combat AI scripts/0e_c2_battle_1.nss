/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_battle_1
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster on heartbeat script when in combat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_c2_battle_1", "12", GetName(oCreature) + " Heartbeat in combat!");
    if (ai_GetIsBusy (oCreature) || ai_Disabled (oCreature)) return;
    // Lets see if there are enemies near by since we are not in combat.
    object oEnemy = ai_GetNearestEnemy (oCreature, 1, 7, 7, -1, -1, TRUE);
    if (oEnemy != OBJECT_INVALID && GetDistanceToObject(oEnemy) <= AI_RANGE_PERCEPTION)
    {
        ai_DoMonsterCombatRound (oCreature);
        return;
    }
    // We need to check for invisible creatures.
    else if(ai_SearchForInvisibleCreature(oCreature)) return;
    // ***************************** END OF COMBAT *****************************
    // Countdown for the end of combats wrap up.
    int nRound = GetLocalInt(oCreature, "AI_WRAP_UP_TIMER") + 1;
    //ai_Debug("0e_c2_battle_1", "26", GetName(OBJECT_SELF) + "'s combat is ending, round: " + IntToString(nRound));
    // Our wrap up timer is done... lets end wrap up for the end of combat.
    if(nRound >= AI_AFTER_COMBAT_WRAP_IN_ROUNDS)
    {
        //ai_Debug("0e_c2_battle_1", "30", GetName(OBJECT_SELF) + "'s combat is over!");
        DeleteLocalInt(oCreature, "AI_WRAP_UP_TIMER");
        ai_ClearCombatState (oCreature);
        // Should we go into stealth mode after combat?
        if (GetLocalString(oCreature, AI_DEFAULT_SCRIPT) == "ai_ambusher" &&
            !GetActionMode(oCreature, ACTION_MODE_STEALTH))
        {
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        }
    }
    // Wrap up is not done so lets add to the timer.
    else SetLocalInt(oCreature, "AI_WRAP_UP_TIMER", nRound);
    // ******************** ACTIONS DURING THE END OF COMBAT *******************
    // Don't check if we are wounded when dominated or a summoned.
    int nAssociateType = GetAssociateType(oCreature);
    if(nAssociateType == ASSOCIATE_TYPE_SUMMONED ||
       nAssociateType == ASSOCIATE_TYPE_DOMINATED) return;
    // Check to see if we are hurt enough to get healing.
    int nHealth = ai_GetPercHPLoss(oCreature);
    // Enemies always heal up to full.
    if (nHealth >= 100) return;
    //ai_Debug("0e_c2_battle_1", "51", GetName(OBJECT_SELF) + " is wounded!");
    // If i'm wounded then see if I can heal myself.
    if(ai_TryHealingTalentOutOfCombat(oCreature, oCreature)) return;
    //ai_Debug("0e_c2_battle_1", "54", GetName(OBJECT_SELF) + " is telling others they are wounded!");
    // Lets let other NPC's know we are hurt and need healing.
    SpeakString(AI_I_AM_WOUNDED, TALKVOLUME_SILENT_TALK);
}
