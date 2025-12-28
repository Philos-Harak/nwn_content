/*////////////////////////////////////////////////
 Script Name: X2_S0_Darkfire
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Evocation
Descriptor(s): Fire
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature, Melee Weapon
Duration: 1 Minute / Level
Save: None
Spell Resistance: No

This spell allows the caster to immolate a non-magical weapon. The weapon will
do 1d6  points of damage, +1 per two caster levels (maximum of +10) of fire
damage. The caster can either target a specific melee weapon in his inventory
or a creature to enchant the weapon the creature is wielding.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void AddFlamingEffectToWeapon(object oTarget, float fDuration, int nCasterLvl)
{
   // If the spell is cast again, any previous itemproperties matching are removed.
   IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell(127,nCasterLvl), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   return;
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
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    object oWeapon, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (EffectVisualEffect(VFX_IMP_FLAME_M), eImpact);
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
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eLink, oPossessor));
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

