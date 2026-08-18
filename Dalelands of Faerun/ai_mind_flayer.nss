/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_mind_flayer
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for Mind Flayers. OBJECT_SELF is the creature running the ai.
 To use this AI set the variable string "DEFAULT_AI_SCRIPT" to "ai_mind_flayer" on the creature.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
/*#include "0i_actions"
//#include "0i_actions_debug"
#include "0i_psionics"
void DoActions ()
{
    // Get the number of enemies that we are in melee combat with.
    int nMelee = GetNumOfEnemiesInMelee ();
    object oNearestEnemy = GetLocalObject (OBJECT_SELF, ENEMY_NEAREST);
    //Debug ("ai_mind_flayer", "17", "*************** " + GetName (OBJECT_SELF) + " ***************");
    //Debug ("ai_mind_flayer", "18", "oNearest Enemy: " + GetName (oNearestEnemy) +
    //       " Distance to Nearest Enemy: " + FloatToString (GetDistanceToObject (oNearestEnemy), 0, 2) +
    //       " Melee: " + IntToString (nMelee));
    //Debug ("ai_mind_flayer", "21", "***************** CHOOSING MIND FLAYER ACTIONS ****************");
    //**************************************************************************
    //* 1) Check for healing conditions, and moral.
    //**************************************************************************
    if (TryHealingTalents (nMelee)) return;
    if (TryHealingPotionTalents (nMelee)) return;
    if (TryCureConditionTalents (nMelee)) return;
    if (MoralCheck (5 - GetLocalInt (OBJECT_SELF, ALLY_NUMBERS), GetLocalObject (OBJECT_SELF, ENEMY_NEAREST))) return;
    //**************************************************************************
    //********************* MIND FLAYER AI *************************************
    //**************************************************************************
    // Get the nearest creature and see if they are disabled so we can eat!
    // If disabled then lets go in for the kill.
    if (GetHasEffect (EFFECT_TYPE_DAZED, oNearestEnemy) ||
        GetHasEffect (EFFECT_TYPE_PARALYZE, oNearestEnemy) ||
        GetHasEffect (EFFECT_TYPE_SLEEP, oNearestEnemy) ||
        GetHasEffect (EFFECT_TYPE_STUNNED, oNearestEnemy))
    {
        //Debug ("ai_mind_flayer", "93", GetName (OBJECT_SELF) + " is attempting to sucking " + GetName (oNearestEnemy) + "'s brain!");
        ActionCastSpellAtObject (716/*SuckBrain*//*, oNearestEnemy, 255, TRUE);
        return;
    }
    // Monsters should use either the best spell they have or a random spell so
    // they all don't look robotic. So lets mix it up 30% of the time.
    int nSpellLevel = 20;
    if (d100() > 70) nSpellLevel = -1;
    //**************************************************************************
    //* 2) Control Spells.
    //**************************************************************************
    // Check the battlefield for a group of enemies to shoot a big spell at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if (TryHarmfulAOEIndiscriminantTalents (nMelee, nSpellLevel)) return;
    if (TryHarmfulAOEDiscriminantTalents (RANGE_PERCEPTION, nMelee, nSpellLevel)) return;
    //**************************************************************************
    //* 3) Protection, Enhancement, & Summon Allies.
    //**************************************************************************
    / Make an intelligence check vs DC 10 (Avg) to use the Advanced a.i. functions.
    if (d20() + GetAbilityModifier (ABILITY_INTELLIGENCE) > 10)
    {
        //Debug ("ai_ranged", "47", "Lets help ourself (smart)!");
        if (TryAdvancedBuffOnSelf (nMelee)) return;
    }
    //Debug ("ai_mind_flayer", "50", "Lets help ourself (normal) Level: " +
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
    if (nMelee > 0)
    {
        // Look for a touch attack since we are in melee.
        if (TryHarmfulTouchTalents (nMelee, nSpellLevel)) return;
    }
    if (TryMagicOnRangedAttacker (nMelee, nSpellLevel)) return;
    if (TryHarmfulRangedTalents (RANGE_PERCEPTION, nMelee, nSpellLevel)) return;
    // Mind flayers try to stun opponents from a distance before moving in to kill.
    // also lets not spam this either.
    if (!nMelee && !CompareLastAction (551))
    {
        // Lets try to stun as many opponents as we can.
        // Lets see if we can find a creature with the most enemies around them.
        string sIndex = IntToString (GetHighestMeleeTargetNotInAOE ());
        object oTarget = GetLocalObject (OBJECT_SELF, ENEMY + sIndex);
        //Debug ("ai_mind_flayer", "104", GetName (OBJECT_SELF) + " is using mind blast on " + GetName (oTarget) + "!");
        ActionCastSpellAtObject (551/*Psionic_Mind_Blast, oTarget);
        SetLastAction (551);
        return;
    }
    //**************************************************************************
    //* PHYSICAL ATTACKS - Either we don't have magic or we are saving our magic.
    //**************************************************************************
    // If this is an effortless battle then lets not waste our talents.
    // If we got here, we're going to use a physical attack (Ranged/Melee).
    //Debug ("ai_mind_flayer", "113", "Lets use an attack!");
    // Physical attacks are under TALENT_CATEGORY_HARMFUL_MELEE (22).
/*    DoPhysicalAttackOnNearest (nMelee);
}
void CheckMindFlayerMovement ()
{
    int nMelee = GetNumOfEnemiesInMelee ();
    object oNearestEnemy = GetNearestEnemy (OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    //Debug ("ai_mind_flayer", "124", "Checkmovement: nMelee: " + IntToString (nMelee) +
    //       " NearestEnemy: " + GetName (oNearestEnemy));
    //**************************************************************************
    //* Stay out of melee if we can.
    //**************************************************************************
    // If we are not in melee then stay out of it!
    if (!nMelee)
    {
        // Stay 8 meters or 26' away from our nearest enemy.
        // Lets not be annoying! If we try 2 times then give up and go into melee.
        float fRange = 8.0f;
        if (oNearestEnemy != OBJECT_INVALID &&
            GetDistanceToObject (oNearestEnemy) < fRange)
        {
            int nFlee = GetLocalInt (OBJECT_SELF, "0_FLEEING");
            if (nFlee < 2)
            {
                SetLocalInt (OBJECT_SELF, "0_FLEEING", ++nFlee);
                //Debug ("ai_mind_flayer", "142", GetName (OBJECT_SELF) +
                //       " is too close to " + GetName (oNearestEnemy) + ", we are moving back (" +
                //       IntToString (nFlee) + ")!");
                ActionMoveAwayFromObject (oNearestEnemy, TRUE, fRange);
            }
        }
    }
} */
void main ()
{
    //DoActions ();
    //ActionDoCommand (CheckMindFlayerMovement ());
}
