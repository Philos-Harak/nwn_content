/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: ai_a_polymorphed
//////////////////////////////////////////////////////////////////////////////////////////////////////
 ai script for polymorphed associates.
 We check for abilities based on the form we are using and if we should polymorph back.
 OBJECT_SELF is the creature running the ai.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
void ai_DoActions(object oCreature, int nForm)
{
    ai_Debug("ai_a_polymorphed", "14", GetName(oCreature) + " using ai_a_polymorphed.");
    // Get the number of enemies that we are in melee combat with.
    int nInMelee = ai_GetNumOfEnemiesInRange(oCreature);
    // Has our master told us to not use magic?
    int bUseMagic = !ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    // ALWAYS - Check for healing, if we are wounded transform back so we can heal!
    if(GetPercentageHPLoss(oCreature) <= AI_HEALTH_BLOODY)
    {
        ai_Debug("ai_a_polymorphed", "23", "We are wounded and are transforming back!");
        ai_RemoveASpecificEffect(oCreature, EFFECT_TYPE_POLYMORPH);
        return;
    }
    int nDifficulty = ai_GetDifficulty(oCreature);
    // Moral Checks will be done in normal form since we change back when wounded.
    //if(nDifficulty >= AI_COMBAT_EFFORTLESS && ai_MoralCheck(oCreature)) return;
    int nSpell;
    object oTarget;
    // DIFFICULT+ -Offensive AOE's and Defensive talents.
    if(nDifficulty >= AI_COMBAT_MODERATE && bUseMagic)
    {
        // Check the battlefield for a group of enemies to shoot a big talent at!
        // We are checking here since these opportunities are rare and we need
        // to take advantage of them as often as possible.
        if(nForm == APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE || nForm == APPEARANCE_TYPE_RAKSHASA_TIGER_MALE)
        {
            // Ice Storm
            if(!ai_CompareLastAction(oCreature, SPELL_ICE_STORM))
            {
                string sIndex = IntToString(ai_GetHighestMeleeIndex(oCreature));
                int nGroup = GetLocalInt(oCreature, AI_ENEMY_MELEE + sIndex);
                if(nGroup > 1)
                {
                    object oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                    if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
                    if(!ai_CreatureImmuneToEffect(oCreature, oTarget, SPELL_ICE_STORM))
                    {
                        nSpell = SPELL_ICE_STORM;
                    }
                }
            }
        }
        // ****************** PROTECTION/ENHANCEMENT TALENTS *******************
        if(nForm == APPEARANCE_TYPE_SPECTRE || nForm == APPEARANCE_TYPE_VAMPIRE_FEMALE ||
            nForm == APPEARANCE_TYPE_VAMPIRE_MALE || nForm == 302/*APPERANCE_TYPE_KOBOLD*/ ||
            nForm == APPEARANCE_TYPE_WILL_O_WISP)
        {
            if(ai_TryToBecomeInvisible(oCreature)) return; // Unlimited invisibility.
        }
        else if(nForm == 413/*APPEARANCE_TYPE_MINDFLAYER*/)
        {
            // Psionic Inertial barrier: x2_s1_psibarr(741)
            // Psionic mage armor.
            if(!GetHasSpellEffect(741/*SPELLABILITY_INERTIAL_BARRIER*/, oCreature) &&
               !ai_CompareLastAction(oCreature, 741/*SPELLABILITY_INERTIAL_BARRIER*/))
            {
                nSpell = 741/*SPELLABILITY_INERTIAL_BARRIER*/;
                oTarget = oCreature;
            }
        }
        if (nSpell != 0)
        {
            ai_SetLastAction(oCreature, nSpell);
            ActionCastSpellAtObject(nSpell, oTarget, 0, TRUE);
            return;
        }
    }
    // SIMPLE+ - Use Offensive talents 30% of the time.
    if(nDifficulty >= AI_COMBAT_EFFORTLESS && bUseMagic && d100() < 31)
    {
        if(nForm == APPEARANCE_TYPE_ELEMENTAL_AIR || nForm == APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER)
        {
            // Pulse Whirlwind: NW_S1_PulsWind(283)
            // All those that fail a save of DC 14 are knocked down and take d3(hitdice/2) damage.
            // We need more than one enemy near us to make this usefull.
            if(nInMelee > 1)
            {
                // Make sure there are no allies within the spell effect.
                oTarget = ai_GetNearestAlly (oCreature);
                if(GetDistanceToObject(oTarget) > RADIUS_SIZE_LARGE &&
                   !ai_CompareLastAction(oCreature, SPELLABILITY_PULSE_WHIRLWIND))
                {
                    nSpell = SPELLABILITY_PULSE_WHIRLWIND;
                    oTarget = oCreature;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_ELEMENTAL_WATER || nForm == APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER)
        {
            // Pulse Drown: NW_S1_PulsDrwn(281)
            // We need more than one enemy near us to make this usefull.
            if(nInMelee > 1)
            {
                // Make sure there are no allies within the spell effect.
                oTarget = ai_GetNearestAlly (oCreature);
                if(GetDistanceBetween(oCreature, oTarget) > RADIUS_SIZE_LARGE &&
                   !ai_CompareLastAction(oCreature, SPELLABILITY_PULSE_DROWN))
                {
                    nSpell = SPELLABILITY_PULSE_DROWN;
                    oTarget = oCreature;
               }
            }
        }
        else if(nForm == APPEARANCE_TYPE_MANTICORE)
        {
            if(!ai_CompareLastAction(oCreature, SPELLABILITY_MANTICORE_SPIKES))
            {
                // Manticore spikes: x0_s1_MantSpike(498)
                // Shoots a number of spikes that do damage on hit.
                string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature));
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                nSpell = SPELLABILITY_MANTICORE_SPIKES;
            }
        }
        else if(nForm == 491/*APPEARANCE_TYPE_HARPY*/)
        {
            if(!ai_CompareLastAction(oCreature, 686/*SPELLABILITY_HARPY_SONG*/))
            {
                // Harpy song: X2_S1_harpycry(686)
                // Charms enemies DC 15 + shifter levels.
                oTarget = ai_GetHighestCRTarget (oCreature);
                int nWillSave = GetWillSavingThrow(oTarget);
                int nDC = GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) + d10() - 5;
                if(nDC > nWillSave)
                {
                    nSpell = 686/*SPELLABILITY_HARPY_SONG*/;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_BASILISK || nForm == APPEARANCE_TYPE_MEDUSA)
        {
            if(!ai_CompareLastAction(oCreature, 687/*SPELLABILITY_PETRIFICATION*/))
            {
                // Petrification gaze: x0_s1_PetrGaze(687)
                // Fort save or be petrified DC 15.
                oTarget = ai_GetLowestCRTarget (oCreature);
                int nFortSave = GetFortitudeSavingThrow(oTarget);
                int nDC = d10() + 5;
                if(nDC > nFortSave)
                {
                    nSpell = 687/*SPELLABILITY_PETRIFICATION*/;
                }
            }
        }
        else if(nForm == 413/*APPEARANCE_TYPE_MINDFLAYER*/)
        {
            if(!ai_CompareLastAction(oCreature, 713/*SPELLABILITY_MIND_BLAST*/))
            {
                // Mind Flayer Mind blast: x2_s1_mblast10(713)
                // Psionice wave that stuns enemies and may do damage within 10 meters.
                int nEnemies = ai_GetNumOfEnemiesInGroup(oCreature, 10.0f);
                if(nEnemies >= d4())
                {
                    nSpell = 713/*SPELLABILITY_MIND_BLAST*/;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_VAMPIRE_FEMALE || nForm == APPEARANCE_TYPE_VAMPIRE_MALE)
        {
            if(!ai_CompareLastAction(oCreature, 687/*SPELLABILITY_DOMINATION*/))
            {
                // Vampire domination gaze: x2_s2_shiftdom(687)
                // Will save or be dominated.
                oTarget = ai_GetHighestCRTarget(oCreature);
                int nWillSave = GetWillSavingThrow(oTarget);
                int nDC = GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) + d10() - 5;
                if(!GetHasSpellEffect(687/*SPELLABILITY_DOMINATION*/, oTarget) && nDC > nWillSave)
                {
                    nSpell = 687/*SPELLABILITY_DOMINATION*/;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_SPECTRE)
        {
            if(!ai_CompareLastAction(oCreature, 802/*SPELLABILITY_SPECTRE_ATTACK*/))
            {
                // Spectre attack: x2_s2_gwdrain(802)
                // Strength drain attack, once per round.
                oTarget = ai_GetLowestCRTarget(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
                int nFortSave = GetFortitudeSavingThrow(oTarget);
                int nDC = GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) + d10() - 5;
                if(!GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL) &&
                    nDC > nFortSave)
                {
                    nSpell = 802/*SPELLABILITY_SPECTRE_ATTACK*/;
                }
             }
        }
        else if(nForm == 428/*APPEARANCE_TYPE_AZER_MALE*/ || nForm == 429/*APPEARANCE_TYPE_AZER_FEMALE*/)
        {
            if(!ai_CompareLastAction(oCreature, SPELL_BURNING_HANDS))
            {
                string sIndex = IntToString(ai_GetHighestMeleeIndex(oCreature, AI_RANGE_MELEE));
                int nGroup = GetLocalInt(oCreature, AI_ENEMY_MELEE + sIndex);
                if(nGroup > 1)
                {
                   // Burning hands: NW_S0_BurnHand(10)
                   // Per the spell burning hands.
                   oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                    if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
                    if(!GetHasFeat(FEAT_EVASION, oTarget))
                    {
                        int nDC = d10() - 2;
                        int nReflexSave = GetReflexSavingThrow(oTarget);
                        if(nDC > nReflexSave)
                        {
                            nSpell = SPELL_BURNING_HANDS;
                        }
                    }
                }
            }
            if(!ai_CompareLastAction(oCreature, 801/*AZER_FIRE_BLAST*/))
            {
                // Fire blast: x2_s2_gwburn()
                // Beam of fire that does damage.
                string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature));
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                if(!GetHasFeat(FEAT_EVASION, oTarget))
                {
                    int nDC = GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) + d10() - 5;
                    int nReflexSave = GetReflexSavingThrow(oTarget);
                    if(nDC > nReflexSave)
                    {
                        nSpell = 801/*AZER_FIRE_BLAST*/;
                    }
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_SLAAD_DEATH)
        {
            if(!ai_CompareLastAction(oCreature, 770/*SPELLABILITY_CHAOS_SPITTLE*/))
            {
                // Chaos Spittle attack: x2_s1_chaosspit(770)
                // Ranged touch attack to do damage.
                string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature));
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                nSpell = 770/*SPELLABILITY_CHAOS_SPITTLE*/;
            }
        }
        else if(nForm == APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE || nForm == APPEARANCE_TYPE_RAKSHASA_TIGER_MALE)
        {
            // Unlimited spells(Dispel Magic, Ice Storm, Mestils Acid breath).
            // As per the spells.
            if(!ai_CompareLastAction(oCreature, SPELL_MESTILS_ACID_BREATH))
            {
                // Check for Mestil's Acid breath.
                string sIndex = IntToString(ai_GetHighestMeleeIndex(oCreature, AI_RANGE_MELEE));
                int nMelee = GetLocalInt(oCreature, AI_ENEMY_MELEE + sIndex);
                if(nMelee > 1)
                {
                    oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                    if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
                    if(!GetHasFeat(FEAT_EVASION, oTarget) &&
                        !ai_CreatureImmuneToEffect(oCreature, oTarget, SPELL_MESTILS_ACID_BREATH))
                    {
                        int nDC = 3 + d10() - 5;
                        int nReflexSave = GetReflexSavingThrow(oTarget);
                        if(nDC > nReflexSave)
                        {
                            nSpell = SPELL_MESTILS_ACID_BREATH;
                        }
                    }
                }
            }
            if(!ai_CompareLastAction(oCreature, SPELL_DISPEL_MAGIC))
            {
                // Dispel Magic.
                oTarget = ai_GetHighestCRTarget(oCreature);
                if(ai_CreatureHasDispelableEffect(oCreature, oTarget))
                {
                    nSpell = SPELL_DISPEL_MAGIC;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_GOLEM_IRON)
        {
            if(!ai_CompareLastAction(oCreature, 263/*Golem_Breath_Gas*/))
            {
                // Breath attack:NW_S1_GolemGas(263)
                // Cone of poisonous gas.
                string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature, AI_RANGE_CLOSE));
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                if(oTarget == OBJECT_INVALID) oTarget = oNearestEnemy;
                if(!ai_CreatureImmuneToEffect(oCreature, oTarget, 263/*Golem_Breath_Gas*/))
                {
                    nSpell = 263/*Golem_Breath_Gas*/;
                }
            }
        }
        else if(nForm == APPEARANCE_TYPE_GOLEM_STONE)
        {
            if(!ai_CompareLastAction(oCreature, 775/*SPELLABILITY_HURL_ROCK*/))
            {
                string sIndex = IntToString(ai_GetMostWoundedIndex(oCreature));
                oTarget = GetLocalObject(oCreature, AI_ENEMY + sIndex);
                // Throw rocks: x2_s1_hurlrock(775)
                // Ranged attack to do damage.
                if(!GetHasFeat(FEAT_EVASION, oTarget))
                {
                    int nDC = GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) + d10() - 5;
                    int nReflexSave = GetReflexSavingThrow(oTarget);
                    if(nDC > nReflexSave)
                    {
                        nSpell = 775/*SPELLABILITY_HURL_ROCK*/;
                    }
                }
            }
        }
        if (nSpell != 0)
        {
            ai_SetLastAction(oCreature, nSpell);
            ActionCastSpellAtObject(nSpell, oTarget, 0, TRUE);
        }
    }
    // PHYSICAL ATTACKS - Either we don't have talents or we are saving them.
    //if(ai_InCombatEquipBestMeleeWeapon(oCreature, TRUE)) return;
    oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee);
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget != OBJECT_INVALID) ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    else ai_SearchForInvisibleCreature(oCreature, TRUE);
}
void main()
{
    object oCreature = OBJECT_SELF;
    // Need to know who we are so we can use thier abilities.
    int nForm = GetAppearanceType(oCreature);
    // Check to see if we are back to our normal form?(-1 to get the actual form #)
    if(nForm == GetLocalInt(oCreature, AI_NORMAL_FORM) - 1)
    {
        // If we are transformed back then go back to our primary ai.
        ai_SetCreatureAIScript(oCreature);
        DeleteLocalInt(oCreature, AI_NORMAL_FORM);
        string sAI = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
        if(sAI == "ai_polymorphed" || sAI == "") sAI = "ai_default";
        ExecuteScript(sAI, oCreature);
    }
    else ai_DoActions(oCreature, nForm);
}
