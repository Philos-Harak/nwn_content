/*////////////////////////////////////////////////
 Script Name: X2_S0_BldeThst
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Caster Level(s): Ranger 3
Innate Level: 3
School: Transmutation
Descriptor(s): Weapon Enchantment
Component(s): Verbal, Somatic
Range: Touch
Area of Effect / Target: Creature or slashing weapon.
Duration: 1 Round / Level
Save: None
Spell Resistance: No

You grant a slashing weapon a +3 enhancement bonus. If targeted on a creature,
the spell will enchant the weapon in the primary hand of the target.
The weapon takes on a blue, fiery glow, shedding illumination as if it were a torch.
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
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect (nDamageType), fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iDurationType = DURATION_TYPE_ROUNDS;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 3;
    Spell.iDamageType = DAMAGE_TYPE_MAGICAL;
    Spell.iImpact = VFX_IMP_SUPER_HEROISM;
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
    int nDamageDice, nEnhancedBonus;
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
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        // Make sure we have a weapon as the target.
        oWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        // Must be a melee weapon.
        if (GetIsMeleeWeapon (oWeapon))
        {
            oPossessor = GetItemPossessor (oWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            // Apply visual effects.
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            // Apply effect.
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyEnhancementBonus (Spell.iResult), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING , TRUE, TRUE));
            DelayCommand (Spell.fDelay, IPSafeAddItemProperty (oWeapon, ItemPropertyLight (IP_CONST_LIGHTBRIGHTNESS_NORMAL, IP_CONST_LIGHTCOLOR_BLUE), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING , TRUE, TRUE));
            if(nDamageDice)
            {
                // Also adding the damage dice and damage type as variables on the weapon to be used in onhit script.
                SetLocalInt(oWeapon, "0_Dmg_Dice", nDamageDice);
                SetLocalInt(oWeapon, "0_Dmg_Type", Spell.iDamageType);
                AddDamageEffectToWeapon(oWeapon, Spell.fDuration, Spell.iCasterLevel, Spell.iDamageType);
            }
        }
        // Display failure text.
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83621, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
