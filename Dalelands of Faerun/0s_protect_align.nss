/*////////////////////////////////////////////////
 script: 0s_protect_align
 Programmer: Kevin Curtis
////////////////////////////////////////////////
Abjuration [Good]
Level:  Clr 1, Good 1, Pal 1, Sor/Wiz 1
Components: V, S, M/DF
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 min./level (D)
Saving Throw:   Will negates (harmless)
Spell Resistance:No

This spell wards a creature from attacks by evil creatures, from mental control,
and from summoned creatures. It creates a magical barrier around the subject at
a distance of 1 foot. The barrier moves with the subject and has two major effects.

First, the subject gains a +2 deflection bonus to AC and a +2 resistance bonus
on saves. Both these bonuses apply against attacks made or effects created by
evil creatures.

Second, the barrier blocks any attempt to possess the warded creature or to
exercise mental control over the creature (including enchantment (charm) effects
and enchantment (compulsion) effects that grant the caster ongoing control over
the subject, such as dominate person) by evil creatures.

Arcane Material Component
A little powdered silver with which you trace a 3-foot -diameter circle on the
floor (or ground) around the creature to be warded.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 2;
    int nAlign1, nAlign2;
    switch (GetSpellId ())
    {
        case SPELL_PROTECTION_FROM_EVIL :
        {
            Spell.iDescriptor = DESC_GOOD;
            nAlign1 = ALIGNMENT_ALL;
            nAlign2 = ALIGNMENT_EVIL;
            break;
        }
        case SPELL_PROTECTION_FROM_GOOD :
        {
            Spell.iDescriptor = DESC_EVIL;
            nAlign1 = ALIGNMENT_ALL;
            nAlign2 = ALIGNMENT_EVIL;
            break;
        }
        case SPELL_PROTECTION_FROM_LAW :
        {
            Spell.iDescriptor = DESC_CHAOTIC;
            nAlign1 = ALIGNMENT_ALL;
            nAlign2 = ALIGNMENT_ALL;
            break;
        }
        case SPELL_PROTECTION__FROM_CHAOS :
        {
            Spell.iDescriptor = DESC_LAWFUL;
            nAlign1 = ALIGNMENT_CHAOTIC;
            nAlign2 = ALIGNMENT_ALL;
            break;
        }
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // AC bonus
    effect eAC = EffectACIncrease (Spell.iResult, AC_DEFLECTION_BONUS);
    eAC = VersusAlignmentEffect (eAC, nAlign1, nAlign2);
    // Save bonus
    effect eSave = EffectSavingThrowIncrease (SAVING_THROW_ALL, Spell.iResult);
    eSave = VersusAlignmentEffect (eSave, nAlign1, nAlign2);
    // Immunity to mind spells
    effect eImmune = EffectImmunity (IMMUNITY_TYPE_MIND_SPELLS);
    eImmune = VersusAlignmentEffect (eImmune, nAlign1, nAlign2);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects
    effect eLink = EffectLinkEffects (eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oCaster, Spell.oAreaTarget);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

