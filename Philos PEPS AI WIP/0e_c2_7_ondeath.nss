/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnDeath script;
  This fires when the creature dies.
  Philos AI does not use this in override versions.
  Included for servers as an example to help add Philos AI to a server.
////////////////////////////////////////////////////////////////////////////////
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2002 Floodgate Entertainment
// Created By: Naomi Novik
// Created On: 12/22/2002
////////////////////////////////////////////////////////////////////////////////
// Modified By: Deva Winblood
// Modified On: April 1st, 2008
// Added Support for Dying Wile Mounted
*///////////////////////////////////////////////////////////////////////////////
#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "x3_inc_horse"
void main()
{
    int nClass = GetLevelByClass(CLASS_TYPE_COMMONER);
    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    object oKiller = GetLastKiller();

    if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB")&&GetIsObjectValid(GetMaster(OBJECT_SELF))) SetLocalInt(GetMaster(OBJECT_SELF),"bX3_STORE_MOUNT_INFO",TRUE);


    // If we're a good/neutral commoner,
    // adjust the killer's alignment evil
    if(nClass > 0 && (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(OBJECT_SELF, EventUserDefined(1007));
    }
    craft_drop_items(oKiller);
//****************************  ADDED AI CODE  *********************************
// Philos AI - At this time there is no code needed for Monster OnDeath events
//****************************  ADDED AI CODE  *********************************
}
