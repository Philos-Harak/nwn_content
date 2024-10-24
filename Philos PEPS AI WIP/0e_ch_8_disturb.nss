/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_8_disturb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates (Summons, Familiars, Companions) OnDisturbed event script.
  Fires when the inventory of oCreature is changed i.e. added or removed.
  Creatures can't have items added or removed from its inventory (it's not a
    container), then the only way this fires for creatures if something is stolen.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
void main()
{
    ai_Debug("0e_ch_8_disturb", "14", GetName(OBJECT_SELF) + " is been disturbed!");
    // We do nothing at the moment... lets not mess up our factions ok?
    // This should be defined by the server admins and is commented out.
    //if(ai_GetIsBusy(OBJECT_SELF, FALSE) || ai_Disabled()) return;
    //object oTarget = GetLastDisturbed();
    //if (oTarget != OBJECT_INVALID) ai_DoMonsterCombatRound ();
}


