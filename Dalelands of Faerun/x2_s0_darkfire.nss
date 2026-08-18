/*////////////////////////////////////////////////
 Script Name: X2_S0_Darkfire
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Cleric 3
Innate Level: 3
School: Evocation
Descriptor(s): Fire
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature, Melee Weapon
Duration: 1 Minute / Level
Save: None
Spell Resistance: No

This spell allows the caster to immolate a non-magical weapon. The weapon will
do 1d6  points of damage, +1 per two caster levels (maximum of +10) of fire
damage. The caster can either target a specific melee weapon in his inventory
or a creature to enchant the weapon the creature is wielding.
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"
void AddDamageEffectToWeapon(object oTarget, float fDuration, int nCasterLevel, int nDamageType)
{
    int nOnHit;
    if(nDamageType == DAMAGE_TYPE_FIRE) { nDamageType = ITEM_VISUAL_FIRE; nOnHit = 148; }
    else if(nDamageType == DAMAGE_TYPE_ACID) { nDamageType = ITEM_VISUAL_ACID; nOnHit = 149; }
    else if(nDamageType == DAMAGE_TYPE_COLD) { nDamageType = ITEM_VISUAL_COLD; nOnHit = 150; }
    else if(nDamageType == DAMAGE_TYPE_ELECTRICAL) { nDamageType = ITEM_VISUAL_ELECTRICAL; nOnHit = 151; }
    else if(nDamageType == DAMAGE_TYPE_SONIC) { nDamageType = ITEM_VISUAL_SONIC; nOnHit = 152; }
    else if(nDamageType == DAMAGE_TYPE_POSITIVE) { nDamageType = ITEM_VISUAL_HOLY; nOnHit = 153; }
    else if(nDamageType == DAMAGE_TYPE_NEGATIVE) { nDamageType = ITEM_VISUAL_EVIL; nOnHit = 154; }
    else if(nDamageType == DAMAGE_TYPE_MAGICAL) { nDamageType = ITEM_VISUAL_SONIC; nOnHit = 155; }
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitCastSpell (nOnHit, nCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect (nDamageType), fDuration,X2_IP_ADDPROP_POLICY_IGNORE_EXISTING, FALSE, TRUE);
}
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDescriptor = DESC_FIRE;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iDamageType = DAMAGE_TYPE_FIRE;
    Spell.iImpact = VFX_IMP_PULSE_FIRE;
    // Setup the spell.
    Spell = SetSpell(Spell);
    // Check to see if we should still fire off the spell.
    if(Spell.iSpellID == STOP_SPELL) return;
    // Set duration as an item enchantment for special feats.
    Spell = GetDuration(Spell, TRUE);
    // *******************************************************************
    // ********************** Spell effects ******************************
    // *******************************************************************
    int nDamageDice = 6;
    int nEnhancedBonus;
    if(GetLocalInt(Spell.oCaster, "0_Use_Enhancing_Component"))
    {
        object oComponentPouch = GetLocalObject(Spell.oCaster, COMPONENT_POUCH);
        // If they have Eschew Materials and no pouch then we check the caster for the component.
        if(oComponentPouch == OBJECT_INVALID && GetHasFeat(1306/*Eschew Materials*/, Spell.oCaster)) oComponentPouch = Spell.oCaster;
        if(oComponentPouch != OBJECT_INVALID)
        {
            // Do a special check for enhancing components in one inventory pass.
            int nStack, nGarnetDust, nGoldlineDust, nDamageChange, nDamageType, nAmountToRemove;
            string sDamageType;
            object oItem = GetFirstItemInInventory(oComponentPouch);
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
                else if(!nDamageChange && GetTag(oItem) == "brandeen_dust") nDamageType = DAMAGE_TYPE_ACID;
                else if(!nDamageChange && GetTag(oItem) == "konerupine_dust") nDamageType = DAMAGE_TYPE_SONIC;
                else if(!nDamageChange && GetTag(oItem) == "tchazar_dust") nDamageType = DAMAGE_TYPE_COLD;
                else if(!nDamageChange && GetTag(oItem) == "waterstar_dust") nDamageType = DAMAGE_TYPE_ELECTRICAL;
                else if(!nDamageChange && GetTag(oItem) == "heliodor_dust") { nDamageType = DAMAGE_TYPE_POSITIVE; nAmountToRemove = 4; }
                else if(!nDamageChange && GetTag(oItem) == "moonbar_dust") { nDamageType = DAMAGE_TYPE_NEGATIVE; nAmountToRemove = 4; }
                else if(!nDamageChange && GetTag(oItem) == "water_opal_dust") { nDamageType = DAMAGE_TYPE_MAGICAL; nAmountToRemove = 4; }
                if(nDamageType)
                {
                    if(nAmountToRemove ==0) nAmountToRemove = 1;
                    nStack = GetItemStackSize(oItem);
                    if(nStack >= nAmountToRemove)
                    {
                        if(nStack > nAmountToRemove) SetItemStackSize(oItem, nStack - nAmountToRemove);
                        else DestroyObject (oItem);
                        nDamageChange = TRUE;
                        Spell.iDamageType = nDamageType;
                        if(nDamageType == DAMAGE_TYPE_ACID) sDamageType = "acid";
                        else if(nDamageType == DAMAGE_TYPE_SONIC) sDamageType = "sonic";
                        else if(nDamageType == DAMAGE_TYPE_COLD) sDamageType = "cold";
                        else if(nDamageType == DAMAGE_TYPE_ELECTRICAL) sDamageType = "electrical";
                        else if(nDamageType == DAMAGE_TYPE_POSITIVE) sDamageType = "positive energy";
                        else if(nDamageType == DAMAGE_TYPE_NEGATIVE) sDamageType = "negative energy";
                        else if(nDamageType == DAMAGE_TYPE_MAGICAL) sDamageType = "magical";
                        SendMessages("Darkfire's damage type has been changed to " + sDamageType + "!", COLOR_GREEN, Spell.oCaster);
                    }
                    nDamageType = 0;
                }
                oItem = GetNextItemInInventory(oComponentPouch);
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
            }
        }
    }
    int nDamageType, nBaseItemType;
    object oWeapon, oPossessor;
    // Create visual effects.
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // Link effects.
    if(Spell.iDamageType == DAMAGE_TYPE_FIRE) nDamageType = VFX_IMP_FLAME_M;
    else if(Spell.iDamageType == DAMAGE_TYPE_ACID) nDamageType = VFX_IMP_ACID_L;
    else if(Spell.iDamageType == DAMAGE_TYPE_COLD) nDamageType = VFX_IMP_FROST_L;
    else if(Spell.iDamageType == DAMAGE_TYPE_ELECTRICAL) nDamageType = VFX_IMP_LIGHTNING_M;
    else if(Spell.iDamageType == DAMAGE_TYPE_SONIC) nDamageType = VFX_IMP_SONIC;
    else if(Spell.iDamageType == DAMAGE_TYPE_POSITIVE) nDamageType = VFX_IMP_HOLY_AID;
    else if(Spell.iDamageType == DAMAGE_TYPE_NEGATIVE) nDamageType = VFX_IMP_NEGATIVE_ENERGY;
    else if(Spell.iDamageType == DAMAGE_TYPE_MAGICAL) nDamageType = VFX_IMP_DISPEL;
    effect eLink = EffectLinkEffects (EffectVisualEffect(nDamageType), eImpact);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid (Spell.oAreaTarget))
    {
        oWeapon = GetTargetedOrEquippedWeapon(Spell.oAreaTarget);
        // Must be a melee weapon.
        if(oWeapon != OBJECT_INVALID)
        {
            oPossessor = GetItemPossessor(oWeapon);
            SignalEvent(oPossessor, EventSpellCastAt(Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand(Spell.fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oPossessor));
            DelayCommand(Spell.fDelay, ApplyEffectToObject(Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // haaaack: store caster level on item for the on hit spell to work properly
            // Also adding the damage dice and damage type as variables on the weapon to be used in onhit script.
            SetLocalInt(oWeapon, "0_DMG_DICE", nDamageDice);
            SetLocalInt(oWeapon, "0_DMG_TYPE", Spell.iDamageType);
            AddDamageEffectToWeapon (oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
            if(nEnhancedBonus > 0)
            {
                DelayCommand(Spell.fDelay, IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nEnhancedBonus), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
            }
            if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_CREATURE)
            {
                nBaseItemType = GetBaseItemType(oWeapon);
                if(nBaseItemType == BASE_ITEM_CSLASHWEAPON ||
                   nBaseItemType == BASE_ITEM_CPIERCWEAPON ||
                   nBaseItemType == BASE_ITEM_CBLUDGWEAPON ||
                   nBaseItemType == BASE_ITEM_CSLSHPRCWEAP)
                {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, Spell.oAreaTarget);
                    SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                    SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                    AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
                    if(nEnhancedBonus > 0)
                    {
                        DelayCommand(Spell.fDelay, IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nEnhancedBonus), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
                    }
                }
                else
                {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, Spell.oAreaTarget);
                    if(GetIsWeapon(oWeapon))
                    {
                        SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                        SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                        AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
                        if(nEnhancedBonus > 0)
                        {
                            DelayCommand(Spell.fDelay, IPSafeAddItemProperty(oWeapon, ItemPropertyEnhancementBonus(nEnhancedBonus), Spell.fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING , TRUE, TRUE));
                        }
                    }
                }
            }
        }
        else FloatingTextStrRefOnCreature(83615, OBJECT_SELF);
        //Get the spells target(s).
        Spell = GetSpellTarget(Spell);
    }
    CleanUpSpell(Spell);
}

