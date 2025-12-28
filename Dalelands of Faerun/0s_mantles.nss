/*////////////////////////////////////////////////
 Script Name: 0s_mantles
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Varies.
Innate Level: Varies
School: Abjuration
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Round / Level
Additional Counter Spells: Lesser Spell Breach, Lesser Spell Mantle
Save: Harmless
Spell Resistance: No

Creates a barrier around the caster that absorbs all incoming spells and
spell-like abilities. It can absorb up to specific number of levels from spells
before collapsing.

Lvl 5: Lesser Spell Mantle absorbs 1d4+6 levels.
Lvl 7: Spell Mantle absorbs 1d8+8 levels.
Lvl 9: Greater spell mantle absorbs 1d12+10 levels.

Enchanting:
Armor, Clothing, and Shields gain spell resistance.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    switch (GetSpellId ())
    {
        case SPELL_LESSER_SPELL_MANTLE :
        {
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 4;
            Spell.iModifier = 6;
            break;
        }
        case SPELL_SPELL_MANTLE :
        {
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 8;
            Spell.iModifier = 8;
            break;
        }
        case SPELL_GREATER_SPELL_MANTLE :
        {
            Spell.iModNumOfDice = 1;
            Spell.iModifierDie = 12;
            Spell.iModifier = 10;
            break;
        }
    }
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
    effect eVisual = EffectVisualEffect (VFX_DUR_SPELLTURNING);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Link Effects
    effect eAbsorb = EffectSpellLevelAbsorption (9, Spell.iResult);
    effect eLink = EffectLinkEffects (eVisual, eAbsorb);
    eLink = EffectLinkEffects(eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        RemoveEffectsFromSpell (Spell.oAreaTarget, Spell.iSpellID);
        RemoveEffectsFromSpell (Spell.oAreaTarget, SPELL_GREATER_SPELL_MANTLE);
        RemoveEffectsFromSpell (Spell.oAreaTarget, SPELL_SPELL_MANTLE);
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eVisual, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

