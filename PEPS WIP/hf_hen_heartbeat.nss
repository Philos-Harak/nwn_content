/*//////////////////////////////////////////////////////////////////////////////
 Script: hf_hen_combat
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Darkness over Daggerford - henchman developement script.
  OnCombatRoundEnd event script;
  Fires at the end of each combat round (6 seconds).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
#include "x2_i0_spells"
void HenchmanSetHome(object oHenchman, location lHome)
{
    SetLocalLocation(oHenchman, "HF_HENCHMAN_HOME_LOC", lHome);
    SetLocalLocation(oHenchman, "X0_RESPAWN_LOC", lHome);
    SetLocalLocation(oHenchman, "NW_ASSOCIATE_START", lHome);
    SetLocalInt(oHenchman, "HF_HENCHMAN_HOME_DEFINED", 1);
}
void HenchmanHire(object oHenchman, object oPC)
{
    // remember that we've met the PC and heal up (once only)
    if (GetLocalInt(oHenchman, "HF_HENCHMAN_KNOWS_"+GetTag(oPC)) == 0)
    {
        SetLocalInt(oHenchman, "HF_HENCHMAN_KNOWS_"+GetTag(oPC), 1);
        ForceRest(oHenchman);
    }
    // remember where our home location is
    if (GetLocalInt(oHenchman, "HF_HENCHMAN_HOME_DEFINED") == 0)
    {
        HenchmanSetHome(oHenchman, GetLocation(oHenchman));
    }
    // setup default henchman modes
    SetAssociateListenPatterns(oHenchman);
    SetLocalInt(oHenchman, "NW_COM_MODE_COMBAT", ASSOCIATE_COMMAND_ATTACKNEAREST);
    SetLocalInt(oHenchman, "NW_COM_MODE_MOVEMENT", ASSOCIATE_COMMAND_FOLLOWMASTER);
    // make sure henchman is not immortal
    SetImmortal(oHenchman, FALSE);
    SetPlotFlag(oHenchman, FALSE);
    // hire the henchman
    SetLocalObject(oHenchman, "HF_HENCHMAN_LAST_MASTER", oPC);
    AddHenchman(oPC, oHenchman);
}
// create or destroy a tombstone map note
void HenchmanTombstone(object oHenchman, int nState)
{
    if (nState == TRUE)
    {
        object oMarker = CreateObject(OBJECT_TYPE_WAYPOINT, "hf_tombstone", GetLocation(oHenchman));
        SetLocalObject(oHenchman, "HF_HENCHMAN_TOMBSTONE", oMarker);
    }
    else
    {
        object oMarker = GetLocalObject(oHenchman, "HF_HENCHMAN_TOMBSTONE");
        DeleteLocalObject(oHenchman, "HF_HENCHMAN_TOMBSTONE");
        SetMapPinEnabled(oMarker, FALSE);
        DestroyObject(oMarker);
    }
}

// henchman raise event
void HenchmanRaise(object oHench, object oPC)
{
    // raise from dead
    SetCommandable(TRUE, oHench);
    AssignCommand(oHench, ClearAllActions());
    AssignCommand(oHench, PlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 1.0, 6.0));
    SetAssociateState(NW_ASC_MODE_DYING, FALSE, oHench);
    SetPlotFlag(oHench, FALSE);
    SetAssociateState(NW_ASC_IS_BUSY, FALSE, oHench);
    // make sure we have at least 5 hit points when we get up
    if (GetCurrentHitPoints(oHench) < 5)
    {
        int nHits = GetCurrentHitPoints(oHench);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(5-nHits), oHench);
    }
    // remove any tombstones
    HenchmanTombstone(oHench, FALSE);
    // reset henchie state
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE, oHench);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE, oHench);
    // automatically re-hire
    if (GetIsObjectValid(oPC))
    {
        ClearPersonalReputation(oPC, oHench);
        if (GetLocalObject(oHench, "HF_HENCHMAN_LAST_MASTER") == oPC)
        {
            if (GetMaster(oHench) != oPC)
            {
                if (!GetIsDead(oPC))
                {
                    HenchmanHire(oHench, oPC);
                }
            }
        }
    }
}
void main()
{
    object oCreature = OBJECT_SELF;
    // get up after combat ends
    if(GetAssociateState(NW_ASC_MODE_DYING, oCreature))
    {
        object oPC = GetMaster(oCreature);
        if(!ai_GetIsInCombat(oPC)) HenchmanRaise(oCreature, oPC);
        else if(GetCommandable())
        {
            ActionPlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 6500000000.0);
            SetCommandable(FALSE);
        }
    }
    // run the standard henchman heartbeat script
    ExecuteScript("nw_ch_ac1", oCreature);
}
