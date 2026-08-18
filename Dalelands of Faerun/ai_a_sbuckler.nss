/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_ass_sbuckler
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Swashbuckler.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
/*#include "0i_actions"
//#include "0i_actions_debug"
void DoActions ()
{
    // nDifficulty is (Enemy level - Ally level).
    //     15+    : Impossible - We need to get away.
    //  11 to  14 : Deadly     - If we are wounded we might want to flee, use all our power.
    //   6 to  10 : Hard       - Make sure we are using most of our powers.
    //   0 to   5 : Difficult  - Use some power but don't go over board.
    //  -5 to  -1 : Easy       - Use some power but don't go over board.
    // -10 to  -6 : Simple     - Use our weaker powers.
    // -14 to -11 : Effortless - Don't waste spells and powers on this.
    //    -15 -   : Pointless  - We probably should ignore these dangers.
    int nDifficulty = GetLocalInt (OBJECT_SELF, ENEMY_POWER) - GetLocalInt (OBJECT_SELF, ALLY_POWER);
    // Lets randomize the Difficulty so our results may vary -5 to 5 on a small bell curve.
    nDifficulty += d6(2) - 7;
    // Get the number of enemies that we are in melee combat with.
    int nMelee = GetNumOfEnemiesInMelee ();
    //object oNearestEnemy = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    //Debug ("0i_ass_sbuckler", "28", "oNearest Enemy: " + GetName (oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2) +
    //       " Melee: " + IntToString (nMelee));
    //Debug ("0i_ass_sbuckler", "31", "Difficulty: " + IntToString (nDifficulty) +
    //       " Enemy Power: " + IntToString (GetLocalInt (OBJECT_SELF, ENEMY_POWER)) +
    //       " Ally Power: " + IntToString (GetLocalInt (OBJECT_SELF, ALLY_POWER)));
    //Debug ("0i_ass_sbuckler", "34", "************* CHOOSING ASSOCIATE SWASHBUCKLER ACTIONS ***********");
    if (TryHealingPotionTalents (nMelee)) return;
    if (nDifficulty >= COMBAT_SIMPLE)
    {
        if (MoralCheck (nDifficulty, GetLocalObject (OBJECT_SELF, ENEMY_NEAREST))) return;
    }
    if (nDifficulty >= COMBAT_DIFFICULT) if (TryBuffSelfWithPotionTalents (nMelee)) return;
    //**************************************************************************
    //* PHYSICAL ATTACKS - Check for ranged then melee attack.
    //**************************************************************************
    //Debug ("0i_ass_sbuckler", "44", "Lets use an attack!");
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if (!GetAssociateMode (MODE_STOP_RANGED) &&
        !GetHasFeatEffect (FEAT_BARBARIAN_RAGE) &&
       (!nMelee || (nMelee == 1 && GetHasFeat (FEAT_POINT_BLANK_SHOT))))
    {
        if (HasRangedWeaponWithAmmo (OBJECT_SELF) || EquipBestRangedWeapon ())
        {
            if (TryRangedSneakAttack (nMelee)) return;
            string sIndex;
            // Lets pick off the weaker targets.
            if (!nMelee) sIndex = IntToString (GetLowestCombatRating ());
            else sIndex = IntToString (GetLowestCombatRating (RANGE_MELEE));
            oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
            if (TryScatterShotFeat (nMelee, oTarget)) return;
            if (TryRapidShotFeat (oTarget)) return;
            //Debug ("0i_ass_sbuckler", "61", "Do ranged attack on " + GetName (oTarget) + "!");
            SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
            ActionAttack (oTarget, TRUE);
            return;
        }
    }
    // ************************** Melee feat attacks *************************
    if (!GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND))) EquipBestMeleeWeapon (oTarget);
    if (TryWhirlwindFeat ()) return;
    if (TrySneakAttack (nMelee)) return;
    oTarget = GetWeakestTargetForMeleeCombat (nMelee);
    if (oTarget != OBJECT_INVALID)
    {
        if (TryHarmfulMeleeTalent (oTarget)) return;
        // Only use parry on an active melee attacker
        object oEnemy = GetLastHostileActor();
        if (oEnemy != OBJECT_INVALID &&
            GetAttackedTarget (oEnemy) == OBJECT_SELF &&
            GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oEnemy)))
        {
            // Only if our parry skill > their attack bonus + 5 + d10
            // Parry has a -4 atk adjustment. Our chance to hit should be 75% + d10.
            // EnemyAtk (20) - OurParrySkill (10) = 0 + d10 (75% to 25% chance to hit).
            int nParrySkill = GetSkillRank (SKILL_PARRY);
            int nAtk = NWNX_Creature_GetAttackBonus (oEnemy);
            if (nAtk - nParrySkill < 0 + d10())
            {
                if (!GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND))) EquipBestMeleeWeapon (oEnemy);
                SetActionMode (OBJECT_SELF, ACTION_MODE_PARRY, TRUE);
                SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
                ActionAttack (oEnemy);
                //Debug ("0i_ass_sbuckler", "92", "Using parry against " + GetName (oEnemy) + "!");
                return;
            }
        }
        if (TryImprovedExpertiseFeat (oTarget)) return;
        if (TryExpertiseFeat (oTarget)) return;
        //Debug ("0i_ass_sbuckler", "98", "Do melee attack against " + GetName (oTarget) + "!");
        SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
        ActionAttack (oTarget);
    }
}
void main ()
{
    DoActions ();
    ActionDoCommand (CheckCombatMovement ());
}*/
void main()
{
}