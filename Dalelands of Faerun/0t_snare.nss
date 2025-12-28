/*////////////////////////////////////////////////
 Script: 0t_snare
 Programmer: Philos
//////////////////////////////////////////////////
As per the snare spell.
/*///////////////////////////////////////////////
#include "0i_checks"
void main()
{
    object oTarget = GetEnteringObject();
    effect eEntangle = EffectEntangle ();
    effect eDuration = EffectVisualEffect (VFX_DUR_ENTANGLE);
    effect eLink = EffectLinkEffects (eEntangle, eDuration);
    if (GetSkillCheck (oTarget, 3/*SKILL_ATHLETICS*/, FALSE, 0, 23) < 0)
    {
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
    }
}
