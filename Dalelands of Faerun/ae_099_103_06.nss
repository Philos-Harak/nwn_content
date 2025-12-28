/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ae_099_103_06
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs on_enter for area 099_103_06.
 - Lets characters with the feat Portal Sensitive know that portals are in the area.
 - All portals should have the tag "Portal"
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
void main()
{
    object oPortal;
    if (GetIsCharacter (OBJECT_SELF) && GetHasFeat (1513 /*Portal Sensitive*/, OBJECT_SELF))
    {
        oPortal = GetNearestObjectByTag ("Portal", OBJECT_SELF, 1);
        if (GetIsObjectValid (oPortal)) SendMessages ("You can feel that there is a portal nearby.", COLOR_GREEN, OBJECT_SELF);
    }
}

