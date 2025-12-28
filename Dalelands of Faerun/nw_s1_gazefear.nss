/*//////////////////////////////////////////////////////////////////////////////
 Gaze: Fear
 NW_S1_GazeFear
////////////////////////////////////////////////////////////////////////////////
 Cone shape that affects all within the AoE if they fail a Will Save.
 Creatures must make a Will save vs Fear DC 10 + Hit die / 2 or be
 Shakened (-2) if the creature is less than 6 hit dice.
 Frightened (-4) if the creature is 6 to 15 hit dice.
 Panicked (-6) if the creature is 16 to 20+ hit dice.
 This effect lasts for 1 round + Hit dice / 3 rounds.
////////////////////////////////////////////////////////////////////////////////
 Created By: Preston Watamaniuk on May 9, 2001
//////////////////////////////////////////////////////////////////////////////*/
#include "0i_spells"
void main()
{
    // Check if the creature is blinded.
    if(GetHasEffect(EFFECT_TYPE_BLINDNESS, OBJECT_SELF))
    {
        FloatingTextStrRefOnCreature(84530, OBJECT_SELF ,FALSE);
        return;
    }
    //Declare major variables
    int nHD = GetHitDice (OBJECT_SELF);
    float fDuration = RoundsToSeconds(1 + (nHD / 3));
    int nDC = 10 + (nHD / 2);
    location lTargetLocation = GetSpellTargetLocation();
    effect eImpact = EffectVisualEffect (VFX_IMP_FEAR_S);
    int nFear;
    int nHitDice = GetHitDice(OBJECT_SELF);
    if(nHitDice < 6) nFear = 2;
    else if(nHitDice < 16) nFear = 4;
    else nFear = 6;
    effect eFear = EffectAttackDecrease(nFear);
    eFear = EffectLinkEffects(EffectSavingThrowDecrease(SAVING_THROW_ALL, nFear), eFear);
    eFear = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, nFear), eFear);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eFear = EffectLinkEffects(eDuration, eFear);
    eFear = EffectLinkEffects(eVisual, eFear);
    float fDelay;
    // Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if (GetIsEnemy(oTarget) && oTarget != OBJECT_SELF)
        {
            // Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt (OBJECT_SELF, SPELLABILITY_GAZE_FEAR));
            // Determine effect delay
            fDelay = GetDistanceBetween (OBJECT_SELF, oTarget) / 20;
            if(!WillSave (oTarget, nDC, SAVING_THROW_TYPE_FEAR, OBJECT_SELF))
            {
                // Apply the VFX impact and effects
                ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
                ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eFear, oTarget, fDuration);
            }
        }
        // Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    }
}

