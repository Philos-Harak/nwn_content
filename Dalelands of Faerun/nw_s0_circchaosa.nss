/*////////////////////////////////////////////////
 Script: nw_s0_circchaosa
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
    Add basic protection effects to entering allies.
/*///////////////////////////////////////////////
#include "NW_I0_SPELLS"
void main()
{
    object oTarget = GetEnteringObject ();
    if (GetIsFriend (oTarget, GetAreaOfEffectCreator ()))
    {
        effect eAC = EffectACIncrease (2, AC_DEFLECTION_BONUS);
        eAC = VersusAlignmentEffect (eAC, ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
        effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, 2);
        eSave = VersusAlignmentEffect (eSave, ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
        effect eImmune = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
        eImmune = VersusAlignmentEffect (eImmune,ALIGNMENT_CHAOTIC, ALIGNMENT_ALL);
        effect eVisual = EffectVisualEffect (VFX_DUR_PROTECTION_EVIL_MINOR);
        effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects (eImmune, eSave);
        eLink = EffectLinkEffects (eLink, eAC);
        eLink = EffectLinkEffects (eLink, eDuration);
        eLink = EffectLinkEffects (eLink, eVisual);
        //Fire cast spell at event for the specified target
        SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, SPELL_MAGIC_CIRCLE_AGAINST_CHAOS, FALSE));
        //Apply the effects
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eLink, oTarget);
     }
}
