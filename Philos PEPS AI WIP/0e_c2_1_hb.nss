/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_associates"
void main()
{
    object oCreature = OBJECT_SELF;
    // * if not runnning normal or better AI then exit for performance reasons
    //if (GetAILevel(oCreature) == AI_LEVEL_VERY_LOW) return;
    if(AI_DEBUG) ai_Debug("0e_c2_1_hb", "14", GetName(oCreature) + " Heartbeat." +
             " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(ai_GetHasEffectType(oCreature, EFFECT_TYPE_SLEEP))
    {
        // If we're asleep and this is the result of sleeping
        // at night, apply the floating 'z's visual effect
        // every so often
        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCreature);
            }
        }
    }
    // Send the user-defined event signal if specified here so it doesn't get skipped.
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_HEARTBEAT));
    }
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature) ||
       GetLocalInt(oCreature, AI_AM_I_SEARCHING)) return;
    if(ai_GetIsInCombat(oCreature))
    {
        if(ai_GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
        {
            object oTarget = ai_GetNearestEnemy(oCreature, 1, 7, 7, -1, -1, TRUE);
            if(GetDistanceBetween(oCreature, oTarget) <= 6.0)
            {
                if(GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0)
                {
                    SetLocalString(oCreature, AI_COMBAT_SCRIPT, "ai_coward");
                    ActionMoveAwayFromObject(oTarget, TRUE, AI_RANGE_LONG);
                    return;
                }
            }
        }
        ai_DoMonsterCombatRound(oCreature);
        return;
    }
    if(ai_CheckForCombat(oCreature, TRUE)) return;
    // If we have not set up our talents then we need to check to see if we should.
    if(!GetLocalInt(oCreature, AI_TALENTS_SET))
    {
        // We setup our talents when a PC gets withing Battlefield range 40.0 meters.
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
        if(oPC != OBJECT_INVALID && GetIsEnemy(oPC, oCreature) &&
           GetDistanceBetween(oCreature, oPC) <= AI_RANGE_BATTLEFIELD)
        {
            if(AI_DEBUG) ai_Debug("0e_c2_1_hb", "59", GetName(oCreature) + " is " +
                     FloatToString(GetDistanceBetween(oCreature, oPC), 0, 2) + " from " + GetName(oPC));
            if(AI_DEBUG) ai_Debug("0e_c2_1_hb", "61", GetName(oCreature) + " is Setting Creature Talents and buffing!");
            ai_SetupMonsterBuffTargets(oCreature);
            // To save steps and time we set the talenst while we buff!
            ai_SetCreatureTalents(oCreature, TRUE);
            ai_ClearBuffTargets(oCreature, "AI_ALLY_TARGET_");
            if(GetObjectSeen(oPC, oCreature))
            {
                if(AI_DEBUG) ai_Debug("0e_c2_1_hb", "68", GetName(oCreature) + " is starting combat!");
                ai_DoMonsterCombatRound(oCreature);
                return;
            }
        }
    }
    if(!IsInConversation (oCreature))
    {
        if(GetWalkCondition(NW_WALK_FLAG_CONSTANT)) WalkWayPoints();
        if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)) PlayMobileAmbientAnimations_NonAvian();
        else if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)) PlayMobileAmbientAnimations_Avian();
        else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)) PlayImmobileAmbientAnimations();
        else if(GetLocalInt(GetModule(), AI_RULE_WANDER) && GetStandardFactionReputation(STANDARD_FACTION_HOSTILE, oCreature) < 11)
        {
            ai_AmbientAnimations(DISTANCE_LARGE);
        }
    }
    if(ai_TryHealing(oCreature, oCreature)) return;
}
