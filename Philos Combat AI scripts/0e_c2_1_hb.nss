/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_1_hb
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnHeartbeat script when out of combat;
  This will usually fire every 6 seconds (1 game round).
*///////////////////////////////////////////////////////////////////////////////
#include "0i_actions"
//#include "0i_actions_debug"
#include "x0_i0_walkway"
#include "x0_i0_anims"
void main()
{
    object oCreature = OBJECT_SELF;
    // * if not runnning normal or better AI then exit for performance reasons
    if (GetAILevel(oCreature) == AI_LEVEL_VERY_LOW) return;
    //ai_Debug("0e_c2_1_hb", "14", GetName(oCreature) + " Heartbeat out of combat." +
    //         " Searching: " + IntToString(GetLocalInt(oCreature, AI_AM_I_SEARCHING)));
    if(GetHasEffect(EFFECT_TYPE_SLEEP, oCreature))
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
    if(ai_GetIsBusy(oCreature) || ai_Disabled(oCreature)) return;
    // If we have not set up our talents then we need to check to see if we should.
    if(!GetLocalInt(oCreature, sTalentsSetVarname))
    {
        // We setup our talents when a PC gets withing Battlefield range 40.0 meters.
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
        if(oPC != OBJECT_INVALID && GetDistanceBetween(oCreature, oPC) <= AI_RANGE_BATTLEFIELD)
        {
            SetLocalInt(oCreature, sTalentsSetVarname, TRUE);
            int nCondition = GetLocalInt(oCreature, "NW_GENERIC_MASTER");
            // Should we buff a caster? Added legacy code just in case.
            if((AI_BUFF_MONSTER_CASTERS || nCondition & 0x04000000) &&
               !GetLocalInt(oCreature, AI_CASTER_USED_BUFFS) && GetIsEnemy(oPC))
            {
                SetLocalInt(oCreature, AI_CASTER_USED_BUFFS, TRUE);
                ai_SetupMonsterBuffTargets(oCreature);
                ai_SetCreatureTalents(oCreature, TRUE);
                ai_ClearBuffTargets(oCreature);
            }
            else ai_SetCreatureTalents(oCreature, FALSE);
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
    // Send the user-defined event signal if specified
    if(GetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT))
    {
        SignalEvent(oCreature, EventUserDefined(EVENT_HEARTBEAT));
        return;
    }
}
