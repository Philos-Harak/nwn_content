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
// This structure is used to represent the number and type of
// enemies that a creature is facing, divided into four main
// categories: fighters, clerics, mages, monsters.
struct stClasses
{
    int FIGHTERS;
    int FIGHTER_LEVELS;
    int CLERICS;
    int CLERIC_LEVELS;
    int MAGES;
    int MAGE_LEVELS;
    int MONSTERS;
    int MONTERS_LEVELS;
    int TOTAL;
    int TOTAL_LEVELS;
};
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
// Wrapper for GetAttackTarget.
// This also checks a saved variable when a talent is used on a creature.
// Keeps the creature on the current target.
object GetAttackedTarget (object oCreature = OBJECT_SELF);
// Returns the nearest enemy that is not disabled.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 & nCType2, with
// corresponding values for nCValue1 & nCValue2.
// NOTE: CREATURE_TYPE_PERCEPTION = 7, PERCEPTION_SEEN = 7.
object GetNearestEnemy (object oObject = OBJECT_SELF, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1);
// Returns the nearest ally.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 & nCType2, with
// corresponding values for nCValue1 & nCValue2.
// NOTE: CREATURE_TYPE_PERCEPTION = 7, PERCEPTION_SEEN = 7.
object GetNearestAlly (object oObject = OBJECT_SELF, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1);
// Gets the number of alive enemies grouped near oTarget.
int GetNumEnemiesInGroup (object oTarget = OBJECT_SELF, float fDistance = RANGE_MELEE);
// Gets the number of alive allies grouped near oTarget.
int GetNumOfAlliesInGroup (object oTarget = OBJECT_SELF, float fDistance = RANGE_MELEE);
// Gets the number of creatures with nRacial_Type that can be seen within fDistance.
int GetRacialTypeCount (int nRacial_Type, float fDistance = 20.0f);
// Get the number and levels of all creatures within fRange.
// They are grouped into Fighters, Clerics, Mages, and Monsters.
struct stClasses AssessFactionClasses (int bEnemy = TRUE, float fRange = RANGE_BATTLEFIELD);
// This will return the class with the most levels.
// Returns a string of "FIGHTER", "CLERIC", "MAGE", or "MONSTER".
// Execute with AssesFactionClasses.
string GetMostDangerousClass (struct stClasses stCount);
// Will equip best weapon ranged or melee and looks at henchmens masters wishes.
void EquipBestWeapons (object oTarget);
// Equip melee weapon AND check for shield. Returns TRUE if equiped, FALSE if not.
int EquipBestMeleeWeapon (object oTarget = OBJECT_INVALID);
// Equip ranged weapon AND check for ammo. Returns TRUE if equiped, FALSE if not.
int EquipBestRangedWeapon (object oTarget = OBJECT_INVALID);
// Determine the percentage of hit points the object has left.
// Returns an integer between 0 - 100.
int GetPercentageHPLoss (object oCreature = OBJECT_SELF);
// Return true if oCreature is Invisible, shealth mode, or has sanctuary up.
int GetInvisible (object oCreature = OBJECT_SELF);
// Checks if the caster has a chance of effecting oTarget.
// Return TRUE if there is a good chance, FALSE if not.
// nSpell is the spell we are casting.
// sIndex is the index of the target saved on the creature casting the spell.
int CheckOffensiveSpellVsTarget (int nSpell, object oTarget);
// See if we need to use defensive casting for this spell!
// or if its too dangerous to cast in melee.
// returns TRUE if its ok to cast, FALSE if it is not.
int CheckCastingInMelee (int nSpell, int nMelee);
// Clears all variables that define objects in combat for oCreature.
void ClearCombatState (object oCreature = OBJECT_SELF);
// Creates the current combat state on oObject for associates.
// Creates Variables ENEMY_* for enemies and ALLY_* for allies.
// Returns the nearest enemy to oObject.
object SetAssociateCombatState (object oObject = OBJECT_SELF);
// Creates the current combat state on oObject for monsters.
// Creates Variables ENEMY_* for enemies and ALLY_* for allies.
// Returns the nearest enemy to oObject.
object SetMonsterCombatState (object oObject = OBJECT_SELF);
// Returns the index of the nearest creature seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetNearestCreatureTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the lowest combat rating target within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetLowestCombatRating (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the highest combat rating target within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestCombatRating (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the target with the most enemies in melee.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestMeleeTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the lowest combat rating target seen within fRange.
// Also checks health for spells so we don't over damage a target.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetLowestCombatRatingForSpell (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF);
// Returns the index of the highest combat rating target seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetHighestCombatRatingForSpell (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF);
// Returns the index of the target with least % of hitpoints.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetMostWoundedTargetForDamage (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF);
// Returns the index of the target with least % of hitpoints.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetMostWoundedTargetForHealing (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF);
// Returns the index of the nearest creature that is attacking an ally seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetBestSneakAttackTarget (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF);
// Finds a creature with the highest group of enemies around them.
// fRange is the range to check.
// sCreatureType is either ENEMY, or ALLY.
object GetGroupedSpellTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Checks to see if oTarget is in a dangerous Area of Effect.
// Returns TRUE if they are and FALSE if not.
int IsInADangerousAOE (object oTarget = OBJECT_SELF);
// Returns the index of the nearest target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetNearestTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the lowest combat rating target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetLowestCombatRatingNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the highest combat rating target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestCombatRatingNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Returns the index of the target with the most enemies seen in melee
// that is not in a dangerous AOE effect.
// If none is found then it will return 0.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestMeleeTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Finds a creature with the highest group of enemies around them that is
// not in a dangerous AOE effect.
// fRange is the range to check.
// sCreatureType is either ENEMY, or ALLY.
// sIndex is the index of the creature saved on oCreature.
object GetGroupedSpellTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF);
// Gets the nearest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetNearestTargetForMeleeCombat (int nMelee);
// Set the creatures ai scripts based on class.
// Gets the weakest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetWeakestTargetForMeleeCombat (int nMelee);
// Set the creatures ai scripts based on class.
// Gets the strongest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetStrongestTargetForMeleeCombat (int nMelee);
// Gets the Breath weapon DC for the dragon.
int GetDragonDC (object oCreature = OBJECT_SELF);
// Set the creatures ai scripts based on the first class or the variable
// "DEFAULT_AI_SCRIPT".
void SetCreatureAIScript (object oCreature = OBJECT_SELF);
// Set an associates ai scripts based on the first class.
void SetAssociateAIScript (object oCreature = OBJECT_SELF);

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
// Wrapper for GetAttackTarget.
// This will get the last attacked target as long as they are in combat.
object GetAttackedTarget (object oCreature = OBJECT_SELF)
{
    object oTarget = GetAttackTarget (oCreature);
    if (!GetIsObjectValid (oTarget)) oTarget = GetLocalObject (oCreature, "0_ATTACKED_TARGET");
    if (GetIsDead (oTarget)) return OBJECT_INVALID;
    return oTarget;
}
// Returns the nearest enemy creature that is not disabled.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 & nCType2, with
// corresponding values for nCValue1 & nCValue2.
object GetNearestEnemy (object oObject = OBJECT_SELF, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1)
{
    object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,
                                 REPUTATION_TYPE_ENEMY,
                                 oObject, nNth, nCType1, nCValue1, nCType2, nCValue2);
    while (oTarget != OBJECT_INVALID && Disabled (oTarget))
    {
        oTarget = GetNearestCreature (CREATURE_TYPE_REPUTATION,
                                     REPUTATION_TYPE_ENEMY,
                                     oObject, ++nNth, nCType1, nCValue1, nCType2, nCValue2);
    }
    return oTarget;
}
// Returns the nearest ally creature.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 with value for nCValue1.
object GetNearestAlly (object oObject = OBJECT_SELF, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1)
{
    return GetNearestCreature (CREATURE_TYPE_REPUTATION,
                               REPUTATION_TYPE_FRIEND,
                               oObject, ++nNth, nCType1, nCValue1, nCType2, nCValue2);
}

// Gets the number of enemies within melee with oTarget.
// Uses the Combat Situation variables to find them.
int GetNumOfEnemiesInMelee (object oTarget = OBJECT_SELF)
{
    int nMelee, nCnt = 1;
    float fDistance = GetLocalFloat (oTarget, ENEMY_RANGE + "1");
    while (fDistance != 0.0)
    {
        if (fDistance < RANGE_MELEE) nMelee ++;
        fDistance = GetLocalFloat (oTarget, ENEMY_RANGE + IntToString (++nCnt));
    }
    return nMelee;
}
// Gets the number of alive enemies grouped near oTarget.
int GetNumEnemiesInGroup (object oTarget = OBJECT_SELF, float fDistance = RANGE_MELEE)
{
    int nCnt;
    location lLocation = GetLocation (oTarget);
    object oCreature = GetFirstObjectInShape (SHAPE_SPHERE, fDistance, lLocation);
    while (oCreature != OBJECT_INVALID)
    {
        if (GetIsEnemy (oCreature) && !GetIsDead (oCreature)) nCnt++;
        oCreature = GetNextObjectInShape (SHAPE_SPHERE, fDistance, lLocation);
    }
    return nCnt;
}
// Gets the number of alive friends grouped near oTarget.
int GetNumOfAlliesInGroup (object oTarget = OBJECT_SELF, float fDistance = RANGE_MELEE)
{
    int nCnt;
    location lLocation = GetLocation (oTarget);
    object oCreature = GetFirstObjectInShape (SHAPE_SPHERE, fDistance, lLocation);
    while (oCreature != OBJECT_INVALID)
    {
        if (GetIsFriend (oCreature) && oTarget != oCreature && !GetIsDead (oCreature))
        {
            nCnt++;
        }
        oCreature = GetNextObjectInShape (SHAPE_SPHERE, fDistance, lLocation);
    }
    return nCnt;
}
// Gets the number of creatures with nRacial_Type that can be seen.
int GetRacialTypeCount (int nRacial_Type, float fDistance = 20.0f)
{
    int nCnt = 1;
    int nCount = 0;
    object oTarget = GetNearestEnemy (OBJECT_SELF, nCnt,
                                      CREATURE_TYPE_PERCEPTION,
                                      PERCEPTION_SEEN,
                                      CREATURE_TYPE_RACIAL_TYPE,
                                      nRacial_Type);
    while (oTarget != OBJECT_INVALID && GetDistanceToObject (oTarget) <= fDistance)
    {
        if (!GetHasEffect (EFFECT_TYPE_TURNED, oTarget)) nCount ++;
        nCnt ++;
        oTarget = GetNearestEnemy (OBJECT_SELF, nCnt,
                                   CREATURE_TYPE_PERCEPTION,
                                   PERCEPTION_SEEN,
                                   CREATURE_TYPE_RACIAL_TYPE,
                                   nRacial_Type);
    }
    return nCount;
}
// Get the number and levels of all creatures within fRange.
// if bEnemy is TRUE then it will check all enemies, FALSE will check all allies.
// They are grouped into Fighters, Clerics, Mages, and Monsters.
struct stClasses AssessFactionClasses (int bEnemy = TRUE, float fRange = RANGE_BATTLEFIELD)
{
    struct stClasses sCount;
    int nCnt = 1, nClass, nLevels;
    object oTarget;
    if (bEnemy) oTarget = GetNearestEnemy (OBJECT_SELF, 1, 7, 7);
    else oTarget = GetNearestAlly (OBJECT_SELF, 1, 7, 7);
    while (oTarget != OBJECT_INVALID && GetDistanceToObject (oTarget) <= fRange)
    {
        //Debug ("0i_combat", "813", "Get classes, oTarget: " + GetName (oTarget));
        nClass = GetClassByPosition (1, oTarget);
        nLevels = GetHitDice (oTarget);
        if (nClass == CLASS_TYPE_ANIMAL ||
            nClass == CLASS_TYPE_BARBARIAN ||
            nClass == CLASS_TYPE_COMMONER ||
            nClass == CLASS_TYPE_CONSTRUCT ||
            nClass == CLASS_TYPE_ELEMENTAL ||
            nClass == CLASS_TYPE_FIGHTER ||
            nClass == CLASS_TYPE_GIANT ||
            nClass == CLASS_TYPE_HUMANOID ||
            nClass == CLASS_TYPE_MONSTROUS ||
            nClass == 45/*CLASS_TYPE_PALADIN*/ ||
            nClass == 46/*CLASS_TYPE_RANGER*/ ||
            nClass == CLASS_TYPE_ROGUE ||
            nClass == CLASS_TYPE_VERMIN ||
            nClass == CLASS_TYPE_MONK ||
            nClass == CLASS_TYPE_SHAPECHANGER ||
            nClass == 43/*CLASS_TYPE_SWASHBUCKLER*/)
        {
            sCount.FIGHTERS += 1;
            sCount.FIGHTER_LEVELS += nLevels;
        }
        else if(nClass == CLASS_TYPE_CLERIC ||
                nClass == CLASS_TYPE_DRUID ||
                nClass == 47/*CLASS_TYPE_FAVOREDSOUL*/)
        {
            sCount.CLERICS += 1;
            sCount.CLERIC_LEVELS += nLevels;
        }
        else if(nClass == CLASS_TYPE_BARD ||
                nClass == CLASS_TYPE_FEY ||
                nClass == CLASS_TYPE_SORCERER ||
                nClass == CLASS_TYPE_WIZARD)
        {
           sCount.MAGES += 1;
           sCount.MAGE_LEVELS += nLevels;
        }
        else if(nClass == CLASS_TYPE_ABERRATION ||
                nClass == CLASS_TYPE_DRAGON ||
                nClass == 29 || //oozes
                nClass == CLASS_TYPE_MAGICAL_BEAST ||
                nClass == CLASS_TYPE_OUTSIDER)
        {
           sCount.MONSTERS += 1;
           sCount.MONTERS_LEVELS += nLevels;
        }
        sCount.TOTAL += 1;
        sCount.TOTAL_LEVELS += nLevels;
        if (bEnemy) oTarget = GetNearestEnemy (OBJECT_SELF, ++nCnt, 7, 7);
        else oTarget = GetNearestAlly (OBJECT_SELF, ++nCnt, 7, 7);
    }
    return sCount;
}
// This will return the class with the most levels.
// Returns a string of "FIGHTER", "CLERIC", "MAGE", or "MONSTER".
// Execute with AssesFactionClasses.
string GetMostDangerousClass (struct stClasses stCount)
{
    string sClass;
    // Lets weight the fighter levels 30% higher.
    int nFighter = ((stCount.FIGHTER_LEVELS) * 13)/10;
    if (nFighter >= stCount.CLERIC_LEVELS)
    {
        if (nFighter >= stCount.MAGE_LEVELS)
        {
            if (nFighter >= stCount.MONTERS_LEVELS) return "FIGHTER";
            else return "MONSTER";
        }
        else if (stCount.MAGE_LEVELS >= stCount.MONTERS_LEVELS) return "MAGE";
        else return "MONSTER";
    }
    else if (stCount.CLERIC_LEVELS >= stCount.MAGE_LEVELS)
    {
        if (stCount.CLERIC_LEVELS >= stCount.MONTERS_LEVELS) return "CLERIC";
        else return "MONSTER";
    }
    else if(stCount.MAGE_LEVELS >= stCount.MONTERS_LEVELS) return "MAGE";
    else return "MONSTER";
    return "";
}
// Will equip best weapon ranged or melee and looks at henchmens masters wishes.
void EquipBestWeapons (object oTarget)
{
    // Lets not check for weapons on creatures that can't use them!
    int nRacialType = GetRacialType (OBJECT_SELF);
    if (nRacialType == RACIAL_TYPE_ANIMAL ||
        nRacialType == RACIAL_TYPE_DRAGON ||
        nRacialType == RACIAL_TYPE_MAGICAL_BEAST ||
        nRacialType == RACIAL_TYPE_OOZE ||
        nRacialType == RACIAL_TYPE_VERMIN) return;
    //if (Polymorphed ()) return;
    ClearAllActions ();
    //Debug ("0i_combat", "906", GetName (OBJECT_SELF) + " is equiping best weapon!");
    // Determine if I am wielding a ranged weapon, melee weapon, or none.
    int bIsWieldingRanged = HasRangedWeaponWithAmmo ();
    int bIsWieldingMelee = GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND));
    //Debug ("0i_combat", "910", "bIsWieldingRanged: " + IntToString (bIsWieldingRanged) +
    //       " bIsWieldingMelee: " + IntToString (bIsWieldingMelee));
    //Debug ("0i_combat", "912", "MODE_STOP_RANGED: " + IntToString (GetAssociateMode (MODE_STOP_RANGED)) + " Invisible: " + IntToString (GetInvisible ()));
    // If we don't want our associate to use a ranged weapon then make them equip a melee weapon.
    // If we are invisible then change to a melee weapon so we can move in to attack.
    if (GetAssociateMode (MODE_STOP_RANGED) || GetInvisible ())
    {
        // Equip a melee weapon unless we already have one.
        if (!bIsWieldingMelee) EquipBestMeleeWeapon (oTarget);
        return;
    }
    // Equip the appropriate weapon for the distance of the enemy.
    int nEnemyGroup = GetNumEnemiesInGroup (OBJECT_SELF);
    //Debug ("0i_combat", "923", GetName (OBJECT_SELF) + " has " + IntToString (nEnemyGroup) + " enemies within 5.0f them! PointBlank: " +
    //       IntToString (GetHasFeat (FEAT_POINT_BLANK_SHOT)));
    // We are in melee combat.
    if (nEnemyGroup > 0)
    {
        if (bIsWieldingRanged)
        {
            // We have the point blank shot feat or there are more than one enemy on us.
            // Note: Point Blank shot feat is bad once we have more than one enemy on us.
            if (!GetHasFeat (FEAT_POINT_BLANK_SHOT) || nEnemyGroup > 1)
            {
                // If I'm not using a melee weapon.
                if (!bIsWieldingMelee)
                {
                    EquipBestMeleeWeapon (OBJECT_INVALID);
                    //Debug ("0i_combat", "974", GetName (OBJECT_SELF) + " is equiping melee weapon due to close enemies!");
                }
            }
        }
    }
    // We are not in melee range.
    else
    {
        //Debug ("0i_combat", "946", GetName (OBJECT_SELF) + " is not in melee combat with an enemy!");
        // If are at range with the enemy then equip a ranged weapon.
        if (!bIsWieldingRanged)
        {
            EquipBestRangedWeapon (oTarget);
            // Make sure that they equiped a range weapon.
            bIsWieldingRanged = HasRangedWeaponWithAmmo (OBJECT_SELF);
            bIsWieldingMelee = GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND));
            //Debug ("0i_combat", "954", GetName (OBJECT_SELF) + " is attempting to equip a ranged weapon: " + IntToString (bIsWieldingRanged));
            // If we equiped a ranged weapon then drop out.
        }
    }
    // We don't have a weapon out so equip one! We are in combat!
    if (!bIsWieldingRanged && !bIsWieldingMelee) EquipBestMeleeWeapon (OBJECT_INVALID);
}
// Equip melee weapon AND check for shield.
// Returns TRUE if equiped, FALSE if not.
int EquipBestMeleeWeapon (object oTarget = OBJECT_INVALID)
{
    //Debug ("0i_combat", "965", GetName (OBJECT_SELF) + " is equiping best melee weapon!");
    int nValue, nRightValue, nLeftValue, n2HandValue, nShieldValue;
    int nLevel = GetCharacterLevels (OBJECT_SELF);
    object oTwoHand = OBJECT_INVALID;
    object oShield = OBJECT_INVALID;
    object oRight = OBJECT_INVALID;
    object oLeft = OBJECT_INVALID;
    object oRightHand = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND);
    if (oRightHand != OBJECT_INVALID)
    {
        // Setup the item in our right hand as our base gold value to check against.
        if (GetIsTwoHandedWeapon (oRightHand, OBJECT_SELF)) n2HandValue = GetGoldPieceValue (oRightHand);
        else if (GetIsSingleHandedWeapon (oRightHand, OBJECT_SELF)) nRightValue = GetGoldPieceValue (oRightHand);
    }
    object oLeftHand = GetItemInSlot (INVENTORY_SLOT_LEFTHAND);
    if (oLeftHand != OBJECT_INVALID)
    {
        // Setup the item in our left hand as our base gold vlue to check against.
        if (GetIsShield (oLeftHand)) nShieldValue = GetGoldPieceValue (oLeftHand);
        else if (GetIsSingleHandedWeapon (oLeftHand, OBJECT_SELF)) nLeftValue = GetGoldPieceValue (oLeftHand);
    }
    // Get the best weapons they have in their inventory.
    object oItem = GetFirstItemInInventory ();
    // If they don't have any items then lets stop, we can't equip a weapon.
    if (oItem == OBJECT_INVALID) return FALSE;
    while (oItem != OBJECT_INVALID)
    {
        // Make sure they are high enough level to equip this item.
        if (nLevel >= NWNX_Item_GetMinEquipLevel (oItem))
        {
            // Not Non-Identified items have a goldpiecevalue of 1. So they will not be selected.
            nValue = GetGoldPieceValue (oItem);
            // Is it a single handed weapon?
            if (GetIsSingleHandedWeapon (oItem, OBJECT_SELF))
            {
                // Replace the lowest value right or left weapon.
                if (nValue > nRightValue && nValue > nLeftValue)
                {
                    if (nRightValue > nLeftValue) { oLeft = oItem; nLeftValue = nValue; }
                    else { oRight = oItem; nRightValue = nValue; }
                }
                else if (nValue > nRightValue) { oRight = oItem; nRightValue = nValue; }
                else if (nValue > nLeftValue) { oLeft = oItem; nLeftValue = nValue; }
            }
            else if (GetIsTwoHandedWeapon (oItem, OBJECT_SELF))
            {
                if (nValue > n2HandValue) { oTwoHand = oItem; n2HandValue = nValue; }
            }
            else if (GetIsShield (oItem))
            {
                if (nValue > nShieldValue) { oShield = oItem; nShieldValue = nValue; }
            }
        }
        oItem = GetNextItemInInventory ();
    }
    //Debug ("0i_combat", "1057", GetName (OBJECT_SELF) + " has Right: " +
    //       GetName (oRight) + ", Left: " + GetName (oLeft) + ", TwoHand: " + GetName (oTwoHand) + ", Shield: " + GetName (oShield));
    // Lets check to equip two weapons first.
    if (oLeft != OBJECT_INVALID &&
       (GetHasFeat (374/*FEAT_DUAL_WIELD*/) ||
        GetHasFeat (FEAT_TWO_WEAPON_FIGHTING)))
    {
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oRight, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1029", GetName (OBJECT_SELF) + " equiped weapon: " + GetName (oRight) + " in the right hand.");
            return TRUE;
        }
        //else Debug ("0i_combat", "1032", GetName (OBJECT_SELF) + " did not equip weapon: " + GetName (oRight) + " in the right hand.");
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oLeft, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1035", GetName (OBJECT_SELF) + " equiped weapon: " + GetName (oLeft) + " in the left hand.");
            return TRUE;
        }
        //else Debug ("0i_combat", "1038", GetName (OBJECT_SELF) + " did not equip weapon: " + GetName (oLeft) + " in the left hand.");
    }
    // Check to see if they should use a two handed weapon.
    // If they have a two handed weapon and a strength bonus of +2 or more then use that.
    // Also use if they don't have a smaller weapon.
    if (oTwoHand != OBJECT_INVALID &&
       (GetAbilityModifier (ABILITY_STRENGTH, OBJECT_SELF) > 1 ||
        oRight == OBJECT_INVALID))
    {
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oTwoHand, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1049", GetName (OBJECT_SELF) + " equiped weapon: " + GetName (oTwoHand) + " as two handed.");
            return TRUE;
        }
        //else Debug ("0i_combat", "1052", GetName (OBJECT_SELF) + " did not equip weapon: " + GetName (oTwoHand) + " as two handed.");
    }
    // Lets equip a weapon and a shield.
    if (oRight != OBJECT_INVALID &&
        oShield != OBJECT_INVALID &&
        GetHasFeat (FEAT_SHIELD_PROFICIENCY))
    {
        int bEquipedRight, bEquipedShield;
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oRight, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1062", GetName (OBJECT_SELF) + " equiped weapon: " + GetName (oRight) + " in the right hand.");
            bEquipedRight = TRUE;
        }
        //else Debug ("0i_combat", "1065", GetName (OBJECT_SELF) + " did not equip weapon: " + GetName (oRight) + " in the right hand.");
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oShield, INVENTORY_SLOT_LEFTHAND))
        {
            //Debug ("0i_combat", "1068", GetName (OBJECT_SELF) + " equiped shield: " + GetName (oShield) + ".");
            bEquipedShield = TRUE;
        }
        //else Debug ("0i_combat", "1071", GetName (OBJECT_SELF) + " did not equip shield: " + GetName (oShield) + ".");
        if (bEquipedRight && bEquipedShield) return TRUE;
    }
    // Finally lets just equip a weapon since we must not have a shield.
    if (oRight != OBJECT_INVALID)
    {
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oRight, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1079", GetName (OBJECT_SELF) + " equiped a melee weapon: " + GetName (oRight) + ".");
            return TRUE;
        }
        //else Debug ("0i_combat", "1082", GetName (OBJECT_SELF) + " did not equip a melee weapon!");
    }
    // Fallback: If I'm still here, try ActionEquipMostDamagingMelee
    ActionEquipMostDamagingMelee (oTarget);
    //Debug ("0i_combat", "1086", GetName (OBJECT_SELF) + " is equiping a melee weapon (Fallback).");
    if (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND) != OBJECT_INVALID) return TRUE;
    return FALSE;
}
// Equip ranged weapon AND check for ammo.
// Returns TRUE if equiped, FALSE if not.
int EquipBestRangedWeapon (object oTarget = OBJECT_INVALID)
{
    //Debug ("0i_combat", "1094", GetName (OBJECT_SELF) + " is looking for best ranged weapon!");
    int nAmmo, nAmmoSlot, nBestType1, nBestType2, nType, nFeat, nValue, nRangedValue;
    int nLevel = GetCharacterLevels (OBJECT_SELF);
    string sAmmo;
    object oRightHand = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND);
    if (oRightHand != OBJECT_INVALID)
    {
        // Setup the item in our right hand as our base gold value to check against.
        if (GetIsRangeWeapon  (oRightHand)) nRangedValue = GetGoldPieceValue (oRightHand);
    }
    object oRanged = OBJECT_INVALID, oAmmo = OBJECT_INVALID;
    // Find the best type of ranged weapon for this player.
    if (GetHasFeat (FEAT_WEAPON_FOCUS_LONGBOW))
    { nBestType1 = BASE_ITEM_LONGBOW; nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow";}
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_SHORTBOW))
    { nBestType1 = BASE_ITEM_SHORTBOW; nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow";}
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW))
    { nBestType1 = BASE_ITEM_HEAVYCROSSBOW; nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt";}
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW))
    { nBestType1 = BASE_ITEM_LIGHTCROSSBOW; nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt";}
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_SLING))
    { nBestType1 = BASE_ITEM_SLING; nAmmo = BASE_ITEM_BULLET; nAmmoSlot = INVENTORY_SLOT_BULLETS; sAmmo = "bullet";}
    else if (GetHasFeat (91/*WEAPON_FOCUS_JAVELIN*/))
    { nBestType1 = 31; }
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_SHURIKEN))
    { nBestType1 = BASE_ITEM_SHURIKEN; }
    else if (GetHasFeat (FEAT_WEAPON_FOCUS_THROWING_AXE))
    { nBestType1 = BASE_ITEM_THROWINGAXE; }
    // These feats require a bow.
    else if (GetHasFeat (FEAT_RAPID_SHOT) || GetHasFeat (1521/*Scatter Shot*/))
    { nBestType1 = BASE_ITEM_LONGBOW; nBestType2 = BASE_ITEM_SHORTBOW;
      nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow"; }
    // This feat requires a xbow.
    else if (GetHasFeat (FEAT_RAPID_RELOAD))
    { nBestType1 = BASE_ITEM_HEAVYCROSSBOW; nBestType2 = BASE_ITEM_LIGHTCROSSBOW;
      nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt"; }
    //Debug ("0i_combat", "1130", "nBestType1: " + IntToString (nBestType1) + " nBestType2: " + IntToString (nBestType2) +
    //       " nAmmo: " + IntToString (nAmmo));
    // Cycle through the inventory looking for a ranged weapon.
    object oItem = GetFirstItemInInventory ();
    while (oItem != OBJECT_INVALID)
    {
        nType = GetBaseItemType (oItem);
        // Make sure this is a ranged weapon.
        //Debug ("0i_combat", "1138", "oItem: " + GetName (oItem) + " Ranged Weapon: " +
        //       Get2DAString ("baseitems", "RangedWeapon", nType));
        if (Get2DAString ("baseitems", "RangedWeapon", nType) != "")
        {
            //Debug ("0i_combat", "1142", " ItemLevel: " + IntToString (NWNX_Item_GetMinEquipLevel (oItem)) +
            //       " nLevel: " + IntToString (nLevel));
            // Make sure they are high enough level to equip this item.
            if (nLevel >= NWNX_Item_GetMinEquipLevel (oItem))
            {
                //Debug ("0i_combat", "1147", " Creature Size: " + IntToString (GetCreatureSize (OBJECT_SELF)) +
                //       " Weapon Size: " + Get2DAString ("baseitems", "WeaponSize", nType) +
                //       " Has feat0: " + IntToString (GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat0", nType)))));
                // Make sure they are large enough to use it and have the proficiency.
                if (StringToInt (Get2DAString ("baseitems", "WeaponSize", nType)) <= GetCreatureSize (OBJECT_SELF) + 1 &&
                    (GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat0", nType))) ||
                     GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat1", nType))) ||
                     GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat2", nType))) ||
                     GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat3", nType))) ||
                     GetHasFeat (StringToInt (Get2DAString ("baseitems", "ReqFeat4", nType)))))
                {
                    // Note Non-Identified items have a goldpiecevalue of 1.
                    // So they will not be selected.
                    nValue = GetGoldPieceValue (oItem);
                    //Debug ("0i_combat", "1161", "nValue: " + IntToString (nValue) +
                    //       " nRangedValue: " + IntToString (nRangedValue) + " nType: " + IntToString (nType));
                    // Is it of the best range weapon type? 0 is any range weapon.
                    // Also grab any range weapon until we have a best type.
                    if (nType == nBestType1 || nType == nBestType2 ||
                        nBestType1 == 0 || oRanged == OBJECT_INVALID)
                    {
                        if (nValue > nRangedValue)
                        {
                            if (nBestType1 == 0)
                            {
                                if (nType == BASE_ITEM_LONGBOW || nType == BASE_ITEM_SHORTBOW)
                                { nAmmo = BASE_ITEM_ARROW; sAmmo = "arrow"; nAmmoSlot = INVENTORY_SLOT_ARROWS; }
                                else if (nType == BASE_ITEM_HEAVYCROSSBOW || nType == BASE_ITEM_LIGHTCROSSBOW)
                                { nAmmo = BASE_ITEM_BOLT; sAmmo = "bolt"; nAmmoSlot = INVENTORY_SLOT_BOLTS; }
                                else if (nType == BASE_ITEM_SLING)
                                { nAmmo = BASE_ITEM_BULLET; sAmmo = "bullet"; nAmmoSlot = INVENTORY_SLOT_BULLETS; }
                                else nAmmo = 0;
                            }
                            // Now do we have ammo for it?
                            //Debug ("0i_combat", "1181", "nAmmo: " + IntToString (nAmmo));
                            if (nAmmo > 0)
                            {
                                if (nAmmo == BASE_ITEM_ARROW ||
                                    nAmmo == BASE_ITEM_BOLT ||
                                    nAmmo == BASE_ITEM_BULLET) oAmmo = GetItemInSlot (nAmmoSlot);
                                if (oAmmo == OBJECT_INVALID)
                                {
                                    // We don't have ammo equiped so lets see if we have any in our inventory.
                                    oAmmo = GetFirstItemInInventory();
                                    while (oAmmo != OBJECT_INVALID)
                                    {
                                        if (GetBaseItemType (oAmmo) == nAmmo) break;
                                        oAmmo = GetNextItemInInventory ();
                                    }
                                    if (oAmmo != OBJECT_INVALID) NWNX_Creature_RunEquip (OBJECT_SELF, oAmmo, nAmmoSlot);
                                }
                            }
                            if (oAmmo != OBJECT_INVALID)
                            {
                                oRanged = oItem; nRangedValue = nValue;
                                //Debug ("0i_combat", "1202", "oRanged: " + GetName (oRanged) +
                                //       " nRangedValue: " + IntToString (nRangedValue));
                            }
                        }
                    }
                }
            }
        }
        oItem = GetNextItemInInventory ();
    }
    // They don't have a range weapon so lets break out.
    if (oRanged == OBJECT_INVALID)
    {
        //Debug ("0i_combat", "1215", GetName (OBJECT_SELF) + " did not equip a ranged weapon!");
        return FALSE;
    }
    if (NWNX_Creature_RunEquip (OBJECT_SELF, oRanged, INVENTORY_SLOT_RIGHTHAND))
    {
        //Debug ("0i_combat", "1220", GetName (OBJECT_SELF) + " equiped a ranged weapon: " + GetName (oRanged) + ".");
        return TRUE;
    }
    // Fallback: If I'm still here, try ActionEquipMostDamagingRanged
    ActionEquipMostDamagingRanged (oTarget);
    //Debug ("0i_combat", "1225", GetName (OBJECT_SELF) + " is equiping a ranged weapon (Fallback).");
    if (HasRangedWeaponWithAmmo ()) return TRUE;
    return FALSE;
}
// Equip melee weapon for a monk.
// Returns TRUE if equiped, FALSE if not.
int EquipBestMonkMeleeWeapon (object oTarget = OBJECT_INVALID)
{
    //Debug ("0i_combat", "1233", GetName (OBJECT_SELF) + " is equiping best monk melee weapon!");
    int nValue, nRightValue;
    int nLevel = GetCharacterLevels (OBJECT_SELF);
    object oRight = OBJECT_INVALID;
    object oRightHand = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND);
    if (oRightHand != OBJECT_INVALID)
    {
        nRightValue = GetGoldPieceValue (oRightHand);
    }
    // Get the best kama they have in their inventory.
    object oItem = GetFirstItemInInventory ();
    // If they don't have any kamas then lets stop, we can't equip a weapon.
    if (oItem == OBJECT_INVALID) return FALSE;
    while (oItem != OBJECT_INVALID)
    {
        // Make sure they are high enough level to equip this item.
        if (nLevel >= NWNX_Item_GetMinEquipLevel (oItem))
        {
            // Not Non-Identified items have a goldpiecevalue of 1. So they will not be selected.
            nValue = GetGoldPieceValue (oItem);
            // Is it a single handed weapon?
            if (GetBaseItemType (oItem) == BASE_ITEM_KAMA)
            {
                // Replace the lowest value right weapon.
                if (nValue > nRightValue)
                {
                    oRight = oItem; nRightValue = nValue;
                }
            }
        }
        oItem = GetNextItemInInventory ();
    }
    //Debug ("0i_combat", "1265", GetName (OBJECT_SELF) + " has Right: " + GetName (oRight));
    // Finally lets just equip the kama if we have one.
    if (oRight != OBJECT_INVALID)
    {
        if (NWNX_Creature_RunEquip (OBJECT_SELF, oRight, INVENTORY_SLOT_RIGHTHAND))
        {
            //Debug ("0i_combat", "1271", GetName (OBJECT_SELF) + " equiped a melee weapon: " + GetName (oRight) + ".");
            return TRUE;
        }
        //else Debug ("0i_combat", "1274", GetName (OBJECT_SELF) + " did not equip a melee weapon!");
    }
    if (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND) != OBJECT_INVALID) return TRUE;
    return FALSE;
}
//   Determine the percentage of hit points the object has left.
//   Returns an integer between 0 - 100.
int GetPercentageHPLoss (object oCreature = OBJECT_SELF)
{
    return (GetCurrentHitPoints (oCreature) * 100) / GetMaxHitPoints (oCreature);
}
// Return true if oCreature is Invisible, shealth mode, or has sanctuary up.
int GetInvisible (object oCreature = OBJECT_SELF)
{
    if(GetHasEffect (EFFECT_TYPE_INVISIBILITY, oCreature) ||
       GetHasEffect (EFFECT_TYPE_IMPROVEDINVISIBILITY, oCreature) ||
      (GetHasSpellEffect (SPELL_DARKNESS, oCreature) && GetHasSpellEffect (SPELL_DARKVISION, oCreature)) ||
       GetActionMode(oCreature, ACTION_MODE_STEALTH) ||
       GetHasEffect(EFFECT_TYPE_SANCTUARY, oCreature) ||
       GetHasEffect(EFFECT_TYPE_ETHEREAL, oCreature))
    {
        return TRUE;
    }
    return FALSE;
}
// Checks if the caster has a chance of effecting oTarget.
// Return TRUE if there is a good chance, FALSE if not.
// nSpell is the spell we are casting.
// sIndex is the index of the target saved on the creature casting the spell.
int CheckOffensiveSpellVsTarget (int nSpell, object oTarget)
{
    // Get this enemies magic defense rating: ((Saves / 3 ) + Spell Resist) / 2
    int nMagic = (GetFortitudeSavingThrow (oTarget) +
              GetReflexSavingThrow (oTarget) +
              GetWillSavingThrow (oTarget)) / 3;
    int nSR = GetSpellResistance (oTarget) / 2;
    nMagic += nSR;
    // Lets see if the enemies magic saves are better than the spells level + d6 + 2?
    int nSpellLvl = StringToInt (Get2DAString ("spells", "Innate", nSpell));
    // If the spell doesn't have a save then skip checking vs targets magic saves.
    if (Get2DAString ("spells", "ImmunityType", nSpell) == "NoSave") nSpellLvl = 99;
    else
    {
       int nRoll = d6() + 2;
       //Debug ("0i_combat", "1318", " nSpellLvl: " + IntToString (nSpellLvl) +
       //       " nRoll: " + IntToString (nRoll) + " = " + IntToString (nSpellLvl + nRoll) +
       //       " > nMagic: " + IntToString (nMagic));
       nSpellLvl += nRoll;
    }
    if (nSpellLvl > nMagic) return TRUE;
    return FALSE;
}
// See if we need to use defensive casting for this spell!
// Or skip casting as melee is too dangerous for casting.
// Returns TRUE if we should cast the spell, FALSE if not.
int CheckCastingInMelee (int nSpell, int nMelee)
{
    // All spells use have the UserType of 1. 2 is Special Abilities, 3 is Feats.
    if (StringToInt (Get2DAString ("spells", "UserType", nSpell)) != 1) return TRUE;
    // If this is a spell and we are in melee.
    if (nMelee > 0 && !GetHasFeat (FEAT_EPIC_IMPROVED_COMBAT_CASTING))
    {
        // If we are already in defensive casting mode then we can cast!
        // This doesn't work as I thought it would allows casting not in defensive mode!
        //Debug ("0i_combat", "1336", " In Defensive Casting Mode: " + IntToString (GetActionMode (OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST)));
        //if (GetActionMode (OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST)) return TRUE;
        // How hard is it to make a check on Defensive Casting?
        // Using DC 19 so we will use with up to a 50% failure.
        int nSpellLevel = StringToInt (Get2DAString ("spells", "Innate", nSpell));
        int nDC = DEFENSIVE_CASTING_DC + nSpellLevel;
        if (GetHasFeat (FEAT_COMBAT_CASTING)) nDC -= 4;
        int nRoll = d10();
        // Do we have a good concentration?
        int nConcentration = GetSkillRank (SKILL_CONCENTRATION);
        //Debug ("0i_combat", "1346", "nDC: " + IntToString (nDC) + " FEAT_COMBAT_CASTING: " +
        //       IntToString (GetHasFeat (FEAT_COMBAT_CASTING)) +
        //       " nConcentration: " + IntToString (nConcentration) + " nRoll: " + IntToString (nRoll));
        if (nConcentration + nRoll > nDC)
        {
            //Debug ("0i_combat", "1469", GetName (OBJECT_SELF) + " is casting defensively!");
            SetActionMode (OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST, TRUE);
        }
        // Defensive casting is a bad idea so maybe casting anyspell is a bad idea.
        else
        {
            object oMelee = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
            if (GetIsObjectValid (oMelee))
            {
                nRoll = d10();
                nDC = CASTING_IN_MELEE_DC + nSpellLevel + nMelee * GetCharacterLevels (oMelee);
                //Debug ("0i_combat", "1362", "nConcentration: " + IntToString (nConcentration) +
                //       " nRoll: " + IntToString (nRoll) + " nDC: " + IntToString (nDC) +
                //       " oMelee: " + GetName (oMelee));
                if (nConcentration + nRoll > nDC) return TRUE;
                //Debug ("0i_combat", "1366", GetName (OBJECT_SELF) + " is not casting in melee against " + GetName (oMelee));
                return FALSE;
            }
        }
    }
    // We don't need to cast defensively so lets make sure it's off.
    else if (GetActionMode (OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST))
    {
        SetActionMode (OBJECT_SELF, ACTION_MODE_DEFENSIVE_CAST, FALSE);
    }
    return TRUE;
}
// Clears all variables that define objects in combat for oCreature.
void ClearCombatState (object oCreature = OBJECT_SELF)
{
    int bEnemyDone, bAllyDone, nCnt = 1;
    string sCnt;
    while (!bEnemyDone || !bAllyDone)
    {
        sCnt = IntToString (nCnt);
        if (GetLocalInt (oCreature, ENEMY_NUMBERS) >= nCnt)
        {
            DeleteLocalObject (oCreature, ENEMY + sCnt);
            DeleteLocalInt (oCreature, ENEMY_DISABLED + sCnt);
            DeleteLocalInt (oCreature, ENEMY_SEEN + sCnt);
            DeleteLocalFloat (oCreature, ENEMY_RANGE + sCnt);
            DeleteLocalInt (oCreature, ENEMY_COMBAT + sCnt);
            DeleteLocalInt (oCreature, ENEMY_MELEE + sCnt);
            DeleteLocalInt (oCreature, ENEMY_HEALTH + sCnt);
        }
        else bEnemyDone = TRUE;
        if (GetLocalInt (oCreature, ALLY_NUMBERS) >= nCnt)
        {
            DeleteLocalObject (oCreature, ALLY + sCnt);
            DeleteLocalInt (oCreature, ALLY_DISABLED + sCnt);
            DeleteLocalInt (oCreature, ALLY_SEEN + sCnt);
            DeleteLocalFloat (oCreature, ALLY_RANGE + sCnt);
            DeleteLocalInt (oCreature, ALLY_COMBAT + sCnt);
            DeleteLocalInt (oCreature, ALLY_MELEE + sCnt);
            DeleteLocalInt (oCreature, ALLY_HEALTH + sCnt);
        }
        else bAllyDone = TRUE;
        nCnt ++;
    }
    DeleteLocalObject (oCreature, ENEMY_NEAREST);
    DeleteLocalInt (oCreature, ENEMY_NUMBERS);
    DeleteLocalInt (oCreature, ENEMY_POWER);
    DeleteLocalInt (oCreature, ALLY_NUMBERS);
    DeleteLocalObject (oCreature, ALLY_POWER);
    // Also clear these combat variables.
    DeleteLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET");
    DeleteLocalInt (OBJECT_SELF, "0_FLEEING");
}
// Creates the current combat situation on oObject for Associates.
// Creates Variables ENEMY_* for enemies and ALLY_* for allies.
// Returns the nearest enemy to oObject.
object SetAssociateCombatState (object oCreature = OBJECT_SELF)
{
    int nEnemyNum, nEnemyPower, nAllyNum, nAllyPower, nMelee, nCombat, nMagic, nHealth;
    int nCnt, nNth, nMeleeAllies, nPower, nDisabled, bThreat, nEHPower, nAHPower;
    float fDistance, fNearest = RANGE_BATTLEFIELD + 1.0;
    string sCnt, sDebugText;
    location lLocation = GetLocation (oCreature);
    object oMelee, oNearestEnemy = OBJECT_INVALID;
    //Debug ("0i_combat", "1430", "************************************************************");
    //Debug ("0i_combat", "1431", "******************* CREATING COMBAT DATA *******************");
    //Debug ("0i_combat", "1432", GetName (oCreature));
    // Get all creatures within 40 meters (5 meters beyond our perception of 35).
    object oObject = GetFirstObjectInShape (SHAPE_SPHERE, RANGE_BATTLEFIELD, lLocation, TRUE);
    while (oObject != OBJECT_INVALID)
    {
        // Process all enemies.
        if (GetIsEnemy (oObject))
        {
            // ********** Check if the Enemy is disabled **********
            bThreat = TRUE;
            nDisabled = Disabled (oObject);
            if (nDisabled)
            {
                // !!!! For /DEBUG CODE !!!!
                //sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
                // Decide if they are still a threat: 1 - dead, 2 - Bleeding.
                if (nDisabled == 1 || nDisabled == 2 ||
                    //nDisabled == EFFECT_TYPE_CONFUSED ||
                    //nDisabled == EFFECT_TYPE_FRIGHTENED ||
                    nDisabled == EFFECT_TYPE_PARALYZE ||
                    nDisabled == EFFECT_TYPE_CHARMED ||
                    nDisabled == EFFECT_TYPE_PETRIFY)
                {
                    bThreat = FALSE;
                    //Debug ("0i_combat", "1456", "Enemy: " + GetName (oObject) + sDebugText);
                }
            }
            // If they are using the coward ai then treat them as frightened.
            // we place it here as an else so we don't overwrite another disabled effect.
            else if (GetLocalString (oObject, "COMBAT_AI_SCRIPT") == "ai_coward")
            {
                nDisabled = 25;
                // !!!! For /DEBUG CODE !!!!
                sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
            }
            if (bThreat)
            {
                sCnt = IntToString (++nEnemyNum);
                // ********** Set if the Enemy is disabled **********
                SetLocalInt (oCreature, ENEMY_DISABLED + sCnt, nDisabled);
                // ********** Set the Enemy Object **********
                SetLocalObject (oCreature, ENEMY + sCnt, oObject);
                // ********** Set the Enemy Combat Rating **********
                nCombat = (NWNX_Creature_GetAttackBonus (oObject) + GetAC (oObject) - 10) / 2;
                SetLocalInt (oCreature, ENEMY_COMBAT + sCnt, nCombat);
                // ********** Set the Enemy Health Percentage **********
                nHealth = GetPercentageHPLoss (oObject);
                SetLocalInt (oCreature, ENEMY_HEALTH + sCnt, nHealth);
                // ********** Set the number of enemies near the enemy **********
                nMelee = 0;
                nNth = 1;
                oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while (oMelee != OBJECT_INVALID && GetDistanceBetween (oMelee, oObject) < 10.0)
                {
                    // We add an enemy to the group.
                    if (GetIsEnemy (oMelee)) nMelee ++;
                    // If they are an ally then we subtract one from the group.
                    else nMelee --;
                    oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt (oCreature, ENEMY_MELEE + sCnt, nMelee);
                // ********** Set the Enemies distance **********
                fDistance = GetDistanceToObject (oObject);
                SetLocalFloat (oCreature, ENEMY_RANGE + sCnt, fDistance);
                // ********** Set if the Enemy is seen **********
                if (GetObjectSeen (oObject, oCreature))
                {
                    SetLocalInt (oCreature, ENEMY_SEEN + sCnt, TRUE);
                    //sDebugText += "**** SEEN ****";
                    // ********** Set the Nearest Enemy seen **********
                    if (fDistance < fNearest)
                    {
                        fNearest = fDistance;
                        oNearestEnemy = oObject;
                    }
                }
                // ********** Get the Total levels of the Enemy **********
                nPower = GetCharacterLevels (oObject) + GetLocalInt (oObject, "0_DIFFICULTY");
                if (nEHPower < nPower) nEHPower = nPower;
                nEnemyPower += (nPower * nHealth) / 100;
                // !!! Temporary /debug code !!!
                if (fDistance < RANGE_MELEE) sDebugText += "**** MELEE ****";
                //Debug ("0i_combat", "1514", "Enemy (" + IntToString (nEnemyNum) + "): " +
                //       GetName (oObject) + sDebugText);
                //Debug ("0i_combat", "1516", "nHealth: " + IntToString (nHealth) +
                //       " nCombat: " + IntToString (nCombat) +
                //       " nMelee: " + IntToString (nMelee) +
                //       " fDistance: " + FloatToString (fDistance, 0, 2) +
                //       " nEnemyNum: " + IntToString (nEnemyNum) +
                //       " nEnemyPower: " + IntToString (nEnemyPower / 2));
            }
        }
        // Process all Allies.
        else
        {
            sCnt = IntToString (++nAllyNum);
            // ********** Set if the Ally is disabled **********
            nDisabled = Disabled (oObject);
            if (nDisabled)
            {
                //sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
                SetLocalInt (oCreature, ALLY_DISABLED + sCnt, nDisabled);
            }
            if (nDisabled != 1 && nDisabled != 2)
            {
                // ********** Set the Ally Object **********
                SetLocalObject (oCreature, ALLY + sCnt, oObject);
                // ********** Set the Ally Combat Rating **********
                nCombat = (NWNX_Creature_GetAttackBonus (oObject) + GetAC (oObject) - 10) / 2;
                SetLocalInt (oCreature, ALLY_COMBAT + sCnt, nCombat);
                // ********** Set the Ally Health Percentage **********
                nHealth = GetPercentageHPLoss (oObject);
                SetLocalInt (oCreature, ALLY_HEALTH + sCnt, nHealth);
                // ********** Set the number of enemies near the ally **********
                nMelee = 0;
                nNth = 1;
                oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while (oMelee != OBJECT_INVALID && GetDistanceBetween (oMelee, oObject) < 10.0)
                {
                    if (GetIsEnemy (oMelee)) nMelee ++;
                    else nMelee --;
                    oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt (oCreature, ALLY_MELEE + sCnt, nMelee);
                // ********** Set the Allies distance **********
                SetLocalFloat (oCreature, ALLY_RANGE + sCnt, GetDistanceToObject (oObject));
                // ********** All allies are considered to be seen **********
                SetLocalInt (oCreature, ALLY_SEEN + sCnt, TRUE);
                // ********** Get the Total levels of the Allies **********
                nPower = GetCharacterLevels (oObject);
                if (nAHPower < nPower) nAHPower = nPower;
                nAllyPower += (nPower * nHealth) / 100;
                //Debug ("0i_combat", "1564", "Ally (" + IntToString (nAllyNum) + "): " +
                //       GetName (oObject) + sDebugText);
                //Debug ("0i_combat", "1566", "nHealth: " + IntToString (nHealth) +
                //       " nCombat: " + IntToString (nCombat) +
                //       " nMelee: " + IntToString (nMelee) +
                //       " fDistance: " + FloatToString (GetDistanceToObject (oObject), 0, 2) +
                //       " nAllyNum: " + IntToString (nAllyNum) +
                //       " nAllyPower: " + IntToString (nAllyPower / 2));
            }
        }
        sDebugText = "";
        oObject = GetNextObjectInShape (SHAPE_SPHERE, RANGE_BATTLEFIELD, lLocation, TRUE);
    }
    //Debug ("0i_combat", "1577", "Nearest Enemy: " + GetName (oNearestEnemy));
    //Debug ("0i_combat", "1578", "****************** FINISHED COMBAT DATA  *******************");
    //Debug ("0i_combat", "1579", "************************************************************");
    // Lets save processing by only clearing previous enemy data we don't overwrite.
    int nEnd = GetLocalInt (oCreature, ENEMY_NUMBERS);
    nCnt = nEnemyNum + 1;
    while (nEnd >= nCnt)
    {
        sCnt = IntToString (nCnt);
        DeleteLocalObject (oCreature, ENEMY + sCnt);
        DeleteLocalInt (oCreature, ENEMY_SEEN + sCnt);
        DeleteLocalFloat (oCreature, ENEMY_RANGE + sCnt);
        DeleteLocalInt (oCreature, ENEMY_COMBAT + sCnt);
        DeleteLocalInt (oCreature, ENEMY_MELEE + sCnt);
        DeleteLocalInt (oCreature, ENEMY_HEALTH + sCnt);
        nCnt ++;
    }
    // Lets save processing by only clearing previous ally data we don't overwrite.
    nEnd = GetLocalInt (oObject, ALLY_NUMBERS);
    nCnt = nAllyNum + 1;
    while (nEnd >= nCnt)
    {
        DeleteLocalObject (oCreature, ALLY + sCnt);
        DeleteLocalInt (oCreature, ALLY_SEEN + sCnt);
        DeleteLocalFloat (oCreature, ALLY_RANGE + sCnt);
        DeleteLocalInt (oCreature, ALLY_COMBAT + sCnt);
        DeleteLocalInt (oCreature, ALLY_MELEE + sCnt);
        DeleteLocalInt (oCreature, ALLY_HEALTH + sCnt);
        nCnt ++;
    }
    // Finally set all group states.
    SetLocalInt (oCreature, ENEMY_NUMBERS, nEnemyNum);
    // Total enemy power is half the levels of all enemies + the total levels
    // of the highest level enemy.
    nEnemyPower = (nEnemyPower / 2) + (nEHPower / 2);
    SetLocalInt (oCreature, ENEMY_POWER, nEnemyPower);
    SetLocalObject (oCreature, ENEMY_NEAREST, oNearestEnemy);
    SetLocalInt (oCreature, ALLY_NUMBERS, nAllyNum);
    // Total ally power is half the levels of all allies + the total levels
    // of the highest level ally.
    nAllyPower = (nAllyPower / 2) + (nAHPower / 2);
    SetLocalInt (oCreature, ALLY_POWER, nAllyPower);
    return oNearestEnemy;
}
// Creates the current combat situation on oObject for monsters.
// Creates Variables ENEMY_* for enemies and ALLY_* for allies.
// Returns the nearest enemy to oObject.
object SetMonsterCombatState (object oCreature = OBJECT_SELF)
{
    int nEnemyNum, nEnemyPower, nAllyNum, nAllyPower, nMelee, nCombat, nMagic, nHealth;
    int nCnt, nNth, nMeleeAllies, nPower, nDisabled, bThreat, nEHPower, nAHPower;
    float fDistance, fNearest = RANGE_BATTLEFIELD + 1.0;
    string sCnt, sDebugText;
    location lLocation = GetLocation (oCreature);
    object oMelee, oNearestEnemy = OBJECT_INVALID;
    //Debug ("0i_combat", "1632", "************************************************************");
    //Debug ("0i_combat", "1633", "******************* CREATING COMBAT DATA *******************");
    //Debug ("0i_combat", "1634", GetName (oCreature));
    // Get all creatures within 40 meters (5 meters beyond our perception of 35).
    object oObject = GetFirstObjectInShape (SHAPE_SPHERE, RANGE_BATTLEFIELD, lLocation, TRUE);
    while (oObject != OBJECT_INVALID)
    {
        // Process all enemies.
        if (GetIsEnemy (oObject))
        {
            // ********** Check if the Enemy is disabled **********
            bThreat = TRUE;
            nDisabled = Disabled (oObject);
            if (nDisabled)
            {
                // !!!! For /DEBUG CODE !!!!
                //sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
                // Decide if they are still a threat: 1 - dead, 2 - Bleeding.
                if (nDisabled == 1 || nDisabled == 2 ||
                    //nDisabled == EFFECT_TYPE_CONFUSED ||
                    //nDisabled == EFFECT_TYPE_FRIGHTENED ||
                    nDisabled == EFFECT_TYPE_PARALYZE ||
                    nDisabled == EFFECT_TYPE_CHARMED ||
                    nDisabled == EFFECT_TYPE_PETRIFY)
                {
                    bThreat = FALSE;
                    //Debug ("0i_combat", "1658", "Enemy: " + GetName (oObject) + sDebugText);
                }
            }
            // If they are using the coward ai then treat them as frightened.
            // we place it here as an else so we don't overwrite another disabled effect.
            else if (GetLocalString (oObject, "COMBAT_AI_SCRIPT") == "ai_coward")
            {
                nDisabled = 25;
                // !!!! For /DEBUG CODE !!!!
                sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
            }
            if (bThreat)
            {
                sCnt = IntToString (++nEnemyNum);
                // ********** Set if the Enemy is disabled **********
                SetLocalInt (oCreature, ENEMY_DISABLED + sCnt, nDisabled);
                // ********** Set the Enemy Object **********
                SetLocalObject (oCreature, ENEMY + sCnt, oObject);
                // ********** Set the Enemy Combat Rating **********
                nCombat = (NWNX_Creature_GetAttackBonus (oObject) + GetAC (oObject) - 10) / 2;
                SetLocalInt (oCreature, ENEMY_COMBAT + sCnt, nCombat);
                // ********** Set the Enemy Health Percentage **********
                nHealth = GetPercentageHPLoss (oObject);
                SetLocalInt (oCreature, ENEMY_HEALTH + sCnt, nHealth);
                // ********** Set the number of enemies near the enemy **********
                nMelee = 0;
                nNth = 1;
                oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while (oMelee != OBJECT_INVALID && GetDistanceBetween (oMelee, oObject) < 10.0)
                {
                    // We add an enemy to the group.
                    if (GetIsEnemy (oMelee)) nMelee ++;
                    // If they are an ally then we subtract one from the group.
                    else nMelee --;
                    oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt (oCreature, ENEMY_MELEE + sCnt, nMelee);
                // ********** Set the Enemies distance **********
                fDistance = GetDistanceToObject (oObject);
                SetLocalFloat (oCreature, ENEMY_RANGE + sCnt, fDistance);
                // ********** Set if the Enemy is seen **********
                if (GetObjectSeen (oObject, oCreature))
                {
                    SetLocalInt (oCreature, ENEMY_SEEN + sCnt, TRUE);
                    //sDebugText += "**** SEEN ****";
                    // ********** Set the Nearest Enemy seen **********
                    if (fDistance < fNearest)
                    {
                        fNearest = fDistance;
                        oNearestEnemy = oObject;
                    }
                }
                // !!! Temporary /debug code !!!
                if (fDistance < RANGE_MELEE) sDebugText += "**** MELEE ****";
                //Debug ("0i_combat", "1712", "Enemy (" + IntToString (nEnemyNum) + "): " +
                //       GetName (oObject) + sDebugText);
                //Debug ("0i_combat", "1714", "nHealth: " + IntToString (nHealth) +
                //       " nCombat: " + IntToString (nCombat) +
                //       " nMelee: " + IntToString (nMelee) +
                //       " fDistance: " + FloatToString (fDistance, 0, 2) +
                //       " nEnemyNum: " + IntToString (nEnemyNum));
            }
        }
        // Process all Allies.
        else
        {
            sCnt = IntToString (++nAllyNum);
            // ********** Set if the Ally is disabled **********
            nDisabled = Disabled (oObject);
            if (nDisabled)
            {
                //sDebugText += "**** DISABLED (" + IntToString (nDisabled) + ") ****";
                SetLocalInt (oCreature, ALLY_DISABLED + sCnt, nDisabled);
            }
            if (nDisabled != 1 && nDisabled != 2)
            {
                // ********** Set the Ally Object **********
                SetLocalObject (oCreature, ALLY + sCnt, oObject);
                // ********** Set the Ally Combat Rating **********
                nCombat = (NWNX_Creature_GetAttackBonus (oObject) + GetAC (oObject) - 10) / 2;
                SetLocalInt (oCreature, ALLY_COMBAT + sCnt, nCombat);
                // ********** Set the Ally Health Percentage **********
                nHealth = GetPercentageHPLoss (oObject);
                SetLocalInt (oCreature, ALLY_HEALTH + sCnt, nHealth);
                // ********** Set the number of enemies near the ally **********
                nMelee = 0;
                nNth = 1;
                oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while (oMelee != OBJECT_INVALID && GetDistanceBetween (oMelee, oObject) < 10.0)
                {
                    if (GetIsEnemy (oMelee)) nMelee ++;
                    else nMelee --;
                    oMelee = GetNearestCreature (CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt (oCreature, ALLY_MELEE + sCnt, nMelee);
                // ********** Set the Allies distance **********
                SetLocalFloat (oCreature, ALLY_RANGE + sCnt, GetDistanceToObject (oObject));
                // ********** All allies are considered to be seen **********
                SetLocalInt (oCreature, ALLY_SEEN + sCnt, TRUE);
                //Debug ("0i_combat", "1757", "Ally (" + IntToString (nAllyNum) + "): " +
                //       GetName (oObject) + sDebugText);
                //Debug ("0i_combat", "1759", "nHealth: " + IntToString (nHealth) +
                //       " nCombat: " + IntToString (nCombat) +
                //       " nMelee: " + IntToString (nMelee) +
                //       " fDistance: " + FloatToString (GetDistanceToObject (oObject), 0, 2) +
                //       " nAllyNum: " + IntToString (nAllyNum));
            }
        }
        sDebugText = "";
        oObject = GetNextObjectInShape (SHAPE_SPHERE, RANGE_BATTLEFIELD, lLocation, TRUE);
    }
    //Debug ("0i_combat", "1769", "Nearest Enemy: " + GetName (oNearestEnemy));
    //Debug ("0i_combat", "1770", "****************** FINISHED COMBAT DATA  *******************");
    //Debug ("0i_combat", "1771", "************************************************************");
    // Lets save processing by only clearing previous enemy data we don't overwrite.
    int nEnd = GetLocalInt (oCreature, ENEMY_NUMBERS);
    nCnt = nEnemyNum + 1;
    while (nEnd >= nCnt)
    {
        sCnt = IntToString (nCnt);
        DeleteLocalObject (oCreature, ENEMY + sCnt);
        DeleteLocalInt (oCreature, ENEMY_SEEN + sCnt);
        DeleteLocalFloat (oCreature, ENEMY_RANGE + sCnt);
        DeleteLocalInt (oCreature, ENEMY_COMBAT + sCnt);
        DeleteLocalInt (oCreature, ENEMY_MELEE + sCnt);
        DeleteLocalInt (oCreature, ENEMY_HEALTH + sCnt);
        nCnt ++;
    }
    // Lets save processing by only clearing previous ally data we don't overwrite.
    nEnd = GetLocalInt (oObject, ALLY_NUMBERS);
    nCnt = nAllyNum + 1;
    while (nEnd >= nCnt)
    {
        DeleteLocalObject (oCreature, ALLY + sCnt);
        DeleteLocalInt (oCreature, ALLY_SEEN + sCnt);
        DeleteLocalFloat (oCreature, ALLY_RANGE + sCnt);
        DeleteLocalInt (oCreature, ALLY_COMBAT + sCnt);
        DeleteLocalInt (oCreature, ALLY_MELEE + sCnt);
        DeleteLocalInt (oCreature, ALLY_HEALTH + sCnt);
        nCnt ++;
    }
    // Finally set all group states.
    SetLocalInt (oCreature, ENEMY_NUMBERS, nEnemyNum);
    SetLocalObject (oCreature, ENEMY_NEAREST, oNearestEnemy);
    SetLocalInt (oCreature, ALLY_NUMBERS, nAllyNum);
    return oNearestEnemy;
}
//******************************************************************************
//******************** Get Targets in combat functions *************************
//******************************************************************************
// Returns the index of the nearest creature seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetNearestCreatureTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = 40.0, fLowestDTargetRange = 40.0;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "1629", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget))
            {
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, sCreatureType + "_DISABLED" + sCnt))
                {
                    if (fTargetRange < fLowestDTargetRange)
                    {
                        fLowestDTargetRange = fTargetRange;
                        nDIndex = nCnt;
                    }
                }
                // Is closer.
                else if (fTargetRange < fLowestTargetRange)
                {
                    fLowestTargetRange = fTargetRange;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "1851", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the lowest combat rating target seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetLowestCombatRating (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "1868", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget))
            {
                nCombat = GetLocalInt (oCreature, sCreatureType + "_COMBAT" + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, sCreatureType + "_DISABLED" + sCnt))
                {
                    if (nCombat < nLDCombat || (nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has less combat or equal combat and is closer.
                else if (nCombat < nLCombat || (nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nLCombat = nCombat;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "1901", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString (nLCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the highest combat rating target seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestCombatRating (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "1918", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " +
        //       IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget))
            {
                nCombat = GetLocalInt (oCreature, sCreatureType + "_COMBAT" + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, sCreatureType + "_DISABLED" + sCnt))
                {
                    if (nCombat < nHDCombat || (nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nHDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has greater combat or equal combat and is closer.
                else if (nCombat > nHCombat || (nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHCombat = nCombat;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "1952", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " HighestCombatRating: " + IntToString (nHCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the lowest combat rating target seen within fRange.
// Also checks health for spells so we don't over damage a target.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetLowestCombatRatingForSpell (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, ENEMY_RANGE + sCnt);
        //Debug ("0i_combat", "1969", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, ENEMY + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, ENEMY_SEEN + sCnt) &&
                !GetIsDead (oTarget))
            {
                nCombat = GetLocalInt (oCreature, ENEMY_COMBAT + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, ENEMY_DISABLED + sCnt))
                {
                    if (nCombat < nLDCombat || (nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has the lowest combat or equal combat and is closer.
                else if (nCombat < nLCombat || (nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if (GetLocalInt (OBJECT_SELF, ENEMY_HEALTH) > 25)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor (oTarget);
                        //Debug ("0i_combat", "2001", "CurrentHP: " + IntToString (GetCurrentHitPoints (oTarget)) +
                        //       "oAttacker: " + GetName (oAttacker));
                        // Is not being attacked by someone else then change.
                        if (oAttacker != oCreature || !GetIsObjectValid (oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLCombat = nCombat;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2019", ENEMY + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString (nLCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the highest combat rating target seen within fRange.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetHighestCombatRatingForSpell (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, ENEMY_RANGE + sCnt);
        //Debug ("0i_combat", "2035", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " +
        //       IntToString (GetLocalInt (oCreature, ENEMY + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if (GetLocalInt (oCreature, ENEMY_SEEN + sCnt) &&
                !GetIsDead (oTarget))
            {
                nCombat = GetLocalInt (oCreature, ENEMY_COMBAT + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, ENEMY_DISABLED + sCnt))
                {
                    if (nCombat < nHDCombat || (nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nHDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has greater combat or equal combat and is closer.
                else if (nCombat > nHCombat || (nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if (GetLocalInt (OBJECT_SELF, ENEMY_HEALTH) > 25)
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor (oTarget);
                        //Debug ("0i_combat", "2068", "CurrentHP: " + IntToString (GetCurrentHitPoints (oTarget)) +
                        //       "oAttacker: " + GetName (oAttacker));
                        // Is not being attacked by someone else then change.
                        if (oAttacker != oCreature || !GetIsObjectValid (oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nHCombat = nCombat;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2086", ENEMY + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " HighestCombatRating: " + IntToString (nHCombat) + " = " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the target with the most enemies seen in melee.
// If none is found then it will return 0.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestMeleeTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nHMelee = -100, nMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "3103", GetName (oTarget) + " fTargetRange: " +
        //FloatToString (fTargetRange, 0, 2) + " fRange: " + FloatToString (fRange, 0, 2) +
        //" Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget))
            {
                nMelee = GetLocalInt (oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has greater melee or equal melee and is closer.
                if (nMelee > nHMelee || (nMelee == nHMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHMelee = nMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    //Debug ("0i_combat", "2125", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " HighestMeleeTarget: " + IntToString (nHMelee) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the target with the least allies seen in melee.
// If none is found then it will return 0.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetLowestMeleeTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nLMelee = 100, nMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2142", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fTargetRange: " + FloatToString (fRange, 0, 2) + " Seen: " +
        //       IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget))
            {
                nMelee = GetLocalInt (oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has lower melee or equal melee and is closer.
                if (nMelee < nLMelee || (nMelee == nLMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nLMelee = nMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    //Debug ("0i_combat", "2164", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestMeleeTarget: " + IntToString (nLMelee) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the target with least % of hitpoints seen.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetMostWoundedTargetForDamage (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF)
{
    int nCnt = 1;
    int nIndex, nHp, nLHp = 200;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange;
    object oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, ENEMY_RANGE + sCnt);
        //Debug ("0i_combat", "2181", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, ENEMY + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, ENEMY_SEEN + sCnt) &&
                !GetIsDead (oTarget))
            {
                nHp = GetLocalInt (oCreature, ENEMY_HEALTH + sCnt);
                // Has lower health or equal health and is closer.
                if (nHp < nLHp || (nHp == nLHp && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if (nHp > 25)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLHp = nHp;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor (oTarget);
                        //Debug ("0i_combat", "2203", "CurrentHP: " + IntToString (GetCurrentHitPoints (oTarget)) +
                        //       "oAttacker: " + GetName (oAttacker));
                        // Is not being attacked by someone else then change.
                        if (oAttacker != oCreature || !GetIsObjectValid (oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLHp = nHp;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    }
    //Debug ("0i_combat", "2219", ENEMY + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " GetMostWoundedTargetForDamage: " + IntToString (nLHp) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the target with least % of hitpoints seen.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetMostWoundedTargetForHealing (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF)
{
    int nCnt = 1;
    int nIndex, nHp, nLHp = 200;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange;
    object oTarget = GetLocalObject (oCreature, ALLY + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, ALLY_RANGE + sCnt);
        //Debug ("0i_combat", "2236", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, ALLY_SEEN + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead.
            if (GetLocalInt (oCreature, ALLY_SEEN + sCnt) &&
                !GetIsDead (oTarget))
            {
                nHp = GetLocalInt (oCreature, ALLY_HEALTH + sCnt);
                // We cannot heal undead.
                if (GetRacialType (oTarget) != RACIAL_TYPE_UNDEAD)
                {
                    // Has lower health or equal health and is closer.
                    if (nHp < nLHp || (nHp == nLHp && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nLHp = nHp;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, ALLY + sCnt);
    }
    //Debug ("0i_combat", "2261", ALLY + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " GetMostWoundedTargetForHealing: " + IntToString (nLHp) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the nearest creature that is attacking an ally seen within fRange.
// Also checks if the target has sneak attack
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
int GetBestSneakAttackTarget (float fRange = RANGE_PERCEPTION, object oCreature = OBJECT_SELF)
{
    int nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = 40.0f, fLowestDTargetRange = 40.0;
    object oAttacking, oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, ENEMY + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2278", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, ENEMY + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, ENEMY + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget) &&
            // Uncanny Dodge II gives immunity to sneak attack unless attacker
            // is 4 levels higher. We will assume they are always immune for simplicity.
                !GetHasFeat (FEAT_UNCANNY_DODGE_2, oTarget))
            {
                oAttacking = GetAttackedTarget (oTarget);
                // Are they attacking someone else?
                //Debug ("0i_combat", "2291", "oTarget: " + GetName (oTarget) +
                //       " is attacking " + GetName (oAttacking));
                if (GetIsObjectValid (oAttacking) && oAttacking != oCreature)
                {
                    // Lets put any disabled targets in its own group.
                    if (GetLocalInt (oCreature, ENEMY + "_DISABLED" + sCnt))
                    {
                        if (fTargetRange < fLowestDTargetRange)
                        {
                            fLowestDTargetRange = fTargetRange;
                            nDIndex = nCnt;
                        }
                    }
                    // Is closer.
                    else if (fTargetRange < fLowestTargetRange)
                    {
                        fLowestTargetRange = fTargetRange;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, ENEMY + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2318", "Get attacking target: fRange: " + FloatToString (fRange, 0, 2) +
    //       " Index: " + IntToString (nIndex));
    return nIndex;
}
// Finds a creature with the highest group of enemies around them.
// fRange is the range to check.
// sCreatureType is either ENEMY, or ALLY.
// sIndex is the index of the creature saved on oCreature.
object GetGroupedSpellTarget (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString (GetHighestMeleeTarget (fRange, sCreatureType, oCreature));
    int nMelee = GetLocalInt (oCreature, sCreatureType + "_MELEE" + sIndex) + 1;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sIndex);
    // If they found a target and we have a 25% per enemy in group.
    int nRoll = d4();
    //Debug ("0i_combat", "2334", "oTarget: " + GetName (oTarget) + " nMelee:" + IntToString (nMelee) +
    //       " d4:" + IntToString (nRoll));
    if (oTarget != OBJECT_INVALID && nMelee >= nRoll) return oTarget;
    return OBJECT_INVALID;
}
// Checks to see if oTarget is in a dangerous Area of Effect.
// Returns TRUE if they are and FALSE if not.
int IsInADangerousAOE (object oTarget = OBJECT_SELF)
{
    int nCnt = 1;
    string sAOEType;
    object oAOE = GetNearestObject (OBJECT_TYPE_AREA_OF_EFFECT, oTarget, nCnt);
    while (oAOE != OBJECT_INVALID)
    {
        //Debug ("0i_combat", "2348", "oTarget/oAOE distance: " + FloatToString (GetDistanceBetween (oTarget, oAOE), 0, 2) +
        //       " AOE Radius: " + FloatToString (NWNX_Object_GetAoEObjectRadius (oAOE), 0, 2) +
        //       " AOE Type: " + GetTag (oAOE));
        if (GetDistanceBetween (oTarget, oAOE) <= NWNX_Object_GetAoEObjectRadius (oAOE))
        {
            // AOE's have the tag set to the "LABEL" in vfx_persistent.2da
            // I have changed those tags to be equal to the row # for easy reference.
            // Below is the list of Offensive AOE effects.
            sAOEType = GetTag (oAOE);
            if (sAOEType == "VFX_PER_FOGACID" || sAOEType == "VFX_PER_FOGFIRE" ||
                sAOEType == "VFX_PER_FOGSTINK" || sAOEType == "VFX_PER_FOGKILL" ||
                sAOEType == "VFX_PER_FOGMIND" || sAOEType == "VFX_PER_WALLFIRE" ||
                sAOEType == "VFX_PER_WALLBLADE" || sAOEType == "VFX_PER_WEB" ||
                sAOEType == "VFX_PER_ENTANGLE" || sAOEType == "VFX_PER_DARKNESS" ||
                sAOEType == "VFX_MOB_SILENCE" || sAOEType == "VFX_PER_DELAY_BLAST_FIREBALL" ||
                sAOEType == "VFX_PER_GREASE" || sAOEType == "VFX_PER_CREEPING_DOOM" ||
                sAOEType == "VFX_PER_EVARDS_BLACK_TENTACLES" || sAOEType == "VFX_PER_GLYPH" ||
                sAOEType == "VFX_PER_FOGBEWILDERMENT") return TRUE;
        }
        oAOE = GetNearestObject (OBJECT_TYPE_AREA_OF_EFFECT, oTarget, ++nCnt);
    }
    return FALSE;
}
// Returns the index of the nearest target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetNearestTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = 40.0, fLowestDTargetRange = 40.0;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2382", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be in a dangerous AOE.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget) &&
                !IsInADangerousAOE (oTarget))
            {
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, ENEMY + "_DISABLED" + sCnt))
                {
                    if (fTargetRange < fLowestDTargetRange)
                    {
                        fLowestDTargetRange = fTargetRange;
                        nDIndex = nCnt;
                    }
                }
                // Is closer.
                else if (fTargetRange < fLowestTargetRange)
                {
                    fLowestTargetRange = fTargetRange;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2413", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString (nLCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the lowest combat rating target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetLowestCombatRatingNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2431", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget) &&
                !IsInADangerousAOE (oTarget))
            {
                nCombat = GetLocalInt (oCreature, sCreatureType + "_COMBAT" + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, ENEMY + "_DISABLED" + sCnt))
                {
                    if (nCombat < nLDCombat || (nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // has less combat or equal combat and is closer.
                else if (nCombat < nLCombat || (nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nLCombat = nCombat;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2465", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString (nLCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the highest combat rating target seen within fRange
// that is not in a dangerous AOE effect.
// If none is found then it will return OBJECT_INVALID.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestCombatRatingNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nHCombat = 0, nHDCombat = 0, nCombat, nIndex, nDIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2483", GetName (oTarget) + " fTargetRange: " + FloatToString (fTargetRange, 0, 2) +
        //       " fRange: " + FloatToString (fRange, 0, 2) + " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget) &&
                !IsInADangerousAOE (oTarget))
            {
                nCombat = GetLocalInt (oCreature, sCreatureType + "_COMBAT" + sCnt);
                // Lets put any disabled targets in its own group.
                if (GetLocalInt (oCreature, ENEMY + "_DISABLED" + sCnt))
                {
                    if (nCombat > nHDCombat || (nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nHDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // has less combat or equal combat and is closer.
                else if (nCombat > nHCombat || (nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHCombat = nCombat;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if (nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //Debug ("0i_combat", "2517", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString (nLCombat) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Returns the index of the target with the most enemies seen in melee.
// If none is found then it will return 0.
// fRange is the maximum distance from oCreature they will check.
// sCreatureType is either ENEMY or ALLY.
int GetHighestMeleeTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    int nHMelee = -100, nMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    while (oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat (oCreature, sCreatureType + "_RANGE" + sCnt);
        //Debug ("0i_combat", "2535", GetName (oTarget) + " fTargetRange: " +
        //       FloatToString (fTargetRange, 0, 2) + " fRange: " + FloatToString (fRange, 0, 2) +
        //       " Seen: " + IntToString (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt)));
        if (fTargetRange <= fRange)
        {
            // We must be able to see them.
            if (GetLocalInt (oCreature, sCreatureType + "_SEEN" + sCnt) &&
                !GetIsDead (oTarget) &&
                !IsInADangerousAOE (oTarget))
            {
                nMelee = GetLocalInt (oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has greater melee and equal melee and is closer.
                if (nMelee > nHMelee || (nMelee == nHMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHMelee = nMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString (++nCnt);
        oTarget = GetLocalObject (oCreature, sCreatureType + sCnt);
    }
    //Debug ("0i_combat", "2557", sCreatureType + " fRange: " + FloatToString (fRange, 0, 2) +
    //       " HighestMeleeTarget: " + IntToString (nHMelee) + " Index: " + IntToString (nIndex));
    return nIndex;
}
// Finds a creature with the highest group of enemies around them.
// fRange is the range to check.
// sCreatureType is either ENEMY, or ALLY.
// sIndex is the index of the creature saved on oCreature.
object GetGroupedSpellTargetNotInAOE (float fRange = RANGE_PERCEPTION, string sCreatureType = ENEMY, object oCreature = OBJECT_SELF)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString (GetHighestMeleeTargetNotInAOE (fRange, sCreatureType, oCreature));
    int nMelee = GetLocalInt (oCreature, sCreatureType + "_MELEE" + sIndex) + 1;
    object oTarget = GetLocalObject (oCreature, sCreatureType + sIndex);
    // If they found a target and we have a 25% per enemy in group.
    int nRoll = d4();
    //Debug ("0i_combat", "2573", "oTarget: " + GetName (oTarget) + " nMelee:" + IntToString (nMelee) +
    //       " d4:" + IntToString (nRoll));
    if (oTarget != OBJECT_INVALID && nMelee >= nRoll) return oTarget;
    return OBJECT_INVALID;
}
// Gets the nearest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetNearestTargetForMeleeCombat (int nMelee)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if (nMelee > 0) sIndex = IntToString (GetNearestCreatureTarget (RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the nearest enemy.
        sIndex = IntToString (GetNearestTargetNotInAOE (RANGE_BATTLEFIELD));
        // If we didn't get a target then they are all in an AOE so get one anyway!
        if (sIndex == "0") sIndex = IntToString (GetNearestCreatureTarget (RANGE_BATTLEFIELD));
        // Should we look them over and see if this is a wise idea?
        if (GetAssociateMode (MODE_CHECK_ATTACK))
        {
            int nECombat = GetLocalInt (OBJECT_SELF, ENEMY_COMBAT + sIndex);
            int nOCombat = (NWNX_Creature_GetAttackBonus (OBJECT_SELF) + GetAC (OBJECT_SELF) - 10) / 2;
            //Debug ("0i_combat", "2599", GetName (OBJECT_SELF) + " (nAtk: " +
            //       IntToString (NWNX_Creature_GetAttackBonus (OBJECT_SELF)) +
            //       " nAC: " + IntToString (GetAC (OBJECT_SELF) - 10) + ") / 2 =  nOCombat: " +
            //       IntToString (nOCombat) + " nECombat: " + IntToString (nECombat));
            // They are too strong so hold here until next round.
            if (nECombat > nOCombat)
            {
                //Debug ("0i_combat", "2606", GetName (OBJECT_SELF) +
                //       " our target is too strong so lets hold here!");
                return OBJECT_INVALID;
            }
        }
    }
    object oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
    // We might not have a target, if so then just use the nearest target.
    if (oTarget == OBJECT_INVALID) oTarget = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    return oTarget;
}

// Gets the weakest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetWeakestTargetForMeleeCombat (int nMelee)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if (nMelee > 0) sIndex = IntToString (GetLowestCombatRating (RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the weakest combat rated enemy.
        sIndex = IntToString (GetLowestCombatRatingNotInAOE (RANGE_BATTLEFIELD));
        // If we didn't get a target then they are all in an AOE so get one anyway!
        if (sIndex == "0") sIndex = IntToString (GetLowestCombatRating (RANGE_BATTLEFIELD));
        // Should we look them over and see if this is a wise idea?
        if (GetAssociateMode (MODE_CHECK_ATTACK))
        {
            int nECombat = GetLocalInt (OBJECT_SELF, ENEMY_COMBAT + sIndex);
            int nOCombat = (NWNX_Creature_GetAttackBonus (OBJECT_SELF) + GetAC (OBJECT_SELF) - 10) / 2;
            //Debug ("0i_combat", "2639", GetName (OBJECT_SELF) + " (nAtk: " +
            //       IntToString (NWNX_Creature_GetAttackBonus (OBJECT_SELF)) +
            //       " nAC: " + IntToString (GetAC (OBJECT_SELF) - 10) + ") / 2 =  nOCombat: " +
            //       IntToString (nOCombat) + " nECombat: " + IntToString (nECombat));
            // They are too strong so hold here until next round.
            if (nECombat > nOCombat)
            {
                //Debug ("0i_combat", "2646", GetName (OBJECT_SELF) +
                //       " our target is too strong so lets hold here!");
                return OBJECT_INVALID;
            }
        }
    }
    object oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
    // We might not have a target, if so then just use the nearest target.
    if (oTarget == OBJECT_INVALID) oTarget = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    return oTarget;
}
// Gets the strongest target for melee combat based if we are in melee or not.
// If not in melee it will get the best target for us to attack.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
object GetStrongestTargetForMeleeCombat (int nMelee)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if (nMelee > 0) sIndex = IntToString (GetHighestCombatRating (RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the weakest combat rated enemy.
        sIndex = IntToString (GetHighestCombatRatingNotInAOE (RANGE_BATTLEFIELD));
        // If we didn't get a target then they are all in an AOE so get one anyway!
        if (sIndex == "0") sIndex = IntToString (GetHighestCombatRating (RANGE_BATTLEFIELD));
        // Should we look them over and see if this is a wise idea?
        if (GetAssociateMode (MODE_CHECK_ATTACK))
        {
            int nECombat = GetLocalInt (OBJECT_SELF, ENEMY_COMBAT + sIndex);
            int nOCombat = (NWNX_Creature_GetAttackBonus (OBJECT_SELF) + GetAC (OBJECT_SELF) - 10) / 2;
            //Debug ("0i_combat", "2678", GetName (OBJECT_SELF) + " (nAtk: " +
            //       IntToString (NWNX_Creature_GetAttackBonus (OBJECT_SELF)) +
            //       " nAC: " + IntToString (GetAC (OBJECT_SELF) - 10) + ") / 2 =  nOCombat: " +
            //       IntToString (nOCombat) + " nECombat: " + IntToString (nECombat));
            // They are too strong so hold here until next round.
            if (nECombat > nOCombat)
            {
                //Debug ("0i_combat", "2685", GetName (OBJECT_SELF) +
                //       " our target is too strong so lets hold here!");
                return OBJECT_INVALID;
            }
        }
    }
    object oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
    // We might not have a target, if so then just use the nearest target.
    if (oTarget == OBJECT_INVALID) oTarget = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    return oTarget;
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
// Set an associates ai scripts based on the first class.
void SetAssociateAIScript (object oCreature = OBJECT_SELF)
{
    // Check for combat modes.
    if (GetCombatMode (COMBAT_MODE_AMBUSHER))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_ambusher");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_NO_COMBAT))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_no_combat");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_DEFENSIVE))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_defensive");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_RANGED))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_ranged");
        return;
    }
    // If they have more than one class use the default ai.
    if (GetClassByPosition (2, oCreature) != CLASS_TYPE_INVALID)
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_default");
    // Select the best ai for this henchmen based on class.
    int nClass = GetClassByPosition (1, oCreature);
    if (nClass == CLASS_TYPE_BARBARIAN) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_barbarian");
    else if (nClass == CLASS_TYPE_BARD) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_bard");
    else if (nClass == CLASS_TYPE_CLERIC) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_cleric");
    else if (nClass == CLASS_TYPE_DRUID) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_druid");
    else if (nClass == CLASS_TYPE_FAVORED_SOUL) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_fsoul");
    else if (nClass == CLASS_TYPE_FIGHTER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_fighter");
    else if (nClass == CLASS_TYPE_MONK) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_monk");
    else if (nClass == CLASS_TYPE_PALADIN2) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_paladin");
    else if (nClass == CLASS_TYPE_RANGER2) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_ranger");
    else if (nClass == CLASS_TYPE_ROGUE) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_rogue");
    else if (nClass == CLASS_TYPE_SORCERER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_sorcerer");
    else if (nClass == CLASS_TYPE_SWASHBUCKLER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_sbuckler");
    else if (nClass == CLASS_TYPE_WARMAGE) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_warmage");
    else if (nClass == CLASS_TYPE_WIZARD) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_wizard");
    else SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ass_default");
}

// Set the creatures ai scripts based on the first class or the variable
// "DEFAULT_AI_SCRIPT".
void SetCreatureAIScript (object oCreature = OBJECT_SELF)
{
    string sAI = GetLocalString (oCreature, "DEFAULT_AI_SCRIPT");
    if (sAI != "")
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", sAI);
        return;
    }
    // Check for combat modes.
    if (GetCombatMode (COMBAT_MODE_AMBUSHER))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ambusher");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_NO_COMBAT))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_no_combat");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_DEFENSIVE))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_defensive");
        return;
    }
    if (GetCombatMode (COMBAT_MODE_RANGED))
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
        return;
    }
    // Select the best ai for this henchmen based on class.
    int nClass = GetClassByPosition (1, oCreature);
    // If they have more than one class use the default ai.
    if (GetClassByPosition (2, oCreature) != CLASS_TYPE_INVALID)
    {
        SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    }
    else if (nClass == CLASS_TYPE_BARBARIAN) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_barbarian");
    else if (nClass == CLASS_TYPE_BARD) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_bard");
    else if (nClass == CLASS_TYPE_CLERIC) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_cleric");
    else if (nClass == CLASS_TYPE_DRUID) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_druid");
    else if (nClass == CLASS_TYPE_FAVORED_SOUL) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_fsoul");
    else if (nClass == CLASS_TYPE_FIGHTER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_fighter");
    else if (nClass == CLASS_TYPE_MONK) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_monk");
    else if (nClass == CLASS_TYPE_PALADIN2) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_paladin");
    else if (nClass == CLASS_TYPE_RANGER2) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_ranger");
    else if (nClass == CLASS_TYPE_ROGUE) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_rogue");
    else if (nClass == CLASS_TYPE_SORCERER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_sorcerer");
    else if (nClass == CLASS_TYPE_SWASHBUCKLER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_sbuckler");
    else if (nClass == CLASS_TYPE_WARMAGE) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_warmage");
    else if (nClass == CLASS_TYPE_WIZARD) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_wizard");
    //else if (nClass == CLASS_TYPE_ABERRATION) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    else if (nClass == CLASS_TYPE_ANIMAL) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_animal");
    else if (nClass == CLASS_TYPE_CONSTRUCT) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_animal");
    else if (nClass == CLASS_TYPE_DRAGON) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_dragon");
    //else if (nClass == CLASS_TYPE_ELEMENTAL) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_FEY) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_GIANT) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_HUMANOID) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_MAGICAL_BEAST) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    else if (nClass == CLASS_TYPE_MONSTROUS) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_OOZE) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_OUTSIDER) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    //else if (nClass == CLASS_TYPE_UNDEAD) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
    else if (nClass == CLASS_TYPE_VERMIN) SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_animal");
    else SetLocalString (oCreature, "COMBAT_AI_SCRIPT", "ai_default");
}
