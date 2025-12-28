/*////////////////////////////////////////////////
 Script: X2_S0_Blckstff
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Wizard / Sorcerer 8
Innate Level: 8
School: Transmutation
Descriptor(s): Weapon Enchantment
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature holding quarterstaff or item (quarterstaff)
Duration: 1 Round / Level
Additional Counter Spells:
Save: No
Spell Resistance: Yes

Casting this spell on a quarterstaff will do the following:
- Gives it a +4 enhancement bonus.
- On striking a creature, dispel magic is cast on the target.

The spell will not work on any other weapon than a quarterstaff
/*/////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void AddBlackStaffEffectOnWeapon (object oTarget, float fDuration)
{
   IPSafeAddItemProperty (oTarget, ItemPropertyEnhancementBonus(4), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE, TRUE);
   IPSafeAddItemProperty (oTarget, ItemPropertyOnHitProps(IP_CONST_ONHIT_DISPELMAGIC, IP_CONST_ONHIT_SAVEDC_16), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING );
   IPSafeAddItemProperty (oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_EVIL), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE );
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_RANGE_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_EVIL_HELP;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    if (GetIsObjectValid (oMyWeapon))
    {
        SignalEvent(GetItemPossessor(oMyWeapon), EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
        if (GetBaseItemType(oMyWeapon) == BASE_ITEM_QUARTERSTAFF)
        {
            ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, GetItemPossessor (oMyWeapon));
            ApplyEffectToObject (Spell.iDurationType, eDuration, GetItemPossessor (oMyWeapon), Spell.fDuration);
            AddBlackStaffEffectOnWeapon (oMyWeapon, Spell.fDuration);
        }
        else
        {
            /* * Invalid Target - This spell must be cast on a quarterstaff * */
            FloatingTextStrRefOnCreature (83620, OBJECT_SELF);
        }
    }
    else
    {
        /* * Spell Failed - Target must be a melee weapon or creature with a melee weapon equipped * */
        FloatingTextStrRefOnCreature(83615, OBJECT_SELF);
    }
    CleanUpSpell (Spell);
}
