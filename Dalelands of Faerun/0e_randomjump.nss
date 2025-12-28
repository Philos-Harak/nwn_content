/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_randomjump
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 On Use Event script that will randomly jump the entering player to a waypoint with the same tag.
 Each object must have same tag with an index.
 Such as TagObject_1 to TagObject_5 with 0_Index = 5 on each one.
 Variables
 0_Index - The number of objects to jump between with the same tag.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_area"
void main ()
{
    object oPC = GetLastUsedBy ();
    // Make sure this is an PC.
    if (GetIsPC (oPC))
    {
        // Get the waypoint tag.
        int iIndex = GetLocalInt(OBJECT_SELF, "0_Index");
        string sTag = GetTag (OBJECT_SELF);
        int nStrLength = GetStringLength (sTag);
        sTag = GetStringLeft (sTag, nStrLength - 2);
        object oWayPoint = GetObjectByTag (sTag + "_" + IntToString (Random (iIndex) + 1));
        float fDelay = PortalEffect (OBJECT_SELF, oPC);
        DelayCommand (fDelay, AssignCommand (oPC, JumpToObject (oWayPoint)));
        MoveAssociates (oPC, oWayPoint);
    }
}

