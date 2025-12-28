/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Name: 0e_bashcontain
 Made By: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Uses the following placeable variables when ever the placeable is destroyed.
 0_CreatePlaceable (0_wooden_rubble) is a placeable used to create on the location of the current object.
 0_Effect (Delay_Explosion) is the file name of an effect to be generated on the location, must work on location.
 0_PlaySound (as_cv_woodbreak2) will have the object play a sound.
 0_Has_Treasure (False) rolls for treasure.
 Checks to see if any items were broken.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_treasure"
#include "0i_items"
#include "0i_effects"

void main ()
{
    // Define variables.
    effect eEffect;
    int iTreasure, iUsed, iEffect;
    location lLocation = GetLocation (OBJECT_SELF);
    string sSound, sCreatePlaceable;
    // Play a sound. Defaults to wood breaking.
    sSound = GetLocalString (OBJECT_SELF, "0_PlaySound");
    if (sSound == "") sSound = "as_cv_woodbreak2";
    PlaySound (sSound);
    // Create a placeable. Defaults to wooden rubble.
    sCreatePlaceable = GetLocalString (OBJECT_SELF, "0_CreatePlaceable");
    if (sCreatePlaceable == "") sCreatePlaceable = "0_wooden_rubble";
    CreateObject (OBJECT_TYPE_PLACEABLE, sCreatePlaceable, lLocation);
    // Run special effect. Defaults to dust explosion.
    iEffect = GetLocalInt (OBJECT_SELF, "0_Effect");
    if (iEffect == 0) iEffect = VFX_IMP_DUST_EXPLOSION;
    eEffect = EffectVisualEffect (iEffect);
    DelayCommand (0.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eEffect, lLocation));
    // Check to make sure the object has not already given out treasure.
    iUsed = GetLocalInt (OBJECT_SELF, "0_Used");
    if (!iUsed)
    {
        ExecuteScript ("0e_rolltreasure", OBJECT_SELF);
        // break anything that needs to be broken.
        CheckForBrokenItems (OBJECT_SELF);
    }
}

