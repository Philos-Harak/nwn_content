/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_quest_action
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that does various quest related actions base on the
 sInput param sent.

 Param: Create_Quest - Checks if there is a quest and then creates if needed.
 Param: Setup_Quest_Giver - Sets quest text for conversation to give the quest.
 Param: Clean_Quest - Clears any quest variables on the PC.
 Param: Giver_Leave - Checks to see if the giver should leave.
 Param: Finisher_Leave - Checks to see if the Finisher should leave.
 Param: Give_Quest - Gives the quest to all relevant PC's.
 Param: Pickup_Quest_NPC - Transfers an NPC for a quest to the PC as a henchman.
 Param: Finish_Quest - Finalizes the quest for PCSpeaker & all PC's on the quest.
 Param: Quest_NPC_Died - Finalizes the quest for when oNPC died.
 Param: Quest_NPC_Action - All conversations with NPC's during a quest.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_journal"
#include "0i_quest"
#include "0i_items"
#include "0i_npc"
#include "0i_area"
#include "0i_webhook"
void GiveTheQuest (object oPC, object oNPC, object oPaper, string sQuestID);
int FinishTheQuest (object oPCSpeaker, object oPC, object oNPC, object oPaper, string sQuestID);
int NPCQuestActions (object oPCSpeaker, object oPC, object oNPC, object oPaper, string sQuestID);
void IncreaseQuestCounters (object oPC, int nQuestType);
// RETURNS Alternate Quest Name.
// Disables the main quest that goes with this alternate quest.
string CheckForAlternateQuest(object oNPC, object oPC, string sQuestID, string sQuestArray);
void NPCDied (object oPCSpeaker, object oPC, object oNPC, object oPaper);

void main()
{
    object oNPC = OBJECT_SELF;
    string sInput = GetScriptParam("sInput");
    Debug("0c_quest_action", "39", "sInput: " + sInput);
    // Used for a workaround when using Executescript to run this script.
    object oPCSpeaker = GetLocalObject(oNPC, "0_PCSpeaker");
    DeleteLocalObject(oNPC, "0_PCSpeaker");
    if(oPCSpeaker == OBJECT_INVALID) oPCSpeaker = GetPCSpeaker();
    if(sInput == "Create_Quest")
    {
        // Get the type of quest (0 - story quests, 1 - side quests, 2 - quests, 3 - treasure quests, 4 - DM quests).
        int nQuestType = GetLocalInt(oNPC, "0_Quest_Type");
        // Check to see if the NPC already has a quest paper.
        object oPaper = GetItemPossessedBy(oNPC, "0_quest_paper");
        if(oPaper != OBJECT_INVALID)
        {
            // If this is a Story Quest then delete the paper we always create a new one.
            if(nQuestType == STORY_QUESTS) DestroyObject(oPaper);
            else
            {
                // Save paper to the PC so we can easily give it to them when they
                // take the quest in 0c_quest_action: .
                SetLocalObject(oPCSpeaker, "0_QUEST_PAPER", oPaper);
                // This NPC already has a quest so exit.
                return;
            }
        }
        // Check to see if the NPC has a specific side quest.
        int nQuestStrRef;
        int nSpecificQuest = GetLocalInt(oNPC, "0_SIDE_QUEST");
        if(nSpecificQuest > 0) nQuestStrRef = StringToInt(Get2DAString("quest_list", "Side_Quest_StrRef", nSpecificQuest));
        // Get the StrRef of the quest to be parsed.
        else if(nQuestType == STORY_QUESTS) nQuestStrRef = GetStoryQuestStrRef(oPCSpeaker, oNPC);
        else if(nQuestType == SIDE_QUESTS) nQuestStrRef = GetSideQuestStrRef(oPCSpeaker, oNPC);
        else if(nQuestType == LOCATION_QUESTS) nQuestStrRef = GetLocationQuestStrRef(oPCSpeaker, oNPC);
        Debug("0c_quest_action", "71", " Creating the Quest!");
        CreateQuest(oPCSpeaker, oNPC, nQuestType, nQuestStrRef);
        return;
    }
    if(sInput == "Setup_Quest_Giver")
    {
        string sQuestText;
        object oArea = GetArea(oPCSpeaker);
        // Get the paper quest from the oPCSpeaker saved in 0c_quest_appear: If_Quest_Giver.
        object oPaper = GetLocalObject(oPCSpeaker, "0_QUEST_PAPER");
         // Get the type of quest (0 - story quests, 1 - side quests, 2 - quests, 3 - treasure quests, 4 - DM quests).
        int nQuestType = GetLocalInt(oNPC, "0_Quest_Type");
        // Set the quest givers conversation line, should be the same as the quest paper description.
        sQuestText = GetDescription(oPaper);
        SetCustomToken(501, sQuestText);
        if(nQuestType == DM_QUESTS) sQuestText = "I will help you.";
        else
        {
            // Set the Papers Name.
            // Get the quests name.
            // Quest Array: (-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Start_Effect-)
            string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
            string sQuestName = GetStringArray(sQuestArray, 0, "-");
            int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
            string sColor;
            if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
            else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
            else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
            else sColor = COLOR_YELLOW;
            if(sQuestName != "")
            {
                string sJournalID = GetStringArray(sQuestArray, 6, "-");
                // If there is a journal ID then add the part # since it has multiple parts and journal entries.
                if(StringToInt(sJournalID) > 0) sQuestName = sQuestName + " Quest (Part " + sJournalID + ")";
                else sQuestName = sQuestName + " Quest";
                SetName(oPaper, AddColorToText(sQuestName, sColor));
            }
            else SetName(oPaper, AddColorToText(GetName (oNPC) + "'s Quest", sColor));
            // Setup the PC's text.
            int nQuestStrRef = StringToInt(GetLocalString(oPaper, "0_Q_STRREF"));
            sQuestText = GetStringByStrRef(nQuestStrRef + 2);
            sQuestText = ParseQuestTextByPaper(sQuestText, oPaper, oPCSpeaker);
        }
        // Set in game conversation text for the PC.
        SetCustomToken(502, sQuestText);
        return;
    }
    if(sInput == "Clean_Quest")
    {
        DeleteLocalString(oPCSpeaker, "0_QUEST_ID");
        DeleteLocalObject(oPCSpeaker, "0_QUEST_PAPER");
        return;
    }
    if(sInput == "Giver_Leave")
    {
        string sQuestID = GetQuestIDByNPC(oNPC, oPCSpeaker, "giver");
        if(sQuestID != "")
        {
            string sQuestArray = GetServerDatabaseString(oPCSpeaker, QUEST_TABLE, "quest", sQuestID);
            string sLeaveMethod = GetStringArray(sQuestArray, 9, "-");
            if(sLeaveMethod != "") MakeNPCLeave(oPCSpeaker, oNPC, sLeaveMethod);
        }
        return;
    }
    if(sInput == "Finisher_Leave")
    {
        string sQuestID = GetQuestIDByNPC(oNPC, oPCSpeaker, "finisher");
        if(sQuestID == "") sQuestID = GetQuestIDByNPC(oNPC, oPCSpeaker, "npc");
        if(sQuestID != "")
        {
            // Check to see if the NPC needs to leave.
            string sQuestArray = GetServerDatabaseString(oPCSpeaker, QUEST_TABLE, "quest", sQuestID);
            string sLeaveMethod = GetStringArray(sQuestArray, 8, "-");
            // We want all side quest givers to leave once done. NPC's too.
            if(sLeaveMethod == "")
            {
                int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
                if(nQuestType == SIDE_QUESTS)
                {
                    string sNPCArray = GetLocalString(oPCSpeaker, "0_Quest_NPC");
                    if(sNPCArray != "")
                    {
                        object oQuestNPC = CheckForNPC(oPCSpeaker, GetArea(oPCSpeaker), sNPCArray);
                        DeleteLocalString(oPCSpeaker, "0_Quest_NPC");
                        if(oQuestNPC != OBJECT_INVALID)
                        {
                            MakeNPCLeave(oPCSpeaker, oQuestNPC, "FAREXIT");
                        }
                    }
                    sLeaveMethod = "FAREXIT";
                }
            }
            if(sLeaveMethod != "") MakeNPCLeave(oPCSpeaker, oNPC, sLeaveMethod);
        }
        return;
    }
    // Below is all code for giving the quest or finishing the quest for all faction PC's.
    // All quest updates are done for all PC's in the faction, the speaker gets any NPC's controlled by the party.
    // All faction PC's need any required items.
    object oPC, oPCSpeakerPaper = GetLocalObject(oPCSpeaker, "0_QUEST_PAPER");
    string sQuestID = GetLocalString(oPCSpeakerPaper, "0_Q_ID");
    string sQuestArray = GetLocalString(oPCSpeakerPaper, "0_Q_QUEST");
    string sQuestName = GetStringArray(sQuestArray, 0, "-");
    int nDBQuestPointer, bFinish = FALSE;
    int nQuestPointer = GetObjectDatabaseInt(oPCSpeaker, QUEST_TABLE, "questpointer", sQuestID);
    Debug("0c_quest_action", "175", "sQuestID: " + sQuestID +
          " nQuestPointer: " + IntToString(nQuestPointer));
    location lLocation = GetLocation(oPCSpeaker);
    oPC = GetFirstFactionMember(oPCSpeaker);
    while(oPC != OBJECT_INVALID)
    {
        // Make sure the PC speaker and Faction PC we are checking are on the same pointer.
        Debug("0c_quest_action", "182", "FactionPC: " + GetName(oPC) +
          " nQuestPointer: " + IntToString(nQuestPointer));        
        if(nQuestPointer == GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestID))
        {
            // We are giving the quest, run all give quest code for each faction PC.
            // Only give the quest to faction PC's without the paper.
            // Note players with pointers equal to quest and no paper should get the quest.
            Debug("0c_quest_action", "189", "GetQuestIDByQuestName: " + GetQuestIDByQuestName(oPC, sQuestName));
            if(sInput == "Give_Quest" && GetQuestIDByQuestName(oPC, sQuestName) == "")
            {
                GiveTheQuest(oPC, oNPC, oPCSpeakerPaper, sQuestID);
            }
            // We are finishing the quest, run all finish the quest code for each faction PC.
            else if(sInput == "Finish_Quest") bFinish = FinishTheQuest(oPCSpeaker, oPC, oNPC, oPCSpeakerPaper, sQuestID);
            // We are running code for NPC died during the quest for each player.
            else if(sInput == "Quest_NPC_Died")
            {
                NPCDied(oPCSpeaker, oPC, oNPC, oPCSpeakerPaper);
                // If bFinish then the NPC finished the quest so log that for
                // when we cleanup after checking all players.
                bFinish = TRUE;
            }
            // If bFinish then the NPC finished the quest so log that for when we cleanup after checking all faction PC's.
            else if(sInput == "Quest_NPC_Action") bFinish = NPCQuestActions(oPCSpeaker, oPC, oNPC, oPCSpeakerPaper, sQuestID);
        }
        oPC = GetNextFactionMember(oPCSpeaker);
    }
    // **************** Do any actions after all faction PC's have been updated.
    string sPlot = GetLocalString(oPCSpeakerPaper, "0_Q_PLOT");
    //Debug ("0c_quest", "117", "sInput: " + sInput + " sPlot: " + sPlot +
    //       " sQuestID: " + sQuestID);
    if(sInput == "Give_Quest")
    {
        // All plots but 4 may give an NPC if there is one.
        string sNPCArray = GetLocalString(oPCSpeakerPaper, "0_Q_NPC");
        if(sPlot != "4" && sNPCArray != "")
        {
            DelayCommand(0.2f, GiveQuestNPC(oPCSpeaker, sQuestID, sNPCArray, sQuestArray));
            string sGiverArray = GetLocalString(oPCSpeakerPaper, "0_Q_GIVER");
            if(GetStringArray(sGiverArray, 0, "-") == GetStringArray(sNPCArray, 0, "-"))
            {
                SetLocalString(oPCSpeakerPaper, "0_Q_GIVER", "");
                SetLocalString(oPCSpeakerPaper, "0_Q_START", "");
                DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "giver", "", sQuestID));
                DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "start", "", sQuestID));
            }
        }
        // Check to see if the Giver needs to leave.
        string sLeaveMethod = GetStringArray(sQuestArray, 9, "-");
        if(sLeaveMethod != "")
        {
            DelayCommand(3.0f, MakeNPCLeave(oPC, OBJECT_SELF, sLeaveMethod));
            // If they are leaving then we are done with them so remove START & GIVER.
            SetLocalString(oPCSpeakerPaper, "0_Q_GIVER", "");
            SetLocalString(oPCSpeakerPaper, "0_Q_START", "");
            DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "giver", "", sQuestID));
            DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "start", "", sQuestID));
        }
        DeleteLocalString(oPCSpeaker, "0_QUEST_ID");
        DeleteLocalObject(oPCSpeaker, "0_QUEST_PAPER");
    }
    else if((sInput == "Finish_Quest" || bFinish) && oPCSpeakerPaper != OBJECT_INVALID)
    {
        string sSTRREF = GetLocalString(oPCSpeakerPaper, "0_Q_STRREF");
        int nQuestStrRef = StringToInt(sSTRREF);
        if(nQuestStrRef == 0)
        {
            string sPCMessage, sNPCMessage;
            int nRoll = d4();
            // Plot - 4 Save NPC, 7 Deliver NPC to Finish NPC.
            if(sPlot == "4" || sPlot == "7")
            {
                string sName = GetLocalString(oPCSpeakerPaper, "0_Q_NPC");
                sName = GetStringArray(sName, 0, "-");
                if(nRoll == 1) sNPCMessage = "Thank you for bringing " + sName + "to me."; 
                if(nRoll == 2) sNPCMessage = "I've been waiting so long to see " + sName + "."; 
                if(nRoll == 3) sNPCMessage = "It is so glad to see you, " + sName + "."; 
                if(nRoll == 4) sNPCMessage = "Thank you for protecting " + sName + ", I hope the journey was safe."; 
                nRoll = d4();
                if(nRoll == 1) sPCMessage = "You are welcome, I shall take my leave now.";
                if(nRoll == 2) sPCMessage = "I'm glad to be of assistance. Good day.";
                if(nRoll == 3) sPCMessage = "It is my pleasure to bring " + sName +" here. Fare well.";
                if(nRoll == 4) sPCMessage = "All part of the job. Now I must move on.";
                SetCustomToken(507, sNPCMessage);
                SetCustomToken(508, sPCMessage);           
            }
            // 6 Deliver NPC to Finish Area.
            if(sPlot == "6")
            {
                string sName = GetLocalString(oPCSpeakerPaper, "0_Q_FINISH");
                sName = GetStringArray(sName, 0, "-");
                if(nRoll == 1) sNPCMessage = "Finally we are here. So this is " + sName + "?"; 
                if(nRoll == 2) sNPCMessage = "This is " + sName + "? Good now I will leave you. Good day."; 
                if(nRoll == 3) sNPCMessage = "I'm glad to be at " + sName + ". You have done well to get me here safely."; 
                if(nRoll == 4) sNPCMessage = "Thank you for your protection, but now that I'm here, I must go."; 
                nRoll = d4();
                if(nRoll == 1) sPCMessage = "You are welcome, I shall take my leave now.";
                if(nRoll == 2) sPCMessage = "Good day to you. Becareful in " + sName + ".";
                if(nRoll == 3) sPCMessage = "Take care and we may meet again.";
                if(nRoll == 4) sPCMessage = "I need to leave now. Good luck in " + sName + ".";
                SetCustomToken(511, sNPCMessage);
                SetCustomToken(508, sPCMessage);
            }
            if(sPlot == "1") // DestroyPlaceable.
            {
                string sName = GetLocalString(oPCSpeakerPaper, "0_Q_PLACEABLE");
                sName = GetStringArray(sName, 0, "-");
                if(nRoll == 1) sNPCMessage = "Now that " + sName + " is destroyed? We can move on."; 
                if(nRoll == 2) sNPCMessage = "With " + sName + " destroyed our lives can get back to normal.";    
                if(nRoll == 3) sNPCMessage = "Thank you for destorying " + sName + ", You are truly great.";
                if(nRoll == 4) sNPCMessage = "With " + sName + " gone I can relaxe.";
                nRoll = d4();
                if(nRoll == 1) sPCMessage = "I shall bid you a good day.";
                if(nRoll == 2) sPCMessage = "It was a pleasure to help you. I must be on my way.";
                if(nRoll == 3) sPCMessage = "Finally I can continue on my journey. Good day.";
                if(nRoll == 4) sPCMessage = "Becareful and if you need anymore help, I will be around.";
                SetCustomToken(507, sNPCMessage);
                SetCustomToken(508, sPCMessage);           
            }
            if(sPlot == "2" || sPlot == "3") // 2)Deliver item or 3)Retrieve item.
            {
                string sName = GetLocalString(oPCSpeakerPaper, "0_Q_ITEM");
                sName = GetStringArray(sName, 0, "-");
                if(nRoll == 1) sNPCMessage = "Now that I have the " + sName + " your services are no longer needed."; 
                if(nRoll == 2) sNPCMessage = "I can't believe I finally have " + sName + ". Thank you!";    
                if(nRoll == 3) sNPCMessage = "With " + sName + " in my hands you can go. Safe journy to you.";
                if(nRoll == 4) sNPCMessage = "Your delivery of " + sName + " is appreciated. Becarefull on your travels.";
                nRoll = d4();
                if(nRoll == 1) sPCMessage = "Farewell.";
                if(nRoll == 2) sPCMessage = "I was happy to bring your " + sName + " to you. Good day.";
                if(nRoll == 3) sPCMessage = "It was no trouble, take care.";
                if(nRoll == 4) sPCMessage = "I shall leave now. Good luck with your " + sName + ".";
                SetCustomToken(507, sNPCMessage);
                SetCustomToken(508, sPCMessage);           
            }
            if(sPlot == "5" || sPlot == "8") // 5)Kill Villain/Creature or 8)Clear area of creatures.
            {
                string sName = GetLocalString(oPCSpeakerPaper, "0_Q_VILLAIN");
                sName = GetStringArray(sName, 0, "-");
                if(sName == "")
                {
                    sName = GetLocalString(oPCSpeakerPaper, "0_Q_CREATURES");
                    sName = "the " + GetStringArray(sName, 0, "-") + "s";                        
                }
                string sAreaName = GetLocalString(oPCSpeakerPaper, "0_Q_AREA");
                sAreaName = GetStringArray(sAreaName, 0, "-");
                if(nRoll == 1) sNPCMessage = "Where is the " + sAreaName + "? We must find and kill " + sName + "!"; 
                if(nRoll == 2) sNPCMessage = "The area of " + sAreaName + " is not safe. Our task is to eliminate " + sName + "!";    
                if(nRoll == 3) sNPCMessage = "We must go to " + sAreaName + " and kill " + sName + " before they get away!";
                if(nRoll == 4) sNPCMessage = "Our task is to find " + sAreaName + " and defeat the " + sName + ". Lets hurry!";
                nRoll = d4();
                if(nRoll == 1) sPCMessage = "Yes, we should be there soon.";
                if(nRoll == 2) sPCMessage = "I shall get you to " + sName + " so we can kill " + sName + ".";
                if(nRoll == 3) sPCMessage = "We are headed to " + sAreaName + " now. You will get to kill " + sName + " soon enough.";
                if(nRoll == 4) sPCMessage = "My plan is to get to " + sAreaName + ". We will defeat " + sName + " and return victorious.";
                SetCustomToken(507, sNPCMessage);
                SetCustomToken(508, sPCMessage);           
            }
        }
        else
        {
            // Plot taking NPC to location.
            if(sPlot == "6")
            {
                // Quest NPC's quest done speech.
                string sQuest14Text = GetStringByStrRef(nQuestStrRef + 14);
                // Setup PC's reply for next quest.
                string sQuest8Text = GetStringByStrRef(nQuestStrRef + 8);
                if(oPCSpeakerPaper != OBJECT_INVALID)
                {
                    sQuest14Text = ParseQuestTextByPaper(sQuest14Text, oPCSpeakerPaper, oPCSpeaker);
                    sQuest8Text = ParseQuestTextByPaper(sQuest8Text, oPCSpeakerPaper, oPCSpeaker);
                }
                else
                {
                    sQuest14Text = ParseQuestTextByDatabase(sQuest14Text, sQuestID, oPCSpeaker);
                    sQuest8Text = ParseQuestTextByDatabase(sQuest8Text, sQuestID, oPCSpeaker);
                }
                SetCustomToken(511, sQuest14Text);
                SetCustomToken(508, sQuest8Text);
                // Save variable so conversation can flow correctly.
                // See script:0c_if_q_finished.
                SetLocalInt (oPCSpeaker, "0_QUEST_FINISHED", TRUE);
            }
            else
            {
                // Get quest finishers ending speech.
                string sQuest7Text = GetStringByStrRef(nQuestStrRef + 7);
                // Setup PC's reply.
                string sQuest8Text = GetStringByStrRef(nQuestStrRef + 8);
                if(oPCSpeakerPaper != OBJECT_INVALID)
                {
                    sQuest7Text = ParseQuestTextByPaper(sQuest7Text, oPCSpeakerPaper, oPCSpeaker);
                    sQuest8Text = ParseQuestTextByPaper(sQuest8Text, oPCSpeakerPaper, oPCSpeaker);
                }
                else
                {
                    sQuest7Text = ParseQuestTextByDatabase(sQuest7Text, sQuestID, oPCSpeaker);
                    sQuest8Text = ParseQuestTextByDatabase(sQuest8Text, sQuestID, oPCSpeaker);
                }
                SetCustomToken(507, sQuest7Text);
                SetCustomToken(508, sQuest8Text);
            }
        }
        // Clear the quest area so other players can do the quest!
        string sAreaArray = GetLocalString(oPCSpeakerPaper, "0_Q_AREA");
        if(sAreaArray != "")
        {
            object oArea = GetObjectByTag(GetStringArray(sAreaArray, 1, "-"));
            // Sometimes if the quest was done before a server reset then
            // the quest area that was generated is not there...
            if(oArea != OBJECT_INVALID) ClearArea(oArea);
        }
    }
}
void GiveTheQuest(object oPC, object oNPC, object oPaper, string sQuestID)
{
    Debug("0c_quest", "397", GetName(oPC) + " is getting the quest: " + sQuestID);
    int nDatabasePointer;
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, TRUE, oPC);
    // Move paper to Quest book if they have one else give to the PC and lock it.
    object oCopyPaper;
    object oBook = GetItemPossessedBy(oPC, "0_quest_book");
    if(oBook != OBJECT_INVALID)
    {
        object oContainer;
        object oInventoryObject = GetFirstItemInInventory(oPC);
        while(oInventoryObject != OBJECT_INVALID)
        {
            if(GetTag(oInventoryObject) == "0_quest_book")
            {
                if(GetBaseItemFitsInInventory(178/*BASE_ITEM_QUEST_BOOK*/, oInventoryObject))
                {
                    oCopyPaper = CopyItem(oPaper, oBook, TRUE);
                    break;
                }
            }
            oInventoryObject = GetNextItemInInventory(oPC);
        }
    }
    if(oCopyPaper == OBJECT_INVALID) oCopyPaper = CopyItem(oPaper, oPC, TRUE);
    // Get the givers name to place on papers.
    string sQuestText = GetDescription(oPaper);
    string sName = AddColorToText(GetName(oNPC), COLOR_GREEN);
    string sArea = AddColorToText(GetName(GetArea(oPC)), COLOR_GREEN);
    // Set the Papers description.
    SetDescription(oCopyPaper, sName + " located in " + sArea + " has given you a quest. '" + sQuestText + "'.");
    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_RECEIVED, FALSE, oPC);
    //Debug ("0c_quest", "187", "oCopyPaper: " + GetName (oCopyPaper));
    SetItemCursedFlag(oCopyPaper, TRUE);
    // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks
    //              -Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-)
    string sQuestArray = GetLocalString(oCopyPaper, "0_Q_QUEST");
    string sQuestName = CheckForAlternateQuest(oNPC, oPC, sQuestID, sQuestArray);
    int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
    int nQuestPointer = StringToInt(GetStringArray(sQuestArray, 2, "-"));
    if(nQuestType != SIDE_QUESTS)
    {
        // Check the pointer for this quest from the database.
        nDatabasePointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestName);
        string sNextQuestPointer = GetStringArray(sQuestArray, 3, "-");
        // If there is no pointer then this is a new quest so lets save it to the
        // database as long as there is a next quest pointer.
        //Debug ("0c_quest", "201", "nDatabasePointer: " + IntToString (nDatabasePointer) +
        //      " nQuestPointer: " + IntToString (nQuestPointer) + " sQuestName: " + sQuestName);
        if(nDatabasePointer == 0 && sNextQuestPointer != "End")
        {
            CheckObjectDataAndInitialize(oPC, QUEST_TABLE, sQuestName);
            SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", nQuestPointer, sQuestName);
        }
    }
    // Used to set for a new players early quests. We randomize 1 quest then use the next two in line.
    else SetLocalInt(GetCreatureHasItem(oPC, "players_book"), "0_SideQuest_Num", nQuestPointer);
    // Check for each plot and set all options for the start of the quest.
    string sPlot = GetLocalString(oCopyPaper, "0_Q_PLOT");
    // Plot #1: DestroyPlaceable.
    // Plot #2: Delivering Item.
    if(sPlot == "2")
    {
        if(nQuestType != SIDE_QUESTS)
        {
            string sPCName = StripColorCodes(RemoveIllegalCharacters(GetName(oPC)));
            DelayCommand(0.5f, SetLocalInt(oNPC, "0_" + sPCName, TRUE));
        }
        DelayCommand(0.5f, CreateQuestItem(oPC, oPC, sQuestID, "item"));
    }
    // Plot #3: Retrieve Item.
    // Plot #4: Save NPC.
    // Plot #5: Kill a creature.
    // Plot #6: Guard NPC to FINISH.  Clear GIVER & START since we can't come back.
    else if(sPlot == "6")
    {
        // Remove the NPC quest giver from the quest and start area as we are done with them.
        SetLocalString(oCopyPaper, "0_Q_GIVER", "");
        SetLocalString(oCopyPaper, "0_Q_START", "");
        DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "giver", "", sQuestID));
        DelayCommand(1.0, SetServerDatabaseString(oPC, QUEST_TABLE, "start", "", sQuestID));
    }
    // Plot #7: Deliver NPC.
    // Plot #8: Clear AREA location.
    // Plot #9: Talk to FINISHER.
    // Plot #10: Special tasks - must be coded.
    // ****************** Special code for setting up quests. ******************
    // All plots but 4 may give an NPC if there is one, set so all faction PC's can get the NPC
    // later if the quest is not finished.
    if(sPlot != "4" && GetLocalString(oCopyPaper, "0_Q_NPC") != "")
    {
        DelayCommand(0.5f, SetQuestState(oPC, sQuestID, 5, 1));
    }
    // Check to see if they are giving an item, works for all plots.
    if(GetLocalString (oCopyPaper, "0_Q_GIVEITEM") != "")
    {
        DelayCommand(0.5f, CreateQuestItem(oPC, oPC, sQuestID, "giveitem"));
    }
    // Does this quest add a Journal entry on quest start?
    int nJournalID = StringToInt(GetStringArray (sQuestArray, 6, "-"));
    if(nJournalID > 0) AddJournalEntry(sQuestName, nJournalID, oPC);
    // Check to see if we should do any effects.
    int nVFX = StringToInt(GetStringArray(sQuestArray, 7, "-"));
    string sSound = GetStringArray(sQuestArray, 8, "-");
    // if this is a side quest or the start of a Story/Town Quest then display it.
    if(nDatabasePointer == 0) DelayCommand(0.5f, QuestUpdate(oPC, sQuestID, GetName(oCopyPaper) + " has begun!", FALSE, FALSE, nVFX, sSound));
}
int FinishTheQuest(object oPCSpeaker, object oPC, object oNPC, object oPaper, string sQuestID)
{
    Debug("0c_quest", "506", GetName(oPC) + " is finishing the quest: " + sQuestID);
   if(GetIsQuestDone(oPC, sQuestID))
    {
        // Quest array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks
        //              -Quest_Type-Journal_ID-Start_Effect-)
        string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
        int nQuestType = StringToInt(GetStringArray (sQuestArray, 5, "-"));
        string sQuestName = GetStringArray(sQuestArray, 0, "-");
        int nNextQuestPointer = GetNextQuestPointer(oPC, sQuestID, sQuestArray);
        //Debug ("0c_quest", "230", "nNextQuestPointer: " + IntToString (nNextQuestPointer));
        // Save the next pointer to the database, "CLEAR" i.e. -2 resets the quest to do it again.
        if(nNextQuestPointer == -2)
        {
            SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", -1, sQuestName);
            DelayCommand(0.2f, SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", 0, sQuestName));
        }
        // All sides quests only have 1 quest chain and do not have a database entry.
        // Set on the NPC that the PC's has finished the quest.
        else if(nQuestType == SIDE_QUESTS)
        {
            string sPCName = StripColorCodes(RemoveIllegalCharacters(GetName(oPC)));
            SetLocalInt(oNPC, "0_" + sPCName, TRUE);
        }
        // We save all STORY_QUESTS and QUESTS here.
        else SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", nNextQuestPointer, sQuestName);
        // Rewards array:(-Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-)
        string sRewardsArray = GetLocalString(oPaper, "0_Q_REWARDS");
        int nVFX = StringToInt(GetStringArray(sRewardsArray, 6, "-"));
        string sSound = GetStringArray (sRewardsArray, 7, "-");
        // Does the player get to keep the item? If not then destroy it now.
        if(GetStringArray(sRewardsArray, 4, "-") != "KEEP")
        {
            // Get item saved from 0c_quest -above- (Function: GetIsQuestDone).
            object oItem = GetLocalObject(oPC, "0_QUEST_ITEM");
            if(oItem != OBJECT_INVALID) DestroyObject(oItem);
        }
        // Either way lets clear the item variable on the player.
        DeleteLocalObject(oPC, "0_QUEST_ITEM");
        // Does this quest add a Journal entry when done?
        int nJournalID = StringToInt(GetStringArray(sRewardsArray, 5, "-"));
        if(nJournalID > 0) AddJournalEntry (sQuestName, nJournalID, oPC);
        // Check for an NPC henchman to remove.
        int nHenchmanIndex;
        string sNPCArray = GetLocalString(oPaper, "0_Q_NPC");
        //Debug ("0c_quest", "301", "0_Q_NPC: " + sNPCArray);
        if(sNPCArray != "")
        {
            nHenchmanIndex = 1;
            string sNPCID;
            string sQName = GetStringArray(sNPCArray, 0, "-");
            string sQID = GetStringArray(sNPCArray, 2, "-");
            object oNPC = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nHenchmanIndex);
            while (oNPC != OBJECT_INVALID)
            {
                sNPCID = GetLocalString(oNPC, "0_QUEST_ID");
                //Debug ("0c_quest", "280", "Associate: " + GetName (oNPC) + " sQName: " + sQName + " sQID: " +
                //       sQID + " sNPCID: " + sNPCID);
                // Added extra check to make sure no quest henchman are not being removed.
                // i.e. if sNPCID is "" then this henchman is NOT a quest henchman.
                if(StripColorCodes(GetName(oNPC)) == sQName && (sQID == sNPCID && sNPCID != ""))
                {
                    // One final check to make sure Henchman are not removed.
                    // All quest NPC's are set as ASSOCIATE_TYPE_NPC.
                    //Debug ("0c_quest", "288", "Associate Type:(6) " + IntToString (GetLocalInt (oNPC, PC_ASSOCIATE_TYPE)));
                    if(GetLocalInt(oNPC, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_NPC)
                    {
                        SetLocalString(oPCSpeaker, "0_Quest_NPC", sNPCArray);
                        DelayCommand (0.2f, RemoveQuestNPC (oPC, oNPC));
                    }
                }
                oNPC = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, ++nHenchmanIndex);
            }
        }
        string sAreaArray = GetLocalString(oPaper, "0_Q_AREA");
        // Clear a players area tags for this quest.
        if(sAreaArray != "")
        {
            object oArea = GetObjectByTag(GetStringArray(sAreaArray, 1, "-"));
            string sID = GetLocalString(oPaper, "0_Q_ID");
            ClearAreaQuestArray(oArea, sID);
        }
        // They have another quest.
        if(nNextQuestPointer > 0)
        {
            // Update quest give rewards.
            QuestUpdate(oPC, sQuestID, "", FALSE, TRUE, nVFX, sSound);
        }
        // They do not have another quest and it is done.
        else
        {
            QuestUpdate(oPC, sQuestID, sQuestName + " has been finished!", FALSE, TRUE, nVFX, sSound);
            IncreaseQuestCounters(oPC, nQuestType);
            SendPlayerQuestDoneToDiscord(oPC, oNPC, sQuestName);
        }
        // Remove quest paper for all PC's not in the conversation.
        // PCSpeaker's will be removed in the script 0c_if_questagain.
        if(oPCSpeaker != oPC) 
        {
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
            object oPaper = GetQuestPaper(oPC, sQuestID);
            RemoveQuestPaperFromDatabase(oPC, oPaper);
            DestroyObject(oPaper);
            NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC);
        }
        return TRUE;
    }
    return FALSE;
}
int NPCQuestActions(object oPCSpeaker, object oPC, object oNPC, object oPaper, string sQuestID)
{
     //1 - Object Destroyed.         6 - Area found.
     //2 - Villain Killed.           7 -
     //3 - Creature Killed.          8 - Area Cleared.
     //4 - Item Picked up.           9 - Escorted NPC is dead.
     //5 - NPC Picked up.            10 - Finished X number of tasks.
     string sStateArray = GetLocalString(oPaper, "0_Q_STATE");
     string sPlot = GetLocalString(oPaper, "0_Q_PLOT");
     // Check to see if we are picking them up.
     if(sPlot == "4" && GetStringArray(sStateArray, 5, "-") == "0")
     {
         // We want to give the NPC to the PCSpeaker an noone else.
         if(oPCSpeaker == oPC)
         {
             AddHenchman(GetPCSpeaker (), oNPC);
             SetLocalInt(oNPC, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_NPC);
             string sID = GetLocalString (oPaper, "0_Q_ID");
             SetLocalString(oPC, "0_QUEST_ID", sID);
         }
         // Everyone should get updated on getting the NPC.
         SetQuestState(oPC, sQuestID, 5, 1);
         QuestUpdate(oPC, sQuestID, GetName (OBJECT_SELF) + " is ready to go.");
         // Quest is not done so do not finish the quest.
         return FALSE;
     }
     // Check to see if we have taken NPC to destination.
     else if (sPlot == "6")
     {
         return FinishTheQuest(oPCSpeaker, oPC, oNPC, oPaper, sQuestID);
     }
     return FALSE;
}
string CheckForAlternateQuest(object oNPC, object oPC, string sQuestID, string sQuestArray)
{
    // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks
    //              -Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-)
    string sQuestName = GetStringArray(sQuestArray, 0, "-");
    string sAQuestName = GetLocalString(oNPC, "0_Alternate_Quest");
    string sAQ_PlayerName = "0_AQ_" + RemoveIllegalCharacters(GetName(oPC, TRUE));
    if(GetLocalInt(oNPC, sAQ_PlayerName))
    {
        // Remove the Alternate quest true variable FOR THIS PC, lets keep it clean!
        DeleteLocalInt(oNPC, sAQ_PlayerName);
        // Set normal quest to finished in the db so we can't do it later.
        CheckObjectDataAndInitialize(oPC, QUEST_TABLE, sQuestName);
        SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", -1, sQuestName);
        sQuestName = sAQuestName;
    }
    // If we are not on an alternate quest then check to see if they have an alternate quest.
    // If so then we need to set the quest to done in the db so we can't do it later.
    else if(sAQuestName != "")
    {
        CheckObjectDataAndInitialize(oPC, QUEST_TABLE, sAQuestName);
        SetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", -1, sAQuestName);
    }
    return sQuestName;
}

void IncreaseQuestCounters(object oPC, int nQuestType)
{
    string sText;
    if(nQuestType == STORY_QUESTS) sText = "mainquests";
    else if(nQuestType == TREASURE_QUESTS) sText = "mapquests";
    else if(nQuestType == DM_QUESTS) sText = "dmquests";
    else sText = "sidequests";
    IncreaseServerDatabaseCounter(oPC, PLAYER_TABLE, sText);
    IncreaseObjectDatabaseCounter(oPC, CHARACTER_TABLE, sText);
}

void NPCDied(object oPCSpeaker, object oPC, object oNPC, object oPaper)
{
    // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-
    //               Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-)
    string sQuestArray = GetLocalString (oPaper, "0_Q_QUEST");
    int nQuestPointer = StringToInt(GetStringArray (sQuestArray, 2, "-"));
    int nQuestType = StringToInt (GetStringArray (sQuestArray, 5, "-"));
    string sQuestName = GetStringArray (sQuestArray, 0, "-");
    // Remove the NPC as a quest giver if it is a side quest.
    if(nQuestType == SIDE_QUESTS) DeleteLocalInt (oNPC, "0_Quest_Type");
    // Update quest and give half xp for reporting.
    SendMessages(GetStringArray(sQuestArray, 0, "-") + " is over.", COLOR_RED, oPC);
    int nCR = StringToInt(GetStringArray(sQuestArray, 1, "-"));
    // Rewards array:(-Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-)
    string sRewardsArray = GetLocalString(oPaper, "0_Q_REWARDS");
    int nXp = StringToInt(GetStringArray(sRewardsArray, 2, "-"));
    if(nXp > 0)
    {
        nXp = nXp * (nCR / 2);
        // We cap xp to MAX_QUEST_XP found in 0i_constants for quests.
        if (nXp > MAX_QUEST_XP) nXp = MAX_QUEST_XP;
        AdjustXPGiveToCreature(oPC, IntToFloat (nXp));
    }
    // Remove quest paper for all PC's not in the conversation.
    // PCSpeaker's will be removed in the script 0c_if_questagain.
    if(oPCSpeaker != oPC) DestroyObject(oPaper);
}
