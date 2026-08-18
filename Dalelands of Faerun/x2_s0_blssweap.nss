/*////////////////////////////////////////////////
 Script: X2_S0_BlssWeap
 Programmer: Andrew Nobbs
////////////////////////////////////////////////
Transmutation
Level:  Pal 1
Components: V, S
Casting Time:   1 standard action
Range:  Touch
Target: Weapon touched
Duration:   1 min./level
Saving Throw:   None
Spell Resistance:   No

  If cast on a crossbow bolt, it adds the ability to
  slay rakshasa's on hit

  If cast on a melee weapon, it will add the
      grants a +1 enhancement bonus.
      grants a +2d6 damage divine to undead
  will add a holy vfx when command becomes available
  If cast on a creature it will pick the first
  melee weapon without these effects
/*///////////////////////////////////////////////
#include "0i_spells"
#include "x2_inc_itemprop"
void AddBlessEffectToWeapon (object oTarget, int nModifier, int nDamageDice, float fDuration)
{
   // If the spell is cast again, any previous enhancement boni are kept
   IPSafeAddItemProperty (oTarget, ItemPropertyEnhancementBonus(nModifier), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE);
   // Replace existing temporary anti undead boni
   IPSafeAddItemProperty (oTarget, ItemPropertyDamageBonusVsRace (IP_CONST_RACIALTYPE_UNDEAD, IP_CONST_DAMAGETYPE_DIVINE, nDamageDice), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   IPSafeAddItemProperty (oTarget, ItemPropertyVisualEffect (ITEM_VISUAL_HOLY), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
   return;
}
void main()
{
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_MAGICAL;
    Spell.iDurationType = DURATION_TYPE_MINUTES;
    Spell.iAreaShape = SHAPE_TOUCH_TARGET;
    Spell.iTargetType = TARGET_TYPE_ALLIES;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE;
    Spell.iDuration = 1;
    Spell.iDurPerLvl = 1;
    Spell.iModifier = 1;
    Spell.iModPerLvl = 1;
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
    int nDamageDice = IP_CONST_DAMAGEBONUS_2d6;
    int nEnhancedBonus, nBaseItemType;
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
                    if(nDamageDice == IP_CONST_DAMAGEBONUS_2d6) nDamageDice = IP_CONST_DAMAGEBONUS_2d8;
                    else if(nDamageDice == IP_CONST_DAMAGEBONUS_2d8) nDamageDice += IP_CONST_DAMAGEBONUS_2d10;
                    else if(nDamageDice == IP_CONST_DAMAGEBONUS_2d10) nDamageDice += IP_CONST_DAMAGEBONUS_2d12;
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
            SendMessages(sSpellName + " has been enhanced to increase the damage dice by one die!", COLOR_GREEN, oObject);
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
    object oPossessor, oMyWeapon;
    effect eImpact = EffectVisualEffect (Spell.iImpact);
    effect eDur = EffectVisualEffect (VFX_DUR_CESSATE_POSITIVE);
    // ---------------- TARGETED ON BOLT  -------------------
    if (GetIsObjectValid(Spell.oTarget) && GetObjectType(Spell.oTarget) == OBJECT_TYPE_ITEM)
    {
        // special handling for blessing crossbow bolts that can slay rakshasa's
        if (GetBaseItemType(Spell.oTarget) == BASE_ITEM_BOLT)
        {
           oPossessor = GetItemPossessor (Spell.oTarget);
           SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
           IPSafeAddItemProperty(Spell.oTarget, ItemPropertyOnHitCastSpell (123, 1), Spell.fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oPossessor);
           ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, Spell.fDuration);
           return;
        }
    }
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while(GetIsObjectValid(Spell.oAreaTarget))
    {
        oMyWeapon = GetTargetedOrEquippedWeapon (Spell.oAreaTarget);
        if(oMyWeapon != OBJECT_INVALID)
        {
            oPossessor = GetItemPossessor(oMyWeapon);
            SignalEvent (oPossessor, EventSpellCastAt (Spell.oCaster, Spell.iSpellID, FALSE));
            DelayCommand (Spell.fDelay, AddBlessEffectToWeapon (oMyWeapon, Spell.iResult, nDamageDice, Spell.fDuration));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, oPossessor));
            DelayCommand (Spell.fDelay, ApplyEffectToObject (Spell.iDurationType, eDur, oPossessor, Spell.fDuration));
            if(GetObjectType(Spell.oAreaTarget) == OBJECT_TYPE_CREATURE)
            {
                nBaseItemType = GetBaseItemType(oMyWeapon);
                if(nBaseItemType == BASE_ITEM_CSLASHWEAPON ||
                   nBaseItemType == BASE_ITEM_CPIERCWEAPON ||
                   nBaseItemType == BASE_ITEM_CBLUDGWEAPON ||
                   nBaseItemType == BASE_ITEM_CSLSHPRCWEAP)
                {
                    oMyWeapon = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, Spell.oAreaTarget);
                    DelayCommand (Spell.fDelay, AddBlessEffectToWeapon(oMyWeapon, Spell.iResult, nDamageDice, Spell.fDuration));
                }
                else
                {
                    oMyWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, Spell.oAreaTarget);
                    if(GetIsWeapon(oMyWeapon))
                    {
                        DelayCommand (Spell.fDelay, AddBlessEffectToWeapon(oMyWeapon, Spell.iResult, nDamageDice, Spell.fDuration));
                    }
                }
            }
        }
        else DelayCommand (Spell.fDelay, FloatingTextStrRefOnCreature(83615, Spell.oAreaTarget));
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    CleanUpSpell (Spell);
}
