//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Fear ability
//:: x3_s2_pdk_fear.nss
//:://////////////////////////////////////////////
//:: Identical to the Fear Spell, except it uses the PDK's character level
//:://////////////////////////////////////////////
//:: Created By: Stratovarius updated by Philos
//:://////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // Declare/assign major variables.
    float fDelay;
    int nSave, nCasterLevel = GetHitDice(OBJECT_SELF);
    float fDuration = RoundsToSeconds(nCasterLevel);
    effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
    effect eFrightened = EffectAttackDecrease(6);
    eFrightened = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 6), eFrightened);
    eFrightened = EffectLinkEffects(EffectSkillDecrease(SKILL_ALL_SKILLS, 6), eFrightened);
    effect eShaken = EffectAttackDecrease (2);
    eShaken = EffectLinkEffects (EffectSavingThrowDecrease (SAVING_THROW_ALL, 2), eShaken);
    eShaken = EffectLinkEffects (EffectSkillDecrease (SKILL_ALL_SKILLS, 2), eShaken);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    eShaken = EffectLinkEffects(eDuration, eShaken);
    eShaken = EffectLinkEffects(eVisual, eShaken);
    eFrightened = EffectLinkEffects(eDuration, eFrightened);
    eFrightened = EffectLinkEffects(eVisual, eFrightened);
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation(), TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(GetIsEnemy(oTarget, OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_FEAR));
            // Make SR Check
            if (!ResistSpell(OBJECT_SELF, oTarget))
            {
                fDelay = GetRandomDelay();
                // Make a will save
                nSave = WillSave(oTarget, GetSpellSaveDC(), SAVING_THROW_TYPE_FEAR, OBJECT_SELF);
                if(!nSave)
                {
                    //Apply the linked effects and the VFX impact
                    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eFrightened, oTarget, fDuration));
                    DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget));
                }
                // Made the Will save but are still shaken for one round.
                else if(nSave == 1) DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eShaken, oTarget, 6.0f));
            }
        }
        //Get next target in the spell cone
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetSpellTargetLocation(), TRUE);
    }
}
