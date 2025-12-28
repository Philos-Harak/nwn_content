/*////////////////////////////////////////////////
 Grease: On Enter
 Created By: Preston Watamaniuk
////////////////////////////////////////////////
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "X2_inc_switches"

void main()
{
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow = EffectMovementSpeedDecrease(50);
    effect eLink = EffectLinkEffects(eVis, eSlow);
    object oTarget = GetEnteringObject();
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) &&
      (!GetCreatureFlag (oTarget, CREATURE_VAR_IS_INCORPOREAL)) )
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(GetAreaOfEffectCreator(), SPELL_GREASE));
        // This area of effect makes anyone in the area move at 1/2 movement.
        // The heartbeat script checks to see if they fall down.
        // Apply reduced movement effect and VFX_Impact
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
}
