/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oe_stealth_a
 Programmer: Unknown - Anphillia server.
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a creature enters stealth.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"
#include "inc_sqlite_time"

void main()
{
    object oPC = OBJECT_SELF;
    if (!GetIsPC (oPC)) return;
    int iTimeStamp = SQLite_GetTimeStamp ();
    int iTimeTillNextStealth = 12 - (iTimeStamp - GetLocalInt (oPC, "LAST_STEALTH_TIME"));
    if (iTimeTillNextStealth > 0)
    {
        SetActionMode (oPC, ACTION_MODE_STEALTH, FALSE);
        FloatingTextStringOnCreature ("You can enter stealth again in " + IntToString (iTimeTillNextStealth) + " seconds", oPC, FALSE);
    }
    else SetLocalInt (oPC, "LAST_STEALTH_TIME", iTimeStamp);
}

