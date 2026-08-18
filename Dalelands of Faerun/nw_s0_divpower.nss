/*////////////////////////////////////////////////
 Script: NW_S0_DivPower
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation
Level:  Clr 4, War 4
Components: V, S, DF
Casting Time:   1 standard action
Range:  Personal
Target: You
Duration:   1 round/level

Calling upon the divine power of your patron, you imbue yourself with strength
and skill in combat. Your base attack bonus becomes equal to your character
level (which may give you additional attacks), you gain a +6 enhancement bonus
to Strength, and you gain 1 temporary hit point per caster level.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 6;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    //Declare major variables
    effect eAttack;
    effect eAttackMod;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Create effects.
    effect eStrength = EffectAbilityIncrease (ABILITY_STRENGTH, Spell.iResult);
    effect eHP = EffectTemporaryHitpoints (Spell.iCasterLevel);
    // Link effects.
    effect eLoopLink;
    effect eLink = EffectLinkEffects (eStrength, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        RemoveTempHitPoints ();
        // Calculate attacks.
        int iTotalCharacterLevel = GetCharacterLevels (Spell.oCaster);
        int iBAB = GetBaseAttackBonus (Spell.oAreaTarget);
        int iEpicPortionOfBAB = (iTotalCharacterLevel - 19 ) / 2;
        if (iEpicPortionOfBAB < 0 )  iEpicPortionOfBAB = 0;
        int iExtraAttacks = 0;
        int iAttackIncrease = 0;
        if (iTotalCharacterLevel > 20 )
        {
            iAttackIncrease = 20 + iEpicPortionOfBAB;
            if (iBAB - iEpicPortionOfBAB < 11 )  iExtraAttacks = 2;
            else if (iBAB - iEpicPortionOfBAB > 10 && iBAB - iEpicPortionOfBAB < 16) iExtraAttacks = 1;
        }
        else
        {
            iAttackIncrease = iTotalCharacterLevel;
            iExtraAttacks = ((iTotalCharacterLevel - 1) / 5) - ((iBAB - 1) / 5);
        }
        iAttackIncrease -= iBAB;
        if (iAttackIncrease < 0 ) iAttackIncrease = 0;
        // Create effects.
        eAttack = EffectAttackIncrease (iAttackIncrease);
        eAttackMod = EffectModifyAttacks (iExtraAttacks);
        // Link effects.
        eLoopLink = EffectLinkEffects (eLink, eAttack);
        eLoopLink = EffectLinkEffects (eLoopLink, eAttackMod);
        eLoopLink = SetEffectCasterLevel(eLoopLink, Spell.iCasterLevel);
        //Apply the armor bonuses and the VFX impact
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLoopLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eHP, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

