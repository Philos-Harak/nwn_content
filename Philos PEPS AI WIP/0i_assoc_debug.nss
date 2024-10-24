/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_associates
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Scripts used for Associates.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions_debug"
// Return TRUE if the associate can attack based on current modes and actions.
int ai_CanIAttack(object oAssociate);
// Returns the nearest locked object from oMaster.
object ai_GetNearestLockedObject(object oCreature);
// Will look for the oTarget or go to the oSpeaker depending on the situation.
void ai_FindTheEnemy(object oCreature, object oSpeaker, object oTarget);
// Selects the correct response base on nCommand from oCommander.
// These are given from either a radial menu option or voice command.
void ai_SelectAssociateCommand(object oCreature, object oCommander, int nCommand);
// Set nAction for the caller to pass to their associates. i.e. For henchmans summons.
void ai_PassActionToAssociates(object oCreature, int nAction, int bStatus = TRUE);
// Set oCreature's ai scripts based on its first class or the variable "AI_DEFAULT_SCRIPT".
// bSetBasicAIScript set to TRUE will skip defensive and ambush tactic type scripts.
void ai_SetAssociateAIScript(object oCreature, int bCheckTacticScripts = TRUE);
// Returns TRUE if oCreature can speak.
int ai_CanISpeak(object oCreature);
// Cleansup any henchman actions and then removes them from the PC's faction.
void ai_FireHenchman(object oPC, object oHenchman);
// Will cast defensive spells (Buffs) on oPC's party from oCreature.
void ai_HenchmanCastDefensiveSpells(object oCreature, object oPC);
// Returns TRUE if we are starting combat due to an enemy being near.
// This should be checked after any "is in combat" checks.
int ai_CheckForCombat(object oCreature);
// Checks all perceived creatures to see if we should calculate a combat round
// or start combat for Associates.
void ai_AssociateEvaluateNewThreat(object oCreature, object oLastPerceived, string sPerception);
// Checks all perceived creatures to see if we should calculate a combat round
// or start combat for Monsters.
void ai_MonsterEvaluateNewThreat(object oCreature, object oLastPerceived, string sPerception);
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************

// Add to nw_ch_aca OnRested event script of henchman.
void ai_OnRested(object oCreature);

int ai_CanIAttack(object oAssociate)
{
    if(ai_GetIsCharacter(oAssociate)) return TRUE;
    int nAction = GetCurrentAction(oAssociate);
    return (!ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND) &&
        !ai_GetAIMode(oAssociate, AI_MODE_FOLLOW) &&
        nAction != ACTION_ITEMCASTSPELL &&
        nAction != ACTION_CASTSPELL);
}
object ai_GetNearestLockedObject(object oCreature)
{
    int nCnt = 1;
    object oMaster = GetMaster(oCreature);
    float fRange = GetLocalFloat(oCreature, AI_TRAP_CHECK_RANGE);
    location lCreature = GetLocation(oCreature);
    object oObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, lCreature, nCnt);
    while (oObject != OBJECT_INVALID || GetDistanceBetween(oMaster, oObject) > fRange)
    {
        if(GetLocked(oObject) && ai_GetIsInLineOfSight(oMaster, oObject)) return oObject;
        oObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, lCreature, ++nCnt);
    }
    return OBJECT_INVALID;
}
void ai_FindTheEnemy(object oCreature, object oSpeaker, object oTarget)
{
    if(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    float fDistance = GetDistanceBetween(oCreature, oTarget);
    ai_Debug("0i_associates", "71", " Distance: " + FloatToString(fDistance, 0, 2) +
             " AI_RULE_PERCEPTION_DISTANCE: " + FloatToString(GetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE), 0, 2) +
             " Hiding? " + IntToString(GetStealthMode(oTarget)));
    if(fDistance <= GetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE))
    {
        if(LineOfSightObject(oCreature, oTarget))
        {
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
            if(fDistance > AI_RANGE_CLOSE)
            {
                int bMoveForward = TRUE;
                // We check this because if the enemy is moving or has not
                // started acting then we don't want to move up on them as they
                // might move towards us! Just attack! Only sneak attack if they are busy.
                int nAction = GetCurrentAction(oTarget);
                ai_Debug("0i_associates", "85", GetName(oTarget) + " current action: " + IntToString(nAction));
                if(nAction == ACTION_MOVETOPOINT ||
                   nAction == ACTION_INVALID ||
                   nAction == ACTION_RANDOMWALK) bMoveForward = FALSE;
                // If they are attacking make sure it is in melee?
                // If not then don't move since they might be moving toward us.
                if(nAction == ACTION_ATTACKOBJECT)
                {
                    if(!ai_GetNumOfEnemiesInRange(oTarget)) bMoveForward = FALSE;
                }
                if(bMoveForward)
                {
                    ai_Debug("0i_associates", "97", "Moving towards " + GetName(oTarget));
                    ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE);
                    ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
                    return;
                }
                ai_Debug("0i_associates", "102", "Searching for " + GetName(oTarget));
                SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
                return;
            }
            ai_Debug("0i_associates", "106", "Moving and searching for " + GetName(oTarget));
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            ActionMoveToObject(oTarget, FALSE, AI_RANGE_MELEE);
            ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
            return;
        }
        ai_Debug("0i_associates", "112", "Moving towards " + GetName(oSpeaker));
        ActionMoveToObject(oSpeaker, TRUE, AI_RANGE_MELEE);
        ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING));
    }
}
void ai_ReactToAssociate(object oCreature, object oCommander)
{
    object oTarget = GetLocalObject(oCommander, AI_MY_TARGET);
    if (oTarget == OBJECT_INVALID) return;
    if(ai_GetIsInCombat(oCreature))
    {
        if(oCommander == GetMaster(oCreature) && ai_GetAIMode(oCreature, AI_MODE_DEFEND_MASTER))
        {
            ai_DoAssociateCombatRound(oCreature, oTarget);
        }
        else ai_DoAssociateCombatRound(oCreature);
        return;
    }
    ai_FindTheEnemy(oCreature, oCommander, oTarget);
}
void ai_SelectAssociateCommand(object oCreature, object oCommander, int nCommand)
{
    object oMaster = GetMaster(oCreature);
    // These nCommands can be issued even when the caller is busy.
    switch(nCommand)
    {
        // Master is being attacked by the enemy.
        case ASSOCIATE_COMMAND_MASTERGOINGTOBEATTACKED:
        {
            object oAttacker = GetGoingToBeAttackedBy(oMaster);
            ai_Debug("0i_associate", "120", GetName(oMaster) + " has been attack by " +
                     GetName(GetGoingToBeAttackedBy(oMaster)) + "!");
            // Used to set who monsters are attacking.
            int nAction = GetCurrentAction(oAttacker);
            if(nAction == ACTION_ATTACKOBJECT) SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oMaster);
            else if(nAction == ACTION_CASTSPELL || nAction == ACTION_ITEMCASTSPELL)
            {
                SetLocalObject(oAttacker, AI_ATTACKED_SPELL, oMaster);
            }
            if(!ai_GetIsBusy(oCreature) && ai_CanIAttack(oCreature))
            {
                if(ai_GetIsInCombat(oCreature)) ai_DoAssociateCombatRound(oCreature);
                else ai_FindTheEnemy(oCreature, oCommander, oAttacker);
            }
            return;
        }
        // Menu used by a player to have the henchman follow them.
        case ASSOCIATE_COMMAND_FOLLOWMASTER:
        {
            ai_Debug("0i_associate", "135", GetName(oMaster) + " has commanded " +
                   GetName(oCreature) + " to FOLLOW.");
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_FOLLOW, TRUE);
            ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
            // To follow we probably should be running and not searching or hiding.
            if(GetDetectMode(oCreature) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature)) SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
            if(GetStealthMode(oCreature)) SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            ai_PassActionToAssociates(oCreature, ACTION_FOLLOW);
            if(ai_IsInCombatRound(oCreature)) ai_ClearCombatState(oCreature);
            else ai_ClearCreatureActions(TRUE);
            SetLocalObject(oCreature, AI_FOLLOW_TARGET, oMaster);
            ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
            aiSaveAssociateAIModesToDb(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman go into NORMAL MODE.
        // We also attack the nearest, this keeps henchman going into combat quickly.
        case ASSOCIATE_COMMAND_ATTACKNEAREST:
        {
            ai_Debug("0i_associates", "158", GetName(oMaster) + " has commanded " +
                   GetName(oCreature) + " to attack nearest(NORMAL MODE).");
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
            // This resets a henchmens failed Moral save in combat.
            string sScript = GetLocalString(oCreature, AI_COMBAT_SCRIPT);
            if(sScript == "ai_coward")
            {
                sScript = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
                SetLocalString(oCreature, AI_COMBAT_SCRIPT, sScript);
            }
            if(!ai_GetIsBusy(oCreature))
            {
                object oEnemy = ai_GetNearestEnemy(oCreature, 1, 7, 7);
                if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oCreature, oEnemy) < AI_RANGE_BATTLEFIELD)
                {
                    ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
                    // If master is attacking a target we will attack them too!
                    if(!ai_GetIsInCombat(oCreature)) ai_SetCreatureTalents(oCreature, FALSE);
                    object oTarget = ai_GetAttackedTarget(oMaster);
                    if(oTarget != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature);
                    else ai_DoAssociateCombatRound(oCreature, oTarget);
                }
            }
            aiSaveAssociateAIModesToDb(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman stay where they are standing.
        case ASSOCIATE_COMMAND_STANDGROUND:
        {
            ai_Debug("0i_associate", "189", GetName(oMaster) + " has commanded " +
                   GetName(OBJECT_SELF) + " to STANDGROUND.");
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, TRUE);
            ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
            ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
            if(ai_IsInCombatRound(oCreature))
            {
                ai_EndCombatRound(oCreature);
                ai_ClearCombatState(oCreature);
                DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
                DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
            }
            ai_ClearCreatureActions(TRUE);
            aiSaveAssociateAIModesToDb(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman attack anyone who attacks them.
        case ASSOCIATE_COMMAND_GUARDMASTER:
        {
            ai_Debug("0i_associate", "211", GetName(oMaster) + " has commanded " +
                   GetName(oCreature) + " to GAURDMASTER.");
            ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, TRUE);
            ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
            ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
            if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature))
            {
                object oLastAttacker = GetLastHostileActor(oMaster);
                if(oLastAttacker != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature, oLastAttacker);
                else ai_FindTheEnemy(oCreature, oCommander, oCommander);
            }
            aiSaveAssociateAIModesToDb(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman heal them as soon as possible.
        case ASSOCIATE_COMMAND_HEALMASTER:
        {
            if(ai_GetIsInCombat(oCreature)) ai_TryHealingTalent(oCreature, ai_GetNumOfEnemiesInRange(oCreature), oCommander);
            else ai_TryHealing(oCreature, oCommander);
            return;
        }
        // Menu used by a player to toggle a henchmans casting options.
        case ASSOCIATE_COMMAND_TOGGLECASTING:
        {
            if(ai_GetMagicMode(oCreature, AI_MAGIC_NO_MAGIC))
            {
                ai_SetMagicMode(oCreature, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING, TRUE);
                ai_SetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will now cast defensive spells only.", AI_COLOR_GRAY, oCommander);
            }
            else if(ai_GetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING))
            {
                ai_SetMagicMode(oCreature, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING, TRUE);
                ai_SendMessages(GetName(oCreature) + " will now cast offensive spells only.", AI_COLOR_GRAY, oCommander);
            }
            else if(ai_GetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING))
            {
                ai_SetMagicMode(oCreature, AI_MAGIC_NO_MAGIC, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will now cast any spell.", AI_COLOR_GRAY, oCommander);
            }
            else
            {
                ai_SetMagicMode(oCreature, AI_MAGIC_NO_MAGIC, TRUE);
                ai_SetMagicMode(oCreature, AI_MAGIC_DEFENSIVE_CASTING, FALSE);
                ai_SetMagicMode(oCreature, AI_MAGIC_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will not use any magic.", AI_COLOR_GRAY, oCommander);
            }
            aiSaveAssociateAIModesToDb(oMaster, oCreature);
            return;
        }
    }
    // If we are busy then these nCommands are ignored.
    if(!ai_GetIsBusy(oCreature))
    {
        // Respond to shouts from friendly non-PCs only.
        if (ai_CanIAttack(oCreature))
        {
            if(nCommand == AI_ALLY_IS_WOUNDED) ai_TryHealing(oCreature, oCommander);
            // A friend sees an enemy. If we are not in combat lets seek them out too!
            if(nCommand == AI_ALLY_SEES_AN_ENEMY ||
               nCommand == AI_ALLY_HEARD_AN_ENEMY)
            {
                ai_Debug("0i_associates", "282", GetName(oCreature) + " receives notice that " +
                         GetName(oCommander) + " has seen/heard an enemy!" +
                         GetName(GetLocalObject(oCommander, AI_MY_TARGET)) + "!");
                ai_ReactToAssociate(oCreature, oCommander);
                return;
            }
            // A friend is in combat. Make some checks to see if we should help.
            else if(nCommand == AI_ALLY_ATKED_BY_WEAPON ||
                    nCommand == AI_ALLY_ATKED_BY_SPELL)
            {
                ai_Debug("0i_associates", "291", GetName(oCreature) + " receives notice that " +
                         GetName(oCommander) + " was attacked by an enemy!" +
                         GetName(GetLocalObject(oCommander, AI_MY_TARGET)) + "!");
                ai_ReactToAssociate(oCreature, oCommander);
                return;
            }
            else if(nCommand == AI_ALLY_IS_DEAD)
            { // Nothing at the moment.
                ai_Debug("0i_associates", "298", GetName(oCreature) + " receives notice that " +
                         GetName(oCommander) + " has died!");
                return;
            }
        }
        switch(nCommand)
        {
            case ASSOCIATE_COMMAND_MASTERATTACKEDOTHER:
            {
                ai_Debug("0i_associate", "307", GetName(oMaster) + " has attacked!");
                if(ai_CanIAttack(oCreature))
                {
                    if(ai_GetIsInCombat(oCreature)) ai_DoAssociateCombatRound(oCreature);
                    else ai_FindTheEnemy(oCreature, oCommander, ai_GetAttackedTarget(oCommander, TRUE, TRUE));
                }
                return;
            }
            // Master tried to open a door or chest that is locked.
            case ASSOCIATE_COMMAND_MASTERFAILEDLOCKPICK:
            {
                // In command mode we let the player tell us what to do.
                if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
                {
                    object oLock = ai_GetNearestLockedObject(oMaster);
                    //Check and see if our master want's us to open locks.
                    if(ai_GetAIMode(oCreature, AI_MODE_PICK_LOCKS) ||
                       ai_GetAIMode(oCreature, AI_MODE_BASH_LOCKS))
                    {
                        ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                        ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                        ai_AttemptToByPassLock(oCreature, oLock);
                    }
                }
                return;
            }
            // Master saw a trap.
            case ASSOCIATE_COMMAND_MASTERSAWTRAP:
            {
                // In command mode we let the player tell us what to do.
                if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED))
                {
                    object oTrap = GetLastTrapDetected(oMaster);
                    // Sometimes GetLastTrapDetected seems to fail.
                    if(oTrap == OBJECT_INVALID) oTrap = GetNearestTrapToObject(oMaster, TRUE);
                    //Check and see if our master want's us to disarm the trap.
                    if(ai_GetAIMode(oCreature, AI_MODE_DISARM_TRAPS))
                    {
                        ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                        ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                        SetTrapDetectedBy(oTrap, oCreature, TRUE);
                        ai_AttemptToDisarmTrap(oCreature, oTrap);
                    }
                }
                return;
            }
            // Menu used by a player to toggle henchmans search on and off.
            case ASSOCIATE_COMMAND_TOGGLESEARCH:
            {
                if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH))
                {
                    ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH, FALSE);
                    SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, FALSE);

                }
                else
                {
                    ai_HaveCreatureSpeak(oCreature, 6, ":29:46:27:33:35:");
                    ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH, TRUE);
                    SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, TRUE);
                }
                aiSaveAssociateAIModesToDb(oMaster, oCreature);
                return;
            }
            // Menu used by a player to toggle henchmans stealth on and off.
            case ASSOCIATE_COMMAND_TOGGLESTEALTH:
            {
                if(ai_GetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH))
                {
                    ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH);
                }
                else
                {
                    ai_HaveCreatureSpeak(oCreature, 6, ":29:46:28:42:31:35:");
                    ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH);
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH, TRUE);
                }
                aiSaveAssociateAIModesToDb(oMaster, oCreature);
                return;
            }
            // Menu used by a player to have the henchman try to bypass the nearest lock.
            case ASSOCIATE_COMMAND_PICKLOCK:
            {
                ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
                object oLock = ai_GetNearestLockedObject(oMaster);
                // Clear locked variable incase we tried already.
                string sID = ObjectToString(oCreature);
                SetLocalInt(oLock, "AI_LOCKED_" + sID, FALSE);
                ai_AttemptToByPassLock(oCreature, oLock);
                aiSaveAssociateAIModesToDb(oMaster, oCreature);
                return;
            }
            // Menu used by a player to have the henchman try to disarm the nearest trap.
            case ASSOCIATE_COMMAND_DISARMTRAP:
            {
                ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
                object oTrap = GetNearestTrapToObject(oMaster);
                // Clear trapped variable incase we tried already.
                string sID = ObjectToString(oCreature);
                ai_AttemptToDisarmTrap(oCreature, oTrap, TRUE);
                aiSaveAssociateAIModesToDb(oMaster, oCreature);
                return;
            }
            // Menu used by a player to open a henchmans inventory to give, move, or take.
            case ASSOCIATE_COMMAND_INVENTORY:
            {
                if(AI_OPEN_INVENTORY)
                {
                    ai_HaveCreatureSpeak(oCreature, 4, ":29:46:35:");
                    OpenInventory(oCreature, oCommander);
                }
                // Can't look at an associate's inventory.
                else
                {
                    ai_HaveCreatureSpeak(oCreature, 6, ":47:30:36:8:48:");
                    ai_SendMessages("You cannot open " + GetName(oCreature) + "'s inventory.", AI_COLOR_GRAY, oMaster);
                }
                return;
            }
            case ASSOCIATE_COMMAND_LEAVEPARTY:
            {
                if(AI_REMOVE_HENCHMAN_ON)
                {
                    ai_ClearCreatureActions();
                    ai_FireHenchman (GetPCSpeaker(), oCreature);
                    PlayVoiceChat (VOICE_CHAT_GOODBYE, oCreature);
                }
            }
        }
    }
}
void ai_PassActionToAssociates(object oCreature, int nAction, int bStatus = TRUE)
{
    int nAssociateType;
    object oAssociate;
    for(nAssociateType = 2; nAssociateType < 6; nAssociateType ++)
    {
        oAssociate = GetAssociate(nAssociateType);
        if(oAssociate != OBJECT_INVALID) SetActionMode(oAssociate, nAction, bStatus);
    }
}
void ai_SetAssociateAIScript(object oCreature, int bCheckTacticScripts = TRUE)
{
    string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
    int nAssociateType = GetAssociateType(oCreature);
    if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR && sCombatAI == "")
    {
        sCombatAI = "ai_a_default";
    }
    else if(sCombatAI == "ai_coward")
    {
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, sCombatAI);
        return;
    }
    else if(bCheckTacticScripts)
    {
        // They should have a skill ranks equal to their level + 1 to use a special AI.
        int nSkillNeeded = GetHitDice(oCreature) + 1;
        if(sCombatAI == "" || sCombatAI == "ai_a_ambusher")
        {
            // Ambusher: requires either Improved Invisibility or Invisibility.
            if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY, oCreature) ||
               GetHasSpell(SPELL_INVISIBILITY, oCreature))
            {
                    int bCast = ai_TryToCastSpell(oCreature, SPELL_IMPROVED_INVISIBILITY, oCreature);
                    if(!bCast) bCast = ai_TryToCastSpell(oCreature, SPELL_INVISIBILITY, oCreature);
                    if(bCast)
                    {
                        SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_a_ambusher");
                        return;
                    }
            }
            // Ambusher: Requires a Hide and Move silently skill equal to your level + 1.
            else if(GetSkillRank(SKILL_HIDE, oCreature) >= nSkillNeeded &&
                     GetSkillRank(SKILL_MOVE_SILENTLY, oCreature) >= nSkillNeeded)
            {
                SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_a_ambusher");
                return;
            }
        }
        // Defensive : requires Parry skill equal to your level or Expertise.
        else if(sCombatAI == "ai_a_defensive" ||
              (sCombatAI == "" &&
              (GetSkillRank(SKILL_PARRY, oCreature) >= nSkillNeeded ||
                  GetHasFeat(FEAT_EXPERTISE, oCreature) ||
                  GetHasFeat(FEAT_IMPROVED_EXPERTISE, oCreature))))
        {
            SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_a_defensive");
            return;
        }
    }
    else if(sCombatAI == "ai_cntrspell" || GetHasSpell(SPELL_LESSER_DISPEL, oCreature) ||
            GetHasSpell(SPELL_DISPEL_MAGIC, oCreature) || GetHasSpell(SPELL_GREATER_DISPELLING, oCreature))
    {
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_cntrspell");
        return;
    }
    if(sCombatAI == "")
    {
        // Select the best ai for this henchmen based on class.
        int nClass = GetClassByPosition(1, oCreature);
        // If they have more than one class use the default ai.
        if(GetClassByPosition(2, oCreature) != CLASS_TYPE_INVALID) sCombatAI = "ai_a_default";
        else if(nClass == CLASS_TYPE_BARBARIAN) sCombatAI = "ai_a_barbarian";
        else if(nClass == CLASS_TYPE_BARD) sCombatAI = "ai_a_bard";
        else if(nClass == CLASS_TYPE_CLERIC) sCombatAI = "ai_a_cleric";
        else if(nClass == CLASS_TYPE_DRUID) sCombatAI = "ai_a_druid";
        else if(nClass == CLASS_TYPE_FIGHTER) sCombatAI = "ai_a_fighter";
        else if(nClass == CLASS_TYPE_MONK) sCombatAI = "ai_a_monk";
        else if(nClass == CLASS_TYPE_PALADIN) sCombatAI = "ai_a_paladin";
        else if(nClass == CLASS_TYPE_RANGER) sCombatAI = "ai_a_ranger";
        else if(nClass == CLASS_TYPE_ROGUE) sCombatAI = "ai_a_rogue";
        else if(nClass == CLASS_TYPE_SORCERER) sCombatAI = "ai_a_sorcerer";
        else if(nClass == CLASS_TYPE_WIZARD) sCombatAI = "ai_a_wizard";
        //else if(nClass == CLASS_TYPE_ABERRATION) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_ANIMAL) sCombatAI = "ai_a_animal";
        //else if(nClass == CLASS_TYPE_CONSTRUCT) sCombatAI = "ai_a_animal";
        //else if(nClass == CLASS_TYPE_DRAGON) sCombatAI = "ai_a_dragon";
        //else if(nClass == CLASS_TYPE_ELEMENTAL) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_FEY) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_GIANT) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_HUMANOID) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_MAGICAL_BEAST) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_MONSTROUS) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_OOZE) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_OUTSIDER) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_UNDEAD) sCombatAI = "ai_a_default";
        //else if(nClass == CLASS_TYPE_VERMIN) sCombatAI = "ai_a_animal";
        else sCombatAI = "ai_a_default";
    }
    ai_Debug("0i_associates", "530", GetName(oCreature) + " is setting AI to " + sCombatAI);
    SetLocalString(oCreature, AI_COMBAT_SCRIPT, sCombatAI);
    SetLocalString(oCreature, AI_DEFAULT_SCRIPT, sCombatAI);
}
int ai_CanISpeak (object oCreature)
{
    int nRace = GetRacialType (oCreature);
    if (nRace == RACIAL_TYPE_ANIMAL || nRace == RACIAL_TYPE_BEAST ||
        nRace == RACIAL_TYPE_CONSTRUCT || nRace == RACIAL_TYPE_OOZE) return FALSE;
    return (GetAbilityScore (oCreature, ABILITY_INTELLIGENCE) > 7);
}
void ai_FireHenchman(object oPC, object oHenchman)
{
    if (oPC == OBJECT_INVALID || oHenchman == OBJECT_INVALID) return;
    // Now double-check that this is actually our master
    if (GetMaster (oHenchman) != oPC) return;
    // Turn off stealth mode
    SetActionMode (oHenchman, ACTION_MODE_STEALTH, FALSE);
    // Remove the henchman
    RemoveHenchman (oPC, oHenchman);
}
void ai_HenchmanCastDefensiveSpells (object oCreature, object oPC)
{
    ai_CastBuffs(oCreature, 3, 0, oPC);
}
int ai_CheckForCombat(object oCreature)
{
    object oEnemy = ai_GetNearestEnemy(oCreature, 1, 7, 7, 7, 5, TRUE);
    ai_Debug("0i_associate", "586", "Checking for Combat: oEnemy is " + GetName(oEnemy) +
             " Distance: " + FloatToString(GetDistanceBetween(oEnemy, oCreature), 0, 2));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oEnemy, oCreature) < AI_RANGE_PERCEPTION)
    {
        ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
        ai_Debug("0i_associates", "578", GetName(oCreature) + " is starting combat!");
        SetLocalObject (oCreature, AI_MY_TARGET, oEnemy);
        SpeakString(AI_I_SEE_AN_ENEMY, TALKVOLUME_SILENT_SHOUT);
        if(ai_CanIAttack(oCreature))
        {
            ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
            ai_SetCreatureTalents(oCreature, FALSE);
            ai_DoAssociateCombatRound(oCreature);
        }
        return TRUE;
    }
    return FALSE;
}
void ai_AssociateEvaluateNewThreat(object oCreature, object oLastPerceived, string sPerception)
{
    if(!ai_CanIAttack(oCreature)) return;
    int nAction = GetCurrentAction(oCreature);
    ai_Debug("0i_associates", "613", "nAction: " + IntToString(nAction));
    switch(nAction)
    {
        // These actions are uninteruptable.
        case ACTION_CASTSPELL :
        case ACTION_ITEMCASTSPELL :
        case ACTION_COUNTERSPELL : return;
        // Might be doing a special action that is not a defined action.
        case ACTION_INVALID :
        {
            int nCombatWait = GetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            ai_Debug("0i_associate", "624", "nCombatWait: " + IntToString(nCombatWait));
            if(nCombatWait)
            {
                if(ai_IsInCombatRound(oCreature, nCombatWait)) return;
                DeleteLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            }
        }
        // We need to reevaluate combat during these actions when we see a new enemy.
        //case ACTION_ATTACKOBJECT :
        //case ACTION_MOVETOPOINT :
    }
    if(ai_GetIsInCombat(oCreature))
    {
        object oTarget = ai_GetAttackedTarget(oCreature);
        ai_Debug("0i_associates", "638", "oTarget: " + GetName(oTarget) +
                 " oTarget Distance: " + FloatToString(GetDistanceBetween(oCreature, oTarget), 0, 2) +
                 " oLastPerceived Distance: " + FloatToString(GetDistanceBetween(oCreature, oLastPerceived), 0, 2));
        // If the LastPerceived is our target then don't recalculate.
        if(oTarget == oLastPerceived) return;
        // If we don't have a target or the lastperceived is closer than our
        // target then recalculate.
        if(oTarget == OBJECT_INVALID ||
           GetDistanceBetween(oCreature, oTarget) > GetDistanceBetween(oCreature, oLastPerceived))
        {
            ai_DoAssociateCombatRound(oCreature);
            return;
        }
        // Lets only reevaluate combat if the new enemy is more powerful
        // than the average enemies we already know about.
        int nPower = ai_GetCharacterLevels(oLastPerceived) / 2;
        int nEnemyPower = GetLocalInt(oCreature, AI_ENEMY_POWER) / (GetLocalInt(oCreature, AI_ENEMY_NUMBERS) + 1);
        ai_Debug("0i_associates", "655", GetName(oLastPerceived) + " nPower: " + IntToString(nPower) +
                 " nEnemyPower: " + IntToString(nEnemyPower));
        if(nEnemyPower < nPower) ai_DoAssociateCombatRound(oCreature);
        return;
    }
    // We are not in combat so alert our allies!
    ai_Debug("0i_associates", "661", GetName(oCreature) + " is starting combat!");
    ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
    SetLocalObject (oCreature, AI_MY_TARGET, oLastPerceived);
    SpeakString(sPerception, TALKVOLUME_SILENT_SHOUT);
    if(sPerception == AI_I_SEE_AN_ENEMY)
    {
        if(ai_CanIAttack(oCreature))
        {
            ai_SetCreatureTalents(oCreature, FALSE);
            ai_DoAssociateCombatRound(oCreature);
        }
    }
    else ai_FindTheEnemy(oCreature, oLastPerceived, oLastPerceived);
}
void ai_MonsterEvaluateNewThreat(object oCreature, object oLastPerceived, string sPerception)
{
    int nAction = GetCurrentAction(oCreature);
    ai_Debug("0i_associates", "672", "nAction: " + IntToString(nAction));
    switch(nAction)
    {
        // These actions are uninteruptable.
        case ACTION_CASTSPELL :
        case ACTION_ITEMCASTSPELL :
        case ACTION_COUNTERSPELL : return;
        // Might be doing a special action that is not a defined action.
        case ACTION_INVALID :
        {
            int nCombatWait = GetLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            ai_Debug("0i_associates", "683", "nCombatWait: " + IntToString(nCombatWait));
            if(nCombatWait)
            {
                if(ai_IsInCombatRound(oCreature, nCombatWait)) return;
                DeleteLocalInt(oCreature, AI_COMBAT_WAIT_IN_SECONDS);
            }
        }
        // We need to reevaluate combat during these actions when we see a new enemy.
        //case ACTION_ATTACKOBJECT :
        //case ACTION_MOVETOPOINT :
    }
    if(ai_GetIsInCombat(oCreature))
    {
        object oTarget = ai_GetAttackedTarget(oCreature);
        ai_Debug("0i_associates", "697", "oTarget: " + GetName(oTarget) +
                 " oTarget Distance: " + FloatToString(GetDistanceBetween(oCreature, oTarget), 0, 2) +
                 " oLastPerceived Distance: " + FloatToString(GetDistanceBetween(oCreature, oLastPerceived), 0, 2));
        // If the LastPerceived is our target then don't recalculate.
        if(oTarget == oLastPerceived) return;
        // If we don't have a target or the lastperceived is closer than our
        // target then recalculate.
        if(oTarget == OBJECT_INVALID ||
           GetDistanceBetween(oCreature, oTarget) > GetDistanceBetween(oCreature, oLastPerceived))
        {
            ai_DoMonsterCombatRound(oCreature);
            return;
        }
        // Now only reevaluate combat if the new enemy is more powerful
        // than the average enemies we already know about.
        int nPower = ai_GetCharacterLevels(oLastPerceived) / 2;
        int nEnemyPower = GetLocalInt(oCreature, AI_ENEMY_POWER) / (GetLocalInt(oCreature, AI_ENEMY_NUMBERS) + 1);
        ai_Debug("0i_associates", "714", GetName(oLastPerceived) + " nPower: " + IntToString(nPower) +
                 " nEnemyPower: " + IntToString(nEnemyPower));
        if(nEnemyPower < nPower) ai_DoMonsterCombatRound(oCreature);
        return;
    }
    // We are not in combat so alert our allies!
    ai_Debug("0i_associates", "720", GetName(oCreature) + " is starting combat!");
    SetLocalObject(oCreature, AI_MY_TARGET, oLastPerceived);
    SpeakString(sPerception, TALKVOLUME_SILENT_SHOUT);
    if(sPerception == AI_I_SEE_AN_ENEMY)
    {
        ai_SetCreatureTalents(oCreature, FALSE);
        ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
        ai_DoMonsterCombatRound(oCreature);
    }
    else ai_FindTheEnemy(oCreature, oLastPerceived, oLastPerceived);
}

//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************

void ai_OnRested(object oCreature)
{
    if(ai_GetMagicMode(oCreature, AI_MAGIC_BUFF_AFTER_REST))
    {
        int nLevel = ai_GetCharacterLevels(oCreature);
        float fDelay = StringToFloat(Get2DAString("restduration", "DURATION", nLevel));
        fDelay = (fDelay / 1000.0f) + 2.0f;
        DelayCommand(fDelay, ai_HenchmanCastDefensiveSpells(oCreature, GetMaster()));
    }
}
