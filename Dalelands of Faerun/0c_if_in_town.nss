/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_in_town
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script checks to see what town the conversation is in.
 Param:
 sTown - name of the town to compare against.
 if sTown is None then its TRUE if they are not in a town.
*///////////////////////////////////////////////////////////////////////////////
int StartingConditional()
{
    // Get quest area to check which town we are in.
    object oWaypoint = GetNearestObjectByTag ("ip_area_level", OBJECT_SELF);
    string sTown = GetScriptParam ("sTown");
    string sAreaTown = GetLocalString (oWaypoint, "0_Town_Area");
    if (sAreaTown == sTown) return TRUE;
    else if (sAreaTown == "" && sTown == "None") return TRUE;
    return FALSE;
}
