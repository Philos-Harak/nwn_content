/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_warmage
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for creatures using the class Warmage.
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
    //Debug ("ai_warmage", "16", "*************** " + GetName (OBJECT_SELF) + " ***************");
    //Debug ("ai_warmage", "17", "oNearest Enemy: " + GetName (oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2) +
    //       " Melee: " + IntToString (nMelee));
    //Debug ("ai_warmage", "20", "************* CHOOSING WARMAGE ACTIONS ***********");
    // Get the number of enemies that we are in melee combat with.
    if (TryHealingPotionTalents (nMelee)) return;
    if (MoralCheck (5 - GetLocalInt (OBJECT_SELF, ALLY_NUMBERS), GetLocalObject (OBJECT_SELF, ENEMY_NEAREST))) return;
    //**************************************************************************
    //* 3) AOE Control spells.
    //**************************************************************************
    // Monsters should use either the best spell they have or a random spell so
    // they all don't look robotic. So lets mix it up 30% of the time.
    int nSpellLevel = 20;
    if (d100() > 70) nSpellLevel = -1;
    // Check the battlefield for a group of enemies to shoot a big spell at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if (TryHarmfulAOEIndiscriminantTalents (nMelee, nSpellLevel)) return;
    if (TryHarmfulAOEDiscriminantTalents (RANGE_PERCEPTION, nMelee, nSpellLevel)) return;
    //**************************************************************************
    //* 3) Protection, Enhancement, & Summon Allies.
    //**************************************************************************
    // Make an intelligence check vs DC 10 (Avg) to use the Advanced a.i. functions.
    /*if (d20() + GetAbilityModifier (ABILITY_INTELLIGENCE) > 10)
    {
        //Debug ("ai_warmage", "42", "Lets help ourself (smart)!");
        if (TryAdvancedBuffOnSelf (nMelee)) return;
    }
    //Debug ("ai_warmage", "45", "Lets help ourself (normal) Level: " +
    //       IntToString (nSpellLevel) + "!");
    int nRoll = d6();
    if (nRoll < 3)
    {
        if (TryProtectionTalents (nMelee, nSpellLevel)) return;
        if (TryEnhancementTalents (nMelee, nSpellLevel)) return;
        if (TrySummonAlliesTalents (nMelee, nSpellLevel)) return;
    }
    else if (nRoll < 5)
    {
        if (TryEnhancementTalents (nMelee, nSpellLevel)) return;
        if (TrySummonAlliesTalents (nMelee, nSpellLevel)) return;
        if (TryProtectionTalents (nMelee, nSpellLevel)) return;
    }
    else
    {
        if (TrySummonAlliesTalents (nMelee, nSpellLevel)) return;
        if (TryProtectionTalents (nMelee, nSpellLevel)) return;
        if (TryEnhancementTalents (nMelee, nSpellLevel)) return;
    }
    // All else fails lets see if we have any good potions.
    if (TryBuffSelfWithPotionTalents (nMelee)) return;
    //**************************************************************************
    //* 4) Offensive spells.
    //**************************************************************************
    //Debug ("ai_warmage", "71", "nSpellLevel: " + IntToString (nSpellLevel));
    if (nMelee > 0)
    {
        // Look for a touch attack since we are in melee.
        if (TryHarmfulTouchTalents (nMelee, nSpellLevel)) return;
    }
    //if (TryMagicOnRangedAttacker (nMelee, nSpellLevel)) return;
    if (TryHarmfulRangedTalents (RANGE_PERCEPTION, nMelee, nSpellLevel)) return;
    //**************************************************************************
    //* 5) PHYSICAL ATTACKS - Check for ranged then melee attack.
    //**************************************************************************
    //Debug ("ai_warmage", "82", "Lets use an attack!");
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
            //Debug ("ai_warmage", "99", "Do ranged attack on " + GetName (oTarget) + "!");
            SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
            SetLastAction (LAST_ACTION_RANGED_ATK);
            ActionAttack (oTarget, TRUE);
            return;
        }
    }
    // ************************** Melee feat attacks *************************
    if (!GetIsMeleeWeapon (GetItemInSlot (INVENTORY_SLOT_RIGHTHAND))) EquipBestMeleeWeapon (oTarget);
    if (TrySneakAttack (nMelee)) return;
    oTarget = GetNearestTargetForMeleeCombat (nMelee);
    if (oTarget != OBJECT_INVALID)
    {
        //Debug ("ai_warmage", "111", "Do melee attack against " + GetName (oTarget) + "!");
        SetLocalObject (OBJECT_SELF, "0_ATTACKED_TARGET", oTarget);
        SetLastAction (LAST_ACTION_MELEE_ATK);
        ActionAttack (oTarget);
    }
}
void main ()
{
    DoActions ();
    ActionDoCommand (CheckCombatMovement ());
}
