/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb_fix
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script;
  This will usually fire every 6 seconds (1 game round).
  This script reverts all monsters and NPC's back to the original games event
  scripts that were changed by Philos' AI scripts.

  To use just place this script and 0e_ch_1_hb_fix in the cleaned up override
  folder and remove the "_fix" part of the name.
  When the game runs it will change all creatures event scripts back to normal.
  and set them up for the default bioware AI scripts.
*///////////////////////////////////////////////////////////////////////////////
#include "x2_inc_switches"
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    ai_FixEventScriptsForMonster(OBJECT_SELF);
    //SpeakString("Philos' AI has reverted my event scripts!");
    // * Goes through and sets up which shouts the NPC will listen to.
    SetListeningPatterns();
    WalkWayPoints();
}
