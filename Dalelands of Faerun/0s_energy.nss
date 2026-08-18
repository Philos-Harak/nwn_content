/*///////////////////////////////////////////////
 Script: 0s_energy
 Programmer: Preston Watamaniuk
/////////////////////////////////////////////////
Used for all energy endure, resist, protect, and buffer spells.
Level: Varies.
School: Abjuration
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Single
Duration: Varies
Save: Harmless
Spell Resistance: No

The target creature gains damage resistance 10/- against all elemental forms of
damage. The spell ends after absorbing 20 points of damage from any single elemental type.
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    // Get which spell this is.
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 24;
    // Setup each individual spells structs.
    int nAmount, nLimit;
    Spell.iSpellID = GetSpellId ();
    // Endure Elements Lvl:1 - Resists 5 damage absorb 20 points of damage.
    if (Spell.iSpellID == SPELL_ENDURE_ELEMENTS)
    {
        nAmount = 5;
        nLimit = 20;
    }
    // Resist Elements Lvl:2 - Resists 10 damage absorb 30 points of damage.
    else if (Spell.iSpellID == SPELL_RESIST_ELEMENTS)
    {
        Spell.iDivineFocus = TRUE;
        Spell.iDurPerLvl = 1;
        nAmount = 10;
        nLimit = 30;
    }
    // Protection from Elements Lvl:3 - Resists 20 damage absorb 40 points of damage.
    else if (Spell.iSpellID == SPELL_PROTECTION_FROM_ELEMENTS)
    {
        Spell.iDivineFocus = TRUE;
        nAmount = 20;
        nLimit = 40;
    }
    // Energy Buffer Lvl:5 - Resists 40 damage absorb 60 points of damage.
    else if (Spell.iSpellID == SPELL_ENERGY_BUFFER)
    {
        nAmount = 40;
        nLimit = 60;
    }
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Get the duration of the spell.
    Spell = GetDuration (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAmount, nEnhancedLimit, nStack;
        int nAugeliteDust, nMalachiteDust, nOrbalineDust, nSpheneDust, nFlamedanceDust;
        int nJacinthDust, nPhenalopeDust, nFireAgateDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nAugeliteDust && GetTag(oItem) == "augelite_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nAugeliteDust = TRUE;
                nEnhancedAmount += 2;    
            }
            else if(!nMalachiteDust && GetTag(oItem) == "malachite_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nMalachiteDust = TRUE;
                nEnhancedAmount += 2;    
            }
            else if(!nOrbalineDust && GetTag(oItem) == "orbaline_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nOrbalineDust = TRUE;
                nEnhancedAmount += 2;    
            }
            else if(!nFlamedanceDust && GetTag(oItem) == "flamedance_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nFlamedanceDust = TRUE;
                nEnhancedAmount += 2;    
            }
            else if(!nSpheneDust && GetTag(oItem) == "sphene_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nSpheneDust = TRUE;
                    nEnhancedAmount += 8;    
                }
            }
            else if(!nJacinthDust && GetTag(oItem) == "jacinth_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nJacinthDust = TRUE;
                    nEnhancedLimit += 20;    
                }
            }
            else if(!nPhenalopeDust && GetTag(oItem) == "phenalope_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nPhenalopeDust = TRUE;
                nEnhancedLimit += 5;    
            }
            else if(!nFireAgateDust && GetTag(oItem) == "fire_agate_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nFireAgateDust = TRUE;
                nEnhancedLimit += 5;    
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAmount)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to resist +" + IntToString(nEnhancedAmount) + " additional damage per hit!", COLOR_GREEN, oObject);
            nAmount += nEnhancedAmount;
        }
        if(nEnhancedLimit)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to absorb +" + IntToString(nEnhancedLimit) + " additional damage per hit!", COLOR_GREEN, oObject);
            nLimit += nEnhancedLimit;
        }
    }
    effect eCold = EffectDamageResistance(DAMAGE_TYPE_COLD, nAmount, nLimit);
    effect eFire = EffectDamageResistance(DAMAGE_TYPE_FIRE, nAmount, nLimit);
    effect eAcid = EffectDamageResistance(DAMAGE_TYPE_ACID, nAmount, nLimit);
    effect eSonic = EffectDamageResistance(DAMAGE_TYPE_SONIC, nAmount, nLimit);
    effect eElec = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, nAmount, nLimit);
    effect eImpact = EffectVisualEffect(VFX_IMP_ELEMENTAL_PROTECTION);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eCold, eFire);
    eLink = EffectLinkEffects(eLink, eAcid);
    eLink = EffectLinkEffects(eLink, eSonic);
    eLink = EffectLinkEffects(eLink, eElec);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        //Link Effects
        RemoveEffectsFromSpell (Spell.oAreaTarget, Spell.iSpellID);
        //Apply the VFX impact and effects
        DelayCommand (Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
        DelayCommand (Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
