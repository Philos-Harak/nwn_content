/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_elc
 Programmer: Philos.
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when an effective Level character restriction is hit.

 Type 2, SubType 5, StrRef 68521
*///////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
#include "nwnx_elc"
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
    /*if (nSubType == NWNX_ELC_SUBTYPE_MIN_EQUIP_LEVEL)
    {
    } */
}

