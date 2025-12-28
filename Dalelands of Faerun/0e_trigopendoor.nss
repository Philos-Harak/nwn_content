/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigopendoor
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for trigger to open the closest door from trigger by using an NPC.
 Looks for the following variables on the trigger.
 0_NPC - the tag of the NPC that should open the door.
 0_Dialog - the dialog the speaker will say. If blank then it will default to "Open the door."

 If there is no opener tag then the trigger will just open the door.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void OpenDoor (object oNPC, object oDoor, object oTrigger)
{
    string sDialog = GetLocalString (oTrigger, "0_Dialog");
    if (sDialog == "") sDialog = "Hold on, I'll open the door.";
    AssignCommand (oNPC, SpeakString (sDialog));
    SetLocked (oDoor, FALSE);
    AssignCommand (oNPC, ClearAllActions ());
    AssignCommand (oNPC, ActionOpenDoor (oDoor));
}

void main ()
{
    object oPC = GetEnteringObject ();
    if (GetIsCharacter (oPC))
    {
        object oDoor = GetNearestObject (OBJECT_TYPE_DOOR, OBJECT_SELF);
        if (!GetIsOpen (oDoor))
        {
            string sNPC = GetLocalString (OBJECT_SELF, "0_NPC");
            if (sNPC == "")
            {
                SetLocked (oDoor, FALSE);
                AssignCommand (oDoor, ActionOpenDoor (oDoor));
            }
            else
            {
                object oNPC = GetNearestObjectByTag (sNPC, OBJECT_SELF);
                OpenDoor (oNPC, oDoor, OBJECT_SELF);
            }
        }
    }
}

