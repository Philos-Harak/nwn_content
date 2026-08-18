/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_elc
 Programmer: Philos.
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when an effective Level character restriction is hit.

 Type 2, SubType 5, StrRef 68521
*///////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
#include "nwnx_elc"
#include "nwnx_creature"
void main()
{
    object oPC = OBJECT_SELF;
    int nType = NWNX_ELC_GetValidationFailureType ();
    int nSubType = NWNX_ELC_GetValidationFailureSubType ();
    int nStrRef = NWNX_ELC_GetValidationFailureMessageStrRef ();
    SetModuleError ("ELC", "0e_elc", "15", "Did not pass ELC: " +
                    GetName(oPC) +
                    ", Type = " +IntToString (nType) +
                    ", SubType = " +IntToString (nSubType) +
                    ", StrRef = " + IntToString (nStrRef));
    // Can use to make special item ability to reduce item level restiction.
    if (nSubType == NWNX_ELC_SUBTYPE_MIN_EQUIP_LEVEL)
    {
        object oItem = NWNX_ELC_GetValidationFailureItem ();
        int iItemType = GetBaseItemType (oItem);
        Debug("0i_creature", "27", "ELC: " + GetName(oPC) + " hit item level restriction for item type " + IntToString(iItemType));
        // If a skin is being equiped then skip the ILR.
        //if (iItemType == 73 || iItemType == 160) NWNX_ELC_SkipValidationFailure();
        if(!GetLocalInt(oPC, "0_Character_Loaded")) 
        {
            NWNX_Creature_RunUnequip(oPC, oItem);
            NWNX_ELC_SkipValidationFailure();
        }
    }
}

