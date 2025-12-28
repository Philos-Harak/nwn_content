/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_dm_guide
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script for the DM guide.
 Param:
 sInput - input to run specific functions.
*///////////////////////////////////////////////////////////////////////////////
void main()
{
    object oPC = GetPCSpeaker ();
    string sInput = GetScriptParam ("sInput");
    if (sInput == "JumpToCynosure") AssignCommand (oPC, JumpToObject (GetWaypointByTag ("WP_Cynosure")));
    else if (sInput == "SendBugReport") SetLocalString (oPC, "0_Input", "BugReport");
}
