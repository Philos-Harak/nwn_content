/*////////////////////////////////////////////////
 Script: 0s_ioun_stones
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Stone    Color   Effects                   Vfx
Topaz    Yellow  +2 Str / +25% movement    1004
Amethyst Purple  +2 Dex / +2 AC Deflection 1003
Emerald  Green   +2 Con / Regeneraton +1   1002
Ruby     Red     +2 Int / +1 to all skills 1001
Saphire  Blue    +2 Wis / Darkvision       1000
Diamond  White   +2 Cha / +1 to all saves  1005
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    int iSpellID;
    effect eVFX, eBonus, eLink, eEffect;
    // Get the ResRef of the stone used.
    object oItem = GetSpellCastItem ();
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    // Remove any ioun stones effects.
    eEffect = GetFirstEffect(Spell.oAreaTarget);
    while (GetIsEffectValid (eEffect))
    {
        iSpellID = GetEffectSpellId (eEffect);
        // Check for turning off a ioun stone.
        if (iSpellID == Spell.iSpellID)
        {
            RemoveEffect (Spell.oAreaTarget, eEffect);
            // If the spell is the same as the one we are removing then
            // don't create the effect again.
            Spell.iSpellID = 0;
        }
        // Check to see if we need to remove an ioun stone
        // Only 1 of each color can be active at a time (Max 6).
        // Dex / AC
        else if (Spell.iSpellID == 558 && iSpellID == 554) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 554 && iSpellID == 558) RemoveEffect (Spell.oAreaTarget, eEffect);
        // / Str
        else if (Spell.iSpellID == 922 && iSpellID == 555) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 555 && iSpellID == 922) RemoveEffect (Spell.oAreaTarget, eEffect);
        // / Int
        else if (Spell.iSpellID == 923 && iSpellID == 556) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 556 && iSpellID == 923) RemoveEffect (Spell.oAreaTarget, eEffect);
        // / Wis
        else if (Spell.iSpellID == 924 && iSpellID == 557) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 557 && iSpellID == 924) RemoveEffect (Spell.oAreaTarget, eEffect);
        // Regeneration / Con
        else if (Spell.iSpellID == 925 && iSpellID == 559) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 559 && iSpellID == 925) RemoveEffect (Spell.oAreaTarget, eEffect);
        // / Cha
        else if (Spell.iSpellID == 926 && iSpellID == 560) RemoveEffect (Spell.oAreaTarget, eEffect);
        else if (Spell.iSpellID == 560 && iSpellID == 926) RemoveEffect (Spell.oAreaTarget, eEffect);
        eEffect = GetNextEffect (Spell.oAreaTarget);
    }
    // Select the Ioun stone that is being activated.
    switch (Spell.iSpellID)
    {
        case 554: // Amethyst (Purple): +2 AC
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1003);
            eBonus = EffectACIncrease(2, AC_DEFLECTION_BONUS);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 555: // Topaz (Yellow) : +2 Str
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1004);
            eBonus = EffectAbilityIncrease (ABILITY_STRENGTH, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 556: // Ruby (Red): +2 Int
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1001);
            eBonus = EffectAbilityIncrease (ABILITY_INTELLIGENCE, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 557: //  Saphire (Blue): +2 Wis
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1000);
            eBonus = EffectAbilityIncrease (ABILITY_WISDOM, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 558: // Amethyst (Purple): +2 Dex
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1003);
            eBonus = EffectAbilityIncrease (ABILITY_DEXTERITY, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 559: // Emerald (Green): +2 Con
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1002);
            eBonus = EffectAbilityIncrease (ABILITY_CONSTITUTION, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 560: // Diamond (White): +2 Cha
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1005);
            eBonus = EffectAbilityIncrease (ABILITY_CHARISMA, 2);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 922: // Topaz (Yellow): +25% movement.
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1004);
            eBonus = EffectMovementSpeedIncrease (25);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 923: // Ruby (Red): +1 to all Skills
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1001);
            eBonus = EffectSkillIncrease (SKILL_ALL_SKILLS, 1);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 924: // Saphire (Blue): Gain Darkvision
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1000);
            eBonus = EffectUltravision ();
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 925: // Emerald (Green): Gain Regeneration +1
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1002);
            eBonus = EffectRegenerate (1, 60.0);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
        case 926: // Diamond (White): +1 to all saves.
        {
            // Create effects based on the stone activated.
            eVFX = EffectVisualEffect (1005);
            eBonus = EffectSavingThrowIncrease (SAVING_THROW_ALL, 1);
            eLink = EffectLinkEffects (eVFX, eBonus);
            break;
        }
    }
    if (Spell.iSpellID > 0)
    {
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // These are not dispellable.
        eLink = ExtraordinaryEffect (eLink);
        // Tag the effect with the stone used.
        eLink = TagEffect (eLink, GetResRef (oItem));
        // Apply the stones effecs.
        ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration);
    }
}

