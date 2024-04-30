/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_battle_2
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiars, Companions) on perception script when in combat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    /*if(GetLastPerceptionSeen ())
    {
        ai_Debug("0e_ch_battle_2", "13", GetName(oCreature) + " sees " +
                 GetName(GetLastPerceived ()) + ".");
    }
    if(GetLastPerceptionHeard ())
    {
        ai_Debug("0e_ch_battle_2", "18", GetName(oCreature) + " heard " +
                 GetName(GetLastPerceived ()) + ".");
    }*/
    if (!ai_GetIsBusy (oCreature) && !ai_Disabled (oCreature) && ai_GetIsInCombat(oCreature))
    {
        ai_DoAssociateCombatRound(oCreature);
    }
}





