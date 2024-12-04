/*//////////////////////////////////////////////////////////////////////////////
 Script: x2_def_heartbeat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  !!!!! Used in Development Folder
  !!!!! Commands creatures in the module: Neverwinter Nights - Infinite Dungeons

  In all other modules it will run the default creature script nw_c2_default1.
  Monster OnHeartbeat script
  We use this to change the creatures event scripts to the new AI event scripts.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
//#include "0i_replace_j_ai"
#include "0i_single_player"
#include "x2_inc_switches"
void main()
{
    ai_OnMonsterSpawn(OBJECT_SELF, GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL));
}

