/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_combat
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for combat scripts.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
#include "0i_items"
#include "0i_spells"
// This structure is used to represent the number and type of
// enemies that a creature is facing, divided into four main
// categories: FIGHTERS, CLERICS, MAGES, MONSTERS.
struct stClasses
{
    int FIGHTERS;
    int FIGHTER_LEVELS;
    int CLERICS;
    int CLERIC_LEVELS;
    int MAGES;
    int MAGE_LEVELS;
    int MONSTERS;
    int MONSTER_LEVELS;
    int TOTAL;
    int TOTAL_LEVELS;
};
//******************************************************************************
//************ GET TARGETS USING THE OBJECT SEARCH FUNCTIONS *******************
//******************************************************************************
// Returns the nearest enemy that is not disabled from oCreature.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 & nCType2, with
// corresponding values for nCValue1 & nCValue2.
// NOTE: CREATURE_TYPE_PERCEPTION = 7, PERCEPTION_SEEN = 7.
// bDisabled = TRUE will also return any disabled targets that are not dead.
object ai_GetNearestEnemy(object oCreature, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1, int bDisabled = FALSE);
// Returns the nearest ally from oCreature.
// You may pass in any of the CREATURE_TYPE_* constants
// used in GetNearestCreature as nCType1 & nCType2, with
// corresponding values for nCValue1 & nCValue2.
// NOTE: CREATURE_TYPE_PERCEPTION = 7, PERCEPTION_SEEN = 7.
object ai_GetNearestAlly(object oCreature, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1);
// Returns the number of alive enemies grouped near oCreature within fDistance.
int ai_GetNumOfEnemiesInGroup(object oCreature, float fDistance = AI_RANGE_MELEE);
// Returns the number of alive allies grouped near oCreature within fDistance.
int ai_GetNumOfAlliesInGroup(object oCreature, float fDistance = AI_RANGE_MELEE);
// Returns the number of creatures of nRacial_Type within fDistance that can be seen by oCreature.
int ai_GetRacialTypeCount(object oCreature, int nRacial_Type, float fDistance = AI_RANGE_PERCEPTION);
// Returns the weakest attacker that is in melee or is attacking oCreature's master.
object ai_GetLowestCRAttackerOnMaster(object oCreature);

//******************************************************************************
//******************** SET/CLEAR COMBAT STATE FUNCTIONS ************************
//******************************************************************************
// Sets oCreatures's combat state by setting variables for AI_ALLIES and AI_ENEMIES.
// Returns the nearest visible enemy.
object ai_SetCombatState(object oCreature);
// Clears all variables that were define for the current round for oCreature.
void ai_ClearCombatState(object oCreature);

//******************************************************************************
//*************** GET TARGETS USING COMBAT STATE FUNCTIONS *********************
//******************************************************************************
// These functions will find a target or an index to a target based on the
// combat state variables created by the function ai_SetCombatState.

// Returns the Index of the nearest creature seen within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetNearestCreatureIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest creature seen wihtin fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetNearestTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the nearest creature seen with the lowest combat rating
// within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetLowestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest creature seen with the lowest combat rating within fRange
// in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetLowestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the nearest creature seen with the highest combat rating
// within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetHighestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest creature seen with the highest combat rating within fRange
// in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetHighestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the creature seen with the lowest enemies to oCreature that
// they are in melee with minus the number of allies to the caller they are in
// melee with within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetLowestMeleeIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY);
// Returns the index of the creature seen with the most enemies to the caller that
// they are in melee with minus the number of allies to oCreature they are in
// melee with within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetHighestMeleeIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY);
// Returns the index of the creature seen with the lowest combat rating and has
// a higher health % than AI_HEALTH_BLOODY within fRange in the combat state.
// Keeps casters from over killing enemies.
// If no creature is found then it will return an index of 0.
int ai_GetLowestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the index of the nearest creature seen with the highest combat rating
// and has a higher health % than AI_HEALTH_BLOODY within fRange in the combat state.
// Helps to keep casters from over killing enemies.
// If no creature is found then it will return an index of 0.
int ai_GetHighestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the index of the nearest creature with the least % of hitpoints within
// fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetMostWoundedIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the lowest health seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetMostWoundedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the nearest ally with the least % of hitpoints within
// fRange in the combat state.
// This also filters for AI_MODE_PARTY_HEALING_OFF and AI_MODE_SELF_HEALING_OFF.
// If no ally is found then it will return an index of 0.
int ai_GetAllyToHealIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the ally with the lowest health seen within fRange in the combat state.
// This also filters for AI_MODE_PARTY_HEALING_OFF and AI_MODE_SELF_HEALING_OFF.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetAllyToHealTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the creature with the lowest fortitude save seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetLowestFortitudeSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the creature with the lowest reflex save seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetLowestReflexSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the creature with the lowest will save seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetLowestWillSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION);
// Returns the creature with the lowest save based on nSpell save type seen
// within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetSpellTargetBasedOnSaves(object oCreature, int nSpell, float fRange = AI_RANGE_PERCEPTION);
// Returns the index of the nearest enemy creature that can see oCreature.
int ai_GetNearestIndexThatSeesUs(object oCreature);
// Returns the index of the nearest creature seen that is busy attacking an ally
// within fRange in the combat state.
// If none is found then it will return 0.
int ai_GetBestSneakAttackIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE);
// Returns the Index of the nearest creature seen that is not in a dangerous
// area of effect within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetNearestIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest combat creature seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetNearestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the nearest creature seen with the lowest combat rating
// that is not in a dangerous area of effect within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetLowestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the lowest combat creature seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetLowestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the nearest creature seen with the highest combat rating
// that is not in a dangerous area of effect within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetHighestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the highest combat creature seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
object ai_GetHighestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the index of the creature seen with the most enemies to oCreature that
// they are in melee with minus the number of allies to oCreature they are in
// melee with that is not in a dangerous area of effect within fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetHighestMeleeIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY);
// Returns a creature of sCreatureType where they have the least number of
// allies and the most number of enemies within fRange in the combat state.
// Returns OBJECT_INVALID if there is not a good creature to select.
// sCreatureType is either AI_ENEMY, or AI_ALLY.
object ai_CheckForGroupedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY);
// Returns a creature of sCreatureType where they have the least number of
// allies and the most number of enemies within fRange that are not in a
// dangerous area of effect in the combat state.
// Returns OBJECT_INVALID if there is not a good creature to select.
// sCreatureType is either AI_ENEMY, or AI_ALLY.
object ai_CheckForGroupedTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY);
// Returns the nearest creature seen of nClassType within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetNearestClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the lowest combat rating seen of nClassType within
// fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetLowestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the highest combat rating seen of nClassType within
// fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetHighestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest creature seen of nRacialType within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetNearestRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the lowest combat rating seen of nRacialType within
// fRange in the combat state. Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetLowestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the highest combat rating seen of nRacialType within
// fRange in the combat state. Returns OBJECT_INVALID if no creature is found.
// sCreatureType is either AI_ENEMY or AI_ALLY.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetHighestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the nearest enemy creature seen wihtin fRange that is a favored enemy
// of the caller in the combat state.
// Returns OBJECT_INVALID if no creature is found.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetNearestFavoredEnemyTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE);
// Returns the nearest creature for melee combat based if we are in melee or not.
// If not in melee it will get the nearest target that is not in a dangerous
// area of effect for us to attack in the combat state.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetNearestTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE);
// Returns the creature with the lowest combat rating for melee combat based if
// we are in melee or not. If not in melee it will get the nearest target that
// is not in a dangerous area of effect for us to attack in the combat state.
// If it returns OBJECT_INVALID then we should stop the attack. The only way
// to not get a target is if we have been told not to attack strong opponents.
// bAlwaysAtk TRUE we attack everything! FALSE we don't attack strong enemies.
object ai_GetLowestCRTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE);
// Returns the creature with the highest combat rating for melee combat based if
// we are in melee or not. If not in melee it will get the nearest target that
// is not in a dangerous area of effect for us to attack in the combat state.
// If it returns OBJECT_INVALID then we should stop the attack.
object ai_GetHighestCRTargetForMeleeCombat(object oCreature, int nInMelee);
// Returns the nearest creature attacking the caller within fRange in the combat state.
// Returns OBJECT_INVALID if oCreature is not being attacked.
object ai_GetEnemyAttackingMe(object oCreature, float fRange = AI_RANGE_MELEE);
// Returns the number of enemies within fRange of the caller in the combat state.
int ai_GetNumOfEnemiesInRange(object oCreature, float fRange = AI_RANGE_MELEE);
// Returns the best ally target withing fRange for nSpell to be cast on.
// Uses the ai_spells.2da file to pick a target.
object ai_GetAllyBuffTarget(object oCreature, int nSpell, float fRange = AI_RANGE_BATTLEFIELD);

//******************************************************************************
//********************  OTHER COMBAT FUNCTIONS  ********************************
//******************************************************************************

// Returns the current round that oCreature is in for this combat.
int ai_GetCurrentRound(object oCreature);
// Returns the difficulty of the battle based on the combat state.
// nDifficulty is Enemy level - Ally level + 20 + Player adjustment.
//    20+    : Impossible     - Cannot win.
// 17 to  19 : Overpowering   - Use all of our powers.
// 15 to  16 : Very Difficult - Use all of our power (Highest level spells).
// 11 to  14 : Challenging    - Use most of our power (Higher level powers).
//  8 to  10 : Moderate       - Use half of our power (Mid level powers and less).
//  5 to   7 : Easy           - Use our weaker powers (Lowest level powers).
//  2 to   4 : Effortless     - Don't waste spells and powers on this.
//  1 or less: Pointless      - We probably should ignore these dangers.
int ai_GetDifficulty(object oCreature);
// Returns oCreatures Combat rating.
//(BAB + AC - 10) / 2
int ai_GetMyCombatRating(object oCreature);
// Returns the last creature oCreature attacked.
// bPhysical checks for creatures attacked in melee or range with a weapon.
// bSpell will look for creatures attacked by a spell.
object ai_GetAttackedTarget(object oCreature, int bPhysical = TRUE, int bSpell = FALSE);
// Returns TRUE if oCreature is of nClassType;
// May also check for general Class types with
// AI_CLASS_TYPE_ARCANE, AI_CLASS_TYPE_DIVINE, AI_CLASS_TYPE_CASTER, AI_CLASS_TYPE_WARRIOR.
int ai_CheckClassType(object oCreature, int nClassType);
// Returns TRUE if oCreature is of nRacialType;
// May also check for general racial types with
// AI_RACIAL_TYPE_ANIMAL_BEAST
int ai_CheckRacialType(object oCreature, int nRacialType);
// Saves oCreatures Normal appearance if they are not polymorphed and it has
// not already been saved.
void ai_SetNormalAppearance(object oCreature);
// Returns the normal appearance of oCreature.
int ai_GetNormalAppearance(object oCreature);
// Return the number and levels of all creatures within fRange.
// They are grouped into Fighters, Clerics, Mages, and Monsters.
struct stClasses ai_GetFactionsClasses(object oCreature, int bEnemy = TRUE, float fRange = AI_RANGE_BATTLEFIELD);
// This will return the class with the most levels.
// Returns a string of "FIGHTER", "CLERIC", "MAGE", or "MONSTER".
// Execute with GetFactionsClasses.
string ai_GetMostDangerousClass(struct stClasses stCount);
// Equips the best weapon, ranged or melee.
// Returns TRUE if equiped, FALSE if not.
// oTarget is the creature the caller is targeting.
void ai_EquipBestWeapons(object oCreature, object oTarget = OBJECT_INVALID);
// Equips a melee weapon AND checks for shield, two weapons, two handed, etc.
// Returns TRUE if equiped, FALSE if not.
// oTarget is the creature the caller is targeting.
int ai_EquipBestMeleeWeapon(object oCreature, object oTarget = OBJECT_INVALID);
// Equips a ranged weapon AND checks for ammo.
// Returns TRUE if equiped, FALSE if not.
// oTarget is the creature the caller is targeting.
int ai_EquipBestRangedWeapon(object oCreature, object oTarget = OBJECT_INVALID);
// Returns TRUE if oCreature is Invisible, stealth mode, or has sanctuary up.
int ai_GetIsInvisible(object oCreature);
// Returns TRUE if if oCaster has a good chance of effecting oCreature with nSpell.
int ai_CastOffensiveSpellVsTarget(object oCaster, object oCreature, int nSpell);
// Returns TRUE if oCreature is in a Dangerous Area of Effect in fRange.
int ai_IsInADangerousAOE(object oCreature, float fRange = AI_RANGE_BATTLEFIELD);
// Gets the base DC for a dragon.
int ai_GetDragonDC(object oCreature);
// Set oCreature's ai scripts based on its first class or the variable "AI_DEFAULT_SCRIPT".
void ai_SetCreatureAIScript(object oCreature);
// Returns TRUE if oTarget is immune to sneak attacks.
int ai_IsImmuneToSneakAttacks(object oCreature, object oTarget);
// Returns TRUE if iIndex target has a higher combat rating than oCreature.
int ai_IsStrongThanMe(object oCreature, int iIndex);
// Returns TRUE if oTarget's CR is within nAdj of oCreature's level, otherwise FALSE.
int ai_StrongOpponent(object oCreature, object oTarget, int nAdj = 2);
// Returns TRUE if attacking oTarget with Power attack is a good option.
int ai_PowerAttackGood(object oCreature, object oTarget, float fAdj);
// Returns TRUE if oTarget's AC - oCreature Atk - nAtkAdj can hit within 25% to 75%.
int ai_AttackPenaltyOk(object oCreature, object oTarget, float fAtkAdj);
// Returns TRUE if oCreature AC - oTarget's Atk is less than 20.
int ai_ACAdjustmentGood(object oCreature, object oTarget, float fACAdj);
// Checks oCreatures melee weapon to see if they can kill oTarget in one hit.
int ai_WillKillInOneHit(object oCreature, object oTarget);
// Returns TRUE if oCreature has Mobility, SpringAttack, or a high Tumble.
int ai_CanIMoveInCombat(object oCreature);
// Returns TRUE if oCreature can safely fire a ranged weapon.
int ai_CanIUseRangedWeapon(object oCreature, int nInMelee);
// Returns TRUE if oCreature moves before the action. FALSE if they do not move.
// and -1 if the action is canceled.
// Checks current combat state to see if oCreature needs to move before using an action.
int ai_CheckCombatPosition(object oCreature, object oTarget, int nInMelee, int nAction, int nBaseItemType = 0);

//******************************************************************************
//************ GET TARGETS USING THE OBJECT SEARCH FUNCTIONS *******************
//******************************************************************************
object ai_GetNearestEnemy(object oCreature, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1, int bDisabled = FALSE)
{
    object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                        oCreature, nNth, nCType1, nCValue1, nCType2, nCValue2);
    if(bDisabled)
    {
        while(oTarget != OBJECT_INVALID && GetIsDead(oTarget))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                         oCreature, ++nNth, nCType1, nCValue1, nCType2, nCValue2);
        }
    }
    else
    {
        while(oTarget != OBJECT_INVALID && ai_Disabled(oTarget))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                         oCreature, ++nNth, nCType1, nCValue1, nCType2, nCValue2);
        }
    }
    return oTarget;
}
object ai_GetNearestAlly(object oCreature, int nNth = 1, int nCType1 = -1, int nCValue1 = -1, int nCType2 = -1, int nCValue2 = -1)
{
    return GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                              oCreature, ++nNth, nCType1, nCValue1, nCType2, nCValue2);
}
int ai_GetNumOfEnemiesInGroup(object oCreature, float fDistance = AI_RANGE_MELEE)
{
    int nCnt;
    location lLocation = GetLocation(oCreature);
    object oEnemy = GetFirstObjectInShape(SHAPE_SPHERE, fDistance, lLocation);
    while(oEnemy != OBJECT_INVALID)
    {
        if(GetIsEnemy(oEnemy) && !GetIsDead(oEnemy)) nCnt++;
        oEnemy = GetNextObjectInShape(SHAPE_SPHERE, fDistance, lLocation);
    }
    return nCnt;
}
int ai_GetNumOfAlliesInGroup(object oCreature, float fDistance = AI_RANGE_MELEE)
{
    int nCnt;
    location lLocation = GetLocation(oCreature);
    object oAlly = GetFirstObjectInShape(SHAPE_SPHERE, fDistance, lLocation);
    while(oAlly != OBJECT_INVALID)
    {
        if(!GetIsEnemy(oAlly) && oAlly != oCreature && !GetIsDead(oAlly))
        {
            nCnt++;
        }
        oAlly = GetNextObjectInShape(SHAPE_SPHERE, fDistance, lLocation);
    }
    return nCnt;
}
int ai_GetRacialTypeCount(object oCreature, int nRacial_Type, float fDistance = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nCount = 0;
    object oEnemy = ai_GetNearestEnemy(oCreature, nCnt,
                                      CREATURE_TYPE_PERCEPTION,
                                      PERCEPTION_SEEN,
                                      CREATURE_TYPE_RACIAL_TYPE,
                                      nRacial_Type);
    while(oEnemy != OBJECT_INVALID && GetDistanceBetween(oEnemy, oCreature) <= fDistance)
    {
        if(!ai_GetHasEffectType(oEnemy, EFFECT_TYPE_TURNED)) nCount++;
        nCnt++;
        oEnemy = ai_GetNearestEnemy(oCreature, nCnt,
                                   CREATURE_TYPE_PERCEPTION,
                                   PERCEPTION_SEEN,
                                   CREATURE_TYPE_RACIAL_TYPE,
                                   nRacial_Type);
    }
    return nCount;
}
object ai_GetLowestCRAttackerOnMaster(object oCreature)
{
    object oTarget = OBJECT_INVALID, oMaster = GetMaster(oCreature);
    //ai_Debug("0i_combat", "419", "Checking for weakest attacker on " + GetName(oMaster));
    int nEnemyCombatRating, nWeakestCombatRating, nCntr = 1;
    float fNearest = AI_RANGE_MELEE + 1.0f;
    // Get the weakest opponent in melee with our master.
    object oEnemy = ai_GetNearestEnemy(oMaster, nCntr, 7, 7);
    float fDistance = GetDistanceBetween(oMaster, oEnemy);
    while (oEnemy != OBJECT_INVALID && fDistance <= AI_RANGE_MELEE)
    {
        nEnemyCombatRating = ai_GetMyCombatRating(oEnemy);
        //ai_Debug("0i_combat", "428", GetName(oEnemy) + " nECR: " + IntToString(nEnemyCombatRating));
        if (nEnemyCombatRating < nWeakestCombatRating ||
            nEnemyCombatRating == nWeakestCombatRating && fDistance < fNearest)
        {
            fNearest = fDistance;
            nWeakestCombatRating = nEnemyCombatRating;
            oTarget = oEnemy;
        }
        oEnemy = ai_GetNearestEnemy(oMaster, ++nCntr, 7, 7);
    }
    // No targets in melee with our master, lets see if there is a ranged attacker.
    if (oTarget == OBJECT_INVALID) oTarget = GetLastHostileActor(oMaster);
    return oTarget;
}

//******************************************************************************
//******************** SET/CLEAR COMBAT STATE FUNCTIONS ************************
//******************************************************************************

object ai_SetCombatState(object oCreature)
{
    //ai_Counter_Start();
    int nEnemyNum, nEnemyPower, nAllyNum, nAllyPower, nInMelee, nMagic;
    int nHealth, nNth, nAllies, nPower, nDisabled, bThreat,nObjects;
    int nEnemyHighestPower, nAllyHighestPower;
    float fNearest = AI_RANGE_BATTLEFIELD;
    string sCnt, sDebugText;
    location lLocation = GetLocation(oCreature);
    object oMelee, oNearestEnemy = OBJECT_INVALID;
    //ai_Debug("0i_combat", "450", "************************************************************");
    //ai_Debug("0i_combat", "451", "******************* CREATING COMBAT DATA *******************");
    //ai_Debug("0i_combat", "452", GetName(oCreature));
    object oObject = oCreature;
    // Get all creatures within 40 meters(5 meters beyond our perception of 35).
    float fDistance = GetDistanceBetween(oObject, oCreature);
    while(oObject != OBJECT_INVALID && fDistance <= AI_RANGE_BATTLEFIELD)
    {
        // Process all enemies.
        if(GetIsEnemy(oObject))
        {
            if(GetObjectSeen(oObject, oCreature) || GetObjectHeard(oObject, oCreature) ||
               ai_GetIsInLineOfSight(oCreature, oObject))
            {
                // ********** Get the Total levels of the Enemy **********
                nPower = FloatToInt(GetChallengeRating(oObject));
                if(nPower < 1) nPower = 1;
                if(nEnemyHighestPower < nPower) nEnemyHighestPower = nPower;
                nEnemyPower += nPower;
                // ********** Check if the Enemy is disabled **********
                bThreat = TRUE;
                nDisabled = ai_Disabled(oObject);
                if(nDisabled)
                {
                    // !!!! For /DEBUG CODE !!!!
                    //sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
                    // Decide if they are still a threat: 1 - dead, 2 - Bleeding.
                    if(nDisabled == 1 || nDisabled == 2 ||
                       //nDisabled == EFFECT_TYPE_CONFUSED ||
                       //nDisabled == EFFECT_TYPE_FRIGHTENED ||
                       //nDisabled == EFFECT_TYPE_PARALYZE ||
                       nDisabled == EFFECT_TYPE_CHARMED ||
                       nDisabled == EFFECT_TYPE_PETRIFY)
                    {
                        bThreat = FALSE;
                        //ai_Debug("0i_combat", "485", "Enemy: " + GetName(oObject) + sDebugText);
                    }
                }
                // If they are using the coward ai then treat them as frightened.
                // we place it here as an else so we don't overwrite another disabled effect.
                else if(GetLocalString(oObject, AI_COMBAT_SCRIPT) == "ai_coward")
                {
                    nDisabled = 25;
                    // !!!! For /DEBUG CODE !!!!
                    //sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
                }
                if(bThreat)
                {
                    sCnt = IntToString(++nEnemyNum);
                    // ********** Set if the Enemy is disabled **********
                    SetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt, nDisabled);
                    // ********** Set the Enemy Object **********
                    SetLocalObject(oCreature, AI_ENEMY + sCnt, oObject);
                    // ********** Set the Enemy Combat Rating **********
                    SetLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt, ai_GetMyCombatRating(oObject));
                    // ********** Set the Enemy Health Percentage **********
                    nHealth = ai_GetPercHPLoss(oObject);
                    SetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt, nHealth);
                    // ********** Set the number of enemies near the enemy **********
                    nInMelee = 0;
                    nNth = 1;
                    oMelee = GetNearestObject(OBJECT_TYPE_CREATURE, oObject, nNth);
                    while(oMelee != OBJECT_INVALID && !GetIsDead(oMelee) &&
                          GetDistanceBetween(oMelee, oObject) < AI_RANGE_MELEE)
                    {
                        // We add an enemy to the group.
                        if(GetIsEnemy(oMelee)) nInMelee++;
                        // If they are an ally then we subtract one from the group.
                        else nInMelee--;
                        oMelee = GetNearestObject(OBJECT_TYPE_CREATURE, oObject, ++nNth);
                    }
                    SetLocalInt(oCreature, AI_ENEMY_MELEE + sCnt, nInMelee);
                    // ********** Set the Enemies distance **********
                    SetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt, fDistance);
                    // ********** Set if the Enemy is seen **********
                    if(GetObjectSeen(oObject, oCreature) ||
                      (GetObjectHeard(oObject, oCreature) && fDistance < AI_RANGE_MELEE &&
                      ai_GetIsInvisible(oObject)))
                    {
                        SetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt, TRUE);
                        //sDebugText += "**** PERCEIVED ****";
                    }
                    else SetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt, FALSE);
                    // ********** Set the Nearest Enemy seen **********
                    if(fDistance < fNearest)
                    {
                        fNearest = fDistance;
                        oNearestEnemy = oObject;
                    }
                }
                // !!! Debug code !!!
                if(fDistance < AI_RANGE_MELEE) sDebugText += "**** MELEE ****";
                //ai_Debug("0i_combat", "551", "Enemy(" + IntToString(nEnemyNum) + "): " +
                //         GetName(oObject) + sDebugText);
                //ai_Debug("0i_combat", "553", "nHealth: " + IntToString(nHealth) +
                //         " nInMelee: " + IntToString(nInMelee) +
                //         " fDistance: " + FloatToString(fDistance, 0, 2) +
                //         " nEnemyNum: " + IntToString(nEnemyNum) +
                //         " nEnemyPower: " + IntToString(nEnemyPower / 2));
            }
            else
            {
                // ********** Also add the levels of Unknown Enemies ***********
                nPower = FloatToInt(GetChallengeRating(oObject) / 1.5);
                if(nPower < 1) nPower = 1;
                nEnemyPower += nPower;
                //ai_Debug("0i_combat", "565", "Enemy(NOT PERCEIVED): " +
                //         GetName(oObject) + " fDistance: " + FloatToString(fDistance, 0, 2) +
                //         " nEnemyPower: " + IntToString(nEnemyPower / 2));
            }
        }
        // Process all Allies.
        else if(GetFactionEqual(oObject, oCreature))
        {
            // ********** Set if the Ally is disabled **********
            nDisabled = ai_Disabled(oObject);
            if(nDisabled)
            {
                //sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
                SetLocalInt(oCreature, AI_ALLY_DISABLED + sCnt, nDisabled);
            }
            if(nDisabled != 1)
            {
                sCnt = IntToString(++nAllyNum);
                // ********** Set the Ally Object **********
                SetLocalObject(oCreature, AI_ALLY + sCnt, oObject);
                // ********** Set the Ally Combat Rating **********
                SetLocalInt(oCreature, AI_ALLY_COMBAT + sCnt, ai_GetMyCombatRating(oObject));
                // ********** Set the Ally Health Percentage **********
                nHealth = ai_GetPercHPLoss(oObject);
                SetLocalInt(oCreature, AI_ALLY_HEALTH + sCnt, nHealth);
                // ********** Set the number of enemies near the ally **********
                nInMelee = 0;
                nNth = 1;
                oMelee = GetNearestObject(OBJECT_TYPE_CREATURE, oObject, nNth);
                while(oMelee != OBJECT_INVALID && !GetIsDead(oMelee) &&
                      GetDistanceBetween(oMelee, oObject) < AI_RANGE_MELEE)
                {
                    if(GetIsEnemy(oMelee)) nInMelee++;
                    else nInMelee--;
                    oMelee = GetNearestObject(OBJECT_TYPE_CREATURE, oObject, ++nNth);
                }
                SetLocalInt(oCreature, AI_ALLY_MELEE + sCnt, nInMelee);
                // ********** Set the Allies distance **********
                SetLocalFloat(oCreature, AI_ALLY_RANGE + sCnt, GetDistanceBetween(oObject, oCreature));
                // ********** All allies are considered to be seen and heard **********
                SetLocalInt(oCreature, AI_ALLY_PERCEIVED + sCnt, TRUE);
                // ********** Get the Total levels of the Allies **********
                nPower = ai_GetCharacterLevels(oObject);
                if(nAllyHighestPower < nPower) nAllyHighestPower = nPower;
                nAllyPower +=(nPower * nHealth) / 100;
                //ai_Debug("0i_combat", "610", "Ally(" + IntToString(nAllyNum) + "): " +
                //       GetName(oObject) + sDebugText);
                //ai_Debug("0i_combat", "612", "nHealth: " + IntToString(nHealth) +
                //       " nInMelee: " + IntToString(nInMelee) +
                //       " fDistance: " + FloatToString(GetDistanceToObject(oObject), 0, 2) +
                //       " nAllyNum: " + IntToString(nAllyNum) +
                //       " nAllyPower: " + IntToString(nAllyPower / 2));
            }
        }
        //sDebugText = "";
        oObject = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oCreature, ++nObjects);
        fDistance = GetDistanceBetween(oObject, oCreature);
    }
    //ai_Debug("0i_combat", "623", "Nearest Enemy: " + GetName(oNearestEnemy));
    //ai_Debug("0i_combat", "624", "****************** FINISHED COMBAT DATA  *******************");
    //ai_Debug("0i_combat", "625", "************************************************************");
    // Lets save processing by only clearing previous enemy data we don't overwrite.
    int nPreviousEnd = GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
    int nCnt = nEnemyNum + 1;
    //ai_Debug("0i_combat", "629", "Clearing Enemy Combat Data: nPreviousEnd: " +
    //         IntToString(nPreviousEnd) + " nCurrentEnd: " + IntToString(nCnt - 1));
    while(nPreviousEnd >= nCnt)
    {
        sCnt = IntToString(nCnt);
        //ai_Debug("0i_combat", "634", "Clearing Enemy Combat Data: " + sCnt + " " +
        //         GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)));
        DeleteLocalObject(oCreature, AI_ENEMY + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt);
        DeleteLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_MELEE + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt);
        nCnt ++;
    }
    // Lets save processing by only clearing previous ally data we don't overwrite.
    nPreviousEnd = GetLocalInt(oCreature, AI_ALLY_NUMBERS);
    nCnt = nAllyNum + 1;
    //ai_Debug("0i_combat", "647", "Clearing Ally Combat Data: nPreviousEnd: " +
    //         IntToString(nPreviousEnd) + " nCurrentEnd: " + IntToString(nCnt - 1));
    while(nPreviousEnd >= nCnt)
    {
        sCnt = IntToString(nCnt);
        //ai_Debug("0i_combat", "652", "Clearing Ally Combat Data: " + sCnt + " " +
        //         GetName(GetLocalObject(oCreature, AI_ALLY + sCnt)));
        DeleteLocalObject(oCreature, AI_ALLY + sCnt);
        DeleteLocalInt(oCreature, AI_ALLY_PERCEIVED + sCnt);
        DeleteLocalFloat(oCreature, AI_ALLY_RANGE + sCnt);
        DeleteLocalInt(oCreature, AI_ALLY_COMBAT + sCnt);
        DeleteLocalInt(oCreature, AI_ALLY_MELEE + sCnt);
        DeleteLocalInt(oCreature, AI_ALLY_HEALTH + sCnt);
        nCnt ++;
    }
    // Finally set all group states.
    SetLocalInt(oCreature, AI_ENEMY_NUMBERS, nEnemyNum);
    // Total enemy power is half the levels of all enemies + the total levels
    // of the highest level enemy.
    nEnemyPower = (nEnemyPower / 2) + nEnemyHighestPower;
    SetLocalInt(oCreature, AI_ENEMY_POWER, nEnemyPower);
    SetLocalObject(oCreature, AI_ENEMY_NEAREST, oNearestEnemy);
    SetLocalInt(oCreature, AI_ALLY_NUMBERS, nAllyNum);
    // Total ally power is half the levels of all allies + the total levels
    // of the highest level ally, only used by associates.
    nAllyPower = (nAllyPower / 2) + nAllyHighestPower;
    SetLocalInt(oCreature, AI_ALLY_POWER, nAllyPower);
    //ai_Debug("0i_combat", "674", "nEnemyPower: " + IntToString(nEnemyPower) +
    //         " nEnemyHighestPower: " + IntToString(nEnemyHighestPower) +
    //         " nAllyPower: " + IntToString(nAllyPower) +
    //         " nAllyHighestPower: " + IntToString(nAllyHighestPower));
    //ai_Counter_End(GetName(oCreature) + " has finished the Combat State");
    return oNearestEnemy;
}
void ai_ClearCombatState(object oCreature)
{
    int bEnemyDone, bAllyDone, nCnt = 1;
    int nEnemyNum = GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
    int nAllyNum = GetLocalInt(oCreature, AI_ALLY_NUMBERS);
    //ai_Debug("0i_combat", "686", "Clearing " + GetName(oCreature) + "'s combat state." +
    //         " nEnemyNum: " + IntToString(nEnemyNum) + " nAllyNum: " + IntToString(nAllyNum));
    string sCnt;
    while(!bEnemyDone || !bAllyDone)
    {
        sCnt = IntToString(nCnt);
        if(nCnt <= nEnemyNum)
        {
            //ai_Debug("0i_combat", "694", "Clearing " + GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)) + ".");
            DeleteLocalObject(oCreature, AI_ENEMY + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt);
            DeleteLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_MELEE + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt);
        }
        else bEnemyDone = TRUE;
        if(nCnt <= nAllyNum)
        {
            //ai_Debug("0i_combat", "706", "Clearing " + GetName(GetLocalObject(oCreature, AI_ALLY + sCnt)) + ".");
            DeleteLocalObject(oCreature, AI_ALLY + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_DISABLED + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_PERCEIVED + sCnt);
            DeleteLocalFloat(oCreature, AI_ALLY_RANGE + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_COMBAT + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_MELEE + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_HEALTH + sCnt);
        }
        else bAllyDone = TRUE;
        nCnt++;
    }
    DeleteLocalObject(oCreature, AI_ENEMY_NEAREST);
    DeleteLocalInt(oCreature, AI_ENEMY_NUMBERS);
    DeleteLocalInt(oCreature, AI_ENEMY_POWER);
    DeleteLocalInt(oCreature, AI_ALLY_NUMBERS);
    DeleteLocalObject(oCreature, AI_ALLY_POWER);
    // Also clear these combat variables at the end of combat.
    DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
    DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
    // Remove Talent variables.
    DeleteLocalJson(oCreature, AI_TALENT_CURE);
    DeleteLocalJson(oCreature, AI_TALENT_HEALING);
    DeleteLocalJson(oCreature, AI_TALENT_ENHANCEMENT);
    DeleteLocalJson(oCreature, AI_TALENT_PROTECTION);
    DeleteLocalJson(oCreature, AI_TALENT_SUMMON);
    DeleteLocalJson(oCreature, AI_TALENT_DISCRIMINANT_AOE);
    DeleteLocalJson(oCreature, AI_TALENT_INDISCRIMINANT_AOE);
    DeleteLocalJson(oCreature, AI_TALENT_RANGED);
    DeleteLocalJson(oCreature, AI_TALENT_TOUCH);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_CURE);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_HEALING);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_ENHANCEMENT);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_PROTECTION);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_SUMMON);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_DISCRIMINANT_AOE);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_INDISCRIMINANT_AOE);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_RANGED);
    DeleteLocalInt(oCreature, AI_NO_TALENTS + AI_TALENT_TOUCH);
    DeleteLocalInt(oCreature, AI_AM_I_SEARCHING);
    DeleteLocalInt(oCreature, AI_TRIED_TO_HIDE);
    DeleteLocalObject(oCreature, AI_IS_INVISIBLE);
    DeleteLocalInt(oCreature, sLastActionVarname);
    DeleteLocalInt(oCreature, AI_TALENTS_SET);
    DeleteLocalInt(oCreature, AI_ROUND);
    DeleteLocalInt(oCreature, sIPHasHasteVarname);
    DeleteLocalInt(oCreature, sIPImmuneVarname);
    DeleteLocalInt(oCreature, sIPResistVarname);
    DeleteLocalInt(oCreature, sIPReducedVarname);
    ai_EndCombatRound(oCreature);
}
//******************************************************************************
//*************** GET TARGETS USING COMBAT STATE FUNCTIONS *********************
//******************************************************************************
// These functions will find a target based on the combat state variables created
// by the function ai_SetCombatState.

int ai_GetNearestCreatureIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "744", "Getting Nearest Creature Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)) +
        //         " bAlwaysAtk: " + IntToString(bAlwaysAtk));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
               !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(fTargetRange < fLowestDTargetRange)
                        {
                            fLowestDTargetRange = fTargetRange;
                            nDIndex = nCnt;
                        }
                    }
                    // Is closer.
                    else if(fTargetRange < fLowestTargetRange)
                    {
                        fLowestTargetRange = fTargetRange;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if(nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //ai_Debug("0i_combat", "781", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetNearestTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "787", "Checking for nearest target within " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "804", "Getting Lowest Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)) +
        //         " bAlwaysAtk: " + IntToString(bAlwaysAtk));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nLDCombat ||(nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nLDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has less combat or equal combat and is closer.
                    else if(nCombat < nLCombat ||(nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) nIndex = ai_GetLowestCRIndex(oCreature, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "849", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object  ai_GetLowestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "855", "Checking for lowest combat rated target in " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetLowestCRIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetHighestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "872", "Getting Highest Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                      (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nHDCombat ||(nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nHDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has greater combat or equal combat and is closer.
                    else if(nCombat > nHCombat ||(nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) nIndex = ai_GetHighestCRIndex(oCreature, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "917", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " HighestCombatRating: " + IntToString(nHCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetHighestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "923", "Checking for highest combat rated target in " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetHighestCRIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "940", "Getting Lowest Index for spell: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget))
            {
                nCombat = GetLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
                // Lets put any disabled targets in its own group, if we
                // ignore associates lets put them here as well.
                if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                  (bIngnoreAssociates && GetAssociateType(oTarget)))
                {
                    if(nCombat < nLDCombat ||(nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has the lowest combat or equal combat and is closer.
                else if(nCombat < nLCombat ||(nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if(GetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt) > AI_HEALTH_BLOODY)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor(oTarget);
                        //ai_Debug("0i_combat", "976", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                        //         "oAttacker: " + GetName(oAttacker));
                        // Is not being attacked by someone else then change.
                        if(oAttacker != OBJECT_SELF || !GetIsObjectValid(oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLCombat = nCombat;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if(nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //ai_Debug("0i_combat", "994", AI_ENEMY + " fRange: " + FloatToString(fRange, 0, 2) +
    //       " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
int ai_GetHighestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1009", "Getting Highest Index for Spell: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget))
            {
                nCombat = GetLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
                // Lets put any disabled targets in its own group, if we
                // ignore associates lets put them here as well.
                if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                  (bIngnoreAssociates && GetAssociateType(oTarget)))
                {
                    if(nCombat < nHDCombat ||(nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nHDCombat = nCombat;
                        nDIndex = nCnt;
                    }
                }
                // Has greater combat or equal combat and is closer.
                else if(nCombat > nHCombat ||(nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if(GetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt) > AI_HEALTH_BLOODY)
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor(oTarget);
                        //ai_Debug("0i_combat", "1045", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                        //         "oAttacker: " + GetName(oAttacker));
                        // Is not being attacked by someone else then change.
                        if(oAttacker != OBJECT_SELF || !GetIsObjectValid(oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nHCombat = nCombat;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a nondisabled target then use our best disabled target.
    if(nIndex == 0 && nDIndex != 0) nIndex = nDIndex;
    //ai_Debug("0i_combat", "1063", AI_ENEMY + " fRange: " + FloatToString(fRange, 0, 2) +
    //       " HighestCombatRating: " + IntToString(nHCombat) + " = " + IntToString(nIndex));
    return nIndex;
}
int ai_GetLowestMeleeIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    int nLMelee = 100, nInMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1076", "Getting Lowest Melee Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fTargetRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                 nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has lower melee or equal melee and is closer.
                if(nInMelee < nLMelee ||(nInMelee == nLMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nLMelee = nInMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    //ai_Debug("0i_combat", "1099", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " LowestMeleeTarget: " + IntToString(nLMelee) + " Index: " + IntToString(nIndex));
    return nIndex;
}
int ai_GetHighestMeleeIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    int nHMelee = -100, nInMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1112", "Getting Highest Melee Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) + " fRange: " +
        //         FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has greater melee or equal melee and is closer.
                if(nInMelee > nHMelee ||(nInMelee == nHMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHMelee = nInMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    //ai_Debug("0i_combat", "1135", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //       " HighestMeleeTarget: " + IntToString(nHMelee) + " Index: " + IntToString(nIndex));
    return nIndex;
}
int ai_GetMostWoundedIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nCnt = 1;
    int nIndex, nHp, nLHp = 200;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1149", "Getting Most Wounded Index: " + sCnt + " " +
        //         GetName(oTarget) +
        //         " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)) +
        //         " Health: " + IntToString(GetLocalInt(oCreature, sCreatureType + "_HEALTH" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nHp = GetLocalInt(oCreature, sCreatureType + "_HEALTH" + sCnt);
                    // Has lower health or equal health and is closer.
                    if(nHp < nLHp ||(nHp == nLHp && fTargetRange < fLowestTargetRange))
                    {
                        // If this creature has high enough health then change.
                        if(nHp > AI_HEALTH_BLOODY)
                        {
                            fLowestTargetRange = fTargetRange;
                            nLHp = nHp;
                            nIndex = nCnt;
                        }
                        else
                        {
                            object oAttacker = GetLastHostileActor(oTarget);
                            //ai_Debug("0i_combat", "1177", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                            //       " oAttacker: " + GetName(oAttacker));
                            // Is not being attacked by someone else then change.
                            if(oAttacker != oCreature || !GetIsObjectValid(oAttacker))
                            {
                                fLowestTargetRange = fTargetRange;
                                nLHp = nHp;
                                nIndex = nCnt;
                            }
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    //ai_Debug("0i_combat", "1194", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //       " GetMostWoundedTargetForDamage: " + IntToString(nLHp) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetMostWoundedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "1200", "Checking for most wounded target in " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetAllyToHealIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int bCheck, nCnt = 1;
    int nIndex, nHp, nLHp = 200;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ALLY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        //ai_Debug("0i_combat", "1252", "oCreature: " + GetName(oCreature) + " oTarget: " +
        //         GetName(oTarget) + " Self Heal: " + IntToString(!ai_GetAssociateMode(oCreature, AI_MODE_SELF_HEALING_OFF));
        if(oTarget != oCreature || !ai_GetAIMode(oCreature, AI_MODE_SELF_HEALING_OFF))
        {
            fTargetRange = GetLocalFloat(oCreature, AI_ALLY_RANGE + sCnt);
            //ai_Debug("0i_combat", "1263", "Getting Ally to Heal Index: " + sCnt + " " +
            //         GetName(oTarget) +
            //         " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
            //         " fRange: " + FloatToString(fRange, 0, 2) +
            //         " Health: " + IntToString(GetLocalInt(oCreature, AI_ALLY_HEALTH + sCnt)));
            if(fTargetRange <= fRange)
            {
                // We see and hear all allies and must be alive.
                if(!GetIsDead(oTarget))
                {
                    nHp = GetLocalInt(oCreature, AI_ALLY_HEALTH + sCnt);
                    // Has lower health or equal health and is closer.
                    if(nHp < nLHp ||(nHp == nLHp && fTargetRange < fLowestTargetRange))
                    {
                        // If this creature has high enough health then change.
                        if(nHp > AI_HEALTH_BLOODY)
                        {
                            fLowestTargetRange = fTargetRange;
                            nLHp = nHp;
                            nIndex = nCnt;
                        }
                        else
                        {
                            object oAttacker = GetLastHostileActor(oTarget);
                            //ai_Debug("0i_combat", "1270", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                            //       " oAttacker: " + GetName(oAttacker));
                            // Is not being attacked by someone else then change.
                            if(oAttacker != oCreature || !GetIsObjectValid(oAttacker))
                            {
                                fLowestTargetRange = fTargetRange;
                                nLHp = nHp;
                                nIndex = nCnt;
                            }
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ALLY + sCnt);
        bCheck = FALSE;
    }
    //ai_Debug("0i_combat", "1287", "fRange: " + FloatToString(fRange, 0, 2) +
    //       " GetAllyToHealTargetForDamage: " + IntToString(nLHp) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetAllyToHealTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    //ai_Debug("0i_combat", "1293", "Checking for ally to heal target in " +
    //         FloatToString(fRange, 0, 2));
    string sIndex = IntToString(ai_GetAllyToHealIndex(oCreature, fRange));
    return GetLocalObject(oCreature, AI_ALLY + sIndex);
}
object ai_GetLowestFortitudeSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nFortitude, nLDFortitude = 100, nLFortitude = 100;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1217", "Getting Lowest Fort Save: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget))
            {
                nFortitude = GetFortitudeSavingThrow(oTarget);
                // Lets put any disabled targets in its own group, if we
                // ignore associates lets put them here as well.
                if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                   (bIngnoreAssociates && GetAssociateType(oTarget)))
                {
                    if(nFortitude < nLDFortitude ||(nFortitude == nLDFortitude && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDFortitude = nFortitude;
                        nDIndex = nCnt;
                    }
                }
                // Has lower Fortitude or equal Fortitude and is closer.
                if(nFortitude < nLFortitude ||(nFortitude == nLFortitude && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if(GetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt) > AI_HEALTH_BLOODY)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLFortitude = nFortitude;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor(oTarget);
                        //ai_Debug("0i_combat", "1253", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                        //       " oAttacker: " + GetName(oAttacker));
                        // Is not being attacked by someone else then change.
                        if(oAttacker != oCreature || !GetIsObjectValid(oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLFortitude = nFortitude;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetLowestFortitudeSaveTarget(oCreature, AI_RANGE_PERCEPTION);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1276", "Fortitude: " + IntToString(nLFortitude) +
    //         " Disabled Fortitude: " + IntToString(nLDFortitude) + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
}
object ai_GetLowestReflexSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nReflex, nLDReflex = 100, nLReflex = 100;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1292", "Getting Lowest Refl Save: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget))
            {
                nReflex = GetReflexSavingThrow(oTarget);
                // Lets put any disabled targets in its own group, if we
                // ignore associates lets put them here as well.
                if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                   (bIngnoreAssociates && GetAssociateType(oTarget)))
                {
                    if(nReflex < nLDReflex ||(nReflex == nLDReflex && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDReflex = nReflex;
                        nDIndex = nCnt;
                    }
                }
                // Has lower Fortitude or equal Fortitude and is closer.
                if(nReflex < nLReflex ||(nReflex == nLReflex && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if(GetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt) > AI_HEALTH_BLOODY)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLReflex = nReflex;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor(oTarget);
                        //ai_Debug("0i_combat", "1328", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                        //        " oAttacker: " + GetName(oAttacker));
                        // Is not being attacked by someone else then change.
                        if(oAttacker != oCreature || !GetIsObjectValid(oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLReflex = nReflex;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetLowestFortitudeSaveTarget(oCreature, AI_RANGE_PERCEPTION);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1351", "Reflex: " + IntToString(nLReflex) +
    //         " Disabled Reflex: " + IntToString(nLDReflex) + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
}
object ai_GetLowestWillSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nWill, nLDWill = 100, nLWill = 100;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1367", "Getting Lowest Will Save: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget))
            {
                nWill = GetWillSavingThrow(oTarget);
                // Lets put any disabled targets in its own group, if we
                // ignore associates lets put them here as well.
                if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                   (bIngnoreAssociates && GetAssociateType(oTarget)))
                {
                    if(nWill < nLDWill ||(nWill == nLDWill && fTargetRange < fLowestDTargetRange))
                    {
                        fLowestDTargetRange = fTargetRange;
                        nLDWill = nWill;
                        nDIndex = nCnt;
                    }
                }
                // Has lower Will or equal Will and is closer.
                if(nWill < nLWill ||(nWill == nLWill && fTargetRange < fLowestTargetRange))
                {
                    // If this creature has high enough health then change.
                    if(GetLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt) > AI_HEALTH_BLOODY)
                    {
                        fLowestTargetRange = fTargetRange;
                        nLWill = nWill;
                        nIndex = nCnt;
                    }
                    else
                    {
                        object oAttacker = GetLastHostileActor(oTarget);
                        //ai_Debug("0i_combat", "1403", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                        //       " oAttacker: " + GetName(oAttacker));
                        // Is not being attacked by someone else then change.
                        if(oAttacker != oCreature || !GetIsObjectValid(oAttacker))
                        {
                            fLowestTargetRange = fTargetRange;
                            nLWill = nWill;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetLowestFortitudeSaveTarget(oCreature, AI_RANGE_PERCEPTION);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1426", "Will: " + IntToString(nLWill) +
    //         " Disabled Will: " + IntToString(nLDWill) + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
}
object ai_GetSpellTargetBasedOnSaves(object oCreature, int nSpell, float fRange = AI_RANGE_PERCEPTION)
{
    // Check the spells save type in "ai_spells.2da" and find the weakest
    // creature based on that save.
    string sSaveType = Get2DAString("ai_spells", "SaveType", nSpell);
    if(sSaveType == "Reflex") return ai_GetLowestReflexSaveTarget(oCreature, fRange);
    if(sSaveType == "Fortitude") return ai_GetLowestFortitudeSaveTarget(oCreature, fRange);
    if(sSaveType == "Will") return ai_GetLowestWillSaveTarget(oCreature, fRange);
    // If there is no save then lets see if we can find an enemy with the lowest health.
    return ai_GetMostWoundedTarget(oCreature, fRange);
}
int ai_GetNearestIndexThatSeesUs(object oCreature)
{
    int nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = AI_RANGE_PERCEPTION + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1451", "Getting Nearest Index that sees us: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " Sees us?: " + IntToString(GetObjectSeen(oCreature, oTarget)));
        if(GetObjectSeen(oCreature, oTarget))
        {
            if(fTargetRange < fLowestTargetRange)
            {
                fLowestTargetRange = fTargetRange;
                nIndex = nCnt;
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    //ai_Debug("0i_combat", "1465", "Nearest Enemy that sees us: nIndex: " + IntToString (nIndex));
    return nIndex;
}
int ai_GetBestSneakAttackIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oAttacking, oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        //ai_Debug("0i_combat", "1479", "Getting Sneak Attack Index: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            // Uncanny Dodge II gives immunity to sneak attack unless attacker
            // is 4 levels higher. We will assume they are always immune for simplicity.
            if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                !GetIsDead(oTarget) && !ai_IsImmuneToSneakAttacks(oCreature, oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    oAttacking = ai_GetAttackedTarget(oTarget);
                    //ai_Debug("0i_combat", "1492", "oTarget: " + GetName(oTarget) +
                    //         " is attacking " + GetName(oAttacking));
                    // They are attacking someone besides us or we are hidden?
                    if((oAttacking != OBJECT_INVALID && oAttacking != oCreature) ||
                       GetActionMode(oCreature, ACTION_MODE_STEALTH))
                    {
                        // Lets put any disabled targets in its own group, if we
                        // ignore associates lets put them here as well.
                        if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                           (bIngnoreAssociates && GetAssociateType(oTarget)))
                        {
                            if(fTargetRange < fLowestDTargetRange)
                            {
                                fLowestDTargetRange = fTargetRange;
                                nDIndex = nCnt;
                            }
                        }
                        // Is closer.
                        else if(fTargetRange < fLowestTargetRange)
                        {
                            fLowestTargetRange = fTargetRange;
                            nIndex = nCnt;
                        }
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see if
        // we can move around in combat.
        if (fRange == AI_RANGE_MELEE && ai_CanIMoveInCombat(oCreature))
        {
            nIndex = ai_GetBestSneakAttackIndex(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
        }
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1535", "Get attacking target (Index: " + IntToString(nIndex) + ")");
    return nIndex;
}
int ai_GetNearestIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1549", "Getting Nearest Index Not in AOE: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be in a dangerous AOE.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget) &&
                !ai_IsInADangerousAOE(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(fTargetRange < fLowestDTargetRange)
                        {
                            fLowestDTargetRange = fTargetRange;
                            nDIndex = nCnt;
                        }
                    }
                    // Is closer.
                    else if(fTargetRange < fLowestTargetRange)
                    {
                        fLowestTargetRange = fTargetRange;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) nIndex = ai_GetNearestIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1592", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetNearestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "1598", "Getting nearest target not in an AOE within " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetNearestIndexNotInAOE(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1615", "Getting Lowest Index Not in AOE: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget) &&
                !ai_IsInADangerousAOE(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nLDCombat ||(nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nLDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // has less combat or equal combat and is closer.
                    else if(nCombat < nLCombat ||(nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) nIndex = ai_GetLowestCRIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1661", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetLowestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "1667", "Getting lowest target not in an AOE within " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetLowestCRIndexNotInAOE(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetHighestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = 0, nHDCombat = 0, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1684", "Getting Highest Index Not in AOE: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget) &&
                !ai_IsInADangerousAOE(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat > nHDCombat ||(nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nHDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // has less combat or equal combat and is closer.
                    else if(nCombat > nHCombat ||(nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) nIndex = ai_GetHighestCRIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1730", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetHighestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    //ai_Debug("0i_combat", "1736", "Getting highest target not in an AOE within " +
    //         FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
    //         " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetNearestIndexNotInAOE(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetHighestMeleeIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    int nHMelee = -100, nInMelee, nIndex, nCnt = 1;
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1751", "Getting Highest Melee Index Not in AOE: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " +
        //         FloatToString(fTargetRange, 0, 2) + " fRange: " + FloatToString(fRange, 0, 2) +
        //         " Seen: " + IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget) &&
                !ai_IsInADangerousAOE(oTarget))
            {
                nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sCnt);
                // Has greater melee and equal melee and is closer.
                if(nInMelee > nHMelee ||(nInMelee == nHMelee && fTargetRange < fLowestTargetRange))
                {
                    fLowestTargetRange = fTargetRange;
                    nHMelee = nInMelee;
                    nIndex = nCnt;
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    //ai_Debug("0i_combat", "1775", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " HighestMeleeTarget: " + IntToString(nHMelee) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_CheckForGroupedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString(ai_GetHighestMeleeIndex(oCreature, fRange, sCreatureType));
    int nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sIndex);
    object oTarget = GetLocalObject(oCreature, sCreatureType + sIndex);
    //ai_Debug("0i_combat", "1787", "Getting Grouped Target: oTarget: " +
    //         GetName(oTarget) + " :" + IntToString(nInMelee));
    return oTarget;
}
object ai_CheckForGroupedTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString(ai_GetHighestMeleeIndexNotInAOE(oCreature, fRange, sCreatureType));
    int nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sIndex);
    object oTarget = GetLocalObject(oCreature, sCreatureType + sIndex);
    //ai_Debug("0i_combat", "1822", "Getting Group Target Not in AOE: oTarget: " +
    //         GetName(oTarget) + " :" + IntToString(nInMelee));
    return oTarget;
}
object ai_GetNearestClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1819", "Getting Nearest Class Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(fTargetRange < fLowestDTargetRange &&
                            ai_CheckClassType(oTarget, nClassType))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nDIndex = nCnt;
                        }
                    }
                    // Is closer.
                    else if(fTargetRange < fLowestTargetRange &&
                             ai_CheckClassType(oTarget, nClassType))
                    {
                        fLowestTargetRange = fTargetRange;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetNearestClassTarget(oCreature, nClassType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1863", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " Index: " + IntToString(nIndex));
    return GetLocalObject(OBJECT_SELF, sCreatureType + IntToString(nIndex));
}
object ai_GetLowestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1878", "Getting Lowest Class Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckClassType(oTarget, nClassType))
        {
            // We must be able to see them.
            if(GetLocalInt(OBJECT_SELF, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nLDCombat ||(nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nLDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has less combat or equal combat and is closer.
                    else if(nCombat < nLCombat ||(nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetLowestCRClassTarget(oCreature, nClassType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1923", "Class: " + IntToString(nClassType) +
    //         " CreatureType: " + sCreatureType + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetHighestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "1939", "Getting Highest Class Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckClassType(oTarget, nClassType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nHDCombat ||(nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nHDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has greater combat or equal combat and is closer.
                    else if(nCombat > nHCombat ||(nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetHighestCRClassTarget(oCreature, nClassType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "1984", "Class: " + IntToString(nClassType) +
    //         " CreatureType: " + sCreatureType + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetNearestRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "2000", "Getting Nearest Racial Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(fTargetRange < fLowestDTargetRange &&
                           ai_CheckRacialType(oTarget, nRacialType))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nDIndex = nCnt;
                        }
                    }
                    // Is closer.
                    else if(fTargetRange < fLowestTargetRange &&
                            ai_CheckRacialType(oTarget, nRacialType))
                    {
                        fLowestTargetRange = fTargetRange;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetNearestRacialTarget(oCreature, nRacialType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "2044", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
    //         " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetLowestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "2059", "Getting Lowest Racial Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckRacialType(oTarget, nRacialType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nLDCombat ||(nCombat == nLDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nLDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has less combat or equal combat and is closer.
                    else if(nCombat < nLCombat ||(nCombat == nLCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nLCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetLowestCRRacialTarget(oCreature, nRacialType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "2104", "Race: " + IntToString(nRacialType) +
    //         " CreatureType: " + sCreatureType + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetHighestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        //ai_Debug("0i_combat", "2120", "Getting Highest Racial Target: " + sCnt + " " +
        //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
        //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
        //         IntToString(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckRacialType(oTarget, nRacialType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_PERCEIVED" + sCnt) &&
                !GetIsDead(oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    nCombat = GetLocalInt(oCreature, sCreatureType + "_COMBAT" + sCnt);
                    // Lets put any disabled targets in its own group, if we
                    // ignore associates lets put them here as well.
                    if(GetLocalInt(oCreature, sCreatureType + "_DISABLED" + sCnt) ||
                       (bIngnoreAssociates && GetAssociateType(oTarget)))
                    {
                        if(nCombat < nHDCombat ||(nCombat == nHDCombat && fTargetRange < fLowestDTargetRange))
                        {
                            fLowestDTargetRange = fTargetRange;
                            nHDCombat = nCombat;
                            nDIndex = nCnt;
                        }
                    }
                    // Has greater combat or equal combat and is closer.
                    else if(nCombat > nHCombat ||(nCombat == nHCombat && fTargetRange < fLowestTargetRange))
                    {
                        fLowestTargetRange = fTargetRange;
                        nHCombat = nCombat;
                        nIndex = nCnt;
                    }
                }
            }
        }
        sCnt = IntToString(++nCnt);
        oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    }
    // If we do not have a good target then lets see if there are more targets.
    if(nIndex == 0 && nDIndex != 0)
    {
        // If we just checked within melee then lets check what we can see.
        if (fRange == AI_RANGE_MELEE) return ai_GetHighestCRRacialTarget(oCreature, nRacialType, AI_RANGE_PERCEPTION, sCreatureType, bAlwaysAtk);
        else nIndex = nDIndex;
    }
    //ai_Debug("0i_combat", "2165", "Race: " + IntToString(nRacialType) +
    //         " CreatureType: " + sCreatureType + " fRange: " +
    //         FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetNearestFavoredEnemyTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE)
{
    int nRace, nRacialType, nIndex, nDIndex, nCnt = 1;
    string sCnt;
    float fFinalTargetRange = fRange + 1.0, fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget, oFinalTarget;
    while(nRace < 24)
    {
        // Find which favored enemies we have.
        if(nRace < 1 && GetHasFeat(FEAT_FAVORED_ENEMY_ABERRATION, oCreature))
        {
            nRace = 1;
            nRacialType = RACIAL_TYPE_ABERRATION;
        }
        else if(nRace < 2 && GetHasFeat(FEAT_FAVORED_ENEMY_ANIMAL, oCreature))
        {
            nRace = 2;
            nRacialType = RACIAL_TYPE_ANIMAL;
        }
        else if(nRace < 3 && GetHasFeat(FEAT_FAVORED_ENEMY_BEAST, oCreature))
        {
            nRace = 3;
            nRacialType = RACIAL_TYPE_BEAST;
        }
        else if(nRace < 4 && GetHasFeat(FEAT_FAVORED_ENEMY_CONSTRUCT, oCreature))
        {
            nRace = 4;
            nRacialType = RACIAL_TYPE_CONSTRUCT;
        }
        else if(nRace < 5 && GetHasFeat(FEAT_FAVORED_ENEMY_DRAGON, oCreature))
        {
            nRace = 5;
            nRacialType = RACIAL_TYPE_DRAGON;
        }
        else if(nRace < 6 && GetHasFeat(FEAT_FAVORED_ENEMY_DWARF, oCreature))
        {
            nRace = 6;
            nRacialType = RACIAL_TYPE_DWARF;
        }
        else if(nRace < 7 && GetHasFeat(FEAT_FAVORED_ENEMY_ELEMENTAL, oCreature))
        {
            nRace = 7;
            nRacialType = RACIAL_TYPE_ELEMENTAL;
        }
        else if(nRace < 8 && GetHasFeat(FEAT_FAVORED_ENEMY_ELF, oCreature))
        {
            nRace = 8;
            nRacialType = RACIAL_TYPE_ELF;
        }
        else if(nRace < 9 && GetHasFeat(FEAT_FAVORED_ENEMY_FEY, oCreature))
        {
            nRace = 9;
            nRacialType = RACIAL_TYPE_FEY;
        }
        else if(nRace < 10 && GetHasFeat(FEAT_FAVORED_ENEMY_GIANT, oCreature))
        {
            nRace = 10;
            nRacialType = RACIAL_TYPE_GIANT;
        }
        else if(nRace < 11 && GetHasFeat(FEAT_FAVORED_ENEMY_GNOME, oCreature))
        {
            nRace = 11;
            nRacialType = RACIAL_TYPE_GNOME;
        }
        else if(nRace < 12 && GetHasFeat(FEAT_FAVORED_ENEMY_GOBLINOID, oCreature))
        {
            nRace = 12;
            nRacialType = RACIAL_TYPE_HUMANOID_GOBLINOID;
        }
        else if(nRace < 13 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFELF, oCreature))
        {
            nRace = 13;
            nRacialType = RACIAL_TYPE_HALFELF;
        }
        else if(nRace < 14 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFLING, oCreature))
        {
            nRace = 14;
            nRacialType = RACIAL_TYPE_HALFLING;
        }
        else if(nRace < 15 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFORC, oCreature))
        {
            nRace = 15;
            nRacialType = RACIAL_TYPE_HALFORC;
        }
        else if(nRace < 16 && GetHasFeat(FEAT_FAVORED_ENEMY_HUMAN, oCreature))
        {
            nRace = 16;
            nRacialType = RACIAL_TYPE_HUMAN;
        }
        else if(nRace < 17 && GetHasFeat(FEAT_FAVORED_ENEMY_MAGICAL_BEAST, oCreature))
        {
            nRace = 17;
            nRacialType = RACIAL_TYPE_MAGICAL_BEAST;
        }
        else if(nRace < 18 && GetHasFeat(FEAT_FAVORED_ENEMY_MONSTROUS, oCreature))
        {
            nRace = 18;
            nRacialType = RACIAL_TYPE_HUMANOID_MONSTROUS;
        }
        else if(nRace < 19 && GetHasFeat(FEAT_FAVORED_ENEMY_ORC, oCreature))
        {
            nRace = 19;
            nRacialType = RACIAL_TYPE_HUMANOID_ORC;
        }
        else if(nRace < 20 && GetHasFeat(FEAT_FAVORED_ENEMY_OUTSIDER, oCreature))
        {
            nRace = 20;
            nRacialType = RACIAL_TYPE_OUTSIDER;
        }
        else if(nRace < 21 && GetHasFeat(FEAT_FAVORED_ENEMY_REPTILIAN, oCreature))
        {
            nRace = 21;
            nRacialType = RACIAL_TYPE_HUMANOID_REPTILIAN;
        }
        else if(nRace < 22 && GetHasFeat(FEAT_FAVORED_ENEMY_SHAPECHANGER, oCreature))
        {
            nRace = 22;
            nRacialType = RACIAL_TYPE_SHAPECHANGER;
        }
        else if(nRace < 23 && GetHasFeat(FEAT_FAVORED_ENEMY_UNDEAD, oCreature))
        {
            nRace = 23;
            nRacialType = RACIAL_TYPE_UNDEAD;
        }
        else if(nRace < 24 && GetHasFeat(FEAT_FAVORED_ENEMY_VERMIN, oCreature))
        {
            nRace = 24;
            nRacialType = RACIAL_TYPE_VERMIN;
        }
        else nRace = 25;
        if(nRace < 25)
        {
            // Now find the creature of the race we have.
            int bIngnoreAssociates = ai_GetAIMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
            sCnt = "1";
            fLowestTargetRange = fRange + 1.0;
            fLowestDTargetRange = fRange + 1.0;
            oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
            while(oTarget != OBJECT_INVALID)
            {
                fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
                //ai_Debug("0i_combat", "2310", "Getting Nearest Favored Enemy: " + sCnt + " " +
                //         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                //         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                //         IntToString(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt)));
                if(fTargetRange <= fRange)
                {
                    // We must be able to see them.
                    if(GetLocalInt(oCreature, AI_ENEMY_PERCEIVED + sCnt) &&
                        !GetIsDead(oTarget))
                    {
                        if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                        {
                            // Lets put any disabled targets in its own group, if we
                            // ignore associates lets put them here as well.
                            if(GetLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt) ||
                               (bIngnoreAssociates && GetAssociateType(oTarget)))
                            {
                                if(fTargetRange < fLowestDTargetRange &&
                                   ai_CheckRacialType(oTarget, nRacialType))
                                {
                                    fLowestDTargetRange = fTargetRange;
                                    nDIndex = nCnt;
                                }
                            }
                            // Is closer.
                            else if(fTargetRange < fLowestTargetRange &&
                                    ai_CheckRacialType(oTarget, nRacialType))
                            {
                                fLowestTargetRange = fTargetRange;
                                nIndex = nCnt;
                            }
                        }
                    }
                }
                sCnt = IntToString(++nCnt);
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
            }
            // If we do not have a good target then lets see if there are more targets.
            if(nIndex == 0 && nDIndex != 0)
            {
                // If we just checked within melee then lets check what we can see.
                if (fRange == AI_RANGE_MELEE) oFinalTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
                else if(fLowestDTargetRange < fFinalTargetRange)
                {
                    oFinalTarget = GetLocalObject(oCreature, AI_ENEMY + IntToString(nDIndex));
                    fFinalTargetRange = fLowestDTargetRange;
                }
            }
            else if(fLowestTargetRange < fFinalTargetRange)
            {
                oFinalTarget = GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
                fFinalTargetRange = fLowestTargetRange;
            }
        }
    }
    //ai_Debug("0i_combat", "2357", "Finding favored enemy oFinalTarget: " + GetName(oFinalTarget) + " fRange: " +
    //        FloatToString(fRange, 0, 2) + " nIndex: " + IntToString(nIndex));
    return oFinalTarget;
}
object ai_GetNearestTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if(nInMelee > 0) sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, AI_RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the nearest enemy.
        sIndex = IntToString(ai_GetNearestIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        // If we didn't get a target then get any target within range.
        if(sIndex == "0")
        {
            sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        }
    }
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    // We might not have a target this is fine as sometimes we don't want to attack!
    //ai_Debug("0i_combat", "2379", GetName(oTarget) + " is the nearest target for melee combat!");
    return oTarget;
}
object ai_GetLowestCRTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if(nInMelee > 0) sIndex = IntToString(ai_GetLowestCRIndex(oCreature, AI_RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the weakest combat rated enemy.
        sIndex = IntToString(ai_GetLowestCRIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        /* Lets stay out of bad AOE's.
        // If we didn't get a target then get any target within range.
        if(sIndex == "0")
        {
            sIndex = IntToString(ai_GetLowestCRIndex(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        } */
    }
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    // We might not have a target this is fine as sometimes we don't want to attack!
    //ai_Debug("0i_combat", "2400", GetName(oTarget) + " is the weakest target for melee combat!");
    return oTarget;
}
object ai_GetHighestCRTargetForMeleeCombat(object oCreature, int nInMelee)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if(nInMelee > 0) sIndex = IntToString(ai_GetHighestCRIndex(oCreature, AI_RANGE_MELEE));
    // If not then lets go find someone to attack!
    else
    {
        // Get the weakest combat rated enemy.
        sIndex = IntToString(ai_GetHighestCRIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION));
        /* Lets stay out of bad AOE's.
        // If we didn't get a target then get any target within range.
        if(sIndex == "0") sIndex = IntToString(ai_GetHighestCRIndex(oCreature, AI_RANGE_PERCEPTION));
        */
    }
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    // We might not have a target this is fine as sometimes we don't want to attack!
    //ai_Debug("0i_combat", "2418", GetName(oTarget) + " is the strongest target for melee combat!");
    return oTarget;
}
object ai_GetEnemyAttackingMe(object oCreature, float fRange = AI_RANGE_MELEE)
{
    int nCtr = 1;
    float fDistance;
    string sCtr = "1";
    object oAttacked;
    object oEnemy = GetLocalObject(oCreature, AI_ENEMY + "1");
    while(oEnemy != OBJECT_INVALID)
    {
        if(!ai_Disabled(oEnemy))
        {
            fDistance = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCtr);
            //ai_Debug("0i_combat", "2462", "Getting Enemy Attacking Me: " + sCtr + " " +
            //                 GetName(oEnemy) + " fTargetRange: " + FloatToString(fDistance, 0, 2) +
            //                 " fRange: " + FloatToString(fRange, 0, 2) + " Attacking: " +
            //                 GetName(ai_GetAttackedTarget(oEnemy)));
            if(fDistance <= fRange)
            {
                oAttacked = ai_GetAttackedTarget(oEnemy);
                // If an enemy isn't attacking someone we must assume we are next!
                if(oAttacked == oCreature || oAttacked == OBJECT_INVALID)
                {
                    //ai_Debug("0i_combat", "2441", "Enemy attacking me: " + GetName(oEnemy) + " has attacked: " + GetName(ai_GetAttackedTarget(oEnemy)));
                    return oEnemy;
                }
            }
        }
        sCtr = IntToString(++nCtr);
        oEnemy = GetLocalObject(oCreature, AI_ENEMY + sCtr);
    }
    return OBJECT_INVALID;
}
int ai_GetNumOfEnemiesInRange(object oCreature, float fRange = AI_RANGE_MELEE)
{
    int nNumOfEnemies, nCnt = 1;
    float fDistance = GetLocalFloat(oCreature, AI_ENEMY_RANGE + "1");
    while(fDistance != 0.0)
    {
        if(fDistance < fRange) nNumOfEnemies ++;
        fDistance = GetLocalFloat(oCreature, AI_ENEMY_RANGE + IntToString(++nCnt));
    }
    //ai_Debug("0i_combat", "2459", IntToString (nNumOfEnemies) + " enemies within " + FloatToString(fRange, 0, 2) + " meters.");
    return nNumOfEnemies;
}
object ai_GetAllyBuffTarget(object oCreature, int nSpell, float fRange = AI_RANGE_BATTLEFIELD)
{
    // Make sure we don't over extend our movement running across the
    // battlefield to cast a spell on someone does not look good.
    float fNearestEnemy = GetDistanceBetween(oCreature, GetLocalObject(oCreature, AI_ENEMY_NEAREST)) - 3.0f;
    // If we are in melee then extend to melee incase an ally is just past the enemy.
    if(fNearestEnemy <= AI_RANGE_MELEE) fNearestEnemy = AI_RANGE_MELEE;
    if(fRange > fNearestEnemy) fRange = fNearestEnemy;
    // Now lets get the best target based on the spell data in ai_spells.2da
    string sBuffTarget = Get2DAString("ai_spells", "Buff_Target", nSpell);
    //ai_Debug("0i_combat", "2596", "sBuffTarget: " + sBuffTarget + " fRange: " + FloatToString(fRange, 0, 2));
    if(sBuffTarget == "0") return oCreature;
    if(sBuffTarget == "1")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_STRENGTH, "", fRange, AI_ALLY);
    else if(sBuffTarget == "2")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_DEXTERITY, "", fRange, AI_ALLY);
    else if(sBuffTarget == "3")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_CONSTITUTION, "", fRange, AI_ALLY);
    else if(sBuffTarget == "4")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_INTELLIGENCE, "", fRange, AI_ALLY);
    else if(sBuffTarget == "5")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_WISDOM, "", fRange, AI_ALLY);
    else if(sBuffTarget == "6")
        return ai_BuffHighestAbilityScoreTarget(oCreature, nSpell, ABILITY_CHARISMA, "", fRange, AI_ALLY);
    else if(sBuffTarget == "7")
        return ai_BuffLowestACTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "8")
        return ai_BuffLowestACWithOutACBonus(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "9")
        return ai_BuffHighestAttackTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "10")
        return ai_BuffMostWoundedTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "11")
        return ai_BuffLowestFortitudeSaveTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "12")
        return ai_BuffLowestReflexSaveTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "13")
        return ai_BuffLowestWillSaveTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    else if(sBuffTarget == "14")
        return ai_BuffLowestSaveTarget(oCreature, nSpell, "", fRange, AI_ALLY);
    return OBJECT_INVALID;
}

//******************************************************************************
//********************  OTHER COMBAT FUNCTIONS  ********************************
//******************************************************************************

int ai_GetCurrentRound(object oCreature)
{
    int nRound = GetLocalInt(oCreature, AI_ROUND) + 1;
    SetLocalInt(oCreature, AI_ROUND, nRound);
    //ai_Debug("0i_combat", "2471", "nRound: " + IntToString(nRound));
    return nRound;
}
int ai_GetDifficulty(object oCreature)
{
    int nAdjustment = GetLocalInt(oCreature, AI_DIFFICULTY_ADJUSTMENT);
    int nDifficulty = GetLocalInt(oCreature, AI_ENEMY_POWER) - GetLocalInt(oCreature, AI_ALLY_POWER) + 13 + nAdjustment;
    if(nDifficulty < 1) nDifficulty = 1;
    //ai_Debug("0i_combat", "2474", "(Difficulty: Enemy Power: " + IntToString(GetLocalInt(oCreature, AI_ENEMY_POWER)) +
    //         " - Ally Power: " + IntToString(GetLocalInt(oCreature, AI_ALLY_POWER)) +
    //         ") + nRoll: 10 + nAdj: " + IntToString(nAdjustment) +
    //         " = " + IntToString(nDifficulty));
    return nDifficulty;
}
int ai_GetMyCombatRating(object oCreature)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    int nAtkBonus = GetBaseAttackBonus(oCreature);
    if(GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) && ai_GetIsFinesseWeapon(oWeapon))
    {
        nAtkBonus += GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    }
    else nAtkBonus += GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    if(ai_GetIsMeleeWeapon(oWeapon)) nAtkBonus += ai_GetWeaponAtkBonus(oWeapon);
    //ai_Debug("0i_combat", "2496", "GetMyCombatRating (nAtkBonus: " + IntToString(nAtkBonus) +
    //         " nAC: " + IntToString(GetAC(oCreature)) + " - 10) / 2 = " +
    //         IntToString((nAtkBonus + GetAC(oCreature) - 10) / 2));
    return(nAtkBonus + GetAC(oCreature) - 10) / 2;
}
object ai_GetAttackedTarget(object oCreature, int bPhysical = TRUE, int bSpell = FALSE)
{
    object oTarget = GetAttackTarget(oCreature);
    if(!GetIsObjectValid(oTarget) && bPhysical) oTarget = GetLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
    if(!GetIsObjectValid(oTarget) && bSpell) oTarget = GetLocalObject(oCreature, AI_ATTACKED_SPELL);
    if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget)) return OBJECT_INVALID;
    return oTarget;
}
int ai_CheckClassType(object oTarget, int nClassType)
{
    int nCnt = 1, nClass = GetClassByPosition(1, oTarget);
    // We check for the group class types.
    if(nClassType < 0)
    {
        while(nCnt <= AI_MAX_CLASSES_PER_CHARACTER)
        {
            int nCaster = StringToInt(Get2DAString("classes", "SpellCaster", nClass));
            if(nClassType == AI_CLASS_TYPE_WARRIOR && !nCaster) return TRUE;
            else if(nClassType == AI_CLASS_TYPE_CASTER && nCaster) return TRUE;
            int nSpellType = StringToInt(Get2DAString("classes", "Arcane", nClass));
            if(nClassType == AI_CLASS_TYPE_ARCANE && nSpellType) return TRUE;
            else if(nClassType == AI_CLASS_TYPE_DIVINE && !nSpellType) return TRUE;
            nClass = GetClassByPosition(++nCnt, oTarget);
        }
    }
    // Checks for normal classes.
    else
    {
        while(nCnt <= AI_MAX_CLASSES_PER_CHARACTER)
        {
            if(nClass == nClassType) return TRUE;
            nClass = GetClassByPosition(++nCnt, oTarget);
        }
    }
    return FALSE;
}
int ai_CheckRacialType(object oTarget, int nRacialType)
{
    int nRace = GetRacialType(oTarget);
    if(nRacialType == nRace) return TRUE;
    else if(nRacialType == AI_RACIAL_TYPE_ANIMAL_BEAST)
    {
        if(nRace == RACIAL_TYPE_ANIMAL ||
           nRace == RACIAL_TYPE_BEAST ||
           nRace == RACIAL_TYPE_MAGICAL_BEAST) return TRUE;
    }
    else if(nRacialType == AI_RACIAL_TYPE_HUMANOID)
    {
        switch (nRace)
        {
            case RACIAL_TYPE_DWARF :
            case RACIAL_TYPE_ELF :
            case RACIAL_TYPE_GNOME :
            case RACIAL_TYPE_HALFELF :
            case RACIAL_TYPE_HALFLING :
            case RACIAL_TYPE_HALFORC :
            case RACIAL_TYPE_HUMAN :
            case RACIAL_TYPE_HUMANOID_GOBLINOID :
            case RACIAL_TYPE_HUMANOID_MONSTROUS :
            case RACIAL_TYPE_HUMANOID_ORC :
            case RACIAL_TYPE_HUMANOID_REPTILIAN :
                return TRUE;
       }
    }
    return FALSE;
}
void ai_SetNormalAppearance(object oCreature)
{
    if(!ai_GetHasEffectType(oCreature, EFFECT_TYPE_POLYMORPH))
    {
        int nForm = GetAppearanceType(oCreature);
        //ai_Debug("0i_combat", "2729", GetName(oCreature) + " form: " + IntToString(nForm));
        SetLocalInt(oCreature, AI_NORMAL_FORM, nForm + 1);
    }
}
int ai_GetNormalAppearance(object oCreature)
{
    int nForm = GetLocalInt(oCreature, AI_NORMAL_FORM) - 1;
    if(nForm == -1)
    {
        ai_SetNormalAppearance(oCreature);
        nForm = GetLocalInt(oCreature, AI_NORMAL_FORM) - 1;
    }
    return nForm;
}
struct stClasses ai_GetFactionsClasses(object oCreature, int bEnemy = TRUE, float fRange = AI_RANGE_BATTLEFIELD)
{
    struct stClasses sCount;
    int nCnt = 1, nPosition, nClass, nLevels;
    object oTarget;
    if(bEnemy) oTarget = ai_GetNearestEnemy(oCreature, 1, 7, 7);
    else oTarget = ai_GetNearestAlly(oCreature, 1, 7, 7);
    while(oTarget != OBJECT_INVALID && GetDistanceBetween(oTarget, oCreature) <= fRange)
    {
        for(nPosition = 1; nPosition <= AI_MAX_CLASSES_PER_CHARACTER; nPosition++)
        {
            nClass = GetClassByPosition(nPosition, oTarget);
            nLevels = GetLevelByPosition(nPosition, oTarget);
            if(nClass == CLASS_TYPE_ANIMAL ||
               nClass == CLASS_TYPE_BARBARIAN ||
               nClass == CLASS_TYPE_COMMONER ||
               nClass == CLASS_TYPE_CONSTRUCT ||
               nClass == CLASS_TYPE_ELEMENTAL ||
               nClass == CLASS_TYPE_FIGHTER ||
               nClass == CLASS_TYPE_GIANT ||
               nClass == CLASS_TYPE_HUMANOID ||
               nClass == CLASS_TYPE_MONSTROUS ||
               nClass == CLASS_TYPE_PALADIN ||
               nClass == CLASS_TYPE_RANGER ||
               nClass == CLASS_TYPE_ROGUE ||
               nClass == CLASS_TYPE_VERMIN ||
               nClass == CLASS_TYPE_MONK ||
               nClass == CLASS_TYPE_SHAPECHANGER)
            {
                sCount.FIGHTERS += 1;
                sCount.FIGHTER_LEVELS += nLevels;
            }
            else if(nClass == CLASS_TYPE_CLERIC ||
                    nClass == CLASS_TYPE_DRUID)
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
               sCount.MONSTER_LEVELS += nLevels;
            }
            sCount.TOTAL_LEVELS += nLevels;
        }
        sCount.TOTAL += 1;
        if(bEnemy) oTarget = ai_GetNearestEnemy(oCreature, ++nCnt, 7, 7);
        else oTarget = ai_GetNearestAlly(oCreature, ++nCnt, 7, 7);
    }
    //ai_Debug("0i_combat", "2627", "Enemy: " + IntToString(bEnemy) + " fRange: " + FloatToString(fRange, 0, 2) +
    //          " CLERICS: " + IntToString(sCount.CLERICS) + "(" + IntToString(sCount.CLERIC_LEVELS) +
    //          ") FIGHTERS: " +IntToString(sCount.FIGHTERS) + "(" + IntToString(sCount.FIGHTER_LEVELS) +
    //          ") MAGES: " +IntToString(sCount.MAGES) + "(" + IntToString(sCount.MAGE_LEVELS) +
    //          ") MONSTERS: " +IntToString(sCount.MONSTERS) + "(" + IntToString(sCount.MONSTER_LEVELS) +
    //          ") TOTALS: " +IntToString(sCount.TOTAL) + "(" + IntToString(sCount.TOTAL_LEVELS));
    return sCount;
}
string ai_GetMostDangerousClass(struct stClasses stCount)
{
    string sClass;
    // Lets weight the fighter levels 30% higher.
    int nFighter =((stCount.FIGHTER_LEVELS) * 13)/10;
    if(nFighter >= stCount.CLERIC_LEVELS)
    {
        if(nFighter >= stCount.MAGE_LEVELS)
        {
            if(nFighter >= stCount.MONSTER_LEVELS) return "FIGHTER";
            else return "MONSTER";
        }
        else if(stCount.MAGE_LEVELS >= stCount.MONSTER_LEVELS) return "MAGE";
        else return "MONSTER";
    }
    else if(stCount.CLERIC_LEVELS >= stCount.MAGE_LEVELS)
    {
        if(stCount.CLERIC_LEVELS >= stCount.MONSTER_LEVELS) return "CLERIC";
        else return "MONSTER";
    }
    else if(stCount.MAGE_LEVELS >= stCount.MONSTER_LEVELS) return "MAGE";
    else return "MONSTER";
    return "";
}
void ai_EquipBestWeapons(object oCreature, object oTarget = OBJECT_INVALID)
{
    // Lets not check for weapons on creatures that can't use them!
    int nRacialType = GetRacialType(oCreature);
    if(nRacialType == RACIAL_TYPE_ANIMAL ||
        nRacialType == RACIAL_TYPE_DRAGON ||
        nRacialType == RACIAL_TYPE_MAGICAL_BEAST ||
        nRacialType == RACIAL_TYPE_OOZE ||
        nRacialType == RACIAL_TYPE_VERMIN) return;
    //if(Polymorphed()) return;
    //ai_Debug("0i_combat", "2669", GetName(OBJECT_SELF) + " is equiping best weapon!");
    // Determine if I am wielding a ranged weapon, melee weapon, or none.
    int bIsWieldingRanged = ai_HasRangedWeaponWithAmmo(oCreature);
    int bIsWieldingMelee = ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
    //ai_Debug("0i_combat", "2673", "bIsWieldingRanged: " + IntToString(bIsWieldingRanged) +
    //         " bIsWieldingMelee: " + IntToString(bIsWieldingMelee));
    // If we are invisible then change to a melee weapon so we can move in to attack.
    if(ai_GetIsInvisible(oCreature))
    {
        // Equip a melee weapon unless we already have one.
        if(!bIsWieldingMelee) ai_EquipBestMeleeWeapon(oCreature, oTarget);
        return;
    }
    // Equip the appropriate weapon for the distance of the enemy.
    int nEnemyGroup = ai_GetNumOfEnemiesInGroup(oCreature);
    //ai_Debug("0i_combat", "2684", GetName(oCreature) + " has " + IntToString(nEnemyGroup) + " enemies within 5.0f them! PointBlank: " +
    //         IntToString(GetHasFeat(FEAT_POINT_BLANK_SHOT, oCreature)));
    // We are in melee combat.
    if(nEnemyGroup > 0)
    {
        if(bIsWieldingRanged)
        {
            // We have the point blank shot feat or there are more than one enemy on us.
            // Note: Point Blank shot feat is bad once we have more than one enemy on us.
            if(!GetHasFeat(FEAT_POINT_BLANK_SHOT, oCreature) || nEnemyGroup > 1)
            {
                // If I'm not using a melee weapon.
                if(!bIsWieldingMelee)
                {
                    ai_EquipBestMeleeWeapon(oCreature);
                    //ai_Debug("0i_combat", "2699", GetName(oCreature) + " is equiping melee weapon due to close enemies!");
                }
            }
        }
    }
    // We are not in melee range.
    else
    {
        //ai_Debug("0i_combat", "2707", GetName(oCreature) + " is not in melee combat with an enemy!");
        // If are at range with the enemy then equip a ranged weapon.
        if(!bIsWieldingRanged)
        {
            ai_EquipBestRangedWeapon(oTarget);
            // Make sure that they equiped a range weapon.
            bIsWieldingRanged = ai_HasRangedWeaponWithAmmo(oCreature);
            bIsWieldingMelee = ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature));
            //ai_Debug("0i_combat", "2719", GetName(oCreature) + " is attempting to equip a ranged weapon: " + IntToString(bIsWieldingRanged));
            // If we equiped a ranged weapon then drop out.
        }
    }
    // We don't have a weapon out so equip one! We are in combat!
    if(!bIsWieldingRanged && !bIsWieldingMelee) ai_EquipBestMeleeWeapon(OBJECT_INVALID);
}
int ai_EquipBestMeleeWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    //ai_Debug("0i_combat", "2724", GetName(OBJECT_SELF) + " is equiping best melee weapon!");
    int nValue, nRightValue, nLeftValue, n2HandValue, nShieldValue;
    int nMaxItemValue = ai_GetMaxItemValueThatCanBeEquiped(GetHitDice(oCreature));
    int nCreatureSize = GetCreatureSize(oCreature);
    object oTwoHand = OBJECT_INVALID;
    object oShield = OBJECT_INVALID;
    object oRight = OBJECT_INVALID;
    object oLeft = OBJECT_INVALID;
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if(oRightHand != OBJECT_INVALID)
    {
        // Setup the item in our right hand as our base gold value to check against.
        if(ai_GetIsTwoHandedWeapon(oRightHand, oCreature)) n2HandValue = GetGoldPieceValue(oRightHand);
        else if(ai_GetIsSingleHandedWeapon(oRightHand, oCreature)) nRightValue = GetGoldPieceValue(oRightHand);
    }
    object oLeftHand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    if(oLeftHand != OBJECT_INVALID)
    {
        // Setup the item in our left hand as our base gold vlue to check against.
        if(ai_GetIsShield(oLeftHand)) nShieldValue = GetGoldPieceValue(oLeftHand);
        else if(ai_GetIsSingleHandedWeapon(oLeftHand, oCreature)) nLeftValue = GetGoldPieceValue(oLeftHand);
    }
    // Get the best weapons they have in their inventory.
    object oItem = GetFirstItemInInventory(oCreature);
    // If they don't have any items then lets stop, we can't equip a weapon.
    if(oItem == OBJECT_INVALID) return FALSE;
    while(oItem != OBJECT_INVALID)
    {
        nValue = GetGoldPieceValue(oItem);
        // Non-Identified items have a goldpiecevalue of 1. So they will not be selected.
        if(nValue > 1 && ai_GetIsProficientWith(oCreature, oItem) &&
           StringToInt(Get2DAString("baseitems", "WeaponSize", GetBaseItemType(oItem))) <= nCreatureSize &&
           (!GetLocalInt(GetModule(), AI_RULE_ILR) || nMaxItemValue >= nValue))
        {
            // Is it a single handed weapon?
            if(ai_GetIsSingleHandedWeapon(oItem, oCreature))
            {
                // Replace the lowest value right or left weapon.
                if(nValue > nRightValue && nValue > nLeftValue)
                {
                    if(nRightValue > nLeftValue) { oLeft = oItem; nLeftValue = nValue; }
                    else { oRight = oItem; nRightValue = nValue; }
                }
                else if(nValue > nRightValue) { oRight = oItem; nRightValue = nValue; }
                else if(nValue > nLeftValue) { oLeft = oItem; nLeftValue = nValue; }
            }
            else if(ai_GetIsTwoHandedWeapon(oItem, oCreature))
            {
                if(nValue > n2HandValue) { oTwoHand = oItem; n2HandValue = nValue; }
            }
            else if(ai_GetIsShield(oItem))
            {
                if(nValue > nShieldValue) { oShield = oItem; nShieldValue = nValue; }
            }
        }
        oItem = GetNextItemInInventory();
    }
    // Lets check to equip two weapons first.
    if(oLeft != OBJECT_INVALID &&
      (GetHasFeat(374/*FEAT_DUAL_WIELD*/, oCreature) || GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oCreature)))
    {
        //ai_Debug("0i_combat", "2783", GetName(oCreature) + " is equiping " +
        //         GetName(oRight) + " in the right hand. " +
        //         GetName(oLeft) + " in the left hand.");
        ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
        ActionEquipItem(oLeft, INVENTORY_SLOT_LEFTHAND);
        return TRUE;
    }
    // Check to see if they should use a two handed weapon.
    // If they have a two handed weapon and a strength bonus of +2 or more then use that.
    // Also use if they don't have a smaller weapon.
    else if(oTwoHand != OBJECT_INVALID &&
           (GetAbilityModifier(ABILITY_STRENGTH, oCreature) > 1 || oRight == OBJECT_INVALID))
    {
        //ai_Debug("0i_combat", "2796", GetName(oCreature) + " is equiping " +
        //         GetName(oTwoHand) + " in both hands. ");
        ActionEquipItem(oTwoHand, INVENTORY_SLOT_RIGHTHAND);
        return TRUE;
    }
    // Lets equip a weapon and a shield.
    else if(oRight != OBJECT_INVALID && oShield != OBJECT_INVALID && GetHasFeat(FEAT_SHIELD_PROFICIENCY, oCreature))
    {
        //ai_Debug("0i_combat", "2804", GetName(oCreature) + " is equiping " +
        //         GetName(oRight) + " in the right hand. " +
        //         GetName(oShield) + " in the left hand.");
        ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
        ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND);
        return TRUE;
    }
    // Finally lets just equip a weapon since we must not have a shield.
    else if(oRight == OBJECT_INVALID)
    {
        //ai_Debug("0i_combat", "2814", GetName(oCreature) + " did not equip a melee weapon");
        // We couldn't find a melee weapon but we are looking to go into melee
        // I'm holding a ranged weapon! Put it up.
        if(GetWeaponRanged(oLeftHand))
        {
            //ai_Debug("0i_combat", "2819", GetName(oCreature) + " is unequiping " + GetName(oLeftHand));
            ActionUnequipItem(oLeftHand);
            return TRUE;
        }
        return FALSE;
    }
    //ai_Debug("0i_combat", "2817", GetName(oCreature) + " is equiping " +
    //         GetName(oRight) + " in the right hand.");
    ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_EquipBestRangedWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    //ai_Debug("0i_combat", "2824", GetName(oCreature) + " is looking for best ranged weapon!");
    int nAmmo, nAmmoSlot, nBestType1, nBestType2, nType, nFeat, nValue, nRangedValue;
    int nMaxItemValue = ai_GetMaxItemValueThatCanBeEquiped(GetHitDice(oCreature));
    string sAmmo;
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if(oRightHand != OBJECT_INVALID)
    {
        // Setup the item in our right hand as our base gold value to check against.
        if(ai_GetIsRangeWeapon(oRightHand)) nRangedValue = GetGoldPieceValue(oRightHand);
    }
    object oRanged = OBJECT_INVALID, oAmmo = OBJECT_INVALID;
    // Find the best type of ranged weapon for this player.
    if(GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW, oCreature))
    { nBestType1 = BASE_ITEM_LONGBOW; nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow";}
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW, oCreature))
    { nBestType1 = BASE_ITEM_SHORTBOW; nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow";}
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW, oCreature))
    { nBestType1 = BASE_ITEM_HEAVYCROSSBOW; nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt";}
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW, oCreature))
    { nBestType1 = BASE_ITEM_LIGHTCROSSBOW; nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt";}
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_SLING, oCreature))
    { nBestType1 = BASE_ITEM_SLING; nAmmo = BASE_ITEM_BULLET; nAmmoSlot = INVENTORY_SLOT_BULLETS; sAmmo = "bullet";}
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_DART, oCreature))
    { nBestType1 = BASE_ITEM_DART; }
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN, oCreature))
    { nBestType1 = BASE_ITEM_SHURIKEN; }
    else if(GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE, oCreature))
    { nBestType1 = BASE_ITEM_THROWINGAXE; }
    // These feats require a bow.
    else if(GetHasFeat(FEAT_RAPID_SHOT, oCreature))
    { nBestType1 = BASE_ITEM_LONGBOW; nBestType2 = BASE_ITEM_SHORTBOW;
      nAmmo = BASE_ITEM_ARROW; nAmmoSlot = INVENTORY_SLOT_ARROWS; sAmmo = "arrow"; }
    // This feat requires a xbow.
    else if(GetHasFeat(FEAT_RAPID_RELOAD, oCreature))
    { nBestType1 = BASE_ITEM_HEAVYCROSSBOW; nBestType2 = BASE_ITEM_LIGHTCROSSBOW;
      nAmmo = BASE_ITEM_BOLT; nAmmoSlot = INVENTORY_SLOT_BOLTS; sAmmo = "bolt"; }
    //ai_Debug("0i_combat", "2860", "nBestType1: " + IntToString(nBestType1) + " nBestType2: " + IntToString(nBestType2) +
    //       " nAmmo: " + IntToString(nAmmo));
    // Cycle through the inventory looking for a ranged weapon.
    object oItem = GetFirstItemInInventory(oCreature);
    int nCreatureSize = GetCreatureSize(oCreature) + 1;
    while(oItem != OBJECT_INVALID)
    {
        nType = GetBaseItemType(oItem);
        // Make sure this is a ranged weapon.
        //ai_Debug("0i_combat", "2868", "oItem: " + GetName(oItem) + " Ranged Weapon: " +
        //       Get2DAString("baseitems", "RangedWeapon", nType));
        if(Get2DAString("baseitems", "RangedWeapon", nType) != "")
        {
            nValue = GetGoldPieceValue(oItem);
            //ai_Debug("0i_combat", "2949", "nValue: " + IntToString(nValue) + " > 1 Proficient: " +
            //         IntToString(ai_GetIsProficientWith(oCreature, oItem)) + " nMaxItemValue: " + IntToString(nMaxItemValue));
            // Non-Identified items have a goldpiecevalue of 1. So they will not be selected.
            if(nValue > 1 && ai_GetIsProficientWith(oCreature, oItem) &&
              (!GetLocalInt(GetModule(), AI_RULE_ILR) || nMaxItemValue >= nValue))
            {
                //ai_Debug("0i_combat", "2876", " Creature Size: " + IntToString(GetCreatureSize(oCreature)) +
                //       " Weapon Size: " + Get2DAString("baseitems", "WeaponSize", nType));
                // Make sure they are large enough to use it and have the proficiency.
                if(StringToInt(Get2DAString("baseitems", "WeaponSize", nType)) <= nCreatureSize)
                {
                    //ai_Debug("0i_combat", "2887", "nValue: " + IntToString(nValue) +
                    //         " nRangedValue: " + IntToString(nRangedValue) + " nType: " + IntToString(nType));
                    // Is it of the best range weapon type? 0 is any range weapon.
                    // Also grab any range weapon until we have a best type.
                    if(nType == nBestType1 || nType == nBestType2 ||
                        nBestType1 == 0 || oRanged == OBJECT_INVALID)
                    {
                        if(nValue > nRangedValue)
                        {
                            if(ai_GetHasItemProperty(oItem, ITEM_PROPERTY_UNLIMITED_AMMUNITION))
                            {
                                oRanged = oItem; nRangedValue = nValue;
                                //ai_Debug("0i_combat", "2891", "Selecting oRanged: " + GetName(oRanged) +
                                //         " nRangedValue: " + IntToString(nRangedValue) + " and doesn't need ammo!");
                            }
                            else
                            {
                                if(nBestType1 == 0)
                                {
                                    if(nType == BASE_ITEM_LONGBOW || nType == BASE_ITEM_SHORTBOW)
                                    { nAmmo = BASE_ITEM_ARROW; sAmmo = "arrow"; nAmmoSlot = INVENTORY_SLOT_ARROWS; }
                                    else if(nType == BASE_ITEM_HEAVYCROSSBOW || nType == BASE_ITEM_LIGHTCROSSBOW)
                                    { nAmmo = BASE_ITEM_BOLT; sAmmo = "bolt"; nAmmoSlot = INVENTORY_SLOT_BOLTS; }
                                    else if(nType == BASE_ITEM_SLING)
                                    { nAmmo = BASE_ITEM_BULLET; sAmmo = "bullet"; nAmmoSlot = INVENTORY_SLOT_BULLETS; }
                                    else nAmmo = 0;
                                }
                                // Now do we have ammo for it?
                                //ai_Debug("0i_combat", "2907", "nAmmo: " + IntToString(nAmmo));
                                if(nAmmo > 0)
                                {
                                    if(nAmmo == BASE_ITEM_ARROW ||
                                        nAmmo == BASE_ITEM_BOLT ||
                                        nAmmo == BASE_ITEM_BULLET) oAmmo = GetItemInSlot(nAmmoSlot);
                                    if(oAmmo == OBJECT_INVALID)
                                    {
                                        // We don't have ammo equiped so lets see if we have any in our inventory.
                                        oAmmo = GetFirstItemInInventory();
                                        while(oAmmo != OBJECT_INVALID)
                                        {
                                            if(GetBaseItemType(oAmmo) == nAmmo) break;
                                            oAmmo = GetNextItemInInventory();
                                        }
                                        if(oAmmo != OBJECT_INVALID) ActionEquipItem(oAmmo, nAmmoSlot);
                                    }
                                }
                                if(oAmmo != OBJECT_INVALID)
                                {
                                    oRanged = oItem; nRangedValue = nValue;
                                    //ai_Debug("0i_combat", "2928", "Selecting oRanged: " + GetName(oRanged) +
                                    //         " nRangedValue: " + IntToString(nRangedValue));
                                }
                            }
                        }
                    }
                }
            }
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    // They don't have a range weapon so lets break out.
    if(oRanged == OBJECT_INVALID)
    {
        //ai_Debug("0i_combat", "2941", GetName(oCreature) + " did not equip a ranged weapon!");
        return FALSE;
    }
    ActionEquipItem(oRanged, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_EquipBestMonkMeleeWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    //ai_Debug("0i_combat", "2949", GetName(OBJECT_SELF) + " is equiping best monk melee weapon!");
    int nValue, nRightValue;
    int nMaxItemValue = ai_GetMaxItemValueThatCanBeEquiped(GetHitDice(oCreature));
    object oRight = OBJECT_INVALID;
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if(oRightHand != OBJECT_INVALID)
    {
        nRightValue = GetGoldPieceValue(oRightHand);
    }
    // Get the best kama they have in their inventory.
    object oItem = GetFirstItemInInventory(oCreature);
    // If they don't have any kamas then lets stop, we can't equip a weapon.
    if(oItem == OBJECT_INVALID) return FALSE;
    while(oItem != OBJECT_INVALID)
    {
        nValue = GetGoldPieceValue(oItem);
        // Make sure they are high enough level to equip this item.
        if(nMaxItemValue >= nValue && nValue > 1)
        {
            // Is it a single handed weapon?
            if(GetBaseItemType(oItem) == BASE_ITEM_KAMA)
            {
                // Replace the lowest value right weapon.
                if(nValue > nRightValue)
                {
                    oRight = oItem; nRightValue = nValue;
                }
            }
        }
        oItem = GetNextItemInInventory(oCreature);
    }
    // Finally lets just equip the kama if we have one.
    if(oRight == OBJECT_INVALID)
    {
        //ai_Debug("0i_combat", "2983", GetName(oCreature) + " did not equip a melee weapon!");
        return FALSE;
    }
    //ai_Debug("0i_combat", "2986", GetName(oCreature) + " is equiping " + GetName(oRight) + " in the right hand.");
    ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_GetIsInvisible(object oCreature)
{
    if(ai_GetHasEffectType(oCreature, EFFECT_TYPE_INVISIBILITY) ||
       ai_GetHasEffectType(oCreature, EFFECT_TYPE_IMPROVEDINVISIBILITY) ||
       ai_GetHasEffectType(oCreature, EFFECT_TYPE_SANCTUARY) ||
       ai_GetHasEffectType(oCreature, EFFECT_TYPE_ETHEREAL) ||
       GetHasSpellEffect(SPELL_DARKNESS, oCreature) ||
       GetActionMode(oCreature, ACTION_MODE_STEALTH)) return TRUE;
   return FALSE;
}
int ai_CastOffensiveSpellVsTarget(object oCaster, object oCreature, int nSpell)
{
    // Check saves.
    string sSave = Get2DAString("ai_spells", "SaveType", nSpell);
    // There is no save!
    if(sSave == "") return TRUE;
    // Get the level of the spell.
    int nSpellLvl = StringToInt(Get2DAString("ai_spells", "Innate", nSpell));
    // Randomize our check.
    nSpellLvl += Random(AI_SPELL_CHECK_DIE) + AI_SPELL_CHECK_BONUS;
    // Check feats that might increase our DC.
    string sSchool = Get2DAString("spells", "School", nSpell);
    if(sSchool == "V")
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_EVOCATION, oCaster)) nSpellLvl += 4;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_EVOCATION, oCaster)) nSpellLvl += 2;
    }
    else if(sSchool == "C")
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_CONJURATION, oCaster)) nSpellLvl += 4;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION, oCaster)) nSpellLvl += 2;
    }
    else if(sSchool == "N")
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_NECROMANCY, oCaster)) nSpellLvl += 4;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_NECROMANCY, oCaster)) nSpellLvl += 2;
    }
    else if(sSchool == "E")
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ENCHANTMENT, oCaster)) nSpellLvl += 4;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT, oCaster)) nSpellLvl += 2;
    }
    else if(sSchool == "I")
    {
        if(GetHasFeat(FEAT_GREATER_SPELL_FOCUS_ILLUSION, oCaster)) nSpellLvl += 4;
        else if(GetHasFeat(FEAT_SPELL_FOCUS_ILLUSION, oCaster)) nSpellLvl += 2;
    }
    else if(sSave == "Reflex")
    {
        string sImmunityType = Get2DAString("ai_spells", "ImmunityType", nSpell);
        // Give a bonus to our check for half dmg spells unless they can dodge it!
        if((sImmunityType == "Fire" || sImmunityType == "Electricity" || sImmunityType == "Acid" ||
            sImmunityType == "Cold" || sImmunityType == "Sonic") &&
            !GetHasFeat(FEAT_IMPROVED_EVASION, oCreature)) nSpellLvl += AI_SPELL_CHECK_NO_EVASION_BONUS;
        //ai_Debug("0i_combat", "3050", " nSpellLvl: " + IntToString(nSpellLvl) +
        //         " > nMagic: " + IntToString(GetReflexSavingThrow(oCreature)));
        return (nSpellLvl > GetReflexSavingThrow(oCreature));
    }
    else if(sSave == "Fortitude") return (nSpellLvl > GetFortitudeSavingThrow(oCreature));
    else if(sSave == "Will") return (nSpellLvl > GetWillSavingThrow(oCreature));
    return TRUE;
}
int ai_IsInADangerousAOE(object oCreature, float fRange = AI_RANGE_BATTLEFIELD)
{
    int nSpell, nCnt = 1;
    string sAOEType;
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCreature, nCnt);
    float fRadius, fDistance = GetDistanceBetween(oCreature, oAOE);
    while(oAOE != OBJECT_INVALID && fDistance <= fRange)
    {
        // AOE's have the tag set to the "LABEL" in vfx_persistent.2da
        // I check vs those labels to see if the AOE is offensive.
        // Below is the list of Offensive AOE effects.
        sAOEType = GetTag(oAOE);
        if(sAOEType == "VFX_PER_WEB") { fRadius = 6.7; nSpell = SPELL_WEB; }
        else if(sAOEType == "VFX_PER_ENTANGLE") { fRadius = 5.0; nSpell = SPELL_ENTANGLE; }
        else if(sAOEType == "VFX_PER_GREASE") { fRadius = 6.0; nSpell = SPELL_GREASE; }
        else if(sAOEType == "VFX_PER_EVARDS_BLACK_TENTACLES")
             { fRadius = 5.0; nSpell = SPELL_EVARDS_BLACK_TENTACLES; }
        //else if(sAOEType == "VFX_PER_DARKNESS") { fRadius = 6.7; nSpell = SPELL_DARKNESS; }
        else if(sAOEType == "VFX_MOB_SILENCE") { fRadius = 4.0; nSpell = SPELL_SILENCE; }
        else if(sAOEType == "VFX_PER_FOGSTINK") { fRadius = 6.7; nSpell = SPELL_STINKING_CLOUD; }
        else if(sAOEType == "VFX_PER_FOGFIRE") { fRadius = 5.0; nSpell = SPELL_INCENDIARY_CLOUD; }
        else if(sAOEType == "VFX_PER_FOGKILL") { fRadius = 5.0; nSpell = SPELL_CLOUDKILL; }
        else if(sAOEType == "VFX_PER_FOGMIND") { fRadius = 5.0; nSpell = SPELL_MIND_FOG; }
        else if(sAOEType == "VFX_PER_CREEPING_DOOM") { fRadius = 6.7; nSpell = SPELL_CREEPING_DOOM; }
        else if(sAOEType == "VFX_PER_FOGACID") { fRadius = 5.0; nSpell = SPELL_ACID_FOG; }
        else if(sAOEType == "VFX_PER_FOGBEWILDERMENT") { fRadius = 5.0; nSpell = SPELL_CLOUD_OF_BEWILDERMENT; }
        else if(sAOEType == "VFX_PER_WALLFIRE") { fRadius = 10.0; nSpell = SPELL_WALL_OF_FIRE; }
        else if(sAOEType == "VFX_PER_WALLBLADE") { fRadius = 10.0; nSpell = SPELL_BLADE_BARRIER; }
        else if(sAOEType == "VFX_PER_DELAY_BLAST_FIREBALL") { fRadius = 2.0; nSpell = SPELL_DELAYED_BLAST_FIREBALL; }
        else if(sAOEType == "VFX_PER_GLYPH") { fRadius = 2.5; nSpell = SPELL_GLYPH_OF_WARDING; }
        else fRadius = 0.0;
        //ai_Debug("0i_combat", "3088", GetName(oCreature) + " distance from AOE is " + FloatToString(fDistance, 0, 2) +
        //        " AOE Radius: " + FloatToString(fRadius, 0, 2) +
        //        " AOE Type: " + GetTag(oAOE));
        // fRadius > 0.0 keeps them from tiggering that they are in a dangerous
        // AOE due to having an AOE on them.
        if(fRadius > 0.0 && fDistance <= fRadius &&
           !ai_CreatureImmuneToEffect(GetAreaOfEffectCreator(oAOE), oCreature, nSpell)) return TRUE;
        oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCreature, ++nCnt);
        fDistance = GetDistanceBetween(oCreature, oAOE);
    }
    return FALSE;
}
int ai_GetDragonDC(object oCreature)
{
    int nDC, nHitDice = GetHitDice(oCreature);
    if(nHitDice < 4) { nDC = 12; }
    else if(nHitDice < 7) { nDC = 13; }
    else if(nHitDice < 10) { nDC = 14; }
    else if(nHitDice < 13) { nDC = 16; }
    else if(nHitDice < 16) { nDC = 18; }
    else if(nHitDice < 19) { nDC = 20; }
    else if(nHitDice < 22) { nDC = 22; }
    else if(nHitDice < 25) { nDC = 24; }
    else if(nHitDice < 28) { nDC = 26; }
    else if(nHitDice < 31) { nDC = 28; }
    else if(nHitDice < 34) { nDC = 30; }
    else if(nHitDice < 37) { nDC = 32; }
    else if(nHitDice < 39) { nDC = 34; }
    else { nDC = 36; }
    string sTag = GetTag(oCreature);
    if(sTag == "gold_dragon") nDC += 5;
    if(sTag == "red_dragon" || sTag == "silver_dragon")  return nDC + 4;
    else if(sTag == "black_dragon" || sTag == "brass_dragon") return nDC + 3;
    else if(sTag == "green_dragon" || sTag == "copper_dragon")  return nDC + 2;
    else if(sTag == "blue_dragon" || sTag == "bronze_dragon")  return nDC + 1;
    //else if(sTag == "white_dragon") nDC += 0;
    return nDC;
}
void ai_SetCreatureAIScript(object oCreature)
{
    string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
    // They should have skill ranks equal to their level + 1 to use a special AI.
    int nSkillNeeded = GetHitDice(oCreature) + 1;
    // Non-Hostile NPC's do not need to use special tactics by default.
    if(GetStandardFactionReputation(STANDARD_FACTION_HOSTILE) > 89 &&
       (sCombatAI == ""))
    {
        // Ambusher: requires either Improved Invisibility or Invisibility.
        if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY, oCreature) ||
           GetHasSpell(SPELL_INVISIBILITY, oCreature))
        {
            int bCast = ai_TryToCastSpell(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature);
            if(!bCast) bCast = ai_TryToCastSpell(oCreature, SPELL_INVISIBILITY, oCreature);
            if(bCast)
            {
                sCombatAI = "ai_ambusher";
            }
        }
        // Ambusher: Requires a Hide and Move silently skill equal to your level + 1.
        else if(GetSkillRank(SKILL_HIDE, oCreature) >= nSkillNeeded &&
                GetSkillRank(SKILL_MOVE_SILENTLY, oCreature) >= nSkillNeeded)
        {
            sCombatAI = "ai_ambusher";
        }
    }
    // Defensive : requires Parry skill equal to your level or Expertise.
    else if(sCombatAI == "" &&
          (GetSkillRank(SKILL_PARRY, oCreature) >= nSkillNeeded ||
           GetHasFeat(FEAT_EXPERTISE, oCreature) ||
           GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature)))
    {
        sCombatAI = "ai_defensive";
    }
    //else if(sCombatAI == "" && (GetHasSpell(SPELL_LESSER_DISPEL, oCreature) ||
    //        GetHasSpell(SPELL_DISPEL_MAGIC, oCreature) || GetHasSpell(SPELL_GREATER_DISPELLING, oCreature)))
    //{
    //    sCombatAI = "ai_cntrspell";
    //}
    if(sCombatAI == "")
    {
        int nAssociateType = GetAssociateType(oCreature);
        if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR)
        {
            sCombatAI = "ai_default";
        }
        else
        {
            // Select the best ai for this henchmen based on class.
            int nClass = GetClassByPosition(1, oCreature);
            // If they have more than one class use the default ai.
            if(GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID) sCombatAI = "ai_default";
            else if(nClass == CLASS_TYPE_BARBARIAN) sCombatAI = "ai_barbarian";
            else if(nClass == CLASS_TYPE_BARD) sCombatAI = "ai_bard";
            else if(nClass == CLASS_TYPE_CLERIC) sCombatAI = "ai_cleric";
            else if(nClass == CLASS_TYPE_DRUID) sCombatAI = "ai_druid";
            else if(nClass == CLASS_TYPE_FIGHTER) sCombatAI = "ai_fighter";
            else if(nClass == CLASS_TYPE_MONK) sCombatAI = "ai_monk";
            else if(nClass == CLASS_TYPE_PALADIN) sCombatAI = "ai_paladin";
            else if(nClass == CLASS_TYPE_RANGER) sCombatAI = "ai_ranger";
            else if(nClass == CLASS_TYPE_ROGUE) sCombatAI = "ai_rogue";
            else if(nClass == CLASS_TYPE_SORCERER) sCombatAI = "ai_sorcerer";
            else if(nClass == CLASS_TYPE_WIZARD) sCombatAI = "ai_wizard";
            //else if(nClass == CLASS_TYPE_ABERRATION) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_ANIMAL) sCombatAI = "ai_animal";
            //else if(nClass == CLASS_TYPE_CONSTRUCT) sCombatAI = "ai_animal";
            else if(nClass == CLASS_TYPE_DRAGON) sCombatAI = "ai_dragon";
            //else if(nClass == CLASS_TYPE_ELEMENTAL) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_FEY) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_GIANT) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_HUMANOID) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_MAGICAL_BEAST) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_MONSTROUS) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_OOZE) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_OUTSIDER) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_UNDEAD) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_VERMIN) sCombatAI = "ai_animal";
            else sCombatAI = "ai_default";
        }
    }
    //ai_Debug("0i_combat", "3373", GetName(oCreature) + " is setting AI to " + sCombatAI);
    SetLocalString(oCreature, AI_DEFAULT_SCRIPT, sCombatAI);
    SetLocalString(oCreature, AI_COMBAT_SCRIPT, sCombatAI);
}
int ai_IsImmuneToSneakAttacks(object oCreature, object oTarget)
{
    if(GetHasFeat(FEAT_UNCANNY_DODGE_2, oTarget) &&
       GetLevelByClass(CLASS_TYPE_ROGUE, oCreature) + 3 < GetLevelByClass(CLASS_TYPE_ROGUE, oTarget)) return TRUE;
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_SNEAK_ATTACK)) return TRUE;
    object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oTarget);
    if(ai_GetHasItemProperty(oSkin, ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS, IP_CONST_IMMUNITYMISC_BACKSTAB)) return TRUE;
    return FALSE;
}
int ai_IsStrongThanMe(object oCreature, int iIndex)
{
    int nECombat = GetLocalInt(oCreature, AI_ENEMY_COMBAT + IntToString(iIndex));
    int nOCombat = ai_GetMyCombatRating(oCreature);
    //ai_Debug("0i_combat", "3213", GetName(oCreature) + " nOCombat: " +
    //       IntToString(nOCombat) + " nECombat: " + IntToString(nECombat));
    return (nECombat > nOCombat);
}
int ai_StrongOpponent(object oCreature, object oTarget, int nAdj = 2)
{
    int nLevel = GetHitDice(oCreature);
    //ai_Debug("0i_combat", "3220", "ai_StrongOpponent");
    nAdj = nAdj *((nAdj + nLevel) / 10);
    //ai_Debug("0i_combat", "3222", "Is the opponent strong? Target CR >= Our level - nAdj(" +
    //          FloatToString(GetChallengeRating(oTarget), 0, 2) + " >= " + IntToString(nLevel - nAdj) + ")");
    return (FloatToInt(GetChallengeRating(oTarget)) >= nLevel - nAdj);
}
int ai_PowerAttackGood(object oCreature, object oTarget, float fAdj)
{
    int nDmg = ai_GetWeaponDamage(oCreature, 2);
    //ai_Debug("0i_combat", "3412", "nDmg: " + IntToString(nDmg) +
    //         " > Target HP: " + IntToString(GetCurrentHitPoints(oTarget)));
    if(nDmg > GetCurrentHitPoints(oTarget)) return FALSE;
    float fDmg = IntToFloat(nDmg);
    float fTargetAC = IntToFloat(GetAC(oTarget));
    float fCreatureAtk = IntToFloat(ai_GetCreatureAttackBonus(oCreature));
    float fNormalChance = fDmg * ((21.0-(fTargetAC - fCreatureAtk))/20.0);
    // Our chance to hit is already minimum of 5% so this doesn't hurt our chance!
    if(fNormalChance <= 0.05) return TRUE;
    float fAdjChance = (fDmg + fAdj) * ((21.0-(fTargetAC - fCreatureAtk + fAdj))/20);
    //ai_Debug("0i_combat", "3420", "fNormalChance: " + FloatToString(fNormalChance, 0, 2) +
    //         " < fAdjChance: " + FloatToString(fAdjChance, 0, 2) + " = " + IntToString(fNormalChance < fAdjChance));
    return fNormalChance < fAdjChance;
}
int ai_AttackPenaltyOk(object oCreature, object oTarget, float fAtkAdj)
{
    float fTargetAC = IntToFloat(GetAC(oTarget));
    float fCreatureAtk = IntToFloat(ai_GetCreatureAttackBonus(oCreature));
    float fNormalChance = (21.0-(fTargetAC - fCreatureAtk))/20.0;
    //ai_Debug("0i_combat", "3431", "Normal Avg Chance: " + FloatToString(fNormalChance, 0, 2) + " <= 0.05");
    // We already need a 20 to hit so this doesn't hurt our chances!
    if(fNormalChance <= 0.05) return TRUE;
    float fAdjChance = (21.0-(fTargetAC - fCreatureAtk + fAtkAdj))/20.0;
    //ai_Debug("0i_combat", "3435", "Adjusted Avg Chance: " + FloatToString(fAdjChance, 0, 2) + " > 0.55");
    // if our chance is 55% or better to hit then use it.
    return fAdjChance > 0.55;
}
int ai_AttackBonusGood(object oCreature, object oTarget, float fAtkAdj)
{
    float fTargetAC = IntToFloat(GetAC(oTarget));
    float fCreatureAtk = IntToFloat(ai_GetCreatureAttackBonus(oCreature));
    float fNormalChance = (21.0-(fTargetAC - fCreatureAtk))/20.0;
    //ai_Debug("0i_combat", "3450", "Normal Avg Chance: " + FloatToString(fNormalChance, 0, 2) + " > 0.99");
    // We already hit them with any roll so this will not help.
    if(fNormalChance > 0.99) return FALSE;
    float fAdjChance = (21.0-(fTargetAC - fCreatureAtk - fAtkAdj))/20.0;
    //ai_Debug("0i_combat", "3454", "Adjusted Avg Chance: " + FloatToString(fAdjChance, 0, 2) + " < 0.0");
    // if our chance increases our to hit then this is good.
    return fAdjChance > 0.0;
}
int ai_ACAdjustmentGood(object oCreature, object oTarget, float fACAdj)
{
    float fCreatureAC = IntToFloat(GetAC(oCreature));
    float fTargetAtk = IntToFloat(ai_GetCreatureAttackBonus(oTarget));
    float fNormalChance = (21.0-(fCreatureAC - fTargetAtk))/20.0;
    //ai_Debug("0i_combat", "3444", "Normal Chance To Hit: " + FloatToString(fNormalChance, 0, 2) + " <= 0.05");
    // They already need a 20 to hit so adding more AC is worthless.
    if(fNormalChance <= 0.05) return FALSE;
    float fAdjChance = (21.0-(fCreatureAC - fTargetAtk + fACAdj))/20.0;
    //ai_Debug("0i_combat", "3448", "Adjusted Chance To Hit: " + FloatToString(fAdjChance, 0, 2) + " < 1.00");
    // Anything less than 1 helps are AC!
    return fAdjChance < 1.00;
}
int ai_CanIMoveInCombat(object oCreature)
{
    // DC 15 tumble check is required to not give attacks of opportunity.
    return (GetHasFeat(FEAT_MOBILITY, oCreature) || GetHasFeat(FEAT_SPRING_ATTACK, oCreature) ||
            GetSkillRank(SKILL_TUMBLE, oCreature) > 9);
}
int ai_CanIUseRangedWeapon(object oCreature, int nInMelee)
{
    return (!nInMelee || ai_GetEnemyAttackingMe(oCreature) == OBJECT_INVALID);
}
int ai_CheckRangedCombatPosition(object oCreature, object oTarget, int nAction)
{
    if(nAction == AI_LAST_ACTION_RANGED_ATK)
    {
        // Watch the nearest enemy instead of our target as they could move toward us.
        object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
        float fDistance = GetDistanceBetween(oCreature, oNearestEnemy);
        //ai_Debug("0i_combat", "3337", "oNearestEnemy: " + GetName(oNearestEnemy) +
        //         " fDistance: " + FloatToString(fDistance, 0, 2));
        // If we have sneak attack then we need to be within 30'.
        if(GetHasFeat(FEAT_SNEAK_ATTACK, oCreature))
        {
            if(fDistance > AI_RANGE_CLOSE)
            {
                // We check this because if the enemy is moving or has not
                // started acting then we don't want to move up on them as they
                // might move towards us! Just attack! Only sneak attack if they are busy.
                int nAction = GetCurrentAction(oNearestEnemy);
                //ai_Debug("0i_combat", "3353", GetName(oNearestEnemy) + " current action: " + IntToString(nAction));
                if(nAction == ACTION_MOVETOPOINT ||
                   nAction == ACTION_INVALID ||
                   nAction == ACTION_RANDOMWALK) return FALSE;
                // If they are attacking make sure it is in melee?
                // If not then don't move since they might be moving toward us.
                if(nAction == ACTION_ATTACKOBJECT)
                {
                    if(!ai_GetNumOfEnemiesInRange(oNearestEnemy)) return FALSE;
                }
                //ai_Debug("0i_combat", "3355", GetName(oCreature) + " is moving closer [8.0] to " +
                //         GetName(oNearestEnemy) + " to sneak attack with a ranged weapon.");
                ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
                ActionMoveToObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
                ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
                return TRUE;
            }
        }
        else if(fDistance < AI_RANGE_LONG)
        {
            // Lets move back a little, too far and we miss attacks!
            //ai_Debug("0i_combat", "3374", GetName(oCreature) + " is moving away from " +
            //         GetName(oNearestEnemy) + "[2.0] to use a ranged weapon.");
            ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
            ActionMoveAwayFromObject(oNearestEnemy, TRUE, 2.0);
            ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
            return TRUE;
        }
    }
    // If we are casting a hostile spell then check positioning.
    else if(nAction > -1 && Get2DAString("ai_spells", "HostileSetting", nAction) == "1")
    {
        // We are out of melee and casting a spell on an ally so don't move.
        if(!GetIsEnemy(oTarget)) return FALSE;
        float fSpellRange = ai_GetSpellRange(nAction);
        float fTargetRange = GetDistanceBetween(oCreature, oTarget);
        //ai_Debug("0i_combat", "3389", "fSpellRange: " + FloatToString(fSpellRange, 0, 2) +
        //         " fTargetRange: " + FloatToString(fTargetRange, 0, 2));
        // Adjust the ranges to see if we are too close.
        if(fSpellRange == 5.0) fSpellRange = 4.5f;
        //else if(fSpellRange == 8.0) fSpellRange = 8.0f;
        else if(fSpellRange > 10.0f) fSpellRange = 10.0f;
        //ai_Debug("0i_combat", "3395", "Adjusted spell range is " +
        //         FloatToString(fSpellRange, 0, 2) + " : " + GetName(oTarget) + " range is " +
        //         FloatToString(fTargetRange, 0, 2) + ".");
        // We are closer than we have to be to cast our spell.
        if(fTargetRange < fSpellRange)
        {
            // Lets move back a little, too far and we miss attacks!
            //ai_Debug("0i_combat", "3402", GetName(oCreature) + " is moving away from " +
            //         GetName(oTarget) + "[2.0] to cast a spell.");
            ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
            ActionMoveAwayFromObject(oTarget, FALSE, 2.0);
            ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
            return TRUE;
        }
    }
    return FALSE;
}
int ai_CheckMeleeCombatPosition(object oCreature, object oTarget, int nAction, int nBaseItemType = 0)
{
    // If we are not being attacked then we might want to back out of combat.
    if(ai_GetEnemyAttackingMe(oCreature) != OBJECT_INVALID)
    {
        //ai_Debug("0i_combat", "3417", "I am being attacked so stand my ground!");
        return FALSE;
    }
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    float fDistance = GetDistanceBetween(oCreature, oNearestEnemy);
    //ai_Debug("0i_combat", "3422", "oNearestEnemy: " + GetName(oNearestEnemy) + " fDistance " + FloatToString(fDistance, 0, 2));
    if(nAction == AI_LAST_ACTION_RANGED_ATK)
    {
        //ai_Debug("0i_combat", "3425", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) +
        //         "[" + FloatToString(AI_RANGE_MELEE - fDistance + 1.0, 0, 2) + "]" + " to use a ranged weapon.");
        ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
        // Lets move just out of melee range!
        int bRun = ai_CanIMoveInCombat(oCreature);
        ActionMoveAwayFromObject(oNearestEnemy, bRun, AI_RANGE_MELEE - fDistance + 1.0);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return TRUE;
    }
    // If we want to cast a spell this round then back away!
    else if(nAction > -1)
    {
        // Some items we don't need to move on such as wands, staves, and rods.
        if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
           nBaseItemType == BASE_ITEM_MAGICWAND ||
           nBaseItemType == BASE_ITEM_MAGICSTAFF ||
           nBaseItemType == BASE_ITEM_MAGICROD) return FALSE;
        float fSpellRange = ai_GetSpellRange(nAction);
        // A Touch spell means we should not move if we are not the target.
        if(fSpellRange <= 5.0 && oCreature != oTarget) return FALSE;
        //ai_Debug("0i_combat", "3446", GetName(oCreature) + " is moving away from " +
        //         GetName(oTarget) + "[" + FloatToString(AI_RANGE_MELEE - fDistance + 1.0, 0, 2) + "] to cast a spell.");
        ai_SetLastAction(oCreature, AI_LAST_ACTION_MOVE);
        SetActionMode(oCreature, ACTION_MODE_DEFENSIVE_CAST, FALSE);
        // Lets move just out of melee range!
        int bRun = ai_CanIMoveInCombat(oCreature);
        ActionMoveAwayFromObject(oNearestEnemy, bRun, AI_RANGE_MELEE - fDistance + 1.0);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return TRUE;
    }
    return FALSE;
}
int ai_CheckCombatPosition(object oCreature, object oTarget, int nInMelee, int nAction, int nBaseItemType = 0)
{
    if(!GetLocalInt(GetModule(), AI_RULE_ADVANCED_MOVEMENT)) return FALSE;
    //ai_Debug("0i_combat", "3460", "|-----> Checking position in combat: " +
    //         GetName(oCreature) + " nMelee: " + IntToString(nInMelee) +
    //         " Action: " + IntToString(nAction) + " Use Advanced Movement: " +
    //         IntToString(GetLocalInt(GetModule(), AI_RULE_ADVANCED_MOVEMENT)));
    if(ai_CompareLastAction(oCreature, AI_LAST_ACTION_MOVE)) return FALSE;
    // We are not in melee combat so lets see how close we should get.
    if(!nInMelee) return ai_CheckRangedCombatPosition(oCreature, oTarget, nAction);
    // If we are in melee we might need to move out of combat.
    return ai_CheckMeleeCombatPosition(oCreature, oTarget, nAction, nBaseItemType);
}
