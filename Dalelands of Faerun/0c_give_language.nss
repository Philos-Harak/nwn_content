/*//////////////////////////////////////////////////////////////////////////////
 Name: 0c_give_language
 Made By: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that gives a specific language feat then subtracts the
 languages left to pick.
 Param:
 nFeat - language feat to be given.
*///////////////////////////////////////////////////////////////////////////////
#include "nwnx_creature"
#include "0i_creature"
void main()
{
    object oPC = GetPCSpeaker ();
    int nLanguage = StringToInt (GetScriptParam ("nFeat"));
    if (nLanguage > 0)
    {
        NWNX_Creature_AddFeatByLevel (oPC, nLanguage, GetCharacterLevels (oPC, FALSE));
        int nNumOfLanguages = GetLocalInt (oPC, "0_Languages_Left") - 1;
        SetLocalInt (oPC, "0_Languages_Left", nNumOfLanguages);
        SetCustomToken (700, IntToString (nNumOfLanguages));
    }
}
