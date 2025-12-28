/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_fear_aura_en
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Aura: Save vs Fear effect.
 DC: 10 + 1/2 Sorcerer level + Charisma modifier.
 Duration: 1 round per 1/2 Sorcerer/Dragon Disciple level + Charisma modifier.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
void main()
{
    object oTarget = GetEnteringObject();
    object oCaster = GetAreaOfEffectCreator();
    string sCasterName = StripColorCodes(GetName (oCaster));
    // Check to make sure this is an enemy. Otherwise get out!
    // Also see if they have already made this save use casters name to who's fear aura.
    if(!GetIsEnemy(oTarget, oCaster) || GetLocalString(oTarget, "0_AURA_FEAR") == sCasterName) return;
    int nLevel = ((GetLevelByClass(CLASS_TYPE_SORCERER, oCaster) + GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, oCaster)) / 2) + GetAbilityModifier(ABILITY_CHARISMA, oCaster);
    int nDC = 10 + nLevel;
    // Add a variable with the casters name to the monster so we know we did a check already.
    // Creatures only have to make one save no matter if the fail or not.
    SetLocalString(oTarget, "0_AURA_FEAR", sCasterName);
    if(!WillSave(oTarget, nDC, SAVING_THROW_TYPE_FEAR, oCaster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt (oCaster, SPELLABILITY_AURA_FEAR));
        effect eImpact = EffectVisualEffect(VFX_IMP_FEAR_S);
        effect eFrightened = EffectAttackDecrease(4);
        eFrightened = EffectLinkEffects(EffectSavingThrowDecrease (SAVING_THROW_ALL, 4), eFrightened);
        eFrightened = EffectLinkEffects(EffectSkillDecrease (SKILL_ALL_SKILLS, 4), eFrightened);
        effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eVisual = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
        eFrightened = EffectLinkEffects(eDuration, eFrightened);
        eFrightened = EffectLinkEffects(eVisual, eFrightened);
        float fDuration = RoundsToSeconds(nLevel);
        //Apply the VFX impact and effects
        ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eFrightened, oTarget, fDuration);
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oTarget);
    }
}
