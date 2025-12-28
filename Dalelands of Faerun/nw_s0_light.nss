/*////////////////////////////////////////////////
 Script: nw_s0_light
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Evocation [Light]
Level:  Brd 0, Clr 0, Drd 0, Sor/Wiz 0
Components: V, M/DF
Casting Time:   1 standard action
Range:  Touch
Target: Object touched
Duration: 1 Hour / level (D)
Saving Throw:   None
Spell Resistance:   No
This spell causes an object to glow like a torch, shedding normal light in a
20-foot radius (and dim light for an additional 20 feet) from the point you touch.
The effect is immobile, but it can be cast on a movable object. Light taken into
an area of magical darkness does not function.

Material Component: A firefly or a piece of phosphorescent moss.
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
    Spell.iDescriptor = DESC_LIGHT;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iDivineFocus = TRUE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iImpact = VFX_IMP_MAGIC_RESISTANCE_USE;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Handle spell cast on item....
    if (GetObjectType(Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        // Do not allow casting on not equippable items
        if (!IPGetIsItemEquipable (Spell.oTarget))
        {
            // Item must be equipable...
            FloatingTextStrRefOnCreature (83326, Spell.oCaster);
            return;
        }
        // Set duration as an item enchantment for special feats.
        Spell = GetDuration (Spell, TRUE);
        itemproperty ip = ItemPropertyLight (IP_CONST_LIGHTBRIGHTNESS_LOW, IP_CONST_LIGHTCOLOR_WHITE);
        if (GetItemHasItemProperty(Spell.oTarget, ITEM_PROPERTY_LIGHT))
        {
            IPRemoveMatchingItemProperties (Spell.oTarget, ITEM_PROPERTY_LIGHT, DURATION_TYPE_TEMPORARY);
        }
        AddItemProperty (Spell.iDurationType, ip, Spell.oTarget, Spell.fDuration);
    }
    // Cast the light spell on a creature.
    else
    {
        // Get the duration of the spell.
        Spell = GetDuration (Spell);
        effect eVisual = EffectVisualEffect (VFX_DUR_LIGHT_WHITE_20);
        effect eImpact = EffectVisualEffect (Spell.iImpact);
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
        while(GetIsObjectValid(Spell.oAreaTarget))
        {
            //Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            //Apply the VFX impact and visual effects
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eVisual, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            //Get the spells target(s).
            Spell = GetSpellTarget (Spell);
        }
    }
    CleanUpSpell (Spell);
}
