/*////////////////////////////////////////////////
 Script Name: X2_S0_KeenEdge
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 3, Bard 3
Innate Level: 3
School: Transmutation
Descriptor(s): Weapon Enchantment
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Creature or Slashing Weapon
Duration: 10 Minutes / Level
Additional Counter Spells:
Save: None
Spell Resistance: No

Adds the Keen property to the targeted slashing melee weapon, increasing its critical threat range.

Enchanting:
Weapons gain the keen property.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // Get the modifier for the effect.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oWeapon, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make sure we have a weapon as the target.
        oWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        // Must be a melee weapon.
        if (GetIsMeleeWeapon (oWeapon))
        {
            oPossessor = GetItemPossessor (oWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply visual effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // Apply effect.
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyKeen (), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING , TRUE, TRUE));
        }
        // Display failure text.
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83621, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

