/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_clientleave
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the client leaves the server.
 Notes: Can save variables to the player.
        Variables left on player:
        0_Character_Loaded - Defines that the character is loaded and character on load script has fired. (0e_areaenter)
        0_Healing_Kit - Defines if the character has had a healing kit used on them.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_henchmen"
#include "0i_webhook"
void main ()
{
    // Get exiting player.
    object oPC = OBJECT_SELF;
    // Players who log in but cancel from the character selection screen run this
    // event. We need to ignore them.
    if(oPC == OBJECT_INVALID) return;
    SetCommandable(TRUE, oPC);
    object oArea = GetArea(oPC);
    //Debug ("0e_clientleave", "26", "oArea: " + GetName (oArea) +
    //       " (" + GetTag (oArea) + ") " + GetName (oPC) + " is leaving.");
    if(GetIsPlayerDM(oPC)) NWNX_Player_ToggleDM(oPC, FALSE);
    if(GetIsCharacter(oPC))
    {
        Debug("0e_clientleave", "28", "NumOfPlayersInArea: " + IntToString(NWNX_Area_GetNumberOfPlayersInArea(oArea) - 1));
        if(NWNX_Area_GetNumberOfPlayersInArea(oArea) - 1 == 0)
        {
            // Setup the Clearing placeable.
            object oWaypoint = GetObjectInAreaByTag (OBJECT_SELF, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
            location lLocation = GetLocation (oWaypoint);
            object oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_clear_area", lLocation);
            SetLocalInt(oObject, "0_Clear_Time", SQLite_GetTimeStamp());
            SetLocalInt(GetModule (), "0_Clear_Objects", GetLocalInt(GetModule(), "0_Clear_Objects") + 1);
            Debug("0e_clientleave", "37", "oArea: " + GetName(oArea) + " (" + GetTag(oArea) +
                   ") Created " + GetName(oObject) + "[" + IntToString (GetLocalInt(GetModule(), "0_Clear_Objects")) +
                   "] due to " + GetName(OBJECT_SELF) + " leaving server.");
        }
        // Clear any temp variables on a player.
        // Only used if the server is not reset.
        DeleteLocalInt(oPC, "0_Character_Loaded");
        // Remove that the healing kit has been used on them. Used in healing kit script.
        DeleteLocalInt(oPC, "0_healing_kit");
        // Remove any armor bonus from spells.
        DeleteLocalInt(oPC, "0_Armor_Bonus");
        // Save character information to the database regardless of time.
        if(!GetLocalInt(oPC, "0_CHAR_DELETED"))
        {
            SaveCharacterData(oPC, TRUE);
            SaveAssociatesToDatabase(oPC, TRUE);
        }
    }
    else if(GetIsDM(oPC))
    {
        int nStatus = GetServerDatabaseInt(oPC, PLAYER_TABLE, "status");
        if(nStatus == 3) SendMessages(GetPCPlayerName(oPC) + " is logging off with " +
            GetName(oPC) + " as a Level 3: Trial DM status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
        if(nStatus == 4) SendMessages(GetPCPlayerName(oPC) + " is logging off with " +
            GetName(oPC) + " as a Level 4: Full DM status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
        if(nStatus == 5) SendMessages(GetPCPlayerName(oPC) + " is logging off with " +
            GetName(oPC) + " as a Level 3: Full Administration status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
        // Only used if the server is not reset.
        DeleteLocalInt(oPC, "0_Character_Loaded");
        SaveDMData(oPC, TRUE);
    }
    if(!GetLocalInt(oPC, "0_DELETED")) SendPlayerLogToDiscord (oPC, TEXT_PLAYER_LOG_OUT);
}

