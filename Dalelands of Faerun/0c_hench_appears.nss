/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_hench_appears
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////

 Text Appears When script that does various quest related checks base on the
 sInput param sent.

 Param: Is_Our_Summons
    Returns TRUE if oHenchman is actually a summons for oPC's henchman.
 Param: Is_Our_Henchman
    Returns TRUE if oHenchman is oPC's henchman.
 Param: Has_Master
    Returns TRUE if oHenchman has a master.
 Param: Undead_Henchman
    Returns TRUE if oHenchman is undead.
 Param: Has_Undead_Associate
    Returns TRUE if oHenchman is an associate of one of our Henchman.
 Param: Has_Animal_Companion
    Returns TRUE if oHenchman has an animal companion summoned.
 Param: Has_Familiar
    Returns TRUE if oHenchman has a familiar summoned.
 Param: Has_Summons
    Returns TRUE if oHenchman has a summons.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_henchmen"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oHenchman = OBJECT_SELF;
    string sInput = GetScriptParam("sInput");
    //Debug("0c_hench_appear", "16", "sInput: " + sInput);
    if(sInput == "Is_Our_Henchman") return (GetMaster(oHenchman) == oPC);
    else if(sInput == "Is_Our_Summons")
    {
        if(GetMaster(oHenchman) == oPC)
        {
            return GetLocalInt(oHenchman, "0_Summon_ID");
        }
    }
    else if(sInput == "Has_Undead_Associate")
    {
        int nIndex = 1;
        object oCreature = GetHenchman(oHenchman, nIndex);
        while(oCreature != OBJECT_INVALID)
        {
            if(GetRacialType(oCreature) == RACIAL_TYPE_UNDEAD) return TRUE;
            oCreature = GetHenchman(oHenchman, ++nIndex);
        }
    }
    else if(sInput == "Has_Master") return GetMaster(oHenchman) != OBJECT_INVALID;
    else if(sInput == "Have_An_Open_Henchman_Slot" && !HasMaxNumberOfHenchman(oPC, TRUE)) return TRUE;
    else if(sInput == "Summons_With_No_Master")
    {
        if(GetLocalInt(oHenchman, "0_Summon_ID"))
        {
            return GetMaster(oHenchman) == OBJECT_INVALID;
        }
    }
    else if(sInput == "Undead_Henchman") return TRUE;
    else if(sInput == "Has_Animal_Companion")
    {
        object oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oHenchman);
        if(oCreature != OBJECT_INVALID) return TRUE;
    }
    else if(sInput == "Has_Familiar")
    {
        object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oHenchman);
        if(oCreature != OBJECT_INVALID) return TRUE;
    }
    else if(sInput == "Has_Summons")
    {
        object oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oHenchman);
        if(oCreature != OBJECT_INVALID) return TRUE;
    }
    return FALSE;
}
