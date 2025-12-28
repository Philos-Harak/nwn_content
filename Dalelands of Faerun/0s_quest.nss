/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_quest
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Spell script to activate the quest paper abilities.
 Quest Difficulty - Show the player the quests difficulty vs current character level.
 Give Quest - Gives the quest to a player in this players party.
 Remove Quest - permanently removes the quest from the player.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "0i_quest"
#include "0i_win_layout_pc"
void main()
{
    int nQuestId = GetSpellId ();
    object oPaper = GetSpellCastItem();
    object oCaster = GetItemPossessor (oPaper);
    if (nQuestId == 888/*SPELL_QUEST_DIFFICULTY*/)
    {
        // Now set the difficulty for the PC.
        string sDifficulty;
        string sQuestArray = GetLocalString (oPaper, "0_Q_QUEST");
        int nCR = StringToInt (GetStringArray (sQuestArray, 1, "-"));
        int nPCLevel = GetCharacterLevels (oCaster);
        int nDifficulty = nCR - nPCLevel;
        // Lets get the difficulty and color for it.
        if (nDifficulty < -2) { sDifficulty = AddColorToText (" effortless", COLOR_WHITE); }
        else if (nDifficulty < 0) { sDifficulty = AddColorToText (" easy", COLOR_GREEN); }
        else if (nDifficulty < 2) { sDifficulty = AddColorToText (" moderate", COLOR_DARK_BLUE); }
        else if (nDifficulty < 4) { sDifficulty = AddColorToText (" challenging", COLOR_YELLOW); }
        else if (nDifficulty < 6) { sDifficulty = AddColorToText (" very difficult", COLOR_ORANGE); }
        else if (nDifficulty < 8) { sDifficulty = AddColorToText (" overpowering", COLOR_RED); }
        else { sDifficulty = AddColorToText (" impossible", COLOR_DARK_MAGENTA);}
        SendMessageToPC (oCaster, GetName (oPaper) + " should be " + sDifficulty + " for you.");
    }
    else if (nQuestId == 889/*SPELL_GIVE_QUEST*/)
    {
        object oTarget = GetSpellTargetObject();
        if (oTarget != OBJECT_INVALID && GetIsCharacter (oTarget))
        {
            if (oCaster == oTarget) SendMessages ("You cannot give the quest to yourself!", COLOR_RED, oCaster);
            else if (GetFactionEqual (oCaster, oTarget))
            {
                // Make sure they do not already have one, if they do not create a new one!
                // Check the name cause all quest papers for one quest have the same name.
                int bFound = FALSE;
                object oItem = GetFirstItemInInventory (oTarget);
                while (oItem != OBJECT_INVALID && bFound == FALSE)
                {
                    if (GetName (oItem) == GetName (oPaper)) bFound = TRUE;
                    oItem = GetNextItemInInventory (oTarget);
                }
                if (bFound == FALSE)
                {
                    object oCopyPaper;
                    // Move paper to Quest book if they have one else give to the PC and lock it.
                    object oBook = GetItemPossessedBy(oTarget, "0_quest_book");
                    if (oBook != OBJECT_INVALID) oCopyPaper = CopyItem (oPaper, oBook, TRUE);
                    else oCopyPaper = CopyItem(oPaper, oTarget, TRUE);
                    SetItemCursedFlag(oCopyPaper, TRUE);
                    // Make sure to give any items required by the quest.
                    string sPlot = GetLocalString(oPaper, "0_Q_PLOT");
                    // Plot 2 - Deliver Item.
                    if(sPlot == "2")
                    {
                        string sQuestID = GetLocalString(oPaper, "0_Q_ID");
                        CreateQuestItem(oCaster, oTarget, sQuestID, "item");
                    }
                    SendMessages (GetName (oPaper) + " has been given to " + GetName (oTarget) + ".", COLOR_GREEN, oCaster);
                }
                else SendMessages ("The player already has this quest!", COLOR_RED, oCaster);
            }
            else SendMessages ("The player is not in your party!", COLOR_RED, oCaster);
        }
        else SendMessages ("The target is not a player character!", COLOR_RED, oCaster);
    }
    else if (nQuestId == 890/*SPELL_REMOVE_QUEST*/)
    {
        string sMessage = "Do you want to remove " + StripColorCodes (GetName(oPaper)) + "?";
        SetLocalObject(oCaster, "REMOVE_QUEST_PAPER", oPaper);
        SetLocalString(oCaster, "YES_NO_MENU", "REMOVE_QUEST_PAPER");
        PopUpYesNoPanel(oCaster, "Remove Quest!", sMessage, 300.0, 75.0);
    }
}
