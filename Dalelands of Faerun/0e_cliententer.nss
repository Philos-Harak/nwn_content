/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_cliententer
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the client enters the server.
 This is the code for setting up a player.
 Players status:
 -1 Banned and cannot play as that player.
 0  A normal player.
 1  A player with benefits.
 2  A player with benefits and shout ability.
 3  A trial DM - limited abilities.
 4  A normal DM - all base DM abilities.
 5  An administrator - complete access to server.
 See 0e_pcloaded for the code that sets up a character of a player.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_win_layout_dm"
#include "0i_win_layout_pc"

void main ()
{
    object oPlayer = GetEnteringObject();
    CheckServerDataAndInitialize(oPlayer, PLAYER_TABLE);
    // ***** Check CD keys for non-administrators *****
    int nStatus = GetServerDatabaseStatusByCDKey(oPlayer);
    if(nStatus < 5)
    {
        string sPublicCDKey = GetServerDatabaseString(oPlayer, PLAYER_TABLE, "publiccdkey");
        string sLoginCDKey = GetPCPublicCDKey(oPlayer);
        if(sPublicCDKey != sLoginCDKey)
        {
            BootPC(oPlayer, "Your player name has a different CD linked to it! Please contact an Administrator.");
            SetModuleError("LOGIN", "0e_cliententer", "32", GetPCPlayerName(oPlayer) +
                           " has tried to log in with " + sLoginCDKey + " CDkey, but this player uses " + sPublicCDKey + " CD key!");
            return;
        }
    }
    // ********* Run all code for DM's. ***********
    if(GetIsDM(oPlayer))
    {
        if(nStatus < 3)
        {
            BootPC(oPlayer, "You do not have Dungeon Master level access! Please contact an Administrator");
            SetModuleError("LOGIN", "0e_cliententer", "43", GetPCPlayerName(oPlayer) +
                           " has tried to log in as a DM. They do not have access and were booted!");
            SendMessages(GetPCPlayerName(oPlayer) + " has tried to log in as a DM. They do not have access and were booted!", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            return;
        }
        else
        {
             if(nStatus == 3) SendMessages(GetPCPlayerName(oPlayer) + " is logging in with " +
                 GetName(oPlayer) + " as a Level 3: Trial DM status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
             if(nStatus == 4) SendMessages(GetPCPlayerName(oPlayer) + " is logging in with " +
                 GetName(oPlayer) + " as a Level 4: Full DM status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
             if(nStatus == 5) SendMessages(GetPCPlayerName(oPlayer) + " is logging in with " +
                 GetName(oPlayer) + " as a Level 3: Full Administration status.", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
        }
        // Make sure the DM database is initialized.
        CheckServerDataAndInitialize(oPlayer, DM_TABLE);
        IncreaseServerDatabaseCounter(oPlayer, PLAYER_TABLE, "dmlogins");
        PopUpDMGUIPanel(oPlayer);
    }
    // ********* Run code for PC's. ***********
    else
    {
        // Check to see if this player is banned.
        if(nStatus == -1)
        {
            BootPC(oPlayer, "You have been banned from the server! Please contact an Administrator.");
            SetModuleError("LOGIN", "0e_cliententer", "69", GetPCPlayerName(oPlayer) +
                           " has tried to log in but has been banned!");
            SendMessages("!!! LOGIN ISSUE!!!" + GetPCPlayerName (oPlayer) + " has tried to log in but have been banned!", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
            return;
        }
        SetServerDatabaseString(oPlayer, PLAYER_TABLE, "lastipaddress", GetPCIPAddress (oPlayer));
        PopUpSmallGUIPanel(oPlayer);
    }
    IncreaseServerDatabaseCounter(oPlayer, PLAYER_TABLE, "logins");
}

