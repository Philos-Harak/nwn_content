/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigclosedoor
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for trigger to close the closest door from trigger by using an NPC.
 Looks for the following variables on the trigger.
 0_NPC - the tag of the creature that should close the door.
 0_Lock - if True it will lock it as well.
 If there is no NPC tag then the trigger will just close the door in 15 seconds.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void CloseDoor (string sNPC, int bLock, object oDoor)
{
    if (GetIsOpen (oDoor) && sNPC == "")
    {
        // Now close it.
        AssignCommand (oDoor, ActionCloseDoor (oDoor));
        if (bLock) DelayCommand (15.0f, AssignCommand (oDoor, ActionLockObject (oDoor)));
    }
    else
    {
        // Get the closest NPC with this tag.
        object oNPC = GetNearestObjectByTag (sNPC, OBJECT_SELF);
        // Now close it.
        AssignCommand (oNPC, ClearAllActions ());
        AssignCommand (oNPC, ActionCloseDoor (oDoor));
        if (bLock) AssignCommand (oDoor, ActionLockObject (oDoor));
    }
}

void main ()
{
    object oPC = GetEnteringObject ();
    if (GetIsCharacter (oPC))
    {
        object oDoor = GetNearestObject (OBJECT_TYPE_DOOR, OBJECT_SELF);
        if (GetIsOpen (oDoor))
        {
            string sNPC = GetLocalString (OBJECT_SELF, "0_NPC");
            int bLock = GetLocalInt (OBJECT_SELF, "0_Lock");
            DelayCommand (15.0f, CloseDoor (sNPC, bLock, oDoor));
        }
    }
}

