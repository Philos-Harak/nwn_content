/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_areaenter
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when creatures enter an area.
 OBJECT_SELF is the area entered.
 ** Player character only code. **
 1) a) Check to see if they have relogged into the server without the server going down.
       (Used to reset player settings.)
    b) Clear the placeable that was set to clear the area.
 2) Check to see if a DM has locked settings and let all players know.
    ** Players, Not DM code. **
    a) Check for quests in the area on every enter.
    b) If not populated then populate area, check weather, and check lights.
    c) Save character data.
 3) Send difficulty message.
 ** Saves character data.
 ** Checks for on enter area tag scripts to be run.
 ** Populates an area for the player.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_henchmen"
#include "0i_area"
#include "0i_effects"
#include "0i_quest"
void main ()
{
    int bPopulated;
    object oArea = OBJECT_SELF;
    object oWaypoint, oCreature = GetEnteringObject();
    // Let them know of any area changes by a DM.
    if(GetIsCharacter(oCreature))
    {
        // First check to see if this is the first area loaded for a character entering the server.
        // If the server has not restarted then they will not go through limbo to run 0e_pcloaded.
        if(!GetLocalInt (oCreature, "0_Character_Loaded")) ExecuteScript("0e_pcloaded", oCreature);
        Debug("0e_areaenter", "37", "NumOfPlayersInArea: " + IntToString(NWNX_Area_GetNumberOfPlayersInArea(oArea)));
        // Remove the clear area heartbeat placeable this area must wait another 30 minutes to clear.
        object oClearArea = GetObjectInAreaByTag(oArea, "0_clear_area", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        if(oClearArea != OBJECT_INVALID)
        {
            SetLocalInt(GetModule(), "0_Clear_Objects", GetLocalInt(GetModule(), "0_Clear_Objects") - 1);
            Debug("0e_areaenter", "40", "Area: " + GetName(OBJECT_SELF) + " (" + GetTag(OBJECT_SELF) +
                   ") Destroy " + GetName(oClearArea) + "[" + IntToString(GetLocalInt(GetModule(), "0_Clear_Objects")) +
                   "] due to " + GetName(oCreature) + " entering.");
            DestroyObject(oClearArea);
        }
        if(GetLocalInt(oArea, "0_PopulateOFF")) SendMessages("A DM has turned spawning off in this area.", COLOR_GRAY, oCreature, FALSE, FALSE);
        if(GetLocalInt(oArea, "0_LootOFF")) SendMessages("A DM has turned loot off in this area.", COLOR_GRAY, oCreature, FALSE, FALSE);
        if(GetLocalInt(oArea, "0_XPOFF")) SendMessages("A DM has turned xp off in this area.", COLOR_GRAY, oCreature, FALSE, FALSE);
        if(GetLocalInt(oArea, "0_Spell_Dead_Magic_Zone"))
        {
            if(GetHighestArcaneCasterClass(oCreature) > 0)
            {
                SendMessages("You feel uncomfortable, this is a dead magic area!", COLOR_GRAY, oCreature, FALSE, FALSE);
            }
        }
        if(GetLocalInt(oArea, "0_CleanOFF")) SendMessages("A DM has turned cleaning systems off in this area.", COLOR_GRAY, oCreature, FALSE, FALSE);
        // Run all code for DM's!
        if(GetIsDungeonMaster(oCreature)) SaveDMData(oCreature);
        // Run all code for PC's.
        else if(GetIsCharacter(oCreature))
        {
            if(!GetLocalInt(oArea, "0_PopulateOFF"))
            {
                CheckPCQuestIDsByArea(oCreature, oArea);
                // First lets make sure the area is not populated.
                if(!GetLocalInt(oArea, "0_Populated"))
                {
                    bPopulated = TRUE;
                    // Populates the area entered.
                    PopulateArea(oArea, oCreature);
                    // Check the lighting.
                    CheckLights(oArea);
                }
            }
            // Always save characters information.
            SaveCharacterData(oCreature);
            SaveAssociatesToDatabase(oCreature, FALSE);
            if(GetHasSpellEffect(934/*SPELL_FIND_THE_PATH*/, oCreature)) TrackQuests(oCreature,OBJECT_INVALID);
        }
        SendDifficultyMessage(oCreature, oArea);
    }
    // Run a specific script for the area entered. Use the areas tag.
    SetLocalObject(oArea, "0_ENTERING_CREATURE", oCreature);
    ExecuteScript("ae_" + GetTag (oArea));
    DeleteLocalObject(oArea, "0_ENTERING_CREATURE");
    if(bPopulated) SetLocalInt(oArea, "0_Populated", TRUE);
}

