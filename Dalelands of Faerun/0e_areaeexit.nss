/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_areaeexit
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the character exits an area.
 OBJECT_SELF is the area entered.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_area"
#include "0i_character"
#include "0i_datetime"
void main ()
{
    object oCreature = GetExitingObject();
    if(GetIsCharacter(oCreature))
    {
        Debug("0e_areaexit", "16", "NumOfPlayersInArea: " + IntToString(NWNX_Area_GetNumberOfPlayersInArea(OBJECT_SELF)));
        if(NWNX_Area_GetNumberOfPlayersInArea(OBJECT_SELF) == 0)
        {
            object oWaypoint = GetObjectInAreaByTag(OBJECT_SELF, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
            location lLocation = GetLocation(oWaypoint);
            object oObject = CreateObject(OBJECT_TYPE_PLACEABLE, "0_clear_area", lLocation);
            SetLocalInt (oObject, "0_Clear_Time", SQLite_GetTimeStamp());
            SetLocalInt (GetModule (), "0_Clear_Objects", GetLocalInt (GetModule (), "0_Clear_Objects") + 1);
            Debug ("0e_areaexit", "24", "oArea: " + GetName (OBJECT_SELF) + " (" + GetTag (OBJECT_SELF) +
                   ") Created " + GetName (oObject) + "[" + IntToString (GetLocalInt (GetModule (), "0_Clear_Objects")) +
                   "] due to " + GetName (oCreature) + " leaving.");
        }
        else
        {
            Debug ("0e_areaexit", "29", "oArea: " + GetName (OBJECT_SELF) + " (" +
                   GetTag (OBJECT_SELF) + ") still has " +
                   IntToString (NWNX_Area_GetNumberOfPlayersInArea (OBJECT_SELF)) + " number of players!");
        }
    }
    // Clear Auras variables when exiting an area. Keeps Auras from hitting multiple times.
    DeleteLocalString (OBJECT_SELF, "0_AURA_FEAR");
    DeleteLocalString (OBJECT_SELF, "0_AURA_HORRIFIC_APPEARANCE");
    // Run a specific script for the area exited. Use the areas tag.
    SetLocalObject (OBJECT_SELF, "0_EXITING_CREATURE", oCreature);
    ExecuteScript ("ax_" + GetTag (OBJECT_SELF), OBJECT_SELF);
}

