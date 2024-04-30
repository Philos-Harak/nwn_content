//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////
//:://////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 1st, 2008
//:: Added Support for Dying Wile Mounted
//:://///////////////////////////////////////////////

#include "x2_inc_compon"
#include "x0_i0_spawncond"
#include "x3_inc_horse"
//******************************  ADDED AI CODE  *******************************
#include "0i_associates"
//******************************  ADDED AI CODE  *******************************

void main()
{
    object oCreature = OBJECT_SELF;
    object oKiller = GetLastKiller();
    if (GetLocalInt(GetModule(),"X3_ENABLE_MOUNT_DB") &&
        GetIsObjectValid(GetMaster(OBJECT_SELF)))
    {
        SetLocalInt(GetMaster(oCreature),"bX3_STORE_MOUNT_INFO",TRUE);
    }
    int nAlign = GetAlignmentGoodEvil(oCreature);
    // If we're a good/neutral commoner, adjust the killer's alignment evil.
    if(GetLevelByClass(CLASS_TYPE_COMMONER) > 0 &&
       (nAlign == ALIGNMENT_GOOD || nAlign == ALIGNMENT_NEUTRAL))
    {
        AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
    }
    // Call to allies to let them know we're dead
    SpeakString("AI_I_AM_DEAD", TALKVOLUME_SILENT_TALK);
    // NOTE: the OnDeath user-defined event does not
    // trigger reliably and should probably be removed
    if(GetSpawnInCondition(NW_FLAG_DEATH_EVENT))
    {
         SignalEvent(oCreature, EventUserDefined(1007));
    }
    craft_drop_items(oKiller);

    //****************************  ADDED AI CODE  *****************************
    ai_OnDeath(oCreature, oKiller);
    //****************************  ADDED AI CODE  *****************************

}
