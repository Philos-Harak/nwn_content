/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_bloodmane
//////////////////////////////////////////////////////////////////////////////////////////////////////
 AI combat action scripts for Bloodmane - Orc Warlord(Barbarian - Example).
 To use this AI set the variable string "AI_DEFAULT_SCRIPT" to "ai_bloodmane" on the creature.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //**************************************************************************
    //************************ START SPECIAL AI SCRIPTS ************************
    //**************************************************************************
    int nRound = ai_GetCurrentRound(oCreature);
    // First round cuss and animate!
    if(nRound == 1)
    {
        // Make him taunt the player!
        ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT);
        PlayVoiceChat(Random(4), oCreature);
    }
    // Second round go into a Rage.
    else if(nRound == 2)
    {
        // Use Rage!
        if(ai_TryBarbarianRageFeat(oCreature)) return;
        // If for some reason he doesn't have a rage then charge into melee!
        object oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, ai_GetNumOfEnemiesInRange(oCreature));
        if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
        // Change Bloodmane's ai to Barbarian since we are done with his special ai.
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_barbarian");
    }
    //**************************************************************************
    //************************ END SPECIAL AI SCRIPTS **************************
    //**************************************************************************
}
