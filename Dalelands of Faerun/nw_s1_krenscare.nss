/*//////////////////////////////////////////////////////////////////////////////
 Krenshar Fear Stare
 NW_S1_KrenScare
////////////////////////////////////////////////////////////////////////////////
 Causes those in the gaze to be frightened (-4 penalty to attacks, saves, and
 skill checks.
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void main()
{
    effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
    effect eFrightened = EffectAttackDecrease(2);
    eFrightened = EffectLinkEffects(EffectSavingThrowDecrease(SAVING_THROW_ALL, 4), eFrightened);
    eFrightened = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 4), eFrightened);
    effect eShaken = EffectAttackDecrease(2);
    eShaken = EffectLinkEffects(EffectSavingThrowDecrease(SAVING_THROW_ALL, 2), eShaken);
    eShaken = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 2), eShaken);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eShaken = EffectLinkEffects(eDuration, eShaken);
    eShaken = EffectLinkEffects(eVisual, eShaken);
    int nSave;
    float fDelay;
    location lLocation = GetSpellTargetLocation ();
    // Get first target in the spell cone.
    object oTarget = GetFirstObjectInShape (SHAPE_SPELLCONE, 10.0, lLocation, TRUE);
    while (GetIsObjectValid (oTarget))
    {
        if (GetIsEnemy (oTarget))
        {
            fDelay = GetDistanceToObject(oTarget) / 20;
            // Fire cast spell at event for the specified target.
            SignalEvent (oTarget, EventSpellCastAt (OBJECT_SELF, SPELLABILITY_KRENSHAR_SCARE));
            nSave = WillSave (oTarget, 12, SAVING_THROW_TYPE_FEAR);
            if (!nSave)
            {
                // Apply the linked effects and the VFX impact.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFrightened, oTarget, 18.0));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            }
            else if (nSave != 2)
            {
                // Apply the linked effects and the VFX impact.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShaken, oTarget, 6.0));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
            }
        }
        // Get next target in the spell cone.
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lLocation, TRUE);
    }
}
