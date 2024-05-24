/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_battle
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
    if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
    {
        object oTarget = GetNearestSeenEnemy();
        if(GetDistanceBetween(oCreature, oTarget) <= 6.0)
        {
            if(GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0)
            {
                TalentFlee(oTarget);
                return;
            }
        }
    }
    ai_DoMonsterCombatRound (oCreature);
}
