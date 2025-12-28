/*////////////////////////////////////////////////
 Script: X2_S0_DeafClng
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Paladin 1
Innate Level: 1
School: Transmutation
Component(s): Verbal, Somatic, Divine Focus
Range: Touch
Area of Effect / Target: Creature, Melee Weapon
Duration: 1 Round / Level
Save: None
Spell Resistance: No

You empower a weapon with a +1 attack bonus and a +3 sonic damage bonus.
Also, the weapon gains the ability to deafen the creature that is struck like a
thunderstone . The attack bonus will not stack with an existing enhancement
bonus or holy avenger properties.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void  AddDeafeningClangEffectToWeapon(object oMyWeapon, int iModifier, float fDuration)
{
    // Sonic bonus is always 2 higher than the attack bonus.
    int iSonicMod = iModifier + 2;
    // If above 5 then adjust for the IP_CONST_DAMAGEBONUS_*
    if (iSonicMod > 5) iSonicMod = iSonicMod + 10;
    IPSafeAddItemProperty (oMyWeapon, ItemPropertyAttackBonus(iModifier), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING , TRUE, TRUE);
    IPSafeAddItemProperty (oMyWeapon, ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_SONIC, iSonicMod), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING , FALSE, TRUE);
    IPSafeAddItemProperty (oMyWeapon, ItemPropertyOnHitCastSpell (137, 5), fDuration,  X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, FALSE);
    IPSafeAddItemProperty (oMyWeapon, ItemPropertyVisualEffect (ITEM_VISUAL_SONIC), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE );
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
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
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
    object oWeapon, oPossessor;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        oWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        if (GetIsMeleeWeapon (oWeapon))
        {
            oPossessor = GetItemPossessor (oWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            DelayCommand (Spell.fDelay, AddDeafeningClangEffectToWeapon (oWeapon, Spell.iResult, Spell.fDuration));
        }
        else
        {
            DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83615, Spell.oCaster));
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
