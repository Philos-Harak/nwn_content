/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_battle
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate on heartbeat script when in combat.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_Assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    //ai_Debug("0e_ch_battle_1", "12", GetName(oCreature) + " Heartbeat in combat!");
    if (ai_GetIsBusy (oCreature) || ai_Disabled (oCreature)) return;
    ai_DoAssociateCombatRound (oCreature);
}
