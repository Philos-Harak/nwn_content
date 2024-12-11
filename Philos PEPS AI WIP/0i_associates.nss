/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_associates
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Scripts used for Associates.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
// Return TRUE if the associate can attack based on current modes and actions.
int ai_CanIAttack(object oAssociate);
// Returns the nearest locked object from oMaster.
object ai_GetNearestLockedObject(object oCreature);
// Will look for the oTarget or go to the oSpeaker depending on the situation.
void ai_FindTheEnemy(object oCreature, object oSpeaker, object oTarget, int bMonster);
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
int ai_CheckForCombat(object oCreature, int bMonster);
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

//******************************************************************************
//******************* Associate AI option scripts ******************************
//******************************************************************************

// Increments/Decrements the following distance of associates.
void ai_FollowIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Turns on/off Ranged combat for oAssociate.
void ai_Ranged(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Search for oAssociate.
void ai_Search(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Stealth for oAssociate.
void ai_Stealth(object oPC, object oAssociate, string sAssociateType);
// Turns on/off Picking/Bashing locks for oAssociate.
void ai_Locks(object oPC, object oAssociate, string sAssociateType, int nMode);
// Turns on/off Disarming of Traps for oAssociate.
void ai_Traps(object oPC, object oAssociate, string sAssociateType);
// Turns on/off the amount of speaking for oAssociate.
void ai_ReduceSpeech(object oPC, object oAssociate, string sAssociateType);
// Adjust magic use options for oAssociate.
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType);
// Adjusts loot options for oAssociate
void ai_Loot(object oPC, object oAssociate, string sAssociateType);
// Adjust loot options for oAssociate
void ai_Spontaneous(object oPC, object oAssociate, string sAssociateType);
// Increments/Decrements the magic use variable for the AI.
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType);
// Increments/Decrements the Loot Range use variable for the AI.
void ai_LootRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Increments/Decrements the Lock Range use variable for the AI.
void ai_LockRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Increments/Decrements the Trap Range use variable for the AI.
void ai_TrapRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType);
// Saves a new AI script for oAssociate.
void ai_SaveAIScript(object oPC, object oAssociate, int nToken);
// Button action for buffing a PC.
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType);
// Button action for setting healing ranges.
void ai_Heal_Button(object oPC, object oAssociate, int nIncrement, string sVar, string sAssociateType);
// Button action for turning healing on/off.
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType, int nMode);
// Button action for selecting a target to follow.
void ai_FollowTarget(object oPC, object oAssociate);
// Button action to allow associates to walk through creatures.
void ai_Ghost_Mode(object oPC, object oAssociate, string sAssociateType);
// Button action for giving commands to associates.
void ai_DoCommand(object oPC, object oAssociate, int nCommand);
// Button action to have associate do an action based on the target via OnPlayer Target event.
void ai_Action(object oPC, object oAssociate);
// Toggles between normal ai script and special tactic ai scripts.
void ai_AIScript(object oPC, object oAssociate, string sAssociate);
// Has the PC select a Trap and then place it on the ground from an associate.
void ai_HavePCPlaceTrap(object oPC, object oAssociate);
// Changes the camera view from either the player to the associate or back.
void ai_ChangeCameraView(object oPC, object oAssociate);
// Checks that the oAssociate is within sight and then opens the inventory.
void ai_OpenInventory(object oAssociate, object oPC);
// Executes an installed plugin.
void ai_PlugIn_Execute(object oPC, string sElem);

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
void ai_FindTheEnemy(object oCreature, object oSpeaker, object oTarget, int bMonster)
{
    if(GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    float fDistance = GetDistanceBetween(oCreature, oTarget);
    ai_Debug("0i_associates", "71", " Distance: " + FloatToString(fDistance, 0, 2) +
             " AI_RULE_PERCEPTION_DISTANCE: " + FloatToString(GetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE), 0, 2) +
             " Hiding? " + IntToString(GetStealthMode(oTarget)));
    float fPerceptionDistance;
    if(bMonster) fPerceptionDistance = GetLocalFloat(GetModule(), AI_RULE_PERCEPTION_DISTANCE);
    else fPerceptionDistance = AI_RANGE_PERCEPTION;
    if(fDistance <= fPerceptionDistance)
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
                    AssignCommand(oCreature, ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING)));
                    return;
                }
                ai_Debug("0i_associates", "102", "Searching for " + GetName(oTarget));
                SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
                return;
            }
            ai_Debug("0i_associates", "106", "Moving and searching for " + GetName(oTarget));
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            ActionMoveToObject(oTarget, FALSE, AI_RANGE_MELEE);
            AssignCommand(oCreature, ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING)));
            return;
        }
        ai_Debug("0i_associates", "112", "Moving towards " + GetName(oSpeaker));
        ActionMoveToObject(oSpeaker, TRUE, AI_RANGE_MELEE);
        AssignCommand(oCreature, ActionDoCommand(DeleteLocalInt(oCreature, AI_AM_I_SEARCHING)));
    }
}
void ai_ReactToAssociate(object oCreature, object oCommander, int bMonster)
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
    ai_FindTheEnemy(oCreature, oCommander, oTarget, bMonster);
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
                else ai_FindTheEnemy(oCreature, oCommander, oAttacker, FALSE);
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
                else ai_FindTheEnemy(oCreature, oCommander, oCommander, FALSE);
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
                ai_ReactToAssociate(oCreature, oCommander, FALSE);
                return;
            }
            // A friend is in combat. Make some checks to see if we should help.
            else if(nCommand == AI_ALLY_ATKED_BY_WEAPON ||
                    nCommand == AI_ALLY_ATKED_BY_SPELL)
            {
                ai_Debug("0i_associates", "291", GetName(oCreature) + " receives notice that " +
                         GetName(oCommander) + " was attacked by an enemy!" +
                         GetName(GetLocalObject(oCommander, AI_MY_TARGET)) + "!");
                ai_ReactToAssociate(oCreature, oCommander, FALSE);
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
                    else ai_FindTheEnemy(oCreature, oCommander, ai_GetAttackedTarget(oCommander, TRUE, TRUE), FALSE);
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
                if(!ai_GetAIMode(oCreature, AI_MODE_COMMANDED) && ai_CanIAttack(oCreature))
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
    if(oPC == OBJECT_INVALID || oHenchman == OBJECT_INVALID) return;
    // Now double-check that this is actually our master
    if(GetMaster(oHenchman) != oPC) return;
    // Turn off stealth mode
    SetActionMode(oHenchman, ACTION_MODE_STEALTH, FALSE);
    // Remove the henchman
    RemoveHenchman (oPC, oHenchman);
    ChangeToStandardFaction(oHenchman, STANDARD_FACTION_DEFENDER);
}
void ai_HenchmanCastDefensiveSpells (object oCreature, object oPC)
{
    ai_CastBuffs(oCreature, 3, 0, oPC);
}
int ai_CheckForCombat(object oCreature, int bMonster)
{
    object oEnemy = ai_GetNearestEnemy(oCreature, 1, 7, 7, 7, 5, TRUE);
    ai_Debug("0i_associate", "586", "Checking for Combat: oEnemy is " + GetName(oEnemy) +
             " Distance: " + FloatToString(GetDistanceBetween(oEnemy, oCreature), 0, 2));
    if(oEnemy != OBJECT_INVALID && GetDistanceBetween(oEnemy, oCreature) < GetLocalFloat(GetModule(), "AI_RULE_PERCEPTION_DISTANCE"))
    {
        //ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
        //SetLocalObject (oCreature, AI_MY_TARGET, oEnemy);
        //SpeakString(AI_I_SEE_AN_ENEMY, TALKVOLUME_SILENT_SHOUT);
        if(ai_CanIAttack(oCreature))
        {
            ai_Debug("0i_associates", "578", GetName(oCreature) + " is starting combat!");
            ai_SetCreatureTalents(oCreature, bMonster);
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
    else ai_FindTheEnemy(oCreature, oLastPerceived, oLastPerceived, FALSE);
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
    ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
    SetLocalObject(oCreature, AI_MY_TARGET, oLastPerceived);
    SpeakString(sPerception, TALKVOLUME_SILENT_SHOUT);
    if(sPerception == AI_I_SEE_AN_ENEMY)
    {
        ai_SetCreatureTalents(oCreature, FALSE);
        ai_DoMonsterCombatRound(oCreature);
    }
    else ai_FindTheEnemy(oCreature, oLastPerceived, oLastPerceived, TRUE);
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

//******************************************************************************
//******************* Associate AI option scripts ******************************
//******************************************************************************
void ai_UpdateToolTipUI(object oPC, string sWindowID1, string sWindowID2, string sToolTipBind, string sText)
{
    int nMenuToken = NuiFindWindow(oPC, sWindowID1);
    if(nMenuToken) NuiSetBind (oPC, nMenuToken, sToolTipBind, JsonString (sText));
    if(sWindowID2 != "")
    {
        int nWidgetToken = NuiFindWindow(oPC, sWindowID2);
        if(nWidgetToken) NuiSetBind (oPC, nWidgetToken, sToolTipBind, JsonString (sText));
    }
}
void ai_Ranged(object oPC, object oAssociate, string sAssociateType)
{
    //ai_ClearCreatureActions();
    if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using ranged combat.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ranged_tooltip", "  Ranged On");
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, FALSE);
        ai_EquipBestRangedWeapon(oAssociate);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is using melee combat only.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_ranged_tooltip", "  Ranged Off");
        ai_SetAIMode(oAssociate, AI_MODE_STOP_RANGED, TRUE);
        ai_EquipBestMeleeWeapon(oAssociate);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_FollowIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) + fIncrement;
    if(fAdjustment > 10.0) fAdjustment = 10.0;
    else if(fAdjustment < 1.0) fAdjustment = 1.0;
    SetLocalFloat(oAssociate, AI_FOLLOW_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 6, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sName;
    object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
    string sTarget;
    if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
    else
    {
        if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
        else sTarget = GetName(oPC);
    }
    float fRange = fAdjustment +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sRange = FloatToString(fRange, 0, 0);
    if(oPC == oAssociate)
    {
        sName = "  All associates";
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_follow_tooltip", sName + " follow");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]");
    }
    else
    {
        sName = "  " + GetName(oAssociate);
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_follow_tooltip", sName + " follow [" + sRange + " meters]");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_follow_target_tooltip", "  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]");
    }
}
void ai_Search(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search off.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search mode Off");
        SetActionMode(oPC, ACTION_MODE_DETECT, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, FALSE);
        if(ai_GetIsCharacter(oAssociate)) ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_search_tooltip", "  Everyone enter search mode");
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning search on.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search mode On");
        ai_SetAIMode(oPC, ACTION_MODE_DETECT, TRUE);
        SetActionMode(oPC, ACTION_MODE_DETECT, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH, TRUE);
        if(ai_GetIsCharacter(oAssociate)) ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_search_tooltip", "  Everyone leave search mode");
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Stealth(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth off.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth mode Off");
        SetActionMode(oAssociate, ACTION_MODE_STEALTH, FALSE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
        if(ai_GetIsCharacter(oAssociate)) ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_stealth_tooltip", "  Everyone enter stealth mode");
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " is turning stealth on.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth mode On");
        SetActionMode(oAssociate, ACTION_MODE_STEALTH, TRUE);
        ai_SetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH, TRUE);
        if(ai_GetIsCharacter(oAssociate)) ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_stealth_tooltip", "  Everyone leave stealth mode");
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Locks(object oPC, object oAssociate, string sAssociateType, int nMode)
{
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
    if(nMode == 1)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS))
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will stop picking locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_pick_locks_tooltip", "  Pick Locks Off [" + sRange + " meters]");
            ai_SetAIMode(oAssociate, AI_MODE_PICK_LOCKS, FALSE);
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will now pick locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_pick_locks_tooltip", "  Pick Locks On [" + sRange + " meters]");
            ai_SetAIMode(oAssociate, AI_MODE_PICK_LOCKS, TRUE);
        }
    }
    else if(nMode == 2)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS))
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will stop bashing locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_bash_locks_tooltip", "  Bash Locks Off [" + sRange + " meters]");
            ai_SetAIMode(oAssociate, AI_MODE_BASH_LOCKS, FALSE);
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will now bash locks.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_bash_locks_tooltip", "  Bash Locks On [" + sRange + " meters]");
            ai_SetAIMode(oAssociate, AI_MODE_BASH_LOCKS, TRUE);
        }
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Traps(object oPC, object oAssociate, string sAssociateType)
{
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will stop disarming traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_traps_tooltip", "  Disable Traps Off [" + sRange + " meters]");
        ai_SetAIMode(oAssociate, AI_MODE_DISARM_TRAPS, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will now disarm traps.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_traps_tooltip", "  Disable Traps On [" + sRange + " meters]");
        ai_SetAIMode(oAssociate, AI_MODE_DISARM_TRAPS, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_ReduceSpeech(object oPC, object oAssociate, string sAssociateType)
{
    if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK))
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will increase speech.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_quiet_tooltip", "  Reduced Speech Off");
        ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, FALSE);
    }
    else
    {
        SendMessageToPC(oPC, GetName(oAssociate) + " will reduce speech.");
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_quiet_tooltip", "  Reduced Speech On");
        ai_SetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK, TRUE);
    }
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_UseMagic(object oPC, object oAssociate, int bNoMagic, int bDefMagic, int bOffMagic, string sAssociateType)
{
    string sText = " is using any magic in combat.";
    if(bNoMagic) sText = " is not using magic in combat.";
    else if(bDefMagic) sText = " is only using defensive spells in combat.";
    else if(bOffMagic) sText = " is only using Offensive spells in combat.";
    SendMessageToPC(oPC, GetName(oAssociate) + sText);
    ai_SetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC, bNoMagic);
    ai_SetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING, bDefMagic);
    ai_SetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING, bOffMagic);
    sText = "  [Any]";
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  [None]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  [Defense]";
    else if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  [Offense]";
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_no_magic_tooltip", sText + " Turn magic use off");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_all_magic_tooltip", sText + " Use any magic");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_def_magic_tooltip", sText + " Use defensive magic only");
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_off_magic_tooltip", sText + " Use offensive magic only");
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Loot(object oPC, object oAssociate, string sAssociateType)
{
    int bLooting = !ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS);
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
    string sMessage, sText;

    if(bLooting)
    {
        sMessage = " is picking up items.";
        sText = "  Looting On [" + sRange + " meters]";
    }
    else
    {
        sMessage = " is not picking up items.";
        sText = "  Looting Off [" + sRange + " meters]";
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sMessage);
    ai_SetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS, bLooting);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_loot_tooltip", sText);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_Spontaneous(object oPC, object oAssociate, string sAssociateType)
{
    int bSpontaneous = !ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE);
    string sMessage, sText;

    if(bSpontaneous)
    {
        sMessage = " has stop casting spontaneous cure spells.";
        sText = "  Spontaneous casting Off";
    }
    else
    {
        sMessage = " will now cast spontaneous cure spells.";
        sText = "  Spontaneous casting On";
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sMessage);
    ai_SetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE, bSpontaneous);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_spontaneous_tooltip", sText);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_MagicIncrement(object oPC, object oAssociate, int nIncrement, string sAssociateType)
{
    int nAdjustment = GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT) + nIncrement;
    if(nAdjustment > 100) nAdjustment = 100;
    else if(nAdjustment < -100) nAdjustment = -100;
    SetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT, nAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 0, JsonInt(nAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sMagic = IntToString(nAdjustment);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_magic_level_tooltip", "  Magic Level [" + sMagic + "]");
}
void ai_LootRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 3, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    string sLoot = "  Looting Off [" + sRange + " meters]";
    if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sLoot = "  Looting On [" + sRange + " meters]";
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_loot_tooltip", sLoot);
}
void ai_LockRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 4, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    string sPick = "  Pick Locks Off [" + sRange + " meters]";
    string sBash = "  Bash Locks Off [" + sRange + " meters]";
    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sPick = "  Pick locks On [" + sRange + " meters]";
    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sBash = "  Pick locks On [" + sRange + " meters]";
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_pick_locks_tooltip", sPick);
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_bash_locks_tooltip", sBash);
}
void ai_TrapRangeIncrement(object oPC, object oAssociate, float fIncrement, string sAssociateType)
{
    float fAdjustment = GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE) + fIncrement;
    if(fAdjustment > 40.0) fAdjustment = 40.0;
    else if(fAdjustment < 0.0) fAdjustment = 0.0;
    SetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE, fAdjustment);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    JsonArraySetInplace(jAIData, 5, JsonFloat(fAdjustment));
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    string sRange = FloatToString(fAdjustment, 0, 0);
    string sText = "  Disable Traps Off [" + sRange + " meters]";
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps On [" + sRange + " meters]";
    ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_traps_tooltip", sText);
}
void ai_SaveAIScript(object oPC, object oAssociate, int nToken)
{
    string sScript = JsonGetString(NuiGetBind(oPC, nToken, "txt_ai_script"));
    string sOldScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(GetStringLeft(sScript, 5) != "ai_a_") ai_SendMessages(sScript + " does not have correct prefix it must have ai_a_ for associates! Did not change AI script.", AI_COLOR_RED, oPC);
    else if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages(sScript + " not found by ResMan! This is not a valid AI script.", AI_COLOR_RED, oPC);
    }
    else if(sScript != sOldScript)
    {
        SetLocalString(oAssociate, AI_COMBAT_SCRIPT, sScript);
        SetLocalString(oAssociate, AI_DEFAULT_SCRIPT, sScript);
        ai_SendMessages(GetName(oAssociate) + " is now using " + sScript + " AI script!", AI_COLOR_GREEN, oPC);
    }
    else ai_SendMessages(GetName(oAssociate) + " is already using this script! Did not change AI script.", AI_COLOR_RED, oPC);
}
void ai_Buff_Button(object oPC, object oAssociate, int nOption, string sAssociateType)
{
    if(nOption == 0)
    {
        int bRestBuff = !ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST);
        ai_SetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST, bRestBuff);
        if(bRestBuff)
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_buff_rest_tooltip", "  [On] Turn buffing after resting off.");
        }
        else
        {
            SendMessageToPC(oPC, GetName(oAssociate) + " will not cast long buffs after resting.");
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_buff_rest_tooltip", "  [Off] Turn buffing after resting on.");
        }
        aiSaveAssociateAIModesToDb(oPC, oAssociate);
    }
    else
    {
        if(!GetIsPossessedFamiliar(oAssociate))
        {
            object oEnemy = GetNearestEnemy(oAssociate);
            //ai_Debug("0e_nui", "865", "oEnemy: " + GetName(oEnemy) + " fDistance: " +
            //         FloatToString(GetDistanceBetween(oAssociate, oEnemy), 0, 2));
            if(GetDistanceBetween(oAssociate, oEnemy) > 30.0 ||
               oEnemy == OBJECT_INVALID)
            {
                ai_CastBuffs(oAssociate, nOption, 0, oPC);
            }
            else ai_SendMessages("You cannot buff while there are enemies nearby.", AI_COLOR_RED, oPC);
        }
        else ai_SendMessages("You cannot buff while possessing your familiar.", AI_COLOR_RED, oPC);
    }
}
void ai_Heal_Button(object oPC, object oAssociate, int nIncrement, string sVar, string sAssociateType)
{
    int nHeal = GetLocalInt(oAssociate, sVar);
    if(nIncrement > 0 && nHeal > 100 - nIncrement) nHeal = 100 - nIncrement;
    if(nIncrement < 0 && nHeal < abs(nIncrement)) nHeal = abs(nIncrement);
    nHeal += nIncrement;
    SetLocalInt(oAssociate, sVar, nHeal);
    string sHeal = IntToString(nHeal);
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    if(sVar == AI_HEAL_OUT_OF_COMBAT_LIMIT)
    {
        string sText = "  Will heal at or below [" + sHeal + "%] health out of combat";
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_out_tooltip", sText);
        JsonArraySetInplace(jAIData, 1, JsonInt(nHeal));
    }
    else if(sVar == AI_HEAL_IN_COMBAT_LIMIT)
    {
        string sText = "  Will heal at or below [" + sHeal + "%] health in combat";
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heal_in_tooltip", sText);
        JsonArraySetInplace(jAIData, 2, JsonInt(nHeal));
    }
    ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
}
void ai_Heal_OnOff(object oPC, object oAssociate, string sAssociateType, int nMode)
{
    string sText, sText2;
    if(nMode == 1)
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF))
        {
            ai_SetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF, FALSE);
            sText = "  Self healing On";
            sText2 = " will now use healing on themselves.";
        }
        else
        {
            ai_SetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF, TRUE);
            sText = "  Self healing Off";
            sText2 = " will stop using healing on themselves.";
        }
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_heals_onoff_tooltip", sText);
    }
    else
    {
        if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF))
        {
            ai_SetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF, FALSE);
            sText = "  Party healing On";
            sText2 = " will now use healing on party members.";
        }
        else
        {
            ai_SetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF, TRUE);
            sText = "  Party healing Off";
            sText2 = " will stop using healing on party members.";
        }
        ai_UpdateToolTipUI(oPC, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_healp_onoff_tooltip", sText);
    }
    SendMessageToPC(oPC, GetName(oAssociate) + sText2);
    aiSaveAssociateAIModesToDb(oPC, oAssociate);
}
void ai_FollowTarget(object oPC, object oAssociate)
{
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_FOLLOW_TARGET");
    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_Original_Guard()
{
    ResetHenchmenState();
    //Companions will only attack the Masters Last Attacker
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    object oMaster = GetMaster();
    object oLastAttacker = GetLastHostileActor(oMaster);
    // * for some reason this is too often invalid. still the routine
    // * works corrrectly
    SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", TRUE);
    HenchmenCombatRound(oLastAttacker);
    ai_SendMessages(GetName(OBJECT_SELF) + " is now guarding you!", AI_COLOR_YELLOW, oMaster);
}
void ai_Original_Follow()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DelayCommand(2.5, VoiceCanDo());
    object oMaster = GetMaster();
    ActionForceFollowObject(oMaster, GetFollowDistance());
    SetAssociateState(NW_ASC_IS_BUSY);
    DelayCommand(5.0, SetAssociateState(NW_ASC_IS_BUSY, FALSE));
    ai_SendMessages(GetName(OBJECT_SELF) + " is now following You!", AI_COLOR_YELLOW, oMaster);
}
void ai_Original_StandGround()
{
    SetAssociateState(NW_ASC_MODE_STAND_GROUND);
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    DelayCommand(2.0, VoiceCanDo());
    ActionAttack(OBJECT_INVALID);
    ClearActions(CLEAR_X0_INC_HENAI_RespondToShout1);
    ai_SendMessages(GetName(OBJECT_SELF) + " is now standing their ground!", AI_COLOR_YELLOW, GetMaster());}
void ai_Original_AttackNearest()
{
    ResetHenchmenState();
    SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE);
    SetAssociateState(NW_ASC_MODE_STAND_GROUND, FALSE);
    DetermineCombatRound();
    // * bonus feature. If master is attacking a door or container, issues VWE Attack Nearest
    // * will make henchman join in on the fun
    object oMaster = GetMaster();
    object oTarget = GetAttackTarget(oMaster);
    if (GetIsObjectValid(oTarget) == TRUE)
    {
        if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE || GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
        {
            ActionAttack(oTarget);
        }
    }
    ai_SendMessages(GetName(OBJECT_SELF) + " is now in normal mode!", AI_COLOR_YELLOW, oMaster);
}
void ai_Original_SetSearch(object oAssociate, int bTurnOn)
{
    SetActionMode(oAssociate, ACTION_MODE_DETECT, bTurnOn);
}
void ai_Original_SetStealth(object oAssociate, int bTurnOn)
{
    SetActionMode(oAssociate, ACTION_MODE_STEALTH, bTurnOn);
}
void ai_Philos_Guard(object oMaster, object oCreature)
{
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature))
    {
        object oLastAttacker = GetLastHostileActor(oMaster);
        if(oLastAttacker != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature, oLastAttacker);
        else AssignCommand(oCreature, ActionMoveToObject(oMaster, TRUE));
    }
    ai_SendMessages(GetName(oCreature) + " is now guarding you!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_Follow(object oMaster)
{
    object oCreature = OBJECT_SELF;
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
    // To follow we probably should be running and not searching or hiding.
    if(GetDetectMode(oCreature) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature)) SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
    if(GetStealthMode(oCreature)) SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW);
    ai_ClearCreatureActions(TRUE);
    if(ai_IsInCombatRound(oCreature)) ai_ClearCombatState(oCreature);
    object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
    if(oTarget == OBJECT_INVALID) oTarget = oMaster;
    ActionMoveToObject(oTarget, TRUE, ai_GetFollowDistance(oCreature));
    ai_SendMessages(GetName(oCreature) + " is now following " + GetName(oTarget) + "!", AI_COLOR_YELLOW, oMaster);
}
void ai_Philos_StandGround(object oMaster)
{
    object oCreature = OBJECT_SELF;
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, TRUE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_COMMANDED, FALSE);
    if(ai_IsInCombatRound(oCreature))
    {
        ai_EndCombatRound(oCreature);
        ai_ClearCombatState(oCreature);
        DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
        DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
    }
    ai_ClearCreatureActions(TRUE);
    ai_SendMessages(GetName(oCreature) + " is now standing their ground!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_AttackNearest(object oMaster, object oCreature)
{
    ai_SetAIMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
    ai_SetAIMode(oCreature, AI_MODE_FOLLOW, FALSE);
    ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
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
        else
        {
            object oTarget = GetLocalObject(oCreature, AI_FOLLOW_TARGET);
            if(oTarget == OBJECT_INVALID) oTarget = oMaster;
            AssignCommand(oCreature, ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature)));
        }
    }
    ai_SendMessages(GetName(oCreature) + " is now in normal mode!", AI_COLOR_YELLOW, oMaster);
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_SetSearch(object oMaster, object oCreature, string sAssociateType, int bTurnOn)
{
     if(bTurnOn)
     {
        ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH, TRUE);
        SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
        //ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, TRUE);
        ai_UpdateToolTipUI(oMaster, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search mode On");
    }
    else
    {
        ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_SEARCH, FALSE);
        SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
        //ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, FALSE);
        ai_UpdateToolTipUI(oMaster, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_search_tooltip", "  Search mode Off");
    }
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_Philos_SetStealth(object oMaster, object oCreature, string sAssociateType, int bTurnOn)
{
    if(bTurnOn)
    {
        ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH);
        SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
        ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH, TRUE);
        ai_UpdateToolTipUI(oMaster, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth mode On");
    }
    else
    {
        ai_SetAIMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
        SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
        //ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH, FALSE);
        ai_UpdateToolTipUI(oMaster, sAssociateType + "_ai_menu", sAssociateType + "_widget", "btn_stealth_tooltip", "  Stealth mode Off");
    }
    aiSaveAssociateAIModesToDb(oMaster, oCreature);
}
void ai_DoCommand(object oPC, object oAssociate, int nCommand)
{
    int nIndex = 1;
    if(oPC == oAssociate)
    {
        if(nCommand == 1) // Guard PC.
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Guard());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Guard());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_Guard(oPC, oAssociate);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_Guard(oPC, oAssociate);
                }
            }
        }
        else if(nCommand == 2) // Follow PC.
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Follow());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_Follow());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_Follow(oPC));
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_Follow(oPC));
                }
            }
        }
        else if(nCommand == 3) // Standground.
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_StandGround());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_StandGround());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_StandGround(oPC));
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Philos_StandGround(oPC));
                }
            }
        }
        else if(nCommand == 4) // Normal mode - i.e. Attack nearest.
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_AttackNearest());
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) AssignCommand(oAssociate, ai_Original_AttackNearest());
                }
            }
            // Use Philos AI commands.
            else
            {
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_AttackNearest(oPC, oAssociate);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Philos_AttackNearest(oPC, oAssociate);
                }
            }
        }
        if(nCommand == 5) // All associates toggle search mode
        {
            int bTurnOn = !ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_SEARCH);
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                ai_Original_SetSearch(oPC, bTurnOn);
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Original_SetSearch(oAssociate, bTurnOn);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Original_SetSearch(oAssociate, bTurnOn);
                }
            }
            else
            {
                ai_Philos_SetSearch(oPC, oPC, "pc", bTurnOn);
                string sAssociateType;
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID)
                    {
                        sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                        ai_Philos_SetSearch(oPC, oAssociate, sAssociateType, bTurnOn);
                    }
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID)
                    {
                        sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                        ai_Philos_SetSearch(oPC, oAssociate, sAssociateType, bTurnOn);
                    }
                }
            }
            if(bTurnOn)
            {
                ai_SendMessages("Everyone is now in search mode!", AI_COLOR_YELLOW, oPC);
                ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_search_tooltip", "  Everyone leave search mode");
            }
            else
            {
                ai_SendMessages("Everyone has left search mode!", AI_COLOR_YELLOW, oPC);
                ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_search_tooltip", "  Everyone enter search mode");
            }
        }
        if(nCommand == 6) // All associate use stealth mode
        {
            int bTurnOn = !ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_STEALTH);
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                ai_Original_SetStealth(oPC, bTurnOn);
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID) ai_Original_SetStealth(oAssociate, bTurnOn);
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID) ai_Original_SetStealth(oAssociate, bTurnOn);
                }
            }
            else
            {
                ai_Philos_SetStealth(oPC, oPC, "pc", bTurnOn);
                string sAssociateType;
                for(nIndex = 1; nIndex <= AI_MAX_HENCHMAN; nIndex++)
                {
                    oAssociate = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
                    if(oAssociate != OBJECT_INVALID)
                    {
                        sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                        ai_Philos_SetStealth(oPC, oAssociate, sAssociateType, bTurnOn);
                    }
                }
                for(nIndex = 2; nIndex < 6; nIndex++)
                {
                    oAssociate = GetAssociate(nIndex, oPC);
                    if(oAssociate != OBJECT_INVALID)
                    {
                        sAssociateType = ai_GetAssociateType(oPC, oAssociate);
                        ai_Philos_SetStealth(oPC, oAssociate, sAssociateType, bTurnOn);
                    }
                }
            }
            if(bTurnOn)
            {
                ai_SendMessages("Everyone is now in stealth mode.", AI_COLOR_YELLOW, oPC);
                ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_stealth_tooltip", "  Everyone leave stealth mode");
            }
            else
            {
                ai_SendMessages("Everyone has left stealth mode.", AI_COLOR_YELLOW, oPC);
                ai_UpdateToolTipUI(oPC, "pc_cmd_menu", "pc_widget", "btn_cmd_stealth_tooltip", "  Everyone enter stealth mode");
            }
        }
    }
    else
    {
        if(nCommand == 1)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_Guard());
            }
            else ai_Philos_Guard(oPC, oAssociate);
        }
        else if(nCommand == 2)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_Follow());
            }
            else AssignCommand(oAssociate, ai_Philos_Follow(oPC));
        }
        else if(nCommand == 3)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_StandGround());
            }
            else AssignCommand(oAssociate, ai_Philos_StandGround(oPC));
        }
        else if(nCommand == 4)
        {
            // Not using Philos Henchman AI. Use vanilla commands.
            if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) == "")
            {
                AssignCommand(oAssociate, ai_Original_AttackNearest());
            }
            else ai_Philos_AttackNearest(oPC, oAssociate);
        }
    }
}
void ai_Action(object oPC, object oAssociate)
{
    if(oPC == oAssociate)
    {
        DeleteLocalObject(oPC, "NW_ASSOCIATE_COMMAND");
        SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION_ALL");
        ai_SendMessages("Party is in action mode!", AI_COLOR_YELLOW, oPC);
    }
    else
    {
        SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
        SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_ACTION");
        ai_SendMessages(GetName(oAssociate) + " is in action mode!", AI_COLOR_YELLOW, oPC);
    }
    EnterTargetingMode(oPC, OBJECT_TYPE_ALL, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_AIScript(object oPC, object oAssociate, string sAssociateType)
{
    if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
    {
        string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
        if(sScript == "ai_a_ambusher")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_peaceful");
            ai_SendMessages(GetName(oAssociate) + " is now using peaceful tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using peaceful tactics");
        }
        else if(sScript == "ai_a_peaceful")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_defensive");
            ai_SendMessages(GetName(oAssociate) + " is now using defensive tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using defensive tactics");
        }
        else if(sScript == "ai_a_defensive")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ranged");
            ai_SendMessages(GetName(oAssociate) + " is now using ranged tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ranged tactics");
        }
        else if(sScript == "ai_a_ranged")
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_cntrspell");
            ai_SendMessages(GetName(oAssociate) + " is now using counter spell tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using counter spell tactics");
        }
        else if(sScript == "ai_a_cntrspell")
        {
            sScript = GetLocalString(oAssociate, AI_DEFAULT_SCRIPT);
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, sScript);
            string sText;
            if(sScript == "ai_a_ambusher") sText = "ambush";
            else sText = "normal";
            ai_SendMessages(GetName(oAssociate) + " is now using " + sText + " tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using " + sText + " tactics");
        }
        else
        {
            SetLocalString(oAssociate, AI_COMBAT_SCRIPT, "ai_a_ambusher");
            ai_SendMessages(GetName(oAssociate) + " is now using ambush tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
    }
    else
    {
        if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using coward tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using coward tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using defensive tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using defensive tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, TRUE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using ranged tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ranged tactics");
        }
        else if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate))
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using normal tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
        else
        {
            SetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, TRUE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_COWARDLY, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, FALSE, oAssociate);
            SetCombatCondition(X0_COMBAT_FLAG_RANGED, FALSE, oAssociate);
            ai_SendMessages(GetName(oAssociate) + " is now using ambush tactics in combat.", AI_COLOR_YELLOW, oPC);
            ai_UpdateToolTipUI(oPC, sAssociateType + "_cmd_menu", sAssociateType + "_widget", "btn_cmd_ai_script_tooltip", "  Using ambush tactics");
        }
    }
}
void ai_HavePCPlaceTrap(object oPC, object oAssociate)
{
    SetLocalObject(oPC, AI_TARGET_ASSOCIATE, oAssociate);
    SetLocalString(oPC, AI_TARGET_MODE, "ASSOCIATE_GET_TRAP");
    ai_SendMessages(GetName(oAssociate) + " select a trap to place.", AI_COLOR_YELLOW, oPC);
    OpenInventory(oAssociate, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_ITEM, MOUSECURSOR_ACTION, MOUSECURSOR_NOWALK);
}
void ai_ChangeCameraView(object oPC, object oAssociate)
{
    object oCamAssociate = GetLocalObject(oPC, "AI_CAMERA_ON_ASSOCIATE");
    if(oCamAssociate == oAssociate)
    {
        DeleteLocalObject(oPC, "AI_CAMERA_ON_ASSOCIATE");
        AttachCamera(oPC, oPC);
    }
    else
    {
        SetLocalObject(oPC, "AI_CAMERA_ON_ASSOCIATE", oAssociate);
        AttachCamera(oPC, oAssociate);
    }
}
void ai_OpenInventory(object oAssociate, object oPC)
{
    // Funny things happen when you open associate inventories when they are not
    // within sight.
    if(LineOfSightObject(oPC, oAssociate))
    {
        OpenInventory(oAssociate, oPC);
    }
    else ai_SendMessages(GetName(oAssociate) + " is not within sight!", AI_COLOR_RED, oPC);
}
void ai_PlugIn_Execute(object oPC, string sElem)
{
    int nIndex = StringToInt(GetStringRight(sElem, 1)) - 1;
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    string sScript = JsonGetString(JsonArrayGet(jPlugins, nIndex));
    if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
    {
        ai_SendMessages(sScript + " not found by ResMan!", AI_COLOR_RED, oPC);
    }
    else
    {
        ai_SendMessages("Executing " + sScript + " script.", AI_COLOR_GREEN, oPC);
        ExecuteScript(sScript, oPC);
    }
}
