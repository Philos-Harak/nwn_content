/*////////////////////////////////////////////////
 Script Name: X2_S0_GrMagWeap
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Bard 3, Cleric 4, Paladin 3, Wizard / Sorcerer 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic
Range: Short
Area of Effect / Target: Creature or  Melee Weapon
Duration: 1 Hour / Level
Save: None
Spell Resistance: No

You empower the touched weapon with a +1 enhancement bonus per 3 caster levels (maximum of +5). You can either directly target the weapon you want to
cast this spell on, or you can target a creature, affecting the creature's main hand weapon.

Arcane Material Component: Powdered lime and carbon
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
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 5;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // Get the result for the effect, sets Spell.iResult.
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
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyEnhancementBonus (Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING , TRUE, TRUE));
        }
        // Display failure text.
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83615, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
