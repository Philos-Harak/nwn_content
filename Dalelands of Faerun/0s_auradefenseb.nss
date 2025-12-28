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
    // Check that they are in the party.
    if (GetFactionEqual (oCaster, oTarget))
    {
        // Remove VFX from target.
        RemoveTagedEffects (oTarget, "AURA_OF_DEFENSE" + GetName (oCaster));
    }
}
