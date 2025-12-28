/*////////////////////////////////////////////////
 Script Name: NW_S0_FeebMind.nss]
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Enchantment (Compulsion) [Mind-Affecting]
Level:  Sor/Wiz 5
Components: V, S, M
Casting Time:   1 standard action
Range:  Medium (100 ft. + 10 ft./level)
Target: One creature
Duration: 1 round / level
Saving Throw:   Will negates; see text
Spell Resistance:   Yes
If the target creature fails a Will saving throw, its Intelligence and Charisma
scores each drop by a 1d4 per 4 levels.
A creature that can cast arcane spells, such as a sorcerer or a wizard, takes a
-4 penalty on its saving throw.

Material Component
A handful of clay, crystal, glass, or mineral spheres.
/*///////////////////////////////////////////////
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_COMPULSION;
    Spell.iDescriptor = DESC_MIND;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.fAreaSize = 10.0f;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iSpellResistance = TRUE;
    Spell.iSave = SAVING_THROW_WILL;
    Spell.iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 4;
    Spell.iModDicePerLvl = 4;
    Spell.iImpact = VFX_IMP_REDUCE_ABILITY_SCORE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Setup visual effects.
    effect eFeeblemind, eLink;
    effect eImpact = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        SignalEvent(Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
        // Make resistance and save check.
        Spell = ResistAndSave (Spell);
        if (!Spell.iSaveResult)
        {
            // Get the result for the effect, sets Spell.iResult.
            Spell = GetModifier (Spell);
            eFeeblemind = EffectAbilityDecrease (ABILITY_INTELLIGENCE, Spell.iResult);
            eLink = EffectLinkEffects (eFeeblemind, eDuration);
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink , Spell.oAreaTarget, Spell.fDuration));
        }
        // * target was immune
        else if (Spell.iSaveResult == 2)
        {
            AssignCommand (Spell.oAreaTarget, SpeakStringByStrRef (40105, TALKVOLUME_TALK));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
