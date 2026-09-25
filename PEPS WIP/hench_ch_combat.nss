/*//////////////////////////////////////////////////////////////////////////////
 Script: hench_ch_combat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  This is a compatibility script for Aielund Saga module.
  Associates (Summons, Familiars, Companions) OnSpellCastAt event script;
  Associate (Summons, Familiars, Companions) OnCombatRoundEnd event script;
  Fires at the end of each combat round (6 seconds).
  We just pass it to the real End of Round script.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    ExecuteScript("nw_ch_ac3");
}
