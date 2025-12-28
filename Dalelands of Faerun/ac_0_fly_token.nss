//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: ac_0_fly_token
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Activate item script for the Fly spells token.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 3/25/15
//////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_effects"

void main()
{
    object oItem = GetItemActivated ();
    object oUser = GetItemActivator ();
    location lTarget = GetItemActivatedTargetLocation();
    vector vCreature, vTarget;
    // Before we can use this item we need to check and see if the user still has the spell effect.
    // If they don't then remove the token and skip flying.
    if (!GetHasSpellEffect (921 /*Fly*/, oUser))
    {
        DestroyObject (oItem);
        SendMessages ("The Fly spell has expired!", COLOR_RED, oUser);
    }
    // Go ahead and fly!
    else
    {
        // If we are below ground then check for line of sight.
        if (!GetIsAreaAboveGround (GetArea (oUser)))
        {
            vCreature = GetPosition (oUser);
            vTarget = GetPositionFromLocation (lTarget);
            // We have line of sight so fly to new location with effects.
            if (LineOfSightVector (vCreature, vTarget)) FlyEffect (oUser, lTarget);
        }
        // Outside you can fly anywhere so fly to new location with effects.
        else FlyEffect (oUser, lTarget);
    }
}
