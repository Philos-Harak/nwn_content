/*//////////////////////////////////////////////////////////////////////////////
// Script Name: ai_animal
////////////////////////////////////////////////////////////////////////////////
 ai script for animals or other basic creatures that don't use items or ranged attacks.
 OBJECT_SELF is the creature running the ai.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    // *************************  MELEE ATTACKS  *******************************
    object oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, ai_GetNumOfEnemiesInRange(oCreature));
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryHarmfulMeleeTalents(oCreature, oTarget)) return;
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
}
