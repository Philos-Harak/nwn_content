/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_messages
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include script for sending messages to files and players on the server.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_constants"
#include "0i_color"
// Sets up a Message on the module to be sent to the log and/or players.
// sTextColor color of text sent to the players and DM's.
// Use COLOR_*. Where * is WHITE, RED, GREEN, BLUE, GRAY, or YELLOW.
// If nLog is TRUE it will send the message to the log file.
// If nToDMs is TRUE it will send the message to all DM's.
// If oPC is set to a player then they will get the message as well.
// Messages delivered by script should be colored as follows.
// _Debug message = COLOR_WHITE
// Generic messages for the player = COLOR_YELLOW
// Negative messages for the player = COLOR_RED
// Positive messages for the player = COLOR_GREEN
// System messages, things that are not part of Dnd = COLOR_GRAY
// Descriptive in game messages = COLOR_BLUE
void ai_SendMessages(string sMessage, string sTextColor = COLOR_YELLOW, object oPC = OBJECT_INVALID, int nToDMs = FALSE, int nLog = FALSE);
// Used for _debugging. Keeps all the information organized.
// Sends info to first pc if true and sends information to log file.
// sScriptName is the name of the script calling this function.
// sLineNumber is the line number of the code calling this function.
// sMessage is the description of the debug being sent.
void ai_Debug(string sScriptName, string sLineNumber, string sMessage);
// A counter to track microseconds in code. Start saves the counter.
void ai_Counter_Start();
// A counter to track microseconds in code. End displays the time between Start
// and End to the log file.
void ai_Counter_End(string sMessage = "");

void ai_SendMessages(string sMessage, string sTextColor = COLOR_YELLOW, object oPC = OBJECT_INVALID, int nToDMs = FALSE, int nLog = FALSE)
{
    // if nLog is TRUE send the message to the log file.
    if(nLog)
    {
        sMessage = ai_StripColorCodes(sMessage);
        // Add PC name to log to know who it belongs to.
        string sLogPCName;
        if(oPC != OBJECT_INVALID) sLogPCName = "(" + GetName(oPC) + ") ";
        WriteTimestampedLogEntry("*** MESSAGE: " + sLogPCName + " " + sMessage);
    }
    sMessage = ai_AddColorToText(sMessage, sTextColor);
    if(oPC != OBJECT_INVALID) SendMessageToPC(oPC, sMessage);
    // If nToDMs is true send message to the DM's online.
    if(nToDMs) SendMessageToAllDMs(sMessage);
}
void ai_Debug(string sScriptName, string sLineNumber, string sMessage)
{
    return;
    sMessage = "(((DEBUG)))[" + sScriptName + " - " + sLineNumber + " ]" + sMessage;
    sMessage = ai_StripColorCodes(sMessage);
    //WriteTimestampedLogEntry(sMessage);
    //if(GetLocalInt(OBJECT_SELF, "AI_DEBUG")) WriteTimestampedLogEntry(sMessage);
    if(GetName(OBJECT_SELF) == "Druid Master") WriteTimestampedLogEntry(sMessage);
}
void ai_Counter_Start()
{
    SetLocalInt(GetModule(), "0_MSCounter", GetMicrosecondCounter());
}
void ai_Counter_End(string sMessage = "")
{
    int nTime = GetMicrosecondCounter();
    nTime = nTime - GetLocalInt(GetModule(), "0_MSCounter");
    float fTime = nTime / 1000000.0;
    ai_Debug("MICROSECOND_COUNTER", "", "Seconds: " + FloatToString(fTime, 0, 10) +
             " Microseconds: " + IntToString(nTime) + " " + sMessage);
}
