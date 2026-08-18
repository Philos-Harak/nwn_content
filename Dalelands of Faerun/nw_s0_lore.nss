/*////////////////////////////////////////////////
 Script Name: NW_S0_Lore.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 4, Wizard / Sorcerer 6
Innate Level: 6
School: Divination
Component(s): Verbal, Somatic, Material, Focus
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Minute / Level
Save: Harmless
Spell Resistance: No

This spell grants the caster a +10 bonus to Lore checks, +1 per 2 caster levels.

Enhanced: The spell determines all magic properties of all magic items,
including how to activate those functions (if appropriate), and how many charges
are left (if any) on the caster at the moment of the spells casting.

Focus: Four strips of ivory formed into a rectangle.
Enhancing Component: 250gp worth of Incense.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.sDivineComponent = COMPONENT_POUCH;
    Spell.sEnhancingComp = "0_incense";
    Spell.iCompAmount = 10; // 250gp worth of Incense.
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModNumOfDice = 1;
    Spell.iModifierDie = 1;
    Spell.iModDicePerLvl = 2;
    Spell.iModifier = 10;
    Spell.iImpact = VFX_IMP_MAGICAL_VISION;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell, sets Spell.fDuration.
    Spell = GetDuration (Spell);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    // Create variables.
    object oItem;
    // Create Effect.
    effect eLore = EffectSkillIncrease (SKILL_LORE, Spell.iResult);
    // Create visual effect.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects (eLore, eDuration);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire spell cast at event for target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        // Apply VFX impact and bonus effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        // If we are enhancing the spell then Identify all magic items.
        if (Spell.sEnhancingComp == "TRUE")
        {
            oItem = GetFirstItemInInventory (Spell.oAreaTarget);
            while (GetIsObjectValid (oItem))
            {
                if (!GetIdentified (oItem)) SetIdentified (oItem, TRUE);
                oItem = GetNextItemInInventory (Spell.oAreaTarget);
            }
        }
        // Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

