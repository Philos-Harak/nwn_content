/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion) OnHeart beat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    SetLocalInt(OBJECT_SELF, AI_ONSPAWN_EVENT, TRUE);
    ai_ChangeEventScriptsForAssociate(OBJECT_SELF);
    ExecuteScript("nw_ch_ac1");
}
