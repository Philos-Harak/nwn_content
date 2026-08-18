/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oe_stealth_a
 Programmer: Philos.
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when an Item Level restriction is hit or a character validation issue.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
#include "nwnx_elc"

void main()
{
    object oPC = OBJECT_SELF;
    int bSkip = FALSE;
    int iSubType = NWNX_ELC_GetValidationFailureSubType ();
    if (iSubType == NWNX_ELC_SUBTYPE_MIN_EQUIP_LEVEL)
    {
        object oItem = NWNX_ELC_GetValidationFailureItem ();
        int iItemType = GetBaseItemType (oItem);
        Debug("0i_creature", "1662", "ELC: " + GetName(oPC) + " hit item level restriction for item type " + IntToString(iItemType));
        // If a skin is being equiped then skip the ILR.
        //if (iItemType == 73 || iItemType == 160) NWNX_ELC_SkipValidationFailure();

    }
    if(bSkip)
    {
        int iType = NWNX_ELC_GetValidationFailureType ();
        int iStrRef = NWNX_ELC_GetValidationFailureMessageStrRef ();
        SendMessages ("ELC FAIL: " + GetName(oPC) +
                      " Type = " +IntToString (iType) +
                      ", SubType = " +IntToString (iSubType) +
                      ", StrRef = " + IntToString (iStrRef));
    }
}

