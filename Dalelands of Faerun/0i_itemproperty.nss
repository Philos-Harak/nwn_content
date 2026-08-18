/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_itemproperty
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts help create item properties.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"

// Gets the first item property of oItem.
// Where nItemPropertyType is equal to the first itemproperty.
// Returns -1 if the item does not have that itemproperty.
itemproperty GetIPOfItem(object oItem, int nItemPropertyType);

// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty(object oItem);

// Checks and items and returns that itemproperty if it has the property type.
// iSubType checks for the sub type of property if it is not -1.
// iCostTableValue checks for the CostTableValue of property if it is not -1.
// Returns the item property if found other wise invalid property.
itemproperty HasProperty(object oItem, int iProperty, int iSubType = -1, int iCostTableValue = -1);

// Checks and items and returns the number of magical properties it has.
// It ignores property 86 as that is an items quality.
int GetNumberOfProperties(object oItem);

// Removes all Items properties based on duration.
// But will not remove the quality.
void RemoveAllItemProperties(object oItem, int iDuration = DURATION_TYPE_TEMPORARY);

// Removes all Item properties with a specific tag.
void RemoveTaggedItemProperties(object oItem, string sTag);

// Checks to see if the item has the property (1).
// If not then creates the property on the item.
// iType = IP_CONST_ABILITY_*.
// iModifier is a number between 1 and 12.
int IP_ABBonus(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (2).
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
// If sName is not "" then it will add it to the end otherwise it adds the modifier to the begining.
// sName: " +" + iModifier + " " + ItemName + " of " + sName (+2 Headband of Intellect).
int IP_ACBonus(object oItem, int iModifier);

// Checks to see if the item has the property (3).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_ACBonusVsAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (4).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_ACBonusVsRace(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (5).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
int IP_ACBonusVsSAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (6).
// If not then creates the property on the item.
// iModifier = 9)-5%, 8)-10%, 7)-15%, 6)-20%, 5)-25% 4)-30% 3)-35% 2)-40% 1)-45% 0)-50%.
int IP_ArcaneSpellFailure(object oItem, int iModifier);

// Checks to see if the item has the property (7).
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
int IP_AttackBonus(object oItem, int iModifier);

// Checks to see if the item has the property (8).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (9).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsRace(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (10).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsSAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (11).
// If not then creates the property on the item.
// iModifier is a number between 1 and 5.
//void IP_AttackPenalty (object oItem, int iModifier);

// Checks to see if the item has the property (12).
// If not then creates the property on the item.
// iType = IP_CONST_FEAT_*.
int IP_BonusFeat(object oItem, int iType);

// Checks to see if the item has the property (13).
// If not then creates the property on the item.
// iType can be a value from 1-25.
int IP_BonusHP(object oItem, int iType);

// Checks to see if the item has the property (14).
// If not then creates the property on the item.
// iType = IP_CONST_CLASS_*.
// iModifier is a number between 0 and 9.
int IP_BonusSpellLevel(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (15).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEBASETYPE_*.
// iModifier is a numbet between 1 and 20.
int IP_BonusSavingThrow(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (16).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEVS_*.
// iModifier is a numbet between 1 and 20.
int IP_BonusSavingThrowVsX(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (17).
// If not then creates the property on the item.
// iModifier = IP_CONST_SPELLRESISTANCEBONUS_*.
int IP_BonusSpellResistance(object oItem, int iModifier);

// Checks to see if the item has the property (18).
// If not then creates the property on the item.
// iType = IP_CONST_CASTSPELL_*.
// iModifier = IP_CONST_CASTSPELL_NUMUSES_*.
int IP_CastSpell(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (19).
// If not then creates the property on the item.
// iModifier = IP_CONST_CONTAINERWEIGHTRED_*.
int IP_ContainerReduceWeight(object oItem, int iModifier);

// Checks to see if the item has the property (20).
// If not then creates the property on the item.
// iType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonus(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (22).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsAlign(object oItem, int iType, int iSubType, int iModifier);

// Checks to see if the item has the property (23).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsRace(object oItem, int iType, int iSubType, int iModifier);

// Checks to see if the item has the property (24).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsSAlign(object oItem, int iType, int iSubType, int iModifier);

// Checks to see if the item has the property (25).
// If not then creates the property on the item.
// iType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEIMMUNITY_*.
int IP_DamageImmunity(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (26).
// If not then creates the property on the item.
// iType = IP_CONST_DAMAGETYPE_*.
// iModifier is a number between 1 and 5. (ie. 1 will give a penalty of 1).
//void IP_DamagePenalty(object oItem, int iModifier);

// Checks to see if the item has the property (27).
// If not then creates the property on the item.
// iType: IP_CONST_DAMAGETYPE_*
// iModifier is IP_CONST_DAMAGERESIST_*
// sName : ItemName + sTypeName + " resistance, " + sModName (Chain shirt Fire resistance, Improved).
int IP_DamageResistance(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (28).
// If not then creates the property on the item.
//void IP_Darkvision (object oItem);

// Checks to see if the item has the property (29).
// If not then creates the property on the item.
// iType = IP_CONST_ABILITY_*.
// iModifier is a number between 1 and 10. (ie. 1 will give a penalty of 1).
//void IP_DecreaseAB(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (30).
// If not then creates the property on the item.
// iType = IP_CONST_ACMODIFIERTYPE_*.
// iModifier is a number between 1 and 5. (ie. 1 will give a penalty of 1).
//void IP_DecreaseAC(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (31).
// If not then creates the property on the item.
// iType = SKILL_*.
// iModifier is a number between 1 and 10. (ie. 1 will give a penalty of 1).
//void IP_DecreaseSkill(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (32).
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
int IP_Enhancement(object oItem, int iModifier);

// Checks to see if the item has the property (33).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (34).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsRace(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (35).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsSAlign(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (36).
// If not then creates the property on the item.
// iModifier is a number between 1 and 5. (ie. 1 will give a penalty of 1).
//void IP_EnhancementPenalty(object oItem, int iModifier);

// Checks to see if the item has the property (37).
// If not then creates the property on the item.
// iModifier = IP_CONST_IMMUNITYSPELL_*.
int IP_ImmunitySpecific(object oItem, int iModifier);

// Checks to see if the item has the property (38).
// If not then creates the property on the item.
int IP_Keen(object oItem);

// Checks to see if the item has the property (39).
// If not then creates the property on the item.
// iType = IP_CONST_LIGHTCOLOR_*.
// iModifier = IP_CONST_LIGHTBRIGHTNESS_*.
int IP_Light(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (40).
// If not then creates the property on the item.
// iModifier = IP_CONST_ALIGNMENTGROUP_*.
int IP_LimitUseByAlign(object oItem, int iModifier);

// Checks to see if the item has the property (41).
// If not then creates the property on the item.
// iModifier = IP_CONST_CLASS_*.
int IP_LimitUseByClass(object oItem, int iModifier);

// Checks to see if the item has the property (42).
// If not then creates the property on the item.
// iModifier = IP_CONST_RACIALTYPE_*.
int IP_LimitUseByRace(object oItem, int iModifier);

// Checks to see if the item has the property (43).
// If not then creates the property on the item.
// iModifier = IP_CONST_ALIGNMENT_*.
int IP_LimitUseBySAlign(object oItem, int iModifier);

// Checks to see if the item has the property (44).
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
//void IP_Mighty(object oItem, int iModifier);

// Checks to see if the item has the property (45).
// If not then creates the property on the item.
// iType = IP_CONST_CASTSPELL_*.
// iModifier this is a number between 1 and 20.
//void IP_OnHitCastSpell(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (46).
// If not then creates the property on the item.
// iType = IP_CONST_ONHIT_*.
// iSubType = IP_CONST_ONHIT_SAVEDC_*.
// iModifier the special depends on the ONHIT type.
//      ABILITYDRAIN      :nSpecial is the ability it is to drain.
//                         constant(IP_CONST_ABILITY_*)
//      BLINDNESS         :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      CONFUSION         :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      DAZE              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      DEAFNESS          :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      DISEASE           :nSpecial is the type of desease that will effect the victim.
//                         constant(DISEASE_*)
//      DOOM              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      FEAR              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      HOLD              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      ITEMPOISON        :nSpecial is the type of poison that will effect the victim.
//                         constant(IP_CONST_POISON_*)
//      SILENCE           :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      SLAYRACE          :nSpecial is the race that will be slain.
//                         constant(IP_CONST_RACIALTYPE_*)
//      SLAYALIGNMENTGROUP:nSpecial is the alignment group that will be slain(ie. chaotic).
//                         constant(IP_CONST_ALIGNMENTGROUP_*)
//      SLAYALIGNMENT     :nSpecial is the specific alignment that will be slain.
//                         constant(IP_CONST_ALIGNMENT_*)
//      SLEEP             :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      SLOW              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//      STUN              :nSpecial is the duration/percentage of effecting victim.
//                         constant(IP_CONST_ONHIT_DURATION_*)
//void IP_OnHitProps(object oItem, int iType, int iSubType, int iModifier);

// Checks to see if the item has the property (47).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEBASETYPE_*.
// iModifier this is a number between 1 and 20 (ie. 1 will give a penalty of 1).
//void IP_ReduceSavingThrow(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (48).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEVS_*.
// iModifier this is a number between 1 and 20 (ie. 1 will give a penalty of 1).
//void IP_ReduceSavingThrowVsX(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (49).
// If not then creates the property on the item.
// iModifier this is a number between 1 and 20.
int IP_Regeneration(object oItem, int iModifier);

// Checks to see if the item has the property (50).
// If not then creates the property on the item.
// iType = SKILL_*.
// iModifier this is a number between 1 and 50.
int IP_SkillBonus(object oItem, int iType, int iModifier);

// Checks to see if the item has the property (51).
// If not then creates the property on the item.
// iType = IP_CONST_UNLIMITEDAMMO_*.
int IP_UnlimitedAmmo(object oItem, int iType);

// Checks to see if the item has the property (52).
// If not then creates the property on the item.
// iModifier this is a number between 1 and 20.
int IP_VampiricRegeneration(object oItem, int iModifier);

// Checks to see if the item has the property (53).
// If not then creates the property on the item.
// iType = ITEM_VISUAL_*.
//void IP_VisualEffect(object oItem, int iType);

// Checks to see if the item has the property (54).
// If not then creates the property on the item.
// iType = IP_CONST_WEIGHTINCREASE_*.
//void IP_WeightIncrease(object oItem, int iType);

// Checks to see if the item has the property (55).
// If not then creates the property on the item.
// iModifier = IP_CONST_REDUCEDWEIGHT_*.
int IP_WeightReduction(object oItem, int iModifier);

// Checks to see if the item has the property (56).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
// iSubModifier = IP_CONST_ALIGNMENT_*.
int IP_BaneAlignment(object oItem, int iType, int iSubType, int iModifier, int iSubModifier);

// Checks to see if the item has the property (57).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier is a number between 1 and 20.
// iSubModifier = IP_CONST_DAMAGEBONUS_*.
int IP_BaneRacial(object oItem, int iType, int iSubType, int iModifier, int iSubModifier);

// Checks to see if the item has the property (58).
// If not then creates the property on the item.
int IP_Haste(object oItem);

// Gives oItem the property set in jProperty.
// jProperty {Item property index, Property Type, SubPropertyType,
//            CostTable Value, Param1 Value, Item window fX, Item window fY}
void AddRawItemProperty(object oPC, object oItem, json jProperty);

// Gets the first item property of oItem.
// Where nItemPropertyType is equal to the first itemproperty.
// Returns -1 if the item does not have that itemproperty.
itemproperty GetIPOfItem (object oItem, int nItemPropertyType)
{
    itemproperty ip = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ip))
    {
        if (GetItemPropertyType (ip) == nItemPropertyType)
        {
            return ip;
        }
        ip = GetNextItemProperty (oItem);
    }
    return ip;
}

// Returns TRUE/FALSE if item has temporary item property.
int CheckForTemporaryItemProperty (object oItem)
{
    itemproperty ipProperty;
    ipProperty = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        // Check to see if the item is temporary enchanted.
        if (GetItemPropertyDurationType (ipProperty) == DURATION_TYPE_TEMPORARY) return TRUE;
        ipProperty = GetNextItemProperty (oItem);
    }
    return FALSE;
}
// Checks and items and returns that itemproperty if it has the property type
// iSubType checks for the sub type of property if it is not -1.
// iCostTableValue checks for the CostTableValue of property if it is not -1.
// Returns the item property if found other wise invalid property.
itemproperty HasProperty (object oItem, int iProperty, int iSubType = -1, int iCostTableValue = -1)
{
   int iCounter = 1, iStringProperty, iStringType, iPropertyFound;
    // Get first property
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        // Check to see if the property type matches.
        iPropertyFound = GetItemPropertyType (ipProperty);
        if (GetItemPropertyType (ipProperty) == iProperty)
        {
            // Should we check the subtype.
            if (iSubType > -1)
            {
                // Check to see if the sub type matches.
                if (GetItemPropertySubType (ipProperty) == iSubType) return ipProperty;
            }
            // Should we check the subtype.
            else if (iCostTableValue > -1)
            {
                // Check to see if the sub type matches.
                if (GetItemPropertyCostTableValue (ipProperty) == iCostTableValue) return ipProperty;
            }
            // Return true as we are not check the type.
            else return ipProperty;
        }
        // Get the next property.
        ipProperty = GetNextItemProperty (oItem);
    }
    return ipProperty;
}

// Checks and items and returns the number of magical properties it has.
int GetNumberOfProperties(object oItem)
{
    int iNumOfProperties = 0, iPropertyType, iPropertySubType;
    // Get first property
    itemproperty ipProperty = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ipProperty))
    {
        // Ignore double type properties such as bane.
        iPropertyType = GetItemPropertyType(ipProperty);
        switch(iPropertyType)
        {
            // Skip these properties as they don't count.
            case 8 : break; // EnhanceAlignmentGroup
            case 44 : break; // Light
            case 62 : break; // UseLimitationAlignmentGroup
            case 63 : break; // UseLimitationClass
            case 64 : break; // UseLimitationRacial
            case 65 : break; // UseLimitationSpecificAlignment
            case 66 : break; // UseLimitationTerrain
            case 86 : break; // Quality
            case 150 : break; // UseLimitationGender
            // Not sure why we are ignoring castable item powers?
            //case 15 :
            //{
            //    iPropertySubType = GetItemPropertySubType(ipProperty);
            //    if (iPropertySubType == IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY) break;
            //    if (iPropertySubType == IP_CONST_CASTSPELL_UNIQUE_POWER) break;
            //}
            default : iNumOfProperties ++;
        }
        // Get the next property
        ipProperty = GetNextItemProperty (oItem);
    }
    // Reduce the number of properties by one on whips.
    if(GetBaseItemType(oItem) == BASE_ITEM_WHIP) iNumOfProperties --;
   return iNumOfProperties;
}

// Removes all Items properties based on duration.
// But will not remove the quality.
void RemoveAllItemProperties (object oItem, int iDuration = DURATION_TYPE_TEMPORARY)
{
    itemproperty ip = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ip))
    {
        if (GetItemPropertyDurationType (ip) == iDuration &&
            GetItemPropertyType (ip) != 86/*Quality*/)
        {
            object oPossessor = GetItemPossessor (oItem);
            RemoveItemProperty (oItem, ip);
        }
        ip = GetNextItemProperty (oItem);
    }
}

// Removes all Item properties with a specific tag.
void RemoveTaggedItemProperties (object oItem, string sTag)
{
    itemproperty ipProp = GetFirstItemProperty (oItem);
    while (GetIsItemPropertyValid (ipProp))
    {
        if (GetItemPropertyTag (ipProp) == sTag) RemoveItemProperty (oItem, ipProp);
        ipProp = GetNextItemProperty (oItem);
    }
}

// Checks to see if the item has the property 1 (property type 0).
// If not then creates the property on the item.
// iType = IP_CONST_ABILITY_*.
// iModifier is a number between 1 and 12.
int IP_ABBonus (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 0, iType)))
    {
        itemproperty ipProperty = ItemPropertyAbilityBonus (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 2 (property type 1).
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
int IP_ACBonus (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 1)))
    {
        itemproperty ipProperty = ItemPropertyACBonus (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 3 (property type 2).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_ACBonusVsAlign (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 2, iType)))
    {
        itemproperty ipProperty = ItemPropertyACBonusVsAlign (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 4 (property type 4).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_ACBonusVsRace (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 4, iType)))
    {
        itemproperty ipProperty = ItemPropertyACBonusVsRace (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 5.(property type 5)
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
// sName: " +" + Modifier + " " + ItemName + " vs " + TypeName (+3 Chain Shirt vs Chaotic Evil).
int IP_ACBonusVsSAlign (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 5, iType)))
    {
        itemproperty ipProperty = ItemPropertyACBonusVsSAlign (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 6 (property type 84).
// If not then creates the property on the item.
// iModifier = 9)-5%, 8)-10%, 7)-15%, 6)-20%, 5)-25% 4)-30% 3)-35% 2)-40% 1)-45% 0)-50%.
int IP_ArcaneSpellFailure (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 84)))
    {
        itemproperty ipProperty = ItemPropertyArcaneSpellFailure (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 7 (property type 56.
// If not then creates the property on the item.
// iModifier is a number between 1 and 20.
int IP_AttackBonus (object oItem, int iModifier)
{
     itemproperty ipProperty;
     if (!GetIsItemPropertyValid (HasProperty (oItem, 56)))
     {
         ipProperty = ItemPropertyAttackBonus (iModifier);
         AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
     }
     else return FALSE;
     return TRUE;
}

// Checks to see if the item has the property 8 (property type 57).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsAlign (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 57, iType)))
    {
        itemproperty ipProperty = ItemPropertyAttackBonusVsAlign (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 9 (property type 58.
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsRace (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 58, iType)))
    {
        itemproperty ipProperty = ItemPropertyAttackBonusVsRace (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 10 (property type 59).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
int IP_AttackBonusVsSAlign (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 59, iType)))
    {
        itemproperty ipProperty = ItemPropertyAttackBonusVsSAlign (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 12 (property type 12).
// If not then creates the property on the item.
// also checks to see if it is a bow or crossbow to select rapid shot or rapid reload.
// iType = IP_CONST_FEAT_*.
int IP_BonusFeat (object oItem, int iType)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 12, iType)))
    {
        itemproperty ipProperty = ItemPropertyBonusFeat (iType);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 13 (property type ?).
// If not then creates the property on the item.
// iModifier can be a value from 1-26.
/*(int IP_BonusHP (object oItem, int iModifier)
{
   if (!GetIsItemPropertyValid (HasProperty (oItem, 13)))
   {
      itemproperty ipProperty = ItemPropertyBonusHitpoints (iModifier);
      AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
   }
   else return FALSE;
   return TRUE;
}*/

// Checks to see if the item has the property 14 (property type 13).
// If not then creates the property on the item.
// iType = IP_CONST_CLASS_*.
// iModifier is a number between 0 and 9.
int IP_BonusSpellLevel (object oItem, int iType, int iModifier)
{
    // Special check to see if we are adding a new bonus spell.
    // If so then add another of the same caster type.
    int iCounter = 1, iStringProperty, iStringType;
    // Check to see if it already has a bonus spell slot.
    itemproperty ipProperty = HasProperty (oItem, 13);
    // If it does have one then add the same caster type.
    if (GetIsItemPropertyValid (ipProperty)) iType = GetItemPropertySubType (ipProperty);
    // Add the spell slot to the item.
    ipProperty = ItemPropertyBonusLevelSpell (iType, iModifier);
    AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    return TRUE;
}

// Checks to see if the item has the property 15 (property type 41).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEBASETYPE_*.
// iModifier is a numbet between 1 and 20.
int IP_BonusSavingThrow (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 41, iType)))
    {
       itemproperty ipProperty = ItemPropertyBonusSavingThrow (iType, iModifier);
       AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 16 (property type 40).
// If not then creates the property on the item.
// iType = IP_CONST_SAVEVS_*.
// iModifier is a numbet between 1 and 20.
int IP_BonusSavingThrowVsX (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 40, iType)))
    {
        itemproperty ipProperty = ItemPropertyBonusSavingThrowVsX (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 17 (property type 39).
// If not then creates the property on the item.
// iModifier = IP_CONST_SPELLRESISTANCEBONUS_*.
int IP_BonusSpellResistance (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 39)))
    {
        itemproperty ipProperty = ItemPropertyBonusSpellResistance (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 18 (property type 15).
// If not then creates the property on the item.
// iType = IP_CONST_CASTSPELL_*.
// iModifier = IP_CONST_CASTSPELL_NUMUSES_*.
int IP_CastSpell (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 15, iType)))
    {
        itemproperty ipProperty = ItemPropertyCastSpell (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property (19) (property type 32).
// If not then creates the property on the item.
// iModifier = IP_CONST_CONTAINERWEIGHTRED_*.
int IP_ContainerReduceWeight (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 32)))
    {
        itemproperty ipProperty = ItemPropertyContainerReducedWeight (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 20 (property type 16).
// If not then creates the property on the item.
// iType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonus (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 16, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageBonus (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 22 (property type 17).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsAlign (object oItem, int iType, int iSubType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 17, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageBonusVsAlign (iType, iSubType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 23 (property type 18).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsRace (object oItem, int iType, int iSubType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 18, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageBonusVsRace (iType, iSubType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 24 (property type 19).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
int IP_DamageBonusVsSAlign (object oItem, int iType, int iSubType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 19, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageBonusVsSAlign (iType, iSubType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 25 (property type 20).
// If not then creates the property on the item.
// iType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEIMMUNITY_*.
int IP_DamageImmunity (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 20, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageImmunity (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 27 (property type 23).
// If not then creates the property on the item.
// iType: IP_CONST_DAMAGETYPE_*
// iModifier is IP_CONST_DAMAGERESIST_*
int IP_DamageResistance (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 23, iType)))
    {
        itemproperty ipProperty = ItemPropertyDamageResistance (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 32 (property type 6).
// If not then creates the property on the item.
// iModifier is a number between 1 and 5.
int IP_Enhancement (object oItem, int iModifier)
{
    int iPropertyCheck, iPropertySubType;
    itemproperty ipProperty;
    if (GetIsAmmo (oItem))
    {
        iPropertyCheck = 16;
        iPropertySubType = IP_CONST_DAMAGETYPE_MAGICAL;
        ipProperty = ItemPropertyDamageBonus (IP_CONST_DAMAGETYPE_MAGICAL, iModifier);
    }
    else
    {
        iPropertyCheck = 6;
        iPropertySubType = -1;
        ipProperty = ItemPropertyEnhancementBonus (iModifier);
    }
    if (!GetIsItemPropertyValid (HasProperty (oItem, iPropertyCheck, iPropertySubType)))
    {
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 33 (property type 7).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsAlign (object oItem, int iType, int iModifier)
{
    int iPropertyCheck, iPropertySubType;
    itemproperty ipProperty;
    if (GetIsAmmo (oItem))
    {
        iPropertyCheck = 17;
        iPropertySubType = IP_CONST_DAMAGETYPE_MAGICAL;
        ipProperty = ItemPropertyDamageBonusVsAlign (iType, IP_CONST_DAMAGETYPE_MAGICAL, iModifier);
    }
    else
    {
        iPropertyCheck = 7;
        iPropertySubType = -1;
        ipProperty = ItemPropertyEnhancementBonusVsAlign (iType, iModifier);
    }
    if (!GetIsItemPropertyValid (HasProperty (oItem, iPropertyCheck, iPropertySubType)))
    {
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 34 (property type 8).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsRace (object oItem, int iType, int iModifier)
{
    int iPropertyCheck, iPropertySubType;
    itemproperty ipProperty;
    if (GetIsAmmo (oItem))
    {
        iPropertyCheck = 18;
        iPropertySubType = IP_CONST_DAMAGETYPE_MAGICAL;
        ipProperty = ItemPropertyDamageBonusVsRace (iType, IP_CONST_DAMAGETYPE_MAGICAL, iModifier);
    }
    else
    {
        iPropertyCheck = 8;
        iPropertySubType = -1;
        ipProperty = ItemPropertyEnhancementBonusVsRace (iType, iModifier);
    }
    if (!GetIsItemPropertyValid (HasProperty (oItem, iPropertyCheck, iPropertySubType)))
    {
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 35 (property type 9).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENT_*.
// iModifier is a number between 1 and 20.
int IP_EnhancementVsSAlign (object oItem, int iType, int iModifier)
{
    int iPropertyCheck, iPropertySubType;
    itemproperty ipProperty;
    if (GetIsAmmo (oItem))
    {
        iPropertyCheck = 19;
        iPropertySubType = IP_CONST_DAMAGETYPE_MAGICAL;
        ipProperty = ItemPropertyDamageBonusVsSAlign (iType, IP_CONST_DAMAGETYPE_MAGICAL, iModifier);
    }
    else
    {
        iPropertyCheck = 9;
        iPropertySubType = -1;
        ipProperty = ItemPropertyEnhancementBonusVsSAlign (iType, iModifier);
    }
    if (!GetIsItemPropertyValid (HasProperty (oItem, iPropertyCheck, iPropertySubType)))
    {
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 37 (property type 53).
// If not then creates the property on the item.
// iModifier = IP_CONST_IMMUNITYSPELL_*.
int IP_ImmunitySpecific (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 53, -1, iModifier)))
    {
        itemproperty ipProperty = ItemPropertySpellImmunitySpecific (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 38 (propertyt type 43).
// If not then creates the property on the item.
int IP_Keen (object oItem)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 43)))
    {
        itemproperty ipProperty = ItemPropertyKeen ();
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 39 (property type 44).
// If not then creates the property on the item.
// iType = IP_CONST_LIGHTCOLOR_* (0 Blue to 6 White).
// iModifier = IP_CONST_LIGHTBRIGHTNESS_* (1 Dim to 4 Bright).
int IP_Light (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 44)))
    {
        itemproperty ipProperty = ItemPropertyLight (iModifier, iType);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 40 (property type 62).
// If not then creates the property on the item.
// iModifier = IP_CONST_ALIGNMENTGROUP_*.
int IP_LimitUseByAlign (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 62)))
    {
        itemproperty ipProperty = ItemPropertyLimitUseByAlign (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 41 (property type 63).
// If not then creates the property on the item.
// iModifier = IP_CONST_CLASS_*.
int IP_LimitUseByClass (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 63)))
    {
        itemproperty ipProperty = ItemPropertyLimitUseByClass (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 42 (property type 64).
// If not then creates the property on the item.
// iModifier = IP_CONST_RACIALTYPE_*.
int IP_LimitUseByRace (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 64)))
    {
        itemproperty ipProperty = ItemPropertyLimitUseByRace (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 43 (property type 65).
// If not then creates the property on the item.
// iModifier = IP_CONST_ALIGNMENT_*.
int IP_LimitUseBySAlign (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 65)))
    {
        itemproperty ipProperty = ItemPropertyLimitUseBySAlign (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 49 (property type 51).
// If not then creates the property on the item.
// iModifier this is a number between 1 and 20.
int IP_Regeneration(object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 51)))
    {
        itemproperty ipProperty = ItemPropertyRegeneration (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 50 (property type 52).
// If not then creates the property on the item.
// iType = SKILL_*.
// iModifier this is a number between 1 and 50.
int IP_SkillBonus (object oItem, int iType, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 52, iType)))
    {
        itemproperty ipProperty = ItemPropertySkillBonus (iType, iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 51 (property type 61).
// If not then creates the property on the item.
// iType = IP_CONST_UNLIMITEDAMMO_*.
int IP_UnlimitedAmmo (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 61)))
    {
        itemproperty ipProperty = ItemPropertyUnlimitedAmmo (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 52 (property type 67).
// If not then creates the property on the item.
// iModifier this is a number between 1 and 20.
int IP_VampiricRegeneration (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 67)))
    {
        itemproperty ipProperty = ItemPropertyVampiricRegeneration (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 55 (property type 11).
// If not then creates the property on the item.
// iType = IP_CONST_REDUCEDWEIGHT_*.
int IP_WeightReduction (object oItem, int iModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 11)))
    {
        itemproperty ipProperty = ItemPropertyWeightReduction (iModifier);
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 56 (property type 17).
// If not then creates the property on the item.
// iType = IP_CONST_ALIGNMENTGROUP_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier = IP_CONST_DAMAGEBONUS_*.
// iSubModifier = IP_CONST_ALIGNMENTGROUP_*.
int IP_BaneAlignment (object oItem, int iType, int iSubType, int iModifier, int iSubModifier)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 17, iType)))
    {
          itemproperty ipProperty = ItemPropertyDamageBonusVsAlign (iType, iSubType, iModifier);
          AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
          ipProperty = ItemPropertyLimitUseByAlign (iSubModifier);
          AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 57 (property type 18).
// If not then creates the property on the item.
// iType = IP_CONST_RACIALTYPE_*.
// iSubType = IP_CONST_DAMAGETYPE_*.
// iModifier is a number between 1 and 20.
// iSubModifier = IP_CONST_DAMAGEBONUS_*.
int IP_BaneRacial (object oItem, int iType, int iSubType, int iModifier, int iSubModifier)
{
    int iPropertyCheck;
    itemproperty ipProperty;
    if (GetIsAmmo (oItem))
    {
        iPropertyCheck = 18;
    }
    else
    {
        iPropertyCheck = 8;
        ipProperty = ItemPropertyEnhancementBonusVsRace (iType, iModifier);
    }
    if (!GetIsItemPropertyValid (HasProperty (oItem, iPropertyCheck, iType)))
    {
         if (iPropertyCheck == 8) AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
         ipProperty = ItemPropertyDamageBonusVsRace (iType, iSubType, iSubModifier);
         AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}

// Checks to see if the item has the property 58 (property type 35).
// If not then creates the property on the item.
int IP_Haste (object oItem)
{
    if (!GetIsItemPropertyValid (HasProperty (oItem, 35)))
    {
        itemproperty ipProperty = ItemPropertyHaste();
        AddItemProperty (DURATION_TYPE_PERMANENT, ipProperty, oItem);
    }
    else return FALSE;
    return TRUE;
}
// Gives oItem the property set in jProperty.
// jProperty {Item property index, Property Type, SubPropertyType,
//            CostTable Value, Param1 Value, Item window fX, Item window fY}
void AddRawItemProperty(object oPC, object oItem, json jProperty)
{
    int nPropertyType = JsonGetInt(JsonArrayGet(jProperty, 1));
    int nSubType = JsonGetInt(JsonArrayGet(jProperty, 2));
    int nCostTableValue = JsonGetInt(JsonArrayGet(jProperty, 3));
    int nParamValue = JsonGetInt(JsonArrayGet(jProperty, 4));
    switch(nPropertyType)
    {
        case 0 :
        {
            itemproperty ip = ItemPropertyAbilityBonus(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 1 :
        {
            itemproperty ip = ItemPropertyACBonus(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 2 :
        {
            itemproperty ip = ItemPropertyACBonusVsAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 3 :
        {
            itemproperty ip = ItemPropertyACBonusVsDmgType(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 4 :
        {
            itemproperty ip = ItemPropertyACBonusVsRace(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 5 :
        {
            itemproperty ip = ItemPropertyACBonusVsSAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 6 :
        {
            itemproperty ip = ItemPropertyEnhancementBonus(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 7 :
        {
            itemproperty ip = ItemPropertyEnhancementBonusVsAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 8 :
        {
            itemproperty ip = ItemPropertyEnhancementBonusVsRace(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 9 :
        {
            itemproperty ip = ItemPropertyEnhancementBonusVsSAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 10 :
        {
            itemproperty ip = ItemPropertyAttackPenalty(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 11 :
        {
            itemproperty ip = ItemPropertyWeightReduction(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 12 :
        {
            itemproperty ip = ItemPropertyBonusFeat(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 13 :
        {
            itemproperty ip = ItemPropertyBonusLevelSpell(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        //case 14 :
        case 15 :
        {
            itemproperty ip = ItemPropertyCastSpell(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 16 :
        {
            itemproperty ip = ItemPropertyDamageBonus(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 17 :
        {
            itemproperty ip = ItemPropertyDamageBonusVsAlign(nSubType, nParamValue, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 18 :
        {
            itemproperty ip = ItemPropertyDamageBonusVsRace(nSubType, nParamValue, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 19 :
        {
            itemproperty ip = ItemPropertyDamageBonusVsSAlign(nSubType, nParamValue, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 20 :
        {
            itemproperty ip = ItemPropertyDamageImmunity(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 21 :
        {
            itemproperty ip = ItemPropertyDamagePenalty(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 22 :
        {
            itemproperty ip = ItemPropertyDamageReduction(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 23 :
        {
            itemproperty ip = ItemPropertyDamageResistance(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 24 :
        {
            itemproperty ip = ItemPropertyDamageVulnerability(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 25 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 26 :
        {
            itemproperty ip = ItemPropertyDarkvision();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 27 :
        {
            itemproperty ip = ItemPropertyDecreaseAbility(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 28 :
        {
            itemproperty ip = ItemPropertyDecreaseAC(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 29 :
        {
            itemproperty ip = ItemPropertyDecreaseSkill(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 30 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        //case 31 :
        case 32 :
        {
            if(GetHasInventory(oItem))
            {
                itemproperty ip = ItemPropertyWeightReduction(nCostTableValue);
                AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            }
            else SendMessages("This must be a container to get this property!", COLOR_RED, oPC);
            break;
        }
        case 33 :
        {
            itemproperty ip = ItemPropertyExtraMeleeDamageType(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 34 :
        {
            itemproperty ip = ItemPropertyExtraRangeDamageType(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 35 :
        {
            itemproperty ip = ItemPropertyHaste();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 36 :
        {
            if(GetIsMeleeWeapon(oItem))
            {
                itemproperty ip = ItemPropertyHolyAvenger();
                AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            }
            else SendMessages("This must be a melee weapon to get this property!", COLOR_RED, oPC);
            break;
        }
        case 37 :
        {
            itemproperty ip = ItemPropertyImmunityMisc(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 38 :
        {
            itemproperty ip = ItemPropertyImprovedEvasion();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 39 :
        {
            itemproperty ip = ItemPropertyBonusSpellResistance(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 40 :
        {
            itemproperty ip = ItemPropertyBonusSavingThrow(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 41 :
        {
            itemproperty ip = ItemPropertyBonusSavingThrowVsX(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 42 :
        {
            SendMessages("This property will need extra code to work!", COLOR_RED, oPC);
            break;
        }
        case 43 :
        {
            itemproperty ip = ItemPropertyKeen();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 44 :
        {
            itemproperty ip = ItemPropertyLight(nCostTableValue, nParamValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 45 :
        {
            itemproperty ip = ItemPropertyMaxRangeStrengthMod(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 46 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 47 :
        {
            itemproperty ip = ItemPropertyNoDamage();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 48 :
        {
            itemproperty ip = ItemPropertyOnHitProps(nSubType, nCostTableValue, 0);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            SendMessages("This property will need special code to allow all options!", COLOR_RED, oPC);
            break;
        }
        case 49 :
        {
            itemproperty ip = ItemPropertyReducedSavingThrow(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 50 :
        {
            itemproperty ip = ItemPropertyReducedSavingThrowVsX(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 51 :
        {
            itemproperty ip = ItemPropertyRegeneration(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 52 :
        {
            itemproperty ip = ItemPropertySkillBonus(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 53 :
        {
            itemproperty ip = ItemPropertySpellImmunitySpecific(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 54 :
        {
            itemproperty ip = ItemPropertySpellImmunitySchool(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 55 :
        {
            itemproperty ip = ItemPropertyThievesTools(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 56 :
        {
            itemproperty ip = ItemPropertyAttackBonus(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 57 :
        {
            itemproperty ip = ItemPropertyAttackBonusVsAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 58 :
        {
            itemproperty ip = ItemPropertyAttackBonusVsRace(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 59 :
        {
            itemproperty ip = ItemPropertyAttackBonusVsSAlign(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 60 :
        {
            itemproperty ip = ItemPropertyAttackPenalty(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 61 :
        {
            itemproperty ip = ItemPropertyUnlimitedAmmo(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 62 :
        {
            itemproperty ip = ItemPropertyLimitUseByAlign(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 63 :
        {
            itemproperty ip = ItemPropertyLimitUseByClass(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 64 :
        {
            itemproperty ip = ItemPropertyLimitUseByRace(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 65 :
        {
            itemproperty ip = ItemPropertyLimitUseBySAlign(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 66 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 67 :
        {
            itemproperty ip = ItemPropertyVampiricRegeneration(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 68 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 69 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 70 :
        {
            itemproperty ip = ItemPropertyTrap(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 71 :
        {
            itemproperty ip = ItemPropertyTrueSeeing();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 72 :
        {
            itemproperty ip = ItemPropertyOnMonsterHitProperties(nSubType);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            SendMessages("This property will need special code to allow all options!", COLOR_RED, oPC);
            break;
        }
        case 73 :
        {
            itemproperty ip = ItemPropertyTurnResistance(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 74 :
        {
            itemproperty ip = ItemPropertyMassiveCritical(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 75 :
        {
            itemproperty ip = ItemPropertyFreeAction();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 76 :
        {
            SendMessages("This property does not work!", COLOR_RED, oPC);
            break;
        }
        case 77 :
        {
            itemproperty ip = ItemPropertyMonsterDamage(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 78 :
        {
            itemproperty ip = ItemPropertyImmunityToSpellLevel(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 79 :
        {
            itemproperty ip = ItemPropertySpecialWalk();
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 80 :
        {
            itemproperty ip = ItemPropertyHealersKit(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 81 :
        {
            itemproperty ip = ItemPropertyWeightIncrease(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 82 :
        {
            itemproperty ip = ItemPropertyOnHitCastSpell(nSubType, nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 83 :
        {
            if(GetIsMeleeWeapon(oItem))
            {
                itemproperty ip = ItemPropertyVisualEffect(nSubType);
                AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            }
            else SendMessages("This must be a melee weapon to get this property!", COLOR_RED, oPC);
            break;
        }
        case 84 :
        {
            itemproperty ip = ItemPropertyArcaneSpellFailure(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 85 :
        {
            itemproperty ip = ItemPropertyMaterial(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 86 :
        {
            itemproperty ip = ItemPropertyQuality(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
        case 87 :
        {
            itemproperty ip = ItemPropertyAdditional(nCostTableValue);
            AddItemProperty(DURATION_TYPE_PERMANENT, ip, oItem);
            break;
        }
    }
}


