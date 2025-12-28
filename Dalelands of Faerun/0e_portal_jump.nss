/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_portal_jump
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event of a portal placeable.
 This is useable by Players and NPC's.
 Used to jump players to the variable 0_Waypoint.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_master"
#include "0i_effects"
#include "0i_quest"

void main()
{
    object oUser, oWaypoint;
    float fDelay;
    effect eEffect;
    // Get the user of the Poral.
    oUser = GetLastUsedBy ();
    // Get the waypoint to jump to.
    oWaypoint = GetObjectByTag (GetLocalString (OBJECT_SELF, "0_Waypoint"));
    if (GetIsObjectValid (oWaypoint))
    {
        fDelay = PortalEffect (OBJECT_SELF, oUser);
        DelayCommand (fDelay, AssignCommand (oUser, JumpToObject (oWaypoint)));
    }
    else SetModuleError ("WAYPOINT", "0e_portal_jump", "25", "(0_Waypoint) Variable is not valid for Waypoint!");
}
