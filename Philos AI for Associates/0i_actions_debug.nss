/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_actions
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for action during combat.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_talents_debug"
#include "x0_inc_henai"
#include "x0_inc_HENAI"
// Chooses an action in combat and executes it for oCreature that is an associate.
void ai_DoAssociateCombatRound(object oCreature, object oTarget = OBJECT_INVALID);
// Chooses an action in combat and executes it for oCreature that is a monster.
void ai_DoMonsterCombatRound(object oCreature);
// Return the distance that is set for how close we should follow our master.
float ai_GetFollowDistance(object oCreature);
// Returns TRUE if the caller's distance is greater than fDistance from their
// master. Unless they are cowardly or in stand ground mode.
// This will also force the caller to move towards their master.
int ai_StayCloseToMaster(object oCreature, float fDistance = AI_RANGE_PERCEPTION);
// Returns TRUE if oCreature becomes invisible or hides.
int ai_TryToBecomeInvisible(object oCreature);
// Returns TRUE if oCreature continues to bash a door.
int ai_BashDoorCheck(object oCreature);
// Returns TRUE if we find an invisible creature within battle and do an action.
// If oCreature is too far away they will move towards the invisible creature.
// If oCreature is close they will attempt to cast a spell or search for them.
int ai_SearchForInvisibleCreature(object oCreature, object oInvisible = OBJECT_INVALID);
// Have oCreature move out of an area effect based on the creatures in the battle.
void ai_MoveOutOfAOE(object oCreature, object oCaster);
// Returns TRUE if oCreature fails a moral check.
// We only make moral checks once we are below AI_HEALTH_WOUNDED health percent.
// If we are at AI_HEALTH_BLOODY hp percent then add + AI_MORAL_INC_DC to the Check.
int ai_MoralCheck(object oCreature);
// Returns TRUE if oCreature is in and nSpell is a dangerous Area Of Effect.
// Used in the on spell cast at scripts. [nw_c2_defaultb and nw_ch_acb].
int ai_GetInAOEReaction(object oCreature, object oCaster, int nSpell);
// Have the associate speak a random voice from VOICE_CHAT_*.
// nRoll is the number to roll.
// sOptionsArray is an array of VOICE_CHAT_* numbers over nRoll.
// example(4, ":3:4:8:7:") will roll a d4() picking from 3,4,8,7 of VOICE_CHAT_*.
// if nRoll is higher than the number of VOICE_CHAT_* then it will not speak.
void ai_HaveCreatureSpeak(object oCreature, int nRoll, string sVoiceChatArray);
// Returns if a spell talent was used.
// This is a common set of AI scripts ran on associate spell casters.
int ai_CheckForAssociateSpellTalent(object oAssociate, int nInMelee, int nMaxLevel);
// Targets the nearest creature oCreature it can see.
// This checks all physcal attack talents starting with ranged attacks then melee.
// Using TALENT_CATEGORY_HARMFUL_MELEE [22] talents.
// If no talents are used it will do either a ranged attack or a melee attack.
void ai_DoPhysicalAttackOnNearest(object oCreature, int nInMelee, int bAlwaysAtk = TRUE, int bAssociate = FALSE);
// Targets the weakest creature oCreature can see.
// This checks all physcal attack talents starting with ranged attacks then melee.
// Using TALENT_CATEGORY_HARMFUL_MELEE [22] talents.
// If no talents are used it will do either a ranged attack or a melee attack.
void ai_DoPhysicalAttackOnLowestCR(object oCreature, int nInMelee, int bAlwaysAtk = TRUE, int bAssociate = FALSE);
// Returns TRUE if they equip a melee weapon, FALSE if they don't.
// This also calls for the next combat round.
// bAssociate TRUE will run a combat round for Associates instead of monsters.
int ai_InCombatEquipBestMeleeWeapon(object oCreature, int bAssociate = FALSE);
// Returns TRUE if they equip a ranged weapon, FALSE if they don't.
// This also calls for the next combat round.
// bAssociate TRUE will run a combat round for Associates instead of monsters.
int ai_InCombatEquipBestRangedWeapon(object oCreature, int bAssociate = FALSE);
// Has oCreature attempt to heal oTarget.
// if oTarger is OBJECT_INVALID then they will check all allies.
void ai_TryHealingOutOfCombat(object oCreature, object oTarget = OBJECT_INVALID);
// oCreature will move into the area looking for creatures.
void ai_ScoutAhead(object oCreature);
// Have oCreature search through nearby placeables for items to pickup.
int ai_AssociateRetrievingItems(object oCreature);
// Returns TRUE if oCreature opens oLocked object.
// This will make oCreature open oLocked either by picking or casting a spell.
int ai_AttemptToByPassLock(object oCreature, object oLocked);
// Returns TRUE if oCreature disarms oTrap.
// bShout if TRUE oCreature will shout out what happens.
int ai_AttemptToDisarmTrap(object oCreature, object oTrap, int bShout = FALSE);
// Used to determine special behaviors for oCeature.
void ai_DetermineSpecialBehavior(object oCreature);
// The target object flees to the specified way point and then destroys itself,
// to be respawned at a later point.  For unkillable sign post characters
// who are not meant to fight back.
void ai_ActivateFleeToExit(object oCreature);
// Returns TRUE if oCreature should flee to an exit.
int ai_GetFleeToExit(object oCreature);

void ai_DoAssociateCombatRound(object oCreature, object oTarget = OBJECT_INVALID)
{
    if(ai_StayCloseToMaster(oCreature)) return;
    object oNearestEnemy = ai_SetCombatState (oCreature);
    if (oNearestEnemy != OBJECT_INVALID || oTarget != OBJECT_INVALID)
    {
        if(GetActionMode(oCreature, ACTION_MODE_DETECT) && !GetHasFeat(FEAT_KEEN_SENSE))
            SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
        ai_SetCombatRound(oCreature);
        string sAI = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
        if(sAI == "") sAI = "ai_a_default";
        ai_Debug("0i_actions", "99", "********** " + GetName (oCreature) + " **********");
        ai_Debug("0i_actions", "100", "********** " + sAI + " **********");
        if(oTarget != OBJECT_INVALID) SetLocalObject(oCreature, "AI_TARGET", oTarget);
        // We clear actions here and setup multiple actions to the queue for oCreature.
        ai_ClearCreatureActions(oCreature);
        ai_Counter_Start();
        ExecuteScript(sAI, oCreature);
        ai_Counter_End(GetName(oCreature) + " has finalized round action.");
        return;
    }
    // We have exhausted our check for an enemy. Combat is over.
    ai_ClearCombatState(oCreature);
    ai_TryHealingOutOfCombat(oCreature, oCreature);
    // Seek out and disable traps.
    object oTrap = GetNearestTrapToObject(oCreature);
    if(oTrap != OBJECT_INVALID &&
       ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS) &&
       ai_AttemptToDisarmTrap(oCreature, oTrap)) return;
    if(ai_AssociateRetrievingItems(oCreature)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD))
    {
        ai_ScoutAhead(oCreature);
        return;
    }
    ai_Debug("0i_actions", "127", GetName (OBJECT_SELF) + "'s combat has ended!");
}
void ai_DoMonsterCombatRound(object oCreature)
{
    object oNearestEnemy = ai_SetCombatState(oCreature);
    if(oNearestEnemy != OBJECT_INVALID)
    {
        if(GetActionMode(oCreature, ACTION_MODE_DETECT) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature))
           SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
        ai_SetCombatRound(oCreature);
        string sAI = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
        if(sAI == "") sAI = "ai_default";
        ai_Debug("0i_actions", "139", "********** " + GetName (oCreature) + " **********");
        ai_Debug("0i_actions", "140", "********** " + sAI + " **********");
        // We clear actions here and setup multiple actions to the queue for oCreature.
        ai_ClearCreatureActions(oCreature);
        ai_Counter_Start();
        ExecuteScript(sAI, oCreature);
        ai_Counter_End(GetName(oCreature) + " is ending round calculations.");
        return;
    }
    // Check to see if we just didn't see the enemies.
    if(GetLocalInt(oCreature, AI_ENEMY_NUMBERS) &&
       ai_SearchForInvisibleCreature(oCreature)) return;
    // We have exhausted our check for an enemy. Combat is over.
    ai_EndCombatRound(oCreature);
    ai_ClearCombatState(oCreature);
    ai_Debug("0i_actions", "154", GetName(oCreature) + "'s combat has ended!");
    return;
}
float ai_GetFollowDistance(object oCreature)
{
    // Also check for size of creature and adjust based on that.
    float fDistance = StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oCreature)));
    if(ai_GetAssociateMode(oCreature, AI_MODE_DISTANCE_CLOSE)) return fDistance + AI_DISTANCE_CLOSE;
    else if(ai_GetAssociateMode(oCreature, AI_MODE_DISTANCE_MEDIUM)) return fDistance + AI_DISTANCE_MEDIUM;
    else if(ai_GetAssociateMode(oCreature, AI_MODE_DISTANCE_LONG)) return fDistance + AI_DISTANCE_LONG;
    return fDistance + 0.5f;
}
int ai_StayCloseToMaster(object oCreature, float fDistance = AI_RANGE_PERCEPTION)
{
    if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND) ||
        GetLocalString(oCreature, AI_COMBAT_SCRIPT) == "ai_coward") return FALSE;
    object oMaster = GetMaster(oCreature);
    if(GetDistanceBetween(oMaster, oCreature) < fDistance) return FALSE;
    ai_ClearCreatureActions(oCreature);
    ai_Debug("0i_associates", "173", "We are too far away! Move to our master.");
    ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
    return TRUE;
}
int ai_TryToBecomeInvisible(object oCreature)
{
    // If we are invisible then we don't need to check this.
    if(!ai_GetIsInvisible(oCreature)) return FALSE;
    // If not invisible lets try.
    int nDarkness;
    if(GetHasSpell(SPELL_DARKNESS, oCreature) && ai_GetHasEffectType(oCreature, EFFECT_TYPE_ULTRAVISION)) nDarkness = TRUE;
    if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY, oCreature) || GetHasSpell(SPELL_INVISIBILITY, oCreature) ||
       GetHasSpell(SPELL_INVISIBILITY_SPHERE, oCreature) ||(nDarkness) ||
       GetHasSpell(SPELL_SANCTUARY, oCreature) || GetHasSpell(SPELL_ETHEREALNESS, oCreature) ||
       GetHasSpell(799/*SPELLABILITY_VAMPIRE_INVISIBILITY*/) ||
       GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature) == TRUE)
    {
        // This bit ported directly from Jasperre
        // Can anyone see me?(has spell effects of X)
        // The point of this is to see if its even worthwhile to go invisbile
        // or will it be immediately dispeled.
        object oSeeMe = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_TRUE_SEEING);
        if(oSeeMe == OBJECT_INVALID)
        {
            oSeeMe = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_SEE_INVISIBILITY);
        }
        if(oSeeMe == OBJECT_INVALID)
        {
            // Check non-invisibility options first. Since they can be used
            // while near enemies.
            if(GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT, oCreature))
            {
                // Go into stealth mode
                SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                ai_Debug("0i_actions", "207", "Using HIDE_IN_PLAIN_SIGHT!");
                return TRUE;
            }
            if(nDarkness)
            {
                ai_SetLastAction(oCreature, SPELL_DARKVISION);
                ActionCastSpellAtObject(SPELL_DARKVISION, oCreature);
                return TRUE;
            }
            if(GetHasSpell(SPELL_ETHEREALNESS, oCreature))
            {
                ai_SetLastAction(oCreature, SPELL_ETHEREALNESS);
                ActionCastSpellAtObject(SPELL_ETHEREALNESS, oCreature);
                return TRUE;
            }
            if(GetHasSpell(SPELL_SANCTUARY, oCreature))
            {
                ai_SetLastAction(oCreature, SPELL_SANCTUARY);
                ActionCastSpellAtObject(SPELL_SANCTUARY, oCreature);
                return TRUE;
            }
            // Get the nearest Enemy and how close they are.
            // Use this to keep invisibility from being spammed in melee.
            object oEnemy = ai_GetNearestEnemy(oCreature);
            if(GetDistanceBetween(oCreature, oEnemy) > AI_RANGE_MELEE)
            {
                if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY, oCreature))
                {
                    ai_SetLastAction(oCreature, SPELL_IMPROVED_INVISIBILITY);
                    ActionCastSpellAtObject(SPELL_IMPROVED_INVISIBILITY, oCreature);
                    return TRUE;
                }
                if(GetHasSpell(SPELL_INVISIBILITY, oCreature))
                {
                    ai_SetLastAction(oCreature, SPELL_INVISIBILITY);
                    ActionCastSpellAtObject(SPELL_INVISIBILITY, oCreature);
                    return TRUE;
                }
                if(GetHasSpell(SPELL_INVISIBILITY_SPHERE, oCreature))
                {
                    ai_SetLastAction(oCreature, SPELL_INVISIBILITY_SPHERE);
                    ActionCastSpellAtObject(SPELL_INVISIBILITY_SPHERE, oCreature);
                    return TRUE;
                }
                if(GetHasSpell(799/*SPELLABILITY_VAMPIRE_INVISIBILITY*/, oCreature))
                {
                    ai_SetLastAction(oCreature, 799/*SPELLABILITY_VAMPIRE_INVISIBILITY*/);
                    ActionCastSpellAtObject(799/*SPELLABILITY_VAMPIRE_INVISIBILITY*/, oCreature);
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}
int ai_SearchForInvisibleCreature(object oCreature, object oInvisible = OBJECT_INVALID)
{
    ai_Debug("0i_actions", "258", GetName(oCreature) + " is searching for an invisible creature (" +
             GetName(oInvisible) + ").");
    if(oInvisible == OBJECT_INVALID)
    {
        // Have we see anyone go invisible?
        oInvisible = GetLocalObject(oCreature, AI_IS_INVISIBLE);
        if(oInvisible == OBJECT_INVALID || GetIsDead(oInvisible))
        {
            oInvisible = ai_GetNearestEnemy(oCreature, 1, 7, PERCEPTION_HEARD_AND_NOT_SEEN);
            if(oInvisible == OBJECT_INVALID) oInvisible = ai_GetNearestEnemy(oCreature);
        }
    }
    float fDistance = GetDistanceBetween(oCreature, oInvisible);
    if(fDistance > AI_RANGE_PERCEPTION) return FALSE;
    ai_Debug("0i_actions", "272", "Is invisible: " + GetName(oInvisible) + " fDistance: " + FloatToString(fDistance, 0, 2));
    SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
    // If we are close enough then lets look for them.
    if(fDistance < AI_RANGE_CLOSE)
    {
        if(GetHasSpellEffect(SPELL_INVISIBILITY, oInvisible) ||
            GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY, oInvisible) ||
            GetHasSpellEffect(SPELL_SANCTUARY, oInvisible) ||
            GetHasSpellEffect(SPELL_ETHEREALNESS, oInvisible))
        {
            if(GetHasSpell(SPELL_TRUE_SEEING, oCreature))
            {
                ai_SetLastAction(oCreature, SPELL_TRUE_SEEING);
                ActionCastSpellAtObject(SPELL_TRUE_SEEING, oCreature);
                return TRUE;
            }
            else if(GetHasSpell(SPELL_SEE_INVISIBILITY, oCreature))
            {
                ai_SetLastAction(oCreature, SPELL_SEE_INVISIBILITY);
                ActionCastSpellAtObject(SPELL_SEE_INVISIBILITY, oCreature);
                return TRUE;
            }
            else if(GetHasSpell(SPELL_INVISIBILITY_PURGE, oCreature))
            {
                ai_SetLastAction(oCreature, SPELL_INVISIBILITY_PURGE);
                ActionCastSpellAtObject(SPELL_INVISIBILITY_PURGE, oCreature);
                return TRUE;
            }
        }
        if(!GetActionMode(oCreature, ACTION_MODE_DETECT))
        {
            ai_Debug("0i_actions", "303", " Using Detect mode.");
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
        }
        ActionMoveToObject(oInvisible, FALSE);
        ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
        if(ai_GetIsInCombat(oCreature)) ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return TRUE;
    }
    else
    {
        ai_Debug("0i_actions", "131", "Moving to invisible creature: " + GetName(oInvisible));
        ActionMoveToObject(oInvisible, TRUE);
        ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
        if(ai_GetIsInCombat(oCreature)) ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
    }
    return TRUE;
}
void ai_MoveOutOfAOE(object oCreature, object oCaster)
{
    location lLocation;
    object oMaster = GetMaster(oCreature);
    // If the caster is not dead and not in an effect then go to them.
    if(oCaster != OBJECT_INVALID &&
       GetObjectSeen(oCaster, oCreature) &&
       !GetIsDead(oCaster) &&
       !ai_IsInADangerousAOE(oCaster)) lLocation = GetLocation(oCaster);
    // Else if our master is not in a AOE then go to them.
    else if(oMaster != OBJECT_INVALID &&
            !ai_IsInADangerousAOE(oMaster)) lLocation = GetLocation(oMaster);
    //else get a random location!
    else lLocation = GetRandomLocation(GetArea(oCreature), oCreature, 10.0);
    ai_ClearCreatureActions(oCreature);
    ai_Debug("0i_actions", "345", GetName(oCreature) + " is moving out of area of effect!");
    ActionMoveToLocation(lLocation, TRUE);
}
int ai_MoralCheck(object oCreature)
{
    // If we are immune to fear then we are immune to MoralChecks!
    // Constructs and Undead are also immune to fear.
    int nRaceType = GetRacialType(oCreature);
    if(!AI_USE_MORAL || GetIsImmune(oCreature, IMMUNITY_TYPE_FEAR) ||
        nRaceType == RACIAL_TYPE_UNDEAD ||
        nRaceType == RACIAL_TYPE_CONSTRUCT ||
        ai_GetIsCharacter(oCreature)) return FALSE;
    // Moral DC is AI_WOUNDED_MORAL_DC - The number of allies.
    // or AI_BLOODY_MORAL_DC - number of allies.
    int nDC;
    int nHpPercent = ai_GetPercHPLoss(oCreature);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    // We only make moral checks if we are below half hitpoints and the Difficulty should be adjusted to -10 at 0.
    if(nHpPercent <= AI_HEALTH_WOUNDED)
    {
        if(nHpPercent <= AI_HEALTH_BLOODY) nDC = AI_BLOODY_MORAL_DC;
        else nDC = AI_WOUNDED_MORAL_DC;
        nDC = nDC - GetLocalInt(oCreature, AI_ALLY_NUMBERS);
        if(nDC < 1) nDC = 1;
        ai_Debug("0i_talents", "367", "Moral check DC: " + IntToString(nDC) + ".");
        if(!WillSave(oCreature, nDC, SAVING_THROW_TYPE_FEAR, oNearestEnemy))
        {
            ai_Debug("0i_talents", "370", "Moral check failed, we are fleeing!");
            SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_coward");
            effect eVFX = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVFX, oCreature, 6.0f);
            ActionMoveAwayFromObject(oNearestEnemy, TRUE, AI_RANGE_LONG);
            if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
            {
                int nRoll = d4();
                if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_FLEE, oCreature);
                else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_GUARDME, oCreature);
                else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_HELP, oCreature);
                else if(nRoll == 4 && nHpPercent < 100) PlayVoiceChat(VOICE_CHAT_HEALME, oCreature);
            }
            return TRUE;
        }
        if(nDC >= 11 && !ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
        {
            int nRoll = d6();
            // Cry out when you are overwhelmed!
            if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_CUSS, oCreature);
            else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_BADIDEA, oCreature);
            else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_ENEMIES, oCreature);
        }
    }
    return FALSE;
}
int ai_GetInAOEReaction(object oCreature, object oCaster, int nSpell)
{
    switch(nSpell)
    {
        case SPELL_ACID_FOG:
        case SPELL_CLOUDKILL:
        case SPELL_CREEPING_DOOM:
        {
            // Nothing but bad times with these spells.
            return TRUE;
        }
        case SPELL_STORM_OF_VENGEANCE:
        {
            // This only harms our enemies!
            return (oCaster != oCreature && GetIsEnemy(oCaster));
        }
        case SPELL_SILENCE:
        {
            // If we can cast spells we should get out!
            return (ai_CheckClassType(oCreature, AI_CLASS_TYPE_CASTER));
        }
        case SPELL_BLADE_BARRIER:
        case SPELL_WALL_OF_FIRE:
        case SPELL_INCENDIARY_CLOUD:
        {
            // Check reflex feats and saves.
            return (!GetHasFeat(FEAT_EVASION, oCreature) &&
                    !GetHasFeat(FEAT_IMPROVED_EVASION, oCreature) &&
                    GetReflexSavingThrow(oCreature) < 21 + d6());
         }
        case SPELL_STINKING_CLOUD:
        {
            // Do we have a high fortitude save? 20 + 5
            return (GetFortitudeSavingThrow(oCreature) < 20 + d6());
        }
        case SPELL_GREASE:
        case SPELL_ENTANGLE:
        case SPELL_VINE_MINE_ENTANGLE:
        case SPELL_WEB:
        {
            // Do we have a high reflex save? d20 + 1
            return (!GetHasFeat(FEAT_WOODLAND_STRIDE, oCreature) &&
                    !GetLocalInt(oCreature, "X2_L_IS_INCORPOREAL") &&
                    GetReflexSavingThrow(oCreature) < 15 + d6());
        }
        case SPELL_EVARDS_BLACK_TENTACLES:
        {
            // Small creatures are immune and can they hit me? d20 + 8 + caster lvl(7)
            return (GetCreatureSize(oCreature) > 2 &&
                    GetAC(oCreature) < 30 + d6());
        }
        case SPELL_CLOUD_OF_BEWILDERMENT:
        {
            // Do we have a high fortitude save? 20 + 2
            return (GetFortitudeSavingThrow(oCreature) < 17 + d6());
        }
        case SPELL_MIND_FOG:
        case SPELL_STONEHOLD:
        {
            // Do we have a high enough will save? 20 + 6
            return (GetWillSavingThrow(oCreature) < 21 + d6());
        }
        case SPELL_SPIKE_GROWTH:
        case SPELL_VINE_MINE_HAMPER_MOVEMENT:
        {
           // Do we have a high reflex save? d20 + 3
           return (GetReflexSavingThrow(oCreature) < 18 + d6());
        }
   }
   return FALSE;
}
void ai_HaveCreatureSpeak(object oCreature, int nRoll, string sVoiceChatArray)
{
    if(ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) return;
    nRoll = Random(nRoll);
    string sVoice = ai_GetStringArray(sVoiceChatArray, nRoll);
    if(sVoice != "") PlayVoiceChat(StringToInt(sVoice), oCreature);
}
int ai_CheckForAssociateSpellTalent(object oAssociate, int nInMelee, int nMaxLevel)
{
    // ******************* OFFENSIVE AOE TALENTS ***********************
    // Check the battlefield for a group of enemies to shoot a big spell at!
    // We are checking here since these opportunities are rare and we need
    // to take advantage of them as often as possible.
    if(!ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING))
    {
        if(ai_UseCreatureTalent(oAssociate, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return TRUE;
        if(ai_UseCreatureTalent(oAssociate, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return TRUE;
    }
    if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) return FALSE;
    // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ************
    // Does our master want to be buffed first?
    object oTarget = OBJECT_INVALID;
    if(ai_GetAssociateMagicMode(oAssociate, AI_MAGIC_BUFF_MASTER)) oTarget = GetMaster(oAssociate);
    return ai_TryDefensiveTalents(oAssociate, nInMelee, nMaxLevel, oTarget);
}
void ai_DoPhysicalAttackOnNearest(object oCreature, int nInMelee, int bAlwaysAtk = TRUE, int bAssociate = FALSE)
{
    talent tUse;
    object oTarget;
    ai_Debug("0i_actions", "496", "Check for ranged attack on nearest enemy!");
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
       !ai_GetAssociateMode(oCreature, AI_MODE_STOP_RANGED) &&
       ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
            // Lets pick off the nearest targets first.
            if(!nInMelee)
            {
                if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature);
            }
            else
            {
                if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                ai_Debug("0i_actions", "519", "Do ranged attack against nearest: " + GetName(oTarget) + "!");
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else if(ai_SearchForInvisibleCreature(oCreature)) return;
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature, bAssociate)) return;
    }
    ai_Debug("0i_actions", "525", "Check for melee attack on nearest enemy!");
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TryWhirlwindFeat(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee, bAlwaysAtk)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestTargetForMeleeCombat(oCreature, nInMelee, bAlwaysAtk);
    // If we don't find a target then we don't want to fight anyone!
    if(oTarget == OBJECT_INVALID) return;
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_Debug("0i_actions", "536", "Do melee attack against nearest: " + GetName(oTarget) + "!");
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
void ai_DoPhysicalAttackOnLowestCR(object oCreature, int nInMelee, int bAlwaysAtk = TRUE, int bAssociate = FALSE)
{
   ai_Debug("0i_actions", "533", "Check for ranged attack on weakest enemy!");
    object oTarget;
    // ************************** Ranged feat attacks **************************
    if(!GetHasFeatEffect(FEAT_BARBARIAN_RAGE, oCreature) &&
       !ai_GetAssociateMode(oCreature, AI_MODE_STOP_RANGED) &&
       ai_CanIUseRangedWeapon(oCreature, nInMelee))
    {
        if(ai_HasRangedWeaponWithAmmo(oCreature))
        {
            if(ai_TryRangedSneakAttack(oCreature, nInMelee)) return;
            // Lets pick off the weaker targets.
            if(!nInMelee)
            {
                if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature);
            }
            else
            {
                if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_MELEE);
                if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTarget(oCreature, AI_RANGE_MELEE);
            }
            if(oTarget != OBJECT_INVALID)
            {
                if(ai_TryRapidShotFeat(oCreature, oTarget, nInMelee)) return;
                ai_Debug("0i_actions", "559", GetName(OBJECT_SELF) + " does ranged attack on weakest: " + GetName(oTarget) + "!");
                ai_ActionAttack(oCreature, AI_LAST_ACTION_RANGED_ATK, oTarget, nInMelee, TRUE);
                return;
            }
            else if(ai_SearchForInvisibleCreature(oCreature)) return;
        }
        else if(ai_InCombatEquipBestRangedWeapon(oCreature, bAssociate)) return;
    }
    ai_Debug("0i_actions", "571", "Check for melee attack on weakest enemy!");
    // ************************** Melee feat attacks *************************
    if(ai_InCombatEquipBestMeleeWeapon(oCreature)) return;
    if(ai_TrySneakAttack(oCreature, nInMelee, bAlwaysAtk)) return;
    if(ai_TryWhirlwindFeat(oCreature)) return;
    if(ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER)) oTarget = ai_GetLowestCRAttackerOnMaster(oCreature);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetNearestFavoredEnemyTarget(oCreature, AI_RANGE_PERCEPTION, bAlwaysAtk);
    if(oTarget == OBJECT_INVALID) oTarget = ai_GetLowestCRTargetForMeleeCombat(oCreature, nInMelee, bAlwaysAtk);
    if(oTarget != OBJECT_INVALID)
    {
        if(ai_TryMeleeTalents(oCreature, oTarget)) return;
        ai_Debug("0i_actions", "577", GetName(OBJECT_SELF) + " does melee attack against weakest: " + GetName(oTarget) + "!");
        ai_ActionAttack(oCreature, AI_LAST_ACTION_MELEE_ATK, oTarget);
    }
    else ai_SearchForInvisibleCreature(oCreature);
}
int ai_InCombatEquipBestMeleeWeapon(object oCreature, int bAssociate = FALSE)
{
    if(ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature))) return FALSE;
    if(ai_EquipBestMeleeWeapon(oCreature))
    {
        // We delay 1 second since ActionEquip is not an action we can check for.
        // This keeps event scripts from clearing before we actually equip.
        SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 1);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return TRUE;
    }
    return FALSE;
}
int ai_InCombatEquipBestRangedWeapon(object oCreature, int bAssociate = FALSE)
{
    if(ai_EquipBestRangedWeapon(oCreature))
    {
        // We delay 1 second since ActionEquip is not an action we can check for.
        // This keeps event scripts from clearing before we actually equip.
        SetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS, 1);
        ActionDoCommand(ExecuteScript("0e_do_combat_rnd", oCreature));
        return TRUE;
    }
    return FALSE;
}
void ai_TryHealingOutOfCombat(object oCreature, object oTarget)
{
    object oMaster = GetMaster(oCreature);
    ai_Debug("0i_actions", "608", "Should we heal? oCreature: " + GetName(oCreature) +
             " oTarget: " + GetName(oTarget));
    if(oTarget == OBJECT_INVALID) ai_CastHealing(oCreature, 0, oMaster, FALSE);
    else
    {
        ai_SetupAllyTargets(oCreature, oMaster);
        int nCntr = 1;
        while(nCntr < 10)
        {
            if(oTarget == GetLocalObject(oCreature, "AI_ALLY_TARGET_" + IntToString(nCntr)))
            {
                ai_CastHealing(oCreature, nCntr, oMaster, FALSE);
                break;
            }
            nCntr++;
        }
    }
}
int ai_PerceiveEnemy(object oCreature, object oEnemy)
{
    float fDistance = GetDistanceBetween(oCreature, oEnemy);
    if(fDistance < 50.0)
    {
        // Game is in meters, so 1 foot = 3.333 meter
        // penalty is -1 per 10' so divide it by 10 to use 0.3333f
        int nDC = 10 + FloatToInt(fDistance * 0.3333f);
        // Check to see if the creature is hiding and add the creatures checks.
        int nEnemyMoveSilent, nEnemyHide;
        if(GetStealthMode(oEnemy))
        {
            nEnemyMoveSilent =(d20() + GetSkillRank(SKILL_MOVE_SILENTLY, oEnemy));
            nEnemyHide =(d20() + GetSkillRank(SKILL_HIDE, oEnemy));
        }
        if(GetIsSkillSuccessful (oCreature, SKILL_SPOT, nDC + nEnemyHide)) return TRUE;
        if(GetIsSkillSuccessful (oCreature, SKILL_LISTEN, nDC + nEnemyMoveSilent)) return TRUE;
    }
    return FALSE;
}
void ai_ScoutAhead(object oCreature)
{
    object oPerceived;
    object oEnemy = GetNearestEnemy(oCreature);
    // We see them so fight!
    if(oEnemy != OBJECT_INVALID)
    {
        if(ai_PerceiveEnemy(oCreature, oEnemy))
        {
            if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
            {
                int nRoll = d10();
                if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_ENEMIES, oCreature);
                else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_FOLLOWME, oCreature);
                else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
            }
            ActionMoveToObject(oEnemy, TRUE, AI_RANGE_LONG);
            return;
        }
        // There are enemies here so lets go to them.
        else
        {
            if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
            {
                int nRoll = d3();
                if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_BADIDEA, oCreature);
                else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_SEARCH, oCreature);
                else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_FOLLOWME, oCreature);
            }
            ActionMoveToObject(oEnemy, TRUE, AI_RANGE_CLOSE);
        }
    }
    // There are no more enemies, but we must look like we are patroling so
    // go to encounter points.
    else
    {
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
        {
            int nRoll = d10();
            if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_BADIDEA, oCreature);
            else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_SEARCH, oCreature);
            else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_FOLLOWME, oCreature);
        }
        // No enemy so lets get a spawn point!
        object oSpawnPoint = GetNearestObjectByTag("ip_encounter", oCreature, d6());
        ActionMoveToObject(oSpawnPoint, TRUE, AI_RANGE_CLOSE);
    }
}
int ai_ShouldIPickItUp(object oCreature, object oItem)
{
    // We always pickup plot items.
    if(GetPlotFlag(oItem))
    {
        PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
        return TRUE;
    }
    if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_GEMS_ITEMS))
    {
        //ai_Debug("0i_actions", "919", "Gems: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_GEMS_ITEMS)));
        if(GetBaseItemType(oItem) == BASE_ITEM_GEM) return TRUE;
        if(ai_GetNumberOfProperties(oItem) > 0) return TRUE;
        return FALSE;
    }
    if(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_MAGIC_ITEMS))
    {
        //ai_Debug("0i_actions", "926", "Magic: " + IntToString(ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_MAGIC_ITEMS)));
        if(ai_GetNumberOfProperties(oItem) > 0) return TRUE;
        return FALSE;
    }
    return TRUE;
}
void ai_TakeItemMessage(object oCreature, object oObject, object oItem, object oMaster)
{
    string sBaseName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "name", GetBaseItemType(oItem))));
    if(GetSkillRank(SKILL_LORE, oCreature, TRUE) > 0) ai_IdentifyItemVsKnowledge(oCreature, oItem);
    if(GetIdentified(oItem))
    {
        ai_SendMessages(GetName(oCreature) + " has found a " + GetName(oItem) + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster, FALSE, TRUE);
    }
    else
    {
       ai_SendMessages(GetName(oCreature) + " has found a " + sBaseName + " from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster, FALSE, TRUE);
    }
    if(GetPlotFlag(oItem))
    {
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
    }
}
void ai_ContinueRetrievingItems(object oCreature)
{
    if(ai_GetIsBusy(oCreature)) return;
    ai_AssociateRetrievingItems(oCreature);
}
void ai_SearchObject(object oCreature, object oObject, object oMaster, int nAssociateType)
{
    //ai_Debug("0i_actions", "954", GetName(OBJECT_SELF) + " is opening " + GetName(oObject));
    string sID = ObjectToString(oCreature);
    SetLocalInt(oObject, "AI_LOOTED_" + sID, TRUE);
    AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN));
    // Big Hack to allow NPC's to loot!
    string sLootScript = GetEventScript(oObject, EVENT_SCRIPT_PLACEABLE_ON_OPEN);
    //ai_Debug("0i_actions", "960", "Loot script: " + sLootScript);
    if(sLootScript != "")
    {
        // Used in Original Campaign loot scripts to get treasure to work.
        SetLocalObject(oObject, "AI_GET_LAST_OPENED_BY", oMaster);
        ExecuteScript(sLootScript, oObject);
    }
    AssignCommand(oObject, ActionWait(2.0f));
    AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
    int nItemType, nGold;
    object oItem = GetFirstItemInInventory(oObject);
    //ai_Debug("0i_actions", "971", "Found: " + GetName(oItem) + " ResRef: " + GetResRef(oItem) +
    //         " in " + GetName(oObject));
    while(oItem != OBJECT_INVALID)
    {
       //ai_Debug("0i_actions", "975", "Found: " + GetName(oItem) + " ResRef: " + GetResRef(oItem));
       if(GetResRef(oItem) == "nw_it_gold001")
       {
            if(!ai_GetIsCharacter(oCreature))
            {
                AssignCommand(oObject, ActionGiveItem(oItem, oMaster));
                ai_SendMessages(GetName(oCreature) + " has retrieved " + IntToString(GetItemStackSize(oItem)) +
                                 " gold from the " + GetName(oObject) + ".", COLOR_GRAY, oMaster);
            }
            else ActionTakeItem(oItem, oObject);
       }
       else if(ai_ShouldIPickItUp(oCreature, oItem))
       {
           //ai_Debug("0i_actions", "988", "Taking: " + GetName(oItem));
           if(nAssociateType == ASSOCIATE_TYPE_HENCHMAN)
           {
               if(!ai_GetIsCharacter(oCreature)) ai_TakeItemMessage(oCreature, oObject, oItem, oMaster);
               ActionTakeItem(oItem, oObject);
           }
           else
           {
               //ai_Debug("0i_actions", "996", "Giving to master: " + GetName(oItem));
               if(!ai_GetIsCharacter(oCreature)) ai_TakeItemMessage(oCreature, oObject, oItem, oMaster);
               AssignCommand(oObject, ActionGiveItem(oItem, oMaster));
           }
       }
       oItem = GetNextItemInInventory(oObject);
       //ai_Debug("0i_actions", "1002", GetName(oItem) + " is the next item.");
    }
    //ai_Debug("0i_actions", "1004", "Setting object as looted. Check for a new Placeable.");
    ActionDoCommand(ai_ContinueRetrievingItems(oCreature));
}
int ai_IsContainerLootable(object oCreature, object oObject, object oMaster)
{
    string sID = ObjectToString(oCreature);
    ai_Debug("0i_actions", "1010", GetName(oObject) + " (sTag " + GetTag(oObject) + ") " +
             "has inventory: " + IntToString(GetHasInventory(oObject)) + " Has been looted: " +
               IntToString(GetLocalInt(oObject, "AI_LOOTED_" + sID)) + " Is Useable? " +
               IntToString(GetUseableFlag(oObject)));
    if(!GetHasInventory(oObject) || !GetUseableFlag(oObject)) return FALSE;
    // This associate has already looted this object, skip.
    if(GetLocalInt(oObject, "AI_LOOTED_" + sID) ||
       ai_GetIsCharacter(oObject)) return FALSE;
    //ai_Debug("0i_actions", "1017", " LineOfSight: " + IntToString(ai_GetIsInLineOfSight(oMaster, oObject)));
    if(!ai_GetIsInLineOfSight(oMaster, oObject)) return FALSE;
    // Have the NPC/PC looting things auto find traps! Yea I know...
    // We have to do this since we cannot trigger traps from modules we don't
    // control the trap trigger scripts from.
    if(GetIsTrapped(oObject))
    {
        SetTrapDetectedBy(GetNearestTrapToObject(oObject, FALSE), oCreature, TRUE);
    }
    if(GetTrapDetectedBy(oObject, oCreature))
    {
        //ai_Debug("0i_actions", "1028", GetName(oObject) + " is trapped!");
        if(ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS) &&
           ai_AttemptToDisarmTrap(oCreature, oObject, TRUE)) return 2;
        return FALSE;
    }
    else if(GetLocked(oObject))
    {
        //ai_Debug("0i_actions", "1035", GetName(oObject) + " is locked!");
        if(!GetLocalInt(oObject, "AI_STATED_LOCKED_" + sID)) SpeakString("That " + GetName(oObject) + " is locked!");
        SetLocalInt(oObject, "AI_STATED_LOCKED_" + sID, TRUE);
        if(ai_GetAssociateMode(oCreature, AI_MODE_OPEN_LOCKS) &&
           ai_AttemptToByPassLock(oCreature, oObject)) return 2;
        return FALSE;
    }
    return TRUE;
}
int ai_AssociateRetrievingItems(object oCreature)
{
    if(!ai_GetAssociateMode(oCreature, AI_MODE_PICKUP_ITEMS)) return FALSE;
    int nObjectType, nAction, nAssociateType = GetAssociateType(oCreature);
    string sAssociateName = ai_RemoveIllegalCharacters(GetName(oCreature));
    object oMaster = GetMaster();
    // Added for PC AI system.
    if(ai_GetIsCharacter(oCreature))
    {
        oMaster = oCreature;
        nAssociateType = ASSOCIATE_TYPE_HENCHMAN;
    }
    int nIndex = 1;
    object oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_ITEM, oMaster, nIndex);
    // We limit the loot search from the master so the henchman stays close to the master.
    while(oObject != OBJECT_INVALID && GetDistanceBetween(oMaster, oObject) < AI_LOOT_DISTANCE)
    {
        nObjectType = GetObjectType(oObject);
        if(nObjectType == OBJECT_TYPE_ITEM)
        {
            ActionPickUpItem(oObject);
            return TRUE;
        }
        else
        {
            nAction = ai_IsContainerLootable(oCreature, oObject, oMaster);
            //ai_Debug("0i_actions", "1062", " nAction: " + IntToString(nAction));
            if(nAction == TRUE)
            {
                ai_ClearCreatureActions(oCreature);
                ActionMoveToObject(oObject, TRUE);
                ActionDoCommand(ai_SearchObject(oCreature, oObject, oMaster, nAssociateType));
                return TRUE;
            }
            // This means that the item is locked or/and trapped.
            if(nAction == 2) return TRUE;
        }
        oObject = GetNearestObject(OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_ITEM, oMaster, ++nIndex);
    }
    return FALSE;
}
int ai_AttempToCastKnockSpell(object oCreature, object oLocked)
{
    if(GetHasSpell(SPELL_KNOCK, oCreature) &&
      (GetIsDoorActionPossible(oLocked, DOOR_ACTION_KNOCK) ||
       GetIsPlaceableObjectActionPossible(oLocked, PLACEABLE_ACTION_KNOCK)) &&
       ai_GetIsInLineOfSight(oCreature, oLocked))
    {
        ai_ClearCreatureActions(oCreature);
        ActionWait(1.0);
        ActionCastSpellAtObject(SPELL_KNOCK, oLocked);
        ActionWait(1.0);
        return TRUE;
    }
    return FALSE;
}
int ai_AttemptToByPassLock(object oCreature, object oLocked)
{
    string sID = ObjectToString(oCreature);
    ai_Debug("0i_actions", "1094", "oCreature: " + GetName(oCreature) + " oLocked:" + GetName(oLocked));
    ai_Debug("0i_actions", "1095", " AI_LOCKED_: " + IntToString(GetLocalInt(oLocked, "AI_LOCKED_" + sID)) +
             " AI_STATED_LOCKED_: " + IntToString(GetLocalInt(oLocked, "AI_STATED_LOCKED_" + sID)));
    if(GetLocalInt(oLocked, "AI_LOCKED_" + sID)) return FALSE;
    // Attempt to cast knock because its always safe to cast it, even on a trapped object.
    if(ai_AttempToCastKnockSpell(oLocked, oCreature)) return TRUE;
    // First, let's see if we notice that it's trapped
    if(GetTrapDetectedBy(oCreature, oLocked))
    {
        // Ick! Try and disarm the trap first
        PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
        if(!ai_AttemptToDisarmTrap(oCreature, oLocked, TRUE)) return FALSE;
    }
    ai_Debug("0i_actions", "1107", "bNeedKey:" + IntToString(GetLockKeyRequired(oLocked)));
    SetLocalInt(oLocked, "AI_LOCKED_" + sID, TRUE);
    if(GetLockKeyRequired(oLocked))
    {
        // We might be able to open this.
        string sKeyTag = GetLockKeyTag(oLocked);
        // Do we have the key?
        object oItem = ai_GetCreatureHasItem(oCreature, sKeyTag, FALSE);
        ai_Debug("0i_actions", "1115", "sKeyTag: " + sKeyTag + " oItem: " + GetName(oItem));
        if(oItem != OBJECT_INVALID)
        {
            int nObjectType = GetObjectType(oLocked);
            if(nObjectType == OBJECT_TYPE_DOOR) ActionOpenDoor(oLocked);
            else if (nObjectType == OBJECT_TYPE_PLACEABLE) ActionUnlockObject(oLocked);
            return TRUE;
        }
        else
        {
            // Can't open this, so skip the checks
            if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
            return FALSE;
        }
    }
    // Now, let's try and pick the lock
    int nSkill = GetSkillRank(SKILL_OPEN_LOCK, oCreature);
    ai_Debug("0i_actions", "1132", "nSkill:" + IntToString(nSkill) + " CanWeUsePlaceable?: " +
             " Attemp Pick: " + IntToString(GetLocalInt(oLocked, "AI_ATTEMPT_PICK_" + sID)));
    if(nSkill > 0)
    {
        object oItem = ai_GetCreatureHasItem (oCreature, "0_thief_tools", FALSE);
        ai_ClearCreatureActions(oCreature);
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANDO, oCreature);
        ActionWait(1.0);
        ActionUseSkill(SKILL_OPEN_LOCK, oLocked, 0, oItem);
        ActionWait(1.0);
        return TRUE;
    }
    ai_ClearCreatureActions(oCreature);
    // Check to make sure we are using a melee weapon.
    if(ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature)) ||
       ai_EquipBestMeleeWeapon(oCreature))
    {
        ActionWait(1.0);
        ActionAttack(oLocked);
    }
    // If we didn't, let the player know.
    if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
    return FALSE;
}
int ai_AttemptToDisarmTrap(object oCreature, object oTrap, int bShout = FALSE)
{
    ai_Debug("0i_actions", "1158", "AttemptToDisarmTrap");
    string sID = ObjectToString(oCreature);
    int nSkill = GetSkillRank(SKILL_DISABLE_TRAP, oCreature);
    int nTrapDC = GetTrapDisarmDC(oTrap);
    if(GetTrapDisarmable(oTrap))
    {
        if(nSkill > 0 && !GetLocalInt(oTrap, "AI_TRAPPED_" + sID))
        {
            object oItem = ai_GetCreatureHasItem (oCreature, "0_thief_tools", FALSE);
            ai_ClearCreatureActions(oCreature);
            ActionUseSkill(SKILL_DISABLE_TRAP, oTrap, 0, oItem);
            ActionDoCommand(PlayVoiceChat(VOICE_CHAT_TASKCOMPLETE, oCreature));
            return TRUE;
        }
        if(GetHasSpell(SPELL_FIND_TRAPS, oCreature) && !GetLocalInt(oTrap, "AI_USE_FIND_TRAPS_" + sID))
        {
            ai_ClearCreatureActions(oCreature);
            ActionCastSpellAtObject(SPELL_FIND_TRAPS, oTrap);
            SetLocalInt(oTrap, "AI_USE_FIND_TRAPS_" + sID, TRUE);
            return TRUE;
        }
    }
    SetLocalInt(oTrap, "AI_TRAPPED_" + sID, TRUE);
    if(bShout && !GetLocalInt(oCreature, "AI_SAW_TRAP_" + sID))
    {
       //StrRef(40551) "This trap can never be disarmed!"
        string sSpeak = GetStringByStrRef(40551);
        SendMessageToPC(GetMaster(oCreature), sSpeak);
        SetLocalInt(oCreature, "AI_SAW_TRAP_" + sID, TRUE);
        PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
    }
    // This is a bit extreme. The player should make them do this.
    /*if(GetObjectType(oTrap) != OBJECT_TYPE_TRIGGER)
    {
        ActionAttack(oTrap);
        return TRUE;
    }
    // Throw ourselves on it nobly! :-)
    ActionMoveToLocation(GetLocation(oTrap));
    SetFacingPoint(GetPositionFromLocation(GetLocation(oTrap)));
    ActionRandomWalk();
    */
    return FALSE;
}
void ai_DetermineSpecialBehavior(object oCreature)
{
    object oTarget = GetNearestSeenEnemy();
    if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE))
    {
        if(ai_GetIsInCombat(oCreature)) ai_DoMonsterCombatRound(oTarget);
        // * if not attacking, then wander.
        else
        {
            ai_ClearCreatureActions(oCreature);
            ActionRandomWalk();
            return;
        }
    }
    else if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
    {
        if(GetIsObjectValid(ai_GetAttackedTarget(oCreature, TRUE, TRUE)))
        {
            if(oTarget != OBJECT_INVALID && GetDistanceBetween(oCreature, oTarget) <= 6.0)
            {
                if(!GetIsFriend(oTarget))
                {
                    if(GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0)
                    {
                        TalentFlee(oTarget);
                    }
                }
            }
        }
        else if(!IsInConversation(OBJECT_SELF))
        {
            ai_ClearCreatureActions(oCreature);
            ActionRandomWalk();
            return;
        }
    }
}
//This function is used only because ActionDoCommand can only accept void functions
void ai_CreateSignPostNPC(string sTag, location lLocal)
{
    CreateObject(OBJECT_TYPE_CREATURE, sTag, lLocal);
}
void ai_ActivateFleeToExit(object oCreature)
{
     //minor optimizations - only grab these variables when actually needed
     //can make for larger code, but it's faster
     //object oExitWay = GetWaypointByTag("EXIT_" + GetTag(OBJECT_SELF));
     //location lLocal = GetLocalLocation(OBJECT_SELF, "NW_GENERIC_START_POINT");
     //string sTag = GetTag(OBJECT_SELF);
     int nPlot = GetLocalInt(oCreature, "NW_GENERIC_MASTER");
     if(nPlot & NW_FLAG_TELEPORT_RETURN || nPlot & NW_FLAG_TELEPORT_LEAVE)
     {
        effect eVis = EffectVisualEffect(VFX_IMP_UNSUMMON);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCreature);
        if(nPlot & NW_FLAG_TELEPORT_RETURN)
        {
            location lLocal = GetLocalLocation(oCreature, "NW_GENERIC_START_POINT");
            string sTag = GetTag(oCreature);
            DelayCommand(6.0, ActionDoCommand(ai_CreateSignPostNPC(sTag, lLocal)));
        }
        ActionDoCommand(DestroyObject(oCreature, 0.75));
     }
     else
     {
        if(nPlot & NW_FLAG_ESCAPE_LEAVE)
        {
            object oExitWay = GetWaypointByTag("EXIT_" + GetTag(oCreature));
            ActionMoveToObject(oExitWay, TRUE);
            ActionDoCommand(DestroyObject(oCreature, 1.0));
        }
        else if(nPlot & NW_FLAG_ESCAPE_RETURN)
        {
            string sTag = GetTag(oCreature);
            object oExitWay = GetWaypointByTag("EXIT_" + sTag);
            ActionMoveToObject(oExitWay, TRUE);
            location lLocal = GetLocalLocation(oCreature, "NW_GENERIC_START_POINT");
            DelayCommand(6.0, ActionDoCommand(ai_CreateSignPostNPC(sTag, lLocal)));
            ActionDoCommand(DestroyObject(oCreature, 1.0));
        }
     }
}
int ai_GetFleeToExit(object oCreature)
{
    int nPlot = GetLocalInt(oCreature, "NW_GENERIC_MASTER");
    if(nPlot & NW_FLAG_ESCAPE_RETURN) return TRUE;
    else if(nPlot & NW_FLAG_ESCAPE_LEAVE) return TRUE;
    else if(nPlot & NW_FLAG_TELEPORT_RETURN) return TRUE;
    else if(nPlot & NW_FLAG_TELEPORT_LEAVE) return TRUE;
    return FALSE;
}

