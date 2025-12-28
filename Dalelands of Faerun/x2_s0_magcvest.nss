/*////////////////////////////////////////////////
 Script Name: X2_S0_MagcVest
////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Transmutation
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: Creature, Armor or Shield
Duration: 1 Hour / Level
Save: None
Spell Resistance: No

You empower the touched clothing, armor or shield with a +1 AC bonus per 3 caster levels (maximum of +5).

Enchanting:
Armor, bracers, clothing, and shields gain an armor bonus.
Rings and cloaks gain a deflection bonus.
Amulets gain a natural armor bonus.
Special: Some creature components can focus the magic to give an armor bonus vs a specific creature type.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void  AddACBonusToArmor(object oMyArmor, float fDuration, int nAmount)
{
    IPSafeAddItemProperty(oMyArmor,ItemPropertyACBonus(nAmount), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING ,FALSE,TRUE);
   return;
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 3;
    Spell.iMaxModifier = 5;
    Spell.iImpact = VFX_IMP_GLOBE_USE;
    Spell.iBeam = VFX_BEAM_FIRE;
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
    object oArmor, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make sure we have a weapon as the target.
        oArmor = GetTargetedOrEquippedArmor (Spell.oAreaTarget);
        // Must be a melee weapon.
        if (oArmor != OBJECT_INVALID)
        {
            oPossessor = GetItemPossessor (oArmor);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply visual effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // Apply effect.
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty(oArmor,ItemPropertyACBonus(Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING ,FALSE,TRUE));
        }
        // Display failure text.
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83826, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
