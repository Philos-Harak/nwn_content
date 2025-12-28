/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_sbuckler
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
    // Get the number of enemies that we are in melee combat with.
    int nMelee = GetNumOfEnemiesInMelee ();
    //object oNearestEnemy = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    //Debug ("ai_sbuckler", "16", "*************** " + GetName (OBJECT_SELF) + " ***************");
    //Debug ("ai_sbuckler", "17", "oNearest Enemy: " + GetName (oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2) +
    //       " Melee: " + IntToString (nMelee));
    //Debug ("ai_sbuckler", "20", "************* CHOOSING SWASHBUCKLER ACTIONS ***********");
    if (TryHealingPotionTalents (nMelee)) return;
    if (MoralCheck (5 - GetLocalInt (OBJECT_SELF, ALLY_NUMBERS), GetLocalObject (OBJECT_SELF, ENEMY_NEAREST))) return;
    if (TryBuffSelfWithPotionTalents (nMelee)) return;
    //**************************************************************************
    //* PHYSICAL ATTACKS - Check for ranged then melee attack.
    //**************************************************************************
    //Debug ("ai_sbuckler", "27", "Lets use an attack!");
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if (!GetHasFeatEffect (FEAT_BARBARIAN_RAGE) &&
       (!nMelee || (nMelee == 1 && GetHasFeat (FEAT_POINT_BLANK_SHOT))))
    {
        if (HasRangedWeaponWithAmmo (OBJECT_SELF) || EquipBestRangedWeapon ())
        {
            if (TryRangedSneakAttack (nMelee)) return;
            string sIndex;
            // Lets pick off the nearest targets.
            if (!nMelee) sIndex = IntToString (GetNearestCreatureTarget ());
            else sIndex = IntToString (GetNearestCreatureTarget (RANGE_MELEE));
            oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
            if (TryScatterShotFeat (nMelee, oTarget)) return;
            if (TryRapidShotFeat (oTarget)) return;
            //Debug ("ai_sbuckler", "43", "Do ranged attack on " + GetName (oTarget) + "!");
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
                //Debug ("ai_sbuckler", "74", "Using parry against " + GetName (oEnemy) + "!");
                return;
            }
        }
        if (TryImprovedExpertiseFeat (oTarget)) return;
        if (TryExpertiseFeat (oTarget)) return;
        //Debug ("0i_ass_sbuckler", "80", "Do melee attack against " + GetName (oTarget) + "!");
        SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
        ActionAttack (oTarget);
    }
}
void main ()
{
    DoActions ();
    ActionDoCommand (CheckCombatMovement ());
}
