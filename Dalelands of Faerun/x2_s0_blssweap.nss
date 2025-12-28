/*////////////////////////////////////////////////
 Script: X2_S0_BlssWeap
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Transmutation
Level:  Pal 1
Components: V, S
Casting Time:   1 standard action
Range:  Touch
Target: Weapon touched
Duration:   1 min./level
Saving Throw:   None
Spell Resistance:   No

  If cast on a crossbow bolt, it adds the ability to
  slay rakshasa's on hit

  If cast on a melee weapon, it will add the
      grants a +1 enhancement bonus.
      grants a +2d6 damage divine to undead
  will add a holy vfx when command becomes available
  If cast on a creature it will pick the first
  melee weapon without these effects
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void AddBlessEffectToWeapon (object oTarget, int iModifier, float fDuration)
{
   // If the spell is cast again, any previous enhancement boni are kept
   IPSafeAddItemProperty (oTarget, ItemPropertyEnhancementBonus (iModifier), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE);
   // Replace existing temporary anti undead boni
   IPSafeAddItemProperty (oTarget, ItemPropertyDamageBonusVsRace (IP_CONST_RACIALTYPE_UNDEAD, IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEBONUS_2d6), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   IPSafeAddItemProperty (oTarget, ItemPropertyVisualEffect (ITEM_VISUAL_HOLY), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
   return;
}

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
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
    object oPossessor, oMyWeapon;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // ---------------- TARGETED ON BOLT  -------------------
    if (GetIsObjectValid(Spell.oTarget) && GetObjectType(Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        // special handling for blessing crossbow bolts that can slay rakshasa's
        if (GetBaseItemType(Spell.oTarget) == BASE_ITEM_BOLT)
        {
           oPossessor = GetItemPossessor (Spell.oTarget);
           SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
           IPSafeAddItemProperty(Spell.oTarget, ItemPropertyOnHitCastSpell (123, 1), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oPossessor);
           ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, Spell.fDuration);
           return;
        }
    }
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        oMyWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        if (GetIsMeleeWeapon (oMyWeapon))
        {
            oPossessor = GetItemPossessor(oMyWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand (Spell.fDelay, AddBlessEffectToWeapon (oMyWeapon, Spell.iResult, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
        }
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83615, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
