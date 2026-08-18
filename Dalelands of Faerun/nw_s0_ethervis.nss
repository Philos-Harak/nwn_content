/*////////////////////////////////////////////////
 Script Name: NW_S0_EtherVis.nss
 Programmer: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 5, Wizard / Sorcerer 6
Innate Level: 5
School: Illusion
Component(s): Verbal, Somatic
Range: Personal
Area of Effect / Target: Caster
Duration: 1 Round / Level
Additional Counter Spells:
Save: Harmless
Spell Resistance: No

The caster is surrounded by a ghostly nimbus of light that grants the target
creature damage reduction 10/+3. The spell absorbs 10 points of melee damage per
caster level, to a maximum of 150, before collapsing.

Enhanced: The spell no longer absorbs damage and lasts the full duration as well
as prevents all spells of level 2 or lower from affecting the caster, and grants
25% concealment.

Material Component: Any small object that has been to the ethereal plane.
Enhancing Component: 300gp worth of diamond dust sprinkled on the caster.

Enchanting:
Armors and shields are reduced in weight.
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
    Spell.sEnhancingComp = "diamond_dust";
    Spell.iCompAmount = 12; // 300gp worth of diamond dust.
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 10;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 150;
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
    // Create visual effects.
    effect eVis = EffectVisualEffect (VFX_DUR_ETHEREAL_VISAGE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eVis, eDur);
    // If we are enhancing the spell then set the damage reduction to infinite.
    // and add immunity to 1st level spells and concealment 10.
    if (Spell.sEnhancingComp == "TRUE")
    {
        Spell.iResult = 0;
        effect eSpell = EffectSpellLevelAbsorption (2);
        effect eConceal = EffectConcealment (25);
        eLink = EffectLinkEffects (eLink, eSpell);
        eLink = EffectLinkEffects (eLink, eConceal);
    }
    effect eDmgReduction = EffectDamageReduction (10, DAMAGE_POWER_PLUS_THREE, Spell.iResult);
    eLink = EffectLinkEffects(eLink, eDmgReduction);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Signal spell cast at event to fire.
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
