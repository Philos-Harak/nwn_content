/*////////////////////////////////////////////////
 Detect Evil: On Exit
 Created By: Philos
////////////////////////////////////////////////
    Creatures exiting the zone if evil have the
    highlight removed.
/*///////////////////////////////////////////////
#include "0i_effects"
void main()
{
    object oTarget = GetExitingObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are an ally.
    if (!GetIsEnemy (oTarget, oCaster))
    {
        // Remove VFX from target.
        RemoveTagedEffects (oTarget, "FAMILY_PROT" + GetName (oCaster));
    }
}
