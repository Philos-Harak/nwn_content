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
            if(nQuestStrRef == 0)
            {
                string sMessage;
                int nRoll = d4();
                int nPlot = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "plot", sQuestID));
                if(nPlot == 1) // DestroyPlaceable.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "placeable", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "Have you destroyed it yet?";
                    if(nRoll == 2) sMessage = "Have you destroyed the " + sName + "?";    
                    if(nRoll == 3) sMessage = "I need " + sName + " gone! Is it gone?";
                    if(nRoll == 4) sMessage = "I hope you have destroyed " + sName + ". It needs to be done.";
                }
                else if(nPlot == 2 || nPlot == 3) // Deliver || Retrieve Item.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "Have do you have my item?";
                    if(nRoll == 2) sMessage = "I'm in need of " + sName + " have you brought it?";    
                    if(nRoll == 3) sMessage = "I've been waiting a long time for " + sName + ", do you have it?";
                    if(nRoll == 4) sMessage = "Welcome! " + sName + " is important to me and I'm waiting on its delivery.";                    
                }
                if(nPlot == 4 || nPlot == 6 || nPlot == 7) // Save NPC.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "I'm waiting for " + sName + ". Have you brought them?";
                    if(nRoll == 2) sMessage = "Is " + sName + " with you?";    
                    if(nRoll == 3) sMessage = "I can't wait to see " + sName + "!";
                    if(nRoll == 4) sMessage = "I hope you have come with " + sName + ".";                    
                }
                if(nPlot == 5) // Kill villain/creature.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "villain", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(sName == "")
                    {
                        sName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                        sName = "the " + GetStringArray(sName, 0, "-") + "s";                        
                    }
                    if(nRoll == 1) sMessage = "Have you killed " + sName + "?";
                    if(nRoll == 2) sMessage = "We need " + sName + " killed! Have you finished them off yet?";    
                    if(nRoll == 3) sMessage = "Has " + sName + " been defeated? They must be removed!";
                    if(nRoll == 4) sMessage = "Death must come to " + sName + "! Are they dead?";                    
                }
                if(nPlot == 8) // Clear area of creatures.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "area", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    string sCreatureName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures");
                    sCreatureName = GetStringArray(sCreatureName, 0, "-");
                    if(nRoll == 1) sMessage = "Is " + sName + " been cleared of the " + sCreatureName + "s?";
                    if(nRoll == 2) sMessage = "Has the " + sCreatureName + "s been removed from " + sName + "?";    
                    if(nRoll == 3) sMessage = "The area of " + sName + " must be cleansed! Have you removed the " + sCreatureName + "s?";
                    if(nRoll == 4) sMessage = "All of the " + sCreatureName + "s must be eliminated! Is " + sName + " free of them?";                    
                }
                SetCustomToken(503, sMessage);
            }
            else 
            {
                string sQuestText = GetStringByStrRef(nQuestStrRef + 3);
                sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                SetCustomToken(503, sQuestText);
            }
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
            if(nQuestStrRef == 0)
            {
                string sMessage;
                int nRoll = d4();
                int nPlot = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "plot", sQuestID));
                if(nPlot == 1) // DestroyPlaceable.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "placeable");
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "It has been destroyed!";
                    if(nRoll == 2) sMessage = "I have destroyed the " + sName + ".";    
                    if(nRoll == 3) sMessage = "The " + sName + " is no more.";
                    if(nRoll == 4) sMessage = "I have finished the task.";
                }
                else if(nPlot == 2 || nPlot == 3) // Deliver || Retrieve Item.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "I have brought your item.";
                    if(nRoll == 2) sMessage = "I have the " + sName + ". Take it.";    
                    if(nRoll == 3) sMessage = "Here is your " + sName + ".";
                    if(nRoll == 4) sMessage = "I've come with the " + sName +".";                    
                }
                if(nPlot == 4 || nPlot == 6 || nPlot == 7) // Save NPC.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(nRoll == 1) sMessage = "Here is " + sName + ". Safe after a long journy.";
                    if(nRoll == 2) sMessage = "I've brought " + sName + " with me.";    
                    if(nRoll == 3) sMessage = "We have made it. They are safe.";
                    if(nRoll == 4) sMessage = "As requested, I have " + sName + " in custody.";                    
                }
                if(nPlot == 5) // Kill villain/creature.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "villain", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(sName == "")
                    {
                        sName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                        sName = " the " + GetStringArray(sName, 0, "-");                        
                    }
                    if(nRoll == 1) sMessage = "I have killed " + sName + ".";
                    if(nRoll == 2) sMessage = "Yes, " + sName + " is dead!";    
                    if(nRoll == 3) sMessage = "I found and defeated " + sName + "!";
                    if(nRoll == 4) sMessage = "I put " + sName + " to death. They will harm no one now!";                    
                }
                if(nPlot == 8) // Clear area of creatures.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "area", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    string sCreatureName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                    sCreatureName = GetStringArray(sCreatureName, 0, "-");
                    if(nRoll == 1) sMessage = "I have cleared " + sName + " of all the" + sCreatureName + "s.";
                    if(nRoll == 2) sMessage = "I killed all the " + sCreatureName + "s and " + sName + " is free once again.";    
                    if(nRoll == 3) sMessage = "The area of " + sName + " has been cleared of all the " + sCreatureName + "s!";
                    if(nRoll == 4) sMessage = "No more " + sCreatureName + "s will plague " + sName + " anymore.";                    
                }
                SetCustomToken(504, sMessage);
            }
            else 
            {
                //Debug("0c_if_quest_done", "18", "sQuestID: " + sQuestID + " nQuestStrRef: " + IntToString(nQuestStrRef));
                string sQuestText = GetStringByStrRef(nQuestStrRef + 4);
                sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                SetCustomToken(504, sQuestText);
            }
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
                if(nQuestStrRef == 0)
                {
                    string sMessage;
                    int nRoll = d4();
                    int nPlot = StringToInt(GetServerDatabaseString(oPC, QUEST_TABLE, "plot", sQuestID));
                    if(nPlot == 1) // DestroyPlaceable.
                    {
                        string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "placeable", sQuestID);
                        sName = GetStringArray(sName, 0, "-");
                        if(nRoll == 1) sMessage = "I have not found it yet.";
                        if(nRoll == 2) sMessage = "I have not destroyed the " + sName + ".";    
                        if(nRoll == 3) sMessage = "I am still looking for the " + sName + ".";
                        if(nRoll == 4) sMessage = "The task still must be done.";
                    }
                    else if(nPlot == 2 || nPlot == 3) // Deliver || Retrieve Item.
                    {
                        string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
                        sName = GetStringArray(sName, 0, "-");
                        if(nRoll == 1) sMessage = "I do not have your item.";
                        if(nRoll == 2) sMessage = "I don't have the " + sName + ".";    
                        if(nRoll == 3) sMessage = "The " + sName + " has eluded me.";
                        if(nRoll == 4) sMessage = "I will come back once I have the " + sName +".";                    
                    }
                    if(nPlot == 4 || nPlot == 6 || nPlot == 7) // Save NPC.
                    {
                        string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
                        sName = GetStringArray(sName, 0, "-");
                        if(nRoll == 1) sMessage = "I have not found " + sName + ".";
                        if(nRoll == 2) sMessage = "I am searching for " + sName + ". I will have them back soon.";    
                        if(nRoll == 3) sMessage = "I will start looking for them.";
                        if(nRoll == 4) sMessage = "I've got a plan to get " + sName + " back to you.";                    
                    }
                    if(nPlot == 5) // Kill villain/creature.
                    {
                        string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "villain", sQuestID);
                        sName = GetStringArray(sName, 0, "-");
                        if(sName == "")
                        {
                            sName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                            sName = "the " + GetStringArray(sName, 0, "-");                        
                        }
                        if(nRoll == 1) sMessage = "I have not killed " + sName + ".";
                        if(nRoll == 2) sMessage = "No, " + sName + " have eluded me!";    
                        if(nRoll == 3) sMessage = "I need to find and defeated " + sName + " still!";
                        if(nRoll == 4) sMessage = "I will put " + sName + " to death. This I swear!";                    
                    }
                    if(nPlot == 8) // Clear area of creatures.
                    {
                        string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "area", sQuestID);
                        sName = GetStringArray(sName, 0, "-");
                        string sCreatureName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                        sCreatureName = GetStringArray(sCreatureName, 0, "-");
                        if(nRoll == 1) sMessage = "The area of " + sName + " is not safe yet. I will kill the " + sCreatureName + "s soon.";
                        if(nRoll == 2) sMessage = "Unfortunately No, I need to kill all the " + sCreatureName + "s in " + sName + ".";    
                        if(nRoll == 3) sMessage = "I will go to " + sName + " remove all the " + sCreatureName + "s!";
                        if(nRoll == 4) sMessage = "The " + sCreatureName + "s still plague " + sName + ". I will go and remove them.";                    
                    }
                    SetCustomToken(505, sMessage);
                }
                else
                {
                    string sQuestText = GetStringByStrRef(nQuestStrRef + 5);
                    sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                    SetCustomToken(505, sQuestText);
                }
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
            // Get quest conversation lines. It is strref line #1.
            int nQuestStrRef = StringToInt(SqlGetString(sqlplot, 2));
            if(nQuestStrRef == 0)
            {
                string sPCMessage, sNPCMessage;
                int nRoll = d4();
                // Plot - 4 Save NPC, 6 Deliver NPC to Finish Area, 7 Deliver NPC to Finish NPC.
                if(sPlot == "4" || sPlot == "6" || sPlot == "7")
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "finish", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    // NPC not picked up so setup first conversation.
                    if(GetStringArray(sStateArray, 5, "-") == "0")
                    {
                        if(nRoll == 1) sNPCMessage = "Are you here to take me back?"; 
                        if(nRoll == 2) sNPCMessage = "Can I join your party?"; 
                        if(nRoll == 3) sNPCMessage = "I need to go to " + sName + ", will you take me?"; 
                        if(nRoll == 4) sNPCMessage = "Take me with you! I am from " + sName + "."; 
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, come with me to " + sName + ".";
                        if(nRoll == 2) sPCMessage = "Yes, I'd like for you to join me.";
                        if(nRoll == 3) sPCMessage = "I'm heading to " + sName + ", lets go.";
                        if(nRoll == 4) sPCMessage = "I will protect you until we get to " + sName + ".";
                    }
                    else // NPC picked up so setup not done conversation.
                    {
                        if(nRoll == 1) sNPCMessage = "Are we headed to " + sName + "?"; 
                        if(nRoll == 2) sNPCMessage = "I can't wait to get to " + sName + "."; 
                        if(nRoll == 3) sNPCMessage = "You will take me to " + sName + "? I must get there."; 
                        if(nRoll == 4) sNPCMessage = "Thank you for your protection, but hopefully I will not need it long."; 
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, we should be there soon.";
                        if(nRoll == 2) sPCMessage = "I shall get you to " + sName + " as soon as possible.";
                        if(nRoll == 3) sPCMessage = "We are headed there. It is a long trip to " + sName +".";
                        if(nRoll == 4) sPCMessage = "My plan is to get to " + sName + ". It may take some time.";
                    }
                }
                if(sPlot == "1") // DestroyPlaceable.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "placeable", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    string sAreaName = GetServerDatabaseString(oPC, QUEST_TABLE, "finish", sQuestID);
                    sAreaName = GetStringArray(sAreaName, 0, "-");
                    if(bQuestDone)
                    {
                        if(nRoll == 1) sNPCMessage = "Now that " + sName + " is destroyed, we can go back to " + sAreaName  + "."; 
                        if(nRoll == 2) sNPCMessage = "I can't wait to get back to " + sAreaName + ".";    
                        if(nRoll == 3) sNPCMessage = "The " + sName + " is destroyed! It is good to be victorious.";
                        if(nRoll == 4) sNPCMessage = "Let's go to " + sAreaName + " now that the " + sName + " is destroyed.";
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, we should be there soon.";
                        if(nRoll == 2) sPCMessage = "We will get to " + sAreaName + " as soon as possible.";
                        if(nRoll == 3) sPCMessage = "We are headed there. It is a long trip to " + sAreaName +".";
                        if(nRoll == 4) sPCMessage = "My plan is to get to " + sAreaName + ". It may take some time.";
                    }
                    else
                    {
                        if(nRoll == 1) sNPCMessage = "Where is the " + sName + "? It must be destroyed!"; 
                        if(nRoll == 2) sNPCMessage = "We have not destroyed the " + sName + ". That is our task!";    
                        if(nRoll == 3) sNPCMessage = "Are we looking for the " + sName + "? If not we must start!";
                        if(nRoll == 4) sNPCMessage = "The task still must be done. Find the " + sName + " and destroy it!";
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, we should be there soon.";
                        if(nRoll == 2) sPCMessage = "I shall get you to " + sName + " as soon as possible.";
                        if(nRoll == 3) sPCMessage = "We are headed there. It is a long trip to " + sName +".";
                        if(nRoll == 4) sPCMessage = "My plan is to get to " + sName + ". It may take some time.";
                    }
                }
                if(sPlot == "2" || sPlot == "3") // 2)Deliver item or 3)Retrieve item.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    string sFinisherName = GetServerDatabaseString(oPC, QUEST_TABLE, "finisher", sQuestID);
                    sFinisherName = GetStringArray(sFinisherName, 0, "-");
                    if(nRoll == 1) sNPCMessage = "We must get " + sName + " to " + sFinisherName + " as quickly as possible!"; 
                    if(nRoll == 2) sNPCMessage = "I know " + sFinisherName + " needs " + sName + ". We must hurry!";    
                    if(nRoll == 3) sNPCMessage = "Are we looking for " + sFinisherName + "? I must get " + sName + " to them!";
                    if(nRoll == 4) sNPCMessage = "We must deliver " + sName + " to " + sFinisherName + ".";
                    nRoll = d4();
                    if(nRoll == 1) sPCMessage = "Yes, we are looking for " + sFinisherName + ".";
                    if(nRoll == 2) sPCMessage = "We will get " + sName + " to " + sFinisherName + " as soon as possible.";
                    if(nRoll == 3) sPCMessage = "We on our way. It will be a long trip to " + sFinisherName +".";
                    if(nRoll == 4) sPCMessage = "We will deliver " + sName + " to " + sFinisherName + ". It may take some time.";
                }
                if(sPlot == "5" || sPlot == "8") // 5)Kill Villain/Creature or 8)Clear area of creatures.
                {
                    string sName = GetServerDatabaseString(oPC, QUEST_TABLE, "villain", sQuestID);
                    sName = GetStringArray(sName, 0, "-");
                    if(sName == "")
                    {
                        sName = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
                        sName = "the " + GetStringArray(sName, 0, "-") + "s";                        
                    }
                    string sAreaName = GetServerDatabaseString(oPC, QUEST_TABLE, "area", sQuestID);
                    sAreaName = GetStringArray(sAreaName, 0, "-");
                    if(bQuestDone)
                    {
                        if(nRoll == 1) sNPCMessage = "Death has come to " + sName + ". Now we can get back."; 
                        if(nRoll == 2) sNPCMessage = "Our mission is complete! The " + sAreaName + " is safe.";    
                        if(nRoll == 3) sNPCMessage = "With the " + sName + " dead. We can celebrate our victory and return.";
                        if(nRoll == 4) sNPCMessage = "The quest is over. We need to report back.";
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, we should be back soon.";
                        if(nRoll == 2) sPCMessage = "We will get back as soon as possible.";
                        if(nRoll == 3) sPCMessage = "Yes, it is good that the " + sName + " is dead.";
                        if(nRoll == 4) sPCMessage = "My plan is to get back now that the defeat of " + sName + " is complete!";
                    }
                    else
                    {
                        if(nRoll == 1) sNPCMessage = "Where is the " + sAreaName + "? We must find and kill " + sName + "!"; 
                        if(nRoll == 2) sNPCMessage = "The area of " + sAreaName + " is not safe. Our task is to eliminate " + sName + "!";    
                        if(nRoll == 3) sNPCMessage = "We must go to " + sAreaName + " and kill " + sName + " before they get away!";
                        if(nRoll == 4) sNPCMessage = "Our task is to find " + sAreaName + " and defeat the " + sName + ". Lets hurry!";
                        nRoll = d4();
                        if(nRoll == 1) sPCMessage = "Yes, we should be there soon.";
                        if(nRoll == 2) sPCMessage = "I shall get you to " + sName + " so we can kill " + sName + ".";
                        if(nRoll == 3) sPCMessage = "We are headed to " + sAreaName + " now. You will get to kill " + sName + " soon enough.";
                        if(nRoll == 4) sPCMessage = "My plan is to get to " + sAreaName + ". We will defeat " + sName + " and return victorious.";
                    }
                }
                SetCustomToken(509, sNPCMessage);
                SetCustomToken(510, sPCMessage);           
            }
            else
            {
                // Plot - 4 Save NPC.
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
                else if(sPlot == "6") // Deliver creature to an area.
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
                string sQuestText = GetStringByStrRef(nQuestStrRef + nStrRefNPC);
                sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                SetCustomToken(509, sQuestText);
                sQuestText = GetStringByStrRef(nQuestStrRef + nStrRefPC);
                sQuestText = ParseQuestTextByDatabase(sQuestText, sQuestID, oPC);
                SetCustomToken(510, sQuestText);
            }
            DelayCommand(0.0f, SaveQuestPaperToPC(oPC, sQuestID));
            return TRUE;
        }
        return FALSE;
    }
    if(sInput == "If_Quest_Continues")
    {
        // Get the last quest paper.
        object oPaper = GetLocalObject(oPC, "0_QUEST_PAPER");
        if(oPaper == OBJECT_INVALID) return FALSE;
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
            if(oPaper == OBJECT_INVALID) return FALSE;
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
                Debug("0c_quest_action", "101", "sQuestArray: " + sQuestArray);
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
            Debug ("0c_quest_appears", "284", "RequiredQuestName: " + sRequiredQuestName +
                   " nRequiredQuestPointer: " + IntToString(nRequiredQuestPointer));
            // There is a required quest and it has not been done. (-1 is done).
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
        if(nHP == nMaxHP) sQuestText = "I'm fully rested and ready to go.";
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
            sQuestName = GetStringArray(sQuestArray, 0, "-");
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
            sQuestName = GetStringArray(sQuestArray, 0, "-");
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
