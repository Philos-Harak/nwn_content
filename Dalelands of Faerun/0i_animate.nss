/*//////////////////////////////////////////////////////////////////////////////
Script Name: 0i_animate
Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include file for NPC animations used on server
 Variables used.
 ANIM_START_LOCATION = NPC's spawn in location.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_items"
#include "0i_position"
// Library for stealth/detect modes
#include "x0_i0_modes"
// Library for Voiceset functionality. All voice calls go through here
#include "x0_i0_voice"
// Library for walkways (need to pass it this way to get access to ClearActiosn in x0_i0_assoc
//#include "x0_i0_walkway"

// Animation length and speed
const float ANIM_LOOPING_LENGTH = 4.0;
const float ANIM_LOOPING_SPEED = 1.0;
// Conversation file that holds the random one-liners for
// NPCs to speak when a PC comes into their home.
// const string ANIM_CONVERSATION = "x0_npc_homeconv";
// Variable that holds the animation flags
const string sAnimCondVarname = "ANIMATION_FLAG";
// ***  Available animation flags  *** //
// Note there is no AI_MOBILE flag as the default
// is mobile ai for creatures that are not set to
// Immobile or mobile close range.
// If set, the creature has been initialized.
const int AI_INITIALIZED           = 0x00000001;
// If set, the NPC is using immobile ai.
const int AI_IS_IMMOBILE           = 0x00000002;
// If set, the NPC is using mobile close-range ai.
const int AI_IS_MOBILE_CLOSE_RANGE = 0x00000004;
// If set, the creature uses animal ai.
const int AI_ANIMAL                = 0x00000008;
// If set, the NPC is using a torch.
const int AI_HAS_TORCH             = 0x00000010;
// If set, the NPC has been triggered and should be animating.
const int AI_IS_ACTIVE             = 0x00000020;
// If set, the NPC is currently interacting with a placeable.
const int AI_IS_INTERACTING        = 0x00000040;
// If set, the NPC is currently talking.
const int AI_IS_TALKING            = 0x00000080;
// If set, the NPC has gone inside an interior area.
const int AI_IS_INSIDE             = 0x00000100;
// The NPC in in a city and will use city ai.
const int AI_CITY                  = 0x00000200;
// The NPC is in a tavern and will use tavern ai.
const int AI_TAVERN                = 0x00000400;
// The NPC is in a church and will use church ai.
const int AI_CHURCH                = 0x00000800;
// The NPC is walking a path and needs to be uninterupted.
const int AI_IS_WALKING               = 0x00001000;

// TRUE if the given creature has the given condition set
int GetAICondition (int iCondition, object oCreature = OBJECT_SELF);

// Mark that the given creature has the given condition set
void SetAICondition (int iCondition, int iValid = TRUE, object oCreature = OBJECT_SELF);

// The call function to set NPC's ai.
void CheckCreatureAI ();

// General initialization for animations.
// Starting ai.
void AIInitialization ();

// Check to see if we're in the middle of some action
// so we don't interrupt or pile actions onto the queue.
// Returns TRUE if in the middle of an action, FALSE otherwise.
int CheckCurrentAction ();

// Perform immobile actions.
// - Check if we need a torch.
// - Put up one-handed weapons.
// - play a random animation.
// - turn towards a nearby placeable and interact.
// - turn around randomly.
void RunAIImmobile ();

// Perform mobile and close mobile actions.
// - go to a nearby placeable and interact with it.
// - go to a nearby friend and talk with them.
// - go to an open door and close it.
// - walk to a nearby waypoint.
// - go into a tavern, shop, or church.
// - go outside if previously went inside.
// Close mobile actions and mobile actions.
// - randomly walk.
// - go back to spawn position.
void RunAIMobile ();

// Returns TRUE if the creature is busy talking or interacting with a placeable.
int GetIsBusyWithAnimation (object oCreature);

// Detect if the creature should have special location ai.
// Such as if in a tavern or church.
void GetLocationAI (object oCreature);

// Get a random nearby friend.
// OBJECT_INVALID will be returned if the friend is a PC,
// is busy with another animation, is in conversation or combat,
// or is further away than the distance limit.
object GetRandomFriend (float fMaxDistance);

// Get a random nearby object within the specified distance with
// the specified tag.
object GetRandomObjectByTag (string sTag, float fMaxDistance);

// Get a random nearby object within the specified distance with
// the specified type.
// nObjType: Any of the OBJECT_TYPE_* constants
object GetRandomObjectByType (int iObjType, float fMaxDistance);

// Get a random waypoint object in the area.
// If fMaxDistance is non-zero, will return OBJECT_INVALID
// if the stop is too far away.
// The first time this is called in a given area, it cycles
// through all the stops in the area and stores them.
object GetRandomWaypoint (float fMaxDistance);

// Set a specific creature (or OBJECT_INVALID to clear) as the caller's "friend"
void SetCurrentFriend (object oFriend);

// Get the caller's current friend, if set; OBJECT_INVALID otherwise
object GetCurrentFriend ();

// Set an object (or OBJECT_INVALID to clear) as the caller's interactive target.
void SetCurrentInteractionTarget (object oTarget);

// Get the caller's current interaction target, if set; OBJECT_INVALID otherwise
object GetCurrentInteractionTarget ();

// Check to see if we should switch on detect/stealth mode
void CheckCurrentModes ();

// Start interacting with a placeable object
void AIActionStartInteracting (object oPlaceable);

// Stop interacting with a placeable object
void AIActionStopInteracting ();

// Start talking with a friend
void AIActionStartTalking (object oFriend, int iHDiff = 0);

// Stop talking to the given friend
void AIActionStopTalking(object oFriend, int iHDiff = 0);

// Play a greeting animation and possibly voicechat.
// If a negative difference is passed in, caller will bow.
void AIActionPlayRandomGreeting (int iHDiff);

// Play a random farewell animation and possibly voicechat.
// If a negative difference is passed in, caller will bow.
void AIActionPlayRandomGoodbye (int iHDiff);

// Randomly move away from an object the specified distance.
// This is mainly because ActionMoveAwayFromLocation isn't working.
void AIActionRandomMoveAway (object oSource, float fDistance);

// Play animation of shaking head "no" to left and right
void AIActionShakeHead();

// Play animation of looking around to left and right
void AIActionLookAround();

// Turn around to face a random direction
void AIActionTurnAround();

// Interact with a placeable object.
// This will activate/deactivate the placeable object if a valid
// one is passed in.
// KLUDGE: If a placeable object without an inventory should
//         still be opened/shut instead of de/activated, set
//         its Will Save to 1.
void AIActionPlayRandomInteractAnimation (object oPlaceable);

// Play a random talk gesture animation.
// If a hit dice difference (should be the hit dice of the talker
// minus the hit dice of the person being talked to) is passed in,
// slightly different animations will play based on this.
void AIActionPlayRandomTalkAnimation (int iHDiff);

/**********************************************************************
 * The following AnimAction functions are special, because they may fail
 * (for instance, AnimActionsSitInChair() will only work if an actual
 * chair object was found to sit in).
 *
 * They all return TRUE on success, FALSE on failure. This allows for
 * trying an action and doing something else if it failed.
 *
 * Unfortunately, that means they cannot be easily used with
 * DelayCommand / AssignAction, but the tradeoff is worth it, IMO.
 **********************************************************************/

// Gets or puts up a torch.
int AIActionTorch ();

// If there's an open door nearby, possibly go close it,
// then come back to our current spot.
// Returns TRUE on success, FALSE on failure.
int AIActionCloseDoors ();

// Sit in a random nearby chair if available.
// Looks for items with tag: NW_SEAT
// Returns TRUE on success, FALSE on failure.
int AIActionSitInChair (float fMaxDistance);

// Get up from a chair if we're sitting.
// Returns TRUE on success, FALSE on failure.
int AIActionGetUpFromChair ();

// Go through a nearby door if appropriate.
// This will be done if the door is unlocked and
// the area the door leads to contains a waypoint
// with one of these tags: NW_TAVERN, NW_SHOP, NW_CHURCH
// Returns TRUE on success, FALSE on failure.
int AIActionGoInside ();

// Leave area if appropriate.
// This only works for NPCs that entered an area that
// has a waypoint with one of these tags:
// NW_TAVERN, NW_SHOP, NW_CHURCH
// If the NPC entered through a door, they will exit through that door.
// Returns TRUE on success, FALSE on failure.
int AIActionGoOutside ();

// Go to a nearby waypoint.
// Returns TRUE on success, FALSE on failure.
int AIActionGoToWaypoint (float fMaxDistance = 20.0);

// Find a friend within the given distance and talk to them.
// Returns TRUE on success, FALSE on failure.
int AIActionFindFriend (float fMaxDistance);

// Find a placeable within the given distance and interact with it.
// Returns TRUE on success, FALSE on failure.
int AIActionFindPlaceable (float fMaxDistance);

// If injured and mobile go to spawn location.
// Returns TRUE on success, FALSE on failure.
int AIActionReturn ();

// ***** Not used at the moment ******
// If it is night, go back to our home waypoint, if we have one.
// This is only meaningful for mobile NPCs who would have left
// their homes during the day.
// Returns TRUE on success, FALSE on failure.
int AIActionGoHome ();

// ***** Not used at the moment ******
// If it is day, leave our home area, if we have one.
// This is only meaningful for mobile NPCs.
// Returns TRUE on success, FALSE on failure.
int AIActionLeaveHome ();

// TRUE if the given creature has the given condition set for AI functions.
int GetAICondition (int iCondition, object oCreature = OBJECT_SELF)
{
    return (GetLocalInt(oCreature, sAnimCondVarname) & iCondition);
}

// Mark that the given creature has the given condition set for AI functions.
void SetAICondition (int iCondition, int iValid = TRUE, object oCreature = OBJECT_SELF)
{
    int iCurrentCond = GetLocalInt(oCreature, sAnimCondVarname);
    if (iValid) SetLocalInt(oCreature, sAnimCondVarname, iCurrentCond | iCondition);
    else SetLocalInt(oCreature, sAnimCondVarname, iCurrentCond & ~iCondition);
}

// The call function to let NPC's and creatures use ai.
// Set the following on creatures for specific ai functions.
// SetAICondition (AI_IS_IMMOBILE, TRUE, oCreature) - Makes creatures not move around.
// SetAICondition (AI_IS_MOBILE_CLOSE_RANGE, TRUE, oCreature) - Makes creatures move around in a limited area.
// Default (No setting) - To make creatures move around in an unlimited area.
void CheckCreatureAI ()
{
    // Is animations frozen for this area?
    if (GetLocalInt (GetArea (OBJECT_SELF), "0_AnimationsOFF"))
    {
        ClearAllActions ();
        return;
    }
    //  Check initializion.
    if (!GetAICondition (AI_INITIALIZED)) AIInitialization ();
    // Check if they are currently doing something. If so then exit.
    if (CheckCurrentAction ()) return;
    // Goto spawn point if we are hurt and exit function.
    if (AIActionReturn ()) return;
    // Check if current modes should change.
    CheckCurrentModes ();
    // Now check to see which ai. we should follow.
    // If immobile then run immobile ai.
    if (GetAICondition (AI_IS_IMMOBILE)) RunAIImmobile ();
    // Otherwise run mobile ai.
    else RunAIMobile ();
}

// General initialization for animations.
// Called from all the Play_* functions.
void AIInitialization ()
{
    // Set the creatures starting point for later reference.
    SetLocalLocation (OBJECT_SELF, "ANIM_START_LOCATION", GetLocation (OBJECT_SELF));
    // Set as initialized.
    SetAICondition (AI_INITIALIZED);
    // Set animals AI.
    int iRace = GetRacialType (OBJECT_SELF);
    if (iRace == RACIAL_TYPE_ANIMAL || iRace == RACIAL_TYPE_BEAST) SetAICondition (AI_ANIMAL);
    // Check for location AI.
    GetLocationAI (OBJECT_SELF);
}

// Check to see if we're in the middle of some action
// so we don't interrupt or pile actions onto the queue.
// Returns TRUE if in the middle of an action, FALSE otherwise.
int CheckCurrentAction()
{
    // We are walking to a point and do not want to stop.
    if (GetAICondition (AI_IS_WALKING)) return TRUE;
    // If we're talking, either keep going or stop.
    // Low prob of stopping, since both parties have
    // a chance and conversations are cool.
    if (GetAICondition (AI_IS_TALKING))
    {
        object oFriend = GetCurrentFriend ();
        int iHDiff = GetHitDice (OBJECT_SELF) - GetHitDice (oFriend);
        if (Random (100) < 5) AIActionStopTalking (oFriend, iHDiff);
        else AIActionPlayRandomTalkAnimation (iHDiff);
        return TRUE;
    }
    // If we're interacting with a placeable, either keep going or
    // stop. High probability of stopping, since looks silly to
    // constantly turn something on-and-off.
    if (GetAICondition (AI_IS_INTERACTING))
    {
        if (Random (100) < 40) AIActionStopInteracting();
        else AIActionPlayRandomInteractAnimation (GetCurrentInteractionTarget ());
        return TRUE;
    }
    // Get the current action.
    int iAction = GetCurrentAction();
    // lets use % we use Random so we get a simple % by using < only.
    int iChance = Random (100);
    // If sitting then check to see if we need to get up?
    if (iAction == ACTION_SIT)
    {
        if (iChance < 15) AIActionGetUpFromChair ();
    }
    // If randomly walking sometimes stop.
    else if (iAction == ACTION_RANDOMWALK)
    {
        if (iChance < 25) return FALSE;
        else return TRUE;
    }
    // If moving to a point never stop.
    else if (iAction == ACTION_MOVETOPOINT) return TRUE;
    // If waiting sometimes stop.
    else if (iAction == ACTION_WAIT)
    {
        if (iChance < 25) return FALSE;
        else return TRUE;
    }
    // We are doing another action return true
    // so they continue the action.
    if (iAction != ACTION_INVALID) return TRUE;
    // Could not find an action so lets go do an action!
    return FALSE;
}

// Perform immobile ai.
// Includes:
// - turn towards a nearby unoccupied friend and 'talk'
// - turn towards a nearby placeable and interact
// - turn around randomly
// - play a random animation
void RunAIImmobile ()
{
    // lets use % we use Random so we get a simple % by using < only.
    int iChance = Random (100);
    object oWeapon = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND);
    // First check to see if we are an animal. If so do Animal AI.
    //if (GetAICondition (AI_ANIMAL))
    //{
    //}
    // Do we need a torch?
    if (AIActionTorch ()) return;
    // Clear any actions before we select an immobile action.
    ClearAllActions ();
    // If we are in a tavern lets then do Tavern AI.
    if (GetAICondition (AI_TAVERN))
    {
        // We always put a one handed weapon up first, lets not be rude!
        if (GetIsObjectValid (oWeapon) && !GetIsTwoHandedWeapon (oWeapon, OBJECT_SELF)) { ActionUnequipItem (oWeapon); return; }
        // Take a drink.
        if (iChance < 25) ActionPlayAnimation (ANIMATION_FIREFORGET_DRINK);
        // Don't feel good.
        else if (iChance < 35)
        {
            if (iChance < 5) VoicePoisoned ();
            ActionPlayAnimation (ANIMATION_LOOPING_PAUSE_DRUNK, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        }
        // Victory!
        else if (iChance < 40) ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY1);
        else if (iChance < 45) ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY2);
        else if (iChance < 50) ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY3);
        // Laughing loudly.
        else if (iChance < 60)
        {
            if (iChance < 10) VoiceLaugh ();
            ActionPlayAnimation (ANIMATION_LOOPING_TALK_LAUGHING, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        }
        // Bored
        else if (iChance < 75) ActionPlayAnimation (ANIMATION_FIREFORGET_PAUSE_BORED);
        // Scratch head.
        else if (iChance < 80) ActionPlayAnimation (ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
        // Tired.
        else if (iChance < 90) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE_TIRED, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else AIActionLookAround ();
    }
    else if (GetAICondition (AI_CHURCH))
    {
        // We always put a one handed weapon up first, lets not be rude!
        if (!GetIsTwoHandedWeapon (oWeapon, OBJECT_SELF)) { ActionUnequipItem (oWeapon); return; }
        // Read.
        if (iChance < 10) ActionPlayAnimation (ANIMATION_FIREFORGET_READ);
        // Meditate.
        else if (iChance < 30) ActionPlayAnimation (ANIMATION_LOOPING_MEDITATE, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH * 2);
        // Worship.
        else if (iChance < 60) ActionPlayAnimation (ANIMATION_LOOPING_WORSHIP, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH * 2);
        // Listen.
        else if (iChance < 70) ActionPlayAnimation (ANIMATION_LOOPING_LISTEN, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        // Pause.
        else if (iChance < 80) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        // Pause2.
        else if (iChance < 90) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE2, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        // Look around.
        else if (iChance < 95) AIActionLookAround ();
        else AIActionTurnAround ();
    }
    // Lets do generic ai for towns and such.
    else
    {
        if (iChance < 10) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else if (iChance < 20) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE2, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else if (iChance < 21) ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else if (iChance < 50) ActionPlayAnimation (ANIMATION_FIREFORGET_PAUSE_BORED);
        else if (iChance < 60) ActionPlayAnimation (ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
        else if (iChance < 80) ActionPlayAnimation (ANIMATION_LOOPING_PAUSE_TIRED, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else if (iChance < 90) ActionPlayAnimation (ANIMATION_LOOPING_LOOK_FAR, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else AIActionLookAround ();
    }
}

// Perform mobile ai.
// This will include:
// - any of the immobile actions
// - close any nearby doors, then return to current position
// - go to a nearby placeable and interact with it
// - go to a nearby friend and interact with them
// - walk to a nearby waypoint
// - going back to starting point especially if you are close mobile.
void RunAIMobile ()
{
    // First lets check for animals and do basic mobility.
    if (GetAICondition (AI_ANIMAL))
    {
        // Find a friendly creature we can see.
        object oFriend = GetNearestCreature (CREATURE_TYPE_REPUTATION,
                                             REPUTATION_TYPE_FRIEND,
                                             OBJECT_SELF,
                                             d4(),
                                             CREATURE_TYPE_PERCEPTION,
                                             PERCEPTION_SEEN);
        // If the friend is valid and 75% chance to move based on the friend.
        if (GetIsObjectValid (oFriend) && d4() < 3)
        {
            // 50% to move to the friend.
            if (d4() < 2) ActionMoveToObject (oFriend, TRUE);
            // 50% to move away from the friend.
            else AIActionRandomMoveAway (oFriend, 100.0);
            /* else
            {
                effect eAnimal = EffectDisappearAppear (GetLocation (oFriend));
                ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eBird, OBJECT_SELF, 4.0);
                AnimActionRandomMoveAway (oFriend, 100.0);
            }  */
        }
        // 25% to randomly walk.
        else ActionRandomWalk ();
        return;
    }
    // Lets see if there are pressing issues to deal with!
    // Possibly close open doors
    if (AIActionCloseDoors ()) return;
    // If there are no issues then lets find something to do!
    // For the rest of these, we check for specific rolls,
    // to ensure that we don't do a lot of lookups on any one given pass.
    int iChance = Random (100);
    // Talking to a friend?
    if (iChance < 20) if (AIActionFindFriend (20.0f)) return;
    // Use a placeable?
    if (iChance < 25) if (AIActionFindPlaceable (20.0f)) return;
    // Sit down?
    if (iChance < 30) if (AIActionSitInChair (20.0f)) return;
    // If set to Close range then random walk or goto spawn location.
    if (iChance < 50 && GetAICondition (AI_IS_MOBILE_CLOSE_RANGE))
    {
        if (iChance < 10)
        {
            ActionRandomWalk ();
            return;
        }
        // Move back to starting point, saved at initialization
        ActionMoveToLocation (GetLocalLocation (OBJECT_SELF,"ANIM_START_LOCATION"));
        return;
    }
    // Check all fully mobile actions.
    if (iChance < 50)
    {
        /* These are turned off until we decide to make a more detailed NPC AI.
        // Check if we should go home
        if (AnimActionGoHome ()) return;
        // Check if we should leave home
        if (AnimActionLeaveHome ()) return;
        */
        // Check to see if we need to go inside.
        if (iChance < 5)
        {
            if (AIActionGoInside ()) return;
            else if (AIActionGoOutside ()) return;
        }
        // Check to see if we need to move to a waypoint.
        if (iChance < 25) if (AIActionGoToWaypoint (20.0f)) return;
        // Do a random walk.
        if (iChance < 40)
        {
            ActionRandomWalk ();
            return;
        }
        // Return to the NPC's spawn location.
        ActionMoveToLocation (GetLocalLocation (OBJECT_SELF, "ANIM_START_LOCATION"));
        return;
    }
    // Default: do a random immobile ai.
    RunAIImmobile ();
}

// Returns TRUE if the creature is busy talking or interacting with a placeable.
int GetIsBusyWithAnimation (object oCreature)
{
    if (GetAICondition (AI_IS_TALKING, oCreature)) return TRUE;
    else if (GetAICondition (AI_IS_INTERACTING, oCreature)) return TRUE;
    return FALSE;
}

// Detect if the creature should have special location ai.
// Such as if in a tavern or church.
void GetLocationAI (object oCreature)
{
    // Check if we are in a tavern.
    object oWaypoint = GetNearestObjectByTag ("NW_TAVERN");
    if (GetIsObjectValid (oWaypoint)) SetAICondition (AI_TAVERN);
    else SetAICondition (AI_TAVERN, FALSE);
    // Check if we are in a church.
    oWaypoint = GetNearestObjectByTag ("NW_CHURCH");
    if (GetIsObjectValid (oWaypoint)) SetAICondition (AI_CHURCH);
    else SetAICondition (AI_CHURCH, FALSE);
}

// Get a random nearby friend within the specified distance limit,
// that isn't busy doing something else.
object GetRandomFriend (float fMaxDistance)
{
    object oFriend = GetNearestCreature (CREATURE_TYPE_REPUTATION,
                                        REPUTATION_TYPE_FRIEND,
                                        OBJECT_SELF, d2(),
                                        CREATURE_TYPE_PERCEPTION,
                                        PERCEPTION_SEEN);
    if (GetIsObjectValid (oFriend)
        && !GetIsPC(oFriend)
        && !IsInConversation (oFriend)
        && !GetIsInCombat (oFriend)
        && !GetIsBusyWithAnimation (oFriend)
        && GetDistanceToObject (oFriend) <= fMaxDistance)
    {
        return oFriend;
    }
    return OBJECT_INVALID;
}

// Get a random nearby object within the specified distance with the specified tag.
object GetRandomObjectByTag (string sTag, float fMaxDistance)
{
    int iNth;
    if (fMaxDistance == 5.0f) iNth = d2();
    else if (fMaxDistance == 10.0f) iNth = d4();
    else iNth = d6();
    object oObj = GetNearestObjectByTag (sTag, OBJECT_SELF, iNth);
    if (GetIsObjectValid (oObj) && GetDistanceToObject (oObj) <= fMaxDistance) return oObj;
    return OBJECT_INVALID;
}

// Get a random nearby object within the specified distance with the specified type.
// iObjType: Any of the OBJECT_TYPE_* constants
object GetRandomObjectByType (int iObjType, float fMaxDistance)
{
    int iNth;
    if (fMaxDistance == 5.0f) iNth = d2();
    else if (fMaxDistance == 10.0f) iNth = d4();
    else iNth = d6();
    object oObj = GetNearestObject (iObjType, OBJECT_SELF, iNth);
    if (GetIsObjectValid (oObj) && GetDistanceToObject (oObj) <= fMaxDistance) return oObj;
    return OBJECT_INVALID;
}

// Get a random waypoint in the area.
// If fMaxDistance is non-zero, will return OBJECT_INVALID
// if the stop is too far away.
// The first time this is called in a given area, it cycles
// through all the stops in the area and store how many in var ANIM_STOPS.
object GetRandomWaypoint (float fMaxDistance)
{
    object oWaypoint;
    object oArea = GetArea(OBJECT_SELF);
    if (!GetLocalInt(oArea, "ANIM_STOPS"))
    {
        // first time -- look up all the stops in the area and store them
        int iNth = 1;
        oWaypoint = GetNearestObject (OBJECT_TYPE_WAYPOINT);
        while (GetIsObjectValid (oWaypoint))
        {
            iNth ++;
            oWaypoint = GetNearestObject (OBJECT_TYPE_WAYPOINT, OBJECT_SELF, iNth);
        }
        SetLocalInt (oArea, "ANIM_STOPS", iNth - 1);
    }
    int iWaypoint = Random (GetLocalInt (oArea, "ANIM_STOPS")) + 1;
    oWaypoint = GetObjectInArea (oArea, iWaypoint, OBJECT_TYPE_WAYPOINT, TRUE);
    if (GetIsObjectValid (oWaypoint) && GetDistanceToObject (oWaypoint) <= fMaxDistance) return oWaypoint;
    return OBJECT_INVALID;
}

// Set a specific creature (or OBJECT_INVALID to clear) as the caller's "friend"
void SetCurrentFriend (object oFriend)
{
    // If this is not an object then delete old friend.
    if (!GetIsObjectValid (oFriend)) DeleteLocalObject (OBJECT_SELF, "NW_ANIM_FRIEND");
    // Otherwise set them as npc's current friend.
    else SetLocalObject(OBJECT_SELF, "NW_ANIM_FRIEND", oFriend);
}

// Get the caller's current friend, if set; OBJECT_INVALID otherwise
object GetCurrentFriend ()
{
    return GetLocalObject (OBJECT_SELF, "NW_ANIM_FRIEND");
}

// Set an object (or OBJECT_INVALID to clear) as the caller's interactive target.
void SetCurrentInteractionTarget (object oTarget)
{
    // If the target is not valid then clear.
    if (!GetIsObjectValid(oTarget)) DeleteLocalObject(OBJECT_SELF, "NW_ANIM_TARGET");
    // Set the target.
    else SetLocalObject(OBJECT_SELF, "NW_ANIM_TARGET", oTarget);
}

// Get the caller's current interaction target, if set; OBJECT_INVALID otherwise
object GetCurrentInteractionTarget ()
{
    return GetLocalObject(OBJECT_SELF, "NW_ANIM_TARGET");
}

// Check to see if we should switch on detect/stealth mode
void CheckCurrentModes()
{
    object oWay = GetNearestObject(OBJECT_TYPE_WAYPOINT);
    string sTag = GetTag(oWay);
    if (sTag == "NW_STEALTH")
    {
        // turn on stealth mode
        SetModeActive(NW_MODE_STEALTH);
        /*if (GetModeActive(NW_MODE_STEALTH))
        {
            // turn off stealth mode
            SetModeActive(NW_MODE_STEALTH, FALSE);
        }
        else
        {
            // turn on stealth mode
            SetModeActive(NW_MODE_STEALTH);
        } */
    }
    else if (sTag == "NW_DETECT")
    {
        // turn on detect mode
        SetModeActive(NW_MODE_DETECT);
        /*if (GetModeActive(NW_MODE_DETECT))
        {
            // turn off detect mode
            SetModeActive(NW_MODE_DETECT);
        }
        else
        {
            // turn on detect mode
            SetModeActive(NW_MODE_DETECT);
        } */
    }
}

/**********************************************************************
 **********************************************************************
 * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE
 * The functions below here are building blocks used in the main
 * functions above.
 * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE
 **********************************************************************
 **********************************************************************/
// Start interacting with a placeable object
void AIActionStartInteracting (object oPlaceable)
{
    // The the NPC to interacting.
    SetAICondition (AI_IS_INTERACTING);
    if (!GetAICondition (AI_IS_IMMOBILE)) ActionMoveToObject (oPlaceable, FALSE, 2.5f);
    ActionDoCommand (SetFacingPoint (GetPosition (oPlaceable)));
    SetCurrentInteractionTarget (oPlaceable);
    AIActionPlayRandomInteractAnimation (oPlaceable);
}

// Stop interacting with a placeable object
void AIActionStopInteracting ()
{
    if (!GetAICondition (AI_IS_IMMOBILE)) AIActionRandomMoveAway (GetCurrentInteractionTarget(), 20.0f);
    SetCurrentInteractionTarget (OBJECT_INVALID);
    SetAICondition (AI_IS_INTERACTING, FALSE);
    if (Random (100) < 50) AIActionTurnAround ();
}

// Start talking with a friend
void AIActionStartTalking (object oFriend, int iHDiff=0)
{
    object oMe = OBJECT_SELF;
    // If NPC's are mobile then move to the new friend.
    if (!GetAICondition (AI_IS_IMMOBILE)) ActionMoveToObject (oFriend, FALSE, 2.5f);
    if (!GetAICondition (AI_IS_IMMOBILE, oFriend)) AssignCommand (oFriend, ActionMoveToObject (oMe, FALSE, 2.5f));
    // Set NPC's as friends.
    SetCurrentFriend (oFriend);
    AssignCommand (oFriend, SetCurrentFriend (oMe));
    // Turn towards each other.
    ActionDoCommand (SetFacingPoint (GetPosition (oFriend)));
    AssignCommand (oFriend, ActionDoCommand (SetFacingPoint (GetPosition (oMe))));
    // Do greetings.
    AIActionPlayRandomGreeting (iHDiff);
    AssignCommand (oFriend, AIActionPlayRandomGreeting (0 - iHDiff));
    // Set that we are both talking.
    SetAICondition (AI_IS_TALKING);
    SetAICondition (AI_IS_TALKING, TRUE, oFriend);
}

// Stop talking to the given friend
void AIActionStopTalking(object oFriend, int iHDiff=0)
{
    object oMe = OBJECT_SELF;
    // Have NPC say goodbye.
    AIActionPlayRandomGoodbye (iHDiff);
    // If NPC is mobile then move away.
    if (!GetAICondition (AI_IS_IMMOBILE)) AIActionRandomMoveAway (oFriend, 20.0f);
    // If NPC is immobile then maybe turn around.
    else if (Random (100) < 50) AIActionTurnAround ();
    // Have Friend say goodbye.
    AssignCommand (oFriend, AIActionPlayRandomGoodbye (0 - iHDiff));
    // If Friend is mobile then move away.
    if (!GetAICondition (AI_IS_IMMOBILE, oFriend)) AssignCommand (oFriend, AIActionRandomMoveAway (oMe, 20.0f));
    // If Friend is immobile then maybe turn around.
    else if (Random (100) < 50) AssignCommand (oFriend, AIActionTurnAround ());
    // Set both as not talking.
    SetAICondition (AI_IS_TALKING, FALSE);
    SetAICondition (AI_IS_TALKING, FALSE, oFriend);
}

// Play a greeting animation and possibly voicechat.
// If a negative hit dice difference (HD caller - HD greeted) is
// passed in, the caller will bow.
void AIActionPlayRandomGreeting (int iHDiff = 0)
{
    if (Random (100) < 5) VoiceHello();
    if (iHDiff < 0 || Random(4) == 0) ActionPlayAnimation (ANIMATION_FIREFORGET_BOW);
    else ActionPlayAnimation (ANIMATION_FIREFORGET_GREETING);
}

// Play a random farewell animation and possibly voicechat.
// If a negative hit dice difference is passed in, the
// caller will bow.
void AIActionPlayRandomGoodbye (int iHDiff)
{
    if (Random (100) < 5) VoiceGoodbye();
    if (iHDiff < 0 || Random(4) == 0) ActionPlayAnimation (ANIMATION_FIREFORGET_BOW);
    else ActionPlayAnimation (ANIMATION_FIREFORGET_GREETING);
}

// Randomly move away from an object the specified distance.
// This is mainly because ActionMoveAwayFromLocation isn't working.
void AIActionRandomMoveAway(object oSource, float fDistance)
{
    location lTarget = GetRandomLocation (GetArea(OBJECT_SELF), oSource, fDistance);
    ActionMoveToLocation (lTarget);
}

// Play animation of shaking head "no" to left & right
void AIActionShakeHead()
{
    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 3.0);
    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 3.0);
}

// Play animation of looking to left and right
void AIActionLookAround()
{
    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_LEFT, 0.75);
    ActionPlayAnimation(ANIMATION_FIREFORGET_HEAD_TURN_RIGHT, 0.75);
}

// Turn around to face a random direction
void AIActionTurnAround()
{
    ActionDoCommand (SetFacing (IntToFloat (Random(360))));
}



// Go through a door and close it behind you,
// then walk a short distance away.
// This assumes the door exists, is unlocked, etc.
void AIActionGoThroughDoor(object oDoor)
{
    //AnimDebug("going through door " + GetTag(oDoor));
    SetLocalInt (oDoor, "BEING_CLOSED", TRUE);
    object oDest = GetTransitionTarget (oDoor);
    ActionMoveToObject (oDest);
    ActionDoCommand (AssignCommand (oDest, ActionCloseDoor (oDest)));
    ActionDoCommand (AssignCommand (oDoor, ActionCloseDoor (oDoor)));
    ActionDoCommand (SetLocalInt (oDoor, "BEING_CLOSED", FALSE));
    DelayCommand (10.0, SetLocalInt (oDoor, "BEING_CLOSED", FALSE));
    AIActionRandomMoveAway (oDest, 10.0f);
}

/**********************************************************************
 * The following AnimAction functions have a possibility of failing
 * and not assigning any actions.
 * They return TRUE on success, FALSE on failure. See notes up in the
 * prototype section for details.
 **********************************************************************/
// Get or put up a torch.
int AIActionTorch ()
{
    object oTorch;
    // Lets not all do it at the same time.
    if (Random (100) < 75) return FALSE;
    // If it is night time and we are not inside.
    if (GetIsNight () && !GetIsAreaInterior (GetArea (OBJECT_SELF)))
    {
        // Do we already have a torch?
        if (!GetAICondition (AI_HAS_TORCH))
        {
            // Only pull out a torch if we can't see in the dark.
            if (!GetHasFeat (FEAT_DARKVISION) && !GetHasFeat (FEAT_LOWLIGHTVISION))
            {
                // Create the torch.
                oTorch = CreateItemOnObject ("0_torch");
                // Make the torch not droppable.
                SetDroppableFlag (oTorch, FALSE);
                ClearAllActions();
                // Now equip it.
                ActionEquipItem (oTorch, INVENTORY_SLOT_LEFTHAND);
                SetAICondition (AI_HAS_TORCH);
                return TRUE;
            }
        }
    }
    // If it is daytime and we have a torch we need to put it away.
    else if (GetAICondition (AI_HAS_TORCH))
    {
        // Get the item in the left hand.
        oTorch = GetItemInSlot (INVENTORY_SLOT_LEFTHAND);
        if (GetTag (oTorch) == "0_torch") ActionUnequipItem (oTorch);
        SetAICondition (AI_HAS_TORCH, FALSE);
        return TRUE;
    }
    return FALSE;
}

// If there's an open door nearby, possibly go close it,
// then come back to our current spot.
int AIActionCloseDoors ()
{
    // The chance we just ignore the door.
    if (Random(100) < 90) return FALSE;
    location locCurrent;
    int iNth = 1;
    // Lets cycle through all the doors and see if any are open.
    object oDoor = GetNearestObject (OBJECT_TYPE_DOOR);
    while (GetIsObjectValid(oDoor))
    {
        locCurrent = GetLocation (OBJECT_SELF);
        // Make sure the door is not too far away.
        if (GetDistanceBetween (oDoor, OBJECT_SELF) < 15.0f)
        {
            // Set a variable to make sure everyone doesn't run to close the same door.
            if (GetIsOpen(oDoor) && !GetLocalInt (oDoor, "BEING_CLOSED"))
            {
                // Set that this door is being closed.
                SetLocalInt (oDoor, "BEING_CLOSED", TRUE);
                // Close the door.
                ActionCloseDoor (oDoor);
                // Once we are done clear the variable.
                ActionDoCommand (SetLocalInt (oDoor, "BEING_CLOSED", FALSE));
                // Now lets go back to where we were.
                ActionMoveToLocation (locCurrent);
                return TRUE;
            }
        }
        iNth ++;
        oDoor = GetNearestObject (OBJECT_TYPE_DOOR, OBJECT_SELF, iNth);
    }
    return FALSE;
}

// Sit in a random nearby chair if available.
// Looks for items with tag: Chair
int AIActionSitInChair (float fMaxDistance)
{
    object oChair = GetRandomObjectByTag ("Chair", fMaxDistance);
    if (GetIsObjectValid (oChair) && !GetIsObjectValid (GetSittingCreature (oChair)))
    {
        ActionMoveToLocation (GetLocation (oChair));
        ActionSit (oChair);
        SetAICondition (AI_IS_INTERACTING);
        return TRUE;
    }
    return FALSE;
}

// Get up from a chair if we're sitting
int AIActionGetUpFromChair ()
{
    if (GetCurrentAction() == ACTION_SIT)
    {
        ClearAllActions();
        SetAICondition(AI_IS_INTERACTING, FALSE);
        AIActionRandomMoveAway (GetNearestObject (OBJECT_TYPE_PLACEABLE), 5.0f);
        return TRUE;
    }
    return FALSE;
}

// Go through a nearby door if appropriate.
// This will be done if the door is unlocked and
// the area the door leads to contains a waypoint
// with one of these tags: NW_TAVERN, NW_SHOP, NW_CHURCH
int AIActionGoInside ()
{
    // Don't go inside a second area, since we'll never get
    // back to our original one if we do that.
    if (GetAICondition (AI_IS_INSIDE)) return FALSE;
    object oDoor = GetRandomObjectByType (OBJECT_TYPE_DOOR, 1000.0);
    if (!GetIsObjectValid (oDoor) || GetLocked (oDoor)) return FALSE;
    object oDest = GetTransitionTarget (oDoor);
    object oWay = GetNearestObjectByTag ("NW_TAVERN", oDest);
    if (!GetIsObjectValid (oWay)) oWay = GetNearestObjectByTag ("NW_SHOP", oDest);
    if (!GetIsObjectValid (oWay)) oWay = GetNearestObjectByTag ("NW_CHURCH", oDest);
    if (GetIsObjectValid (oWay))
    {
        AIActionGoThroughDoor (oDoor);
        SetAICondition (AI_IS_INSIDE);
        SetLocalObject (OBJECT_SELF, "NW_ANIM_DOOR", oDest);
        GetLocationAI (OBJECT_SELF);
        return TRUE;
    }
    return FALSE;
}

// Leave area if appropriate.
// This only works for NPCs that entered an area that
// has a waypoint with one of these tags: NW_TAVERN, NW_SHOP, NW_CHURCH
// If the NPC entered through a door, they will exit through that door.
int AIActionGoOutside ()
{
    if (GetAICondition (AI_IS_INSIDE))
    {
        object oDoor = GetLocalObject (OBJECT_SELF, "NW_ANIM_DOOR");
        if (GetIsObjectValid (oDoor))
        {
            DeleteLocalObject (OBJECT_SELF, "NW_ANIM_DOOR");
            AIActionGoThroughDoor (oDoor);
            SetAICondition (AI_IS_INSIDE, FALSE);
            GetLocationAI (OBJECT_SELF);
            return TRUE;
        }
    }
    return FALSE;
}

// Go to a nearby waypoint.
int AIActionGoToWaypoint (float fMaxDistance = 20.0)
{
    object oWaypoint = GetRandomWaypoint (fMaxDistance);
    if (GetIsObjectValid (oWaypoint))
    {
        ClearAllActions ();
        ActionMoveToObject(oWaypoint, FALSE, 5.0f);
        return TRUE;
    }
    return FALSE;
}

// Find a friend within the given distance and talk to them.
// Returns TRUE on success, FALSE on failure.
int AIActionFindFriend (float fMaxDistance)
{
    // Try and find a friend to talk to
    object oFriend = GetRandomFriend (fMaxDistance);
    if (GetIsObjectValid (oFriend) &&
       !GetIsBusyWithAnimation (oFriend) &&
       !GetAICondition (AI_IS_WALKING))
    {
        int iHDiff = GetHitDice(OBJECT_SELF) - GetHitDice(oFriend);
        AIActionStartTalking (oFriend, iHDiff);
        return TRUE;
    }
    return FALSE;
}

// Find a placeable within the given distance and interact
// with it.
// Returns TRUE on success, FALSE on failure.
int AIActionFindPlaceable (float fMaxDistance)
{
    object oPlaceable = GetRandomObjectByType (OBJECT_TYPE_PLACEABLE, 5.0f);
    // We don't want to interact with chairs.
    if (GetIsObjectValid (oPlaceable) && GetTag (oPlaceable) != "Chair")
    {
        // Also don't interact with locked or trapped placeables!
        if (!GetLocked (oPlaceable) && !GetIsTrapped (oPlaceable))
        {
            AIActionStartInteracting (oPlaceable);
            return TRUE;
        }
    }
    return FALSE;
}

// If injured go to the NPC's spawn location.
// Returns TRUE on success, FALSE on failure.
int AIActionReturn ()
{
    // If we are wounded then go to start location.
    if (GetCurrentHitPoints () < GetMaxHitPoints ())
    {
        // Get the start location.
        location lStart = GetLocalLocation (OBJECT_SELF, "ANIM_START_LOCATION");
        ClearAllActions ();
        ActionMoveToLocation (lStart);
        //ActionRest();
        return TRUE;
    }
    return FALSE;
}

// If it is night, they might go back to thier starting location.
// Returns TRUE on success, FALSE on failure.
int AIActionGoHome()
{
    object oHome = GetAreaFromLocation (GetLocalLocation (OBJECT_SELF, "ANIM_START_LOCATION"));
    if (!GetIsDay () && GetArea(OBJECT_SELF) != GetArea (oHome) && Random (100) < 50)
    {
        ClearAllActions ();
        AIActionGoOutside ();
        AIActionGoThroughDoor (GetLocalObject (OBJECT_SELF, "NW_ANIM_DOOR_HOME"));
        return TRUE;
    }
    return FALSE;
}

// If it is day, they might leave our home area, if we have one.
// This is only meaningful for mobile NPCs.
// Returns TRUE on success, FALSE on failure.
int AIActionLeaveHome ()
{
    object oHome = GetAreaFromLocation (GetLocalLocation (OBJECT_SELF, "ANIM_START_LOCATION"));
    if (GetIsDay() && GetArea(OBJECT_SELF) == GetArea(oHome))
    {
        // Find the nearest door and walk out
        ClearAllActions ();
        object oDoor = GetNearestObject (OBJECT_TYPE_DOOR);
        if (!GetIsObjectValid(oDoor) || GetLocked (oDoor)) return FALSE;
        object oDest = GetTransitionTarget (oDoor);
        if (GetIsObjectValid (oDest))
        {
            SetLocalObject(OBJECT_SELF, "NW_ANIM_DOOR_HOME", oDest);
            AIActionGoThroughDoor (oDoor);
            return TRUE;
        }
    }
    return FALSE;
}



/**********************************************************************
 **********************************************************************
 * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE
 * The functions stuck below here are generally just big ugly
 * switch statements to choose between a bunch of random
 * animations.
 * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE * NOTE
 **********************************************************************
 **********************************************************************/

// Interact with a placeable object.
// This will activate/deactivate the placeable object if a valid
// one is passed in.
// KLUDGE: If a placeable object without an inventory should
//         still be opened/shut instead of de/activated, set
//         its Will Save to 1.
void AIActionPlayRandomInteractAnimation (object oPlaceable)
{
    int iChance = Random(100);
    if (iChance < 10)
    {
        ActionPlayAnimation(ANIMATION_FIREFORGET_PAUSE_SCRATCH_HEAD);
        return;
    }
    // See where the placeable is in relation to us, height-wise
    vector vPos = GetPosition(oPlaceable);
    vector vMyPos = GetPosition(OBJECT_SELF);
    float fZDiff = vMyPos.z - vPos.z;
    // we're above the placeable
    if ( fZDiff > 0.0 ) ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    else ActionPlayAnimation (ANIMATION_LOOPING_GET_MID, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    // KLUDGE! KLUDGE! KLUDGE!
    // Because of placeables like the trap doors, etc, that should be
    // "opened" rather than "activated", but don't have an inventory,
    // we use this ugly hack: set the "Will" saving throw of a placeable
    // to the value 1 if it should be opened rather than activated.
    if (GetHasInventory(oPlaceable) || GetWillSavingThrow(oPlaceable) == 1)
    {
        if (GetIsOpen(oPlaceable)) AssignCommand (oPlaceable, DelayCommand (ANIM_LOOPING_LENGTH, ActionPlayAnimation (ANIMATION_PLACEABLE_CLOSE)));
        else AssignCommand (oPlaceable, DelayCommand (ANIM_LOOPING_LENGTH, ActionPlayAnimation (ANIMATION_PLACEABLE_OPEN)));
    }
    else
    {
        int iIsActive = GetLocalInt (oPlaceable, "NW_ANIM_PLACEABLE_ACTIVE");
        if (iIsActive)
        {
            AssignCommand (oPlaceable, DelayCommand (ANIM_LOOPING_LENGTH, ActionPlayAnimation (ANIMATION_PLACEABLE_DEACTIVATE)));
            SetLocalInt (oPlaceable, "NW_ANIM_PLACEABLE_ACTIVE", FALSE);
        }
        else
        {
            AssignCommand (oPlaceable, DelayCommand (ANIM_LOOPING_LENGTH, ActionPlayAnimation (ANIMATION_PLACEABLE_ACTIVATE)));
            SetLocalInt (oPlaceable, "NW_ANIM_PLACEABLE_ACTIVE", TRUE);
        }
    }
    return;
}

// Play a random talk gesture animation.
// If a hit dice difference (should be the hit dice of the caller
// minus the hit dice of the person being talked to) is passed in,
// the caller will play slightly different animations if they are
// weaker.
void AIActionPlayRandomTalkAnimation (int iHDiff)
{
    // Do chatter.
    int iAnimation, iChance = Random(100);
    // Negative voices.
    if (iChance < 1) { VoiceThreaten (); iAnimation = -30; }
    else if (iChance < 2) { VoiceCuss (); iAnimation = -25; }
    else if (iChance < 3) { VoiceStop (); iAnimation = -20; }
    else if (iChance < 4) { VoiceBadIdea (); iAnimation = -15; }
    else if (iChance < 5) { VoiceNo (); iAnimation = -10; }
    else if (iChance < 6) { VoiceCannotDo (); iAnimation = -5; }
    // Neutral voices.
    else if (iChance < 7) { VoiceLookHere (); iAnimation = 0; }
    // Positive voices.
    else if (iChance < 8) { VoiceCanDo (); iAnimation = 5; }
    else if (iChance < 9) { VoiceYes (); iAnimation = 10; }
    else if (iChance < 10) { VoiceTaskComplete (); iAnimation = 15; }
    else if (iChance < 11) { VoiceLaugh (); iAnimation = 20; }
    // Do animations.
    iAnimation = iAnimation + Random (100);
    // Forceful.
    if (iChance < 10) ActionPlayAnimation (ANIMATION_LOOPING_TALK_FORCEFUL, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    // Taunt.
    else if (iChance < 20)
    {
        if (iHDiff > 0) ActionPlayAnimation (ANIMATION_FIREFORGET_TAUNT);
        else ActionPlayAnimation (ANIMATION_FIREFORGET_PAUSE_BORED);
    }
    // Pleading.
    else if (iChance < 30)
    {
        if (iHDiff < 0) ActionPlayAnimation (ANIMATION_LOOPING_TALK_PLEADING, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
        else ActionPlayAnimation (ANIMATION_LOOPING_TALK_PLEADING, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    }
    // Shake head.
    else if (iChance < 40) AIActionShakeHead ();
    // Listen.
    else if (iChance < 60) ActionPlayAnimation (ANIMATION_LOOPING_LISTEN, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    // Talking.
    else if (iChance < 85) ActionPlayAnimation (ANIMATION_LOOPING_TALK_NORMAL, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    // Salute.
    else if (iChance < 90)
    {
        if (iHDiff < 0) ActionPlayAnimation (ANIMATION_FIREFORGET_SALUTE, 0.75);
        else ActionPlayAnimation (ANIMATION_LOOPING_LOOK_FAR, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
    }
    // Laughter
    else ActionPlayAnimation (ANIMATION_LOOPING_TALK_LAUGHING, ANIM_LOOPING_SPEED, ANIM_LOOPING_LENGTH);
}

/* DO NOT CLOSE THIS TOP COMMENT!
   This main() function is here only for compilation testing.
void main() {}
/* */
