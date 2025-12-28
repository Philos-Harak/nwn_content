/*//////////////////////////////////////////////////////////////////////////////
 Script:0c_if_pl_status
 Programmer:Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears when script that checks the PCSpeakers Player status.
 Example: sQualifier > iStatus 5 is if (PCStatus > Status) return TRUE.
 Params:
 sQualifier - set to either "==", "!=", ">", "<".
 nStatus - set from -1 to 5.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_database"
int StartingConditional ()
{
    object oPC = GetPCSpeaker ();
    int nParamStatus = StringToInt (GetScriptParam ("nStatus"));
    string sQualifier = GetScriptParam ("sQualifier");
    int nPCStatus = GetServerDatabaseInt (oPC, PLAYER_TABLE, "status");
    if (sQualifier == "==") { if (nPCStatus == nParamStatus) return TRUE;}
    if (sQualifier == "!=") { if (nPCStatus != nParamStatus) return TRUE;}
    else if (sQualifier == ">") { if (nPCStatus > nParamStatus) return TRUE;}
    else if (sQualifier == "<") { if (nPCStatus < nParamStatus) return TRUE;}
    return FALSE;
}
