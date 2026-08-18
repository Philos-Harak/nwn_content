/*////////////////////////////////////////////////
 Script: X2_S0_MagcWeap
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Transmutation
Level:  Clr 1, Pal 1, Sor/Wiz 1, War 1
Components: V, S, DF
Casting Time:   1 standard action
Range:  Touch
Target: Weapon touched
Duration:   1 min./level
Saving Throw:   Will negates (harmless, object)
Spell Resistance:   Yes (harmless, object)

Magic weapon gives a weapon a +1 enhancement bonus on attack and damage rolls.

You can't cast this spell on a natural weapon, such as an unarmed strike
(instead, see magic fang).
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"
void AddDamageEffectToWeapon(object oTarget, float fDuration, int nCasterLevel, int nDamageType)
{
    if(nDamageType == DAMAGE_TYPE_FIRE) nDamageType = ITEM_VISUAL_FIRE;
    else if(nDamageType == DAMAGE_TYPE_ACID) nDamageType = ITEM_VISUAL_ACID;
    else if(nDamageType == DAMAGE_TYPE_COLD) nDamageType = ITEM_VISUAL_COLD;
    else if(nDamageType == DAMAGE_TYPE_ELECTRICAL) nDamageType = ITEM_VISUAL_ELECTRICAL;
    else if(nDamageType == DAMAGE_TYPE_SONIC) nDamageType = ITEM_VISUAL_SONIC;
    else if(nDamageType == DAMAGE_TYPE_DIVINE) nDamageType = ITEM_VISUAL_HOLY;
    else if(nDamageType == DAMAGE_TYPE_POSITIVE) nDamageType = ITEM_VISUAL_HOLY;
    else if(nDamageType == DAMAGE_TYPE_NEGATIVE) nDamageType = ITEM_VISUAL_EVIL;
    else if(nDamageType == DAMAGE_TYPE_MAGICAL) nDamageType = ITEM_VISUAL_SONIC;
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell (124, nCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect (nDamageType), fDuration,X2_IP_ADDPROP_POLICY_IGNORE_EXISTING, FALSE, TRUE);
}
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDivineFocus = TRUE;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
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
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nStack, nGarnetDust, nFloursparDust;
        float fEnhancedDuration;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nFloursparDust && GetTag(oItem) == "flourspar_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack == 1) DestroyObject (oItem);
                else SetItemStackSize(oItem, nStack - 1);
                nFloursparDust = TRUE;
                fEnhancedDuration += 0.5;
            }
            else if(!nGarnetDust && GetTag(oItem) == "garnet_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 1)
                {
                    if(nStack > 2) SetItemStackSize(oItem, nStack - 2);
                    else DestroyObject (oItem);
                    nGarnetDust = TRUE;

                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(fEnhancedDuration > 0.0)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has enhanced the duration by +" + FloatToString(fEnhancedDuration * 100.0) + "%!", COLOR_GREEN, oObject);
            Spell.fDuration *= (1.0 + fEnhancedDuration);
        }
    }
    int nDamageDice, nEnhancedBonus, nBaseItemType;
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        // Do a special check for enhancing components in one inventory pass.
        int nStack, nGarnetDust, nGoldlineDust;
        object oItem = GetFirstItemInInventory(Spell.oCaster);
        while(oItem != OBJECT_INVALID)
        {
            if(!nGarnetDust && GetTag(oItem) == "garnet_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 1)
                {
                    if(nStack > 2) SetItemStackSize(oItem, nStack - 2);
                    else DestroyObject (oItem);
                    nGarnetDust = TRUE;
                    nDamageDice += 2;
                }
            }
            else if(!nGoldlineDust && GetTag(oItem) == "goldline_dust")
            {
                nStack = GetItemStackSize(oItem);
                if(nStack > 1)
                {
                    if(nStack > 2) SetItemStackSize(oItem, nStack - 2);
                    else DestroyObject (oItem);
                    nGoldlineDust = TRUE;
                    nEnhancedBonus += 1;
                }
            }
            oItem = GetNextItemInInventory(Spell.oCaster);
        }
        object oObject;
        if(nGarnetDust)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced to increase the damage dice to d" + IntToString(nDamageDice) + "!", COLOR_GREEN, oObject);
        }
        if(nEnhancedBonus)
        {
            string sSpellName = GetStringByStrRef(StringToInt(Get2DAString("Spells", "Name", Spell.iSpellID)));
            if(GetIsCharacter(Spell.oCaster)) oObject = Spell.oCaster;
            else oObject = GetMaster(Spell.oCaster);
            SendMessages(sSpellName + " has been enhanced by increasing the Enhancement bonus by +" + IntToString(nEnhancedBonus) + "!", COLOR_GREEN, oObject);
            Spell.iResult += nEnhancedBonus;
        }
    }
    object oWeapon, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make sure we have a weapon as the target.
        oWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        // Must be a melee weapon.
        if(oWeapon != OBJECT_INVALID)
        {
            oPossessor = GetItemPossessor (oWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply visual effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // Apply effect.
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyEnhancementBonus (Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
            if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_CREATURE)
            {
                nBaseItemType = GetBaseItemType(oWeapon);
                if(nBaseItemType == BASE_ITEM_CSLASHWEAPON ||
                   nBaseItemType == BASE_ITEM_CPIERCWEAPON ||
                   nBaseItemType == BASE_ITEM_CBLUDGWEAPON ||
                   nBaseItemType == BASE_ITEM_CSLSHPRCWEAP)
                {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, Spell.oAreaTarget);
                    DelayCommand(Spell.fDelay, IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
                    if(nDamageDice)
                    {
                        SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                        SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                        AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
                    }
                }
                else
                {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, Spell.oAreaTarget);
                    if(GetIsWeapon(oWeapon))
                    {
                        DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyEnhancementBonus (Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
                    }
                }
            }
            if(nDamageDice)
            {
                // Also adding the damage dice and damage type as variables on the weapon to be used in onhit script.
                SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
                if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_CREATURE)
                {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, Spell.oAreaTarget);
                    if(GetIsWeapon(oWeapon))
                    {
                        SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                        SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                        AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
                    }
                }
            }
        }
        // Display failure text.
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83615, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
