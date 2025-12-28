/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_no_deity
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Conversation script that checks to see if character has a class with faith.
 If so then it returns true to make the player go pray at the alter of AO.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_quest"
int StartingConditional()
{
    object oPC = GetPCSpeaker ();
    // These classes must choose a god.
    int nClass = GetClassByPosition (1, oPC);
    if (nClass == CLASS_TYPE_CLERIC ||
        nClass == CLASS_TYPE_PALADIN ||
        nClass == 47/*Favored Soul*/)
    {
        // If the db deity field is 0 then they have not picked a deity.
        if (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "deity") == 0) return TRUE;
    }
    return FALSE;
}
