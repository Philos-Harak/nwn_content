/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_combat
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for combat scripts.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_messages"
#include "0i_items"
#include "0i_states_cond"
#include "0i_spells_debug"
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
// Returns the index of the nearest creature with least % of hitpoints within
// fRange in the combat state.
// If no creature is found then it will return an index of 0.
// sCreatureType is either AI_ENEMY or AI_ALLY.
int ai_GetMostWoundedIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
// Returns the creature with the lowest health seen within fRange in the combat state.
// Returns OBJECT_INVALID if no creature is found.
object ai_GetMostWoundedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE);
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

//******************************************************************************
//********************  OTHER COMBAT FUNCTIONS  ********************************
//******************************************************************************
// Returns the current round that oCreature is in for this combat.
int ai_GetCurrentRound(object oCreature);
// Returns the difficulty of the battle based on the combat state.
// nDifficulty is Enemy level - Ally level + 15 + Rnd bellcurve -5 to +5 [(d6(2) - 7].
//    31+    : Impossible - We need to get away.
// 26 to  30 : Deadly     - If we are wounded we might want to flee, use all our power.
// 21 to  25 : Hard       - Make sure we are using most of our powers.
// 16 to  20 : Difficult  - Use some power but don't go over board.
// 11 to  15 : Easy       - Use some power but don't go over board.
//  6 to  10 : Simple     - Use our weaker powers.
//  1 to   5 : Effortless - Don't waste spells and powers on this.
//  0 or less: Pointless  - We probably should ignore these dangers.
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
// Returns the percentage of hit points oCreature has left.
int ai_GetPercHPLoss(object oCreature);
// Return TRUE if oCreature is Invisible, shealth mode, or has sanctuary up.
int ai_GetIsInvisible(object oCreature);
// Returns TRUE if if oCaster has a good chance of effecting oCreature with nSpell.
int ai_CastOffensiveSpellVsTarget(object oCaster, object oCreature, int nSpell);
// Returns TRUE if oCreature is in a Dangerous Area of Effect in fRange.
int ai_IsInADangerousAOE(object oCreature, float fRange = AI_RANGE_BATTLEFIELD);
// Gets the base DC for a dragon.
int ai_GetDragonDC(object oCreature);
// Set oCreature's ai scripts based on its first class or the variable "AI_DEFAULT_SCRIPT".
void ai_SetCreatureAIScript(object oCreature);
// Returns TRUE if iIndex target has a higher combat rating than oCreature.
int ai_IsStrongThanMe(object oCreature, int iIndex);
// Returns TRUE if oTarget's CR is within nAdj of oCreature's level, otherwise FALSE.
int ai_StrongOpponent(object oCreature, object oTarget, int nAdj = 2);
// Returns TRUE if oTarget's AC - oCreature Atk - nAtkAdj can hit within 25% to 75%.
int ai_CanHitOpponent(object oCreature, object oTarget, int nAtkAdj);
// Returns TRUE if oCreature AC - oTarget's Atk is less than 20.
int ai_EnemyCanHitMe(object oCreature, object oTarget);
// Returns TRUE if oCreature has Mobility, SpringAttack, or a high Tumble.
int ai_CanIMoveInCombat(object oCreature);
// Returns TRUE if oCreature can safely fire a ranged weapon.
int ai_CanIUseRangedWeapon(object oCreature, int nInMelee);
// Sets an associate event scripts for when in combat, saving old script names.
void ai_SetAssociateCombatEventScripts(object oCreature);
// Sets a monsters event scripts for when in combat, saving old script names.
void ai_SetMonsterCombatEventScripts(object oCreature);
// Sets a creatures event scripts back to default, used after combat.
void ai_RestoreNonCombatEventScripts(object oCreature);
// Returns the number of hitpoints a creature must have to not be healed.
// This is based off of the PC's settings for an associate and other creatures use a default.
int ai_GetHealersHpLimit(object oCreature);
// Returns TRUE if oCreature moves before the action. FALSE if they do not move.
// and -1 if the action is canceled.
// Checks current combat state to see if oCreature needs to move before using an action.
int ai_CheckCombatPosition(object oCreature, object oTarget, int nInMelee, int nAction);

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
        if(GetIsFriend(oAlly) && oAlly != oCreature && !GetIsDead(oAlly))
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
    ai_Debug("0i_combat", "420", "Checking for weakest attacker on " + GetName(oMaster));
    int nEnemyCombatRating, nWeakestCombatRating, nCntr = 1;
    float fNearest = AI_RANGE_MELEE + 1.0f;
    // Get the weakest opponent in melee with our master.
    object oEnemy = ai_GetNearestEnemy(oMaster, nCntr, 7, 7);
    float fDistance = GetDistanceBetween(oMaster, oEnemy);
    while (oEnemy != OBJECT_INVALID && fDistance <= AI_RANGE_MELEE)
    {
        nEnemyCombatRating = ai_GetMyCombatRating(oEnemy);
        ai_Debug("0i_combat", "429", GetName(oEnemy) + " nECR: " + IntToString(nEnemyCombatRating));
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
    ai_Counter_Start();
    int nEnemyNum, nEnemyPower, nAllyNum, nAllyPower, nInMelee, nMagic;
    int nHealth, nCnt, nNth, nAllies, nPower, nDisabled, bThreat;
    int nEnemyHighestPower, nAllyHighestPower;
    float fDistance, fNearest = AI_RANGE_BATTLEFIELD + 1.0;
    string sCnt, sDebugText;
    location lLocation = GetLocation(oCreature);
    object oMelee, oNearestEnemy = OBJECT_INVALID;
    ai_Debug("0i_combat", "458", "************************************************************");
    ai_Debug("0i_combat", "459", "******************* CREATING COMBAT DATA *******************");
    ai_Debug("0i_combat", "460", GetName(oCreature));
    // Get all creatures within 40 meters(5 meters beyond our perception of 35).
    object oObject = GetFirstObjectInShape(SHAPE_SPHERE, AI_RANGE_BATTLEFIELD, lLocation, TRUE);
    while(oObject != OBJECT_INVALID)
    {
        // Process all enemies.
        if(GetIsEnemy(oObject))
        {
            // ********** Check if the Enemy is disabled **********
            bThreat = TRUE;
            nDisabled = ai_Disabled(oObject);
            if(nDisabled)
            {
                // !!!! For /DEBUG CODE !!!!
                sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
                // Decide if they are still a threat: 1 - dead, 2 - Bleeding.
                if(nDisabled == 1 || nDisabled == 2 ||
                   //nDisabled == EFFECT_TYPE_CONFUSED ||
                   //nDisabled == EFFECT_TYPE_FRIGHTENED ||
                   //nDisabled == EFFECT_TYPE_PARALYZE ||
                   nDisabled == EFFECT_TYPE_CHARMED ||
                   nDisabled == EFFECT_TYPE_PETRIFY)
                {
                    bThreat = FALSE;
                    ai_Debug("0i_combat", "484", "Enemy: " + GetName(oObject) + sDebugText);
                }
            }
            // If they are using the coward ai then treat them as frightened.
            // we place it here as an else so we don't overwrite another disabled effect.
            else if(GetLocalString(oObject, AI_COMBAT_SCRIPT) == "ai_coward")
            {
                nDisabled = 25;
                // !!!! For /DEBUG CODE !!!!
                sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
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
                oMelee = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while(oMelee != OBJECT_INVALID && GetDistanceBetween(oMelee, oObject) < AI_RANGE_MELEE)
                {
                    // We add an enemy to the group.
                    if(GetIsEnemy(oMelee)) nInMelee++;
                    // If they are an ally then we subtract one from the group.
                    else nInMelee--;
                    oMelee = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt(oCreature, AI_ENEMY_MELEE + sCnt, nInMelee);
                // ********** Set the Enemies distance **********
                fDistance = GetDistanceBetween(oObject, oCreature);
                SetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt, fDistance);
                // ********** Set if the Enemy is seen **********
                if(GetObjectSeen(oObject, oCreature))
                {
                    SetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt, TRUE);
                    sDebugText += "**** SEEN ****";
                    // ********** Set the Nearest Enemy seen **********
                    if(fDistance < fNearest)
                    {
                        fNearest = fDistance;
                        oNearestEnemy = oObject;
                    }
                }
                // ********** Get the Total levels of the Enemy **********
                nPower = ai_GetCharacterLevels(oObject);
                if(nEnemyHighestPower < nPower) nEnemyHighestPower = nPower;
                nEnemyPower +=(nPower * nHealth) / 100;
                // !!! Temporary debug code !!!
                if(fDistance < AI_RANGE_MELEE) sDebugText += "**** MELEE ****";
                ai_Debug("0i_combat", "541", "Enemy(" + IntToString(nEnemyNum) + "): " +
                         GetName(oObject) + sDebugText);
                ai_Debug("0i_combat", "543", "nHealth: " + IntToString(nHealth) +
                         " nCombat: " + IntToString(ai_GetMyCombatRating(oObject)) +
                         " nInMelee: " + IntToString(nInMelee) +
                         " fDistance: " + FloatToString(fDistance, 0, 2) +
                         " nEnemyNum: " + IntToString(nEnemyNum) +
                         " nEnemyPower: " + IntToString(nEnemyPower / 2));
            }
        }
        // Process all Allies.
        else
        {
            // ********** Set if the Ally is disabled **********
            nDisabled = ai_Disabled(oObject);
            if(nDisabled)
            {
                sDebugText += "**** DISABLED(" + IntToString(nDisabled) + ") ****";
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
                oMelee = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oObject, nNth);
                while(oMelee != OBJECT_INVALID && GetDistanceBetween(oMelee, oObject) < 10.0)
                {
                    if(GetIsEnemy(oMelee)) nInMelee++;
                    else nInMelee--;
                    oMelee = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, oObject, ++nNth);
                }
                SetLocalInt(oCreature, AI_ALLY_MELEE + sCnt, nInMelee);
                // ********** Set the Allies distance **********
                SetLocalFloat(oCreature, AI_ALLY_RANGE + sCnt, GetDistanceBetween(oObject, oCreature));
                // ********** All allies are considered to be seen **********
                SetLocalInt(oCreature, AI_ALLY_SEEN + sCnt, TRUE);
                // ********** Get the Total levels of the Allies **********
                nPower = ai_GetCharacterLevels(oObject);
                if(nAllyHighestPower < nPower) nAllyHighestPower = nPower;
                nAllyPower +=(nPower * nHealth) / 100;
                ai_Debug("0i_combat", "590", "Ally(" + IntToString(nAllyNum) + "): " +
                         GetName(oObject) + sDebugText);
                ai_Debug("0i_combat", "592", "nHealth: " + IntToString(nHealth) +
                         " nInMelee: " + IntToString(nInMelee) +
                         " fDistance: " + FloatToString(GetDistanceToObject(oObject), 0, 2) +
                         " nAllyNum: " + IntToString(nAllyNum) +
                         " nAllyPower: " + IntToString(nAllyPower / 2));
            }
        }
        //sDebugText = "";
        oObject = GetNextObjectInShape(SHAPE_SPHERE, AI_RANGE_BATTLEFIELD, lLocation, TRUE);
    }
    ai_Debug("0i_combat", "602", "Nearest Enemy: " + GetName(oNearestEnemy));
    ai_Debug("0i_combat", "603", "****************** FINISHED COMBAT DATA  *******************");
    ai_Debug("0i_combat", "604", "************************************************************");
    // Lets save processing by only clearing previous enemy data we don't overwrite.
    int nEnd = GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
    nCnt = nEnemyNum + 1;
    ai_Debug("0i_combat", "608", "Clearing Enemy Combat Data: nEnd: " + IntToString(nEnd) +
             " nCnt: " + IntToString(nCnt));
    while(nEnd >= nCnt)
    {
        sCnt = IntToString(nCnt);
        ai_Debug("0i_combat", "613", "Clearing Enemy Combat Data: " + sCnt + " " +
                 GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)));
        DeleteLocalObject(oCreature, AI_ENEMY + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_SEEN + sCnt);
        DeleteLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_MELEE + sCnt);
        DeleteLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt);
        nCnt ++;
    }
    // Lets save processing by only clearing previous ally data we don't overwrite.
    nEnd = GetLocalInt(oCreature, AI_ALLY_NUMBERS);
    nCnt = nAllyNum + 1;
    ai_Debug("0i_combat", "626", "Clearing Ally Combat Data: nEnd: " + IntToString(nEnd) +
             " nCnt: " + IntToString(nCnt));
    while(nEnd >= nCnt)
    {
        sCnt = IntToString(nCnt);
        ai_Debug("0i_combat", "631", "Clearing Ally Combat Data: " + sCnt + " " +
                 GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)));
        DeleteLocalObject(oCreature, AI_ALLY + sCnt);
        DeleteLocalInt(oCreature, AI_ALLY_SEEN + sCnt);
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
    nEnemyPower =(nEnemyPower / 2) + (nEnemyHighestPower / 2);
    SetLocalInt(oCreature, AI_ENEMY_POWER, nEnemyPower);
    SetLocalObject(oCreature, AI_ENEMY_NEAREST, oNearestEnemy);
    SetLocalInt(oCreature, AI_ALLY_NUMBERS, nAllyNum);
    // Total ally power is half the levels of all allies + the total levels
    // of the highest level ally, only used by associates.
    nAllyPower =(nAllyPower / 2) + (nAllyHighestPower / 2);
    SetLocalInt(oCreature, AI_ALLY_POWER, nAllyPower);
    ai_Counter_End(GetName(oCreature) + " has created the Combat State");
    return oNearestEnemy;
}
void ai_ClearCombatState(object oCreature)
{
    int bEnemyDone, bAllyDone, nCnt = 1;
    int nEnemyNum = GetLocalInt(oCreature, AI_ENEMY_NUMBERS);
    int nAllyNum = GetLocalInt(oCreature, AI_ALLY_NUMBERS);
    ai_Debug("0i_combat", "661", "Clearing " + GetName(oCreature) + "'s combat state." +
             " nEnemyNum: " + IntToString(nEnemyNum) + " nAllyNum: " + IntToString(nAllyNum));
    string sCnt;
    while(!bEnemyDone || !bAllyDone)
    {
        sCnt = IntToString(nCnt);
        if(nCnt <= nEnemyNum)
        {
            ai_Debug("0i_combat", "669", "Clearing " + GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)) + ".");
            DeleteLocalObject(oCreature, AI_ENEMY + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_DISABLED + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_SEEN + sCnt);
            DeleteLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_COMBAT + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_MELEE + sCnt);
            DeleteLocalInt(oCreature, AI_ENEMY_HEALTH + sCnt);
        }
        else bEnemyDone = TRUE;
        if(nCnt <= nAllyNum)
        {
            ai_Debug("0i_combat", "681", "Clearing " + GetName(GetLocalObject(oCreature, AI_ENEMY + sCnt)) + ".");
            DeleteLocalObject(oCreature, AI_ALLY + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_DISABLED + sCnt);
            DeleteLocalInt(oCreature, AI_ALLY_SEEN + sCnt);
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
    DeleteLocalInt(oCreature, sLastActionVarname);
    DeleteLocalInt(oCreature, sTalentsSetVarname);
    ai_RestoreNonCombatEventScripts(oCreature);
    ai_EndCombatRound(oCreature);
    ai_ClearCreatureActions(oCreature, TRUE);
}
//******************************************************************************
//*************** GET TARGETS USING COMBAT STATE FUNCTIONS *********************
//******************************************************************************
// These functions will find a target based on the combat state variables created
// by the function ai_SetCombatState.

int ai_GetNearestCreatureIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "743", "Getting Nearest Creature Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "780", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetNearestTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "786", "Checking for nearest target within " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "803", "Getting Lowest Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "848", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object  ai_GetLowestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "854", "Checking for lowest combat rated target in " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetLowestCRIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetHighestCRIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "871", "Getting Highest Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "916", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " HighestCombatRating: " + IntToString(nHCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetHighestCRTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "922", "Checking for highest combat rated target in " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetHighestCRIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "939", "Getting Lowest Index for spell: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                        ai_Debug("0i_combat", "975", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                                 "oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "993", AI_ENEMY + " fRange: " + FloatToString(fRange, 0, 2) +
           " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
int ai_GetHighestCRIndexForSpell(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "1008", "Getting Highest Index for Spell: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                        ai_Debug("0i_combat", "1044", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                                 "oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "1062", AI_ENEMY + " fRange: " + FloatToString(fRange, 0, 2) +
           " HighestCombatRating: " + IntToString(nHCombat) + " = " + IntToString(nIndex));
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
        ai_Debug("0i_combat", "1075", "Getting Lowest Melee Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fTargetRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1098", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " LowestMeleeTarget: " + IntToString(nLMelee) + " Index: " + IntToString(nIndex));
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
        ai_Debug("0i_combat", "1111", "Getting Highest Melee Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) + " fRange: " +
                 FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1134", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
           " HighestMeleeTarget: " + IntToString(nHMelee) + " Index: " + IntToString(nIndex));
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
        ai_Debug("0i_combat", "1148", "Getting Most Wounded Index: " + sCnt + " " +
                 GetName(oTarget) +
                 " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)) +
                 " Health: " + IntToString(GetLocalInt(oCreature, sCreatureType + "_HEALTH" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
                            ai_Debug("0i_combat", "1176", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                                   "oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "1193", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
           " GetMostWoundedTargetForDamage: " + IntToString(nLHp) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetMostWoundedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "1199", "Checking for most wounded target in " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
object ai_GetLowestFortitudeSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nFortitude, nLDFortitude = 100, nLFortitude = 100;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "1216", "Getting Lowest Fort Save: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                        ai_Debug("0i_combat", "1252", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                               " oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "1275", "Fortitude: " + IntToString(nLFortitude) +
             " Disabled Fortitude: " + IntToString(nLDFortitude) + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
}
object ai_GetLowestReflexSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nReflex, nLDReflex = 100, nLReflex = 100;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "1291", "Getting Lowest Refl Save: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                        ai_Debug("0i_combat", "1327", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                                " oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "1350", "Reflex: " + IntToString(nLReflex) +
             " Disabled Reflex: " + IntToString(nLDReflex) + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
}
object ai_GetLowestWillSaveTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION)
{
    int nCnt = 1;
    int nIndex, nDIndex, nWill, nLDWill = 100, nLWill = 100;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestDTargetRange = fRange + 1.0, fLowestTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "1366", "Getting Lowest Will Save: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                        ai_Debug("0i_combat", "1402", "CurrentHP: " + IntToString(GetCurrentHitPoints(oTarget)) +
                               " oAttacker: " + GetName(oAttacker));
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
    ai_Debug("0i_combat", "1425", "Will: " + IntToString(nLWill) +
             " Disabled Will: " + IntToString(nLDWill) + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
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
        ai_Debug("0i_combat", "1450", "Getting Nearest Index that sees us: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " Sees us?: " + IntToString(GetObjectSeen(oCreature, oTarget)));
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
    ai_Debug("0i_combat", "1462", "Nearest Enemy that sees us: nIndex: " + IntToString (nIndex));
    return nIndex;
}
int ai_GetBestSneakAttackIndex(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oAttacking, oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
        ai_Debug("0i_combat", "1478", "Getting Sneak Attack Index: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
                !GetIsDead(oTarget) &&
            // Uncanny Dodge II gives immunity to sneak attack unless attacker
            // is 4 levels higher. We will assume they are always immune for simplicity.
                !GetHasFeat(FEAT_UNCANNY_DODGE_2, oTarget))
            {
                if(bAlwaysAtk || !ai_IsStrongThanMe(oCreature, nCnt))
                {
                    oAttacking = ai_GetAttackedTarget(oTarget);
                    ai_Debug("0i_combat", "1494", "oTarget: " + GetName(oTarget) +
                             " is attacking " + GetName(oAttacking));
                    // They are not attacking us?
                    if(oAttacking != oCreature)
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
    ai_Debug("0i_combat", "1534", "Get attacking target (Index: " + IntToString(nIndex) + ")");
    return nIndex;
}
int ai_GetNearestIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1548", "Getting Nearest Index Not in AOE: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be in a dangerous AOE.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1591", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetNearestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "1597", "Getting nearest target not in an AOE within " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetNearestIndexNotInAOE(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetLowestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1614", "Getting Lowest Index Not in AOE: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1660", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " LowestCombatRating: " + IntToString(nLCombat) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetLowestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "1666", "Getting lowest target not in an AOE within " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
    string sIndex = IntToString(ai_GetLowestCRIndexNotInAOE(oCreature, fRange, sCreatureType, bAlwaysAtk));
    return GetLocalObject(oCreature, sCreatureType + sIndex);
}
int ai_GetHighestCRIndexNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = 0, nHDCombat = 0, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1683", "Getting Highest Index Not in AOE: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them and they can't be dead or dying.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1729", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_GetHighestTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    ai_Debug("0i_combat", "1735", "Getting highest target not in an AOE within " +
             FloatToString(fRange, 0, 2) + " CreatureType: " + sCreatureType +
             " AlwaysAtk: " + IntToString(bAlwaysAtk));
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
        ai_Debug("0i_combat", "1750", "Getting Highest Melee Index Not in AOE: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " +
                 FloatToString(fTargetRange, 0, 2) + " fRange: " + FloatToString(fRange, 0, 2) +
                 " Seen: " + IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1774", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " HighestMeleeTarget: " + IntToString(nHMelee) + " Index: " + IntToString(nIndex));
    return nIndex;
}
object ai_CheckForGroupedTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString(ai_GetHighestMeleeIndex(oCreature, fRange, sCreatureType));
    int nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sIndex) + 1;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sIndex);
    // If they found a target and we have a 25% per enemy in group.
    int nRoll = d4();
    ai_Debug("0i_combat", "1786", "Getting Grouped Target: oTarget: " +
             GetName(oTarget) + " :" + IntToString(nInMelee) +
             " >= d4:" + IntToString(nRoll));
    if(oTarget != OBJECT_INVALID && nInMelee >= nRoll) return oTarget;
    return OBJECT_INVALID;
}
object ai_CheckForGroupedTargetNotInAOE(object oCreature, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY)
{
    // Lets see if we can find a creature with the most enemies around them.
    string sIndex = IntToString(ai_GetHighestMeleeIndexNotInAOE(oCreature, fRange, sCreatureType));
    int nInMelee = GetLocalInt(oCreature, sCreatureType + "_MELEE" + sIndex) + 1;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sIndex);
    if(oTarget == OBJECT_INVALID) return OBJECT_INVALID;
    // If they found a target and we have a 25% per enemy in group.
    int nRoll = d4();
    ai_Debug("0i_combat", "1801", "Getting Group Target Not in AOE: oTarget: " +
             GetName(oTarget) + " :" + IntToString(nInMelee) +
             " >= d4:" + IntToString(nRoll));
    if(nInMelee >= nRoll) return oTarget;
    return OBJECT_INVALID;
}
object ai_GetNearestClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1818", "Getting Nearest Class Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1863", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return GetLocalObject(OBJECT_SELF, sCreatureType + IntToString(nIndex));
}
object ai_GetLowestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1868", "Getting Lowest Class Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckClassType(oTarget, nClassType))
        {
            // We must be able to see them.
            if(GetLocalInt(OBJECT_SELF, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1922", "Class: " + IntToString(nClassType) +
             " CreatureType: " + sCreatureType + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetHighestCRClassTarget(object oCreature, int nClassType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1938", "Getting Highest Class Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckClassType(oTarget, nClassType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "1983", "Class: " + IntToString(nClassType) +
             " CreatureType: " + sCreatureType + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetNearestRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "1999", "Getting Nearest Racial Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange)
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "2043", sCreatureType + " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetLowestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nLCombat = 100, nLDCombat = 100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "2058", "Getting Lowest Racial Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(OBJECT_SELF, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckRacialType(oTarget, nRacialType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "2103", "Race: " + IntToString(nRacialType) +
             " CreatureType: " + sCreatureType + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetHighestCRRacialTarget(object oCreature, int nRacialType, float fRange = AI_RANGE_PERCEPTION, string sCreatureType = AI_ENEMY, int bAlwaysAtk = TRUE)
{
    int nHCombat = -100, nHDCombat = -100, nCombat, nIndex, nDIndex, nCnt = 1;
    int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
    string sCnt = "1";
    float fTargetRange, fLowestTargetRange = fRange + 1.0;
    float fLowestDTargetRange = fRange + 1.0;
    object oTarget = GetLocalObject(oCreature, sCreatureType + sCnt);
    while(oTarget != OBJECT_INVALID)
    {
        fTargetRange = GetLocalFloat(oCreature, sCreatureType + "_RANGE" + sCnt);
        ai_Debug("0i_combat", "2119", "Getting Highest Racial Target: " + sCnt + " " +
                 GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                 " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                 IntToString(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt)));
        if(fTargetRange <= fRange && ai_CheckRacialType(oTarget, nRacialType))
        {
            // We must be able to see them.
            if(GetLocalInt(oCreature, sCreatureType + "_SEEN" + sCnt) &&
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
    ai_Debug("0i_combat", "2164", "Race: " + IntToString(nRacialType) +
             " CreatureType: " + sCreatureType + " fRange: " +
             FloatToString(fRange, 0, 2) + " Index: " + IntToString(nIndex));
    return GetLocalObject(oCreature, sCreatureType + IntToString(nIndex));
}
object ai_GetNearestFavoredEnemyTarget(object oCreature, float fRange = AI_RANGE_PERCEPTION, int bAlwaysAtk = TRUE)
{
    int nRace, nRacialType, nIndex, nDIndex, nCnt = 1;
    string sCnt;
    float fTargetRange, fLowestTargetRange, fLowestDTargetRange;
    object oTarget;
    while(oTarget == OBJECT_INVALID && nRace <24)
    {
        // Find which favored enemies we have.
        if(nRace < 1 && GetHasFeat(FEAT_FAVORED_ENEMY_ABERRATION, oCreature))
        {
            nRace = 1;
            nRacialType = RACIAL_TYPE_ABERRATION;
        }
        else if(nRace < 1 && GetHasFeat(FEAT_FAVORED_ENEMY_ANIMAL, oCreature))
        {
            nRacialType = RACIAL_TYPE_ANIMAL;
        }
        else if(nRace < 2 && GetHasFeat(FEAT_FAVORED_ENEMY_BEAST, oCreature))
        {
            nRace = 2;
            nRacialType = RACIAL_TYPE_BEAST;
        }
        else if(nRace < 3 && GetHasFeat(FEAT_FAVORED_ENEMY_CONSTRUCT, oCreature))
        {
            nRace = 3;
            nRacialType = RACIAL_TYPE_CONSTRUCT;
        }
        else if(nRace < 4 && GetHasFeat(FEAT_FAVORED_ENEMY_DRAGON, oCreature))
        {
            nRace = 4;
            nRacialType = RACIAL_TYPE_DRAGON;
        }
        else if(nRace < 5 && GetHasFeat(FEAT_FAVORED_ENEMY_DWARF, oCreature))
        {
            nRace = 5;
            nRacialType = RACIAL_TYPE_DWARF;
        }
        else if(nRace < 6 && GetHasFeat(FEAT_FAVORED_ENEMY_ELEMENTAL, oCreature))
        {
            nRace = 6;
            nRacialType = RACIAL_TYPE_ELEMENTAL;
        }
        else if(nRace < 7 && GetHasFeat(FEAT_FAVORED_ENEMY_ELF, oCreature))
        {
            nRace = 7;
            nRacialType = RACIAL_TYPE_ELF;
        }
        else if(nRace < 8 && GetHasFeat(FEAT_FAVORED_ENEMY_FEY, oCreature))
        {
            nRace = 8;
            nRacialType = RACIAL_TYPE_FEY;
        }
        else if(nRace < 9 && GetHasFeat(FEAT_FAVORED_ENEMY_GIANT, oCreature))
        {
            nRace = 9;
            nRacialType = RACIAL_TYPE_GIANT;
        }
        else if(nRace < 10 && GetHasFeat(FEAT_FAVORED_ENEMY_GNOME, oCreature))
        {
            nRace = 10;
            nRacialType = RACIAL_TYPE_GNOME;
        }
        else if(nRace < 11 && GetHasFeat(FEAT_FAVORED_ENEMY_GOBLINOID, oCreature))
        {
            nRace = 11;
            nRacialType = RACIAL_TYPE_HUMANOID_GOBLINOID;
        }
        else if(nRace < 12 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFELF, oCreature))
        {
            nRace = 12;
            nRacialType = RACIAL_TYPE_HALFELF;
        }
        else if(nRace < 13 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFLING, oCreature))
        {
            nRace = 13;
            nRacialType = RACIAL_TYPE_HALFLING;
        }
        else if(nRace < 14 && GetHasFeat(FEAT_FAVORED_ENEMY_HALFORC, oCreature))
        {
            nRace = 14;
            nRacialType = RACIAL_TYPE_HALFORC;
        }
        else if(nRace < 15 && GetHasFeat(FEAT_FAVORED_ENEMY_HUMAN, oCreature))
        {
            nRace = 15;
            nRacialType = RACIAL_TYPE_HUMAN;
        }
        else if(nRace < 16 && GetHasFeat(FEAT_FAVORED_ENEMY_MAGICAL_BEAST, oCreature))
        {
            nRace = 16;
            nRacialType = RACIAL_TYPE_MAGICAL_BEAST;
        }
        else if(nRace < 17 && GetHasFeat(FEAT_FAVORED_ENEMY_MONSTROUS, oCreature))
        {
            nRace = 17;
            nRacialType = RACIAL_TYPE_HUMANOID_MONSTROUS;
        }
        else if(nRace < 18 && GetHasFeat(FEAT_FAVORED_ENEMY_ORC, oCreature))
        {
            nRace = 18;
            nRacialType = RACIAL_TYPE_HUMANOID_ORC;
        }
        else if(nRace < 19 && GetHasFeat(FEAT_FAVORED_ENEMY_OUTSIDER, oCreature))
        {
            nRace = 19;
            nRacialType = RACIAL_TYPE_OUTSIDER;
        }
        else if(nRace < 20 && GetHasFeat(FEAT_FAVORED_ENEMY_REPTILIAN, oCreature))
        {
            nRace = 20;
            nRacialType = RACIAL_TYPE_HUMANOID_REPTILIAN;
        }
        else if(nRace < 21 && GetHasFeat(FEAT_FAVORED_ENEMY_SHAPECHANGER, oCreature))
        {
            nRace = 21;
            nRacialType = RACIAL_TYPE_SHAPECHANGER;
        }
        else if(nRace < 22 && GetHasFeat(FEAT_FAVORED_ENEMY_UNDEAD, oCreature))
        {
            nRace = 22;
            nRacialType = RACIAL_TYPE_UNDEAD;
        }
        else if(nRace < 23 && GetHasFeat(FEAT_FAVORED_ENEMY_VERMIN, oCreature))
        {
            nRace = 23;
            nRacialType = RACIAL_TYPE_VERMIN;
        }
        else nRace = 24;
        if(nRace < 24)
        {
            // Now find the creature of the race we have.
            int bIngnoreAssociates = ai_GetAssociateMode(oCreature, AI_MODE_IGNORE_ASSOCIATES);
            sCnt = "1";
            fLowestTargetRange = fRange + 1.0;
            fLowestDTargetRange = fRange + 1.0;
            oTarget = GetLocalObject(oCreature, AI_ENEMY + sCnt);
            while(oTarget != OBJECT_INVALID)
            {
                fTargetRange = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCnt);
                ai_Debug("0i_combat", "2309", "Getting Nearest Favored Enemy: " + sCnt + " " +
                         GetName(oTarget) + " fTargetRange: " + FloatToString(fTargetRange, 0, 2) +
                         " fRange: " + FloatToString(fRange, 0, 2) + " Seen: " +
                         IntToString(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt)));
                if(fTargetRange <= fRange)
                {
                    // We must be able to see them.
                    if(GetLocalInt(oCreature, AI_ENEMY_SEEN + sCnt) &&
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
                if (fRange == AI_RANGE_MELEE) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
                else nIndex = nDIndex;
            }
            else oTarget = GetLocalObject(oCreature, AI_ENEMY + IntToString(nIndex));
        }
    }
    ai_Debug("0i_combat", "2356", " fRange: " + FloatToString(fRange, 0, 2) +
             " Index: " + IntToString(nIndex));
    return oTarget;
}
object ai_GetNearestTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if(nInMelee > 0) sIndex = IntToString(ai_GetNearestCreatureIndex(oCreature, AI_RANGE_MELEE, AI_ENEMY, bAlwaysAtk));
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
    // We might not have a target, if so then just use the nearest target.
    if(oTarget == OBJECT_INVALID) oTarget = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    ai_Debug("0i_combat", "2379", GetName(oTarget) + " is the nearest target for melee combat!");
    return oTarget;
}
object ai_GetLowestCRTargetForMeleeCombat(object oCreature, int nInMelee, int bAlwaysAtk = TRUE)
{
    string sIndex;
    // Are we in melee? If so try to get the weakest enemy in melee.
    if(nInMelee > 0) sIndex = IntToString(ai_GetLowestCRIndex(oCreature, AI_RANGE_MELEE, AI_ENEMY, bAlwaysAtk));
    // If not then lets go find someone to attack!
    else
    {
        // Get the weakest combat rated enemy.
        sIndex = IntToString(ai_GetLowestCRIndexNotInAOE(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        // If we didn't get a target then get any target within range.
        if(sIndex == "0")
        {
            sIndex = IntToString(ai_GetLowestCRIndex(oCreature, AI_RANGE_PERCEPTION, AI_ENEMY, bAlwaysAtk));
        }
    }
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    // We might not have a target, if so then just use the nearest target.
    if(oTarget == OBJECT_INVALID) oTarget = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    ai_Debug("0i_combat", "2401", GetName(oTarget) + " is the weakest target for melee combat!");
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
        // If we didn't get a target then get any target within range.
        if(sIndex == "0") sIndex = IntToString(ai_GetHighestCRIndex(oCreature, AI_RANGE_PERCEPTION));
    }
    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
    // We might not have a target, if so then just use the nearest target.
    if(oTarget == OBJECT_INVALID) oTarget = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    ai_Debug("0i_combat", "2420", GetName(oTarget) + " is the strongest target for melee combat!");
    return oTarget;
}
object ai_GetEnemyAttackingMe(object oCreature, float fRange = AI_RANGE_MELEE)
{
    int nCtr = 1;
    float fDistance, fEnemyDistance = fRange + 1.0;
    string sCtr = "1";
    object oAttacked, oAttacker = OBJECT_INVALID;
    object oEnemy = GetLocalObject(oCreature, AI_ENEMY + "1");
    while(oEnemy != OBJECT_INVALID)
    {
        fDistance = GetLocalFloat(oCreature, AI_ENEMY_RANGE + sCtr);
        ai_Debug("0i_combat", "2433", "Getting Enemy Attacking Me: " + sCtr + " " +
                         GetName(oEnemy) + " fTargetRange: " + FloatToString(fDistance, 0, 2) +
                         " fRange: " + FloatToString(fRange, 0, 2) + " Attacking: " +
                         GetName(ai_GetAttackedTarget(oEnemy)));
        if(fDistance <= fRange)
        {
            oAttacked = ai_GetAttackedTarget(oEnemy);
            // If an enemy isn't attacking someone we must assume we are next!
            if(oAttacked == oCreature || oAttacked == OBJECT_INVALID)
            {
                if(fDistance < fEnemyDistance)
                {
                    oAttacker = oEnemy;
                    fEnemyDistance = fDistance;
                }
            }
        }
        sCtr = IntToString(++nCtr);
        oEnemy = GetLocalObject(oCreature, AI_ENEMY + sCtr);
    }
    ai_Debug("0i_combat", "2453", "Enemy attacking me: " + GetName(oAttacker) + " has attacked: " + GetName(ai_GetAttackedTarget(oAttacker)));
    return oAttacker;
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
    ai_Debug("0i_combat", "2465", IntToString (nNumOfEnemies) + " enemies within " + FloatToString(fRange, 0, 2) + " meters.");
    return nNumOfEnemies;
}

//******************************************************************************
//********************  OTHER COMBAT FUNCTIONS  ********************************
//******************************************************************************

int ai_GetCurrentRound(object oCreature)
{
    int nRound = GetLocalInt(oCreature, AI_ROUND) + 1;
    SetLocalInt(oCreature, AI_ROUND, nRound);
    ai_Debug("0i_combat", "2477", "nRound: " + IntToString(nRound));
    return nRound;
}
int ai_GetDifficulty(object oCreature)
{
    // We randomize a bell curve of +10 to +20
    int nRoll = d6(2) + 8;
    int nDifficulty = GetLocalInt(oCreature, AI_ENEMY_POWER) - GetLocalInt(oCreature, AI_ALLY_POWER) + nRoll;
    int nAdjustment = GetLocalInt(oCreature, AI_DIFFICULTY_ADJUSTMENT);
    //ai_Debug("0i_combat", "2486", "(Difficulty: Enemy Power: " + IntToString(GetLocalInt(oCreature, AI_ENEMY_POWER)) +
    //         " - Ally Power: " + IntToString(GetLocalInt(oCreature, AI_ALLY_POWER)) +
    //         ") + nRoll: " + IntToString(nRoll) + " + nAdj: " + IntToString(nAdjustment) +
    //         " = " + IntToString(nDifficulty));
    return nDifficulty + nAdjustment;
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
    ai_Debug("0i_combat", "2500", "GetMyCombatRating (nAtkBonus: " + IntToString(nAtkBonus) +
             " nAC: " + IntToString(GetAC(oCreature)) + " - 10) / 2");
    return(nAtkBonus + GetAC(oCreature) - 10) / 2;
}
object ai_GetAttackedTarget(object oCreature, int bPhysical = TRUE, int bSpell = FALSE)
{
    object oTarget = GetAttackTarget(oCreature);
    if(!GetIsObjectValid(oTarget) && bPhysical) oTarget = GetLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
    if(!GetIsObjectValid(oTarget) && bSpell) oTarget = GetLocalObject(oCreature, AI_ATTACKED_SPELL);
    if(GetIsDead(oTarget)) return OBJECT_INVALID;
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
    ai_Debug("0i_combat", "2058", "Enemy: " + IntToString(bEnemy) + " fRange: " + FloatToString(fRange, 0, 2) +
              " CLERICS: " + IntToString(sCount.CLERICS) + "(" + IntToString(sCount.CLERIC_LEVELS) +
              ") FIGHTERS: " +IntToString(sCount.FIGHTERS) + "(" + IntToString(sCount.FIGHTER_LEVELS) +
              ") MAGES: " +IntToString(sCount.MAGES) + "(" + IntToString(sCount.MAGE_LEVELS) +
              ") MONSTERS: " +IntToString(sCount.MONSTERS) + "(" + IntToString(sCount.MONSTER_LEVELS) +
              ") TOTALS: " +IntToString(sCount.TOTAL) + "(" + IntToString(sCount.TOTAL_LEVELS));
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
    ai_Debug("0i_combat", "2673", GetName(OBJECT_SELF) + " is equiping best weapon!");
    // Determine if I am wielding a ranged weapon, melee weapon, or none.
    int bIsWieldingRanged = ai_HasRangedWeaponWithAmmo(oCreature);
    int bIsWieldingMelee = ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
    ai_Debug("0i_combat", "2677", "bIsWieldingRanged: " + IntToString(bIsWieldingRanged) +
             " bIsWieldingMelee: " + IntToString(bIsWieldingMelee));
    // If we are invisible then change to a melee weapon so we can move in to attack.
    if(ai_GetIsInvisible(oCreature))
    {
        // Equip a melee weapon unless we already have one.
        if(!bIsWieldingMelee) ai_EquipBestMeleeWeapon(oCreature, oTarget);
        return;
    }
    // Equip the appropriate weapon for the distance of the enemy.
    int nEnemyGroup = ai_GetNumOfEnemiesInGroup(oCreature);
    ai_Debug("0i_combat", "2688", GetName(oCreature) + " has " + IntToString(nEnemyGroup) + " enemies within 5.0f them! PointBlank: " +
             IntToString(GetHasFeat(FEAT_POINT_BLANK_SHOT, oCreature)));
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
                    ai_Debug("0i_combat", "2703", GetName(oCreature) + " is equiping melee weapon due to close enemies!");
                }
            }
        }
    }
    // We are not in melee range.
    else
    {
        ai_Debug("0i_combat", "2711", GetName(oCreature) + " is not in melee combat with an enemy!");
        // If are at range with the enemy then equip a ranged weapon.
        if(!bIsWieldingRanged)
        {
            ai_EquipBestRangedWeapon(oTarget);
            // Make sure that they equiped a range weapon.
            bIsWieldingRanged = ai_HasRangedWeaponWithAmmo(oCreature);
            bIsWieldingMelee = ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature));
            ai_Debug("0i_combat", "2719", GetName(oCreature) + " is attempting to equip a ranged weapon: " + IntToString(bIsWieldingRanged));
            // If we equiped a ranged weapon then drop out.
        }
    }
    // We don't have a weapon out so equip one! We are in combat!
    if(!bIsWieldingRanged && !bIsWieldingMelee) ai_EquipBestMeleeWeapon(OBJECT_INVALID);
}
int ai_EquipBestMeleeWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    ai_Debug("0i_combat", "2728", GetName(OBJECT_SELF) + " is equiping best melee weapon!");
    int nValue, nRightValue, nLeftValue, n2HandValue, nShieldValue;
    int nMaxItemValue = ai_GetMaxItemValueThatCanBeEquiped(GetHitDice(oCreature));
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
        // Non-Identified items have a goldpiecevalue of 1. So they will not be selected.
        nValue = GetGoldPieceValue(oItem);
        // Make sure they are high enough level to equip this item.
        if(nMaxItemValue >= nValue && nValue > 1)
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
        ai_Debug("0i_combat", "2787", GetName(oCreature) + " is equiping " +
                 GetName(oRight) + " in the right hand. " +
                 GetName(oLeft) + " in the left hand.");
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
        ai_Debug("0i_combat", "2800", GetName(oCreature) + " is equiping " +
                 GetName(oTwoHand) + " in both hands. ");
        ActionEquipItem(oTwoHand, INVENTORY_SLOT_RIGHTHAND);
        return TRUE;
    }
    // Lets equip a weapon and a shield.
    else if(oRight != OBJECT_INVALID && oShield != OBJECT_INVALID && GetHasFeat(FEAT_SHIELD_PROFICIENCY, oCreature))
    {
        ai_Debug("0i_combat", "2808", GetName(oCreature) + " is equiping " +
                 GetName(oRight) + " in the right hand. " +
                 GetName(oShield) + " in the left hand.");
        ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
        ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND);
        return TRUE;
    }
    // Finally lets just equip a weapon since we must not have a shield.
    else if(oRight == OBJECT_INVALID)
    {
        ai_Debug("0i_combat", "2818", GetName(oCreature) + " did not equip a melee weapon");
        return FALSE;
    }
    ai_Debug("0i_combat", "2821", GetName(oCreature) + " is equiping " +
             GetName(oRight) + " in the right hand.");
    ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_EquipBestRangedWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    ai_Debug("0i_combat", "2828", GetName(oCreature) + " is looking for best ranged weapon!");
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
    { nBestType1 = 31; }
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
    ai_Debug("0i_combat", "2864", "nBestType1: " + IntToString(nBestType1) + " nBestType2: " + IntToString(nBestType2) +
           " nAmmo: " + IntToString(nAmmo));
    // Cycle through the inventory looking for a ranged weapon.
    object oItem = GetFirstItemInInventory(oCreature);
    while(oItem != OBJECT_INVALID)
    {
        nType = GetBaseItemType(oItem);
        // Make sure this is a ranged weapon.
        ai_Debug("0i_combat", "2872", "oItem: " + GetName(oItem) + " Ranged Weapon: " +
               Get2DAString("baseitems", "RangedWeapon", nType));
        if(Get2DAString("baseitems", "RangedWeapon", nType) != "")
        {
            nValue = GetGoldPieceValue(oItem);
            // Make sure they are high enough level to equip this item.
            if(nMaxItemValue >= nValue && nValue > 1)
            {
                ai_Debug("0i_combat", "2880", " Creature Size: " + IntToString(GetCreatureSize(oCreature)) +
                       " Weapon Size: " + Get2DAString("baseitems", "WeaponSize", nType) +
                       " Has feat0: " + IntToString(GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat0", nType)))));
                // Make sure they are large enough to use it and have the proficiency.
                if(StringToInt(Get2DAString("baseitems", "WeaponSize", nType)) <= GetCreatureSize(oCreature) + 1 &&
                 (GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat0", nType))) ||
                     GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat1", nType))) ||
                     GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat2", nType))) ||
                     GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat3", nType))) ||
                     GetHasFeat(StringToInt(Get2DAString("baseitems", "ReqFeat4", nType)))))
                {
                    ai_Debug("0i_combat", "2891", "nValue: " + IntToString(nValue) +
                             " nRangedValue: " + IntToString(nRangedValue) + " nType: " + IntToString(nType));
                    // Is it of the best range weapon type? 0 is any range weapon.
                    // Also grab any range weapon until we have a best type.
                    if(nType == nBestType1 || nType == nBestType2 ||
                        nBestType1 == 0 || oRanged == OBJECT_INVALID)
                    {
                        if(nValue > nRangedValue)
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
                            ai_Debug("0i_combat", "2911", "nAmmo: " + IntToString(nAmmo));
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
                                ai_Debug("0i_combat", "2932", "Selecting oRanged: " + GetName(oRanged) +
                                         " nRangedValue: " + IntToString(nRangedValue));
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
        ai_Debug("0i_combat", "2945", GetName(oCreature) + " did not equip a ranged weapon!");
        return FALSE;
    }
    ActionEquipItem(oRanged, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_EquipBestMonkMeleeWeapon(object oCreature, object oTarget = OBJECT_INVALID)
{
    ai_Debug("0i_combat", "2953", GetName(OBJECT_SELF) + " is equiping best monk melee weapon!");
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
        ai_Debug("0i_combat", "2987", GetName(oCreature) + " did not equip a melee weapon!");
        return FALSE;
    }
    ai_Debug("0i_combat", "2990", GetName(oCreature) + " is equiping " + GetName(oRight) + " in the right hand.");
    ActionEquipItem(oRight, INVENTORY_SLOT_RIGHTHAND);
    return TRUE;
}
int ai_GetPercHPLoss(object oCreature)
{
    return(GetCurrentHitPoints(oCreature) * 100) / GetMaxHitPoints(oCreature);
}
int ai_GetIsInvisible(object oCreature)
{
    return (ai_GetHasEffectType(oCreature, EFFECT_TYPE_INVISIBILITY) ||
            ai_GetHasEffectType(oCreature, EFFECT_TYPE_IMPROVEDINVISIBILITY) ||
           (GetHasSpellEffect(SPELL_DARKNESS, oCreature) &&
            GetHasSpellEffect(SPELL_DARKVISION, oCreature)) ||
            GetActionMode(oCreature, ACTION_MODE_STEALTH) ||
            ai_GetHasEffectType(oCreature, EFFECT_TYPE_SANCTUARY) ||
            ai_GetHasEffectType(oCreature, EFFECT_TYPE_ETHEREAL));
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
        ai_Debug("0i_combat", "3052", " nSpellLvl: " + IntToString(nSpellLvl) +
                 " > nMagic: " + IntToString(GetReflexSavingThrow(oCreature)));
        return (nSpellLvl > GetReflexSavingThrow(oCreature));
    }
    else if(sSave == "Fortitude") return (nSpellLvl > GetFortitudeSavingThrow(oCreature));
    else if(sSave == "Will") return (nSpellLvl > GetWillSavingThrow(oCreature));
    return TRUE;
}
int ai_IsInADangerousAOE(object oCreature, float fRange = AI_RANGE_BATTLEFIELD)
{
    int nCnt = 1;
    string sAOEType;
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, oCreature, nCnt);
    float fRadius, fDistance = GetDistanceBetween(oCreature, oAOE);
    while(oAOE != OBJECT_INVALID && fDistance <= fRange)
    {
        // AOE's have the tag set to the "LABEL" in vfx_persistent.2da
        // I check vs those labels to see if the AOE is offensive.
        // Below is the list of Offensive AOE effects.
        sAOEType = GetTag(oAOE);
        if(sAOEType == "VFX_PER_WEB") fRadius = 6.7;
        else if(sAOEType == "VFX_PER_ENTANGLE") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_GREASE") fRadius = 6.0;
        else if(sAOEType == "VFX_PER_EVARDS_BLACK_TENTACLES") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_DARKNESS") fRadius = 6.7;
        else if(sAOEType == "VFX_MOB_SILENCE") fRadius = 4.0;
        else if(sAOEType == "VFX_PER_FOGSTINK") fRadius = 6.7;
        else if(sAOEType == "VFX_PER_FOGFIRE") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_FOGKILL") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_FOGMIND") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_CREEPING_DOOM") fRadius = 6.7;
        else if(sAOEType == "VFX_PER_FOGACID") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_FOGBEWILDERMENT") fRadius = 5.0;
        else if(sAOEType == "VFX_PER_WALLFIRE") fRadius = 10.0;
        else if(sAOEType == "VFX_PER_WALLBLADE") fRadius = 10.0;
        else if(sAOEType == "VFX_PER_DELAY_BLAST_FIREBALL") fRadius = 2.0;
        else if(sAOEType == "VFX_PER_GLYPH") fRadius = 2.5;
        else fRadius = 0.0;
        ai_Debug("0i_combat", "3090", GetName(oCreature) + " distance from AOE is " + FloatToString(fDistance, 0, 2) +
                " AOE Radius: " + FloatToString(fRadius, 0, 2) +
                " AOE Type: " + GetTag(oAOE));
        // fRadius > 0.0 keeps them from tiggering that they are in a dangerous
        // AOE due to having an AOE on them.
        if(fRadius > 0.0 && fDistance <= fRadius) return TRUE;
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
    if(sCombatAI == "" || sCombatAI == "ai_ambusher")
    {
        // Ambusher: requires either Improved Invisibility or Invisibility.
        if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY, oCreature) ||
           GetHasSpell(SPELL_INVISIBILITY, oCreature))
        {
                int bCast = ai_TryToCastSpell(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature);
                if(!bCast) bCast = ai_TryToCastSpell(oCreature, SPELL_INVISIBILITY, oCreature);
                if(bCast)
                {
                    SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_ambusher");
                    SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
                    return;
                }
        }
        // Ambusher: Requires a Hide and Move silently skill equal to your level + 1.
        else if(GetSkillRank(SKILL_HIDE, oCreature) >= nSkillNeeded &&
                 GetSkillRank(SKILL_MOVE_SILENTLY, oCreature) >= nSkillNeeded)
        {
            SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_ambusher");
            SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
            SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
            return;
        }
    }
    // Defensive : requires Parry skill equal to your level or Expertise.
    else if(sCombatAI == "ai_defensive" ||
          (sCombatAI == "" &&
          (GetSkillRank(SKILL_PARRY, oCreature) >= nSkillNeeded ||
              GetHasFeat(FEAT_EXPERTISE, oCreature) ||
              GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature))))
    {
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_defensive");
        return;
    }
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
            else if(nClass == CLASS_TYPE_ANIMAL) sCombatAI = "ai_animal";
            else if(nClass == CLASS_TYPE_CONSTRUCT) sCombatAI = "ai_animal";
            else if(nClass == CLASS_TYPE_DRAGON) sCombatAI = "ai_dragon";
            //else if(nClass == CLASS_TYPE_ELEMENTAL) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_FEY) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_GIANT) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_HUMANOID) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_MAGICAL_BEAST) sCombatAI = "ai_default";
            else if(nClass == CLASS_TYPE_MONSTROUS) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_OOZE) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_OUTSIDER) sCombatAI = "ai_default";
            //else if(nClass == CLASS_TYPE_UNDEAD) sCombatAI = "ai_default";
            else if(nClass == CLASS_TYPE_VERMIN) sCombatAI = "ai_animal";
            else sCombatAI = "ai_default";
        }
    }
    SetLocalString(oCreature, AI_COMBAT_SCRIPT, sCombatAI);
    SetLocalString(oCreature, AI_DEFAULT_SCRIPT, sCombatAI);
}
int ai_IsStrongThanMe(object oCreature, int iIndex)
{
    int nECombat = GetLocalInt(oCreature, AI_ENEMY_COMBAT + IntToString(iIndex));
    int nOCombat = ai_GetMyCombatRating(oCreature);
    ai_Debug("0i_combat", "3215", GetName(oCreature) + " nOCombat: " +
           IntToString(nOCombat) + " nECombat: " + IntToString(nECombat));
    // They are too strong so hold here until next round.
    return (nECombat > nOCombat);
}
int ai_StrongOpponent(object oCreature, object oTarget, int nAdj = 2)
{
    int nLevel = GetHitDice(oCreature);
    ai_Debug("0i_combat", "3223", "ai_StrongOpponent");
    nAdj = nAdj *((nAdj + nLevel) / 10);
    ai_Debug("0i_combat", "3225", "Is the opponent strong? Target CR >= Our level - nAdj(" +
              FloatToString(GetChallengeRating(oTarget), 0, 2) + " >= " + IntToString(nLevel - nAdj) + ")");
    return (FloatToInt(GetChallengeRating(oTarget)) >= nLevel - nAdj);
}
int ai_CanHitOpponent(object oCreature, object oTarget, int nAtkAdj)
{
    int nEAC = GetAC(oTarget);
    int nOAtk = ai_GetCreatureAttackBonus(oCreature);
    // EnemyAC(20) - OurAtk(10 + nAtkAdj) - d10().
    int nRoll = d10();
    ai_Debug("0i_combat", "3235", "My chance to hit [nEAC:(" + IntToString(nEAC) + ") - nOAtk(" +
              IntToString(nOAtk) + ") + nAtkAdj(" + IntToString(nAtkAdj) + ") - nRoll(" +
              IntToString(nRoll) + ") = " + IntToString(nEAC - nOAtk + nAtkAdj - nRoll) + " < 10 || > 19]");
    nOAtk = nEAC - nOAtk + nAtkAdj - nRoll;
    // Use it if we must roll a 20 to hit! No loss % to hit at with this.
    // or if our chance is 55% or better to hit on avg roll.
    return (nOAtk < 10 || nOAtk > 19);
}
int ai_EnemyCanHitMe(object oCreature, object oTarget)
{
    int nOAC = GetAC(oCreature);
    int nEAtk = ai_GetCreatureAttackBonus(oTarget);
    // OurAC(20) - EnemyAtk(5) < 20
    ai_Debug("0i_combat", "3248", "Enemies roll needed to hit [nOAC(" + IntToString(nOAC) + ") - nEAtk(" +
              IntToString(nEAtk) + ") = " +
              IntToString(nOAC - nEAtk) + " < 20]");
    // Return TRUE if they need less than a 20 to hit.
    return (nOAC - nEAtk < 20);
}
int ai_CanIMoveInCombat(object oCreature)
{
    return (GetHasFeat(FEAT_MOBILITY, oCreature) || GetHasFeat(FEAT_SPRING_ATTACK, oCreature) ||
            GetSkillRank(SKILL_TUMBLE, oCreature) > ai_GetCharacterLevels(oCreature));
}
int ai_CanIUseRangedWeapon(object oCreature, int nInMelee)
{
    return ((!nInMelee || (nInMelee == 1 && GetHasFeat(FEAT_POINT_BLANK_SHOT, oCreature))) &&
           (ai_HasRangedWeaponWithAmmo(oCreature) || ai_EquipBestRangedWeapon(oCreature)));
}
void ai_SetAssociateCombatEventScripts(object oCreature)
{
    if(GetLocalString(oCreature, AI_EVENT_SCRIPT_1) != "") return;
    // Set associates battle heartbeat script (1).
    string sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_1, sEventScript);
    ai_Debug("0i_combat", "3270", GetName(oCreature) + " is saving EVENT_SCRIPT_CREATURE_ON_HEARTBEAT " +
             sEventScript + " for combat.");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, AI_ASSOCIATE_BATTLE_SCRIPT_1);
    // Set associates battle perception script (2).
    sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_2, sEventScript);
    ai_Debug("0i_combat", "3276", GetName(oCreature) + " is saving EVENT_SCRIPT_CREATURE_ON_NOTICE " +
             sEventScript + " for combat.");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, AI_ASSOCIATE_BATTLE_SCRIPT_2);
    // Set associates battle dialogue script (4).
    sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_4, sEventScript);
    ai_Debug("0i_combat", "3282", GetName(oCreature) + " is saving EVENT_SCRIPT_CREATURE_ON_DIALOGUE " +
             sEventScript + " for combat.");
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, AI_ASSOCIATE_BATTLE_SCRIPT_4);
}
void ai_SetMonsterCombatEventScripts(object oCreature)
{
    ai_Debug("0i_combat", "3288", GetName(oCreature) + " is setting EVENT_SCRIPTS for combat.");
    if(GetLocalString(oCreature, AI_EVENT_SCRIPT_1) != "") return;
    // Set monsters battle heartbeat script (1).
    string sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_1, sEventScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, AI_MONSTER_BATTLE_SCRIPT_1);
    // Set associates battle perception script (2).
    sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_2, sEventScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, AI_MONSTER_BATTLE_SCRIPT_2);
    // Set monsters battle dialogue script (4).
    sEventScript = GetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE);
    SetLocalString(oCreature, AI_EVENT_SCRIPT_4, sEventScript);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, AI_MONSTER_BATTLE_SCRIPT_4);
}
void ai_RestoreNonCombatEventScripts(object oCreature)
{
    // Restore creatures default heartbeat script (1).
    string sEventScript = GetLocalString(oCreature, AI_EVENT_SCRIPT_1);
    if(sEventScript == "") return;
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, sEventScript);
    ai_Debug("0i_combat", "3309", "Restoring EVENT_SCRIPT_CREATURE_ON_HEARTBEAT to " + sEventScript);
    // Restore creatures default perception[NOTICE] script (1).
    sEventScript = GetLocalString(oCreature, AI_EVENT_SCRIPT_2);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_NOTICE, sEventScript);
    ai_Debug("0i_combat", "3313", "Restoring EVENT_SCRIPT_CREATURE_ON_NOTICE to " + sEventScript);
    // Restore creatures default perception[NOTICE] script (1).
    sEventScript = GetLocalString(oCreature, AI_EVENT_SCRIPT_4);
    SetEventScript(oCreature, EVENT_SCRIPT_CREATURE_ON_DIALOGUE, sEventScript);
    ai_Debug("0i_combat", "3317", "Restoring EVENT_SCRIPT_CREATURE_ON_DIALOGUE to " + sEventScript);
    DeleteLocalString(oCreature, AI_EVENT_SCRIPT_1);
    DeleteLocalString(oCreature, AI_EVENT_SCRIPT_2);
    DeleteLocalString(oCreature, AI_EVENT_SCRIPT_4);
}
int ai_GetHealersHpLimit(object oCreature)
{
    // Monsters need a bit more lead time to get a healing spell off.
    if(GetAssociateType(oCreature) == ASSOCIATE_TYPE_NONE) return 60;
    else
    {
        // Check for Associate rules.
        if(ai_GetAssociateMode(oCreature, AI_MODE_HEAL_AT_25)) return 25;
        else if(ai_GetAssociateMode(oCreature, AI_MODE_HEAL_AT_75)) return 75;
    }
    return 50;
}
int ai_CheckRangedCombatPosition(object oCreature, object oTarget, int nAction)
{
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    ai_Debug("0i_combat", "3337", "oNearestEnemy: " + GetName(oNearestEnemy) +
             " fDistance: " + FloatToString(GetDistanceBetween(oCreature, oNearestEnemy), 0, 2));
    if(nAction == AI_LAST_ACTION_RANGED_ATK)
    {
        float fNearestEnemyDistance = GetDistanceBetween(oCreature, oNearestEnemy);
        float fTargetDistance = GetDistanceBetween(oCreature, oTarget);
        ai_Debug("0i_combat", "3343", " oTarget: " + GetName(oTarget) + " fDistance " + FloatToString(fTargetDistance, 0, 2) +
                 " oNearestEnemy: " + GetName(oNearestEnemy) + " fDistance " + FloatToString(fNearestEnemyDistance, 0, 2));
        float fDistance;
        if(fNearestEnemyDistance < fTargetDistance) fDistance = fNearestEnemyDistance;
        else fDistance = fTargetDistance;
        // If we have sneak attack then we need to be within 30'.
        if(GetHasFeat(FEAT_SNEAK_ATTACK, oCreature))
        {
            if(fDistance > AI_RANGE_CLOSE)
            {
                ActionMoveToObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
                ai_Debug("0i_combat", "3354", GetName(oCreature) + " is moving closer to " + GetName(oNearestEnemy) + " to sneak attack with a ranged weapon.");
                return TRUE;
            }
            else
            {
                ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
                ai_Debug("0i_combat", "3360", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) + " to sneak attack with a ranged weapon.");
                return TRUE;
            }
        }
        else
        {
            if(fDistance < AI_RANGE_CLOSE)
            {
                ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
                ai_Debug("0i_combat", "3369", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) + " to use a ranged weapon.");
                return TRUE;
            }
        }
    }
    //************ This will make them drop out of combat and not cast the spell.
    //************ Need to work on this.
    // If we are casting a hostile spell then check positioning.
    else if(nAction > -1 && Get2DAString("ai_spells", "HostileSetting", nAction) == "1")
    {
        float fSpellRange = ai_GetSpellRange(nAction);
        float fTargetRange = GetDistanceBetween(oCreature, oTarget);
        ai_Debug("0i_combat", "3381", "fSpellRange: " + FloatToString(fSpellRange, 0, 2) +
                 " fTargetRange: " + FloatToString(fTargetRange, 0, 2));
        // Adjust the ranges to see if we are too close.
        if(fSpellRange == 5.0) fSpellRange = 4.5f;
        //else if(fSpellRange == 8.0) fSpellRange = 7.5f;
        //else if(fSpellRange == 20.0f) fSpellRange = 15.0f;
        //else if(fSpellRange == 40.0f) fSpellRange = 15.0f;
        else if(fSpellRange > 7.0f) fSpellRange = 7.5f;
        ai_Debug("0i_combat", "3389", "Adjusted spell range is " +
                 FloatToString(fSpellRange, 0, 2) + " : " + GetName(oTarget) + " range is " +
                 FloatToString(fTargetRange, 0, 2) + ".");
        // We are closer than we have to be to cast our spell.
        if(fTargetRange < fSpellRange)
        {
            ActionMoveAwayFromObject(oTarget, TRUE, fSpellRange);
            ai_Debug("0i_combat", "3396", GetName(oCreature) + " is moving away from " +
                     GetName(oTarget) + " to cast a spell.");
            return TRUE;
        }
    }
    return FALSE;
}
int ai_CheckMeleeCombatPosition(object oCreature, object oTarget, int nAction)
{
    // If we are not being attacked then we might want to back out of combat.
    if(ai_GetEnemyAttackingMe(oCreature) != OBJECT_INVALID)
    {
        ai_Debug("0i_combat", "3408", "I am being attacked so stand my ground!");
        return FALSE;
    }
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    if(nAction == AI_LAST_ACTION_RANGED_ATK)
    {
        ai_Debug("0i_combat", "3414", "oNearestEnemy: " + GetName(oNearestEnemy) + " fDistance " + FloatToString(GetDistanceToObject(oNearestEnemy), 0, 2));
        ai_Debug("0i_combat", "3415", GetName(oCreature) + " is moving away from " + GetName(oNearestEnemy) + " to use a ranged weapon.");
        ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_CLOSE);
        return TRUE;
    }
    //********* This tends to have them drop out of combat and not cast the spell!!
    //********* Need to work on it.
    // If we cast a spell this round then back away!
    else if(nAction > -1)
    {
        float fSpellRange = ai_GetSpellRange(nAction);
        if(fSpellRange == 5.0) fSpellRange = 4.5f;
        //else if(fSpellRange == 8.0) fSpellRange = 7.5f;
        //else if(fSpellRange == 20.0f) fSpellRange = 15.0f;
        //else if(fSpellRange == 40.0f) fSpellRange = 15.0f;
        else if(fSpellRange > 7.0f) fSpellRange = 7.5f;
        ai_Debug("0i_combat", "3430", GetName(oCreature) + " is moving away from " +
                 GetName(oTarget) + "[" + FloatToString(fSpellRange, 0, 2) + "] to cast a spell.");
        ai_ClearCreatureActions(oCreature);
        ActionMoveAwayFromObject(oTarget, TRUE, fSpellRange);
        return TRUE;
    }
    return FALSE;
}
int ai_CheckCombatPosition(object oCreature, object oTarget, int nInMelee, int nAction)
{
    ai_Debug("0i_combat", "3440", "|-----> Checking position in combat: " +
             GetName(oCreature) + " nMelee: " + IntToString(nInMelee) +
             " Action: " + IntToString(nAction));
    // We are not in melee combat so lets see how close we should get.
    if(!nInMelee) return ai_CheckRangedCombatPosition(oCreature, oTarget, nAction);
    // If we are in melee we might need to move out of combat.
    return ai_CheckMeleeCombatPosition(oCreature, oTarget, nAction);
}
