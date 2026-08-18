/*/////////////////////////////////////////////////////////////////////////////////// 
 Aura of defense: On Exit
 Created By: Philos
/////////////////////////////////////////////////////////////////////////////////////
    Creatures exiting the zone : remove Aura of Defense.
    Give +1 ac at Paladin 6th+ or +2 ac if Paladins is 13th+ if in this PC's party.
/*/////////////////////////////////////////////////////////////////////////////////// 
#include "0i_effects"
void main()
{
    object oTarget = GetExitingObject();
    object oCaster = GetAreaOfEffectCreator();
    // Check that they are in the party.
    if (GetFactionEqual(oCaster, oTarget))
    {
        RemoveTagedEffects(oTarget, "AURA_OF_DEFENSE" + GetName (oCaster));
    }
}
