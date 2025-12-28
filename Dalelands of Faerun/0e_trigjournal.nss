/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigjournal
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script when player enters the trigger.
 str: 0_Journal is the journal number to check always two digits ie "02".
 int: 0_JournalID is the journal entry id that is checked to be equal or higher.
 str: 0_Script is the script to run.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void main()
{
    int iJournal, iJournalID;
    string sJournalTag, sScript;
    object oPC = GetEnteringObject ();
    // Make sure this is an PC.
    if (GetIsCharacter (oPC))
    {
        // Get the script to fire.
        sScript = GetLocalString (OBJECT_SELF, "0_Script");
        // Get the Journal # to create the tag.
        sJournalTag = "0_Journal_" + GetLocalString (OBJECT_SELF, "0_Journal");
        // Get the Journal ID that we want to check.
        iJournalID = GetLocalInt (OBJECT_SELF, "0_Journal_ID");
        // Get the players Journal entry to match with the ID.
        iJournal = GetLocalInt (oPC, "NW_JOURNAL_ENTRY" + sJournalTag);
        // If the Entry is equal or greater than the ID then run the script.
        if (iJournal >= iJournalID) ExecuteScript (sScript, OBJECT_SELF);
    }
}

