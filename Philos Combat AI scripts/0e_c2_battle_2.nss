/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_battle_2
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster on perception script when in combat!
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen ())
    {
        ai_Debug("0e_c2_battle_2", "14", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("0e_c2_battle_2", "19", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived ()) + ".");
    }*/
    if (!ai_GetIsBusy (oCreature) && !ai_Disabled (oCreature) && ai_GetIsInCombat(oCreature))
    {
        ai_DoMonsterCombatRound(oCreature);
    }
}
