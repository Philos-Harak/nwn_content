/*////////////////////////////////////////////////
 Script: nw_s0_ghostvis
 Programmer: Created By: Preston Watamaniuk
////////////////////////////////////////////////
Caster Level(s): Bard 2, Wizard / Sorcerer 2
Innate Level: 2
School: Illusion
Component(s): Verbal, Somatic, Arcane Focus
Range: Personal
Area of Effect / Target: Caster
Duration: 10 Minutes / Level or until discharged
Save: Harmless
Spell Resistance: No

The caster is surrounded by a ghostly nimbus of light that grants the target
creature damage reduction 5/+1. The spell absorbs 5 points of melee damage per
caster level, to a maximum of 75, before collapsing.

Enhanced: The spell no longer absorbs damage and lasts the full duration as well
as prevents all spells of level 1 or lower from affecting the caster, and grants
10% concealment.

Material Component: Piece of garment owned by a ghost.
Enhancing Component: 100gp worth of diamond dust sprinkled on the caster.

Enchanting: Armors and shields are reduced in weight.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_PERSONAL;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 10;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 5;
    Spell.iModPerLvl = 1;
    Spell.iMaxModifier = 75;
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
    effect eVis = EffectVisualEffect (VFX_DUR_GHOSTLY_VISAGE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    effect eLink = EffectLinkEffects(eVis, eDur);
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAbsorb, nStack;
        int nLaeralTearsDust, nPeridotDust, nRaindropDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            // Laeral's Tears Dust enhances the spell to absorb an additional 20 points of damage.
            if(GetTag(oItem) == "laeral_tears_dust" && !nLaeralTearsDust)
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nLaeralTearsDust = TRUE;
                    nEnhancedAbsorb += 20;
                }
            }
            // Peridot Dust Enhances the spell to absorb 1st level spells.
            else if(GetTag(oItem) == "peridot_dust" && !nPeridotDust)
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nPeridotDust = TRUE;
                    effect eSpell = EffectSpellLevelAbsorption(1);
                    eLink = EffectLinkEffects(eLink, eSpell);
                }
            }
            // Raindrop Dust Enhances the spell to increase concealment by +10%.
            else if(GetTag(oItem) == "raindrop_dust" && !nRaindropDust)
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nRaindropDust = TRUE;
                    effect eConceal = EffectConcealment(10);
                    eLink = EffectLinkEffects(eLink, eConceal);
                }
            }
            else if(nRaindropDust && nPeridotDust && nLaeralTearsDust) break;
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAbsorb)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to absorb +" + IntToString(nEnhancedAbsorb) + " additional damage!", COLOR_GREEN, oObject);
            Spell.iResult = Spell.iResult + nEnhancedAbsorb;
        }
    }
    effect eDmgReduction = EffectDamageReduction (5, DAMAGE_POWER_PLUS_ONE, Spell.iResult);
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

