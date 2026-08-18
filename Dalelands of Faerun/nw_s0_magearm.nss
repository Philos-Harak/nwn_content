/*////////////////////////////////////////////////
 Script: nw_s0_magearm
 Programmer: Preston Watamaniuk
//////////////////////////////////////////////////
Conjuration (Creation) [Force]
Level:  Sor/Wiz 1
Components: V, S, F
Casting Time:   1 standard action
Range:  Touch
Target: Creature touched
Duration:   1 hour/level (D)
Saving Throw:   Will negates (harmless)
Spell Resistance:   No
An invisible but tangible field of force surrounds the subject of a mage armor
spell, providing a +4 armor bonus to AC.

Unlike mundane armor, mage armor entails no armor check penalty, arcane spell
failure chance, or speed reduction.

Focus: A piece of cured leather.
/*////////////////////////////////////////////////
#include "nwnx_creature"
#include "nwnx_effect"
#include "0i_spells"
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iSubSchool = SUBSCHOOL_CREATION;
    Spell.iDescriptor = DESC_FORCE;
    Spell.sArcaneComponent = COMPONENT_POUCH;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDurationType = DURATION_TYPE_HOURS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 4;
    Spell.iImpact = VFX_IMP_AC_BONUS;
    // Setup the spell.
    Spell = SetSpell (Spell);
    // Check to see if we should still fire off the spell.
    if (Spell.iSpellID == STOP_SPELL) return;
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration (Spell, TRUE);
    // Get the result for the effect, sets Spell.iResult.
    Spell = GetModifier (Spell);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nEnhancedAC, nStack;
        int nAlestoneDust, nJasmalDust;
        float fEnhancedDuration;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nAlestoneDust && GetTag(oItem) == "alestone_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nAlestoneDust = TRUE;
                fEnhancedDuration += 0.5;
            }
            else if(!nJasmalDust && GetTag(oItem) == "jasmal_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 3)
                {
                    if(nStack > 4) SetItemStackSize(oItem, nStack - 4);
                    else DestroyObject (oItem);
                    nJasmalDust = TRUE;
                    nEnhancedAC += 1;
                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nEnhancedAC)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase armor bonus by +" + IntToString(nEnhancedAC) + "!", COLOR_GREEN, oObject);
            Spell.iResult += nEnhancedAC;
        }
        if(fEnhancedDuration > 0.0)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the duration by +" + FloatToString(fEnhancedDuration * 100.0) + "%!", COLOR_GREEN, oObject);
            Spell.fDuration *= 1.0 + fEnhancedDuration;
        }
    }
    int nArmorBonus;
    //Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDuration = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Used to anchor the spell to the creature so we can test for it.
    effect eEffect = EffectSpellImmunity (SPELL_HORSE_MOUNT);
    eEffect = RemoveEffectIcon (eEffect);
    // Setup armor bonus i.e. Spell.iResult.
    // Setup an expire script to remove spells non-effects effects.
    effect eScript = EffectRunScript ("", "0s_magearmor_r", "", 0.0, IntToString (Spell.iResult));
    // Create the AC increase effect.
    effect eIconEffect = EffectIcon (35/*AC_INCREASE*/);
    // Link the effects
    effect eLink = EffectLinkEffects (eDuration, eEffect);
    eLink = EffectLinkEffects (eLink, eScript);
    eLink = EffectLinkEffects (eLink, eIconEffect);
    eLink = SetEffectCasterLevel(eLink, Spell.iCasterLevel);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        //Fire cast spell at event for the specified target
        SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
        // Remove any previously cast spell on this target.
        RemoveSpellEffects (Spell.iSpellID, Spell.oAreaTarget);
        if(!GetHasSpellEffect(962/*SPELL_GREATER_MAGE_ARMOR*/))
        {
            // Set the armor bonus on the character incase they equip or unequip items.
            nArmorBonus = GetLocalInt (Spell.oAreaTarget, "0_Armor_Bonus");
            SetLocalInt (Spell.oAreaTarget, "0_Armor_Bonus", Spell.iResult + nArmorBonus);
            // Apply effects
            DelayCommand (Spell.fDelay, CheckForArmorBonus (Spell.oAreaTarget));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eLink, Spell.oAreaTarget, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
            //Get the spells target(s).
        }
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}

