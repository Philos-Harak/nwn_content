/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trig_rep
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script when player enters the trigger.
 Variables set on trigger:
 0_Reputation_Needed (Int) the reputation needed to trigger the script.
 0_Script (String) is the script to run.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_character"

void main()
{
    int iReputation, iAreaRep, iRepNeeded;
    string sScript;
    object oPC = GetEnteringObject ();
    // Make sure this is an PC.
    if (GetIsPC (oPC))
    {
        // Get the script to fire.
        sScript = GetLocalString (OBJECT_SELF, "0_Script");
        // Get the reputation needed.
        iRepNeeded = GetLocalInt (OBJECT_SELF, "0_Reputation_Needed");
        iReputation = GetCharacterReputation (oPC);
        // If the Entry is equal or greater than the ID then run the script.
        if (iReputation >= iRepNeeded) ExecuteScript (sScript, OBJECT_SELF);
    }
}

