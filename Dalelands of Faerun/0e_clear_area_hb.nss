/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_clear_area_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event script that runs every 6 seconds counting down to clear the current area.
 OBJECT_SELF is the placeable.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_area"
#include "0i_datetime"
#include "0i_spawn"
// Constant for how long to wait to clear an area in seconds 1800 is 30 minutes.
const int CLEAR_AREA_TIME = 1800;
void main()
{
    // Check the time and see if we should clear the area.
    int nCurrentTime = SQLite_GetTimeStamp();
    int nStartTime = GetLocalInt(OBJECT_SELF, "0_Clear_Time");
    //Debug("0e_clear_area_hb", "18", "oArea: " + GetName(GetArea(OBJECT_SELF)) + " Current Time: " + IntToString(nCurrentTime) +
    //       " Start Time: " + IntToString(nStartTime));
    if(nCurrentTime - nStartTime > CLEAR_AREA_TIME)
    {
        object oArea = GetArea(OBJECT_SELF);
        DestroyObject(OBJECT_SELF);
        //SetLocalInt (GetModule (), "0_Clear_Objects", GetLocalInt (GetModule (), "0_Clear_Objects") - 1);
        //Debug ("0e_clear_area_hb", "25", "Area: " + GetName (oArea) + " (" + GetTag (oArea) +
        //       ") Destroy " + GetName (OBJECT_SELF) + "[" + IntToString (GetLocalInt (GetModule (), "0_Clear_Objects")) +
        //       "] due to area being cleared.");
        // Is cleaning turned off by the DM?
        if(GetLocalInt(oArea, "0_CleanOFF")) return;
        ClearArea(oArea);
    }
}
