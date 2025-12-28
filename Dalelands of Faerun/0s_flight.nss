/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_flight
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Ability to move from one location to another via flight.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
void main()
{
    location lTarget = GetSpellTargetLocation();
    vector vCreature, vTarget;
    // If we are below ground then check for line of sight.
    if (!GetIsAreaAboveGround (GetArea (OBJECT_SELF)))
    {
        vCreature = GetPosition (OBJECT_SELF);
        vTarget = GetPositionFromLocation (lTarget);
        // We have line of sight so fly to new location with effects.
        if (LineOfSightVector (vCreature, vTarget)) FlyEffect (OBJECT_SELF, lTarget);
    }
    // Outside you can fly anywhere so fly to new location with effects.
    else FlyEffect (OBJECT_SELF, lTarget);
    // Set a 3 round Cooldown timer for the fly feat.
    DelayCommand (18.0f, IncrementRemainingFeatUses (OBJECT_SELF, 1368));
    DelayCommand (18.0f, IncrementRemainingFeatUses (OBJECT_SELF, 1369));
}
