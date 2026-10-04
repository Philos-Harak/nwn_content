/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_quest
//////////////////////////////////////////////////////////////////////////////////////////////////////
Include scripts for use with quests.
 Note Predefining variables on NPC's:
 0_Required_Reputation - Int - minimum reputation to get this NPC's quest.
 0_Required_Quest - Int - The number of the request needed to get this NPC's quest.
 0_Quest_Type  type of quest given(0 - Main Quest, 1 - Side Quest(Random), 2 - Town Quest).
 0_Quest_Name       defines the name of the quest for this NPC.
 0_Quest_Opening    defines the quest NPC's opening line to the PC.

 Below is the variables on the quest paper to build the quest in the world.
 Variables saved on any quest paper "0_Q_*".
 QUEST(Str/Array "-") The quests starting information.
        Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-ID-)
            Name - Name of the quest. Used on the quest paper.
            CR - Challenge Rating of the Quest. Tells the Player the level of the quest.
            If left blank the CR will be equal to the PC
            Quest_Pointer - Number of this quest in the row line of quest_list.2da.
            Next_Quest_Pointer - links this quest to the next quest in the chain.
            Put END to designate this as the last quest in this chain.
            Tasks - Used if this is quest type 10(Do X tasks). This number is the
            number of tasks that needs to be completed.
            Quest_Type - The quest is a 0) Main quest, 1)Side quest, 2)Town quest 3)Treasure maps.
            Journal_ID - The ID of the quests name if you need to add a journal entry.
            Visual_Effect - The effect # to play when the quest is taken. 145 is default.
            Sound_Effect - The sound file to play when the quest is taken. "as_fanfare_intro" is default.
            Leave_Method - The Giver will leave when quest is taken. "TELEPORT", FAREXIT, NEAREXIT".
 STRREF(Str) Quests String Reference in the Tlk file of the quest description.
 ID(Str) The unique id of this quest: Side quests = Side_Quest_ID + DATETIME,
                                      Main quests = Main_Quest_ID 
                                      Location quests = Loc_Quest_ID.
 PLOT(Str) Quest Plot:
         1 - Destroy Object         5 - Kill villain only            9 - Talk to NPC
         2 - Deliver item           6 - Deliver creature to area     10 - Do X special tasks
         3 - Retrieve item          7 - Deliver creature to finisher 11 - Gain selected item.
         4 - Retrieve creature      8 - Clear area of creatures and villain.
 START (Str/Array "-") Quest starting location.
        Array:(-Area_Name-Area_Tag-Town_Area-)
        Town_Area defines what town's random area selections it uses.
       (Essembra, Hap, Ashabenford, Blackfeather bridge(BFBridge), Featherfalls, Shadowdale)
 GIVER (Str/Array "-") NPC Quest giver.
         Array:(-Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-)
 AREA  (Str/Array "-") Quest area location where the player will find NPC's and hostile creatures.
        Area Array:(-Area_Name-Area_Tag-)
 NPC   (Str/Array "-") Neutral/Defending NPC in the quest.
        Array:(-Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-Wounded%-Saved-)
 VILLAIN(Str/Array "-") Villain in the quest.
        Array:(-Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-Wounded%-)
 CREATURES(Str/Array "-") Hostile creatures in the quest that spawn in the AREA location.
        creature Array:(-Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)
 ALLIES(Str/Array "-") Neutral/Defending creatures in the quest that spawn in the AREA location.
        ally Array:(-Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)
 FOLLOWERS(Str/Array "-") Neutral/Defending creatures in the quest that spawn in the FINISH location.
        creature Array:(-Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)
 ENEMIES(Str/Array "-") Hostile creatures in the quest that spawn in the FINISH location.
        Enemies Array:(-Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-)
 GIVEITEM(Str/Array "-") Item to give PC from Giver in the quest.
        Give Array:(-Name-BaseName-BaseItemType-ResRef-ID-)
 ITEM  (Str/Array "-") Item in the quest usually in the AREA location.
        Item Array:(-Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-)
 PLACEABLE(Str/Array "-") Placeable in the quest that spawns in the AREA location.
        Array:(-Name-ResRef-ID-Waypoint spawn)
 FPLACEABLE(Str/Array "-") Placeable in the quest that spawns in the FINISH location.
        Array:(-Name-ResRef-ID-Waypoint spawn)
 FINISH(Str/Array "-") Quest finishing location.
        Finish Array:(-Area_Name-Area_Tag-)
 FINISHER(Str/Array "-") NPC Quest finisher.
         Array:(-Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-Wounded%-)
 REWARDS(Str/Array "-") Rewards given to the PC for finishing this quest chain or end of quest.
        Rewards Array:(-Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-Leave_Method-)
            Fame/Infamy - If the PC gets a check to increase their fame/infamy on a successfull quest.
            XP/Gold - The amount of XP/Gold gained per quest level. Cap of 50xp per level and total cap of 500xp.
            KEEP - If set to KEEP then the item from quest type 3 will not be taken from the player.
            Journal_ID - The ID of the quests name if you need to add a journal entry.
            Visual_Effect - The effect # to play when the quest is finished.
            Sound_Effect - The sound file to play when the quest is finished.
            Leave_Method - The Finisher will leave when quest is finished. "TELEPORT", FAREXIT, NEAREXIT".
        For consistancy quests give no more than 50xp per level(except tutorial) and cap at 300xp.
 STATE(Str/Array "-") Quest State: What the PC has done in the quest.
         Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
         0 - Not used.
         1 - Object Destroyed.         6 - Area found.
         2 - Villain Killed.           7 -(Has allies)
         3 - Creature Killed.          8 - Area Cleared.
         4 - Item Picked up.           9 - Escorted NPC is dead.
         5 - NPC Picked up.            10 - Finished X number of tasks.

 Quest pointer information on the player: It is saved by the Quest Name.
    It can be any number in the sequence of the quest parts See quest_list.2da. 1 is thus column 1 in quest_list.2da.
    When finished it will be -1 to denote the quest is done.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
//#include "0i_treasure"
#include "0i_character"
#include "0i_spawn"
#include "0i_npc"
#include "0i_area"
// Returns TRUE if oPC is in sQuestID's finish area.
int GetIsInQuestFinishArea(object oPC, string sQuestID);
// Returns TRUE if oPC has sQuestID Plot Item in their inventory or equiped.
int GetHasQuestItem(object oPC, string sQuestID);
// Returns the ResRef of a creature within sEncounter at nlevel.
// Used to pull creature resref's from the encounter charts.
string GetEncounterResRef(string sEncounter, int nLevel);
// Rolls from a list of encounters based on the encounter type in quest_list.2da
string GetEncounterChart(string sEncounterTypes);
// Checks for any waypoint that might summon a resref, or have sWaypoint as a tag.
// If it does not then it will randomize from the waypoints in the area.
object GetQuestWaypoint(object oArea, string sResRef, string sWaypoint);
// Gives Quest update sounds and visual.
// oPC is the PC getting the update.
// sQuestID is the Quest ID in the database we want to use for rewards.
// sMessage is the update message to give to the player.
// bUpdateDescription if TRUE it will update the description with the sMessage text.
// bReward if TRUE it will use sQuestID's rewards.
// nVFX defines if we do nVFX for the update.
// sSound if set will play the sound given.
void QuestUpdate(object oPC, string sQuestID, string sMessage = "", int bUpdateDescription = FALSE, int bRewards = FALSE, int nVFX = 0, string sSound = "");
// Check to make sure the PC's on the quest is near the kill.
// Then register the kill.
// oCreature is the creature killed.
// oKiller is the creature that killed.
// sQuestID is the ID of the quest for this dead creature.
void CheckQuestKill(object oKilled, object oKiller, string sQuestID);
// Returns the quest creature if either found in oArea or created in oArea.
// oArea is the Area to check for the creature.
// sQuestID is the ID of the quest to check from.
// sNPCArray is the npc array of the creature we are checking.
//     i.e. sGiverarray, sNPCArray, sFinisherarray, sVillainArray.
// oWaypoint will be used unless its set to OBJECT_INVALID.
object GetQuestCharacter(object oPC, object oArea, string sQuestID, string sNPCArray, object oWaypoint = OBJECT_INVALID);
// Returns TRUE if if oCreature has either a main or side quest that oPC has.
// oPC is the PC to check for.
// oCreature is the NPC to check.
// sQuestID is the quest ID for main quests to continue.
int CheckNPCHasQuestReady(object oPC, object oCreature, string sQuestID = "");
// Returns TRUE if tracks are found for a quest on oUser or their master.
// Sends a message of what direction oPC should go for any quests succesfully checked.
// oHenchman is the henchman checking for oPC. OBJECT_INVALID makes the player check.
int TrackQuests(object oPC, object oHenchman, int bFoundTracks = FALSE);
// Return quest paper on oPC for sQuestID.
object GetQuestPaper(object oPC, string sQuestID);
// Find quest paper on oPC for sQuestID then save to "0_QUEST_PAPER" object variable.
void SaveQuestPaperToPC(object oPC, string sQuestID);
// RETURNS TRUE if oPC has MAX_QUESTS.
int HasMaximumNumberOfQuests(object oPC);
//******************************************************************************
//*********      Return quest information from the database             *********
//******************************************************************************
// Adds a quest paper to the players database for quicker checks.
// Used in the 0e_aquireitem event script.
void AddQuestPaperToDatabase(object oPC, object oItem);
// Removes a quest paper from the players database for quicker checks.
// Used in the 0e_unaquireitem event script.
void RemoveQuestPaperFromDatabase(object oPC, object oItem);
// On character load check to see if they are on any quests.
// If so then reload any NPC henchman or item variables.
// oPC is the PC to check.
void CheckForQuestNPCsOnLoad(object oPC);
// Returns the quests pointer saved to oPC's database for sQuestName.
// If the quest has not been started it will point to the first quest in the chain.
// Returns -1 if the pointer is at the end.
// Returns -2 if there is no quest with that name.
// nQuestType is the quest type: MAIN_QUESTS(0), SIDE_QUESTS(1), TOWN QUESTS(2).
int GetQuestPointerFromDataBase(object oPC, string sQuestName, int nQuestType = 0);
//******************************************************************************
//**********      Get Quest ID from database with scripts              *********
//******************************************************************************
// These scripts get a quest paper from a PC that use the object we are searching from.

// Returns the quest database ID linked to the Quest name.
// returns "" if the quest name is not found in the database.
string GetQuestIDByQuestName(object oPC, string sQuestName);
// Returns quest database ID linked to oNPC.
// Linked to sNPCVar = giver, npc, villain, finisher.
// returns "" if the NPC is not found in the database.
string GetQuestIDByNPC(object oNPC, object oPC, string sNPCVariable);
// Returns the quest database ID linked to oArea tag.
// Linked to sAreaVariable = start, area or finish.
// returns "" if the area is not found in the database.
string GetQuestIDByAreaTag(object oArea, object oPC, string sAreaVariable);
// Returns quest database ID linked to oItem in oPC's inventory.
// returns "" if the item is not found in the database.
string GetQuestIDByItem(object oItem, object oPC);
// Returns quest database ID linked to oPlaceable tag.
// returns "" if the placeable is not found in the database.
string GetQuestIDByPlaceable(object oPlaceable, object oPC);
// Returns quest database ID linked to oCreature tag.
// returns "" if the creature is not found in the database.
string GetQuestIDByCreature(object oCreature, object oPC);
// Returns the array set in the TLK for any quest information.
// Quest information must use the "-" array delimiter.
// sData is the quest text to pull the array from [QUEST:---].
// iPosition is the position pointing to the begining of the data.
// Note the array must end in a "]"
string GetQuestData(string sData, int iPosition);
// Returns the parsed quest text.
// sText is the text to parse.
// oPaper is the quest item with the quest variables.
// oPC is the player with the paper.
string ParseQuestTextByPaper(string sText, object oPaper, object oPC);
// Returns the parsed quest text.
// sText is the text to parse.
// sQuestID is the ID of the quest we are parsing.
// oPC is the player of the quest.
string ParseQuestTextByDatabase(string sText, string sQuestID, object oPC);

//******************************************************************************
//**********                Area Quest creation scripts                *********
//******************************************************************************
// These scripts are used for setting a quest array upon an area so we know
// what quests are active in the area. We use the quests ID to make each quest
// in the area unique.
// Quest ID for Story Quests are Story_Quest_ID (MAIN_## is the Quest number).
// Quest ID for Location Quests are Loc_Quest_ID (LOC_## is the Quest number) + GetDateTimeString().
// Quest ID for Side Quests are Side_Quest_ID (SIDE_## is the Quest number) + GetDateTimeToString().;

// Checks oPC's database for quests in oArea then saves them to the area.
// These are used in other scripts to pull quests linked to the area.
void CheckPCQuestIDsByArea(object oPC, object oArea);
// Checks to see if the area has any quests setup for sQuestID.
// An area can have up to 10 quest active.
// sPCName is the TRUE PC name.
// oArea = The area the PC is in.
// Returns 0 if not found and sets the oArea to having sQuestID
//         1 if sQuestID has been set on oArea but sPCName has not been here
//           then sets the PC as having been here.
//         2 if quest found and PC has been here.
int CheckandSaveAreaQuestArray(string sPCName, object oArea, string sQuestID);
// Returns TRUE if sQuestID has been finished by oPC.
int GetIsQuestDone(object oPC, string sQuestID);
// Returns sQuestText with text for the giver moving to a new location, only if it is a side quest.
string CheckIsGiverMoving(object oPC, object oPaper, string sQuestText);
// Based upon sLeave Method oNPC will leave the area.
// sLeaveMethod can be one of the following:
// TELEPORT - oNPC teleports away.
// FAREXIT - oNPC walks to and opens if it is a door the farthest exit in the area and disappears.
// NEAREXIT - oNPC walks to and opens if it is a door the nearest exit in the area and disappears.
// Tag of an object - oNPC walks to and disappears next to the nearest object with sLeaveMethod as its tag.
void MakeNPCLeave(object oPC, object oNPC, string sLeaveMethod);
// STATE(Str/Array "-") Quest State: What the PC has done in the quest.
//         Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
//         1 - Object Destroyed.         6 - Area found.
//         2 - Villain Killed.           7 -
//         3 - Creature Killed.          8 - Area Cleared.
//         4 - Item Picked up.           9 - Escorted NPC is dead.
//         5 - NPC Picked up.            10 - Finished X number of tasks.
// nValue is usually 0, 1, 2 not used, or x number for a task.
int GetQuestState(object oPC, string sQuestID, int nState);
// STATE(Str/Array "-") Quest State: What the PC has done in the quest.
//         Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
//         1 - Object Destroyed.         6 - Area found.
//         2 - Villain Killed.           7 -
//         3 - Creature Killed.          8 - Area Cleared.
//         4 - Item Picked up.           9 - Escorted NPC is dead.
//         5 - NPC Picked up.            10 - Finished X number of tasks.
// nValue is usually 0, 1, 2 not used, or x number for a task.
void SetQuestState(object oPC, string sQuestID, int nState, int nValue);
// Returns the next quest pointer based on the QuestID.
// -1 is the end of the quest.
// -2 means clear the quest.
// All other numbers point to the quest_list.2da line.
int GetNextQuestPointer(object oPC, string sQuestID, string sQuestArray);
// Removes the quest oNPC from oPC as a henchman.
void RemoveQuestNPC(object oPC, object oNPC);
// Checks the oPaper for an NPC and makes them a henchman for oPC.
void GiveQuestNPC(object oPC, string sQuestID, string sNPCArray, string sQuestArray);
// Checks the area for an NPC from the NPCArray.
// Sets them with the Quest ID and returns the NPC or OBJECT_INVALID.
object CheckForNPC(object oPC, object oArea, string sNPCArray);
//******************************************************************************
//**********                     Get Quest StrRef                      *********
//******************************************************************************

int GetLocationQuestStrRef (object oPC, object oNPC);
int GetStoryQuestStrRef (object oPC, object oNPC);
int GetSideQuestStrRef (object oPC, object oNPC);
//******************************************************************************
//**********              Area Quest Population System                 *********
//******************************************************************************

void CreateQuestItem(object oPC, object oContainer, string sQuestID, string sItemType);
void PopulatePlaceables(string sPlaceableArray, string sItemArray, location lLocation);
void PopulateQuestCreatures(object oPC, object oWaypoint, string sCreatureArray, int nFaction = 4);
void PopulateAreaQuestItem(object oPC, object oArea, object oWaypoint, string sQuestID);
void PopulateStartQuestArea(object oPC, object oArea, string sQuestID);
void PopulateAreaQuestArea(object oPC, object oArea, string sQuestID);
void PopulateFinishQuestArea(object oPC, object oArea, string sQuestID);

//******************************************************************************
//**********              Quest Initial Creation System                *********
//******************************************************************************
string GenerateNPCWithResRefAndSetName(string sResRef, string sArray, location lLocation);
string GenerateNPCArrayAndSetName(string sArray, int nCR, object oPC);
string GenerateCreatureArray(string sCreatureArray, int nQuestLevel, location lLocation);
string GenerateItemArray(string sItemArray, int nQuestLevel, object oPaper, object oPC);
string GeneratePlaceableArray(string sPlaceableArray, location lLocation, object oPaper);
// Returns a unique ID for each SIDE_QUEST = Time + StrRef of the quest.
// or Returns a specific ID for STORY_QUESTS & QUESTS - UNIQUE_ + [ID:]
string SaveQuestID(int nQuestType, int nQuestPointer);
// 0_Q_QUEST array -Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Start_Effect-Leave_Method-
string SaveQuestDataToArray(string sQuestText, int nQuestType, object oPC, object oArea);
int SavePlot(string sQuestText);
// 0_Q_START array -StartName-StartTag-Town_Area-
string SaveStartingAreaToArray(object oArea, object oTarget, string sQuestText);
// Returns the NPC Array for a quest based on sNPCArray value, oNPC, and nNPCType.
// sNPCArray will default to "-----------4--2--".
// oNPC the NPC to generate the NPCArray from.
// nNPCType defines what type of quest NPC they are; 0 - Generic 1 - Giver, 2 - Quest, 3 - Finisher.
// nNPCLevel is the level to generate a generic NPC - Only used with nNPCType 3.
// NPCArray -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-
string SaveNPCToArray(string sNPCArray, object oNPC, int nNPCType, object oPC, object oPaper, int nQuestLevel = 0);
// 0_Q_REWARDS array -Fame-Infamy-Xp-Gold-KEEP-Journal ID-Reward_Effect-
string SaveRewardsToArray(string sQuestText);
string SaveFinishToArray(string sQuestText, int nPlot, int nQuestType, string sTownArea, object oPaper);
string CheckForAreaToArray(string sQuestText, string sTownAreat);
string CheckForNPCToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, object oPC);
string CheckForVillianToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, object oPC);
string CheckForCreaturesToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, string sQuestVar);
string CheckForItemToArray(string sQuestText, int nQuestLevel, object oPaper, object oPC);
string CheckForGiveItemToArray(string sQuestText, int nQuestLevel, object oPaper, object oPC);
string CheckForPlaceableToArray(string sQuestText, location lLocation, object oPaper);
string CheckForFPlaceableToArray(string sQuestText, location lLocation, object oPaper);
string GetRandomTown(string sTownArea);
string GetRandomArea(string sTownArea);
object CreateBlankQuest(object oPC, object oTarget);
// Creates a quest for oPC and puts it on oTarget.
// nQuestType is the type of quest STORY_QUESTS, SIDE_QUESTS.
// nQuestStrRef is the TLK line that holds the quest.
object CreateQuest(object oPC, object oTarget, int nQuestType, int nQuestStrRef);
// Creates a treasure map quest on oPaper for oPC.
// nLevel defines the CR of the quest. 0 will set the CR to oPC's level.
// DO NOT Build treasure Maps on players! They will not transfer to the database.
void Build_Treasure_Map(object oPC, object oPaper, int nLevel = 0);

int GetIsInQuestFinishArea(object oPC, string sQuestID)
{
    object oArea = GetArea(oPC);
    string sLocationTag = GetTag(oArea);
    string sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "finish", sQuestID);
    if(sLocationTag == GetStringArray(sArray, 1, "-")) return TRUE;
    return FALSE;
}
int GetHasQuestItem(object oPC, string sQuestID)
{
    string sItemArray = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
    if(sItemArray == "") return FALSE;
    string sItemName = GetStringArray(sItemArray, 0, "-");
    // Cycle through the PC's inventory to find the item.
    object oItem = GetFirstItemInInventory(oPC);
    while(oItem != OBJECT_INVALID)
    {
        if(GetLocalString(oItem, "0_QUEST_ID") == sQuestID && GetName(oItem) == sItemName) return TRUE;
        oItem = GetNextItemInInventory(oPC);
    }
    // Now check PC's equiped items.
    int nSlot = 0;
    oItem = GetItemInSlot(nSlot, oPC);
    while(oItem != OBJECT_INVALID)
    {
        if(GetLocalString(oItem, "0_QUEST_ID") == sQuestID && GetName(oItem) == sItemName) return TRUE;
        nSlot++;
        oItem = GetItemInSlot(nSlot, oPC);
    }
    return FALSE;
}
string GetEncounterChart(string sEncounterTypes)
{
    int nRow = StringToInt(Get2DAString("quest_list", sEncounterTypes, 0));
    int nRoll = Random(nRow) + 1;
    return Get2DAString("quest_list", sEncounterTypes, nRoll);
}
string GetEncounterResRef(string sEncounter, int nLevel)
{
    // Calculate row in the 2da (each level gets 5 entries thus ((ilevel - 1) * 5) + Random (5) + 1)
    int nRow = ((nLevel - 1) * 5) + Random(5) + 1;
    return Get2DAString(sEncounter, "ResRef", nRow);
}
object GetQuestWaypoint(object oArea, string sResRef, string sWaypoint)
{
    int nIndex = 1, nNumOfWaypoints, nRoll;
    // Make sure blanks don't register.
    if(sResRef == "") sResRef = "X";
    object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    while(oWaypoint != OBJECT_INVALID)
    {
        //Debug("0i_quest", "699", "sResRef: " + sResRef + " 0_Resref: " + GetLocalString(oWaypoint, "0_Resref") +
        //       " sWaypoint: " + sWaypoint + " oWaypoint Tag: " + GetTag(oWaypoint));
        if(sResRef == GetLocalString(oWaypoint, "0_Resref") ||
            sWaypoint == GetTag(oWaypoint))
        {
            DeleteLocalInt(oArea, "0_AreaObject");
            return oWaypoint;
        }
        oWaypoint = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_WAYPOINT);
    }
    // We did not find a specific waypoint so lets randomize one from
    // all the waypoints in the area.
    nRoll = Random(nIndex) + 1;
    //Debug("0i_quest", "709", "nRoll: " + IntToString(nRoll) + " nNumOfWaypoints: " + IntToString(nNumOfWaypoints));
    return GetObjectInArea(oArea, nRoll, OBJECT_TYPE_WAYPOINT, TRUE);
}
void QuestUpdate(object oPC, string sQuestID, string sMessage = "", int bUpdateDescription = FALSE, int bRewards = FALSE, int nVFX = 0, string sSound = "")
{
    // Send message to player if there is a message to send.
    if(sMessage != "")
    {
        SendMessages(sMessage, COLOR_GREEN, oPC, FALSE, FALSE);
        if(bUpdateDescription)
        {
            // Update quest paper description if it is set.
            string sDescription = GetServerDatabaseString(oPC, QUEST_TABLE, "description", sQuestID);
            sDescription += " " + AddColorToText(sMessage, COLOR_GREEN);
            SetServerDatabaseString(oPC, QUEST_TABLE, "description", sDescription, sQuestID);
        }
    }
    // Play the sound effects if set.
    if(sSound != "") AssignCommand(oPC, PlaySound(sSound));
    // Play the visual effects if set.
    if(nVFX)
    {
        effect eQuest = EffectVisualEffect(nVFX);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eQuest, oPC);
    }
    if(bRewards)
    {
        // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-)
        string sQuestArray = GetServerDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
        int nCR = StringToInt(GetStringArray(sQuestArray, 1, "-"));
        // Rewards Array:(-Fame-Infamy-Xp-Gold-KEEP-Journal ID-Visual_Effect-Sound_Effect-)
        string sRewardsArray = GetServerDatabaseString(oPC, QUEST_TABLE, "rewards", sQuestID);
        // Increase/Decrease the players fame if required.
        int nFame = StringToInt(GetStringArray(sRewardsArray, 0, "-"));
        if(nFame != 0) CheckForReputationAdjustment(oPC, "fame");
        // Increase/Decrease the players infamy if required.
        int nInfamy = StringToInt(GetStringArray(sRewardsArray, 1, "-"));
        if(nInfamy != 0) CheckForReputationAdjustment(oPC, "infamy");
        // Give xp if possible.
        int nXp = StringToInt(GetStringArray(sRewardsArray, 2, "-"));
        if(nXp > 0)
        {
            nXp = nXp * nCR;
            // We cap xp to MAX_QUEST_XP found in 0i_constants for quests.
            if(nXp > MAX_QUEST_XP) nXp = MAX_QUEST_XP;
            AdjustXPGiveToCreature(oPC, IntToFloat(nXp));
        }
        // Give gold if possible. Quests give the amount set * quest level.
        int nGold = StringToInt(GetStringArray(sRewardsArray, 3, "-"));
        if(nGold > 0)
        {
            nGold = nGold * nCR;
            GiveGoldToCreature(oPC, nGold);
        }
    }
}
void CheckQuestKill(object oKilled, object oKiller, string sQuestID)
{
    // Get all of our information to populate the area
    object oArea = GetArea(oKilled);
    // Check all creatures incase this is a plot 8 quest.
    // Must split up the GetObjectInArea calls.
    int nCount = 1;
    int nAlive= 0;
    // Check to see if all Quest Kill creatures are dead.
    object oCreature = GetObjectInArea(oArea, nCount, OBJECT_TYPE_CREATURE);
    while(oCreature != OBJECT_INVALID)
    {
        // Check to see the quest creatures are all dead.
        // Since one quest kill creature(that is not a villain) is still
        // alive the area is not cleared.
        if(!GetIsDead(oCreature) &&
            GetLocalString(oCreature, "0_QUEST_KILL") != "" &&
            !GetLocalInt(oCreature, "0_VILLAIN") &&
            oCreature != oKilled) nAlive++;
        oCreature = GetObjectInArea(oArea, ++nCount, OBJECT_TYPE_CREATURE);
    }
    // If the killer is an NPC then increase the radius to the map(so PC's get quest credit).
    float fDistance;
    // Now check to see if any quest player(s) are near the killed creature.
    nCount = 1;
    int nVillainState, nCreatureState, nClearState;
    string sPlot, sPCName, sQueryPlot, sStateArray;
    sqlquery sqlplot;
    object oPC = GetFirstPC();
    while(oPC != OBJECT_INVALID)
    {
        fDistance = GetDistanceBetween(oPC, oKilled);
        if(fDistance <= 120.0 && fDistance != 0.0)
        {
            sPCName = GetName(oPC, TRUE);
            sQueryPlot = "SELECT plot, state FROM QuestTable WHERE name = @name AND tag = @tag;";
            sqlplot = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryPlot);
            SqlBindString(sqlplot, "@name", sPCName);
            SqlBindString(sqlplot, "@tag", sQuestID);
            if(SqlStep(sqlplot))
            {
                // Get the quest state.
                sPlot = SqlGetString(sqlplot, 0);
                sStateArray = SqlGetString(sqlplot, 1);
                nVillainState = StringToInt(GetStringArray(sStateArray, 2, "-"));
                nCreatureState = StringToInt(GetStringArray(sStateArray, 3, "-"));
                nClearState = StringToInt(GetStringArray(sStateArray, 8, "-"));
                // If this is a villain and the quest state is 0 then set the quest state.
                if(GetLocalInt(oKilled, "0_VILLAIN") && !nVillainState)
                {
                    // Set that the villain is dead in the quest state.
                    SetQuestState(oPC, sQuestID, 2, 1);
                    nVillainState = 1;
                    // If this is a kill the creature quest then update.
                    // if quest type is kill villain(5) or Kill all creatures(8).
                    if(sPlot == "5" || sPlot == "8") QuestUpdate(oPC, sQuestID, GetName(oKilled) + " has been killed!", TRUE);
                }
                // if Plot 8 - kill all creatures and Creature State(3) is 0 i.e. not done.
                else if(!nCreatureState)
                {
                    if(nAlive == 0)
                    {
                        // Update the quest paper state array that all the creatures are dead.
                        // We do this so they don't respawn later to keep people from farming.
                        SetQuestState(oPC, sQuestID, 3, 1);
                        nCreatureState = 1;
                        // Update the quest(8) that all the creatures are dead.
                        if(sPlot == "8") QuestUpdate(oPC, sQuestID, "All of the " + GetName(oKilled) + "'s have been killed!", TRUE);
                    }
                    else if(sPlot == "8" && nAlive < 6)
                    {
                        if(nAlive == 1) SendMessages(IntToString(nAlive) + " " + GetName(oKilled) + " still alive!", COLOR_RED, oPC);
                        else SendMessages(IntToString(nAlive) + " " + GetName(oKilled) + "'s still left!", COLOR_RED, oPC);
                    }
                }
                if(sPlot == "8")
                {
                    // Check to see if all Quest Creatures and villains are dead.
                    // and clear area is not set.
                    if(nVillainState && nCreatureState && !nClearState)
                    {
                        // Update state array that the area is cleared.
                        SetQuestState(oPC, sQuestID, 8, 1);
                        QuestUpdate(oPC, sQuestID, GetName(oArea) + " has been cleared!", TRUE);
                    }
                }
            }    
        }
        nCount++;
        oPC = GetNextPC();
    }
}
object GetQuestCharacter(object oPC, object oArea, string sQuestID, string sNPCArray, object oWaypoint = OBJECT_INVALID)
{
    // Get the NPC's information we will need to search.
    object oNPC = CheckForNPC(oPC, oArea, sNPCArray);
    if(oNPC == OBJECT_INVALID)
    {
        // We have not found the character so check spawn waypoints to see if they will be spawned.
        // Quests are checked before the area has been populated.
        // If they have a resref see if there is a waypoint spawn for them and we have not found them yet.
        if(oWaypoint == OBJECT_INVALID)
        {
            string sNPCResRef = GetStringArray(sNPCArray, 1, "-");
            string sNPCWaypoint = GetStringArray(sNPCArray, 11, "-");
            oWaypoint = GetQuestWaypoint(oArea, sNPCResRef, sNPCWaypoint);
            ClearWaypointSpawning(oWaypoint);
        }
        oNPC = CreateNPC(GetLocation(oWaypoint), sNPCArray);
        SetUpNPC(oNPC);
        CheckAnimations(oNPC);
        // Equip the Finisher based on array.
        int nItems = StringToInt(GetStringArray(sNPCArray, 12, "-"));
        int nPackage = StringToInt(GetStringArray(sNPCArray, 6, "-"));
        DelayCommand(0.5f, GiveCreatureEquipment(oNPC, nItems, FALSE, nPackage));
        DelayCommand(1.0f, EquipItems(oNPC, TRUE, TRUE));
        // Set if character is wounded.
        int nWounded = StringToInt(GetStringArray(sNPCArray, 13, "-"));
        SetCreatureAsWounded(oNPC, nWounded);
        // Set the ID of the character.
        SetLocalString(oNPC, "0_QUEST_ID", sQuestID);
    }
    return oNPC;
}
int CheckNPCHasQuestReady(object oPC, object oCreature, string sQuestID = "")
{
    int nQuestType, nQuestPointer;
    string sQuestListColumn, sQuestName;
    // if there is no sQuestID then this is the start of a quest
    // Get the information from the NPC.
    if(sQuestID == "")
    {
        nQuestType = GetLocalInt(oCreature, "0_Quest_Type");
        sQuestName = GetLocalString(oCreature, "0_Quest_Name");
        // if no quest name, quest name is for story quests and location questsonly.
        // and not side quest or dm quest then there is no quest.
        if(nQuestType != SIDE_QUESTS && nQuestType != DM_QUESTS && sQuestName != "") return TRUE;
    }
    // Get the last quest data from the player since we are continuing a quest.
    else
    {
        // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-
        //               Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-)
        string sQuestArray = GetServerDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
        nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
        sQuestName = GetStringArray(sQuestArray, 0, "-");
    }
    // If this is a side quest NPC then make sure PC has not done this quest already.
    // We Set a variable 0_(PC's Name) to TRUE on the NPC if the quest has been completed
    if(nQuestType == SIDE_QUESTS || nQuestType == DM_QUESTS)
    {
        string sPCName = StripColorCodes(RemoveIllegalCharacters(GetName(oPC)));
        if(!GetLocalInt(oCreature, "0_" + sPCName)) return TRUE;
    }
    else if(sQuestName != "")
    {
        // Get the PC's quest pointer from the database or quest_list.2da if
        // quest has not been started for the name of this quest.
        nQuestPointer = GetQuestPointerFromDataBase(oPC, sQuestName, nQuestType);
        if(nQuestPointer > 0) return TRUE;
    }
    return FALSE;
}
int TrackQuests(object oUser, object oHenchman, int bFoundTracks = FALSE)
{
    string sName, sQuestID, sQuestName;
    string sQuestState,sArray, sXY;
    int iMakeCheck, iDC, iCounter, iSize, iRacialType;
    int iQX, iQY, iCX, iCY, iX, iY, iDistance;
    object oTransition, oChecker, oArea = GetArea(oUser);
    if(oHenchman != OBJECT_INVALID) oChecker = oHenchman;
    else oChecker = oUser;
    location lLocation = GetLocation(oUser);
    // Find the first quest in the database.
    // ********** Check for Max quest papers.
    string sQuery = "SELECT tag, state, creatures, villain, area, quest FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oUser, TRUE));
    if(SqlStep(sql))  sQuestID = SqlGetString(sql, 0);
    while(sQuestID != "")
    {
        // Get the quest state.
        sQuestState = SqlGetString(sql, 1);
        // Check to see if this quest has creatures.
        if(GetStringArray(sQuestState, 3, "-") == "0")
        {
            sArray = SqlGetString(sql, 2);
            // Get the size and racial type.
            iSize = StringToInt(GetStringArray(sArray, 6, "-"));
            iRacialType = StringToInt(GetStringArray(sArray, 7, "-"));
            // Get the DC for the tracks.
            iDC = TrackingDC(oArea, oUser, OBJECT_INVALID, lLocation, iSize, iRacialType);
        }
        // Check to see if this quest has a villain.
        else if(GetStringArray(sQuestState, 2, "-") == "0")
        {
            sArray = SqlGetString(sql, 3);
            iRacialType = StringToInt(GetStringArray(sArray, 4, "-"));
            // Get the DC for the tracks.
            iDC = TrackingDC(oArea, oUser, OBJECT_INVALID, lLocation, CREATURE_SIZE_MEDIUM, iRacialType);
        }
        sName = "";
        if(iDC > 0 && GetStringRight(sQuestID, 3) != "map")
        {
            // Check the quest location vs current location and select a direction to go.
            // Keep in mind transitions.
            // Get the quest x,y coordinates.
            sArray = SqlGetString(sql, 4);
            sXY = GetStringArray(sArray, 1, "-");
            iQX = StringToInt(GetStringLeft(sXY, 3));
            iQY = StringToInt(GetStringRight(sXY, 3));
            // Get current location x,y coordinates.
            sXY = GetTag(oArea);
            iCX = StringToInt(GetStringLeft(sXY, 3));
            iCY = StringToInt(GetStringRight(sXY, 3));
            // Get distance from x and y.
            iX = iQX - iCX;
            iY = iQY - iCY;
            iDistance = abs(iX) + abs(iY);
            // If the distance is 0 then they are here.
            if(iDistance == 0) sName = "Fresh";
            else
            {
                // Calculate distance DC(+2 per area away).
                iDC = iDC +(iDistance * 2);
                // Make a Survival check against the DC of the tracks, Survival use to be Craft_Armor!
                if(GetSkillCheck(oChecker, SKILL_SURVIVAL, FALSE, 0, iDC, 0, FALSE) >= 0 ||
                   GetHasSpellEffect(934/*SPELL_FIND_THE_PATH*/, oUser))
                {
                    // Check the information point to see if a direction is blocked.
                    object oInfoPoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
                    // Select the direction the creatures went.
                    // Decide if they followed the x or the y axis.
                    // This follows the X axis.
                    if(abs(iX) > abs(iY))
                    {
                        // They went East if possible.
                        if(iX > 0)
                        {
                            // See if we can go East.
                            if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                            else
                            {
                                if(iY > 0)
                                {
                                    // See if we can go North.
                                    if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                                    else
                                    {
                                        // See if we can go South.
                                        if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                                        else sName = "Blocked";
                                    }
                                }
                                else
                                {
                                    // See if we can go South.
                                    if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                                    else
                                    {
                                        // See if we can go North.
                                        if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                                        else sName = "Blocked";
                                    }
                                }
                            }
                        }
                        // They went West if possible.
                        else
                        {
                            // See if we can go West.
                            if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                            else
                            {
                                if(iY > 0)
                                {
                                    // See if we can go North.
                                    if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                                    else
                                    {
                                        // See if we can go South.
                                        if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                                        else sName = "Blocked";
                                    }
                                }
                                else
                                {
                                    // See if we can go South.
                                    if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                                    else
                                    {
                                        // See if we can go North.
                                        if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                                        else sName = "Blocked";
                                    }
                                }
                            }
                        }
                    }
                    // The followed the Y axis.
                    else
                    {
                        // They went North if possible.
                        if(iY < 0)
                        {
                            // See if we can go North.
                            if(!GetLocalInt(oInfoPoint, "0_North_Blocked")) sName = "North";
                            else
                            {
                                if(iX > 0)
                                {
                                    // See if we can go East.
                                    if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                                    else
                                    {
                                        // See if we can go West.
                                        if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                                        else sName = "Blocked";
                                    }
                                }
                                else
                                {
                                    // See if we can go West.
                                    if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                                    else
                                    {
                                        // See if we can go East.
                                        if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                                        else sName = "Blocked";
                                    }
                                }
                            }
                        }
                        // They went South if possible.
                        else
                        {
                            // See if we can go South.
                            if(!GetLocalInt(oInfoPoint, "0_South_Blocked")) sName = "South";
                            else
                            {
                                if(iX > 0)
                                {
                                    // See if we can go East.
                                    if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                                    else
                                    {
                                        // See if we can go West.
                                        if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                                        else sName = "Blocked";
                                    }
                                }
                                else
                                {
                                    // See if we can go West.
                                    if(!GetLocalInt(oInfoPoint, "0_West_Blocked")) sName = "West";
                                    else
                                    {
                                        // See if we can go East.
                                        if(!GetLocalInt(oInfoPoint, "0_East_Blocked")) sName = "East";
                                        else sName = "Blocked";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            sQuestName = GetStringArray(SqlGetString(sql, 5), 0, "-");
            if(sName != "")
            {
                if(sName == "Blocked")
                {
                    SendMessages("Tracks Lead back the way you came in this area that match creatures in " + sQuestName + ".", COLOR_GREEN, oUser, FALSE, FALSE);
                    bFoundTracks = TRUE;
                }
                else if(sName == "Fresh")
                {
                    SendMessages("The tracks are very fresh in this area that match the creatures for " + sQuestName + ".", COLOR_GREEN, oUser, FALSE, FALSE);
                    bFoundTracks = TRUE;
                }
                else
                {
                    SendMessages("Tracks lead " + sName + " in this area that match creatures in " + sQuestName + ".", COLOR_GREEN, oUser, FALSE, FALSE);
                    bFoundTracks = TRUE;
                }
            }
            else if(iDC > 0)
            {
                SendMessages("There are no tracks in this area that belong to creatures in " + sQuestName + ".", COLOR_RED, oUser, FALSE, FALSE);
            }
        }
        if(SqlStep(sql)) sQuestID = SqlGetString(sql, 0);
        else sQuestID = "";
    }
    return bFoundTracks;
}
object GetQuestPaper(object oPC, string sQuestID)
{
    // Find the quest paper on oPC for sQuestID.
    object oPaper = GetFirstItemInInventory(oPC);
    while(oPaper != OBJECT_INVALID)
    {
        if(sQuestID == GetLocalString(oPaper, "0_Q_ID")) return oPaper;
        oPaper = GetNextItemInInventory(oPC);
    }
    return OBJECT_INVALID;
}
void SaveQuestPaperToPC(object oPC, string sQuestID)
{
    // Find the quest paper on oPC for sQuestID.
    object oPaper = GetFirstItemInInventory(oPC);
    while(oPaper != OBJECT_INVALID)
    {
        if(sQuestID == GetLocalString(oPaper, "0_Q_ID")) break;
        oPaper = GetNextItemInInventory(oPC);
    }
    if(oPaper != OBJECT_INVALID) SetLocalObject(oPC, "0_QUEST_PAPER", oPaper);
}
int HasMaximumNumberOfQuests(object oPC)
{
    // ********** Check for Max quest papers.
    int nNumOfQuests;
    string sQuery = "SELECT tag FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    string sQuestID;
    if(SqlStep(sql))  sQuestID = SqlGetString(sql, 0);
    while(sQuestID != "")
    {
        if(GetStringRight(sQuestID, 12) != "treasure_map") nNumOfQuests++;
        if(SqlStep(sql)) sQuestID = SqlGetString(sql, 0);
        else sQuestID = "";
    }
    if(nNumOfQuests >= MAX_QUESTS)
    {
        SendMessages("You cannot take anymore quests. The maximum is " + IntToString(MAX_QUESTS) + ".", COLOR_RED, oPC);
        return TRUE;
    }
    return FALSE;
}
void AddQuestPaperToDatabase(object oPC, object oItem)
{
    if(!GetIsCharacter(oPC)) return;
    string sID = GetLocalString(oItem, "0_Q_ID");
    //WriteTimestampedLogEntry("0i_quest, 543, Adding Quest To Database: " + sID);
    if(CheckServerDataAndInitialize(oPC, QUEST_TABLE, sID))
    {
        string sData = GetDescription(oItem);
        SetServerDatabaseString(oPC, QUEST_TABLE, "description", sData, sID);
        sData = GetLocalString(oItem, "0_Q_QUEST");
        SetServerDatabaseString(oPC, QUEST_TABLE, "quest", sData, sID);
        sData = GetLocalString(oItem, "0_Q_STRREF");
        SetServerDatabaseString(oPC, QUEST_TABLE, "strref", sData, sID);
        sData = GetLocalString(oItem, "0_Q_PLOT");
        SetServerDatabaseString(oPC, QUEST_TABLE, "plot", sData, sID);
        sData = GetLocalString(oItem, "0_Q_START");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "start", sData, sID);
        sData = GetLocalString(oItem, "0_Q_GIVER");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "giver", sData, sID);
        sData = GetLocalString(oItem, "0_Q_AREA");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "area", sData, sID);
        sData = GetLocalString(oItem, "0_Q_NPC");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "npc", sData, sID);
        sData = GetLocalString(oItem, "0_Q_VILLAIN");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "villain", sData, sID);
        sData = GetLocalString(oItem, "0_Q_CREATURES");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sData, sID);
        sData = GetLocalString(oItem, "0_Q_ALLIES");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "allies", sData, sID);
        sData = GetLocalString(oItem, "0_Q_FOLLOWERS");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "followers", sData, sID);
        sData = GetLocalString(oItem, "0_Q_ENEMIES");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "enemies", sData, sID);
        sData = GetLocalString(oItem, "0_Q_GIVEITEM");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "giveitem", sData, sID);
        sData = GetLocalString(oItem, "0_Q_ITEM");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "item", sData, sID);
        sData = GetLocalString(oItem, "0_Q_PLACEABLE");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "placeable", sData, sID);
        sData = GetLocalString(oItem, "0_Q_FPLACEABLE");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "fplaceable", sData, sID);
        sData = GetLocalString(oItem, "0_Q_FINISH");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "finish", sData, sID);
        sData = GetLocalString(oItem, "0_Q_FINISHER");
        if(sData != "") SetServerDatabaseString(oPC, QUEST_TABLE, "finisher", sData, sID);
        sData = GetLocalString(oItem, "0_Q_REWARDS");
        SetServerDatabaseString(oPC, QUEST_TABLE, "rewards", sData, sID);
        sData = GetLocalString(oItem, "0_Q_STATE");
        SetServerDatabaseString(oPC, QUEST_TABLE, "state", sData, sID);
    }
}
void RemoveQuestPaperFromDatabase(object oPC, object oItem)
{
    string sID = GetLocalString(oItem, "0_Q_ID");
    if(sID != "") DeleteServerDatabaseObject(oPC, QUEST_TABLE, sID);
}
void CheckForQuestNPCsOnLoad(object oPC)
{
    int nItems;
    string sQuestID, sStateArray, sNPCArray, sNPCSlot, sID;
    object oQuestNPC;
    // Get the location to spawn the NPC.
    location lLocation = GetLocation(oPC);
    string sQuery = "SELECT tag, state, npc FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql))  sQuestID = SqlGetString(sql, 0);
    while(sQuestID != "")
    {
        // Check to see if the PC should have an NPC from a quest.
        sStateArray = SqlGetString(sql, 1);
        // State 5 = 1 Is NPC picked up, State 9 = Is NPC dead.
        //Debug("0i_quest", "1140", "State 5: " + GetStringArray(sStateArray, 5, "-") +
        //       " State 9: " + GetStringArray(sStateArray, 9, "-"));
        if(GetStringArray(sStateArray, 5, "-") == "1" &&
           GetStringArray(sStateArray, 9, "-") == "0")
        {
            // 0_Q_NPC array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1
            //               -Align2-Faction-Waypoint spawn-Items-Wounded%-Saved-
            sNPCArray = SqlGetString(sql, 2);
            sNPCSlot = GetStringArray(sNPCArray, 14, "-");
            //Debug("0i_quest", "1149", "oPC: " + GetName(oPC) + " sNPCSlot: " + sNPCSlot + " sNPCArray: " + sNPCArray);
            oQuestNPC = GetServerDatabaseObject(oPC, OBJECT_TABLE, lLocation, OBJECT_INVALID, sNPCSlot);
            if(!GetIsObjectValid(oQuestNPC)) oQuestNPC = GetQuestCharacter(oPC, GetArea(oPC), sQuestID, sNPCArray, oPC);
            if(!GetIsObjectValid(GetMaster(oQuestNPC)))
            {
                if(!GetLocalInt (oPC, "0_Character_Loaded")) SetCommandable(TRUE, oQuestNPC);
                SetUpNPC(oQuestNPC, FALSE);
                // Make them a henchman.
                AddHenchman(oPC, oQuestNPC);
                SetLocalInt(oQuestNPC, "AI_LIMIT_HENCHMAN_MENUS", TRUE);
                // Set the quest tag of NPC, used to match the quest NPC to the PC on the quest.
                SetLocalString(oQuestNPC, "0_QUEST_ID", GetStringArray(sNPCArray, 2, "-"));
                SetLocalInt(oQuestNPC, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_NPC);
            }
        }
        if(SqlStep(sql))  sQuestID = SqlGetString(sql, 0);
        else sQuestID = "";
    }
}
int GetQuestPointerFromDataBase(object oPC, string sQuestName, int nQuestType = 0)
{
    int nPointer;
    string s2daQuestName, sQuestColumn;
    // Get the column from the quest_list.2da based on quest type.
    if(nQuestType == STORY_QUESTS) sQuestColumn = "Story_Quest_Name";
    else if(nQuestType == SIDE_QUESTS) sQuestColumn = "Side_Quest_Name";
    else if(nQuestType == LOCATION_QUESTS) sQuestColumn = "Loc_Quest_Name";
    else return 0;
    // Check the pointer for this quest from the database.
    nPointer = GetObjectDatabaseInt(oPC, QUEST_TABLE, "questpointer", sQuestName);
    Debug("0i_quest", "981", "oPC: " + GetName(oPC) + " nPointer: " + IntToString(nPointer));
    // Check to see if this quest is just starting.
    if(nPointer == 0)
    {
        // Search all quests in the quest_list.2da
        nPointer = 1;
        while(nPointer < 50)
        {
            // Get the String Reference.
            s2daQuestName = Get2DAString("quest_list", sQuestColumn, nPointer);
            if(s2daQuestName == sQuestName) return nPointer;
            nPointer++;
        }
        // We looped out! There is no quest with this name.
        if(sQuestName != "Treasure Map") SetModuleError("QUEST", "0i_quest", "966", sQuestName + " is not a proper quest!");
        return -2;
    }
    return nPointer;
}
string GetQuestIDByQuestName(object oPC, string sQuestName)
{
    string sQuestArray, sDBQuestName;
    string sQuery = "SELECT quest, tag FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql))  sQuestArray = SqlGetString(sql, 0);
    while(sQuestArray != "")
    {
        // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-
        // Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-)
        sDBQuestName = GetStringArray(sQuestArray, 0, "-");
        //Debug("0i_quest", "957", "sQuestName: " + sQuestName + " sDBQuestName: " + sDBQuestName);
        if(sQuestName == sDBQuestName)
        {
            return SqlGetString(sql, 1);
        }
        if(SqlStep(sql)) sQuestArray = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestIDByNPC(object oNPC, object oPC, string sNPCVariable)
{
    string sNPCName = StripColorCodes(GetName(oNPC));
    string sNPCID = GetLocalString(oNPC, "0_QUEST_ID");
    string sNPCArray, sDBNPCName, sDBID;
    string sQuery = "SELECT tag, " + sNPCVariable + " FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
    while(sDBID != "")
    {
        // -Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-
        // Faction-Waypoint spawn-Items-SideQuest-
        sNPCArray = SqlGetString(sql, 1);
        sDBNPCName = GetStringArray(sNPCArray, 0, "-");
        //Debug("0i_quest", "635", "sNPCArray: " + sNPCArray + " sNPCName: " + sNPCName + " sDBNPCName: " + sDBNPCName +
        //      " sNPCID: " + sNPCID + " sDBID: " + sDBID);
        if(sNPCName == sDBNPCName && (sNPCID == sDBID || GetStringLeft(sDBID, 6) == "UNIQUE"))
        {
            return sDBID;
        }
        if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestIDByAreaTag(object oArea, object oPC, string sAreaVariable)
{
    string sDBID, sAreaArray, sDBAreaTag, sAreaTag = GetTag(oArea);
    string sQuery = "SELECT tag, " + sAreaVariable + " FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql))  sDBID = SqlGetString(sql, 0);
    while(sDBID != "")
    {
        // 0_Q_AREA array -AreaName-AreaTag-
        sAreaArray = SqlGetString(sql, 1);
        sDBAreaTag = GetStringArray(sAreaArray, 1, "-");
        if(sAreaTag == sDBAreaTag)
        {
            return sDBID;
        }
        if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestIDByItem(object oItem, object oPC)
{
    string sItemArray, sItemDBName, sDBID;
    string sItemQuestID = GetLocalString(oItem, "0_QUEST_ID");
    string sQuery = "SELECT tag, item FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql))  sDBID = SqlGetString(sql, 0);
    while(sDBID != "")
    {
        // 0_Q_ITEM array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
        sItemArray = SqlGetString(sql, 1);
        if(sItemQuestID == sDBID)
        {
            return sDBID;
        }
        if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestIDByPlaceable(object oPlaceable, object oPC)
{
    string sPlaceableArray, sQuestDBResRef, sDBID;
    string sPlaceableResRef = GetResRef(oPlaceable);
    string sPlaceableID = GetLocalString(oPlaceable, "0_QUEST_ID");
    string sQuery = "SELECT tag, placeable FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
    while(sDBID != "")
    {
        // 0_Q_PLACEABLE array -Name-ResRef-ID-WPspawn
        sPlaceableArray = SqlGetString(sql, 1);
        sQuestDBResRef = GetStringArray(sPlaceableArray, 1, "-");
        //Debug("0i_quest", "1106", "sPlaceableArray: " + sPlaceableArray + " sPlaceableResRef: " + sPlaceableResRef +
        //      " sQuestDBResRef: " + sQuestDBResRef + " sPlaceableID: " + sPlaceableID + " sDBID: " + sDBID);
        if(sPlaceableResRef == sQuestDBResRef && sPlaceableID == sDBID)
        {
            return sDBID;
        }
        if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestIDByCreature(object oCreature, object oPC)
{
    int i = 0;
    string sCreatureArray, sQuestDBName, sDBID;
    string sCreatureName = StripColorCodes(GetName(oCreature));
    string sCreatureID = GetLocalString(oCreature, "0_QUEST_ID");
    string sQuery = "SELECT tag, creature FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", GetName(oPC, TRUE));
    if(SqlStep(sql))  sDBID = SqlGetString(sql, 0);
    while(sDBID != "")
    {
        // 0_Q_CREATURE array -Name-ResRef-ID-Number-WPspawn-Size-RacialType-
        sCreatureArray = SqlGetString(sql, 1);
        sQuestDBName = GetStringArray(sCreatureArray, 0, "-");
        if(sCreatureName == sQuestDBName &&(sCreatureID == sDBID || GetStringLeft(sDBID, 6) == "UNIQUE"))
        {
            return sDBID;
        }
        if(SqlStep(sql)) sDBID = SqlGetString(sql, 0);
        else return "";
    }
    return "";
}
string GetQuestData(string sData, int iPosition)
{
   int iCount = iPosition, iStringLength = GetStringLength(sData);
   string sChar;
   // Search the string.
   while(iCount < iStringLength)
   {
      sChar = GetSubString(sData, iCount, 1);
      // Look for the mark.
      if(sChar == "]")
      {
            // Now pull it and return.
            sData = GetSubString(sData, iPosition, iCount - iPosition);
            return sData;
      }
      iCount ++;
   }
   // Did not find it so return error.
   return "";
}
string ParseQuestTextByPaper(string sText, object oPaper, object oPC)
{
    string sReplace, sArray;
    // Parse the description into a conversation quest.
    // Check for [START:NAME].
    // 0_Q_START array -StartName-StartTag-TownArea-EndName-EndTag-End WPspawn-Leave method-NPC Name-NPC ResRef-
    if(FindSubString(sText, "[START:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_START");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[START:NAME]", sReplace);
    }
    // Check for [FINISH:NAME].
    if(FindSubString(sText, "[FINISH:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_FINISH");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[FINISH:NAME]", sReplace);
    }
    // Check for [AREA:NAME].
    // 0_Q_AREA array -Name-Tag-
    if(FindSubString(sText, "[AREA:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_AREA");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_RED);
        sText = StringReplaceText(sText, "[AREA:NAME]", sReplace);
    }
    // Check for [GIVER:NAME].
    // 0_Q_GIVER array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-SideQuest-.
    if (FindSubString(sText, "[GIVER:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_GIVER");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[GIVER:NAME]", sReplace);
    }
    // 0_Q_NPC array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetLocalString(oPaper, "0_Q_NPC");
    if(sArray != "")
    {
        // Check for [NPC:NAME].
        if(FindSubString(sText, "[NPC:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [NPC:HIM/HER].
        if(FindSubString (sText, "[NPC:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[NPC:HIM/HER]", sReplace);
        }
        // Check for [NPC:HIS/HER].
        if(FindSubString(sText, "[NPC:HIS/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "his";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[NPC:HIS/HER]", sReplace);
        }
        // Check for [NPC:HE/SHE].
        if(FindSubString(sText, "[NPC:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[NPC:HE/SHE]", sReplace);
        }
        // Check for [NPC:MAN/WOMAN].
        if(FindSubString(sText, "[NPC:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[NPC:MAN/WOMAN]", sReplace);
        }
        // Check for [NPC:SON/DAUGHTER].
        if(FindSubString(sText, "[NPC:SON/DAUGHTER]") >= 0)
        {
            if(sGender == "0") sReplace = "son";
            else sReplace = "daughter";
            sText = StringReplaceText(sText, "[NPC:SON/DAUGHTER]", sReplace);
        }
        // Check for [NPC:RACE].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[NPC:RACE]") >= 0)
        {
            sReplace = GetStringArray(sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:RACE]", sReplace);
        }
        // Check for [NPC:CLASS].
        if (FindSubString (sText, "[NPC:CLASS]") >= 0)
        {
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:CLASS]", sReplace);
        }
    }
    // 0_Q_VILLAIN array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetLocalString(oPaper, "0_Q_VILLAIN");
    if(sArray != "")
    {
        // Check for [VILLAIN:NAME].
        if(FindSubString(sText, "[VILLAIN:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[VILLAIN:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [VILLAIN:HIS/HER].
        if(FindSubString(sText, "[VILLAIN:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[VILLAIN:HIM/HER]", sReplace);
        }
        // Check for [VILLAIN:HE/SHE].
        if(FindSubString(sText, "[VILLAIN:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[VILLAIN:HE/SHE]", sReplace);
        }
        // Check for [VILLAIN:MAN/WOMAN].
        if(FindSubString (sText, "[VILLAIN:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[VILLAIN:MAN/WOMAN]", sReplace);
        }
        // Check for [VILLAIN:RACE].
        // **** Needs to be worked on.
        if (FindSubString (sText, "[VILLAIN:RACE]") >= 0)
        {
            sReplace = GetStringArray (sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText (sReplace, COLOR_RED);
            sText = StringReplaceText (sText, "[VILLAIN:RACE]", sReplace);
        }
        // Check for [VILLAIN:CLASS].
        if(FindSubString(sText, "[VILLAIN:CLASS]") >= 0)
        {
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText (sReplace, COLOR_RED);
            sText = StringReplaceText (sText, "[VILLAIN:CLASS]", sReplace);
        }
    }
    // 0_Q_CREATURE array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetLocalString (oPaper, "0_Q_CREATURES");
    if(sArray != "")
    {
        string sCreatureName = GetStringArray(sArray, 0, "-");
        // Check for [CREATURE:NAMES].
        if(FindSubString(sText, "[CREATURE:NAMES]") >= 0)
        {
            sReplace = sCreatureName + "s";
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[CREATURE:NAMES]", sReplace);
        }
        // Check for [CREATURE:NAME].
        if(FindSubString(sText, "[CREATURE:NAME]") >= 0)
        {
            sReplace = sCreatureName;
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[CREATURE:NAME]", sReplace);
        }
    }
    // Followers array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetLocalString(oPaper, "0_Q_FOLLOWERS");
    if(sArray != "")
    {
        string sFollowerName = GetStringArray(sArray, 0, "-");
        // Check for [FOLLOWERS:NAMES].
        if(FindSubString(sText, "[FOLLOWERS:NAMES]") >= 0)
        {
            sReplace = sFollowerName + "s";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FOLLOWERS:NAMES]", sReplace);
        }
        // Check for [FOLLOWERS:NAME].
        if(FindSubString(sText, "[FOLLOWERS:NAME]") >= 0)
        {
            sReplace = sFollowerName;
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FOLLOWERS:NAME]", sReplace);
        }
    }
    // 0_Q_CREATURE array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetLocalString(oPaper, "0_Q_ENEMIES");
    if(sArray != "")
    {
        string sEnemyName = GetStringArray(sArray, 0, "-");
        // Check for [ENEMIES:NAMES].
        if(FindSubString(sText, "[ENEMIES:NAMES]") >= 0)
        {
            sReplace = sEnemyName + "s";
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[ENEMIES:NAMES]", sReplace);
        }
        // Check for [ENEMIES:NAME].
        if(FindSubString(sText, "[ENEMIES:NAME]") >= 0)
        {
            sReplace = sEnemyName;
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[ENEMIES:NAME]", sReplace);
        }
    }
    string sPrefix, sSuffix;
    // 0_Q_ITEM array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
    sArray = GetLocalString(oPaper, "0_Q_ITEM");
    if(sArray != "")
    {
        sReplace = GetStringArray(sArray, 0, "-");
        // Check for [ITEM:NAME].
        if(FindSubString(sText, "[ITEM:NAME]") >= 0)
        {
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[ITEM:NAME]", sReplace);
        }
        // Check for [ITEM:REALNAME].
        // 0_Q_ITEM array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
        if(FindSubString(sText, "[ITEM:REALNAME]") >= 0)
        {
            sText = StringReplaceText(sText, "[ITEM:NAME]", sReplace);
        }
        // Check for [ITEM:BASENAME].
        if(FindSubString(sText, "[ITEM:BASENAME]") >= 0)
        {
            int nBaseItem = StringToInt(GetStringArray (sArray, 2, "-"));
            sPrefix = "";
            sSuffix = "";
            switch(nBaseItem)
            {
                case 20 : // Arrows
                case 25 : // Bolts
                    sPrefix = "quiver of ";
                    sSuffix = "s";
                break;
                case 26 : // boots
                case 36 : // gloves
                case 78 : // bracers
                    sPrefix = "pair of ";
                    //sSuffix = "s";
                break;
                case 27 : // bullets
                case 59 : // shurikens
                    sPrefix = "bag of ";
                    sSuffix = "s";
                break;
                case 31 : // darts
                case 63 : // throwing axes
                    sPrefix = "bunch of ";
                    sSuffix = "s";
                break;
            }
            sReplace = sPrefix + GetStringArray(sArray, 1, "-") + sSuffix;
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[ITEM:BASENAME]", sReplace);
        }
    }
    // 0_Giveitem array -Name-BaseName-BaseItemType-ResRef-Tag-Container tag-
    sArray = GetLocalString(oPaper, "0_Q_GIVEITEM");
    if(sArray != "")
    {
        // Check for [GIVEITEM:NAME].
        if(FindSubString(sText, "[GIVEITEM:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[GIVEITEM:NAME]", sReplace);
        }
        // Check for [GIVEITEM:BASENAME].
        if(FindSubString(sText, "[GIVEITEM:BASENAME]") >= 0)
        {
            sArray = GetLocalString(oPaper, "0_Q_GIVEITEM");
            int nBaseItem = StringToInt(GetStringArray (sArray, 2, "-"));
            sPrefix = "";
            sSuffix = "";
            switch (nBaseItem)
            {
                case 20 : // Arrows
                case 25 : // Bolts
                    sPrefix = "quiver of ";
                    sSuffix = "s";
                break;
                case 26 : // boots
                case 36 : // gloves
                case 78 : // bracers
                    sPrefix = "pair of ";
                    //sSuffix = "s";
                break;
                case 27 : // bullets
                case 59 : // shurikens
                    sPrefix = "bag of ";
                    sSuffix = "s";
                break;
                case 31 : // darts
                case 63 : // throwing axes
                    sPrefix = "bunch of ";
                    sSuffix = "s";
                break;
            }
            sReplace = sPrefix + GetStringArray(sArray, 1, "-") + sSuffix;
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[GIVEITEM:BASENAME]", sReplace);
        }
    }
    // Check for [PLACEABLE:NAME].
    // 0_Q_PLACEABLE array -Name-ResRef-Tag-WPspawn
    if(FindSubString(sText, "[PLACEABLE:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_PLACEABLE");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_BLUE);
        sText = StringReplaceText(sText, "[PLACEABLE:NAME]", sReplace);
    }
    // Check for [FPLACEABLE:NAME].
    // 0_Q_FPLACEABLE array -Name-ResRef-Tag-WPspawn
    if (FindSubString (sText, "[FPLACEABLE:NAME]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_FPLACEABLE");
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_BLUE);
        sText = StringReplaceText(sText, "[FPLACEABLE:NAME]", sReplace);
    }
    // Check for [GOLD]
    // 0_Q_REWARDS array -Reputation-XP-Gold-KEEP-
    if(FindSubString(sText, "[GOLD]") >= 0)
    {
        sArray = GetLocalString(oPaper, "0_Q_REWARDS");
        int nGold = StringToInt(GetStringArray (sArray, 3, "-"));
        sArray = GetLocalString(oPaper, "0_Q_QUEST");
        int nLevel = StringToInt(GetStringArray (sArray, 1, "-"));
        sReplace = IntToString(nGold * nLevel);
        sReplace = AddColorToText(sReplace, COLOR_GOLD);
        sText = StringReplaceText(sText, "[GOLD]", sReplace);
    }
    // 0_Q_FINISHER array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetLocalString (oPaper, "0_Q_FINISHER");
    if(sArray != "")
    {
        // Check for [FINISHER:NAME].
        if(FindSubString(sText, "[FINISHER:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [FINISHER:HIS/HER].
        if(FindSubString (sText, "[FINISHER:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[FINISHER:HIM/HER]", sReplace);
        }
        // Check for [FINISHER:HE/SHE].
        if(FindSubString(sText, "[FINISHER:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[FINISHER:HE/SHE]", sReplace);
        }
        // Check for [FINISHER:MAN/WOMAN].
        if(FindSubString (sText, "[FINISHER:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[FINISHER:MAN/WOMAN]", sReplace);
        }
        // Check for [FINISHER:RACE].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[FINISHER:RACE]") >= 0)
        {
            sReplace = GetStringArray (sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:RACE]", sReplace);
        }
        // Check for [FINISHER:CLASS].
        if(FindSubString(sText, "[FINISHER:CLASS]") >= 0)
        {
            sArray = GetLocalString(oPaper, "0_Q_FINISHER");
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:CLASS]", sReplace);
        }
    }
    // Check for [PC:NAME].
    if(FindSubString(sText, "[PC:NAME]") >= 0)
    {
        sReplace = GetName(oPC, TRUE);
        sText = StringReplaceText(sText, "[PC:NAME]", sReplace);
    }
    int nStart, nEnd, nLength;
    // Check for colors [GOLD/
    nStart = FindSubString (sText, "[GOLD/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xE2\xAA\x20>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    // Check for colors [YELLOW/
    nStart = FindSubString(sText, "[YELLOW/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\xFF\x20>" + GetSubString(sText, nStart + 8, nEnd - nStart - 8) + "</c>" + sSuffix;
    }
    // Check for colors [RED/
    nStart = FindSubString(sText, "[RED/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\x20\x20>" + GetSubString(sText, nStart + 5, nEnd - nStart - 5) + "</c>" + sSuffix;
    }
    // Check for colors [PURPLE/
    nStart = FindSubString(sText, "[PURPLE/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\x20\xFF>" + GetSubString(sText, nStart + 8, nEnd - nStart - 8) + "</c>" + sSuffix;
    }
    // Check for colors [GREEN/
    nStart = FindSubString(sText, "[GREEN/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\x20\xFF\x20>" + GetSubString(sText, nStart + 7, nEnd - nStart - 7) + "</c>" + sSuffix;
    }
    // Check for colors [BLUE/
    nStart = FindSubString (sText, "[BLUE/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\x20\x55\xFF>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    // Check for colors [GRAY/
    nStart = FindSubString(sText, "[GRAY/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xAA\xAA\xAA>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    return sText;
}
string ParseQuestTextByDatabase(string sText, string sQuestID, object oPC)
{
    string sReplace, sArray;
    // Parse the description into a conversation quest.
    // Check for [START:NAME].
    // 0_Q_START array -StartName-StartTag-TownArea-EndName-EndTag-End WPspawn-Leave method-NPC Name-NPC ResRef-
    if(FindSubString(sText, "[START:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "start", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[START:NAME]", sReplace);
    }
    // Check for [FINISH:NAME].
    if(FindSubString(sText, "[FINISH:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "finish", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[FINISH:NAME]", sReplace);
    }
    // Check for [AREA:NAME].
    // 0_Q_AREA array -Name-Tag-
    if(FindSubString(sText, "[AREA:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "area", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_RED);
        sText = StringReplaceText(sText, "[AREA:NAME]", sReplace);
    }
    // Check for [GIVER:NAME].
    // 0_Q_GIVER array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-SideQuest-.
    if(FindSubString(sText, "[GIVER:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "giver", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_GREEN);
        sText = StringReplaceText(sText, "[GIVER:NAME]", sReplace);
    }
    // 0_Q_NPC array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "npc", sQuestID);
    if(sArray != "")
    {
        // Check for [NPC:NAME].
        if(FindSubString(sText, "[NPC:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [NPC:HIM/HER].
        if(FindSubString(sText, "[NPC:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[NPC:HIM/HER]", sReplace);
        }
        // Check for [NPC:HIS/HER].
        if(FindSubString(sText, "[NPC:HIS/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "his";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[NPC:HIS/HER]", sReplace);
        }
        // Check for [NPC:HE/SHE].
        if(FindSubString(sText, "[NPC:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[NPC:HE/SHE]", sReplace);
        }
        // Check for [NPC:MAN/WOMAN].
        if(FindSubString(sText, "[NPC:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[NPC:MAN/WOMAN]", sReplace);
        }
        // Check for [NPC:SON/DAUGHTER].
        if(FindSubString(sText, "[NPC:SON/DAUGHTER]") >= 0)
        {
            if(sGender == "0") sReplace = "son";
            else sReplace = "daughter";
            sText = StringReplaceText(sText, "[NPC:SON/DAUGHTER]", sReplace);
        }
        // Check for [NPC:RACE].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[NPC:RACE]") >= 0)
        {
            sReplace = GetStringArray(sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:RACE]", sReplace);
        }
        // Check for [NPC:CLASS].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[NPC:CLASS]") >= 0)
        {
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[NPC:CLASS]", sReplace);
        }
    }
    // 0_Q_VILLAIN array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "villain", sQuestID);
    if(sArray != "")
    {
        // Check for [VILLAIN:NAME].
        if(FindSubString(sText, "[VILLAIN:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[VILLAIN:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [VILLAIN:HIS/HER].
        if(FindSubString(sText, "[VILLAIN:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[VILLAIN:HIM/HER]", sReplace);
        }
        // Check for [VILLAIN:HE/SHE].
        if(FindSubString(sText, "[VILLAIN:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[VILLAIN:HE/SHE]", sReplace);
        }
        // Check for [VILLAIN:MAN/WOMAN].
        if(FindSubString(sText, "[VILLAIN:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[VILLAIN:MAN/WOMAN]", sReplace);
        }
        // Check for [VILLAIN:RACE].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[VILLAIN:RACE]") >= 0)
        {
            sReplace = GetStringArray(sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[VILLAIN:RACE]", sReplace);
        }
        // Check for [VILLAIN:CLASS].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[VILLAIN:CLASS]") >= 0)
        {
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[VILLAIN:CLASS]", sReplace);
        }
    }
    // 0_Q_CREATURE array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "creatures", sQuestID);
    if(sArray != "")
    {
        string sCreatureName = GetStringArray(sArray, 0, "-");
        // Check for [CREATURE:NAMES].
        if(FindSubString(sText, "[CREATURE:NAMES]") >= 0)
        {
            sReplace = sCreatureName + "s";
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[CREATURE:NAMES]", sReplace);
        }
        // Check for [CREATURE:NAME].
        if(FindSubString(sText, "[CREATURE:NAME]") >= 0)
        {
            sReplace = sCreatureName;
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[CREATURE:NAME]", sReplace);
        }
    }
    // Followers array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "followers", sQuestID);
    if(sArray != "")
    {
        string sFollowerName = GetStringArray(sArray, 0, "-");
        // Check for [FOLLOWERS:NAMES].
        if(FindSubString(sText, "[FOLLOWERS:NAMES]") >= 0)
        {
            sReplace = sFollowerName + "s";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FOLLOWERS:NAMES]", sReplace);
        }
        // Check for [FOLLOWERS:NAME].
        if(FindSubString(sText, "[FOLLOWERS:NAME]") >= 0)
        {
            sReplace = sFollowerName;
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FOLLOWERS:NAME]", sReplace);
        }
    }
    // 0_Q_CREATURE array -Name-ResRef-Tag-Number-WPspawn-Size-RacialType-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "enemies", sQuestID);
    if(sArray != "")
    {
        string sEnemyName = GetStringArray(sArray, 0, "-");
        // Check for [ENEMIES:NAMES].
        if(FindSubString(sText, "[ENEMIES:NAMES]") >= 0)
        {
            sReplace = sEnemyName + "s";
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[ENEMIES:NAMES]", sReplace);
        }
        // Check for [ENEMIES:NAME].
        if(FindSubString(sText, "[ENEMIES:NAME]") >= 0)
        {
            sReplace = sEnemyName;
            sReplace = AddColorToText(sReplace, COLOR_RED);
            sText = StringReplaceText(sText, "[ENEMIES:NAME]", sReplace);
        }
    }
    string sPrefix, sSuffix;
    // 0_Q_ITEM array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "item", sQuestID);
    if(sArray != "")
    {
        sReplace = GetStringArray(sArray, 0, "-");
        // Check for [ITEM:NAME].
        if(FindSubString(sText, "[ITEM:NAME]") >= 0)
        {
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[ITEM:NAME]", sReplace);
        }
        // Check for [ITEM:REALNAME].
        // 0_Q_ITEM array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
        if(FindSubString(sText, "[ITEM:REALNAME]") >= 0)
        {
            sText = StringReplaceText(sText, "[ITEM:REALNAME]", sReplace);
        }
        // Check for [ITEM:BASENAME].
        if(FindSubString(sText, "[ITEM:BASENAME]") >= 0)
        {
            int nBaseItem = StringToInt(GetStringArray(sArray, 2, "-"));
            sPrefix = "";
            sSuffix = "";
            switch(nBaseItem)
            {
                case 20 : // Arrows
                case 25 : // Bolts
                    sPrefix = "quiver of ";
                    sSuffix = "s";
                break;
                case 26 : // boots
                case 36 : // gloves
                case 78 : // bracers
                    sPrefix = "pair of ";
                    //sSuffix = "s";
                break;
                case 27 : // bullets
                case 59 : // shurikens
                    sPrefix = "bag of ";
                    sSuffix = "s";
                break;
                case 31 : // darts
                case 63 : // throwing axes
                    sPrefix = "bunch of ";
                    sSuffix = "s";
                break;
            }
            sReplace = sPrefix + GetStringArray(sArray, 1, "-") + sSuffix;
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[ITEM:BASENAME]", sReplace);
        }
    }
    // 0_Giveitem array -Name-BaseName-BaseItemType-ResRef-Tag-Container tag-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "giveitem", sQuestID);
    if(sArray != "")
    {
        // Check for [GIVEITEM:NAME].
        if(FindSubString(sText, "[GIVEITEM:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[GIVEITEM:NAME]", sReplace);
        }
        // Check for [GIVEITEM:BASENAME].
        if(FindSubString(sText, "[GIVEITEM:BASENAME]") >= 0)
        {
            int nBaseItem = StringToInt(GetStringArray(sArray, 2, "-"));
            sPrefix = "";
            sSuffix = "";
            switch(nBaseItem)
            {
                case 20 : // Arrows
                case 25 : // Bolts
                    sPrefix = "quiver of ";
                    sSuffix = "s";
                break;
                case 26 : // boots
                case 36 : // gloves
                case 78 : // bracers
                    sPrefix = "pair of ";
                    //sSuffix = "s";
                break;
                case 27 : // bullets
                case 59 : // shurikens
                    sPrefix = "bag of ";
                    sSuffix = "s";
                break;
                case 31 : // darts
                case 63 : // throwing axes
                    sPrefix = "bunch of ";
                    sSuffix = "s";
                break;
            }
            sReplace = sPrefix + GetStringArray(sArray, 1, "-") + sSuffix;
            sReplace = AddColorToText(sReplace, COLOR_YELLOW);
            sText = StringReplaceText(sText, "[GIVEITEM:BASENAME]", sReplace);
        }
    }
    // Check for [PLACEABLE:NAME].
    // 0_Q_PLACEABLE array -Name-ResRef-Tag-WPspawn
    if(FindSubString(sText, "[PLACEABLE:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "placeable", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_BLUE);
        sText = StringReplaceText(sText, "[PLACEABLE:NAME]", sReplace);
    }
    // Check for [FPLACEABLE:NAME].
    // 0_Q_FPLACEABLE array -Name-ResRef-Tag-WPspawn
    if(FindSubString(sText, "[FPLACEABLE:NAME]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "fplaceable", sQuestID);
        sReplace = GetStringArray(sArray, 0, "-");
        sReplace = AddColorToText(sReplace, COLOR_BLUE);
        sText = StringReplaceText(sText, "[FPLACEABLE:NAME]", sReplace);
    }
    // Check for [GOLD]
    // 0_Q_REWARDS array -Reputation-XP-Gold-KEEP-
    if(FindSubString(sText, "[GOLD]") >= 0)
    {
        sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "rewards", sQuestID);
        int nGold = StringToInt(GetStringArray(sArray, 3, "-"));
        sArray = GetObjectDatabaseString(oPC, QUEST_TABLE, "quest", sQuestID);
        int nLevel = StringToInt(GetStringArray(sArray, 1, "-"));
        sReplace = IntToString(nGold * nLevel);
        sReplace = AddColorToText(sReplace, COLOR_GOLD);
        sText = StringReplaceText(sText, "[GOLD]", sReplace);
    }
    // 0_Q_FINISHER array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-
    sArray = GetServerDatabaseString(oPC, QUEST_TABLE, "finisher", sQuestID);
    if(sArray != "")
    {
        // Check for [FINISHER:NAME].
        if(FindSubString(sText, "[FINISHER:NAME]") >= 0)
        {
            sReplace = GetStringArray(sArray, 0, "-");
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:NAME]", sReplace);
        }
        string sGender = GetStringArray(sArray, 3, "-");
        // Check for [FINISHER:HIS/HER].
        if(FindSubString(sText, "[FINISHER:HIM/HER]") >= 0)
        {
            if(sGender == "0") sReplace = "him";
            else sReplace = "her";
            sText = StringReplaceText(sText, "[FINISHER:HIM/HER]", sReplace);
        }
        // Check for [FINISHER:HE/SHE].
        if(FindSubString(sText, "[FINISHER:HE/SHE]") >= 0)
        {
            if(sGender == "0") sReplace = "he";
            else sReplace = "she";
            sText = StringReplaceText(sText, "[FINISHER:HE/SHE]", sReplace);
        }
        // Check for [FINISHER:MAN/WOMAN].
        if(FindSubString(sText, "[FINISHER:MAN/WOMAN]") >= 0)
        {
            if(sGender == "0") sReplace = "man";
            else sReplace = "woman";
            sText = StringReplaceText(sText, "[FINISHER:MAN/WOMAN]", sReplace);
        }
        // Check for [FINISHER:RACE].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[FINISHER:RACE]") >= 0)
        {
            sReplace = GetStringArray(sArray, 4, "-");
            if(sReplace == "0") sReplace = "dwarf";
            else if(sReplace == "1") sReplace = "elf";
            else if(sReplace == "2") sReplace = "drow";
            else if(sReplace == "3") sReplace = "gnome";
            else if(sReplace == "4") sReplace = "halfling";
            else if(sReplace == "5") sReplace = "half elf";
            else if(sReplace == "6") sReplace = "half orc";
            else if(sReplace == "7") sReplace = "human";
            else if(sReplace == "8") sReplace = "aasimar";
            else if(sReplace == "9") sReplace = "tiefling";
            else if(sReplace == "10") sReplace = "air genasi";
            else if(sReplace == "11") sReplace = "earth genasi";
            else if(sReplace == "12") sReplace = "fire genasi";
            else if(sReplace == "13") sReplace = "water genasi";
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:RACE]", sReplace);
        }
        // Check for [FINISHER:CLASS].
        // **** Needs to be worked on.
        if(FindSubString(sText, "[FINISHER:CLASS]") >= 0)
        {
            sReplace = GetStringArray(sArray, 5, "-");
            sReplace = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", StringToInt(sReplace))));
            sReplace = AddColorToText(sReplace, COLOR_GREEN);
            sText = StringReplaceText(sText, "[FINISHER:CLASS]", sReplace);
        }
    }
    // Check for [PC:NAME].
    if(FindSubString(sText, "[PC:NAME]") >= 0)
    {
        sReplace = GetName(oPC, TRUE);
        sText = StringReplaceText(sText, "[PC:NAME]", sReplace);
    }
    int nStart, nEnd, nLength;
    // Check for colors [GOLD/
    nStart = FindSubString(sText, "[GOLD/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xE2\xAA\x20>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    // Check for colors [YELLOW/
    nStart = FindSubString(sText, "[YELLOW/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\xFF\x20>" + GetSubString(sText, nStart + 8, nEnd - nStart - 8) + "</c>" + sSuffix;
    }
    // Check for colors [RED/
    nStart = FindSubString(sText, "[RED/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\x20\x20>" + GetSubString(sText, nStart + 5, nEnd - nStart - 5) + "</c>" + sSuffix;
    }
    // Check for colors [PURPLE/
    nStart = FindSubString(sText, "[PURPLE/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xFF\x20\xFF>" + GetSubString(sText, nStart + 8, nEnd - nStart - 8) + "</c>" + sSuffix;
    }
    // Check for colors [GREEN/
    nStart = FindSubString(sText, "[GREEN/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        //Debug("0i_quest", "1536", " iStart: " + IntToString(nStart) + " nEnd: " + IntToString(nEnd) +
        //       " length: " + IntToString(GetStringLength(sText) - nEnd - 1) + " sPrefix: " + sPrefix + " sSuffix: " + sSuffix);
        sText = sPrefix + "<c\x20\xFF\x20>" + GetSubString(sText, nStart + 7, nEnd - nStart - 7) + "</c>" + sSuffix;
    }
    // Check for colors [BLUE/
    nStart = FindSubString(sText, "[BLUE/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\x20\x55\xFF>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    // Check for colors [GRAY/
    nStart = FindSubString(sText, "[GRAY/");
    if(nStart >= 0)
    {
        nEnd = FindSubString(sText, "]", nStart);
        sPrefix = GetStringLeft(sText, nStart);
        sSuffix = GetStringRight(sText, GetStringLength(sText) - nEnd - 1);
        sText = sPrefix + "<c\xAA\xAA\xAA>" + GetSubString(sText, nStart + 6, nEnd - nStart - 6) + "</c>" + sSuffix;
    }
    return sText;
}
void CheckPCQuestIDsByArea(object oPC, object oArea)
{
    // Check Start, Area, and Finish quest area.
    // Save to Area array.
    int nQuestPopulated, bQuestInArea;
    string sPlot, sAreaArray, sText, sNPCQuestID;
    string sPCName = GetName(oPC, TRUE);
    string sAreaTag = GetTag(oArea);
    string sStartDBTag, sAreaDBTag, sFinishDBTag, sQuestID;
    object oNPC;
    string sQuery = "SELECT plot, start, area, finish, npc, tag FROM QuestTable WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign(SERVER_DATABASE, sQuery);
    SqlBindString(sql, "@name", sPCName);
    if(SqlStep(sql))  sPlot = SqlGetString(sql, 0);
    while(sPlot != "")
    {
        sQuestID = SqlGetString(sql, 5);
        //Debug("0i_quest", "1914", "sPlot: " + sPlot + " sQuestID: " + sQuestID + " sAreaTag: " + sAreaTag);
        sFinishDBTag = GetStringArray(SqlGetString(sql, 3), 1, "-");
        //Debug("0i_quest", "1915", " sFinishDBTag: " + sFinishDBTag);
        if(sFinishDBTag == sAreaTag)
        {
            bQuestInArea = TRUE;
            // Plot 6 is Escort NPC to FINISH location they should say something.
            if(sPlot == "6")
            {
                oNPC = CheckForNPC(oPC, oArea, SqlGetString(sql, 4));
                if(oNPC != OBJECT_INVALID)
                {
                    sText = "We are here!";
                    int nRoll = d6();
                    if(nRoll == 1) sText = "Yes, this is it! We are finally here.";
                    else if(nRoll == 2) sText = "Finally we have made it.";
                    else if(nRoll == 3) sText = "This is the location we have been looking for!";
                    else if(nRoll == 4) sText = "Our travels together are over, we are here.";
                    else if(nRoll == 5) sText = "This is the location!";
                    DelayCommand(12.0f, FloatingTextStringOnCreature(sText, oNPC));
                }
            }
            if(!CheckandSaveAreaQuestArray(sPCName, oArea, sQuestID)) PopulateFinishQuestArea(oPC, oArea, sQuestID);
        }
        else // The quest area. Were all the action happens!
        {
            sAreaDBTag = GetStringArray(SqlGetString(sql, 2), 1, "-");
            //Debug("0i_quest", "1940", " sAreaDBTag: " + sAreaDBTag);
            if(sAreaDBTag == sAreaTag)
            {
                bQuestInArea = TRUE;
                // Check to see if the quest has already been populated.
                nQuestPopulated = CheckandSaveAreaQuestArray(sPCName, oArea, sQuestID);
                //Debug("0i_quest", "1947", "nQuestPopulated: " + IntToString(nQuestPopulated));
                // 2 = This quest area is populated and PC has already been here so exit.
                if(nQuestPopulated == 2) return;
                // 1 = The area was set to this QuestID, but this player has not
                // loaded into this area another player did, so lets build any
                // items this player should find.
                else if(nQuestPopulated == 1)
                {
                    PopulateAreaQuestItem(oPC, oArea, GetQuestWaypoint(oArea, "", ""), sQuestID);
                }
                else PopulateAreaQuestArea(oPC, oArea, sQuestID);
            }
            else
            {
                //Debug("0i_quest", "1959", " sStartDBTag: " + sStartDBTag);
                sStartDBTag = GetStringArray(SqlGetString(sql, 1), 1, "-");
                if(sStartDBTag == sAreaTag)
                {
                    bQuestInArea = TRUE;
                    if(!CheckandSaveAreaQuestArray(sPCName, oArea, sQuestID))
                    {
                        PopulateStartQuestArea(oPC, oArea, sQuestID);
                    }
                }
            }
        }
        if(SqlStep(sql)) sPlot = SqlGetString(sql, 0);
        else sPlot = "";
    }
    // If its not a FINISH, AREA, or START location then check for new quest NPC(Giver).
    if(!bQuestInArea)
    {
        // Get the encounter waypoint.
        object oWaypoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        // This defines areas as Civilized. Only Civilized areas can give quests.
        if(GetLocalInt(oWaypoint, "0_No_Difficulty"))
        {
            // Is this is a Quest area set on the encounter waypoint.
            // This is a variable on the encounter waypoint of an area to let us
            // know we can start quests in this area. "Faerun is not a legal area to
            // start random quests.
            string sTownArea = GetLocalString(oWaypoint, "0_Town_Area");
            if(sTownArea != "" && sTownArea != "Faerun")
            {
                // Taverns have a higher chance to have a quest NPC.
                int nQuestChance = NPC_QUEST_CHANCE;
                object oWP_Area = GetObjectInAreaByTag(oArea, "NW_TAVERN", 1, OBJECT_TYPE_WAYPOINT, TRUE);
                if(oWP_Area != OBJECT_INVALID) nQuestChance = NPC_TAVERN_QUEST_CHANCE;
                // Chance a quest giver will spawn.
                if(d100LuckRoll(oPC) <= 100)//nQuestChance)
                {
                    // Check to see if a random Quest Giver is already in the area.
                    // We do not want to add multiple quest givers!
                    int i = 1;
                    // Search all spawned creatures for a giver.
                    object oCreature = GetObjectInArea(oArea, i, OBJECT_TYPE_CREATURE);
                    while(oCreature != OBJECT_INVALID)
                    {
                        if(CheckNPCHasQuestReady(oPC, oCreature, ""))
                        {
                            // Remove the loops saved index since we are aborting early.
                            DeleteLocalInt(oArea, "0_AreaObject");
                            break;
                        }
                        else oCreature = GetObjectInArea(oArea, ++i, OBJECT_TYPE_CREATURE);
                    }
                    // If a quest giver for this NPC was not found then make one.
                    if(oCreature == OBJECT_INVALID)
                    {
                        // Get a random spawn waypoint in area used.
                        oWaypoint = GetObjectInAreaByTag(oArea, "ip_encounter", d6(), OBJECT_TYPE_WAYPOINT, TRUE);
                        // If this one doesn't exist use the first one instead.
                        if(oWaypoint == OBJECT_INVALID) oWaypoint = GetObjectInAreaByTag(oArea, "ip_encounter", 1, OBJECT_TYPE_WAYPOINT, TRUE);
                        location lLocation = GetLocation(oWaypoint);
                        // Giver Array:(-Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint spawn-Items-Wounded%-)
                        string sGiverArray = "-----------4--1--";
                        // Set level to 1/2 of the PC's level +/- one.
                        int nLevel = GetCharacterLevels(oPC);
                        sGiverArray = GenerateNPCArrayAndSetName(sGiverArray,(nLevel / 2) + d3()-2, oPC);
                        // Create the quest giver.
                        WriteTimestampedLogEntry("0i_quest, 2336, sGiverArray: " + sGiverArray);
                        oCreature = CreateNPC(lLocation, sGiverArray);
                        SetUpNPC(oCreature);
                        SetLocalInt(oCreature, "0_Animation", 1);
                        CheckAnimations(oCreature);
                        // Give them normal equipment.
                        GiveEquipment(oCreature, TRUE);
                        // Equip items.
                        EquipItems(oCreature, TRUE, TRUE);
                        // Let them walk around and act normal.
                        AssignCommand(oCreature, SetSpawnInCondition(SPAWN_IN_AMBIENT_ANIMATIONS));
                        // Make them a side quest giver.
                        SetLocalInt(oCreature, "0_Quest_Type", SIDE_QUESTS);
                        SetName(oCreature, AddColorToText(GetName(oCreature), COLOR_DARK_CYAN));
                    }
                }
            }
        }
    }
}
int CheckandSaveAreaQuestArray(string sPCName, object oArea, string sQuestID)
{
    string sQuestIndex, sAreaQuestIndexID;
    sPCName = RemoveIllegalCharacters(sPCName);
    int nQuestIndex = 1;
    while(nQuestIndex <= 10)
    {
        sQuestIndex = IntToString(nQuestIndex);
        // If the index and Player QuestID are the same then the player has been
        // in the area after the quest was active.
        //Debug("0i_quest", "2054", "AreaQuestArray - 0_QUEST_" + sQuestIndex + "_" + sPCName + ":" +
        //      GetLocalString(oArea, "0_QUEST_" + sQuestIndex + "_" + sPCName));
        if(GetLocalString(oArea, "0_QUEST_" + sQuestIndex + "_" + sPCName) == sQuestID) return 2;
        // If index and Paper QuestID are the same then this quest has already populated this area.
        //Debug("0i_quest", "2057", "AreaQuestArray - 0_QUEST_" + sQuestIndex + ":" +
        //      GetLocalString(oArea, "0_QUEST_" + sQuestIndex));
        sAreaQuestIndexID = GetLocalString(oArea, "0_QUEST_" + sQuestIndex);
        if(sAreaQuestIndexID == sQuestID)
        {
            // Tag the area with the players name so they cannot populate more items.
            SetLocalString(oArea, "0_QUEST_" + sQuestIndex + "_" + sPCName, sQuestID);
            return 1;
        }
        if(sAreaQuestIndexID == "")
        {
            SetLocalString(oArea, "0_QUEST_" + sQuestIndex, sQuestID);
            SetLocalString(oArea, "0_QUEST_" + sQuestIndex + "_" + sPCName, sQuestID);
            return 0;
        }
        nQuestIndex++;
    }
    return 0;
}
int GetIsQuestDone(object oPC, string sQuestID)
{
    // PLOT(Str) Quest Plot:
    //         1 - Destroy Object         5 - Kill creature        9 - Talk to NPC
    //         2 - Deliver item           6 - Deliver creature     10 - Do X special tasks
    //         3 - Retrieve item          7 - Not Used
    //         4 - Retrieve creature      8 - Clear area
    string sPlot;
    string sQueryPlot = "SELECT plot, state, item, npc, finish, quest FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlplot = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryPlot);
    SqlBindString(sqlplot, "@name", GetName(oPC, TRUE));
    SqlBindString(sqlplot, "@tag", sQuestID);
    if(SqlStep(sqlplot)) sPlot = SqlGetString(sqlplot, 0);
    else return FALSE;
    //     Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
    //     1 - Object Destroyed.         6 - Area found.
    //     2 - Villain Killed.           7 -
    //     3 - Creature Killed.          8 - Area Cleared.
    //     4 - Item Picked up.           9 - Escorted NPC is dead.
    //     5 - NPC Picked up.            10 - Finished X number of tasks.
    string sStateArray = SqlGetString(sqlplot, 1);
    // Plot #1: Destory placeable.
    if(sPlot == "1" && GetStringArray(sStateArray, 1, "-") == "1") return TRUE;
    // Plot #2:  Delivering an item and Plot #3: Retrieving an item.
    else if(sPlot == "2" || sPlot == "3")
    {
        // Check the PC to see if they have the item.
        // Search for the item by 0_Quest_ID and name in the inventory.
        // Item Array:(-Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-)
        string sItemArray = SqlGetString(sqlplot, 2);
        string sName = GetStringArray(sItemArray, 0, "-");
        string sID = GetStringArray (sItemArray, 4, "-");
        object oItem = GetFirstItemInInventory(oPC);
        while(oItem != OBJECT_INVALID)
        {
            if(GetLocalString(oItem, "0_QUEST_ID") == sID &&
              (GetName(oItem) == sName || sName == "NORMAL"))
            {
                // Saved so the item can be removed later.
                SetLocalObject(oPC, "0_QUEST_ITEM", oItem);
                return TRUE;
            }
            oItem = GetNextItemInInventory(oPC);
        }
        int iSlot = 0;
        oItem = GetItemInSlot(iSlot, oPC);
        while(iSlot < 18)
        {
            if(GetLocalString(oItem, "0_QUEST_ID") == sID &&
              (GetName(oItem) == sName || sName == "NORMAL"))
            {
                // Saved so the item can be removed later.
                SetLocalObject(oPC, "0_QUEST_ITEM", oItem);
                return TRUE;
            }
            oItem = GetItemInSlot(++iSlot, oPC);
        }
    }
    // Plot #4: Retrieve NPC.
    else if(sPlot == "4" || sPlot == "7")
    {
        // Check to see if the NPC is here.
        location lLocation = GetLocation(oPC);
        // Get the NPC's name and tag.
        // Array:(-Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1
        //         -Align2-Faction-Waypoint spawn-Items-)
        string sNPCArray = SqlGetString(sqlplot, 3);
        string sName = GetStringArray (sNPCArray, 0, "-");
        string sID = GetStringArray (sNPCArray, 2, "-");
        // Search for the NPC in the shape.
        int i;
        object oHenchman;
        object oPlayer = GetFirstPC();
        while(oPlayer != OBJECT_INVALID)
        {
            i = 1;
            oHenchman = GetHenchman(oPlayer, i);
            while(oHenchman != OBJECT_INVALID)
            {
                if(StripColorCodes(GetName(oHenchman)) == sName &&
                sID == GetLocalString(oHenchman, "0_QUEST_ID"))
                {
                    if(GetDistanceBetween(oPC, oHenchman) < XP_PARTY_RADIUS &&
                                           GetArea(oPC) == GetArea(oHenchman)) return TRUE;
                }
                oHenchman = GetHenchman(oPlayer, ++i);
            }
            oPlayer = GetNextPC();
        }
    }
    // Plot #5: Kill villian or creature.
    else if(sPlot == "5")
    {
        // Check to see if they have finished all states. 2 - Kill Villain or 3 - Kill Creatures
        int nVState = StringToInt(GetStringArray(sStateArray, 2, "-"));
        int nCState = StringToInt(GetStringArray(sStateArray, 3, "-"));
        if(nVState == 1) return TRUE;
        else if(nVState > 0 && nCState == 1) return TRUE;
    }
    // Plot #6: Deliver NPC to an finish area.
    else if(sPlot == "6")
    {
        string sTag = GetTag(GetArea(oPC));
        string sFinishArray = SqlGetString(sqlplot, 4);
        string sAreaTag = GetStringArray (sFinishArray, 1, "-");
        // Check to see if the tags match.
        if(sAreaTag == sTag) return TRUE;
    }
    // Plot #7: Deliver NPC to a FINISHER linked with Plot 4.
    // Plot #8: Clear area of villian and creatures.
    else if(sPlot == "8" && GetStringArray(sStateArray, 8, "-") == "1") return TRUE;
    // Plot #9: Just talk to the Finisher.
    else if(sPlot == "9")
    {
        //Debug("0i_quest", "2761", "sPlot: " + sPlot);
        return TRUE;
    }
    // Plot #10: Do X special task.
    else if(sPlot == "10")
    {
        int nState = StringToInt(GetStringArray(sStateArray, 10, "-"));
        // Quest array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Start_Effect-)
        string sQuestArray = SqlGetString(sqlplot, 5);
        int nTasksNeeded = StringToInt(GetStringArray(sQuestArray, 4, "-"));
        if(nState >= nTasksNeeded) return TRUE;
    }
    return FALSE;
}

string CheckIsGiverMoving(object oPC, object oPaper, string sQuestText)
{
    // Only add text if this is a Side Quest.
    // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-)
    string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
    if(StringToInt(GetStringArray(sQuestArray, 5, "-")) == SIDE_QUESTS)
    {
        // Start array:-StartName-StartTag-TownArea-
        string sStartArray = GetLocalString(oPaper, "0_Q_START");
        // Finish array:-StartName-StartTag-
        string sFinishArray = GetLocalString(oPaper, "0_Q_FINISH");
        // If the starting and finish tags are different then the giver is moving.
        if(GetStringArray(sStartArray, 1, "-") != GetStringArray(sFinishArray, 1, "-"))
        {
            string sGiverArray = GetLocalString(oPaper, "0_Q_GIVER");
            string sFinisherArray = GetLocalString(oPaper, "0_Q_FINISHER");
            string sFinisherName = GetStringArray(sFinisherArray, 0, "-");
            if(GetStringArray(sGiverArray, 0, "-") != sFinisherName) return sQuestText;
            int nRoll = d4();
            if(nRoll == 1) sQuestText = sQuestText + " I'll be in [FINISH:NAME] later.";
            else if(nRoll == 2) sQuestText = sQuestText + " Find me in [FINISH:NAME] when you're done.";
            else if(nRoll == 3) sQuestText = sQuestText + " Go see me at [FINISH:NAME] once you are finished.";
            else sQuestText = sQuestText + " If you are helping then meet me in [FINISH:NAME] once completed.";
        }
    }
    return sQuestText;
}
void MakeNPCLeave(object oPC, object oNPC, string sLeaveMethod)
{
    object oArea = GetArea(oPC);
    location lLocation;
    vector vLoc;
    if(IsInConversation(oNPC))
    {
        DelayCommand(3.0f, MakeNPCLeave(oPC, oNPC, sLeaveMethod));
        return;
    }
    int nEffect;
    object oExit;
    // Have them teleport away.
    if(sLeaveMethod == "TELEPORT")
    {
        // Bigger effect for higher level.
        int nLevel = GetHitDice(oNPC);
        if(nLevel > 20)
        {
            if(GetAlignmentGoodEvil(oNPC) == ALIGNMENT_EVIL) nEffect = VFX_FNF_SUMMON_GATE;
            else nEffect = VFX_FNF_SUMMON_CELESTIAL;
        }
        else if(nLevel > 15) nEffect = VFX_FNF_SUMMON_UNDEAD;
        else if(nLevel > 10) nEffect = VFX_FNF_SUMMON_MONSTER_3;
        else if(nLevel > 5) nEffect = VFX_FNF_SUMMON_MONSTER_2;
        else nEffect = VFX_FNF_SUMMON_MONSTER_1;
        effect eEffect = EffectVisualEffect(nEffect);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEffect, GetLocation(oNPC));
        AssignCommand(oNPC, SetIsDestroyable(TRUE, FALSE));
        DestroyObject(oNPC, 1.0f);
        return;
    }
    // Check method for leaving an area by the farthest way possible.
    else if(sLeaveMethod == "FAREXIT")
    {
        // Look for a door first.
        int i = 10;
        oExit = GetNearestObject(OBJECT_TYPE_DOOR, oNPC, i);
        while(!GetIsObjectValid(oExit) && i > 0)
        {
            i--;
            oExit = GetNearestObject(OBJECT_TYPE_DOOR, oNPC, i);
        }
        if(oExit != OBJECT_INVALID) lLocation = GetLocation(oExit);
        // No doors so lets move to the edge.
        if(oExit == OBJECT_INVALID)
        {
            lLocation = GetLocation(oNPC);
            vLoc = GetPositionFromLocation(GetLocation(oNPC));
            float fX = IntToFloat(GetAreaSize(AREA_WIDTH, oArea));
            if(vLoc.x > fX / 2) vLoc.x = 1.0;
            else vLoc.x = fX - 1.0;
            lLocation = Location(oArea, vLoc, 0.0);
        }
    }
    else if(sLeaveMethod == "NEAREXIT")
    {
        // Look for a door first.
        oExit = GetNearestObject(OBJECT_TYPE_DOOR, oNPC);
        if(oExit != OBJECT_INVALID) lLocation = GetLocation(oExit);
        // No doors so lets move to the edge.
        if(oExit == OBJECT_INVALID)
        {
            // Get the edge of the map.
            lLocation = GetLocation(oNPC);
            vLoc = GetPositionFromLocation(GetLocation(oNPC));
            float fX = IntToFloat(GetAreaSize(AREA_WIDTH, oArea));
            if(vLoc.x < fX / 2) vLoc.x = 1.0;
            else vLoc.x = fX - 1.0;
            lLocation = Location(oArea, vLoc, 0.0);
        }
    }
    else
    {
        oExit = GetObjectByTag(sLeaveMethod);
        lLocation = GetLocation(oExit);
    }
    //Debug("0i_quest", "2311", "lLocation: " + LocationToStringArray(lLocation));
    SetLocalLocation(oNPC, "0_Exit", lLocation);
    // They will not be interupted by animations.
    SetAICondition(AI_IS_WALKING, TRUE, oNPC);
    AssignCommand(oNPC, ActionMoveToLocation(lLocation));
    AssignCommand(oNPC, SetIsDestroyable(TRUE, FALSE));
    AssignCommand(oNPC, ActionDoCommand(DestroyObject(oNPC)));
    DelayCommand(60.0, DestroyObject(oNPC));
}

// STATE(Str/Array "-") Quest State: What the PC has done in the quest.
//         Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
//         1 - Object Destroyed.         6 - Area found.
//         2 - Villain Killed.           7 -
//         3 - Creature Killed.          8 - Area Cleared.
//         4 - Item Picked up.           9 - Escorted NPC is dead.
//         5 - NPC Picked up.            10 - Finished X number of tasks.
// nValue is usually 0, 1, x number for a task.
int GetQuestState(object oPC, string sQuestID, int nState)
{
    string sStateArray = GetServerDatabaseString(oPC, QUEST_TABLE, "state", sQuestID);
    return StringToInt(GetStringArray(sStateArray, nState, "-"));
}

// STATE(Str/Array "-") Quest State: What the PC has done in the quest.
//         Each array is usually either 1 - TRUE, or 0 - FALSE. 10 - can any number.
//         1 - Object Destroyed.         6 - Area found.
//         2 - Villain Killed.           7 -
//         3 - Creature Killed.          8 - Area Cleared.
//         4 - Item Picked up.           9 - Escorted NPC is dead.
//         5 - NPC Picked up.            10 - Finished X number of tasks.
// nValue is usually 0, 1, x number for a task.
void SetQuestState(object oPC, string sQuestID, int nState, int nValue)
{
    string sStateArray = GetServerDatabaseString(oPC, QUEST_TABLE, "state", sQuestID);
    sStateArray = SetStringArray(sStateArray, nState, IntToString(nValue), "-");
    SetServerDatabaseString(oPC, QUEST_TABLE, "state", sStateArray, sQuestID);
}
int GetNextQuestPointer(object oPC, string sQuestID, string sQuestArray)
{
    // Quest array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Start_Effect-)
    // Get the next quest pointer.
    string sPointer = GetStringArray(sQuestArray, 3, "-");
    if(sPointer == "END") return -1;
    else if(sPointer == "CLEAR") return -2;
    return StringToInt(sPointer);
}

// Removes the quest oNPC from oPC as a henchman.
void RemoveQuestNPC(object oPC, object oNPC)
{
    //Debug("0i_quest", "3269", "Removing NPC: " + GetName(oNPC) + " from " + GetName(oPC));
    DeleteLocalString(oNPC, PC_ASSOCIATE_TYPE);
    DeleteLocalString(oNPC, "0_QUEST_ID");
    DeleteLocalInt(oNPC, "0_Quest_Type");
    RemoveHenchman(oPC, oNPC);
    ClearAllActions(FALSE, oNPC);
    ChangeToStandardFaction(oNPC, STANDARD_FACTION_DEFENDER);
    RemoveHenchmanFromDatabase(oPC, oNPC);
    SetCommandable(TRUE, oNPC);
    AssignCommand(oNPC, ClearAllActions());
 }

// Checks the oPaper for an NPC and makes them a henchman for oPC.
void GiveQuestNPC(object oPC, string sQuestID, string sNPCArray, string sQuestArray)
{
    // 0_Q_NPC array: -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1
    //                -Align2-Faction-Waypoint spawn-Items-
    object oNPC = GetQuestCharacter(oPC, GetArea(oPC), sQuestID, sNPCArray, oPC);
    //Debug("0i_quest", "2661", "oNPC: " + GetName(oNPC) + " sNPCArray: " + sNPCArray);
    object oItem = GetCreatureHasItem(oNPC, "0_quest_paper");
    DestroyObject(oItem);
    // Set the associate type for the NPC.
    SetLocalInt(oNPC, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_NPC);
    string sColor;
    int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
    if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
    else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
    //else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
    if(sColor != "")
    {
        string sNPCName = StripColorCodes(GetName(oNPC));
        sNPCName = AddColorToText(sNPCName, sColor);
        SetName(oNPC, sNPCName);
    }
    // Let's make sure we are firing our OnDeath script after the AI.
    SetLocalString(oNPC, "AI_ON_DEATH", "nw_ch_ac7");
    // Save the NPC to the database and get the database tag.
    string sDatabaseTag = SaveAssociateToDatabase(oPC, oNPC);
    sNPCArray = SetStringArray(sNPCArray, 14, sDatabaseTag, "-");
    SetServerDatabaseString(oPC, QUEST_TABLE, "npc", sNPCArray, sQuestID);
    AddHenchman(oPC, oNPC);
    // Initialized NPC's AI data, Must be done after AddHenchman function.
    //ai_SetupAssociateData(oPC, oNPC);
    // Lock the NPC's widget.
    SetLocalInt(oNPC, "AI_LIMIT_HENCHMAN_MENUS", TRUE);
    // Set the NPC's widget buttons with
    // Follow (8), Hold(16), Normal(32), Action(1024), Toggle AI(4096).
    SetLocalInt(oNPC, "ASSOCIATE_WIDGET_BUTTONS", 5176);
    //SetLocalInt(oNPC, "ASSOCIATE_WIDGET_BUTTONS", 2102328); Spell Widget(2097152)
    // Add Feats to the NPC's widget buttons, must be done after AddHenchman function.
    //ai_SetFeattoAssociateWidget(oPC, oNPC, 1110, 834, GetClassByPosition(1, oNPC));
    //ai_SetFeattoAssociateWidget(oPC, oNPC, 1107, 830, GetClassByPosition(1, oNPC));
    //ai_SetSpelltoAssociateWidget(oPC, oNPC, 107, 10, 1); // Magic Missle
    //oItem = CreateItemOnObject("0_neck_fireball3", oNPC, 1);
    //ai_SetItemtoAssociateWidget(oPC, oNPC, oItem);
    // Set State 5 to TRUE(NPC Picked up).
    SetQuestState(oPC, sQuestID, 5, 1);
    SetLocalString(oNPC, "0_QUEST_ID", sQuestID);
}

// Checks the area for an NPC from the NPCArray.
// Sets them with the Quest ID and returns the NPC or OBJECT_INVALID.
object CheckForNPC(object oPC, object oArea, string sNPCArray)
{
    int nIndex = 1;
    string sNPCName = GetStringArray(sNPCArray, 0, "-");
    // Search all spawned creatures for the NPC.
    object oNPC = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_CREATURE);
    while(oNPC != OBJECT_INVALID)
    {
        //Debug("0i_quest", "2682", "sNPCName: " + sNPCName + " NPC: " + StripColorCodes(GetName(oNPC)));
        // We match them up by name.
        if(sNPCName == StripColorCodes(GetName(oNPC)))
        {
            // Remove the loops saved index since we are aborting early.
            DeleteLocalInt(oArea, "0_AreaObject");
            // Make sure they have this quests ID.
            SetLocalString(oPC, "0_QUEST_ID", GetStringArray(sNPCArray, 2, "-"));
            return oNPC;
        }
        // If they have not been found then keep searching.
        oNPC = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_CREATURE);
    }
    //Debug("0i_quest", "2702", "CheckForNPC: " + sNPCName + " not found.");
    return OBJECT_INVALID;
}
//******************************************************************************
//**********                     Get Quest StrRef                      *********
//******************************************************************************
int GetLocationQuestStrRef (object oPC, object oNPC)
{
    string sQuestName = GetLocalString (oNPC, "0_Quest_Name");
    // If the npc has the quest pointer then use it.
    int nPointer = GetLocalInt(oNPC, "0_Quest_Pointer");
    // If not then pull the pointer from the database.
    if (nPointer == 0) nPointer = GetQuestPointerFromDataBase (oPC, sQuestName, LOCATION_QUESTS);
    else DeleteLocalInt(oNPC, "0_Quest_Pointer");
    return StringToInt (Get2DAString ("quest_list", "Quest_StrRef", nPointer));
}
int GetStoryQuestStrRef (object oPC, object oNPC)
{
    string sQuestName = GetLocalString(oNPC, "0_Quest_Name");
    // Check if they are on an alternate quest set on NPC with variable 0_Alternate_Quest.
    // This is set in 0c_if_q_giver.
    if(GetLocalInt(oNPC, "0_AQ" + GetName(oPC, TRUE)))
    {
        sQuestName = GetLocalString(OBJECT_SELF, "0_Alternate_Quest");
    }
    // If the npc has the quest pointer then use it.
    int nPointer = GetLocalInt(oNPC, "0_Quest_Pointer");
    // If not then pull the pointer from the database.
    if(nPointer == 0) nPointer = GetQuestPointerFromDataBase(oPC, sQuestName, STORY_QUESTS);
    else DeleteLocalInt(oNPC, "0_Quest_Pointer");
    return StringToInt(Get2DAString("quest_list", "Story_Quest_StrRef", nPointer));
}
int GetSideQuestStrRef (object oPC, object oNPC)
{
    int nPointer;
    // Check to see if they are just starting with this character only creates them for levels 1-3.
    // The first 3 quests are close to town and easier so they can be eased into the quest system.
    // Check the NPC for the town area first then default to current area.
    string sTownArea = GetLocalString (oNPC, "0_TOWN_AREA");
    if(sTownArea == "")
    {
        object oWaypoint = GetObjectInAreaByTag (GetArea (oNPC), "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        sTownArea = GetLocalString (oWaypoint, "0_Town_Area");
    }
    if(sTownArea == "Essembra" && GetCharacterLevels(oPC) < 4 && GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests") < 3)
    {
        // Save which quest the player is on from the 8 "easy quests" use the Players Handbook.
        object oBook = GetCreatureHasItem (oPC, "players_book");
        nPointer = GetLocalInt (oBook, "0_SideQuest_Num");
        // If we have been given a quest then go to the next easy quest 1 - 8.
        if(nPointer > 0)
        {
            nPointer ++;
            if(nPointer > 8) nPointer = 1;
        }
        // We have not done an easy quest so lets get one at random.
        else nPointer = d8();
        SetLocalInt(oBook, "0_SideQuest_Num", nPointer);
    }
    else
    {
        // Roll for the quest pointer get the number of side quest to roll from.
        // There are 8 starter quests that we skip.
        nPointer = StringToInt (Get2DAString ("quest_list", "Side_Quest_Desc", 0)) - 8;
        nPointer = Random (nPointer) + 9;
    }
    // Now set the NPC with the quest so they don't change later.
    SetLocalInt (oNPC, "0_SIDE_QUEST", nPointer);
    return StringToInt (Get2DAString ("quest_list", "Side_Quest_StrRef", nPointer));
}
//******************************************************************************
//**********              Area Quest Population System                 *********
//******************************************************************************

// This must be delayed if used in a loop.
void CreateQuestPlaceable(string sPlaceableArray, location lLocation)
{
    // Placeable array: -Name-ResRef-ID-Waypoint spawn-
    string sName = GetStringArray(sPlaceableArray, 0, "-");
    string sResRef = GetStringArray(sPlaceableArray, 1, "-");
    string sQuestID = GetStringArray(sPlaceableArray, 2, "-");
    object oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLocation, FALSE, sQuestID);
    if(sName != "") SetName(oPlaceable, sName);
    SetLocalString(oPlaceable, "0_QUEST_ID", sQuestID);
    SetLocalInt(oPlaceable, "0_Spawned", TRUE);
}

// This must be delayed if used in a loop.
// nType Adds things based on the type of creature: 0 - NPC, 1 - Villain, 2 - Giver.
void CreateQuestNPC(object oPC, string sQuestArray, string sNPCArray, object oWaypoint, int nType = 0)
{
    if(sNPCArray != "")
    {
        //Debug("0i_quest", "2440", "sNPCArray: " + sNPCArray + " lLocation: " + LocationToStringArray(lLocation));
        object oNPC = CreateNPC(GetLocation(oWaypoint), sNPCArray);
        string sQuestName = GetStringArray(sQuestArray, 0, "-");
        string sID = GetStringArray(sNPCArray, 2, "-");
        int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
        // Creating a quest VILLAIN.
        if(nType == 1)
        {
            SetUpVillain(oNPC);
            // Give villians a base set of items.
            GiveMagicalEquipment(oNPC, FloatToInt(GetChallengeRating (oNPC)));
            SetName(oNPC, ColorVillainName(oNPC, GetName(oNPC)));
            // Set the villain to walk around and act natural in close range.
            SetAICondition(AI_IS_MOBILE_CLOSE_RANGE, TRUE, oNPC);
            // Make sure the villian drops at least one magic item.
            if(GetLocalInt(oNPC, "0_BonusMagicItems") == 0) SetLocalInt(oNPC, "0_BonusMagicItems", 1);
            // Make sure they roll a permanent item.
            if(GetLocalInt(oNPC, "0_BaseItemType") == 0) SetLocalInt(oNPC, "0_BaseItemType", 149);
            // Give villain the kill ID of the quest paper.
            SetLocalString(oNPC, "0_QUEST_KILL", sID);
            // Set this creature as the villain TRUE.
            SetLocalInt(oNPC, "0_VILLAIN", TRUE);
            // Set all bosses to use battlecries.
            SetLocalInt(oNPC, "0_Battlecry", TRUE);
            // If they are defined as a Villain then give them Villain powers.
            SetupCreature(oNPC, oWaypoint);
            if(GetLocalInt(oWaypoint, "0_Villain")) GiveVillianSpecialPower(oNPC);
        }
        // Creating a quest GIVER
        else if(nType == 2)
        {
            SetUpNPC(oNPC);
            SetLocalInt(oNPC, "0_Quest_Type", nQuestType);
            SetLocalString(oNPC, "0_Quest_Name", sQuestName);
            SetupCreature(oNPC);
            string sColor;
            if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
            else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
            //else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
            if(sColor != "") SetName(oNPC, AddColorToText(GetName(oNPC), sColor));
        }
        // Creating a quest NPC
        else
        {
            SetUpNPC(oNPC);
            // Set generated NPC's to immobile animations.
            SetAICondition(AI_IS_IMMOBILE, TRUE, oNPC);
            // Give the NPC the quest name incase they give the next quest.
            //SetLocalString(oNPC, "0_Quest_Name", sQuestName);
            SetupCreature(oNPC);
            string sColor;
            if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
            else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
            //else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
            if(sColor != "") SetName(oNPC, AddColorToText(GetName(oNPC), sColor));
        }
        // Set the ID of the character.
        SetLocalString(oNPC, "0_QUEST_ID", sID);
        CheckAnimations(oNPC);
        // Equip the NPC based on equipment array.
        int nItems = StringToInt(GetStringArray(sNPCArray, 12, "-"));
        int nPackage = StringToInt(GetStringArray(sNPCArray, 6, "-"));
        DelayCommand(0.5f, GiveCreatureEquipment(oNPC, nItems, FALSE, nPackage));
        DelayCommand(1.0f, EquipItems(oNPC, TRUE, TRUE));
        // Set if character is wounded.
        int nWounded = StringToInt(GetStringArray(sNPCArray, 13, "-"));
        SetCreatureAsWounded(oNPC, nWounded);
    }
}

// Must be delayed if used within a loop.
void CreateQuestCreatures(object oPC, string sCreatureArray, location lLocation, int nFaction = 0)
{
    string sName = GetStringArray(sCreatureArray, 0, "-");
    string sResRef = GetStringArray(sCreatureArray, 1, "-");
    string sID = GetStringArray(sCreatureArray, 2, "-");
    // Get the number of creatures to spawn.
    int nNumber = StringToInt(GetStringArray(sCreatureArray, 3, "-"));
    // If the number of creatures is not set then randomize.
    if(nNumber < 1) nNumber = d3() + 2;
    else if(nNumber > 10) nNumber = 10;
    // Get if wounded.
    int nWounded = StringToInt(GetStringArray(sCreatureArray, 5, "-"));
    object oCreature;
    int nCounter = 0;
    // Create all of the creatures.
    while(nCounter < nNumber)
    {
        // Create the creature.
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation, FALSE);
        if(!GetIsObjectValid(oCreature)) SetModuleError("RESREF", "0i_quest", "2518", "Quest error invalid RESREF: " + sResRef + " sID: " + sID + " sName: " + sName);
        else
        {
            CheckAnimations(oCreature);
            CheckForTreasure(oPC, oCreature);
            if(GetLocalInt(oCreature, "0_No_Ranged")) SetAssociateMode(MODE_STOP_RANGED, TRUE);
            // Set creature faction.
            ChangeToStandardFaction(oCreature, nFaction);
            SetCreatureAsWounded(oCreature, nWounded);
            // If they have a specific name then give it to them.
            if(sName != "") SetName(oCreature, sName);
            // Set the quest kill ID if it is part of the quest.
            if(nFaction == 0) SetLocalString(oCreature, "0_QUEST_KILL", sID);
            // Set the creatures to walk around and act natural in close range.
            SetAICondition(AI_IS_MOBILE_CLOSE_RANGE, TRUE, oCreature);
        }
        nCounter++;
    }
}
void CreateQuestItem(object oPC, object oContainer, string sQuestID, string sItemType)
{
    // Get all of our information to populate the area
    string sItemArray;
    string sPCName = GetName(oPC, TRUE);
    string sQueryItem = "SELECT " + sItemType + ", quest FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlitem = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryItem);
    SqlBindString(sqlitem, "@name", sPCName);
    SqlBindString(sqlitem, "@tag", sQuestID);
    if(SqlStep(sqlitem)) sItemArray = SqlGetString(sqlitem, 0);
    else return;
    // 0_Q_ITEM array: -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
    //Debug("0i_quest", "2514", "sItemArray: " + sItemArray + "sPaperVariable: " + sPaperVariable +
    //       " oContainer: " + GetName(oContainer));
    if(sItemArray != "")
    {
        object oItem;
        int nLevel = StringToInt(GetStringArray(SqlGetString(sqlitem, 1), 1, "-"));
        string sName = GetStringArray(sItemArray, 0, "-");
        int nBaseItemType = StringToInt(GetStringArray(sItemArray, 2, "-"));
        string sResRef = GetStringArray(sItemArray, 3, "-");
        //Debug("0i_quest", "2514", "nLevel: " + IntToString(nLevel));
        // Check for item types that should not be randomized.
        if(nBaseItemType == 16 || // Armor
            nBaseItemType == 24 || // miscsmall
            nBaseItemType == 29 || // miscmedium
            nBaseItemType == 34 || // misclarge
            nBaseItemType == 39 || // healerskit
            nBaseItemType == 44 || // magicrod
            nBaseItemType == 45 || // magicstaff
            nBaseItemType == 46 || // magicwand
            nBaseItemType == 49 || // potions
            nBaseItemType == 62 || // thievestools
            nBaseItemType == 66 || // largebox
            nBaseItemType == 74 || // book
            nBaseItemType == 75 || // spellscroll
            nBaseItemType == 77 || // gem
            nBaseItemType == 79 || // miscthin
            sResRef != "") // use resref no matter what.
        {
            //Debug("0i_quest", "2541", "Create item: sResRef: " + sResRef + " oContainer: " + GetName(oContainer));
            oItem = CreateItemOnObject(sResRef, oContainer);
        }
        // Create item based on item type.
        else oItem = RollMagicItems(oContainer, nLevel, 1, nBaseItemType, oPC, TRUE, TRUE);
        if(oItem != OBJECT_INVALID)
        {
            // Set its ID.
            SetLocalString(oItem, "0_QUEST_ID", sQuestID);
            // Bind this item to a player.
            SetLocalString(oItem, "0_Binded", sPCName);
            if(sName != "NORMAL") SetName(oItem, sName);
            // This is not the quest item this is a given item to help on a quest!
            // If its a quest item then set the state.
            //if(sPaperVariable == "0_Q_GIVEITEM") SetQuestState(oPaper, 4, 1);
        }
        else SetModuleError("ITEM CREATION", "0i_quest", "2898", "Item is Invalid! ResRef:" + sResRef +
                             " BaseItemType:" + IntToString(nBaseItemType) + " oContainer: " + GetName(oContainer));
    }
}

// Must be delayed if used within a loop.
void PopulatePlaceables(string sPlaceableArray, string sItemArray, location lLocation)
{
    if(sPlaceableArray != "")
    {
        string sName = GetStringArray(sPlaceableArray, 0, "-");
        string sID = GetStringArray(sPlaceableArray, 2, "-");
        // Check for GROUP placeables.
        if(sName == "GROUP") CreateGroupPlaceable(GetStringArray(sPlaceableArray, 1, "-"), lLocation, sID);
        else CreateQuestPlaceable(sPlaceableArray, lLocation);
    }
}

void PopulateQuestCreatures(object oPC, object oWaypoint, string sCreatureArray, int nFaction = 4)
{
    if(sCreatureArray != "")
    {
        string sWPTag = GetStringArray(sCreatureArray, 4, "-");
        string sTag = GetTag(oWaypoint);
        // Check to see if the creatures should spawn at all the waypoints.
        if(sWPTag == "ALL" && sTag == "ip_encounter")
        {
            ClearWaypointSpawning(oWaypoint);
            DelayCommand(0.1, CreateQuestCreatures(oPC, sCreatureArray, GetLocation(oWaypoint), nFaction));
        }
        // Check to see if the creatures should spawn at one waypoint but all other waypoints are empty.
        else if(sWPTag == "EMPTY" && sTag == "ip_encounter")
        {
            ClearWaypointSpawning(oWaypoint);
        }
        // If the waypoint tag matches the creatures spawn point then clear waypoint and create creatures.
        else if(sWPTag == GetTag(oWaypoint))
        {
            ClearWaypointSpawning(oWaypoint);
            DelayCommand(0.1, CreateQuestCreatures(oPC, sCreatureArray, GetLocation(oWaypoint), nFaction));
        }
    }
}

void PopulateAreaQuestItem(object oPC, object oArea, object oWaypoint, string sQuestID)
{
    // Get all of our information to populate the item
    string sItemArray;
    string sQueryItem = "SELECT item FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlitem = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryItem);
    SqlBindString(sqlitem, "@name", GetName(oPC, TRUE));
    SqlBindString(sqlitem, "@tag", sQuestID);
    if(SqlStep(sqlitem)) sItemArray = SqlGetString(sqlitem, 0);
    else return;
    object oContainer, oCreature;
    // 0_Q_ITEM array: -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
    string sItemContainerTag = GetStringArray(sItemArray, 5, "-");
    // It has a specific creature/placeable to be put in so lets put it there.
    //Debug("0i_quest", "2631", "sItemContainerTag: " + sItemContainerTag);
    if(sItemContainerTag != "")
    {
        oContainer = GetObjectInAreaByTag(oArea, sItemContainerTag, 1, OBJECT_TYPE_ALL, TRUE);
    }
    // Could not find a specific creature or placeable to put item in.
    if(oContainer == OBJECT_INVALID)
    {
        string sID = GetStringArray(sItemArray, 4, "-");
        // Look for containers with the quest id first.
        oContainer = GetObjectInAreaByTag(oArea, sID, 1, OBJECT_TYPE_PLACEABLE, TRUE);
        //Debug("0i_quest", "2655", "oContainer: " + GetName(oContainer));
        if(oContainer == OBJECT_INVALID)
        {
            int nIndex = 1;
            oCreature = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_CREATURE);
            while(oCreature != OBJECT_INVALID)
            {
                if(!GetIsDead(oCreature))
                {
                    //Debug("0i_qust", "2664", "oCreature: " + GetName(oCreature) +
                    //       " 0_QUEST_KILL: " + GetLocalString(oCreature, "0_QUEST_KILL"));
                    // Save the creature as the container.
                    if(GetLocalString(oCreature, "0_QUEST_KILL") == sID) oContainer = oCreature;
                    // If they are the villain then stop looking and use them!
                    if(GetLocalInt(oCreature, "0_VILLAIN")) oCreature = OBJECT_INVALID;
                    else oCreature = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_CREATURE);
                    // If there is no villain then just use the last creature found.
                }
                else oCreature = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_CREATURE);
            }
            //Debug("0i_quest", "2661", "oContainer: " + GetName(oContainer));
            // We have checked for everything and found nothing! Create a corpse and drop it.
            if(oContainer == OBJECT_INVALID)
            {
                string sIndex = IntToString(Random(36) + 1);
                oContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "0_corpse_" + sIndex, GetLocation(oWaypoint));
                SetLocalInt(oContainer, "0_Spawned", TRUE);
                //Debug("0i_quest", "2682", "oContainer: " + GetName(oContainer) + " oWaypoint: " + GetName(oWaypoint));
            }
        }
    }
    CreateQuestItem(oPC, oContainer, sQuestID, "item");
}
void PopulateStartQuestArea(object oPC, object oArea, string sQuestID)
{
    // Get all of our information to populate the item
    string sGiverArray;
    string sPCName = GetName(oPC, TRUE);
    string sQueryGiver = "SELECT giver, quest FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlgiver = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryGiver);
    SqlBindString(sqlgiver, "@name", sPCName);
    SqlBindString(sqlgiver, "@tag", sQuestID);
    if(SqlStep(sqlgiver)) sGiverArray = SqlGetString(sqlgiver, 0);
    else return;
    int bGiverSpawned;
    string sGiverResRef, sGiverWPTag;
    string sQuestArray = SqlGetString(sqlgiver, 1);
    object oNPC = CheckForNPC(oPC, GetArea(oPC), sGiverArray);
    if(oNPC != OBJECT_INVALID)
    {
        bGiverSpawned = TRUE;
        string sColor;
        int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
        if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
        else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
        //else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
        if(sColor != "") SetName(oNPC, AddColorToText(GetName(oNPC), sColor));
    }
    else
    {
        sGiverResRef = GetStringArray(sGiverArray, 1, "-");
        // Make sure blanks don't register.
        if(sGiverResRef == "") sGiverResRef = "X";
        sGiverWPTag = GetStringArray(sGiverArray, 11, "-");
        // Cycle through all the waypoints in one pass and populate the area.
        int nIndex = 1, nNumOfEncWP;
        string sWPTag;
        // Check all waypoints in the area.
        object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
        while(oWaypoint != OBJECT_INVALID)
        {
            sWPTag = GetTag(oWaypoint);
            if(sGiverResRef == GetLocalString(oWaypoint, "0_Resref") || sGiverWPTag == sWPTag)
            {
                DelayCommand(0.1, CreateQuestNPC(oPC, sQuestArray, sGiverArray, oWaypoint, 2));
                bGiverSpawned = TRUE;
                break;
            }
            if(sWPTag == "ip_encounter") nNumOfEncWP++;
            oWaypoint = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_WAYPOINT);
        }
        if(!bGiverSpawned)
        {
            // We did not find specific waypoints so lets randomize one from all the waypoints in the area.
            int nRoll = Random(nNumOfEncWP) + 1;
            oWaypoint = GetObjectInAreaByTag(oArea, "ip_encounter", nRoll, OBJECT_TYPE_WAYPOINT, TRUE);
            //Debug("0i_quest", "2727", "nRoll: " + IntToString(nRoll) + " nNumOfEncWP: " + IntToString(nNumOfEncWP));
            ClearWaypointSpawning(oWaypoint);
            CreateQuestNPC(oPC, sQuestArray, sGiverArray, oWaypoint, 2);
        }
    }
}
void PopulateAreaQuestArea(object oPC, object oArea, string sQuestID)
{
    // Get all of our information to populate the item
    string sPlot;
    string sPCName = GetName(oPC, TRUE);
    string sQueryArea = "SELECT plot, state, placeable, villain, creatures, allies, npc, quest, item FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlarea = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryArea);
    SqlBindString(sqlarea, "@name", sPCName);
    SqlBindString(sqlarea, "@tag", sQuestID);
    if(SqlStep(sqlarea)) sPlot = SqlGetString(sqlarea, 0);
    else return;
    int bPlaceableDestroyed, bVillainGone, bVillainSpawned, bCreaturesGone;
    int bNPCSpawned, bNPCGone, bAlliesGone, bItemTaken;
    string sPlaceableWPTag, sVillainWPTag, sCreaturesWPTag, sAlliesWPTag;
    string sNPCResRef, sNPCWPTag;
    string sStateArray = SqlGetString(sqlarea, 1);
    string sQuestArray = SqlGetString(sqlarea, 7);
    object oNPC;
    string sPlaceableArray = SqlGetString(sqlarea, 2);
    if(sPlaceableArray == "") bPlaceableDestroyed = TRUE;
    else
    {
        sPlaceableWPTag = GetStringArray(sPlaceableArray, 3, "-");
        bPlaceableDestroyed = StringToInt(GetStringArray(sStateArray, 1, "-"));
    }
    string sVillainArray = SqlGetString(sqlarea, 3);
    if(sVillainArray == "") bVillainGone = TRUE;
    else
    {
        sVillainWPTag = GetStringArray(sVillainArray, 11, "-");
        bVillainGone = StringToInt(GetStringArray(sStateArray, 2, "-"));
    }
    string sCreaturesArray = SqlGetString(sqlarea, 4);
    if(sCreaturesArray == "") bCreaturesGone = TRUE;
    else
    {
        sCreaturesWPTag = GetStringArray(sCreaturesArray, 4, "-");
        bCreaturesGone = StringToInt(GetStringArray(sStateArray, 3, "-"));
    }
    string sAlliesArray = SqlGetString(sqlarea, 5);
    if(sAlliesArray == "") bAlliesGone = TRUE;
    else sAlliesWPTag = GetStringArray(sAlliesArray, 4, "-");
    string sNPCArray = SqlGetString(sqlarea, 6);
    if(sPlot != "4" || sNPCArray == "") bNPCGone = TRUE;
    else
    {
        if(GetStringArray(sStateArray, 5, "-") != "0" ||
            GetStringArray(sStateArray, 9, "-") != "0") bNPCGone = TRUE;
        if(!bNPCGone)
        {
            oNPC = CheckForNPC(oPC, GetArea(oPC), sNPCArray);
            if(oNPC != OBJECT_INVALID)
            {
                bNPCSpawned = TRUE;
                string sColor;
                int nQuestType = StringToInt(GetStringArray(sQuestArray, 5, "-"));
                if(nQuestType == STORY_QUESTS) sColor = COLOR_MAGENTA;
                else if(nQuestType == SIDE_QUESTS) sColor = COLOR_CYAN;
                //else if(nQuestType == 2) sColor = COLOR_SET; // Town Quests
                if(sColor != "") SetName(oNPC, AddColorToText(GetName(oNPC), sColor));
            }
            else
            {
                sNPCResRef = GetStringArray(sNPCArray, 1, "-");
                // Make sure blanks don't register.
                if(sNPCResRef == "") sNPCResRef = "X";
                sNPCWPTag = GetStringArray(sNPCArray, 11, "-");
            }
        }
    }
    // Used in Placeable building to see if we have a unique sID.
    string sItemArray = SqlGetString(sqlarea, 7);
    if(sItemArray == "") bItemTaken = TRUE;
    else bItemTaken = StringToInt(GetStringArray(sStateArray, 4, "-"));
    // Cycle through all the waypoints in one pass and populate the area.
    int nIndex = 1, nNumOfEncWP;
    string sWPTag;
    location lWPLocation;
    object oArea = GetArea(oPC);
    // Check all waypoints in the area.
    object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    while(oWaypoint != OBJECT_INVALID)
    {
        sWPTag = GetTag(oWaypoint);
        lWPLocation = GetLocation(oWaypoint);
        if(!bPlaceableDestroyed && sPlaceableWPTag == sWPTag) DelayCommand(0.1, PopulatePlaceables(sPlaceableArray, sItemArray, lWPLocation));
        if(!bVillainGone && sVillainWPTag == sWPTag)
        {
            // We want to clear the nearest waypoint for any tag villain.
            // This is usually because we have a Villain boss set at the closest waypoint.
            // We need to clear them so they don't get too villain bosses!
            ClearWaypointSpawning(GetNearestObjectByTag("ip_encounter", oWaypoint));
            ClearWaypointSpawning(oWaypoint);
            DelayCommand(0.1, CreateQuestNPC(oPC, sQuestArray, sVillainArray, oWaypoint, 1));
            bVillainSpawned = TRUE;
        }
        if(!bCreaturesGone) PopulateQuestCreatures(oPC, oWaypoint, sCreaturesArray, 0);
        if(!bNPCSpawned && !bNPCGone && (sNPCResRef == GetLocalString(oWaypoint, "0_Resref") || sNPCWPTag == sWPTag))
        {
            ClearWaypointSpawning(oWaypoint);
            DelayCommand(0.1, CreateQuestNPC(oPC, sQuestArray, sNPCArray, oWaypoint));
            bNPCSpawned = TRUE;
        }
        if(!bAlliesGone) PopulateQuestCreatures(oPC, oWaypoint, sAlliesArray, 3);
        if(sWPTag == "ip_encounter") nNumOfEncWP ++;
        oWaypoint = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_WAYPOINT);
    }
    // We did not find specific waypoints so lets randomize one from all the waypoints in the area.
    int nRoll = Random(nNumOfEncWP) + 1;
    oWaypoint = GetObjectInAreaByTag(oArea, "ip_encounter", nRoll, OBJECT_TYPE_WAYPOINT, TRUE);
    lWPLocation = GetLocation(oWaypoint);
    //Debug("0i_quest", "2800", "nRoll: " + IntToString(nRoll) + " nNumOfEncWP: " + IntToString(nNumOfEncWP));
    if(!bPlaceableDestroyed && sPlaceableWPTag == "") PopulatePlaceables(sPlaceableArray, sItemArray, lWPLocation);
    if(!bVillainGone && !bVillainSpawned) CreateQuestNPC(oPC, sQuestArray, sVillainArray, oWaypoint, 1);
    if(!bCreaturesGone && sCreaturesWPTag == "")
    {
        ClearWaypointSpawning(oWaypoint);
        CreateQuestCreatures(oPC, sCreaturesArray, lWPLocation, 0);
    }
    if(!bNPCGone && !bNPCSpawned) CreateQuestNPC(oPC, sQuestArray, sNPCArray, oWaypoint);
    if(!bAlliesGone && sAlliesWPTag == "")
    {
        ClearWaypointSpawning(oWaypoint);
        CreateQuestCreatures(oPC, sAlliesArray, lWPLocation, 3);
    }
    // Add items to the end so we can populate that with placeables or creatures.
    // Delay so all items have time to spawn.
    if(!bItemTaken) DelayCommand(1.0, PopulateAreaQuestItem(oPC, oArea, oWaypoint, sQuestID));
}
void PopulateFinishQuestArea(object oPC, object oArea, string sQuestID)
{
    string sPlot;
    // Get all of our information to populate the area
    string sQueryfinish = "SELECT plot, finisher, followers, enemies, fplaceable, quest FROM QuestTable WHERE name = @name AND tag = @tag;";
    sqlquery sqlfinish = SqlPrepareQueryCampaign(SERVER_DATABASE, sQueryfinish);
    SqlBindString(sqlfinish, "@name", GetName(oPC, TRUE));
    SqlBindString(sqlfinish, "@tag", sQuestID);
    if(SqlStep(sqlfinish)) sPlot = SqlGetString(sqlfinish, 0);
    else return;
    //Debug("0i_quest", "3206", "sPlot: " + sPlot);
    string sQuestArray = SqlGetString(sqlfinish, 5);
    int bFinisherSpawned, bFollowersGone, bEnemiesGone, bFPlaceableGone;
    string sFinisherArray, sFinisherResRef, sFinisherWPTag, sFollowersWPTag;
    string sFPlaceableWPTag, sEnemiesWPTag;
    if(sPlot == "6") bFinisherSpawned = TRUE;
    else
    {
        sFinisherArray = SqlGetString(sqlfinish, 1);
        if(CheckForNPC(oPC, oArea, sFinisherArray) != OBJECT_INVALID) bFinisherSpawned = TRUE;
        else
        {
            sFinisherResRef = GetStringArray(sFinisherArray, 1, "-");
            if(sFinisherResRef == "") sFinisherResRef = "X";
            sFinisherWPTag = GetStringArray(sFinisherArray, 11, "-");
        }
    }
    string sFollowersArray = SqlGetString(sqlfinish, 2);
    if(sFollowersArray == "") bFollowersGone = TRUE;
    else
    {
        sFollowersWPTag = GetStringArray(sFollowersArray, 4, "-");
    }
    string sEnemiesArray = SqlGetString(sqlfinish, 3);
    if(sEnemiesArray == "") bEnemiesGone = TRUE;
    else
    {
        sEnemiesWPTag = GetStringArray(sEnemiesArray, 4, "-");
    }
    string sFPlaceableArray = SqlGetString(sqlfinish, 4);
    if(sFPlaceableArray == "") bFPlaceableGone = TRUE;
    else
    {
        sFPlaceableWPTag = GetStringArray(sFPlaceableArray, 3, "-");
    }
    // Cycle through all the waypoints in one pass and populate the area.
    int nNumOfEncWP, nIndex = 1;
    string sWPTag;
    // Check all waypoints in the area.
    object oWaypoint = GetObjectInArea(oArea, nIndex, OBJECT_TYPE_WAYPOINT);
    while(oWaypoint != OBJECT_INVALID)
    {
        sWPTag = GetTag(oWaypoint);
        //Debug("0i_quest", "2854", "bFinisherSpawned: " + IntToString(bFinisherSpawned) +
        //      " sFinisherResRef: " + sFinisherResRef + " 0_Resref: " + GetLocalString(oWaypoint, "0_Resref") +
        //      " sFinisherWPTag: " + sFinisherWPTag + " sWPTag: " + sWPTag);
        if(!bFinisherSpawned && (sFinisherResRef == GetLocalString(oWaypoint, "0_Resref") || sFinisherWPTag == sWPTag))
        {
            ClearWaypointSpawning(oWaypoint);
            DelayCommand(0.1, CreateQuestNPC(oPC, sQuestArray, sFinisherArray, oWaypoint));
            bFinisherSpawned = TRUE;
        }
        if(!bFPlaceableGone && sFPlaceableWPTag == sWPTag) DelayCommand(0.1, PopulatePlaceables(sFPlaceableArray, "", GetLocation(oWaypoint)));
        if(!bFollowersGone) PopulateQuestCreatures(oPC, oWaypoint, sFollowersArray, 3);
        if(!bEnemiesGone) PopulateQuestCreatures(oPC, oWaypoint, sEnemiesArray, 0);
        if(sWPTag == "ip_encounter") nNumOfEncWP++;
        oWaypoint = GetObjectInArea(oArea, ++nIndex, OBJECT_TYPE_WAYPOINT);
    }
    // We did not find specific waypoints so lets randomize one from all the waypoints in the area.
    int nRoll = Random(nNumOfEncWP) + 1;
    oWaypoint = GetObjectInAreaByTag (oArea, "ip_encounter", nRoll, OBJECT_TYPE_WAYPOINT, TRUE);
    location lWPLocation = GetLocation(oWaypoint);
    //Debug("0i_quest", "2871", "nRoll: " + IntToString(nRoll) + " nNumOfEncWP: " + IntToString(nNumOfEncWP));
    if(!bFinisherSpawned) CreateQuestNPC(oPC, sQuestArray, sFinisherArray, oWaypoint);
    if(!bFollowersGone && sFollowersWPTag == "")
    {
        ClearWaypointSpawning(oWaypoint);
        CreateQuestCreatures(oPC, sFollowersArray, lWPLocation, 3);
    }
    if(!bEnemiesGone && sEnemiesWPTag == "")
    {
        ClearWaypointSpawning(oWaypoint);
        CreateQuestCreatures(oPC, sEnemiesArray, lWPLocation, 0);
    }
    if(!bFPlaceableGone && sFPlaceableWPTag == "") PopulatePlaceables(sFPlaceableArray, "",lWPLocation);
}
//******************************************************************************
//**********                 Quest Creation systems                   **********
//******************************************************************************
string GenerateNPCWithResRefAndSetName(string sResRef, string sArray, location lLocation)
{
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
    if(!GetIsObjectValid(oCreature)) SetModuleError("RESREF", "0i_quest", "2682", "Creature not created: " + sResRef);
    else SetupCreature(oCreature);
    // Set the creatures name if not already set.
    string sName = GetStringArray(sArray, 0, "-");
    if(sName == "") sArray = SetStringArray(sArray, 0, GetName(oCreature), "-");
    SetIsDestroyable(TRUE, FALSE, FALSE, oCreature);
    DestroyObject(oCreature);
    return sArray;
}

string GenerateNPCArrayAndSetName(string sArray, int nCR, object oPC)
{
    int nLevel;
    // Creature array -Name-ResRef-Tag-Gender-Race-Class-Package-level-Align1
    //               -Align2-Faction-Waypoint spawn-Items-Wounded%
    // Check for fields to copy the PC.
    // Check for the class of the villain.
    if(GetStringArray(sArray, 5, "-") == "?")
    {
       int nType = GetClassByPosition(1, oPC);
       // Paladins will not fight another paladin so make them a fighter.
       if(nType == 45/*CLASS_TYPE_PALADIN*/) nType = CLASS_TYPE_FIGHTER;
       sArray = SetStringArray(sArray, 5, IntToString(nType), "-");
       // Use default Package.
       sArray = SetStringArray(sArray, 6, IntToString(nType), "-");
    }
    string sLevel = GetStringArray(sArray, 7, "-");
    if(sLevel == "?") sArray = SetStringArray(sArray, 7, IntToString(GetCharacterLevels(oPC)), "-");
    else if(GetStringLeft(sLevel, 1) == "~")
    {
        nLevel = StringToInt(GetStringRight(sLevel, GetStringLength(sLevel) - 1));
        nLevel = GetCharacterLevels(oPC) - nLevel;
        if(nLevel < 1) nLevel = 1;
        sArray = SetStringArray(sArray, 7, IntToString(nLevel), "-");
    }
    else if(sLevel == "" || sLevel == "0")
    {
        if(nCR < 1) nCR = 1;
        sArray = SetStringArray(sArray, 7, IntToString(nCR), "-");
    }
    sArray = CreateNPCArray(sArray);
    return sArray;
}

string GenerateCreatureArray(string sCreatureArray, int nQuestLevel, location lLocation)
{
    int nNumber;
    string sChart;
    object oCreature;
    string sName = GetStringArray(sCreatureArray, 0, "-");
    string sResRef = GetStringArray(sCreatureArray, 1, "-");
    if(sResRef == "RANDOM") sChart = GetEncounterChart("Encounter");
    else if(sResRef == "HUMANOIDS") sChart = GetEncounterChart("Enc_Humanoid");
    else if(sResRef == "ANIMALS") sChart = GetEncounterChart("Enc_Animal");
    else if(sName == "ENCOUNTER")
    {
        sChart = sResRef;
        nNumber = StringToInt(GetStringArray(sCreatureArray, 3, "-"));
    }
    // They have specified a specific creature.
    else
    {
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
        if(!GetIsObjectValid(oCreature)) SetModuleError("RESREF", "0i_quest", "2744", "A quest has an invalid ResRef(" +  sResRef + ")");
        // sArray 0: Name.
        if(sName == "") sCreatureArray = SetStringArray(sCreatureArray, 0, GetName(oCreature), "-");
        // sArray 1: ResRef is already set.
        // sArray 2: Creature's ID is set in another script.
        nNumber = StringToInt(GetStringArray(sCreatureArray, 3, "-"));
        if(nNumber == 0) nNumber = d3()+ 2;
    }
    // if sEncounter is set then roll on that encounter chart.
    if(sChart != "")
    {
        // Calculate row in the 2da(each level gets 5 entries thus((nQuestLevel - 1) * 5) + Random(5) + 1)
        int nRoll =((nQuestLevel - 1) * 5) + Random(5) + 1;
        // Get the resref of the creature to spawn.
        sResRef = Get2DAString(sChart, "ResRef", nRoll);
        // Now spawn so we can get the creatures name.
        oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLocation);
        if(!GetIsObjectValid(oCreature)) SetModuleError("RESREF", "0i_quest", "435", "sEncounter(" + sChart + ") 2da Row:(" + IntToString(nRoll) + ") has an invalid ResRef(" +  sResRef + ")");
        // Save Creature to array.
        // sArray 0: Name.
        if(sName == "" || sName == "ENCOUNTER") sCreatureArray = SetStringArray(sCreatureArray, 0, GetName(oCreature), "-");
        sCreatureArray = SetStringArray(sCreatureArray, 1, sResRef, "-");
        // sArray 2: Creature's ID is set later.
        // Set the number of creatures.
        if(nNumber == 0)
        {
            // Check the encounter chart.
            nNumber = StringToInt(Get2DAString(sChart, "Number", nRoll));
            if(nNumber == 0) nNumber = d3()+ 2;
        }
    }
    sCreatureArray = SetStringArray(sCreatureArray, 3, IntToString(nNumber), "-");
    // sArray 4: Waypoint spawn is not changed.
    // sArray 5: Wounded% is set already.
    // Set creatures size.
    sCreatureArray = SetStringArray(sCreatureArray, 6, IntToString(GetCreatureSize(oCreature)), "-");
    // Set creatures racial type.
    sCreatureArray = SetStringArray(sCreatureArray, 7, IntToString(GetRacialType(oCreature)), "-");
    AssignCommand(oCreature, SetIsDestroyable(TRUE, FALSE));
    DestroyObject(oCreature);
    return sCreatureArray;
}

string GenerateItemArray(string sItemArray, int nQuestLevel, object oPaper, object oPC)
{
    int nRoll, nItemNumber, nBaseItemType;
    string sBaseItemType, sTag;
    object oItem, oItemPC;
    string sName = GetStringArray(sItemArray, 0, "-");
    string sBaseName = GetStringArray(sItemArray, 1, "-");
    string sResRef = GetStringArray(sItemArray, 3, "-");
    string sContainerTag = GetStringArray(sItemArray, 5, "-");
    // if [ITEM:--RANDOM---- then randomize an item.
    if(sBaseName == "RANDOM" && sResRef == "")
    {
        nRoll = d6();
        if(nRoll < 5) sBaseName = "MAGIC_ITEM";
        else if(nRoll == 5) sBaseName = "ART";
        else sBaseName = "GEM";
    }
    // if [ITEM:--RANDOM--0_holyring_5-- then randomize from 5 holyrings.
    if(sBaseName == "RANDOM" && sResRef != "")
    {
        // Randomize the item as we always randomize.
        // Use last digit of resref. i.e. 0_holyring_5
        // Will randomize between 5 different holy rings.
        // Get the number of items to roll from.
        nRoll = StringToInt(GetStringRight(sResRef, 1));
        // Roll
        nItemNumber = Random(nRoll) + 1;
        // Save the item number incase we need to match a placeable with it.
        SetLocalInt(oPaper, "0_ItemNumber", nItemNumber);
        // Recompile the item ResRef back together.
        nRoll = GetStringLength(sResRef) - 1;
        sResRef = GetStringLeft(sResRef, nRoll) + IntToString(nItemNumber);
        // Create the item on the NPC.
        oItem = CreateItemOnObject(sResRef);
        sBaseName = GetName(oItem, TRUE);
    }
    // if [ITEM:--MAGIC_ITEM---- then randomize a magic item.
    else if(sBaseName == "MAGIC_ITEM")
    {
        oItem = RollMagicItems(OBJECT_SELF, nQuestLevel, 1, 149);
        nBaseItemType = GetBaseItemType(oItem);
        sBaseName = GetName(oItem, TRUE);
        // Check for item types that should not be randomized.
        if(nBaseItemType == 24 || // miscsmall
            nBaseItemType == 29 || // miscmedium
            nBaseItemType == 34 || // misclarge
            nBaseItemType == 39 || // healerskit
            nBaseItemType == 44 || // magicrod
            nBaseItemType == 45 || // magicstaff
            nBaseItemType == 46 || // magicwand
            nBaseItemType == 49 || // potions
            nBaseItemType == 62 || // thievestools
            nBaseItemType == 66 || // largebox
            nBaseItemType == 74 || // book
            nBaseItemType == 75 || // spellscroll
            nBaseItemType == 77 || // gem
            nBaseItemType == 79) // miscthin
            sResRef = GetResRef(oItem);
    }
    // if [ITEM:--ART----] then randomize an art object.
    else if(sBaseName == "ART")
    {
        oItem = RollArt(OBJECT_SELF, nQuestLevel, 1);
        sResRef = GetResRef(oItem);
        sBaseName = "piece of art";
    }
    // if [ITEM:--GEM----] then randomize a gem.
    else if(sBaseName == "GEM")
    {
        oItem = RollGems(OBJECT_SELF, nQuestLevel, 1);
        sResRef = GetResRef(oItem);
        sBaseName = "gem";
    }
    // Check to see if this is random item with base type.
    else if(sBaseName == "RANDOMTYPE")
    {
        nRoll = StringToInt(GetStringArray(sItemArray, 2, "-"));
        oItem = RollMagicItems(OBJECT_SELF, nQuestLevel, 1, nRoll, oPC, TRUE, TRUE);
        nBaseItemType = GetBaseItemType(oItem);
        sBaseName = GetName(oItem, TRUE);
    }
    else if(sBaseName == "PC_CLASS")
    {
        int nClass = GetClassByPosition(1, oPC);
        switch(nClass)
        {
            // Warrior type classes.
            case CLASS_TYPE_BARBARIAN :
            case CLASS_TYPE_FIGHTER :
            case CLASS_TYPE_CLERIC  :
            case CLASS_TYPE_PALADIN2 :
            case CLASS_TYPE_RANGER2 :
            case CLASS_TYPE_SWASHBUCKLER :
            case CLASS_TYPE_FAVORED_SOUL :
            {
                // Get weapon in right hand, if no weapon then get armor, if no armor random a weapon.
                oItemPC = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
                if(oItemPC == OBJECT_INVALID) oItemPC = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
                if(oItemPC == OBJECT_INVALID) oItem = RollMagicItems(OBJECT_SELF, nQuestLevel, 1, 135); /*Martial_Weapon*/
                else oItem = CopyItem(oItemPC, OBJECT_SELF);
                break;
            }
            // Rogue Classes
            case CLASS_TYPE_BARD :
            case CLASS_TYPE_ROGUE :
            case CLASS_TYPE_MONK :
            {
                // Give armor, if no armor then magic clothing.
                oItemPC = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
                if(oItemPC == OBJECT_INVALID) oItem = RollMagicItems(OBJECT_SELF, nQuestLevel, 1, 147); /*Magic_Clothing*/
                else oItem = CopyItem(oItemPC, OBJECT_SELF);
                break;
            }
            // Caster Classes
            case CLASS_TYPE_DRUID :
            case CLASS_TYPE_SORCERER :
            case CLASS_TYPE_WIZARD :
            case CLASS_TYPE_WARMAGE :
            {
                oItem = RollMagicItems(OBJECT_SELF, nQuestLevel, 1, 148);/*Magic_Jewelry*/
                break;
            }
        }
        nBaseItemType = GetBaseItemType(oItem);
        sBaseName = GetName(oItem, TRUE);
    }
    // Create the exact item in the quest.
    else
    {
        sResRef = GetStringArray(sItemArray, 3, "-");
        // Create the item on the NPC.
        oItem = CreateItemOnObject(sResRef);
    }
    // Check armors so we can make that exact armor.
    if(nBaseItemType == BASE_ITEM_ARMOR)
    {
        sTag = GetTag(oItem);
        if(sTag == "garb") nBaseItemType = 115;
        else if(sTag == "outfit") nBaseItemType = 116;
        else if(sTag == "robe") nBaseItemType = 117;
        else if(sTag == "tunic") nBaseItemType = 118;
        else if(sTag == "padded") nBaseItemType = 119;
        else if(sTag == "leather") nBaseItemType = 120;
        else if(sTag == "stleather") nBaseItemType = 121;
        else if(sTag == "hide") nBaseItemType = 122;
        else if(sTag == "chainshirt") nBaseItemType = 123;
        else if(sTag == "scalemail") nBaseItemType = 124;
        else if(sTag == "chainmail") nBaseItemType = 125;
        else if(sTag == "breastplate") nBaseItemType = 126;
        else if(sTag == "splintmail") nBaseItemType = 127;
        else if(sTag == "bandedmail") nBaseItemType = 128;
        else if(sTag == "halfplate") nBaseItemType = 129;
        else if(sTag == "fullplate") nBaseItemType = 130;
        else if(sTag == "dress") nBaseItemType = 152;
    }
    // Set the items name.
    if(sName == "") sName = "<c��>" + GetName(OBJECT_SELF) + "'s " + GetName(oItem, TRUE) + "</c>";
    else if(sName == "BASE_NAME") sName = "<c��>" + GetName(oItem, TRUE) + "</c>";
    else if(sName == "ORIGINAL") sName = GetName(oItem);
    sItemArray = "";
    sItemArray = SetStringArray(sItemArray, 0, sName, "-");
    sItemArray = SetStringArray(sItemArray, 1, sBaseName, "-");
    sItemArray = SetStringArray(sItemArray, 2, IntToString(nBaseItemType), "-");
    sItemArray = SetStringArray(sItemArray, 3, sResRef, "-");
    DestroyObject(oItem);
    // Set Item ID.
    sItemArray = SetStringArray(sItemArray, 4, GetLocalString(oPaper, "0_Q_ID"), "-");
    // Set the container tag to put item into.
    sItemArray = SetStringArray(sItemArray, 5, sContainerTag, "-");
    return sItemArray;
}

string GeneratePlaceableArray(string sPlaceableArray, location lLocation, object oPaper)
{
    object oPlaceable;
    string sName = GetStringArray(sPlaceableArray, 0, "-");
    string sResRef = GetStringArray(sPlaceableArray, 1, "-");
    string sSpawnPoint = GetStringArray(sPlaceableArray, 3, "-");
    if(sName == "GROUP") { /* We just pass the group on...*/ }
    // if [PLACEABLE:-RANDOM-ResRef-ID-Waypoint spawn-] randomize the placeable.
    else if(sName == "RANDOM" || sName == "RANDOMRESREF")
    {
        // Randomize the placeable as we always randomize.
        // Use last digit of resref. i.e. 0_Altar_5
        // Will randomize between 5 different altars.
        // Check to see if we randomized an item.
        // If so then use the same random number for the placeable.
        // if there is an nItemNumber from the Item creation code.
        // This is so we can make matching placeables and items for a quest.
        // Otherwise randomize it.
        int nRoll;
        int nItemNumber = GetLocalInt(oPaper, "0_ItemNumber");
        if(nItemNumber == 0)
        {
            nRoll = StringToInt(GetStringRight(sResRef, 1));
            nItemNumber = Random(nRoll) + 1;
        }
        // Recompile the placeable.
        nRoll = GetStringLength(sResRef) - 1;
        sResRef = GetStringLeft(sResRef, nRoll) + IntToString(nItemNumber);
        oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLocation);
        if(!GetIsObjectValid(oPlaceable)) SetModuleError("RESREF", "0i_quest", "574", "Quest Array: "
                                         + sPlaceableArray + " has an invalid ResRef(" +  sResRef + ")");
        // Clear the array to setup our placeable.
        sPlaceableArray = "-----";
        sPlaceableArray = SetStringArray(sPlaceableArray, 0, GetName(oPlaceable), "-");
        sPlaceableArray = SetStringArray(sPlaceableArray, 1, sResRef, "-");
        // sArray 2: Set Item ID in another script.
        // Set waypoint spawn.
        sPlaceableArray = SetStringArray(sPlaceableArray, 3, sSpawnPoint, "-");
    }
    // Not random so get the data arranged as an array.
    else
    {
        if(sName == "")
        {
            oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLocation);
            if(!GetIsObjectValid(oPlaceable)) SetModuleError("RESREF", "0i_quest", "590", "Quest Array: "
                                             + sPlaceableArray + " has an invalid ResRef(" +  sResRef + ")");
            // Create the name.
            sPlaceableArray = SetStringArray(sPlaceableArray, 0, GetName(oPlaceable), "-");
        }
    }
    sPlaceableArray = SetStringArray(sPlaceableArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
    return sPlaceableArray;
    DestroyObject(oPlaceable);
}

// Returns a unique ID for each SIDE_QUEST - Time + StrRef of the quest.
// or Returns a specific ID for STORY_QUESTS & QUESTS - UNIQUE_ + [ID:]
string SaveQuestID(int nQuestType, int nQuestPointer)
{
    if(nQuestType == STORY_QUESTS) 
    {
        return "UNIQUE_" + Get2DAString("quest_list", "Story_Quest_ID", nQuestPointer);
    }
    if(nQuestType == SIDE_QUESTS) 
    {
        return Get2DAString("quest_list", "Side_Quest_ID", nQuestPointer) + GetDateTimeToString();
    }
    if(nQuestType == LOCATION_QUESTS) 
    {
        return Get2DAString("quest_list", "Loc_Quest_ID", nQuestPointer);
    }
    return "";
}

// 0_Q_QUEST array -Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Start_Effect-ID-
string SaveQuestDataToArray(string sQuestText, int nQuestType, object oPC, object oArea)
{
    int nMaxLevel;
    int i = FindSubString(sQuestText, "[QUEST:");
    string sQuestArray = GetQuestData(sQuestText, i + 7);
    // Check CR of the quest and adjust if needed.
    if(StringToInt(GetStringArray(sQuestArray, 1, "-")) == 0)
    {
        int nQuestLevel = GetCharacterLevels(oPC);
        // This code limited the quests to the Town level + 5.
        // For example Essembra would do a max of 8th level quests.
        //object oWaypoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        //if(oWaypoint == OBJECT_INVALID) nMaxLevel = 20;
        //else nMaxLevel = GetLocalInt(oWaypoint, "0_Max_Level") + 5;
        //if(nQuestLevel > nMaxLevel) nQuestLevel = nMaxLevel;
        sQuestArray = SetStringArray(sQuestArray, 1, IntToString(nQuestLevel), "-");
    }
    sQuestArray = SetStringArray(sQuestArray, 5, IntToString(nQuestType), "-");
    return sQuestArray;
}

int SavePlot(string sQuestText)
{
    int i = FindSubString(sQuestText, "[PLOT:");
    return StringToInt(GetQuestData(sQuestText, i + 6));
}

// Start array -StartName-StartTag-Town_Area-
string SaveStartingAreaToArray(object oArea, object oTarget, string sQuestText)
{
    string sArray, sTownArea;
    // Check to see if the quest has a starting area. If not then use the current.
    int i = FindSubString(sQuestText, "[STARTAREA:");
    if(i != -1) return GetQuestData(sQuestText, i + 11);
    else
    {
        // Check the NPC for the town area first then default to current area.
        sTownArea = GetLocalString(oTarget, "0_TOWN_AREA");
        if(sTownArea == "")
        {
            object oWaypoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
            sTownArea = GetLocalString(oWaypoint, "0_Town_Area");
        }
    }
    sArray = SetStringArray("----", 0, GetName(oArea), "-");
    sArray = SetStringArray(sArray, 1, GetTag(oArea), "-");
    return SetStringArray(sArray, 2, sTownArea, "-");
}

// Giver array -Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-Wounded%-
string SaveNPCToArray(string sNPCArray, object oNPC, int nNPCType, object oPC, object oPaper, int nQuestLevel = 0)
{
    if(nNPCType == 3)
    {
        if(sNPCArray != "")
        {
            string sResRef = GetStringArray(sNPCArray, 1, "-");
            if(sResRef != "") 
            {
                location lLocation = GetLocation(GetWaypointByTag(WP_CREATURE_SPAWN));
                sNPCArray = GenerateNPCWithResRefAndSetName(sResRef, sNPCArray, lLocation);
            }
            else sNPCArray = GenerateNPCArrayAndSetName(sNPCArray, nQuestLevel, oPC);
            sNPCArray = SetStringArray(sNPCArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
            return sNPCArray;
        }
        // Default to the Giver as the finisher unless plot 6 in that case the NPC is the finisher.
        if(GetLocalString(oPaper, "0_Q_PLOT") == "6") return "";
        return GetLocalString(oPaper, "0_Q_GIVER");
    }
    string sNPCName = StripColorCodes(GetName(oNPC));
    if(sNPCArray == "") sNPCArray = "-----------4--2--";
    if(GetLocalInt(oNPC, "0_Generated_NPC"))
    {
        sNPCArray = SetStringArray(sNPCArray, 0, sNPCName, "-");
        //(1) ResRef is not set for randoms.
        //(2) Tag is set below.
        sNPCArray = SetStringArray(sNPCArray, 3, IntToString(GetGender(oNPC)), "-");
        sNPCArray = SetStringArray(sNPCArray, 4, IntToString(GetNPCRaceType(oNPC)), "-");
        sNPCArray = SetStringArray(sNPCArray, 5, IntToString(GetClassByPosition(1, oNPC)), "-");
        // Package is set to the class for default level up.
        sNPCArray = SetStringArray(sNPCArray, 6, IntToString(GetClassByPosition(1, oNPC)), "-");
        sNPCArray = SetStringArray(sNPCArray, 7, IntToString(GetCharacterLevels(oNPC)), "-");
        sNPCArray = SetStringArray(sNPCArray, 8, IntToString(GetAlignmentLawChaos(oNPC)), "-");
        sNPCArray = SetStringArray(sNPCArray, 9, IntToString(GetAlignmentGoodEvil(oNPC)), "-");
        //(10) This is set to 4 for .
        //(11) Waypoint spawn is not set for randoms.
        //(12) Items is set to 2 for normal equipment.
        //(13) We don't set the wounded %.
    }
    // If not then get the resref.
    else
    {
        sNPCArray = SetStringArray(sNPCArray, 0, sNPCName, "-");
        sNPCArray = SetStringArray(sNPCArray, 1, GetResRef(oNPC), "-");
        //(2) tag is set below.
        //(3) through(9) are defined by the pallet.
        //(10) Waypoint spawn is defined by programmer or is not set.
        //(11) Items is defined by programmer or is set to 1 normal equipment.
        //(13) We don't set the wounded %.
    }
    sNPCArray = SetStringArray(sNPCArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
    return sNPCArray;
}
// Finish array -Area_Name-Area_Tag-
string SaveFinishToArray(string sQuestText, int nPlot, int nQuestType, string sTownArea, object oPaper)
{
    string sFinishArray;
    int i = FindSubString(sQuestText, "[FINISH:");
    if(i == -1)
    {
        // Add 25% chance quest giver will be in different area.
        // We don't go back to the quest giver for quests 2 & 6.
        // We also do not want to mess with main quests & Town quests.
        if(d100() < 26 &&
            nPlot != 2 &&
            nPlot != 6 &&
            nQuestType == SIDE_QUESTS)
            {
                sQuestText = sQuestText + "[FINISH:RANDOMLOCAL]";
                i = FindSubString(sQuestText, "[FINISH:");
            }
    }
    if(i != -1)
    {
        string sLeaveMethod, sStartArray;
        sFinishArray = GetQuestData(sQuestText, i + 8);
        string sName = GetStringArray(sFinishArray, 0, "-");
        if(sFinishArray == "RANDOMTOWN") sFinishArray = GetRandomTown(sTownArea);
        else if(sFinishArray == "RANDOMAREA") sFinishArray = GetRandomArea(sTownArea);
        else if(sFinishArray == "RANDOMLOCAL")
        {
            // Roll for a random area near the quest area.
            // Get the number of areas in the list from row 0.
            int nRoll = StringToInt(Get2DAString("quest_list", sTownArea, 0));
            nRoll = Random(nRoll) + 1;
            // Get the area tag from the list.
            string sAreaTag = Get2DAString("quest_list", sTownArea, nRoll);
            // Set new random end area to Start array.
            sFinishArray = SetStringArray("-----", 1, sAreaTag, "-");
            object oArea = GetObjectByTag(GetStringArray(sFinishArray, 1, "-"));
            sFinishArray = SetStringArray(sFinishArray, 0, GetName(oArea), "-");
            // If a random leave method has not been set then create one.
            string sQuestArray = GetLocalString(oPaper, "0_Q_QUEST");
            string sStartName = GetStringArray(GetLocalString(oPaper, "0_Q_START"), 0, "-");
            string sFinishName = GetStringArray(GetLocalString(oPaper, "0_Q_FINISH"), 0, "-");
            if(sStartName != sFinishName)
            {
                int nRoll = d6();
                if(nRoll < 3) sLeaveMethod = "FAREXIT";
                else if(nRoll < 6) sLeaveMethod = "NEAREXIT";
                else sLeaveMethod = "TELEPORT";
                // Save to the Quest array for Leave method.
                sQuestArray = SetStringArray(sQuestArray, 9, sLeaveMethod, "-");
                SetLocalString(oPaper, "0_Q_QUEST", sQuestArray);
            }
        }
        // Not random and name is not defined.
        else if(sName == "")
        {
            // Check for a name.
            string sName = GetStringArray(sFinishArray, 0, "-");
            string sAreaTag = GetStringArray(sFinishArray, 1, "-");
            object oQuestArea = GetObjectByTag(sAreaTag);
            if(oQuestArea == OBJECT_INVALID)
            {
                // Get the x number and y number from the area tag example: "100_100_00"
                int nZ;
                int nY = StringToInt(GetSubString(sAreaTag, 4, 3));
                int nX = StringToInt(GetStringLeft(sAreaTag, 3));
                if(GetStringLength(sAreaTag) > 7) nZ = StringToInt(GetStringRight(sAreaTag, 2));
                else nZ = 0;
                // Generate the selected area.
                oQuestArea = GenerateArea(CreateAreaTag(nX, nY, nZ));
                sAreaTag = GetTag(oQuestArea);
            }
            sName = GetName(oQuestArea);
            sFinishArray = SetStringArray(sFinishArray, 0, sName, "-");
        }
    }
    else
    {
        // No finish area then use the starting area.
        // 0_Q_START array -Area_Name-Area_Tag-TownArea-
        sFinishArray = GetLocalString(oPaper, "0_Q_START");
    }
    return sFinishArray;
}
// 0_Q_REWARDS array -Fame-Infamy-Xp-Gold-KEEP-Journal_ID-Reward_Effect-
string SaveRewardsToArray(string sQuestText)
{
    int i = FindSubString(sQuestText, "[REWARDS:");
    return GetQuestData(sQuestText, i + 9);
}

// 0_Q_AREA array -Area_Name-Area_Tag-
string CheckForAreaToArray(string sQuestText, string sTownArea)
{
    string sArray, sName;
    int i = FindSubString(sQuestText, "[AREA:");
    if(i != -1)
    {
        int nZ, nY, nX;
        string sAreaTag, sX, sY;
        object oQuestArea;
        sArray = GetQuestData(sQuestText, i + 6);
        if(sArray == "RANDOMTOWN") sArray = GetRandomTown(sTownArea);
        else if(sArray == "RANDOMAREA") sArray = GetRandomArea(sTownArea);
        // Not random so get the information.
        else
        {
            sAreaTag = GetStringArray(sArray, 1, "-");
            sName = GetStringArray(sArray, 0, "-");
            oQuestArea = GetObjectByTag(sAreaTag);
            // Make sure the area is generated. If not then generate.
            if(!GetIsObjectValid(oQuestArea))
            {
                // Get the x number and y number from the area tag example: "100_100_00"
                nY = StringToInt(GetSubString(sAreaTag, 4, 3));
                nX = StringToInt(GetStringLeft(sAreaTag, 3));
                if(GetStringLength(sAreaTag) > 7) nZ = StringToInt(GetStringRight(sAreaTag, 2));
                else nZ = 0;
                // Generate the selected area.
                oQuestArea = GenerateArea(CreateAreaTag(nX, nY, nZ));
                sAreaTag = GetTag(oQuestArea);
            }
            // Generate sArray
            if(sName == "") sName = GetName(oQuestArea);
            sArray = SetStringArray(sArray, 0, sName, "-");
            sArray = SetStringArray(sArray, 1, sAreaTag, "-");
        }
        return sArray;
    }
    return "";
}

// 0_Q_NPC array [NPC:-Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-]
string CheckForNPCToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, object oPC)
{
    int i = FindSubString(sQuestText, "[NPC:");
    if(i != -1)
    {
        string sArray = GetQuestData(sQuestText, i + 5);
        if(sArray != "GIVER")
        {
            int nLevel = nQuestLevel / 2 + d3()-2;
            if(nLevel < 1) nLevel = 1;
            string sResRef = GetStringArray(sArray, 1, "-");
            if(sResRef != "") sArray = GenerateNPCWithResRefAndSetName(sResRef, sArray, lLocation);
            else sArray = GenerateNPCArrayAndSetName(sArray, nLevel, oPC);
            sArray = SetStringArray(sArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
            return sArray;
        }
        return GetLocalString(oPaper, "0_Q_GIVER");
    }
    return "";
}

// 0_Q_VILLAIN array [VILLAIN:-Name-ResRef-ID-Gender-Race-Class-Package-level-Align1-Align2-Faction-Waypoint_spawn-Items-]
string CheckForVillianToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, object oPC)
{
    int i = FindSubString(sQuestText, "[VILLAIN:");
    if(i != -1)
    {
        string sArray = GetQuestData(sQuestText, i + 9);
        string sResRef = GetStringArray(sArray, 1, "-");
        if(sResRef != "") sArray = GenerateNPCWithResRefAndSetName(sResRef, sArray, lLocation);
        else sArray = GenerateNPCArrayAndSetName(sArray, nQuestLevel + d3()-2, oPC);
        sArray = SetStringArray(sArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
        return sArray;
    }
    return "";
}

// Creature array -Name-ResRef-ID-Number-Waypoint_spawn-Wounded%-Size-RacialType-
string CheckForCreaturesToArray(string sQuestText, int nQuestLevel, location lLocation, object oPaper, string sQuestVar)
{
    int i;
    i = FindSubString(sQuestText, sQuestVar);
    if(i != -1)
    {
        string sCreatureArray = GetQuestData(sQuestText, i + GetStringLength(sQuestVar));
        sCreatureArray = GenerateCreatureArray(sCreatureArray, nQuestLevel, lLocation);
        // Set creature ID.
        sCreatureArray = SetStringArray(sCreatureArray, 2, GetLocalString(oPaper, "0_Q_ID"), "-");
        return sCreatureArray;
    }
    return "";
}

// Item array -Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-
string CheckForItemToArray(string sQuestText, int nQuestLevel, object oPaper, object oPC)
{
    int i = FindSubString(sQuestText, "[ITEM:");
    if(i != -1)
    {
        string sItemArray = GetQuestData(sQuestText, i + 6);
        sItemArray = GenerateItemArray(sItemArray, nQuestLevel, oPaper, oPC);
        return sItemArray;
    }
    return "";
}

// Item array -Name-BaseName-BaseItemType-ResRef-Tag-
string CheckForGiveItemToArray(string sQuestText, int nQuestLevel, object oPaper, object oPC)
{
    int i = FindSubString(sQuestText, "[GIVEITEM:");
    if(i != -1)
    {
        string sItemArray = GetQuestData(sQuestText, i + 10);
        sItemArray = GenerateItemArray(sItemArray, nQuestLevel, oPaper, oPC);
        return sItemArray;
    }
    return "";
}

// Placeable array -Name-ResRef-Tag-Waypoint spawn-
string CheckForPlaceableToArray(string sQuestText, location lLocation, object oPaper)
{
    int i = FindSubString(sQuestText, "[PLACEABLE:");
    if(i != -1)
    {
        string sPlaceableArray = GetQuestData(sQuestText, i + 11);
        sPlaceableArray = GeneratePlaceableArray(sPlaceableArray, lLocation, oPaper);
        return sPlaceableArray;
    }
    return "";
}

// FPlaceable array -Name-ResRef-Tag-Waypoint spawn-
string CheckForFPlaceableToArray(string sQuestText, location lLocation, object oPaper)
{
    int i = FindSubString(sQuestText, "[FPLACEABLE:");
    if(i != -1)
    {
        string sPlaceableArray = GetQuestData(sQuestText, i + 12);
        sPlaceableArray = GeneratePlaceableArray(sPlaceableArray, lLocation, oPaper);
        return sPlaceableArray;
    }
    return "";
}

string GetRandomTown(string sTownArea)
{
    // In quest_list.2da "TOWNNAME_quest" column defines the civilized areas
    // that a quest can end. This links to a list of the areas for each town
    // the quest can end in. This column is named "TOWNNAME" i.e. "Essembra"
    // Get the number of Towns this town can send a quest to.
    int nRoll = StringToInt(Get2DAString("quest_list", sTownArea + "_q", 0));
    nRoll = Random(nRoll) + 1;
    // Get the random Town column to get an area from.
    string sTownColumn = Get2DAString("quest_list", sTownArea + "_q", nRoll);
    // Get the number of areas that are linked to this town.
    nRoll = StringToInt(Get2DAString("quest_list", sTownColumn, 0));
    // Randomly roll for an area in this town.
    string sAreaTag = Get2DAString("quest_list", sTownColumn, nRoll);
    object oQuestArea = GetObjectByTag(sAreaTag);
    return "-" + GetName(oQuestArea) + "-" + sAreaTag + "-";
}

string GetRandomArea(string sTownArea)
{
    int nZ, nYQ, nXQ, nZQ;
    string sRanAreaTag, sY, sX, sZ, sYQ, sXQ, sZQ, sArray;
    object oWaypoint;
    // Randomize area.
    // In quest_list.2da "#Name#_end" column 1 Is the default area tag.
    // i.e. the main area for this quest area number.
    string sAreaTag = Get2DAString("quest_list", sTownArea, 1);
    // Now generate a new tag 3 - 5 areas away North/South & East/West.
    // Lets make sure it is not in a civilized area.
    int bCivilized = TRUE;
    int nFailSafe = 0;
    // Get the x number and y number from the area tag example: "100_100_00"
    int nY = StringToInt(GetSubString(sAreaTag, 4, 3));
    int nX = StringToInt(GetStringLeft(sAreaTag, 3));
    if(GetStringLength(sAreaTag) > 7) nZ = StringToInt(GetStringRight(sAreaTag, 2));
    else nZ = 0;
    while(bCivilized && nFailSafe < 20)
    {
        // Randomize the Y axis up or down.
        if(d2() == 1) nYQ = nY + d4() + 1;
        else nYQ = nY - d3() - 2;
        // Randomize the X axis up or down.
        if(d2() == 1) nXQ = nX + d4() + 1;
        else nXQ = nX - d3() - 2;
        // Adjust to match area tags with leading 0's.
        if(nYQ < 10) sYQ = "00" + IntToString(nYQ);
        else if(nYQ < 100) sYQ = "0" + IntToString(nYQ);
        else sYQ = IntToString(nYQ);
        if(nXQ < 10) sXQ = "00" + IntToString(nXQ);
        else if(nXQ < 100) sXQ = "0" + IntToString(nXQ);
        else sXQ = IntToString(nXQ);
        // Recompile to get the area.
        sRanAreaTag = sXQ + "_" + sYQ;
        // Now make sure it is not civilized.
        object oQuestArea = GetObjectByTag(sRanAreaTag);
        if(oQuestArea != OBJECT_INVALID)
        {
            // All civilized areas have a 0_No_Difficutly variable set to TRUE;
           oWaypoint = GetObjectInAreaByTag(oQuestArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
            if(!GetLocalInt(oWaypoint, "0_No_Difficulty"))
            {
                bCivilized = FALSE;
                sArray = "-" + GetName(oQuestArea) + "-" + sRanAreaTag + "-";
            }
        }
        // This area has not been generated yet.
        else
        {
            // Generate the selected area.
            oQuestArea = GenerateArea(CreateAreaTag(nXQ, nYQ, nZQ));
            // Generated areas are automatically not civilnZed.
            // If the area exists then set so we can continue.
            if(GetIsObjectValid(oQuestArea))
            {
                bCivilized = FALSE;
                sRanAreaTag = GetTag(oQuestArea);
                sArray = "-" + GetName(oQuestArea) + "-" + sRanAreaTag + "-";
            }
        }
        nFailSafe ++;
        if(nFailSafe >= 20) SetModuleError("AREA", "0c_quest_create", "610", "Loop Exit fail safe! We could not select a good area for the quest in " + sTownArea + "!");
    }
    return sArray;
}
object CreateBlankQuest(object oPC, object oTarget)
{
    object oPaper = CreateItemOnObject("0_quest_paper_dm", oTarget); 
    // Quest ID
    string sQuestID = "CUSTOM_" + GetDateTimeToString();
    SetLocalString(oPaper, "0_Q_ID", sQuestID);
    SetLocalString(oPaper, "0_Q_PLOT", "1");
    // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-ID-)
    string sArray = "-Quest-1-0-End-0-4-0-145-as_fanfare_intro--" + sQuestID + "-";
    SetLocalString(oPaper, "0_Q_QUEST", sArray);
    // 0_Q_REWARDS
    sArray = "---25-100---145-as_fanfare_intro--";
    SetLocalString(oPaper, "0_Q_REWARDS", sArray);    
    string sState = "-0-0-0-0-0-0-0-0-0-0-0-";
    SetLocalString(oPaper, "0_Q_STATE", sState);
    return oPaper;
}
// Creates a quest for oPC and puts it on oTarget.
// nQuestType is the type of quest STORY_QUESTS, SIDE_QUESTS, LOCATION_QUESTS.
// nQuestStrRef is the TLK line that holds the quest.
object CreateQuest(object oPC, object oTarget, int nQuestType, int nQuestStrRef)
{
    object oPaper, oWaypoint;
    // Create quest paper on oTarget so we can save to it.
    if(nQuestType == STORY_QUESTS) oPaper = CreateItemOnObject("0_quest_paper_m", oTarget);
    else oPaper = CreateItemOnObject("0_quest_paper", oTarget);
    // Save paper to PC so we can pass it to script: 0c_quest and 0c_if_questagain.
    SetLocalObject(oPC, "0_QUEST_PAPER", oPaper);
    object oArea = GetArea(oPC);
    string sState = "-0-0-0-0-0-0-0-0-0-0-0-";
    string sQuestText = GetStringByStrRef(nQuestStrRef);
    // Get location to safely create creatures and objects.
    location lLocation = GetLocation(GetWaypointByTag(WP_CREATURE_SPAWN));
    // 0_Q_QUEST
    string sArray = SaveQuestDataToArray(sQuestText, nQuestType, oPC, oArea);
    int nQuestLevel = StringToInt(GetStringArray(sArray, 1, "-"));
    int nQuestPointer = StringToInt(GetStringArray(sArray, 2, "-"));
    SetLocalString(oPaper, "0_Q_QUEST", sArray);
    //string sCompleteArray = SetStringArray("--", 1, sArray);
    // 0_Q_ID
    sArray = SaveQuestID(nQuestType, nQuestPointer);
    // Set the ID on the Giver.
    if(!GetIsPC(oTarget)) SetLocalString(oTarget, "0_QUEST_ID", sArray);
    SetLocalString(oPaper, "0_Q_ID", sArray);
    //sCompleteArray = SetStringArray(sCompleteArray, 0, sArray);
    // 0_Q_STRREF
    SetLocalString(oPaper, "0_Q_STRREF", IntToString(nQuestStrRef));
    //sCompleteArray = SetStringArray(sCompleteArray, 2, IntToString(nQuestStrRef));
    // 0_Q_PLOT
    int nPlot = SavePlot(sQuestText);
    SetLocalString(oPaper, "0_Q_PLOT", IntToString(nPlot));
    //sCompleteArray = SetStringArray(sCompleteArray, 3, IntToString(nPlot));
    // 0_Q_START
    sArray = SaveStartingAreaToArray(oArea, oTarget, sQuestText);
    SetLocalString(oPaper, "0_Q_START", sArray);
    string sTownArea = GetStringArray(sArray, 2, "-");
    if(sTownArea == "" && nQuestType == SIDE_QUESTS)
    {
        object oWaypoint = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        sTownArea = GetLocalString(oWaypoint, "0_Town_Area");
    }
    //sCompleteArray = SetStringArray(sCompleteArray, 4, sArray);
    // 0_Q_GIVER
    int nCharacterIndex = FindSubString(sQuestText, "[GIVER:");
    if(nCharacterIndex != -1) sArray = GetQuestData(sQuestText, nCharacterIndex + 7);
    else sArray = SaveNPCToArray(sArray, oTarget, 1, oPC, oPaper);
    SetLocalString(oPaper, "0_Q_GIVER", sArray);
    //sCompleteArray = SetStringArray(sCompleteArray, 5, sArray);
    // 0_Q_FINISH
    string sArea = GetLocalString(oTarget, "0_QUEST_FINISH");
    if(sArea != "")
    {
        object oQuestArea = GetObjectByTag(sArea);
        string sName = GetName(oQuestArea);
        sArray = "-" + sName + "-" + sArea + "-";
    }
    else sArray = SaveFinishToArray(sQuestText, nPlot, nQuestType, sTownArea, oPaper);
    SetLocalString(oPaper, "0_Q_FINISH", sArray);
    //sCompleteArray = SetStringArray(sCompleteArray, 6, sArray);
    // 0_Q_FINISHER
    nCharacterIndex = FindSubString(sQuestText, "[FINISHER:");
    if(nCharacterIndex != -1)
    {
        sArray = GetQuestData(sQuestText, nCharacterIndex + 10);
        sArray = SaveNPCToArray(sArray, OBJECT_INVALID, 3, oPC, oPaper, nQuestLevel);
    }
    else sArray = GetLocalString(oPaper, "0_Q_GIVER");
    SetLocalString(oPaper, "0_Q_FINISHER", sArray);
    //sCompleteArray = SetStringArray(sCompleteArray, 7, sArray);
    // 0_Q_REWARDS
    sArray = SaveRewardsToArray(sQuestText);
    SetLocalString(oPaper, "0_Q_REWARDS", sArray);
    //sCompleteArray = SetStringArray(sCompleteArray, 8, sArray);
    // *************************************************************************
    // Parse the Quest code for objects we might need to generate.
    // *************************************************************************
    // 0_Q_AREA for all areas and town only checks.
    sArea = GetLocalString(oTarget, "0_QUEST_AREA");
    if(sArea != "")
    {
        object oQuestArea = GetObjectByTag(sArea);
        string sName = GetName(oQuestArea);
        sArray = "-" + sName + "-" + sArea + "-";
    }
    else sArray = CheckForAreaToArray(sQuestText, sTownArea);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_AREA", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 9, sArray);
    }
    // Set quest state 6 for area showing there is no area.
    else sState = SetStringArray(sState, 6, "2", "-");
    // 0_Q_NPC
    sArray = CheckForNPCToArray(sQuestText, nQuestLevel, lLocation, oPaper, oPC);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_NPC", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 10, sArray);
    }
    // Set Quest state 5 for NPC meaning there are no NPCs.
    else sState = SetStringArray(sState, 5, "2", "-");
    // 0_Q_VILLAIN
    sArray = CheckForVillianToArray(sQuestText, nQuestLevel, lLocation, oPaper, oPC);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_VILLAIN", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 11, sArray);
    }
    // Set quest state 2 for Villain meaning there are no Villians.
    else sState = SetStringArray(sState, 2, "2", "-");
    // 0_Q_CREATURES
    sArray = CheckForCreaturesToArray(sQuestText, nQuestLevel, lLocation, oPaper, "[CREATURES:");
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_CREATURES", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 12, sArray);
    }
    // Set quest state 3 for Creature stating there are no creatures.
    else sState = SetStringArray(sState, 3, "2", "-");
    // 0_Q_ALLIES
    sArray = CheckForCreaturesToArray(sQuestText, nQuestLevel, lLocation, oPaper, "[ALLIES:");
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_ALLIES", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 13, sArray);
    }
    // 0_Q_FOLLOWERS
    sArray = CheckForCreaturesToArray(sQuestText, nQuestLevel, lLocation, oPaper, "[FOLLOWERS:");
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_FOLLOWERS", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 14, sArray);
    }
    // 0_Q_ENEMIES
    sArray = CheckForCreaturesToArray(sQuestText, nQuestLevel, lLocation, oPaper, "[ENEMIES:");
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_ENEMIES", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 15, sArray);
    }
    // 0_Q_ITEM
    sArray = CheckForItemToArray(sQuestText, nQuestLevel, oPaper, oPC);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_ITEM", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 16, sArray);
    }
    // Set quest state 4 for items stating there is no item for quest.
    else sState = SetStringArray(sState, 4, "2", "-");
    // 0_Q_GIVEITEM
    sArray = CheckForGiveItemToArray(sQuestText, nQuestLevel, oPaper, oPC);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_GIVEITEM", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 17, sArray);
    }
    // 0_Q_PLACEABLE
    sArray = CheckForPlaceableToArray(sQuestText, lLocation, oPaper);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_PLACEABLE", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 18, sArray);
    }
    // Set quest state 2 for placeable showing there is no placeable for quest.
    else sState = SetStringArray(sState, 1, "2", "-");
    // 0_Q_FPLACEABLE
    sArray = CheckForFPlaceableToArray(sQuestText, lLocation, oPaper);
    if(sArray != "")
    {
        SetLocalString(oPaper, "0_Q_FPLACEABLE", sArray);
        //sCompleteArray = SetStringArray(sCompleteArray, 19, sArray);
    }
    // Save quest state to the paper.
    SetLocalString(oPaper, "0_Q_STATE", sState);
    //sCompleteArray = SetStringArray(sCompleteArray, 20, sState);
    //Debug("0c_quest_create", "238", "Quest array: " + sCompleteArray);
    // Save complete array to paper.
    //  SetLocalString(oPaper, "0_Quest_Array", sCompleteArray);
    // Build the description for the paper.
    string sQuestDescription = GetStringByStrRef(nQuestStrRef + 1);
    sQuestDescription = CheckIsGiverMoving(oPC, oPaper, sQuestDescription);
    sQuestDescription = ParseQuestTextByPaper(sQuestDescription, oPaper, oPC);
    SetDescription(oPaper, sQuestDescription);
    return oPaper;
}
void Build_Treasure_Map(object oPC, object oPaper, int nLevel = 0)
{
    if(GetLocalString(oPaper, "0_Q_QUEST") == "")
    {
        int nVillainRoll, nCreatureRoll;
        if(nLevel == 0) nLevel = GetCharacterLevels(oPC, TRUE) + d3() - 2;
        if(nLevel < 1) nLevel = d3() + 2;
        if(nLevel > 40) nLevel = 40;
        string sLevel = IntToString(nLevel);
        string sVillainText, sCreature = "", sEncounter = "";
        location lLocation = GetLocation(GetObjectByTag("WP_Creature_Spawn"));
        // 0_Q_ID - Create a unique quest ID for treasure maps.
        string sQuestID = GetDateTimeToString() + "_" + IntToString(Random(10000)) + "_t_map";
        SetLocalString(oPaper, "0_Q_ID", sQuestID);
        string sState = "-0-0-0-0-0-2-0-0-0-0-0-";
        // Build quest info for a treasure map.
        // Quest Array:(-Quest_Name-CR-Quest_Pointer-Next_Quest_Pointer-Tasks-Quest_Type-Journal_ID-Visual_Effect-Sound_Effect-Leave_Method-ID-)
        string sText = "-Treasure Map-" + sLevel + "-0-END-0-3-0-145-as_fanfare_intro--";
        SetLocalString(oPaper, "0_Q_QUEST", sText);
        SetLocalString(oPaper, "0_Q_PLOT", "11");
        // Randomize the area but don't select an area higher than the quests nLevel.
        int nRoll = StringToInt(Get2DAString("quest_list", "Dungeon_Level", 0));
        while(nRoll > 1)
        {
            if(nLevel >= StringToInt(Get2DAString("quest_list", "Dungeon_Level", nRoll))) break;
            nRoll--;
        }
        nRoll = Random(nRoll) + 1;
        string sName = Get2DAString("quest_list", "Dungeon_Name", nRoll);
        string sTag = Get2DAString("quest_list", "Dungeon_Tag", nRoll);
        //string sName = "Dark Cave";
        //string sTag = "092_110_01";
        SetLocalString(oPaper, "0_Q_AREA", "-" + sName + "-" + sTag + "-");
        // Chance for a villain.
        nVillainRoll = d100();
        if(nVillainRoll < 50)
        {
            nVillainRoll = d6();
            string sResRef = "";
            if(nVillainRoll == 1)
            {
                sCreature = "ENCOUNTER";
                sEncounter = "e_elementals";
                sResRef = GetEncounterResRef("e_elementals", nLevel);
                sVillainText = " There is a warning of a [VILLAIN:NAME] protecting the item.";
                sText = GenerateNPCWithResRefAndSetName(sResRef, "--" + sResRef + "---------3--3--",lLocation);
            }
            else if(nVillainRoll == 2)
            {
                sCreature = "ENCOUNTER";
                sEncounter = "e_drow";
                sResRef = GetEncounterResRef("e_drow", nLevel);
                sVillainText = " There is a warning of a [VILLAIN:NAME] protecting the item.";
                sText = GenerateNPCWithResRefAndSetName(sResRef, "--" + sResRef + "---------3--3--",lLocation);
            }
            else if(nVillainRoll == 3)
            {
                sCreature = "ENCOUNTER";
                sEncounter = "e_orcs";
                sResRef = GetEncounterResRef("e_orcs", nLevel);
                sVillainText = " There is a warning of a [VILLAIN:NAME] protecting the item.";
                sText = GenerateNPCWithResRefAndSetName(sResRef, "--" + sResRef + "---------3--3--",lLocation);
            }
            else if(nVillainRoll == 4)
            {
                sCreature = "ENCOUNTER";
                sEncounter = "e_undead";
                sResRef = GetEncounterResRef("e_undead", nLevel);
                sVillainText = " There is a warning of a [VILLAIN:NAME] protecting the item.";
                sText = GenerateNPCWithResRefAndSetName(sResRef, "--" + sResRef + "---------3--3--",lLocation);
            }
            else
            {
                sVillainText = " The name [VILLAIN:NAME] is writen at the bottom of the map.";
                sText = GenerateNPCArrayAndSetName("--------?---0--3--", nLevel, oPC);
            }
            if(sCreature == "ENCOUNTER")
            {
                sName = GetRandomName(0, 0, nLevel, ALIGNMENT_NEUTRAL, GetStringArray(sText, 0, "-"));
                sText = SetStringArray(sText, 0, sName, "-");
            }
            SetLocalString(oPaper, "0_Q_VILLAIN", sText);
        }
        else
        {
            nVillainRoll = -1;
            sState = SetStringArray(sState, 2, "2", "-");
        }
        // Chance for Creatures.
        nCreatureRoll = d100();
        if(nVillainRoll == -1 || nCreatureRoll < 50)
        {
            if(sCreature == "")
            {
                nCreatureRoll = d4();
                if(nCreatureRoll = 1) sEncounter = "RANDOM";
                else if(nCreatureRoll = 2) sEncounter = "HUMANOID";
                else if(nCreatureRoll = 3) sEncounter = "ANIMAL";
                else
                {
                    sCreature = "ENCOUNTER";
                    nCreatureRoll = d8();
                    switch(nVillainRoll)
                    {
                        case 1 : sEncounter = "e_bandits"; break;
                        case 2 : sEncounter = "e_drow"; break;
                        case 3 : sEncounter = "e_elementals"; break;
                        case 4 : sEncounter = "e_orcs"; break;
                        case 5 : sEncounter = "e_reptilian"; break;
                        case 6 : sEncounter = "e_spiders"; break;
                        case 7 : sEncounter = "e_undead"; break;
                        case 8 : sEncounter = "e_elementals"; break;
                    }
                }
            }
            sText = GenerateCreatureArray("-" + sCreature + "-" + sEncounter + "--4---", nLevel, lLocation);
            SetLocalString(oPaper, "0_Q_CREATURES", sText);
        }
        else
        {
            nCreatureRoll = -1;
            sState = SetStringArray(sState, 3, "2", "-");
        }
        // Setup the magic item.
        int nRow, nBonusGoldValue, nItemType, nItemRoll = d20();
        string sResRef = "", sBaseItemType = "", sBaseName = "";
        string sPallet, sTextName = "BASENAME";
        switch(nItemRoll)
        {
            case 1  : case 2  : case 3  : case 4  :
            { sName = "ORIGINAL"; sBaseItemType = "133"; sBaseName = "RANDOMTYPE"; break; } // Melee Weapon.
            case 5  : case 6  : case 7  :
            { sName = "ORIGINAL"; sBaseItemType = "137"; sBaseName = "RANDOMTYPE"; break; } // Ranged Weapon.
            case 8  : case 9  : case 10 : case 11 :
            { sName = "ORIGINAL"; sBaseItemType = "141"; sBaseName = "RANDOMTYPE"; break; } // Armor & Shields.
            case 12  : case 13  : case 14  :
            { sName = "ORIGINAL"; sBaseItemType = "147"; sBaseName = "RANDOMTYPE"; break;} // Clothing.
            case 15  : case 16  : case 17  :
            { sName = "ORIGINAL"; sBaseItemType = "148"; sBaseName = "RANDOMTYPE"; break; } // Jewelry.
            case 18 : case 19 :
            {
                nBonusGoldValue = 500;
                sName = "ORIGINAL";
                sTextName = "NAME";
                nItemType = 1;
                sPallet = "wondrous_pallet";
                nRow = RollOn2daTableWithMinItems (sPallet,  nLevel);
                sResRef = Get2DAString (sPallet, "ResRef", nRow);
                break;
            }
            case 20 :
            {
                nBonusGoldValue = 1000;
                sName = "ORIGINAL";
                sTextName = "NAME";
                nItemType = 2;
                sPallet = "special_pallet";
                nRow = RollOn2daTableWithMinItems (sPallet, nLevel);
                sResRef = Get2DAString (sPallet, "ResRef", nRow);
                break;
            }
        }
        //Item Array:(-Name-BaseName-BaseItemType-ResRef-ID-Container_tag-Max_properties-)
        sText = GenerateItemArray("-" + sName + "-" + sBaseName + "-" + sBaseItemType + "-" + sResRef + "---", nLevel, oPaper, oPC);
        if(GetStringLeft(GetStringArray(sText, 0, "-"), 6) == "<cqq�>") sText = SetStringArray(sText, 0, "NORMAL", "-");
        // If a special or wondrous item we need to add the color to the name.
        if(nRow > 0)
        {
            sName = AddColorToText(GetStringArray(sText, 0, "-"), Get2DAString(sPallet, "Name_Color", nRow));
            sText = SetStringArray(sText, 0, sName, "-");
        }
        SetLocalString(oPaper, "0_Q_ITEM", sText);
        // Set the maps gold value based upon the item generated.
        NWNX_Item_SetAddGoldPieceValue(oPaper, (nLevel * 100) + nBonusGoldValue);
        // Set placeable array: -Name-ResRef-ID-Waypoint spawn
        sText = GeneratePlaceableArray("--0_tm_chest---", lLocation, oPaper);
        SetLocalString(oPaper, "0_Q_PLACEABLE", sText);
        // Set the rewards.
        sText = "-------145-as_fanfare_intro--";
        SetLocalString(oPaper, "0_Q_REWARDS", sText);
        // Set Quest State.
        SetLocalString(oPaper, "0_Q_STATE", sState);
        int nTextRoll = d4();
        if(nTextRoll == 1) sText = "This is an old worn out sheet of paper with crude markings upon it.";
        else if(nTextRoll == 2) sText = "This skin parchment was rolled up and bound with a ribbon.";
        else if(nTextRoll == 3) sText = "The paper is well made and very old. The ink is crisp with flecks of gold.";
        else sText = "Wrinkled and burned the markings are hard to make out.";
        nTextRoll = d6();
        if(nTextRoll == 1) sText += " Inspecting closer you notice this is a treasure map!";
        else if(nTextRoll == 2) sText += " Looking over the drawings and text you can determine this reveals the location of a hidden item!";
        else if(nTextRoll == 3) sText += " The ink shows a location filled with monsters and treasure!";
        else sText += " It shows a map with the location to a magical treasure.";
        nTextRoll = d6();
        if(nTextRoll == 1) sText += " The drawings upon the page show where [AREA:NAME] is hidden.";
        else if(nTextRoll == 2) sText += " The name of the location is hard to read but you finally make out [AREA:NAME].";
        else if(nTextRoll == 3) sText += " There is text that states [AREA:NAME] at the top with an x on the map.";
        else sText += " Written upon the side of the map is [AREA:NAME] and an arrow points to it's hiding place.";
        string sQuality;
        if(sBaseItemType != "")
        {
            if(nLevel >= 18) sQuality = "a " + AddColorToText("relic", COLOR_RELIC);
            else if(nLevel >= 12) sQuality = "a " + AddColorToText("legendary", COLOR_LEGENDARY) + " item";
            else if(nLevel >= 6) sQuality = "an " + AddColorToText("exquisite", COLOR_EXQUISITE) + " item";
            else sQuality = "a " + AddColorToText("masterwork", COLOR_MAGIC) + " item";
        }
        else if(nItemType == 1) sQuality = "a " + AddColorToText("wondrous", COLOR_MAGIC) + " item";
        else if(nItemType == 2) sQuality = "a " + AddColorToText("special", COLOR_UNIQUE) + " item";
        nTextRoll = d6();
        if(nTextRoll == 1) sText += " Some writing at the bottom denotes " + sQuality + " with the name [ITEM:" + sTextName + "]!";
        else if(nTextRoll == 2) sText += " Written to the left of the map is " + sQuality + " of great power. A [ITEM:" + sTextName + "] is hidden deep inside.";
        else if(nTextRoll == 3) sText += " Written hastily is the name of " + sQuality + ". The word [ITEM:" + sTextName + "] is circled in blood.";
        else sText += " In large text written over the map is [ITEM:" + sTextName + "] shown to be " + sQuality + "!";
        if(d100() < 50 && nVillainRoll != -1) sText += sVillainText;
        if(d100() < 50 && nCreatureRoll != -1) sText += " Also [CREATURE:NAMES] are noted to be near the area as well.";
        SetDescription(oPaper, ParseQuestTextByPaper(sText, oPaper, oPC));
    }
}
