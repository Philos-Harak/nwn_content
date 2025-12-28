/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_disarmtrap
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event that fires when someone disarms a trap on a door, placeable, or trigger.
 Gives a small experience bonus for disarming it.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
void main ()
{
    int nXP = GetTrapDisarmDC (OBJECT_SELF);
    int nCR = GetLocalInt (GetArea (OBJECT_SELF), "0_Area_Level");
    // Lets give the xp out as long as a creature unlocked it.
    if (!GetLocalInt (OBJECT_SELF, "0_NoDisableXP"))
    {
        GiveAreaXP (OBJECT_SELF, IntToFloat (nXP) + BASE_DISARM_TRAP_XP, IntToFloat (nCR));
    }
    DeleteLocalInt (OBJECT_SELF, "0_NoDisableXP");
}

