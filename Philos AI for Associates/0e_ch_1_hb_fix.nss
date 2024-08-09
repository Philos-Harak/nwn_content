/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_1_hb_fix
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate(Summons, Familiar, Companion)
  This will usually fire every 6 seconds (1 game round).
  This script reverts all NPC's back to the original games event scripts that
  were changed by Philos' AI scripts.

  To use just place this script and 0e_c2_1_hb_fix in the cleaned up override
  folder and remove the "_fix" part of the name.
  When the game runs it will change all creatures event scripts back to normal.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
//#include "0i_assoc_debug"
void main()
{
    object oCreature = OBJECT_SELF;
    ai_FixEventScripts(OBJECT_SELF);
    FloatingTextStringOnCreature("Philos' AI has reverted my event scripts!", oCreature, FALSE, FALSE);
}
