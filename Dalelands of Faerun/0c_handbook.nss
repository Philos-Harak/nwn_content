/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_handbook
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken quest script that does various tasks based on what the Player has
 selected in the players handbook.
 Param:
 sInput - input to select the function to run.
/*//////////////////////////////////////////////////////////////////////////////
#include "nwnx_player"
#include "0i_character"
void main()
{
    int nValue;
    string sValue, sSelect, sGroup, sGroupSelect;
    location lLocation;
    effect eEffect;
    object oPC = GetPCSpeaker ();
    string sInput = GetScriptParam ("sInput");
    if (sInput == "JumpToCynosure") AssignCommand (oPC, JumpToObject (GetWaypointByTag ("WP_Cynosure")));
    if (sInput == "ToggleDMPC")
    {
        if (GetLocalInt (oPC, "0_DM_STATUS"))
        {
            SendMessages ("You have removed DM status as a player.", COLOR_GRAY, oPC);
            SendMessages (GetName (oPC, TRUE) + " has removed DM status as a player.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            SetLocalInt (oPC, "0_DM_STATUS", FALSE);
            NWNX_Player_ToggleDM (oPC, FALSE);
        }
        else
        {
            SendMessages ("You have gained DM status as a player.", COLOR_GRAY, oPC);
            SendMessages (GetName (oPC, TRUE) + " has gained DM status as a player.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            SetLocalInt (oPC, "0_DM_STATUS", TRUE);
            NWNX_Player_ToggleDM (oPC, TRUE);
        }
    }
    else if (sInput == "SendBugReport") SetLocalString (oPC, "0_Input", "BugReport");
    else if (sInput == "ChangePCDesc")
    {
        string sMessage = GetDescription (oPC);
        SendMessages (sMessage, COLOR_GRAY, oPC);
        SetLocalString (oPC, "0_Input", "ChangePCDesc");
    }
    else if (sInput == "PlayerInformation")
    {
        SetCustomToken (1101, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "characters")));
        SetCustomToken (1102, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "highestlevel")));
        SetCustomToken (1103, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "logins")));
        SetCustomToken (1104, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "rests")));
        SetCustomToken (1105, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "bleeds")));
        SetCustomToken (1106, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "respawns")));
        SetCustomToken (1107, IntToString (GetServerDatabaseInt (oPC, PLAYER_TABLE, "deaths")));
        nValue = GetServerDatabaseInt (oPC, PLAYER_TABLE, "kills") + GetLocalInt (oPC, "0_Kills");
        SetCustomToken (1108, IntToString (nValue));
    }
    else if (sInput == "CharacterInformation")
    {
        SetCustomToken (1101, IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "rests")));
        SetCustomToken (1102, IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "bleeds")));
        SetCustomToken (1103, IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "respawns")));
        SetCustomToken (1104, IntToString (GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "deaths")));
        nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "kills") + GetLocalInt (oPC, "0_Kills");
        SetCustomToken (1105, IntToString (nValue));
        nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "sidequests");
        SetCustomToken (1106, IntToString (nValue));
        nValue = GetObjectDatabaseInt (oPC, CHARACTER_TABLE, "mainquests");
        SetCustomToken (1107, IntToString (nValue));
    }
    else if (sInput == "RemoveMapPins")
    {
        int i = GetLocalInt (oPC, "NW_TOTAL_MAP_PINS");
        string sPinID;
        while (i > 0)
        {
            sPinID = IntToString (i);
            DeleteLocalObject (oPC, "NW_MAP_PIN_AREA_" + sPinID);
            DeleteLocalFloat (oPC, "NW_MAP_PIN_XPOS_" + sPinID);
            DeleteLocalFloat (oPC, "NW_MAP_PIN_YPOS_" + sPinID);
            DeleteLocalString (oPC, "NW_MAP_PIN_NTRY_" + sPinID);
            i --;
        }
    }
}
