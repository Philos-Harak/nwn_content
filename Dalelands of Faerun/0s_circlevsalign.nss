/*////////////////////////////////////////////////
 Script Name: 0s_circlevsalign
 Programmer:  Preston Watamaniuk
////////////////////////////////////////////////
School: Abjuration
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single, Medium
Duration: 2 Minutes / Level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

When this spell is cast, the caster chooses to be protected from either chaos,
law, good or evil. The spell target and all allies within 10 feet receive a +2
deflection bonus to Armor Class, +2 to all saving throws, and immunity to any
mind-affecting spells and spell-like abilities used by creatures of the chosen
alignment.

Enchanting:
Armor, bracers, clothing, and shields gain an armor bonus vs alignment.
Rings and cloaks gain a deflection bonus vs alignment.
Amulets gain a natural armor bonus vs alignment.

Arcane Material Component
A little powdered silver with which you trace a 3-foot diameter circle on the
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
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 2;
    Spell.iDurPerLvl = 1;
    int iAOE, iVisual, iImpact, iSpellID = GetSpellId ();
    if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_CHAOS)
    {
        Spell.iDescriptor = DESC_CHAOTIC;
        iAOE = AOE_MOB_CIRCCHAOS;
        iVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
        iImpact = VFX_IMP_EVIL_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_EVIL)
    {
        Spell.iDescriptor = DESC_EVIL;
        iAOE = AOE_MOB_CIRCEVIL;
        iVisual = VFX_DUR_PROTECTION_EVIL_MINOR;
        iImpact = VFX_IMP_EVIL_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_GOOD)
    {
        Spell.iDescriptor = DESC_GOOD;
        iAOE = AOE_MOB_CIRCGOOD;
        iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
        iImpact = VFX_IMP_GOOD_HELP;
    }
    else if (iSpellID == SPELL_MAGIC_CIRCLE_AGAINST_LAW)
    {
        Spell.iDescriptor = DESC_LAWFUL;
        iAOE = AOE_MOB_CIRCLAW;
        iVisual = VFX_DUR_PROTECTION_GOOD_MINOR;
        iImpact = VFX_IMP_GOOD_HELP;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create area effect.
    effect eAOE = EffectAreaOfEffect (iAOE);
    // Create visual effect.
    effect eVisual = EffectVisualEffect (iVisual);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    effect eImpact = EffectVisualEffect (iImpact);
    // Link effects.
    effect eLink = EffectLinkEffects (eAOE, eVisual);
    eLink = EffectLinkEffects (eLink, eDuration);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid (Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Create an instance of the AOE Object using the Apply Effect function
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
