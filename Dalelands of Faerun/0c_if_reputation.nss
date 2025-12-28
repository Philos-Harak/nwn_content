/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_reputation
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if the PC has a reputation.
 Param:
 nFame - the fame the PC must have. If blank it is not checked.
 nInfamy - the Infamy the PC must have. If blank it is not checked.
 DC is (Current Fame * 2) + 5
 Fame/Infamy ratings
 1  DC 5   Accepted/Suspicious (Easy)                11 DC 24  Reputable/Degenerate
 2  DC 7   Noted/Flagrant                            12 DC 26  Honored/Inglorious (Formidable)
 3  DC 9   Known/Blatant                             13 DC 28  Celebrated/Contemptible
 4  DC 11  Good standing/Scandalous (Average)        14 DC 30  Illustrious/Dispicable (Heroic)
 5  DC 13  Liked/Shady                               15 DC 32  Eminent/Wanted
 6  DC 15  Well-known/Shameful (Tough)               16 DC 34  Acclaimed/Detestable
 7  DC 17  Admired/Nefarious                         17 DC 36  Prestigious/Heinous
 8  DC 19  Prominant/Notorious                       18 DC 38  Famous/Infamous
 9  DC 21  Distinguished/Disreputable (Challenging)  19 DC 40  Renowned/Villainous (Nearly Impossible)
 10 DC 22  Popular/Crooked                           20 DC 42  Revered/Dreaded

*///////////////////////////////////////////////////////////////////////////////
#include "0i_database"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    int nFame = StringToInt (GetScriptParam ("nFame"));
    int nInfamy = StringToInt (GetScriptParam ("nInfamy"));
    if (nFame > 0)
    {
        int nPCFame = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "fame");
        if (nPCFame >= nFame) return TRUE;
    }
    else if (nInfamy > 0)
    {
        int nPCInfamy = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "infamy");
        if (nPCInfamy >= nInfamy) return TRUE;
    }
    return FALSE;
}
