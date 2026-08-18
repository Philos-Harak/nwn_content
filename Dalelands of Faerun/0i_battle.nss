/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_battle
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for combat scripts.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
#include "0i_items"
#include "0i_states"
#include "0i_checks"
// Does a ranged attack & damage to oTarget with oWeapon and oAmmo.
// oAttacker the creature making the attack.
// oWeapon the ranged weapon making the attack with.
// oAmmo the ammo used in the attack if there is any.
// oTarget the creature the attack is being attempted on.
void DoRangedAttack (object oAttacker, object oWeapon, object oAmmo, object oTarget);
// Does a ranged attack & damage to oTarget.
// oAttacker the creature making the attack.
// oTarget the creature the attack is being attempted on.
// nAtkBonus the number to add to the attack roll.
// nDmgType : DAMAGE_TYPE_PIERCING, DAMAGE_TYPE_BLUDGEONING.
// nDmgDice : 1d6, 2d8, 2d4+5, etc.
// bEffect TRUE show arrow effect, FALSE show nothing.
void DoSpecificRangedAttack (object oAttacker, object oTarget, int nAtkBonus, int nDmgType, string sDmgDice, int bEffect);
// Gets the Breath weapon DC for the dragon.
int GetDragonDC (object oCreature = OBJECT_SELF);

int GetPropDamageType (itemproperty ipProp)
{
    int iCostTableValue = GetItemPropertyCostTableValue (ipProp);
    int iDmg;
    switch (iCostTableValue)
    {
       case 1: iDmg = 1; break;
       case 2: iDmg = 2; break;
       case 3: iDmg = 3; break;
       case 4: iDmg = 4; break;
       case 5: iDmg = 5; break;
       case 6: iDmg = d4(); break;
       case 7: iDmg = d6(); break;
       case 8: iDmg = d8(); break;
       case 9: iDmg = d10(); break;
       case 10: iDmg = d6(2); break;
       case 11: iDmg = d8(2); break;
       case 12: iDmg = d4(2); break;
       case 13: iDmg = d10(2); break;
       case 14: iDmg = d12(); break;
       case 15: iDmg = d12(2); break;
       case 16: iDmg = 6; break;
       case 17: iDmg = 7; break;
       case 18: iDmg = 8; break;
       case 19: iDmg = 9; break;
       case 20: iDmg = 10; break;
       default: iDmg = 1; break;
   }
   return iDmg;
}
// Does a ranged attack & damage to oTarget with oWeapon and oAmmo.
// oAttacker the creature making the attack.
// oWeapon the ranged weapon making the attack with.
// oAmmo the ammo used in the attack if there is any.
// oTarget the creature the attack is being attempted on.
void DoRangedAttack (object oAttacker, object oWeapon, object oAmmo, object oTarget)
{
    int iAB, iAC, iRoll, iCheck, iProp, iSubProp, iCostTableValue, iParam1Value;
    string sMessage, sHit;
    float fDistance, fDelay;
    //int iTargetAlign1, iTargetAlign2, iTargetRace, iAttackAlign1, iAttackAlign2, iAttackRace;
    itemproperty ipProp;
    //**************************************************************************
    //*********  Do Attack! ****************************************************
    //**************************************************************************
    iAB = NWNX_Creature_GetAttackBonus (oAttacker, 0);
    iAC = GetAC (oTarget);
    iRoll = d20();
    // iCheck is a hit if > -1 and a miss if < 0;
    if (iRoll == 20) iCheck = 20;
    else if (iRoll > 1) iCheck = iRoll + iAB - iAC;
    else iCheck == 0;
    // If they missed then set the hit to FALSE or 0;
    if (iCheck < 1) iCheck = 0;
    //**************************************************************************
    //*********  Do Damage! ****************************************************
    //**************************************************************************
    int iFire, iAcid, iCold, iElectrical, iPositive, iNegative, iDivine, iMagical, iSonic;
    int iDmg, iMagicImpact, iBludgeoning, iPiercing, iSlashing, iArrowEffect;
    int iDieToRoll, iNumDice, iWeaponType, iBaseItemType;
    string sProjSound;
    // Get any damage properties from weapon.
    // Get base weapon damage.
    iBaseItemType = GetBaseItemType (oWeapon);
    // Play weapon sound.
    if (iBaseItemType == BASE_ITEM_HEAVYCROSSBOW || iBaseItemType == BASE_ITEM_LIGHTCROSSBOW)
    {
        if (d2() == 1) PlaySound ("cb_sh_xbow1");
        else PlaySound ("cb_sh_xbow2");
    }
    else if (iBaseItemType == BASE_ITEM_LONGBOW || BASE_ITEM_SHORTBOW)
    {
        if (d2() == 1) PlaySound ("cb_sh_bow1");
        else PlaySound ("cb_sh_bow2");
    }
    else if (iBaseItemType == BASE_ITEM_SLING)
    {
        if (d2() == 1) PlaySound ("cb_sh_sling1");
        else PlaySound ("cb_sh_sling2");
    }
    // Get 1)Piercing 2)Blundgeoning 3)Slashing
    iWeaponType = StringToInt (Get2DAString ("baseitems", "WeaponType", iBaseItemType));
    iNumDice = StringToInt (Get2DAString ("baseitems", "NumDice", iBaseItemType));
    iDieToRoll = StringToInt (Get2DAString ("baseitems", "DieToRoll", iBaseItemType));
    // Roll base weapon damage;
    while (iNumDice > 0)
    {
        iDmg = iDmg + Random (iDieToRoll) + 1;
        iNumDice--;
    }
    switch (iWeaponType)
    {
        case 1: iPiercing = iDmg; break;
        case 2: iBludgeoning = iDmg; break;
        case 3: iSlashing = iDmg; break;
    }
    ipProp = GetFirstItemProperty (oWeapon);
    while (GetIsItemPropertyValid (ipProp))
    {
        iProp = GetItemPropertyType (ipProp);
        if (iProp == ITEM_PROPERTY_ENHANCEMENT_BONUS)
        {
            switch (iWeaponType)
            {
                case 1: iPiercing += GetItemPropertyCostTableValue (ipProp); break;
                case 2: iBludgeoning += GetItemPropertyCostTableValue (ipProp); break;
                case 3: iSlashing += GetItemPropertyCostTableValue (ipProp); break;
            }
        }
        else if (iProp == ITEM_PROPERTY_DAMAGE_BONUS)
        {
            iDmg = GetPropDamageType (ipProp);
            iSubProp = GetItemPropertySubType (ipProp);
            switch (iSubProp)
            {
                case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
            }
        }
        else if (iProp == ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP)
        {
            int iTargetAlign1 = GetAlignmentLawChaos (oTarget);
            int iTargetAlign2 = GetAlignmentGoodEvil (oTarget);
            iSubProp = GetItemPropertySubType (ipProp);
            if (iTargetAlign1 == iSubProp || iTargetAlign2 == iSubProp)
            {
                iDmg = GetPropDamageType (ipProp);
                iParam1Value = GetItemPropertyParam1Value (ipProp);
                switch (iParam1Value)
                {
                    case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                }
            }
        }
        else if (iProp == ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP)
        {
            int iTargetRace = GetRacialType (oTarget);
            iSubProp = GetItemPropertySubType (ipProp);
            if (iTargetRace == iSubProp)
            {
                iDmg = GetPropDamageType (ipProp);
                iParam1Value = GetItemPropertyParam1Value (ipProp);
                switch (iParam1Value)
                {
                    case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                }
            }
        }
        ipProp = GetNextItemProperty (oWeapon);
    }
    if (GetIsObjectValid (oAmmo))
    {
        // Get any damage properties of the ammo.
        ipProp = GetFirstItemProperty (oAmmo);
        while (GetIsItemPropertyValid (ipProp))
        {
            iProp = GetItemPropertyType (ipProp);
            if (iProp == ITEM_PROPERTY_DAMAGE_BONUS)
            {
                iDmg = GetPropDamageType (ipProp);
                iSubProp = GetItemPropertySubType (ipProp);
                switch (iSubProp)
                {
                    case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                }
            }
            else if (iProp == ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP)
            {
                int iTargetAlign1 = GetAlignmentLawChaos (oTarget);
                int iTargetAlign2 = GetAlignmentGoodEvil (oTarget);
                iSubProp = GetItemPropertySubType (ipProp);
                if (iTargetAlign1 == iSubProp || iTargetAlign2 == iSubProp)
                {
                    iDmg = GetPropDamageType (ipProp);
                    iParam1Value = GetItemPropertyParam1Value (ipProp);
                    switch (iParam1Value)
                    {
                        case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    }
                }
            }
            else if (iProp == ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP)
            {
                int iTargetRace = GetRacialType (oTarget);
                iSubProp = GetItemPropertySubType (ipProp);
                if (iTargetRace == iSubProp)
                {
                    iDmg = GetPropDamageType (ipProp);
                    iParam1Value = GetItemPropertyParam1Value (ipProp);
                    switch (iParam1Value)
                    {
                        case 0: iBludgeoning += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 1: iPiercing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 2: iSlashing += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 5: iMagical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 6: iAcid += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 7: iCold += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 8: iDivine += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 9: iElectrical += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 10: iFire += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 11: iNegative += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 12: iPositive += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                        case 13: iSonic += iDmg; iArrowEffect = VFX_DUR_MIRV_ACID; break;
                    }
                }
            }
            ipProp = GetNextItemProperty (oAmmo);
        }
    }
    // Get distance and delay vs target.
    fDistance = GetDistanceBetween (oAttacker, oTarget);
    fDelay = fDistance / 25.0f;
    // Shoot arrow through the air, show hit or miss based on iCheck.
    effect eArrow = EffectVisualEffect (iArrowEffect, !iCheck);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eArrow, oTarget);
    if (iCheck) sHit = "*hit*";
    else sHit = "*miss*";
    sMessage =  AddColorToText (GetName (oAttacker), COLOR_LIGHT_MAGENTA) +
                AddColorToText (" attacks " + GetName (oTarget) + " : " + sHit + " : (" +
                               IntToString (iRoll) + " + " + IntToString (iAB) +
                               " = " + IntToString (iRoll + iAB) + ")", COLOR_DARK_ORANGE);
    DelayCommand (fDelay - 0.1f, SendMessageToPC (oAttacker, sMessage));
    DelayCommand (fDelay - 0.1f, SendMessageToPC (oTarget, sMessage));
    if (iCheck)
    {
        effect eDmg, eElement, eImpact, eDuration;
        // Apply any damage to the target!
        if (iBludgeoning)
        {
            iMagicImpact = 0;
            eDmg = EffectDamage (iBludgeoning, DAMAGE_TYPE_BLUDGEONING);
            sProjSound = "cb_ht_arrow1";
        }
        if (iPiercing)
        {
            iMagicImpact = 0;
            eDmg = EffectDamage (iPiercing, DAMAGE_TYPE_PIERCING);
            sProjSound = "";
            sProjSound = "cb_ht_arrow1";
        }
        if (iSlashing)
        {
            iMagicImpact = 0;
            eDmg = EffectDamage (iSlashing, DAMAGE_TYPE_SLASHING);
            sProjSound = "";
            sProjSound = "cb_ht_arrow1";
        }
        if (iMagical)
        {
            iMagicImpact = 0;
            eElement = EffectDamage (iMagical, DAMAGE_TYPE_MAGICAL);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlelec";
        }
        if (iAcid)
        {
            iMagicImpact = VFX_COM_HIT_ACID;
            eElement = EffectDamage (iAcid, DAMAGE_TYPE_ACID);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlacid";
        }
        if (iCold)
        {
            iMagicImpact = VFX_COM_HIT_FROST;
            eDmg = EffectDamage (iCold, DAMAGE_TYPE_COLD);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlcold";
        }
        if (iDivine)
        {
            iMagicImpact = VFX_COM_HIT_DIVINE;
            eElement = EffectDamage (iDivine, DAMAGE_TYPE_DIVINE);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlcold";
        }
        if (iElectrical)
        {
            iMagicImpact = VFX_COM_HIT_ELECTRICAL;
            eElement = EffectDamage (iElectrical, DAMAGE_TYPE_ELECTRICAL);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlelec";
        }
        if (iFire)
        {
            iMagicImpact = VFX_COM_HIT_FIRE;
            eElement = EffectDamage (iFire, DAMAGE_TYPE_FIRE);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlfire";
        }
        if (iNegative)
        {
            iMagicImpact = VFX_COM_HIT_NEGATIVE;
            eElement = EffectDamage (iNegative * NWNX_Object_GetDamageImmunity (oTarget, DAMAGE_TYPE_NEGATIVE), DAMAGE_TYPE_NEGATIVE);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlsonc";
        }
        if (iPositive)
        {
            iMagicImpact = VFX_COM_HIT_DIVINE;
            eElement = EffectDamage (iPositive, DAMAGE_TYPE_POSITIVE);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlcold";
        }
        if (iSonic)
        {
            iMagicImpact = VFX_COM_HIT_SONIC;
            eElement = EffectDamage (iSonic, DAMAGE_TYPE_SONIC);
            eDmg = EffectLinkEffects (eElement, eDmg);
            sProjSound = "cb_sh_prjtlsonc";
        }
        if (iMagicImpact > 0)
        {
            eImpact = EffectVisualEffect (iMagicImpact);
            eDmg = EffectLinkEffects (eImpact, eDmg);
        }
        DelayCommand (fDelay, PlaySound (sProjSound));
        DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget));
        eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
        eImpact = EffectVisualEffect (VFX_DUR_ARROW_IN_CHEST_RIGHT);
        eDuration = EffectLinkEffects (eImpact, eDuration);
        DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eDuration, oTarget, 30.0f));
    }
}
// Does a ranged attack & damage to oTarget.
// oAttacker the creature making the attack.
// oTarget the creature the attack is being attempted on.
// nAtkBonus the number to add to the attack roll.
// nDmgType : DAMAGE_TYPE_PIERCING, DAMAGE_TYPE_BLUDGEONING.
// nDmgDice : 1d6, 2d8, 2d4+5, etc.
// bEffect TRUE show arrow effect, FALSE show nothing.
void DoSpecificRangedAttack (object oAttacker, object oTarget, int nAtkBonus, int nDmgType, string sDmgDice, int bEffect)
{
    int nAC, nRoll, nCheck;
    string sMessage, sHit;
    float fDistance, fDelay;
    //**************************************************************************
    //*********  Do Attack! ****************************************************
    //**************************************************************************
    nAC = GetAC (oTarget);
    nRoll = d20();
    // nCheck is a hit if > -1 and a miss if < 0;
    if (nRoll == 20) nCheck = 20;
    else if (nRoll > 1) nCheck = nRoll + nAtkBonus - nAC;
    else nCheck == 0;
    // If they missed then set the hit to FALSE or 0;
    if (nCheck < 1) nCheck = 0;
    //**************************************************************************
    //*********  Do Damage! ****************************************************
    //**************************************************************************
    int nFire, nAcid, nCold, nElectrical, nPositive, nNegative, nDivine, nMagical, nSonic;
    int nDmg, nMagicImpact, nBludgeoning, nPiercing, nSlashing, nArrowEffect;
    // Roll damage;
    nDmg = RollDiceString (sDmgDice);
    // Get distance and delay vs target.
    fDistance = GetDistanceBetween (oAttacker, oTarget);
    fDelay = fDistance / 25.0f;
    // Shoot arrow through the air, show hit or miss based on nCheck.
    effect eArrow = EffectVisualEffect (nArrowEffect, !nCheck);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eArrow, oTarget);
    if (nCheck) sHit = "*hit*";
    else sHit = "*miss*";
    sMessage =  GetName (oAttacker) +
                AddColorToText (" attacks ", COLOR_DARK_ORANGE) + GetName (oTarget) +
                AddColorToText (" : " + sHit + " : (" + IntToString (nRoll) +
                " + " + IntToString (nAtkBonus) + " = " +
                IntToString (nRoll + nAtkBonus) + ")", COLOR_DARK_ORANGE);
    DelayCommand (fDelay - 0.1f, SendMessageToPC (oAttacker, sMessage));
    DelayCommand (fDelay - 0.1f, SendMessageToPC (oTarget, sMessage));
    if (nCheck)
    {
        effect eDmg, eElement, eImpact, eDuration;
        // Apply any damage to the target!
        if (nDmgType == DAMAGE_TYPE_BLUDGEONING ||
            nDmgType == DAMAGE_TYPE_PIERCING ||
            nDmgType == DAMAGE_TYPE_SLASHING)
        {
            nMagicImpact = 0;
            eDmg = EffectDamage (nDmg, nDmgType);
        }
        // Left these in so we can add magical damage later.
        if (nMagical)
        {
            nMagicImpact = 0;
            eElement = EffectDamage (nMagical, DAMAGE_TYPE_MAGICAL);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nAcid)
        {
            nMagicImpact = VFX_COM_HIT_ACID;
            eElement = EffectDamage (nAcid, DAMAGE_TYPE_ACID);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nCold)
        {
            nMagicImpact = VFX_COM_HIT_FROST;
            eDmg = EffectDamage (nCold, DAMAGE_TYPE_COLD);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nDivine)
        {
            nMagicImpact = VFX_COM_HIT_DIVINE;
            eElement = EffectDamage (nDivine, DAMAGE_TYPE_DIVINE);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nElectrical)
        {
            nMagicImpact = VFX_COM_HIT_ELECTRICAL;
            eElement = EffectDamage (nElectrical, DAMAGE_TYPE_ELECTRICAL);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nFire)
        {
            nMagicImpact = VFX_COM_HIT_FIRE;
            eElement = EffectDamage (nFire, DAMAGE_TYPE_FIRE);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nNegative)
        {
            nMagicImpact = VFX_COM_HIT_NEGATIVE;
            eElement = EffectDamage (nNegative * NWNX_Object_GetDamageImmunity (oTarget, DAMAGE_TYPE_NEGATIVE), DAMAGE_TYPE_NEGATIVE);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nPositive)
        {
            nMagicImpact = VFX_COM_HIT_DIVINE;
            eElement = EffectDamage (nPositive, DAMAGE_TYPE_POSITIVE);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nSonic)
        {
            nMagicImpact = VFX_COM_HIT_SONIC;
            eElement = EffectDamage (nSonic, DAMAGE_TYPE_SONIC);
            eDmg = EffectLinkEffects (eElement, eDmg);
        }
        if (nMagicImpact > 0)
        {
            eImpact = EffectVisualEffect (nMagicImpact);
            eDmg = EffectLinkEffects (eImpact, eDmg);
        }
        DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oTarget));
        if (bEffect)
        {
            eDuration = EffectVisualEffect (VFX_DUR_CESSATE_NEGATIVE);
            eImpact = EffectVisualEffect (VFX_DUR_ARROW_IN_CHEST_RIGHT);
            eDuration = EffectLinkEffects (eImpact, eDuration);
            DelayCommand (fDelay, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eDuration, oTarget, 30.0f));
        }
    }
}
// Gets the Breath weapon DC for the dragon.
int GetDragonDC (object oCreature = OBJECT_SELF)
{
    int nDC, nHitDice = GetHitDice (oCreature);
    if (nHitDice < 4) { nDC = 12; }
    else if (nHitDice < 7) { nDC = 13; }
    else if (nHitDice < 10) { nDC = 14; }
    else if (nHitDice < 13) { nDC = 16; }
    else if (nHitDice < 16) { nDC = 18; }
    else if (nHitDice < 19) { nDC = 20; }
    else if (nHitDice < 22) { nDC = 22; }
    else if (nHitDice < 25) { nDC = 24; }
    else if (nHitDice < 28) { nDC = 26; }
    else if (nHitDice < 31) { nDC = 28; }
    else if (nHitDice < 34) { nDC = 30; }
    else if (nHitDice < 37) { nDC = 32; }
    else if (nHitDice < 39) { nDC = 34; }
    else { nDC = 36; }
    string sTag = GetTag (oCreature);
    if (sTag == "gold_dragon") nDC += 5;
    if (sTag == "red_dragon" || sTag == "silver_dragon")  return nDC + 4;
    else if (sTag == "black_dragon" || sTag == "brass_dragon") return nDC + 3;
    else if (sTag == "green_dragon" || sTag == "copper_dragon")  return nDC + 2;
    else if (sTag == "blue_dragon" || sTag == "bronze_dragon")  return nDC + 1;
    //else if (sTag == "white_dragon") nDC += 0;
    return nDC;
}
