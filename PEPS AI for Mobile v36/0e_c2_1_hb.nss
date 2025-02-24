/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script;
  This will usually fire every 6 seconds (1 game round).

  I am reverting the AI script back to the games default scripts for efficiency.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    SetLocalInt(OBJECT_SELF, AI_ONSPAWN_EVENT, TRUE);
    ai_ChangeEventScriptsForMonster(OBJECT_SELF);
    ExecuteScript("nw_c2_default1");
}
