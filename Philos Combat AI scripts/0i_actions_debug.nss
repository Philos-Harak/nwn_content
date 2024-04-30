/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_actions
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for action during combat.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_talents_debug"
#include "X0_I0_ANIMS"
// Chooses an action in combat for oCreature.
// Returns TRUE if an action was done.
// Returns FALSE if no enemy was found, combat is over.
void ai_DoMonsterCombatRound(object oCreature);
// Returns TRUE if oCreature becomes invisible or hides.
int ai_TryToBecomeInvisible(object oCreature);
// Returns TRUE if oCreature continues to bash a door.
int ai_BashDoorCheck(object oCreature);
// Returns TRUE if we find an invisible creature within battle and do an action.
// If oCreature is too far away they will move towards the invisible creature.
// If oCreature is close they will attempt to cast a spell or search for them.
int ai_SearchForInvisibleCreature(object oCreature);
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
        ai_Debug("0i_actions", "51", "********** " + GetName (oCreature) + " **********");
        ai_Debug("0i_actions", "52", "********** " + sAI + " **********");
        // We clear actions here and setup multiple actions to the queue for oCreature.
        ai_ClearCreatureActions(oCreature);
        ai_Counter_Start();
        ExecuteScript(sAI, oCreature);
        ai_Counter_End(GetName(oCreature) + " is ending round.");
        return;
    }
    // Check to see if we just didn't see the enemies.
    if(GetLocalInt(oCreature, AI_ENEMY_NUMBERS) &&
       ai_SearchForInvisibleCreature(oCreature)) return;
    // We have exhausted our check for an enemy. Combat is over.
    ai_ClearCombatState(oCreature);
    ai_Debug("0i_actions", "65", GetName(oCreature) + "'s combat has ended!");
    return;
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
                ai_Debug("0i_actions", "108", "Using HIDE_IN_PLAIN_SIGHT!");
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
int ai_SearchForInvisibleCreature(object oCreature)
{
    int nCnt = 1;
    float fDistance;
    ai_Debug("0i_actions", "157", GetName(oCreature) + " is searching for an invisible creature.");
    object oInvisible = OBJECT_INVALID;
    object oEnemy = ai_GetNearestEnemy(oCreature, nCnt, 7, 6);
    while(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_PERCEPTION)
    {
        ai_Debug("0i_actions", "163", "oEnemy: " + GetName(oEnemy) + " fDistance: " +
                 FloatToString(GetDistanceBetween(oCreature, oEnemy), 0, 2));
        if(ai_GetIsInLineOfSight(oCreature, oEnemy))
        {
            oInvisible = oEnemy;
            break;
        }
        oEnemy = ai_GetNearestEnemy(oCreature, ++nCnt, 7, 6);
    }
    if(oInvisible == OBJECT_INVALID) return FALSE;
    ai_HaveCreatureSpeak(oCreature, 4, ":10:23:27:37:");
    fDistance = GetDistanceBetween(oCreature, oInvisible);
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
        if(fDistance > AI_RANGE_MELEE)
        {
            ai_Debug("0i_actions", "204", " Moving closer to " + GetName(oInvisible));
            ActionMoveToObject(oInvisible, FALSE, AI_RANGE_MELEE);
        }
        if(!GetActionMode(oCreature, ACTION_MODE_DETECT))
        {
            ai_Debug("0i_actions", "209", " Using Detect mode.");
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            return TRUE;
        }
    }
    else
    {
        ai_Debug("0i_actions", "216", "Moving to invisible creature: " + GetName(oInvisible));
        ActionMoveToObject(oInvisible, TRUE, AI_RANGE_MELEE);
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
    ai_Debug("0i_actions", "236", GetName(oCreature) + " is moving out of area of effect!");
    ActionMoveToLocation(lLocation, TRUE);
}
int ai_MoralCheck(object oCreature)
{
    // If we are immune to fear then we are immune to MoralChecks!
    // Constructs and Undead are also immune to fear.
    int nRaceType = GetRacialType(oCreature);
    if(GetIsImmune(oCreature, IMMUNITY_TYPE_FEAR) ||
        nRaceType == RACIAL_TYPE_UNDEAD ||
        nRaceType == RACIAL_TYPE_CONSTRUCT) return FALSE;
    // Moral DC is AI_MORAL_DC - The number of allies.
    int nDC = AI_MORAL_DC - GetLocalInt(oCreature, AI_ALLY_NUMBERS);
    object oNearestEnemy = GetLocalObject(oCreature, AI_ENEMY_NEAREST);
    int nHpPercent = ai_GetPercHPLoss(oCreature);
    // We only make moral checks if we are below half hitpoints and the Difficulty should be adjusted to -10 at 0.
    if(nHpPercent <= AI_HEALTH_WOUNDED)
    {
        // Increase Difficulty by 10(50%).
        if(nHpPercent <= AI_HEALTH_BLOODY) nDC += AI_MORAL_INC_DC;
        if(nDC < 1) nDC = 1;
        ai_Debug("0i_talents", "257", "Moral check DC: " + IntToString(nDC) + ".");
        if(!WillSave(oCreature, nDC, SAVING_THROW_TYPE_FEAR, oNearestEnemy))
        {
            ai_Debug("0i_talents", "260", "Moral check failed, we are fleeing!");
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
    }
    if(nDC >= 11 && !ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK))
    {
        int nRoll = d6();
        // Cry out when you are overwhelmed!
        if(nRoll == 1) PlayVoiceChat(VOICE_CHAT_CUSS, oCreature);
        else if(nRoll == 2) PlayVoiceChat(VOICE_CHAT_BADIDEA, oCreature);
        else if(nRoll == 3) PlayVoiceChat(VOICE_CHAT_ENEMIES, oCreature);
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
    if(!ai_GetAssociateMode(oAssociate, AI_MODE_DEFENSIVE_CASTING))
    {
        if(ai_UseCreatureTalent(oAssociate, AI_TALENT_INDISCRIMINANT_AOE, nInMelee, nMaxLevel)) return TRUE;
        if(ai_UseCreatureTalent(oAssociate, AI_TALENT_DISCRIMINANT_AOE, nInMelee, nMaxLevel)) return TRUE;
    }
    if(ai_GetAssociateMode(oAssociate, AI_MODE_OFFENSIVE_CASTING)) return FALSE;
    // ********** PROTECTION/ENHANCEMENT/SUMMON TALENTS ************
    // Does our master want to be buffed first?
    object oTarget = OBJECT_INVALID;
    if(ai_GetAssociateMode(oAssociate, AI_MODE_BUFF_MASTER)) oTarget = GetMaster(oAssociate);
    return ai_TryDefensiveTalents(oAssociate, nInMelee, nMaxLevel, oTarget);
}
