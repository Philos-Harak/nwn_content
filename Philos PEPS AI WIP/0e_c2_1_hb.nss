/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_associates"
#include "0i_assoc_debug"
#include "x0_i0_walkway"
//#include "x0_i0_anims"
void main()
{
    object oCreature = OBJECT_SELF;
    // * if not runnning normal or better AI then exit for performance reasons
    if (GetAILevel(oCreature) == AI_LEVEL_VERY_LOW) return;
    ai_Debug("0e_c2_1_hb", "17", GetName(oCreature) + " Heartbeat." +
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
        ai_DoMonsterCombatRound (oCreature);
        return;
    }
    if(ai_CheckForCombat(oCreature)) return;
    // If we have not set up our talents then we need to check to see if we should.
    if(!GetLocalInt(oCreature, AI_TALENTS_SET))
    {
        // We setup our talents when a PC gets withing Battlefield range 40.0 meters.
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
        if(oPC != OBJECT_INVALID && GetIsEnemy(oPC, oCreature) &&
           GetDistanceBetween(oCreature, oPC) <= AI_RANGE_BATTLEFIELD)
        {
            ai_Debug("0e_c2_1_hb", "62", GetName(oCreature) + " is " +
                     FloatToString(GetDistanceBetween(oCreature, oPC), 0, 2) + " from " + GetName(oPC));
            int nCondition = GetLocalInt(oCreature, "NW_GENERIC_MASTER");
            // Should we buff a caster? Added legacy code just in case.
            if((GetLocalInt(GetModule(), AI_RULE_BUFF_MONSTERS) || nCondition & 0x04000000) &&
               !GetLocalInt(oCreature, AI_CASTER_BUFFS_SET))
            {
                SetLocalInt(oCreature, AI_CASTER_BUFFS_SET, TRUE);
                ai_SetupMonsterBuffTargets(oCreature);
                // To save steps and time we set the talenst while we buff!
                ai_SetCreatureTalents(oCreature, TRUE);
                ai_ClearBuffTargets(oCreature, "AI_ALLY_TARGET_");
            }
            else ai_SetCreatureTalents(oCreature, FALSE);
            if(GetObjectSeen(oPC, oCreature))
            {
                ai_Debug("0e_c2_1_hb", "78", GetName(oCreature) + " is starting combat!");
                ai_DoMonsterCombatRound(oCreature);
                return;
            }
        }
    }
    if(GetWalkCondition(NW_WALK_FLAG_CONSTANT, oCreature))
    {
        WalkWayPoints();
    }
    if(!IsInConversation (oCreature))
    {
        if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS) ||
            GetIsEncounterCreature(oCreature)) PlayMobileAmbientAnimations_NonAvian();
        else if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)) PlayMobileAmbientAnimations_Avian();
        else if (GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS)) PlayImmobileAmbientAnimations();
    }
    if(ai_TryHealing(oCreature, oCreature)) return;
    // Send the user-defined event signal if specified
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_HEARTBEAT));
        return;
    }
}
