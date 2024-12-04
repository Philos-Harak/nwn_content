/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_9_onspawn
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnSpawn script;
  This fires when the creature spawns.
  Philos AI does not use this in override versions.
  Included for servers as an example to help add Philos AI to a server.
////////////////////////////////////////////////////////////////////////////////
 * Default OnSpawn handler with XP1 revisions.
 * This corresponds to and produces the same results
 * as the default OnSpawn handler in the OC.
 *
 * This can be used to customize creature behavior in three main ways:
 *
 * - Uncomment the existing lines of code to activate certain
 *   common desired behaviors from the moment when the creature
 *   spawns in.
 *
 * - Uncomment the user-defined event signals to cause the
 *   creature to fire events that you can then handle with
 *   a custom OnUserDefined event handler script.
 *
 * - Add new code _at the end_ to alter the initial
 *   behavior in a more customized way.
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2002 Floodgate Entertainment
// Created By: Naomi Novik
// Created On: 12/11/2002
////////////////////////////////////////////////////////////////////////////////
// Updated 2003-08-20 Georg Zoeller: Added check for variables to active spawn
// in conditions without changing the spawnscript
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
#include "0i_single_player"
#include "x0_i0_anims"
// #include "x0_i0_walkway" - in x0_i0_anims
#include "x0_i0_treasure"
#include "x2_inc_switches"
void main()
{
    object oCreature = OBJECT_SELF;
    // ***** Spawn-In Conditions ***** //

    // * REMOVE COMMENTS (// ) before the "Set..." functions to activate
    // * them. Do NOT touch lines commented out with // *, those are
    // * real comments for information.

    // * Philos AI - This is valid to use.
    // *
    // * This causes the creature to say a one-line greeting in their
    // * conversation file upon perceiving the player. Put [NW_D2_GenCheck]
    // * in the "Text Seen When" field of the greeting in the conversation
    // * file. Don't attach any player responses.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_CONVERSATION);

    // * Philos AI - This is valid to use.
    // * Same as above, but for hostile creatures to make them say
    // * a line before attacking.
    // *
    // SetSpawnInCondition(NW_FLAG_SPECIAL_COMBAT_CONVERSATION);

    // * Philos AI - All NPC's attack when allies call for help.
    // *
    // * This NPC will attack when its allies call for help
    // *
    // SetSpawnInCondition(NW_FLAG_SHOUT_ATTACK_MY_TARGET);

    // Philos AI - All creatures will go into stealth mode if they have
    // *
    // a good hide/move silently rank.
    // * If the NPC has the Hide skill they will go into stealth mode
    // * while doing WalkWayPoints().
    // *
    // SetSpawnInCondition(NW_FLAG_STEALTH);

    //--------------------------------------------------------------------------
    // Philos AI - Creatures with good hide/Move Silently ranks
    // will automatically use stealth.
    //
    // Enable stealth mode by setting a variable on the creature
    // Great for ambushes
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    //if (GetCreatureFlag(oCreature, CREATURE_VAR_USE_SPAWN_STEALTH) == TRUE)
    //{
    //    SetSpawnInCondition(NW_FLAG_STEALTH);
    //}
    // * Same, but for Search mode
    // *
    // SetSpawnInCondition(NW_FLAG_SEARCH);

    //--------------------------------------------------------------------------
    // Philos AI - Creatures do not have a search mode at this time.
    //
    // Make creature enter search mode after spawning by setting a variable
    // Great for guards, etc
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    //if (GetCreatureFlag(oCreature, CREATURE_VAR_USE_SPAWN_SEARCH) == TRUE)
    //{
    //    SetSpawnInCondition(NW_FLAG_SEARCH);
    //}
    // * Philos AI - This does not work.
    // *
    // * This will set the NPC to give a warning to non-enemies
    // * before attacking.
    // * NN -- no clue what this really does yet
    // *
    // SetSpawnInCondition(NW_FLAG_SET_WARNINGS);

    // Philos AI - This is valid to use.
    // *
    // * Separate the NPC's waypoints into day & night.
    // * See comment on WalkWayPoints() for use.
    // *
    // SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING);

    // Philos AI - This is valid to use.
    // *
    // * If this is set, the NPC will appear using the "EffectAppear"
    // * animation instead of fading in, *IF* SetListeningPatterns()
    // * is called below.
    // *
    //SetSpawnInCondition(NW_FLAG_APPEAR_SPAWN_IN_ANIMATION);

    // Philos AI - This is valid to use.
    // *
    // * This will cause an NPC to use common animations it possesses,
    // * and use social ones to any other nearby friendly NPCs.
    // *
    // SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);

    //--------------------------------------------------------------------------
    // Philos AI - This is valid to use.
    //
    // Enable immobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(oCreature, CREATURE_VAR_USE_SPAWN_AMBIENT_IMMOBILE) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS);
    }
    // Philos AI - This is valid to use.
    // *
    // * Same as above, except NPC will wander randomly around the
    // * area.
    // *
    // SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);


    //--------------------------------------------------------------------------
    // Philos AI - This is valid to use.
    //
    // Enable mobile ambient animations by setting a variable
    // See x2_inc_switches for more information about this
    //--------------------------------------------------------------------------
    if (GetCreatureFlag(oCreature, CREATURE_VAR_USE_SPAWN_AMBIENT) == TRUE)
    {
        SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS);
    }
    // **** Animation Conditions **** //
    // * These are extra conditions you can put on creatures with ambient
    // * animations.

    // Philos AI - This is valid to use.
    // *
    // * Civilized creatures interact with placeables in
    // * their area that have the tag "NW_INTERACTIVE"
    // * and "talk" to each other.
    // *
    // * Humanoid races are civilized by default, so only
    // * set this flag for monster races that you want to
    // * behave the same way.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_CIVILIZED);

    // Philos AI - This is valid to use.
    // *
    // * If this flag is set, this creature will constantly
    // * be acting. Otherwise, creatures will only start
    // * performing their ambient animations when they
    // * first perceive a player, and they will stop when
    // * the player moves away.
    // SetAnimationCondition(NW_ANIM_FLAG_CONSTANT);

    // Philos AI - This is valid to use.
    // *
    // * Civilized creatures with this flag set will
    // * randomly use a few voicechats. It's a good
    // * idea to avoid putting this on multiple
    // * creatures using the same voiceset.
    // SetAnimationCondition(NW_ANIM_FLAG_CHATTER);

    // Philos AI - This is valid to use.
    // *
    // * Creatures with _immobile_ ambient animations
    // * can have this flag set to make them mobile in a
    // * close range. They will never leave their immediate
    // * area, but will move around in it, frequently
    // * returning to their starting point.
    // *
    // * Note that creatures spawned inside interior areas
    // * that contain a waypoint with one of the tags
    // * "NW_HOME", "NW_TAVERN", "NW_SHOP" will automatically
    // * have this condition set.
    // SetAnimationCondition(NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE);


    // **** Special Combat Tactics *****//
    // * These are special flags that can be set on creatures to
    // * make them follow certain specialized combat tactics.
    // * NOTE: ONLY ONE OF THESE SHOULD BE SET ON A SINGLE CREATURE.

    // * Philos AI - This does not work all creatures will use ranged weapons
    // * as long as they have them in inventory.
    // *
    // * Ranged attacker
    // * Will attempt to stay at ranged distance from their
    // * target.

    // Philos AI - This is valid to use.
    // *
    // * Defensive attacker
    // * Will use defensive combat feats and parry
    // SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_defensive");

    // Philos AI - This is valid to use.
    // *
    // * Ambusher
    // * Will go stealthy/invisible and attack, then
    // * run away and try to go stealthy again before
    // * attacking anew.
    // SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_ambusher");

    // * Philos AI - This does not work.
    // *
    // **** Escape Commands ***** //
    // * NOTE: ONLY ONE OF THE FOLLOWING SHOULD EVER BE SET AT ONE TIME.
    // * NOTE2: Not clear that these actually work. -- NN

    // * Flee to a way point and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_RETURN);

    // * Flee to a way point and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_ESCAPE_LEAVE);

    // * Teleport to safety and do not return.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_LEAVE);

    // * Teleport to safety and return a short time later.
    // *
    // SetSpawnInCondition(NW_FLAG_TELEPORT_RETURN);



    // ***** CUSTOM USER DEFINED EVENTS ***** /


    // Philos AI - This is valid to use.
    // *
    /*
      If you uncomment any of these conditions, the creature will fire
      a specific user-defined event number on each event. That will then
      allow you to write custom code in the "OnUserDefinedEvent" handler
      script to go on top of the default NPC behaviors for that event.

      Example: I want to add some custom behavior to my NPC when they
      are damaged. I uncomment the "NW_FLAG_DAMAGED_EVENT", then create
      a new user-defined script that has something like this in it:

      if (GetUserDefinedEventNumber() == 1006) {
          // Custom code for my NPC to execute when it's damaged
      }

      These user-defined events are in the range 1001-1007.
    */

    // * Fire User Defined Event 1001 in the OnHeartbeat
    // *
    // SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);

    // * Fire User Defined Event 1002
    // *
    // SetSpawnInCondition(NW_FLAG_PERCIEVE_EVENT);

    // * Fire User Defined Event 1005
    // *
    // SetSpawnInCondition(NW_FLAG_ATTACK_EVENT);

    // * Fire User Defined Event 1006
    // *
    // SetSpawnInCondition(NW_FLAG_DAMAGED_EVENT);

    // * Fire User Defined Event 1008
    // *
    // SetSpawnInCondition(NW_FLAG_DISTURBED_EVENT);

    // * Fire User Defined Event 1003
    // *
    // SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);

    // * Fire User Defined Event 1004
    // *
    // SetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT);

    // Philos AI - This has been adjusted for use the the default Philos AI.
    // *
    // ***** DEFAULT GENERIC BEHAVIOR (DO NOT TOUCH) ***** //

    // * Philos AI uses a diffreent Listening Patter system.
    // *
    // * Goes through and sets up which shouts the NPC will listen to.
    // *
    //SetListeningPatterns();

    // Philos AI - This is valid to use.
    // *
    // * Walk among a set of waypoints.
    // * 1. Find waypoints with the tag "WP_" + NPC TAG + "_##" and walk
    // *    among them in order.
    // * 2. If the tag of the Way Point is "POST_" + NPC TAG, stay there
    // *    and return to it after combat.
    //
    // * Optional Parameters:
    // * void WalkWayPoints(int nRun = FALSE, float fPause = 1.0)
    //
    // * If "NW_FLAG_DAY_NIGHT_POSTING" is set above, you can also
    // * create waypoints with the tags "WN_" + NPC Tag + "_##"
    // * and those will be walked at night. (The standard waypoints
    // * will be walked during the day.)
    // * The night "posting" waypoint tag is simply "NIGHT_" + NPC tag.
    WalkWayPoints();

    //* Create a small amount of treasure on the creature
    if ((GetLocalInt(GetModule(), "X2_L_NOTREASURE") == FALSE)  &&
        (GetLocalInt(oCreature, "X2_L_NOTREASURE") == FALSE)   )
    {
        CTG_GenerateNPCTreasure(TREASURE_TYPE_MONSTER, oCreature);
    }


    // ***** ADD ANY SPECIAL ON-SPAWN CODE HERE ***** //

    // * If Incorporeal, apply changes
    if (GetCreatureFlag(oCreature, CREATURE_VAR_IS_INCORPOREAL) == TRUE)
    {
        effect eConceal = EffectConcealment(50, MISS_CHANCE_TYPE_NORMAL);
        eConceal = ExtraordinaryEffect(eConceal);
        effect eGhost = EffectCutsceneGhost();
        eGhost = ExtraordinaryEffect(eGhost);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eConceal, oCreature);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eGhost, oCreature);
//****************************  ADDED AI CODE  *****************************
        string sCombatAI = GetLocalString(oCreature, AI_DEFAULT_SCRIPT);
        if (sCombatAI == "") SetLocalString(oCreature, AI_DEFAULT_SCRIPT, "ai_incorporeal");
//****************************  ADDED AI CODE  *****************************
    }

    // * Give the create a random name.
    // * If you create a script named x3_name_gen in your module, you can
    // * set the value of the variable X3_S_RANDOM_NAME on oCreature inside
    // * the script to override the creature's default name.
    if (GetCreatureFlag(oCreature, CREATURE_VAR_RANDOMIZE_NAME) == TRUE)
    {
        ExecuteScript("x3_name_gen",oCreature);
        string sName = GetLocalString(oCreature,"X3_S_RANDOM_NAME");
        if ( sName == "" )
        {
            sName = RandomName();
        }
        SetName(oCreature,sName);
    }
//****************************  ADDED AI CODE  *********************************
    ai_SetListeningPatterns(oCreature);
    ai_SetCreatureAIScript(oCreature);
    ai_SetMonsterEventScripts(oCreature);
    ai_SetAura(oCreature);
//****************************  ADDED AI CODE  *********************************
}
