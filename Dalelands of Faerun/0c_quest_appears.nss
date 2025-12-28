/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_quest_appears
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Variables used by Quest Givers:
 0_Quest_Type - Int - Set to 1 for Side Quests, 2 for Town Quests, 0 is Main Quests.
 Main quests will always have a quest name.
 **** The named quest will fire if there is no alternate quest & if Fame/Infamy and required quests are met.
 **** If there is an alternate quest the main quest will fire if all Fame/Infamy and required quests are met.
 0_Quest_Name - Str - The name of the quest for this NPC. (Must have for main quests!)
 0_Quest_Opening - Str - The quest NPC's opening statement to the PC.
 0_Required_Level - Int - minimum character level required to get this quest.
 0_Required_Fame - Int - minimum fame to get this NPC's quest.
 0_Required_Infamy - Int - minimum infamy to get this NPC's quest.
 0_Required_Quest - Str - The name of the quest that must be finished to get this NPC's quest.
 **** The alternate quest will fire if any of the main quests Fame/Infamy and required quests are not met.
 0_Alternate_Quest - Int The pointer to the quests alternate start based on the following.
 0_AQuest_Opening - Str - Alternate Quest opening statement from NPC.
 0_Town_Quest_Pointer - The row number in quest_list.2da for the town quest of the NPC.
////////////////////////////////////////////////////////////////////////////////

 Text Appears When script that does various quest related checks base on the
 sInput param sent.

 Param: If_Quest_Finisher
    RETURNS TRUE if oNPC is a quest finisher for one of the quests the PCSpeaker has.
    1) Sets up the conversation node for oNPC to ask if the quest is done.
 Param: If_Quest_Done
    RETURNS TRUE if PCSpeaker has finished the quest.
    1) Sets up the conversation node for PCSpeaker to say they finshed the quest.
    2) Gets and saves the quest paper that is on PCSpeaker for this quest to PCSpeaker.
 Param: If_Quest_Not_Done
    RETURNS TRUE if PCSpeaker has not finished the quest.
 Param: If_Quest_NPC
    RETURNS TRUE if oNPC is a quest NPC for one of the quests the PCSpeaker has.
 Param: If_Quest_Continues
    RETURNS TRUE if the quest points to a new quest.
 Param: If_Quest_Giver
    RETURNS TRUE if oNPC is a quest giver for a quest.
 Param: If_Quest_Finished
    RETURNS TRUE if the quest was finished in the 0c_quest_action
 Param: Quest_NPC_Walking
    RETURNS TRUE if oNPC is walking away after giving a quest.
 Param: Quest_NPC_Health
    RETURNS TRUE always, Sets CUSTOM 508 for how the NPC's health is.
 Param: If_Quest_Pointer
    RETURNS TRUE if quest pointer of speaker equals Param: nPointer.
    Additional Param: sQuestName - if "" then it will look for it via the NPC.
    if they are not on this quest it will compare to 0.
    if they have finished this quest it will compare to -1.
 Param: If_Not_Quest_Pointer
    RETURNS TRUE if quest pointer of speaker does not equal Param: nPointer.
    Additional Param: sQuestName - if "" then it will look for it via the NPC.
    if they are not on this quest it will return FALSE. This is for being on the quest.
    if they have finished this quest it will compare to -1.
*///////////////////////////////////////////////////////////////////////////////
#include "nwnx_feedback"
#include "0i_quest"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oNPC = OBJECT_SELF;
    string sInput = GetScriptParam("sInput");
    if(sInput == "If_Quest_Finisher")
    {
        string sQuestID = GetQuestIDByNPC(oNPC, oPC, "finisher");
        if(sQuestID != "")
        {
            // Get finishers conversation line. It is +3 strref line ahead of the quest info.
            int nQuestStrRef = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "strref", sQuestID));
            string sQuestText = GetStringByStrRef(nQuestStrRef + 3);
            sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
            SetCustomToken(503, sQuestText);
            // Set the quest ID so later scripts can pull it from the PC.
            SetLocalString(oPC, "0_QUEST_ID", sQuestID);
            return TRUE;
        }
        DeleteLocalString(oPC, "0_QUEST_ID");
        return FALSE;
    }
    if(sInput == "If_Quest_Done")
    {
        // Get quest ID saved in "If_Quest_Finisher" code see above.
        string sQuestID = GetLocalString(oPC, "0_QUEST_ID");
        if(GetIsQuestDone(oPC, sQuestID))
        {
            // Get the PC's reply for done.
            int nQuestStrRef = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "strref", sQuestID));
            //Debug("0c_if_quest_done", "18", "sQuestID: " + sQuestID + " nQuestStrRef: " + IntToString(nQuestStrRef));
            string sQuestText = GetStringByStrRef(nQuestStrRef + 4);
            sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
            SetCustomToken(504, sQuestText);
            // Save the paper for this quest to oPC.
            SaveQuestPaperToPC(oPC, sQuestID);
            return TRUE;
        }
        DeleteLocalObject(oPC, "0_QUEST_PAPER");
        return FALSE;
    }
    if(sInput == "If_Quest_Not_Done")
    {
        if(GetLocalObject(oPC, "0_QUEST_PAPER") == OBJECT_INVALID)
        {
            // Get PC's not done reply.
            string sQuestID = GetLocalString(oPC, "0_QUEST_ID");
            Debug("0c_quest_appears", "112", "sQuestID: " + sQuestID);
            if(sQuestID != "")
            {
                int nQuestStrRef = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "strref", sQuestID));
                string sQuestText = GetStringByStrRef(nQuestStrRef + 5);
                sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                SetCustomToken(505, sQuestText);
                DeleteLocalString(oPC, "0_QUEST_ID");
                return TRUE;
            }
        }
        return FALSE;
    }
    if(sInput == "If_Quest_NPC")
    {
        string sQuestID = GetQuestIDByNPC(OBJECT_SELF, oPC, "npc");
        Debug("0c_quest_appears", "111", "sQuestID: " + sQuestID);
        if(sQuestID != "")
        {
            int nStrRefNPC, nStrRefPC;
            string sPlot;
            string sQueryPlot = "SELECT plot, state, strref FROM QuestTable WHERE name = @name AND tag = @tag;";
            sqlquery sqlplot = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryPlot);
            SqlBindString(sqlplot, "@name", GetName(oPC, TRUE));
            SqlBindString(sqlplot, "@tag", sQuestID);
            if(SqlStep(sqlplot)) sPlot = SqlGetString(sqlplot, 0);
            else return FALSE;
            string sStateArray = SqlGetString(sqlplot, 1);
            int bQuestDone = GetIsQuestDone(oPC, sQuestID);
            // Plot - 4 Save NPC or 7 Retrieve NPC.
            if(sPlot == "4")
            {
                // NPC not picked up so setup first conversation.
                if(GetStringArray(sStateArray, 5, "-") == "0")
                {
                    nStrRefNPC = 9;
                    nStrRefPC = 10;
                }
                // NPC picked up so setup not done conversation.
                else
                {
                    nStrRefNPC = 11;
                    nStrRefPC = 13;
                }
            }
            else if(sPlot == "6")
            {
                nStrRefNPC = 11;
                if(bQuestDone) nStrRefPC = 12;
                else nStrRefPC = 13;
            }
            // Plot 1, 2, 3, 5, 7, 8, 10: If NPC is following PC then give responce
            // based on if the quest is not done or is done.
            else if(bQuestDone)
            {
                nStrRefNPC = 14;
                nStrRefPC = 12;
            }
            else
            {
                nStrRefNPC = 11;
                nStrRefPC = 13;
            }
            // Get quest conversation lines. It is strref line #1.
            int nQuestStrRef = StringToInt(SqlGetString(sqlplot, 2));
            string sQuestText = GetStringByStrRef(nQuestStrRef + nStrRefNPC);
            sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
            SetCustomToken(509, sQuestText);
            sQuestText = GetStringByStrRef(nQuestStrRef + nStrRefPC);
            sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
            SetCustomToken(510, sQuestText);
            DelayCommand(0.0f, SaveQuestPaperToPC(oPC, sQuestID));
            return TRUE;
        }
        return FALSE;
    }
    if(sInput == "If_Quest_Continues")
    {
        // Get the last quest paper.
        object oPaper = GetLocalObject(oPC, "0_QUEST_PAPER");
        string sQuestID = GetLocalString(oPaper, "0_Q_ID");
        // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-
        //               Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-ID-)
        string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
        int nNextQuestPointer = GetNextQuestPointer(oPC, sQuestID, sQuestArray);
        //Debug ("0c_quest_appears", "156", "oPaper: " + GetName (oPaper) + " sQuestArray: " + sQuestArray +
        //       " nNextQuestPointer: " + IntToString (nNextQuestPointer));
        DeleteServerDatabaseObject(oPC, QUEST_TABLE, sQuestID);
        NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
        DestroyObject(oPaper);
        DelayCommand(0.5, NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC));
        // if the next quest pointer is higher than 0 then the quest continues.
        if (nNextQuestPointer > 0)
        {
            // Pass the type of quest we need to setup: 0-Main 1-Side 2-Town, 3-Treasure maps.
            int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
            // Pass the name of the quest so we know what quest to setup.
            string sQuestName = GetStringArray(sQuestArray, 0, "-");
            // Make sure NPC is set to create new quest.
            SetLocalInt(oNPC, "0_Quest_Type", nQuestType);
            SetLocalString(oNPC, "0_Quest_Name", sQuestName);
            SetLocalObject(oNPC, "0_PCSpeaker", oPC);
            SetLocalInt(oNPC, "0_Quest_Pointer", nNextQuestPointer);
            SetScriptParam("sInput", "Create_Quest");
            ExecuteScript("0c_quest_action", oNPC);
            // Get the new paper from script 0c_quest_action: "Create_Quest".
            oPaper = GetLocalObject(oPC, "0_QUEST_PAPER");
            // Get the new quest information.
            // Get quest givers conversation line.
            // Quest givers StrRef Lines are +1 Starting convo, +2 Not done convo, +3 Ending convo
            int nQuestStrRef = StringToInt(GetLocalString(oPaper, "0_Q_STRREF"));
            string sQuestText = GetStringByStrRef(nQuestStrRef + 1);
            sQuestText = CheckIsGiverMoving(oPC, oPaper, sQuestText);
            sQuestText = ParseQuestTextByPaper(sQuestText, oPaper, oPC);
            // Set in game conversation text.
            SetCustomToken(501, sQuestText);
            // Get the givers name to place on papers.
            string sName = AddColorToText(GetName (oNPC), COLOR_GREEN);
            string sArea = AddColorToText(GetName (GetArea (oPC)), COLOR_GREEN);
            // Set the Papers description.
            sQuestText = sName + " located in " + sArea + " has given you a quest. '" + sQuestText + "'.";
            SetDescription(oPaper, sQuestText);
            // Set the Papers Name and Journal if it has a name.
            sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
            nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
            string sColor;
            if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
            else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
            else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
            else sColor = COLOR_YELLOW;
            if(sQuestName != "")
            {
                string sJournalID = GetStringArray (sQuestArray, 6, "-");
                // If there is a journal ID then add the part # since it has multiple parts and journal entries.
                if (StringToInt (sJournalID) > 0) sQuestName = sQuestName + " Quest (Part " + sJournalID + ")";
                else sQuestName = sQuestName + " Quest";
                SetName(oPaper, AddColorToText (sQuestName, sColor));
            }
            else SetName(oPaper, AddColorToText (GetName (oNPC) + "'s Quest", sColor));
            // Setup the PC's text.
            sQuestText = GetStringByStrRef(nQuestStrRef + 2);
            sQuestText = ParseQuestTextByPaper(sQuestText, oPaper, oPC);
            // Set in game conversation text.
            SetCustomToken(502, sQuestText);
            //Debug ("0c_quest_appears", "213", "oPaper: " + GetName(oPaper));
            // Now that we have changed to a new paper we need to save it for the PC.
            SetLocalString(oPC, "0_QUEST_ID", GetLocalString(oPaper, "0_Q_ID"));
            // Now give the quest to the PC and other players nearby.
            SetScriptParam("sInput", "Give_Quest");
            ExecuteScript("0c_quest_action", oNPC);
            DeleteLocalString(oPC, "0_QUEST_ID");
            DeleteLocalObject(oPC, "0_QUEST_PAPER");
            return TRUE;
        }
        // Passes variable to 0c_quest_apppear "If_Quest_Finished".
        else SetLocalInt(oPC, "0_QUEST_FINISHED", TRUE);
        DeleteLocalString(oPC, "0_QUEST_ID");
        DeleteLocalObject(oPC, "0_QUEST_PAPER");
        return FALSE;
    }
    if(sInput == "If_Quest_Giver")
    {
        string sQuestID = GetQuestIDByNPC(oNPC, oPC, "giver");
        Debug("0c_quest_appears", "256", "sQuestID: " + sQuestID);
        if(sQuestID == "")
        {
            Debug("0c_quest_appears", "256", "oNPC: " + GetName(oNPC));
            if(!CheckNPCHasQuestReady(oPC, oNPC)) return FALSE;
            Debug("0c_quest_appears", "259", "Max Quests: " + IntToString(HasMaximumNumberOfQuests(oPC)));
            if(HasMaximumNumberOfQuests(oPC)) return FALSE;
            // Check for a minimum level to take this quest.
            int nRequiredLevel = GetLocalInt(oNPC, "0_Required_Level");
            Debug("0c_quest_appears", "263", "nRequiredLevel: " + IntToString(nRequiredLevel) +
                   " Character Level: " + IntToString(GetCharacterLevels(oPC)));
            if(nRequiredLevel > GetCharacterLevels(oPC)) return FALSE;
            // See if a reputation is required for this quest giver.
            int nRequiredFame = GetLocalInt(oNPC, "0_Required_Fame");
            int nRequiredInfamy = GetLocalInt(oNPC, "0_Required_Infamy");
            Debug ("0c_quest_appears", "269", "Required Fame: " + IntToString (nRequiredFame) +
                   " Repuired Infamy: " + IntToString(nRequiredInfamy));
            if(nRequiredFame > 0 || nRequiredInfamy > 0)
            {
                // If reputation is required and it is not high enough then exit with no quest NPC.
                if(nRequiredFame > GetCharacterReputation(oPC)) return FALSE;
                else if(nRequiredInfamy > GetCharacterReputation(oPC, FALSE)) return FALSE;
            }
            string sQuestText;
            // Check to see if the player has done the required quest.
            // 0_Required_Quest is set to the name of the quest that must be
            // completed before this quest can be taken.
            string sRequiredQuestName = GetLocalString(oNPC, "0_Required_Quest");
            int nRequiredQuestPointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sRequiredQuestName);
            // There is a required quest and it has not been done. (-1 is done).
            Debug ("0c_quest_appears", "284", "RequiredQuestName: " + sRequiredQuestName +
                   " nRequiredQuestPointer: " + IntToString(nRequiredQuestPointer));
            if(sRequiredQuestName != "" && nRequiredQuestPointer != -1)
            {
                // Is there an alternate quest since they have not done the
                // previous quest line?
                string sAlternateQuest = GetLocalString(oNPC, "0_Alternate_Quest");
                if(sAlternateQuest != "")
                {
                    // Set a local int on oNPC to pass to 0c_quest_create script
                    // to show we need to do the alternate quest.
                    SetLocalInt(oNPC, "0_AQ_" + RemoveIllegalCharacters(GetName(oPC, TRUE)), TRUE);
                    // Set alternate quest text if it exists.
                    sQuestText = GetLocalString(oNPC, "0_AQuest_Opening");
                }
                else return FALSE;
            }
            // They have done the previous quest line or there is none.
            else
            {
                string sQuestName = GetLocalString(oNPC, "0_Quest_Name");
                // Check the pointer for this quest from the database.
                int nQuestPointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestName);
                Debug("0c_quest_appears", "311", "oPC: " + GetName(oPC) + " nQuestPointer: " + IntToString(nQuestPointer));
                if(nQuestPointer != 0) return FALSE;
                sQuestText = GetLocalString(oNPC, "0_Quest_Opening");
            }
            // Check for opening sentence on oNPC.
            if(sQuestText == "")
            {
                int nRoll = d4();
                if (nRoll == 1) sQuestText = "Welcome, Can you aid me in my time of need?";
                else if (nRoll == 2) sQuestText = "I hope you're an adventurer! Please, can you help me?";
                else if (nRoll == 3) sQuestText = "Ah someone looking for work? I have a mission of great importance!";
                else if (nRoll == 4) sQuestText = "I have a quest! Are you interested?";
            }
            SetCustomToken(500, sQuestText);
            return TRUE;
        }
        return FALSE;
    }
    if(sInput == "If_Quest_Finished")
    {
        if (GetLocalInt(oPC, "0_QUEST_FINISHED"))
        {
            DeleteLocalInt(oPC, "0_QUEST_FINISHED");
            return TRUE;
        }
        return FALSE;
    }
    if(sInput == "Quest_NPC_Walking")
    {
        object oExit = GetLocalObject(oNPC, "0_Exit");
        if(GetIsObjectValid(oExit))
        {
            ActionMoveToObject (oExit, FALSE);
            ActionDoCommand(DestroyObject(oNPC));
            return TRUE;
        }
        return FALSE;
    }
    if(sInput == "Quest_NPC_Health")
    {
        string sQuestText;
        int nHP = GetCurrentHitPoints(oNPC);
        int nMaxHP = GetMaxHitPoints(oNPC);
        if(nHP = nMaxHP) sQuestText = "I'm fully rested and ready to go.";
        else if(nHP < nMaxHP / 4) sQuestText = "I'm severly wounded and can't go much further.";
        else if(nHP < nMaxHP / 2) sQuestText = "I'm wounded and need to rest.";
        else sQuestText = "I have a few scratches and am winded, but ready to continue.";
        // Set in game conversation text.
        SetCustomToken (508, sQuestText);
        return TRUE;
    }
    if(sInput == "If_Quest_Pointer")
    {
        int nQuestPointer;
        string sQuestName = GetScriptParam("sQuestName");
        if(sQuestName == "")
        {
            string sQuestID = GetQuestIDByNPC(oNPC, oPC, "giver");
            if(sQuestID == "") sQuestID = GetQuestIDByNPC(oNPC, oPC, "npc");
            if(sQuestID == "") sQuestID = GetQuestIDByPlaceable(oNPC, oPC);
            // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-ID-)
            string sQuestArray = GetServerDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
            string sQuestName = GetStringArray(sQuestArray, 0, "-");
        }
        if(sQuestName != "")
        {
            nQuestPointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestName);
        }
        else nQuestPointer = 0;
        int nParamPointer = StringToInt(GetScriptParam("nPointer"));
        Debug("0c_quest_appears", "389", "nQuestPointer: " + IntToString(nQuestPointer) +
              " nParamPointer: " + IntToString(nParamPointer));
        if(nQuestPointer == nParamPointer) return TRUE;
        return FALSE;
    }
    if(sInput == "If_Not_Quest_Pointer")
    {
        int nQuestPointer;
        string sQuestName = GetScriptParam("sQuestName");
        if(sQuestName == "")
        {
            string sQuestID = GetQuestIDByNPC(oNPC, oPC, "giver");
            if(sQuestID == "") sQuestID = GetQuestIDByNPC(oNPC, oPC, "npc");
            if(sQuestID == "") sQuestID = GetQuestIDByPlaceable(oNPC, oPC);
            // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-ID-)
            string sQuestArray = GetServerDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
            string sQuestName = GetStringArray(sQuestArray, 0, "-");
        }
        if(sQuestName != "")
        {
            nQuestPointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestName);
        }
        else nQuestPointer = 0;
        int nParamPointer = StringToInt(GetScriptParam("nPointer"));
        Debug("0c_quest_appears", "413", "nQuestPointer: " + IntToString(nQuestPointer) +
              " nParamPointer: " + IntToString(nParamPointer));
        if(nQuestPointer == nParamPointer || nQuestPointer == 0) return FALSE;
        return TRUE;
    }
    return TRUE;
}
