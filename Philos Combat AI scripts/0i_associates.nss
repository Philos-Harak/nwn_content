/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_associates
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Scripts used for Associates.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_states_cond"
#include "0i_actions"
//#include "0i_actions_debug"

// Chooses an action while in combat and executes it for oCreature.
void ai_DoAssociateCombatRound(object oCreature, object oTarget = OBJECT_INVALID);
// Return TRUE if the associate can attack based on current modes and actions.
int ai_CanIAttack(object oAssociate);
// Returns the nearest locked object from oMaster.
object ai_GetNearestLockedObject(object oCreature);
// Returns TRUE if the caller can open oObject.
// Checks to see if oObject is locked and/or if a key is needed to open oObject
// by oCreature.
int ai_CanIOpenObject(object oCreature, object oObject);
// Returns TRUE if oCreature opens oLocked object.
// This will make oCreature open oLocked either by picking or casting a spell.
int ai_AttemptToByPassLock(object oCreature, object oLocked);
// Returns TRUE if oCreature disarms oTrap.
// bShout if TRUE oCreature will shout out what happens.
int ai_AttemptToDisarmTrap(object oCreature, object oTrap, int bShout = FALSE);
// Returns TRUE if the caller casts Knock on oLocked object.
int ai_AttempToCastKnockSpell(object oCreature, object oLocked);
// Returns TRUE if the caller's distance is greater than fDistance from their
// master. Unless they are cowardly or in stand ground mode.
// This will also force the caller to move towards their master.
int ai_StayCloseToMaster(object oCreature, float fDistance = AI_RANGE_PERCEPTION);
// Returns TRUE if oCreature can hear or see oEnemy. Uses skills to check.
int ai_PerceiveEnemy(object oCreature, object oEnemy);
// oCreature will move into the area looking for creatures.
void ai_ScoutAhead(object oCreature);
// Selects the correct response base on nCommand from oCommander.
// These are given from either a radial menu option or voice command.
void ai_SelectAssociateCommand(object oCreature, object oCommander, int nCommand);
// Return the distance that is set for how close we should follow our master.
float ai_GetFollowDistance(object oCreature);
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
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
// These scripts are one line inserts for the creature event they go at the end.
// example ai_OnDeath goes at the end of the OnDeath event (nw_c2_default7).

// Add to nw_c2_default7 OnDeath script of monsters and
// add to nw_ch_ac7 OnDeath event script of henchman.
void ai_OnDeath(object oCreature, object oKiller);
// Add to nw_c2_default9 OnSpawn event script of monsters and
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal);
// Add to nw_ch_ac9 OnSpawn event script of henchman.
void ai_OnAssociateSpawn(object oCreature);
// Add to nw_ch_aca OnRested event script of henchman.
void ai_OnRested(object oCreature);

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
        //ai_Debug("0i_actions", "80", "********** " + GetName (oCreature) + " **********");
        //ai_Debug("0i_actions", "81", "********** " + sAI + " **********");
        if(oTarget != OBJECT_INVALID) SetLocalObject(oCreature, "AI_TARGET", oTarget);
        // We clear actions here and setup multiple actions to the queue for oCreature.
        ai_ClearCreatureActions(oCreature);
        //ai_Counter_Start();
        ExecuteScript(sAI, oCreature);
        //ai_Counter_End(GetName(oCreature) + " is ending round.");
        return;
    }
    // Check to see if we just didn't see the enemies.
    if (GetLocalInt(oCreature, AI_ENEMY_NUMBERS) &&
        ai_SearchForInvisibleCreature(oCreature)) return;
    // We have exhausted our check for an enemy. Combat is over.
    ai_ClearCombatState(oCreature);
    //ai_Debug("0i_actions", "95", GetName (OBJECT_SELF) + "'s combat has ended!");
}
int ai_CanIAttack(object oAssociate)
{
    int nAction = GetCurrentAction(oAssociate);
    return (!ai_GetAssociateMode(oAssociate, AI_MODE_STAND_GROUND) &&
        !ai_GetAssociateMode(oAssociate, AI_MODE_FOLLOW) &&
        nAction != ACTION_ITEMCASTSPELL &&
        nAction != ACTION_CASTSPELL);
}
object ai_GetNearestLockedObject(object oCreature)
{
    int nCnt = 1;
    location lCreature = GetLocation(oCreature);
    object oObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, lCreature, nCnt);
    while (oObject != OBJECT_INVALID)
    {
        if(GetLocked(oObject)) return oObject;
        if(++nCnt > 10) break;
        oObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, lCreature, nCnt);
    }
    return OBJECT_INVALID;
}
int ai_CanIOpenObject(object oCreature, object oObject)
{
    string sLockKeyTag = GetLockKeyTag(oObject);
    if(sLockKeyTag == "") return TRUE;
    return (ai_GetCreatureHasItem(oCreature, sLockKeyTag, FALSE) != OBJECT_INVALID);
}
int ai_AttemptToByPassLock(object oCreature, object oLocked)
{
    //ai_Debug("0i_associates", "126", "oCreature: " + GetName(oCreature) + " oLocked:" + GetName(oLocked));
    //ai_Debug("0i_associates", "127", "Trapped?: " + IntToString(GetIsTrapped(oLocked)) +
    //       " Trap detected?:" + IntToString(GetTrapDetectedBy(oLocked, oCreature)));
    // Attempt to cast knock because its always safe to cast it, even on a trapped object.
    if(ai_AttempToCastKnockSpell(oLocked, oCreature)) return TRUE;
    // First, let's see if we notice that it's trapped
    if(GetIsTrapped(oLocked) && GetTrapDetectedBy(oCreature, oLocked))
    {
        // Ick! Try and disarm the trap first
        PlayVoiceChat(VOICE_CHAT_LOOKHERE, oCreature);
        if(!ai_AttemptToDisarmTrap(oCreature, oLocked, TRUE))
        {
            PlayVoiceChat(VOICE_CHAT_NO, oCreature);
            return FALSE;
        }
    }
    // We might be able to open this.
    int bCanDo = FALSE;
    string sKeyTag = GetLockKeyTag(oLocked);
    //ai_Debug("0i_associates", "145", "sKeyTag: " + sKeyTag);
    if(sKeyTag != "")
    {
        // Do we have the key?
        object oItem = ai_GetCreatureHasItem(oCreature, sKeyTag, FALSE);
        if(oItem != OBJECT_INVALID)
        {
            ActionOpenDoor(oLocked);
            bCanDo = TRUE;
        }
    }
    int bNeedKey = GetLockKeyRequired(oLocked);
    // We don't have the key and a key is required. So we are done!
    //ai_Debug("0i_associates", "158", "bCanDo: " + IntToString(bCanDo) +
    //       " bNeedKey:" + IntToString(bNeedKey));
    if(!bCanDo && bNeedKey)
    {
        // Can't open this, so skip the checks
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
        return FALSE;
    }
    // Now, let's try and pick the lock first
    int nSkill = GetSkillRank(SKILL_OPEN_LOCK, oCreature);
    string sName = ai_RemoveIllegalCharacters(GetName(oCreature));
    //ai_Debug("0i_associates", "169", "bCanDo: " + IntToString(bCanDo) +
    //       " nSkill:" + IntToString(nSkill) + " CanWeUsePlaceable?: " + IntToString(CanWeUsePlaceable(oLocked)) +
    //       " Attemp Pick: " + IntToString(GetLocalInt(oLocked, "0_ATTEMPT_PICK_" + sName)));
    if(!bCanDo && nSkill > 0 && ai_CanIOpenObject(oCreature, oLocked) && !GetLocalInt(oLocked, "0_ATTEMPT_PICK_" + sName))
    {
        object oItem = ai_GetCreatureHasItem (oCreature, "0_thief_tools", FALSE);
        ai_ClearCreatureActions(oCreature);
        if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANDO, oCreature);
        ActionWait(1.0);
        ActionUseSkill(SKILL_OPEN_LOCK, oLocked, 0, oItem);
        ActionWait(1.0);
        bCanDo = TRUE;
        // Set that we have tried to pick this... only do once. Keeps us from
        // trying over and over!
        SetLocalInt(oLocked, "0_ATTEMPT_PICK_" + sName, TRUE);
    }
    if(!bCanDo) bCanDo = ai_AttempToCastKnockSpell(oCreature, oLocked);
    //ai_Debug("0i_associates", "186", "bCanDo: " + IntToString(bCanDo) +
    //       " CanWeOpenObject?: " + IntToString(CanWeOpenObject(oLocked)));
    if(!bCanDo && ai_CanIOpenObject(oCreature, oLocked))
    {
        ai_ClearCreatureActions(oCreature);
        // Check to make sure we are using a melee weapon.
        if(ai_GetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)) ||
           ai_EquipBestMeleeWeapon(oCreature))
        {
            ActionWait(1.0);
            ActionAttack(oLocked);
            bCanDo = TRUE;
        }
    }
    // If we didn't, let the player know
    if(!bCanDo && !ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
    return bCanDo;
}
int ai_AttemptToDisarmTrap(object oCreature, object oTrap, int bShout = FALSE)
{
    if(!GetIsTrapped(oTrap)) return FALSE;
    int bValid = GetIsObjectValid(oTrap);
    int bISawTrap = GetTrapDetectedBy(oTrap, oCreature);
    int bCloseEnough = GetDistanceBetween(oTrap, oCreature) <= 15.0;
    int bInLineOfSight = ai_GetIsInLineOfSight(oCreature, oTrap);
    if(!bValid || !bISawTrap || !bCloseEnough || !bInLineOfSight)
    {
        if(bShout) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
        return FALSE;
    }
    string sID = ObjectToString(oTrap);
    int nSkill = GetSkillRank(SKILL_DISABLE_TRAP, oCreature);
    int nTrapDC = GetTrapDisarmDC(oTrap);
    if(nSkill > 0 && GetTrapDisarmable(oTrap))
    {
        object oItem = ai_GetCreatureHasItem (oCreature, "0_thief_tools", FALSE);
        ai_ClearCreatureActions(oCreature);
        ActionUseSkill(SKILL_DISABLE_TRAP, oTrap, 0, oItem);
        ActionDoCommand(PlayVoiceChat(VOICE_CHAT_TASKCOMPLETE, oCreature));
        return TRUE;
    }
    if(GetHasSpell(SPELL_FIND_TRAPS, oCreature) && GetTrapDisarmable(oTrap) && !GetLocalInt(oTrap, "AI_USE_FIND_TRAPS"))
    {
        ai_ClearCreatureActions(oCreature);
        ActionCastSpellAtObject(SPELL_FIND_TRAPS, oTrap);
        SetLocalInt(oTrap, "AI_USE_FIND_TRAPS", 10);
        return TRUE;
    }
    // MODIFIED February 7 2003. Merged the 'attack object' inside of the bshout
    // this is not really something you want the henchmen just to go and do
    // spontaneously
    else if(bShout)
    {
        ai_ClearCreatureActions(oCreature);
        if(GetLocalInt(oCreature, "X0_L_SAWTHISTRAPALREADY" + sID) != 10)
        {
           //StrRef(40551) "This trap can never be disarmed!"
            string sSpeak = GetStringByStrRef(40551);
            SendMessageToPC(GetMaster(oCreature), sSpeak);
            SetLocalInt(oCreature, "X0_L_SAWTHISTRAPALREADY" + sID, 10);
        }
        if(GetObjectType(oTrap) != OBJECT_TYPE_TRIGGER)
        {
            ActionAttack(oTrap);
            return TRUE;
        }
        // Throw ourselves on it nobly! :-)
        ActionMoveToLocation(GetLocation(oTrap));
        SetFacingPoint(GetPositionFromLocation(GetLocation(oTrap)));
        ActionRandomWalk();
        return TRUE;
    }
    if(nSkill < 1) return FALSE;
    // * Put a check in so that when a henchmen who cannot disarm a trap
    // * sees a trap they do not repeat their voiceover forever
    if (GetLocalInt(oCreature, "X0_L_SAWTHISTRAPALREADY" + sID) != 10)
    {
        PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
        SetLocalInt(oCreature, "X0_L_SAWTHISTRAPALREADY" + sID, 10);
        string sSpeak = GetStringByStrRef(40551);
        SendMessageToPC(GetMaster(oCreature), sSpeak);
    }
    return FALSE;
}
int ai_AttempToCastKnockSpell(object oCreature, object oLocked)
{
    // If that didn't work, let's try using a knock spell
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
int ai_StayCloseToMaster(object oCreature, float fDistance = AI_RANGE_PERCEPTION)
{
    if(ai_GetAssociateMode(oCreature, AI_MODE_STAND_GROUND) ||
        GetLocalString(oCreature, AI_COMBAT_SCRIPT) == "ai_coward") return FALSE;
    object oMaster = GetMaster(oCreature);
    if(GetDistanceBetween(oMaster, oCreature) < fDistance) return FALSE;
    ai_ClearCreatureActions(oCreature);
    //ai_Debug("0i_associates", "293", "We are too far away! Move to our master.");
    ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
    return TRUE;
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
void ai_FindTheEnemy(object oCreature, object oCommander, object oTarget)
{
    //ai_Debug("0i_associates", "368", " Distance: " + FloatToString(GetDistanceBetween(oCreature, oTarget), 0, 2));
    if(LineOfSightObject(oCreature, oCommander))
    {
        float fDistance = GetDistanceBetween(oCreature, oTarget);
        if(fDistance > AI_RANGE_CLOSE)
        {
            //ai_Debug("0i_associates", "374", "Moving towards " + GetName(oTarget));
            ActionMoveToObject(oTarget, TRUE, AI_RANGE_CLOSE - 0.5f);
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
        }
        else
        {
            //ai_Debug("0i_associates", "379", "Searching for " + GetName(oTarget));
            SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
            ActionMoveToObject(oTarget, TRUE, AI_RANGE_MELEE);
            SetLocalInt(oCreature, AI_AM_I_SEARCHING, TRUE);
        }
    }
}
void ai_ReactToAssociate(object oCreature, object oCommander)
{
    object oTarget = GetLocalObject(oCommander, AI_MY_TARGET);
    if (oTarget == OBJECT_INVALID) return;
    if(ai_GetIsInCombat(oCreature))
    {
        if(oCommander == GetMaster(oCreature) && ai_GetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER))
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
            //ai_Debug("0i_associate", "405", GetName(oMaster) + " has been attack by " +
            //         GetName(GetGoingToBeAttackedBy(oMaster)) + "!");
            // Used to set who monsters are attacking.
            int nAction = GetCurrentAction(oAttacker);
            if(nAction == ACTION_ATTACKOBJECT) SetLocalObject(oAttacker, AI_ATTACKED_PHYSICAL, oMaster);
            else if(nAction == ACTION_CASTSPELL || nAction == ACTION_ITEMCASTSPELL)
            {
                SetLocalObject(oAttacker, AI_ATTACKED_SPELL, oMaster);
            }
            if(ai_GetIsInCombat(oCreature))
            {
                if(!ai_GetIsBusy(oCreature) && ai_CanIAttack(oCreature)) ai_DoAssociateCombatRound(oCreature);
            }
            else ai_SearchForInvisibleCreature(oCreature);
            return;
        }
        // Menu used by a player to have the henchman follow them.
        case ASSOCIATE_COMMAND_FOLLOWMASTER:
        {
            //ai_Debug("0i_associate", "424", GetName(oMaster) + " has commanded " +
            //       GetName(oCreature) + " to FOLLOW.");
            ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, TRUE);
            // To follow we probably should be running and not searching or hiding.
            if(GetDetectMode(oCreature) && !GetHasFeat(FEAT_KEEN_SENSE, oCreature)) SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
            if(GetStealthMode(oCreature)) SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
            ai_PassActionToAssociates(oCreature, ACTION_FOLLOW);
            if(ai_IsInCombatRound(oCreature)) ai_EndCombatRound(oCreature);
            DeleteLocalObject(oCreature, AI_ATTACKED_PHYSICAL);
            DeleteLocalObject(oCreature, AI_ATTACKED_SPELL);
            ai_ClearCreatureActions(oCreature, TRUE);
            ActionMoveToObject(oMaster, TRUE, ai_GetFollowDistance(oCreature));
            ai_SaveAssociateConversationData(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman go into NORMAL MODE.
        // We also attack the nearest, this keeps henchman going into combat quickly.
        case ASSOCIATE_COMMAND_ATTACKNEAREST:
        {
            //ai_Debug("0i_associates", "445", GetName(oMaster) + " has commanded " +
            //       GetName(oCreature) + " to attack nearest(NORMAL MODE).");
            ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
            // This resets a henchmens failed Moral save in combat.
            ai_SetAssociateAIScript(oCreature);
            if(!ai_GetIsBusy(oCreature) && ai_GetNearestEnemy(oCreature, 1, 7, 7) != OBJECT_INVALID)
            {
                ai_HaveCreatureSpeak(oCreature, 5, ":0:1:2:3:6:");
                // If master is attacking a target we will attack them too!
                object oTarget = ai_GetAttackedTarget(oMaster);
                if(oTarget != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature);
                else ai_DoAssociateCombatRound(oCreature, oTarget);
            }
            ai_SaveAssociateConversationData(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman stay where they are standing.
        case ASSOCIATE_COMMAND_STANDGROUND:
        {
            //ai_Debug("0i_associate", "467", GetName(oMaster) + " has commanded " +
            //       GetName(OBJECT_SELF) + " to STANDGROUND.");
            ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, TRUE);
            ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
            ai_PassActionToAssociates(oCreature, ACTION_FOLLOW, FALSE);
            ai_ClearCreatureActions(oCreature, TRUE);
            ai_SaveAssociateConversationData(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman attack anyone who attacks them.
        case ASSOCIATE_COMMAND_GUARDMASTER:
        {
            //ai_Debug("0i_associate", "481", GetName(oMaster) + " has commanded " +
            //       GetName(oCreature) + " to GAURDMASTER.");
            ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, TRUE);
            ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
            ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
            if(!ai_GetIsBusy(oCreature) && ai_GetIsInCombat(oCreature))
            {
                object oLastAttacker = GetLastHostileActor(oMaster);
                if(oLastAttacker != OBJECT_INVALID) ai_DoAssociateCombatRound(oCreature, oLastAttacker);
                else ai_FindTheEnemy(oCreature,oCommander, oCommander);
            }
            ai_SaveAssociateConversationData(oMaster, oCreature);
            return;
        }
        // Menu used by a player to have the henchman heal them as soon as possible.
        case ASSOCIATE_COMMAND_HEALMASTER:
        {
            int nSpell, bCast = FALSE;
            if(GetHasSpell(SPELL_HEAL, oCreature) || ai_GetKnownSpell(oCreature, SPELL_HEAL))
                { nSpell = SPELL_HEAL; bCast = TRUE; }
            else if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS, oCreature) ||
                    ai_GetKnownSpell(oCreature, SPELL_CURE_CRITICAL_WOUNDS))
                     { nSpell = SPELL_CURE_CRITICAL_WOUNDS; bCast = TRUE; }
            else if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS, oCreature) ||
                    ai_GetKnownSpell(oCreature, SPELL_CURE_SERIOUS_WOUNDS))
                     { nSpell = SPELL_CURE_SERIOUS_WOUNDS; bCast = TRUE; }
            else if(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS, oCreature) ||
                    ai_GetKnownSpell(oCreature, SPELL_CURE_MODERATE_WOUNDS))
                     { nSpell = SPELL_CURE_MODERATE_WOUNDS; bCast = TRUE; }
            else if(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS, oCreature) ||
                    ai_GetKnownSpell(oCreature, SPELL_CURE_LIGHT_WOUNDS))
                     { nSpell = SPELL_CURE_LIGHT_WOUNDS; bCast = TRUE; }
            else if(!ai_GetAssociateMode(oCreature, AI_MODE_DO_NOT_SPEAK)) PlayVoiceChat(VOICE_CHAT_CANTDO, oCreature);
            if(bCast)
            {
                ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                ai_SaveAssociateConversationData(oMaster, oCreature);
                ai_ClearCreatureActions(oCreature);
                ActionCastSpellAtObject(nSpell, oMaster);
            }
            return;
        }
        // Menu used by a player to toggle a henchmans casting options.
        case ASSOCIATE_COMMAND_TOGGLECASTING:
        {
            if(ai_GetAssociateMode(oCreature, AI_MODE_NO_MAGIC))
            {
                ai_SetAssociateMode(oCreature, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING, TRUE);
                ai_SetAssociateMode(oCreature, AI_MODE_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will now cast defensive spells only.", COLOR_GRAY, oCommander);
            }
            else if(ai_GetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING))
            {
                ai_SetAssociateMode(oCreature, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_OFFENSIVE_CASTING, TRUE);
                ai_SendMessages(GetName(oCreature) + " will now cast offensive spells only.", COLOR_GRAY, oCommander);
            }
            else if(ai_GetAssociateMode(oCreature, AI_MODE_OFFENSIVE_CASTING))
            {
                ai_SetAssociateMode(oCreature, AI_MODE_NO_MAGIC, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will now cast any spell.", COLOR_GRAY, oCommander);
            }
            else
            {
                ai_SetAssociateMode(oCreature, AI_MODE_NO_MAGIC, TRUE);
                ai_SetAssociateMode(oCreature, AI_MODE_DEFENSIVE_CASTING, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_OFFENSIVE_CASTING, FALSE);
                ai_SendMessages(GetName(oCreature) + " will not use any magic.", COLOR_GRAY, oCommander);
            }
            ai_SaveAssociateConversationData(oMaster, oCreature);
            return;
        }
    }
    // If we are busy then these nCommands are ignored.
    if(!ai_GetIsBusy(oCreature))
    {
        // Respond to shouts from friendly non-PCs only.
        if (!ai_GetIsCharacter(oCommander) && !GetIsEnemy(oCommander, oCreature))
        {
            //if(nCommand == AI_ALLY_IS_WOUNDED) ai_TryHealingTalentsOutOfCombat(oCreature, oCommander);
            // A friend sees an enemy. If we are not in combat lets seek them out too!
            if(nCommand == AI_ALLY_SEES_AN_ENEMY ||
               nCommand == AI_ALLY_HEARD_AN_ENEMY)
            {
                //ai_Debug("0i_associates", "571", GetName(oCreature) + " receives notice that " +
                //         GetName(oCommander) + " has seen/heard an enemy!");
                ai_ReactToAssociate(oCreature, oCommander);
                return;
            }
            // A friend is in combat. Make some checks to see if we should help.
            else if(nCommand == AI_ALLY_ATKED_BY_WEAPON ||
                    nCommand == AI_ALLY_ATKED_BY_SPELL)
            {
                //ai_Debug("0i_associates", "580", GetName(oCreature) + " receives notice that " +
                //         GetName(oCommander) + " was attacked by an enemy!");
                ai_ReactToAssociate(oCreature, oCommander);
                return;
            }
            else if(nCommand == AI_ALLY_IS_DEAD)
            { // Nothing at the moment.
                //ai_Debug("0i_associates", "587", GetName(oCreature) + " receives notice that " +
                //         GetName(oCommander) + " has died!");
                return;
            }
        }
        switch(nCommand)
        {
            case ASSOCIATE_COMMAND_MASTERATTACKEDOTHER:
            {
                //ai_Debug("0i_associate", "596", GetName(oMaster) + " has attacked!");
                if(ai_CanIAttack(oCreature))
                {
                    if(ai_GetIsInCombat(oCreature)) ai_DoAssociateCombatRound(oCreature);
                    else ai_FindTheEnemy(oCreature, oCommander, oCommander);
                }
                return;
            }
            // Master tried to open a door or chest that is locked.
            case ASSOCIATE_COMMAND_MASTERFAILEDLOCKPICK:
            {
                object oLock = ai_GetNearestLockedObject(oMaster);
                //Check and see if our master want's us to open locks.
                if(ai_GetAssociateMode(oCreature, AI_MODE_OPEN_LOCKS))
                {
                    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                    ai_AttemptToByPassLock(oCreature, oLock);
                }
                return;
            }
            // Master saw a trap.
            case ASSOCIATE_COMMAND_MASTERSAWTRAP:
            {
                object oTrap = GetLastTrapDetected(oMaster);
                //Check and see if our master want's us to disarm the trap.
                if(ai_GetAssociateMode(oCreature, AI_MODE_DISARM_TRAPS))
                {
                    ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                    SetTrapDetectedBy(oTrap, oCreature, TRUE);
                    ai_AttemptToDisarmTrap(oCreature, oTrap);
                }
                return;
            }
            // Menu used by a player to toggle henchmans search on and off.
            case ASSOCIATE_COMMAND_TOGGLESEARCH:
            {
                if(GetActionMode(oCreature, ACTION_MODE_DETECT))
                {
                    SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, FALSE);
                }
                else
                {
                    ai_HaveCreatureSpeak(oCreature, 6, ":29:46:27:33:35:");
                    SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_DETECT, TRUE);
                }
                return;
            }
            // Menu used by a player to toggle henchmans stealth on and off.
            case ASSOCIATE_COMMAND_TOGGLESTEALTH:
            {
                if(GetActionMode(oCreature, ACTION_MODE_STEALTH) == TRUE)
                {
                    ai_SetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH, FALSE);
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH);
                }
                else
                {
                    ai_HaveCreatureSpeak(oCreature, 6, ":29:46:28:42:31:35:");
                    ai_SetAssociateMode(oCreature, AI_MODE_AGGRESSIVE_STEALTH);
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                    ai_PassActionToAssociates(oCreature, ACTION_MODE_STEALTH, TRUE);
                }
                ai_SaveAssociateConversationData(oMaster, oCreature);
                return;
            }
            // Menu used by a player to have the henchman try to bypass the nearest lock.
            case ASSOCIATE_COMMAND_PICKLOCK:
            {
                ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
                object oLock = ai_GetNearestLockedObject(oMaster);
                ai_AttemptToByPassLock(oCreature, oLock);
                ai_SaveAssociateConversationData(oMaster, oCreature);
                return;
            }
            // Menu used by a player to have the henchman try to disarm the nearest trap.
            case ASSOCIATE_COMMAND_DISARMTRAP:
            {
                ai_SetAssociateMode(oCreature, AI_MODE_DEFEND_MASTER, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_STAND_GROUND, FALSE);
                ai_SetAssociateMode(oCreature, AI_MODE_FOLLOW, FALSE);
                ai_AttemptToDisarmTrap(oCreature, GetNearestTrapToObject(oMaster), TRUE);
                ai_SaveAssociateConversationData(oMaster, oCreature);
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
                    ai_SendMessages("You cannot open " + GetName(oCreature) + "'s inventory.", COLOR_GRAY, oMaster);
                }
                return;
            }
            case ASSOCIATE_COMMAND_LEAVEPARTY:
            {
                if(AI_REMOVE_HENCHMAN_ON)
                {
                    ai_ClearCreatureActions(oCreature);
                    ai_FireHenchman (GetPCSpeaker(), oCreature);
                    PlayVoiceChat (VOICE_CHAT_GOODBYE, oCreature);
                }
            }
        }
    }
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
    if(sCombatAI == "ai_coward")
    {
        SetLocalString(oCreature, AI_COMBAT_SCRIPT, sCombatAI);
        return;
    }
    if(bCheckTacticScripts)
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
                        SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_ambusher_a");
                        SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
                        return;
                    }
            }
            // Ambusher: Requires a Hide and Move silently skill equal to your level + 1.
            else if(GetSkillRank(SKILL_HIDE, oCreature) >= nSkillNeeded &&
                     GetSkillRank(SKILL_MOVE_SILENTLY, oCreature) >= nSkillNeeded)
            {
                SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_a_ambusher");
                SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
                SetLocalInt(oCreature, "AI_TRIED_TO_HIDE", TRUE);
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
    ai_ClearCreatureActions(oHenchman);
    RemoveHenchman (oPC, oHenchman);
}
void ai_HenchmanCastDefensiveSpells (object oCreature, object oPC)
{
    ai_SetupBuffTargets(oCreature, oPC);
    ai_CastBuffs(oCreature, 3, 0, oPC);
    ai_ClearBuffTargets(oCreature);
}
//******************************************************************************
//********************* Creature event scripts *********************************
//******************************************************************************
void ai_OnDeath(object oCreature, object oKiller)
{
    DeleteLocalObject(oKiller, AI_ATTACKED_PHYSICAL);
    DeleteLocalObject(oKiller, AI_ATTACKED_SPELL);
    ai_SetIdentifyAllItems(oCreature, FALSE);
    SpeakString(AI_I_AM_DEAD, TALKVOLUME_SILENT_TALK);
    // Added code to allow for permanent associates in the battle!
    if(AI_PERMANENT_ASSOCIATES)
    {
        int nCntr = 1;
        object oAssociate = GetAssociate(nCntr, oCreature, 1);
        while (nCntr < 6)
        {
            //ai_Debug("0i_associates", "862", GetName(oAssociate) + " nCntr: " + IntToString(nCntr));
            if(oAssociate != OBJECT_INVALID) DelayCommand(0.0, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
            oAssociate = GetAssociate(++nCntr, oCreature, 1);
        }
    }
}
void ai_OnMonsterSpawn(object oCreature, int bIncorporeal)
{
    if(bIncorporeal)
    {
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
    }
    if(GetAssociateType(oCreature) != ASSOCIATE_TYPE_NONE)
    {
        // This allows for permanent associates.
        if(AI_PERMANENT_ASSOCIATES) SetIsDestroyable (FALSE, FALSE, TRUE);
        else SetIsDestroyable (TRUE, FALSE, FALSE);
    }
    ai_SetMonsterListeningPatterns (oCreature);
    ai_SetCreatureAIScript (oCreature);
    ai_SetAura(oCreature);
    ai_SetIdentifyAllItems(oCreature);
    SetLootable(oCreature, TRUE);
}
void ai_OnAssociateSpawn(object oCreature)
{
    if(GetAssociateType(oCreature) != ASSOCIATE_TYPE_NONE)
    {
        // This allows for permanent associates.
        if(AI_PERMANENT_ASSOCIATES) SetIsDestroyable (FALSE, FALSE, TRUE);
        else SetIsDestroyable (TRUE, FALSE, FALSE);
    }
    ai_SetMonsterListeningPatterns(oCreature);
    ai_SetAssociateAIScript(oCreature, TRUE);
    ai_SetAura(oCreature);
    ai_SetIdentifyAllItems(oCreature);
    SetLootable (oCreature, TRUE);
    object oMaster = GetMaster(oCreature);
    if(ai_GetIsCharacter(oMaster))
    {
        ai_SetAssociateConversationData(oMaster, oCreature);
        // Lets make sure they don't start patrolling. That should be selected each time.
        ai_SetAssociateMode(oCreature, AI_MODE_SCOUT_AHEAD, FALSE);
    }
}
void ai_OnRested(object oCreature)
{
    if(ai_GetAssociateMode(oCreature, AI_MODE_BUFF_AFTER_REST))
    {
        int nLevel = ai_GetCharacterLevels(oCreature);
        float fDelay = StringToFloat(Get2DAString("restduration", "DURATION", nLevel));
        fDelay = (fDelay / 1000.0f) + 2.0f;
        DelayCommand(fDelay, ai_HenchmanCastDefensiveSpells(oCreature, GetMaster()));
    }
}
