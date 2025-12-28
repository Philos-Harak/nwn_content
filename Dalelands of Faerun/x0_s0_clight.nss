/*////////////////////////////////////////////////
 Script: x0_s0_clight
 Programmer: Brent Knowles
////////////////////////////////////////////////
Illusion [Light]
Level:  Clr 3, Sor/Wiz 2
Components: V, S, M
Casting Time:   1 standard action
Range:  Touch
Target: Object touched
Effect: Magical, heatless flame
Duration:   Permanent
Saving Throw:   None
Spell Resistance:   No

A flame, equivalent in brightness to a torch, springs forth from an object that you touch.
The effect looks like a regular flame, but it creates no heat and doesn’t use oxygen.
A continual flame can be covered and hidden but not smothered or quenched.

Material component: You sprinkle ruby dust (worth 50 gp) on the item that is to carry the flame.

*////////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_LIGHT;
    Spell.sArcaneComponent = "0_ruby_dust";
    Spell.sDivineComponent = "0_ruby_dust";
    Spell.iCompAmount = 50;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iImpact = VFX_IMP_HEAD_MIND;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    //Declare and assign impact visual effect.
    effect eImpact = EffectVisualEffect(Spell.iImpact);
    // Only castable on an item now.
    // Do not allow casting on not equippable items
    if (!IPGetIsItemEquipable(Spell.oTarget))
    {
        // Item must be equipable...
        FloatingTextStrRefOnCreature (83326, Spell.oCaster);
    }
    else
    {
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, GetItemPossessor (Spell.oTarget));
        itemproperty ip = ItemPropertyLight (IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_WHITE);
        ip = TagItemProperty (ip, "0_Continual_Light");
        IPSafeAddItemProperty (Spell.oTarget, ip, 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, TRUE, TRUE);
    }
    CleanUpSpell (Spell);
}



