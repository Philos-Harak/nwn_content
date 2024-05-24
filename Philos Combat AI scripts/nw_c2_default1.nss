/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script;
  This will usually fire every 6 seconds (1 game round).
  We use this to change the creatures event scripts to the new AI event scripts.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "x2_inc_switches"
void main()
{
    ai_OnMonsterSpawn(OBJECT_SELF, GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL));
    ExecuteScript("0e_c2_1_hb");
}
