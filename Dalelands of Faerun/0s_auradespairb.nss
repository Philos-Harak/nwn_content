/*////////////////////////////////////////////////
 Aura of despair: On Exit
 Created By: Philos
////////////////////////////////////////////////
    Creatures exiting the zone : Remove effect.
    Enemies get -2 penalty on all Saving Throws.
/*///////////////////////////////////////////////
#include "0i_effects"
void main()
{
    object oTarget = GetExitingObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are an enemy.
    if (!GetIsEnemy(oTarget, oCaster))
    {
        // Remove VFX from target.
        RemoveTagedEffects (oTarget, "AURA_OF_DESPAIR" + GetName (oCaster));
    }
}
