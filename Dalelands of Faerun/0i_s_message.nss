/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_s_message
//////////////////////////////////////////////////////////////////////////////////////////////////////

 Include script for sending messages to files and players on the server.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_server_const"
#include "0i_server_colors"
//#include "nwnx_events"
// Message Color Constants. Colors go from 1 to 10 in order Red/Green/Blue
// Sends an error message to the log file and and an error variable is set
// so Administrators can see the last error, viable name: 0_Error.
// sErrorType is the type of error reported;
//      "BUG REPORT" is a bug report from a player.
//      "DATABASE" is Database errors.
//      "RESREF" is resref errors where an item, placeable, or creature could not spawn.
//      "WAYPOINT" is waypoint errors where a player is not sent the the correct location.
//      "TAG" the tag was not found.
//      "ELC" effective level character error.
//      "ERROR" are all other errors that can happen.
//      "LOGIN" are to show login issues.
// sScriptName is the name of the script calling this function.
// sLineNumber is the line number of the code calling this function.
// sError is the description of the error being sent.
void SetModuleError(string sErrorType, string sScriptName, string sLineNumber, string sError);
// Checks to see what error (if any) is set on the module for an administrator to see.
// Returns the error if its there else returns "".
// NOT BUILT YET!
string GetModuleError();
// Sets up a Message on the module to be sent to the log and/or players.
// sTextColor color of text sent to the players and DM's.
// Use COLOR_*. Where * is WHITE, RED, GREEN, BLUE, GRAY, or YELLOW.
// If iLog is TRUE it will send the message to the log file.
// If iToDMs is TRUE it will send the message to all DM's.
// if oPC is set to a player then they will get the message as well.
// Messages delivered by script should be colored as follows.
// _Debug message = COLOR_WHITE
// Generic messages for the player = COLOR_YELLOW
// Negative messages for the player = COLOR_RED
// Positive messages for the player = COLOR_GREEN
// System messages, things that are not part of Dnd = COLOR_GRAY
// Descriptive in game messages = COLOR_BLUE
void SendMessages(string sMessage, string sTextColor = COLOR_YELLOW, object oPC = OBJECT_INVALID, int iToDMs = FALSE, int iLog = FALSE);
// Used for _debugging. Keeps all the information organized.
// Sends info to first pc if true and sends information to log file.
// sScriptName is the name of the script calling this function.
// sLineNumber is the line number of the code calling this function.
// sError is the description of the error being sent.
void Debug(string sScriptName, string sLineNumber, string sMessage);
// Send the login server message to a player.
// Will display the message once they are logged in and loaded into an area.
// oPC is the player logging in.
void SendServerMessage(object oPC, int iCounter = 1);
// Sends a message to a player after they are logged in and loaded into an area other than the loading area.
// sMessage is the message to deliver.
// sTextColor is MCOLOR_* options.
// oPC is the player logging in.
// iDM also sends it to the DM's.
// iLog also sends it to the logs.
void SendMessageAfterPlayerLoad(string sMessage,object oPC, string sTextColor, int iDM = FALSE, int iLog = FALSE, int iCounter = 1);
// Broadcasts a message based on GetLocalInt (oPC, "0_Broadcast").
// They are color coded: DM - grey, Local - white, Party - green, Global - yellow.
void SendBroadcastMessage(object oPC, string sMessage);

void SetModuleError(string sErrorType, string sScriptName, string sLineNumber, string sError)
{
    object oModule = GetModule ();
    sError = "!!!" + sErrorType + "!!! [" + sScriptName + ":" + sLineNumber + "] " + sError;
    SetLocalString(oModule, "0_Error", sError);
    SendMessageToAllDMs(AddColorToText (sError, COLOR_WHITE));
    sError = StripColorCodes (sError);
    WriteTimestampedLogEntry(sError);
}
void SendMessages(string sMessage, string sTextColor = COLOR_YELLOW, object oPC = OBJECT_INVALID, int bToDMs = FALSE, int bLog = FALSE)
{
    if(bLog)
    {
        sMessage = StripColorCodes (sMessage);
        string sLogPCName = "";
        if(oPC != OBJECT_INVALID) sLogPCName = "(" + GetName(oPC) + ") ";
        WriteTimestampedLogEntry("*** MESSAGE: " + sLogPCName + " " + sMessage);
    }
    sMessage = AddColorToText (sMessage, sTextColor);
    if(oPC != OBJECT_INVALID) SendMessageToPC (oPC, sMessage);
    // If iToDMs is true send message to the DM's online.
    if (bToDMs) SendMessageToAllDMs(sMessage);
}
void Debug(string sScriptName, string sLineNumber, string sMessage)
{
    if(DEBUG_MODE)
    {
        // Create the message.
        sMessage = "(((DEBUG)))[" + sScriptName + " - " + sLineNumber + " ]" + sMessage;
        StripColorCodes(sMessage);
        if(DEBUG_FIRST_PC) SendMessageToPC(GetFirstPC(), AddColorToText (sMessage, COLOR_WHITE));
        WriteTimestampedLogEntry(sMessage);
    }
}
void SendServerMessage(object oPC, int nCounter = 1)
{
    string sNewsMessage = Get2DAString ("News", "Text", 1);
    string sAreaTag = GetTag (GetArea (oPC));
    // Check counter and exit if they have not left limbo within one minute.
    if (nCounter < 5)
    {
        if (sAreaTag == "0_limbo" || sAreaTag == "") DelayCommand (12.0, SendServerMessage (oPC, nCounter  + 1));
        else
        {
            // Title
            SendMessages (Get2DAString ("Messages", "Text", 0), COLOR_WHITE, oPC);
            // Version
            SendMessages (Get2DAString ("Messages", "Text", 1), COLOR_GRAY, oPC);
            // Server Message
            SendMessages (Get2DAString ("Messages", "Text", 2), COLOR_GREEN, oPC);
            // Main News Message
            SendMessages (Get2DAString ("Messages", "Text", 3), COLOR_WHITE, oPC);
            // News Message 2
            string sMessage = Get2DAString ("Messages", "Text", 4);
            if (sMessage != "") SendMessages (sMessage, COLOR_GRAY, oPC);
            // News Message 3
            sMessage = Get2DAString ("Messages", "Text", 5);
            if (sMessage != "") SendMessages (sMessage, COLOR_GRAY, oPC);
            // News Message 4
            sMessage = Get2DAString ("Messages", "Text", 6);
            if (sMessage != "") SendMessages (sMessage, COLOR_GRAY, oPC);
            // News Message 5
            sMessage = Get2DAString ("Messages", "Text", 7);
            if (sMessage != "") SendMessages (sMessage, COLOR_GRAY, oPC);
        }
    }
}
void SendMessageAfterPlayerLoad(string sMessage,object oPC, string sTextColor, int iDM = FALSE, int iLog = FALSE, int iCounter = 1)
{
    string sAreaTag = GetTag (GetArea (oPC));
    if(iCounter < 5)
    {
        if(sAreaTag == "0_limbo" || sAreaTag == "") DelayCommand(15.0, SendMessageAfterPlayerLoad (sMessage, oPC, sTextColor, iDM, iLog, iCounter + 1));
        else
        {
            SendMessages(sMessage, sTextColor, oPC, iDM, iLog);
        }
    }
}
void SendBroadcastMessage(object oPC, string sMessage)
{
    // Get the broadcast mode.
    int iBroadcast = GetLocalInt (oPC, "0_Broadcast");
    // Send the message based on the broadcast selection.
    // DM Private
    if (iBroadcast == 0)
    {
        // Send message to PC and all DM's.
        SendMessages (sMessage, COLOR_GRAY, oPC, TRUE, FALSE);
    }
    // Local
    else if(iBroadcast == 1)
    {
        // Send the message to all within talking distance (30 meters).
        float fDistance;
        int i = 1;
        object oPlayer = GetFirstPC();
        while(GetIsObjectValid(oPlayer))
        {
            if(oPlayer != oPC) fDistance = GetDistanceBetween(oPlayer, oPC);
            else fDistance = 1.0f;
            if(fDistance != 0.0f && fDistance < 31.0f) SendMessages(sMessage, COLOR_WHITE, oPlayer, FALSE, FALSE);
            oPlayer = GetNextPC();
        }
    }
    // Party
    else if(iBroadcast == 2)
    {
        // Send the message to all PC's.
        object oPlayer = GetFirstFactionMember(oPC);
        while(GetIsObjectValid(oPlayer))
        {
            SendMessages(sMessage, COLOR_GREEN, oPlayer, FALSE, FALSE);
            oPlayer = GetNextFactionMember(oPC);
        }
    }
    // Global
    else if(iBroadcast == 3)
    {
        // Send the message to all PC's.
        object oPlayer = GetFirstPC();
        while(GetIsObjectValid(oPlayer))
        {
            SendMessages(sMessage, COLOR_YELLOW, oPlayer, FALSE, FALSE);
            oPlayer = GetNextPC ();
        }
    }
}
