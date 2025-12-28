/*///////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_has_dbchest
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that returns TRUE if a players player handbook as tag on it.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_items"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    string sTag = GetScriptParam ("sTag");
    int bTrue = StringToInt (GetScriptParam ("bTrue"));
    object oPlayersHandBook = GetCreatureHasItem (oPC, "players_book");
    if (GetLocalInt (oPlayersHandBook, sTag) == bTrue) return TRUE;
    return FALSE;
}
