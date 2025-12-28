/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_portalexplode
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnDamage event script for placeable (Portal).
 When a portal is damaged it is destroyed and explodes!
*/////////////////////////////////////////////////////////////////////////////////////////////////////

#include "0i_effects"

void main()
{
    int iDmg, iLevel;
    object oArea;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION);
    effect eImp = EffectVisualEffect(VFX_IMP_MAGBLUE);
    effect eDmg;
    // Get area level.
    oArea = GetArea (OBJECT_SELF);
    iLevel = GetLocalInt (oArea, "0_Area_Level");
    // Get the portal location.
    location lLocation = GetLocation (OBJECT_SELF);
    //Apply the explosion at the location captured above.
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eExplode, lLocation);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape (SHAPE_SPHERE, 30.0f, lLocation, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    // Cycle through the targets within the shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        // Get the distance between the explosion and the target to calculate delay
        fDelay = GetDistanceBetweenLocations (lLocation, GetLocation(oTarget)) / 20;
        //Roll damage for each target
        iDmg = d6(iLevel);
        //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
        iDmg = GetReflexAdjustedDamage (iDmg, oTarget, 10 + iLevel, SAVING_THROW_TYPE_NEGATIVE);
        //Set the damage effect
        eDmg = EffectDamage (iDmg, DAMAGE_TYPE_NEGATIVE);
        if(iDmg > 0)
        {
            // Apply effects to the currently selected target.
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget));
            //This visual effect is applied to the target object not the location as above.
            // This visual effect represents the burst that erupts on the target not on the ground.
            DelayCommand (fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oTarget));
        }
       //Select the next target within the shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, 30.0f, lLocation, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}

