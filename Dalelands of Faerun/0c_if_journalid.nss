//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: 0c_if_journalid
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Conversation script that checks to see if they have gotten to the specified
 journal ID.
 NPC Variables:
 0_Journal - The last two digits of the journal tag. i.e. "01".
 0_JournalID - The ID of the journal the player has to be at or above.


*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_creature"

int StartingConditional()
{
    int iJournal, iJournalID;
    string sJournalTag;
    object oPC = GetPCSpeaker ();
    sJournalTag = "0_Journal_" + GetLocalString (OBJECT_SELF, "0_Journal");
    iJournalID = GetLocalInt (OBJECT_SELF, "0_Journal_ID");
    iJournal = GetLocalInt (oPC, "NW_JOURNAL_ENTRY" + sJournalTag);
    if (iJournal == iJournalID) return TRUE;
    return FALSE;
}
