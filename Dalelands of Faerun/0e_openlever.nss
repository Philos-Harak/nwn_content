/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_openlever
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 This will open and close a door or placeable
 with the tag in the variable 0_tag.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_s_message"

void main()
{
    int iCounter;
    string sTag;
    object oTrigger;
    sTag = GetLocalString (OBJECT_SELF, "0_Tag");
    // Is the object on?
    if (GetLocalInt(OBJECT_SELF,"NW_L_AMION") == 0)
    {
        // Turn on.
        PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",1);
        // Unlock and Open all doors with the same tag as the lever.
        iCounter = 1;
        object oObject = GetNearestObjectByTag (sTag, OBJECT_SELF, iCounter);
        while (GetIsObjectValid (oObject))
        {
           AssignCommand(oObject, ActionUnlockObject (oObject));
           AssignCommand(oObject, ActionOpenDoor (oObject));
           iCounter ++;
           oObject = GetNearestObjectByTag (sTag, OBJECT_SELF, iCounter);
        }
    }
    // Animiation is on...
    else
    {
        // Turn animation off.
        PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt(OBJECT_SELF,"NW_L_AMION",0);
        // Close and lock all doors with the same tag as the lever.
        iCounter = 1;
        object oObject = GetNearestObjectByTag (sTag, OBJECT_SELF, iCounter);
        while (GetIsObjectValid (oObject))
        {
           AssignCommand(oObject, ActionCloseDoor (oObject));
           AssignCommand(oObject, ActionLockObject (oObject));
           iCounter ++;
           oObject = GetNearestObjectByTag (sTag, OBJECT_SELF, iCounter);
        }
    }
}

