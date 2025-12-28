/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_journal
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for journals.

 All journal entries have a tag 0_Journal_## where the ## is its number.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_feedback"
#include "0i_database"
#include "0i_master"
#include "0i_server_colors"
#include "0i_s_message"
// Add a permanent journal entry to oCreature.
// - sJournaltag: the journal tag used in the toolset's Journal Editor
// - iID: the ID of the journal as seen in the toolset's Journal Editor
// - oPC the PC to place the journal entry on.
// - bAllowOverrideHigher will allow a lower number entry to override a higher one.
void AddJournalEntry (string sQuestName, int nID, object oPC, int bAllowOverrideHigher = TRUE);

// Call for a PC that has not been logged in since a server reset.
// Adds all of the PC's journals to the character.
void SetupPCJournal (object oPC);

// Add a permanent journal entry to oCreature.
// - sJournaltag: the journal tag used in the toolset's Journal Editor
// - iID: the ID of the journal as seen in the toolset's Journal Editor
// - oPC the PC to place the journal entry on.
void AddJournalEntry (string sQuestName, int nID, object oPC, int bAllowOverrideHigher = TRUE)
{
    int nOldID, bAddEntry = TRUE;
    string sName;
    // Journal entries are based on character name so we must
    // Change the characters name back to original before we use the journal.
    // Check to see if we need to adjust the players name.
    int nRespawn = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "respawns");
    if (nRespawn == 0)
    {
        sName = GetName (oPC, TRUE);
        NWNX_Rename_SetPCNameOverride (oPC, sName, "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
    }
    // Check to see if we need intialize a new Journal in the database.
    nOldID = GetObjectDatabaseInt (oPC, QUEST_TABLE, "journalid", sQuestName);
    if (nOldID == 0) CheckObjectDataAndInitialize (oPC, QUEST_TABLE, sQuestName);
    // If we are not overriding higher level quests then lets check.
    if (bAllowOverrideHigher == FALSE && nOldID >= nID) bAddEntry = FALSE;
    if (bAddEntry)
    {
        SetObjectDatabaseInt (oPC, QUEST_TABLE, "journalid", nID, sQuestName);
        // Change spaces to _ for quest tag
        string sQuestTag = StringReplaceText (sQuestName, " ", "_");
        AddJournalQuestEntry (sQuestTag, nID, oPC, FALSE, FALSE, TRUE);
    }
    // Replace name color if we need to.
    if (nRespawn == 0)
    {
        sName = GetName (oPC);
        sName = AddColorToText (sName, COLOR_GOLD);
        NWNX_Rename_SetPCNameOverride (oPC, sName, "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
    }
}

// Call for a PC that has not been logged in since a server reset.
// Adds all of the PC's journals to the character.
void SetupPCJournal (object oPC)
{
    string sName, sQuestName, sQuestTag, sDoneQuestName, sIndex;
    // Journal entries are based on character name so we must
    // Change the characters name back to original before we use the journal.
    // Check to see if we need to adjust the players name.
    int nRespawn = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "respawns");
    if (nRespawn == 0)
    {
        sName = GetName (oPC, TRUE);
        NWNX_Rename_SetPCNameOverride (oPC, sName, "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
    }
    // Hide all Journal updates since they already did these.
    NWNX_Feedback_SetJournalUpdatedMessageHidden (TRUE, oPC);
    // Go through and give all of the PC's Story Quest journal entries.
    int nID, nIndex = 1;
    while (nIndex < 101)
    {
        sQuestName = Get2DAString ("quest_list", "Story_Quest_Name", nIndex);
        if (sQuestName != "" && sDoneQuestName != sQuestName)
        {
            // Get the journal ID.
            nID = GetObjectDatabaseInt (oPC, QUEST_TABLE, "journalid", sQuestName);
            // Change spaces to _ for quest tag
            sQuestTag = StringReplaceText (sQuestName, " ", "_");
            if (nID != 0) AddJournalQuestEntry (sQuestTag, nID, oPC, FALSE, FALSE, TRUE);
            sDoneQuestName = sQuestName;
        }
        else nIndex = 101;
        nIndex ++;
    }
    // Go through and give all of the PC's Quest journal entries.
    nIndex = 1;
    while (nIndex < 101)
    {
        sQuestName = Get2DAString ("quest_list", "Quest_Name", nIndex);
        if (sQuestName != "" && sDoneQuestName != sQuestName)
        {
            // Get the journal ID.
            nID = GetObjectDatabaseInt (oPC, QUEST_TABLE, "journalid", sQuestName);
            // Change spaces to _ for quest tag
            sQuestTag = StringReplaceText (sQuestName, " ", "_");
            if (nID != 0) AddJournalQuestEntry (sQuestTag, nID, oPC, FALSE, FALSE, TRUE);
            sDoneQuestName = sQuestName;
        }
        else nIndex = 101;
        nIndex ++;
    }
    // Give all Villain quest entries.
    nIndex = 1;
    while (nIndex < 10)
    {
        sQuestName = "0_quest_v_" + IntToString (nIndex);
        nID = GetObjectDatabaseInt (oPC, QUEST_TABLE, "journalid", sQuestName);
        if (nID != 0) AddJournalQuestEntry (sQuestName, nID, oPC, FALSE, FALSE, TRUE);
        nIndex ++;
    }
    // Set journal entries to be shown again.
    NWNX_Feedback_SetJournalUpdatedMessageHidden (FALSE, oPC);
    // Replace name color if we need to.
    if (nRespawn == 0)
    {
        sName = GetName (oPC);
        sName = AddColorToText (sName, COLOR_GOLD);
        NWNX_Rename_SetPCNameOverride (oPC, sName, "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
    }
}


