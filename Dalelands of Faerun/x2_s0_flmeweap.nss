/*////////////////////////////////////////////////
 Script: X2_S0_FlmeWeap
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 2
Innate Level: 2
School: Evocation
Descriptor(s): Weapon Enchantment
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature or Melee Weapon
Duration: 1 Minute / Level
Additional Counter Spells:
Save: None
Spell Resistance: No

Sets a melee weapon aflame, granting 1d4 points of fire damage +1 per caster
level to a maximum of +10. You can target a specific weapon or a creature with this spell.

Enchanting:
Weapons and gloves gain fire damage.
Armors gains fire damage resistance.
Bracers, belts, cloaks, and helmets gain saving throw bonus vs fire.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void AddFlamingEffectToWeapon(object oTarget, float fDuration, int iCasterLevel)
{
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell (124, iCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect (ITEM_VISUAL_FIRE), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_PULSE_FIRE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oWeapon, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while( GetIsObjectValid (Spell.oAreaTarget))
    {
        oWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        // Must be a melee weapon.
        if (GetIsMeleeWeapon (oWeapon))
        {
            oPossessor = GetItemPossessor (oWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // haaaack: store caster level on item for the on hit spell to work properly
            AddFlamingEffectToWeapon (oWeapon, Spell.fDuration, Spell.iCasterLevel);
        }
        else
        {
            FloatingTextStrRefOnCreature (83615, OBJECT_SELF);
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
