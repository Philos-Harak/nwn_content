/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigjump
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 On Enter Event script that will jump the entering player to a waypoint with the proper tag.
 Variables
 0_Transition - The waypoint tag to transition the player to.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
void main ()
{
    string sWPTag;
    object oWayPoint, oPC = GetEnteringObject ();
    // Make sure this is an PC.
    if (GetIsPC (oPC))
    {
        // Get the waypoint tag.
        sWPTag = GetLocalString (OBJECT_SELF, "0_Transition");
        oWayPoint = GetObjectByTag (sWPTag);
        AssignCommand (oPC, JumpToObject (oWayPoint));
    }
}

