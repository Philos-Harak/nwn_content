//::///////////////////////////////////////////////
//:: Generic eventhook include
//:: inc_eventhook
//:://////////////////////////////////////////////
/** @file
    A system for scheduling scripts to be run on
    an arbitrary event during runtime (instead of
    being hardcoded in compilation).

    Scheduling a script happens by calling
    AddEventScript with the object the script is
    to be run on (and on which the data about the
    script is stored on), an EVENT_* constant
    determining the event that the script is to be
    run on and the name of the script to be run.

    In addition to these, there is a parameter to
    control whether the script will be just during
    the next invocation of the event, or during all
    invocations from now on until the script is
    explicitly descheduled.
    This feature only automatically works when using
    ExecuteAllScriptsHookedToEvent(). That is, merely
    viewing the eventscript list does not trigger the
    effect.

    See the comments in function prototype section for
    more details.


    Added event constants to be used with items. For
    example, now you can define a script to be fired
    for The Sword of Foo every time someone equips it.


    NOTE: Persistence of scripts hooked to non-creatures
    over module boundaries is not guaranteed. ie, if
    the player takes abovementioned Sword of Foo to
    another module, it most likely will lose the locals
    defining the script hooked into it.


    @author Ordedan
    @date   Created  - 28.02.2005
    @date   Modified - 26.05.2005
    @date   Modified - 04.09.2005
*/
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////


//////////////////////////////////////////////////
/* Constant defintions                          */
//////////////////////////////////////////////////

// Module events

/// Module event - On Acquire Item
const int EVENT_ONACQUIREITEM               = 1;
/// Module event - On Activate Item
const int EVENT_ONACTIVATEITEM              = 2;
/// Module event - On Client Enter
const int EVENT_ONCLIENTENTER               = 3;
/// Module event - On Client Leave
const int EVENT_ONCLIENTLEAVE               = 4;
/// Module event - On Cutscene Abort
const int EVENT_ONCUTSCENEABORT             = 5;
/// Module event - On Heartbeat
const int EVENT_ONHEARTBEAT                 = 6;
/// Module event - On Player Death
const int EVENT_ONPLAYERDEATH               = 9;
/// Module event - On Player Dying
const int EVENT_ONPLAYERDYING               = 10;
/// Module event - On Player Equip Item
const int EVENT_ONPLAYEREQUIPITEM           = 11;
/// Module event - On Player Level Up
const int EVENT_ONPLAYERLEVELUP             = 12;
/// Module event - On Player Rest Cancelled
const int EVENT_ONPLAYERREST_CANCELLED      = 13;
/// Module event - On Player Rest Started
const int EVENT_ONPLAYERREST_STARTED        = 14;
/// Module event - On Player Rest Finished
const int EVENT_ONPLAYERREST_FINISHED       = 15;
/// Module event - On Player Unequip Item
const int EVENT_ONPLAYERUNEQUIPITEM         = 16;
/// Module event - On Player Respawn
const int EVENT_ONPLAYERRESPAWN             = 17;
/// Module event - On Unacquire Item
const int EVENT_ONUNAQUIREITEM              = 18;
/// Module event - On Player Chat
const int EVENT_ONPLAYERCHAT                = 49;

/**
 * Module Event - On Userdefined
 * This has special handling
 * @see prc_onuserdef.nss
 */
const int EVENT_ONUSERDEFINED               = 19;


// Other events
/// Virtual event - On Hit
/// Requires OnHitCastSpell: Unique on the weapon used
const int EVENT_ONHIT                       = 20;
/// Virtual event - On Spell Cast
//const int EVENT_ONSPELLCAST           = 21;
/// Virtual event - On Power Manifest
//const int EVENT_ONPOWERMANIFEST       = 22;


/// Virtual event - On Player Level Down
/// WARNING: Event detection is slightly inaccurate
const int EVENT_ONPLAYERLEVELDOWN           = 35;

/// Virtual event - On Physically Attacked
/// WARNING: Event detection is highly inaccurate
const int EVENT_VIRTUAL_ONPHYSICALATTACKED  = 36;

/// Virtual event - On Blocked
/// WARNING: Event detection is inaccurate
const int EVENT_VIRTUAL_ONBLOCKED           = 37;

/// Virtual event - On Combat Round End
/// WARNING: Event detection is inaccurate
const int EVENT_VIRTUAL_ONCOMBATROUNDEND    = 38;

/// Virtual event - On Conversation
/// Does not work on PCs!
const int EVENT_VIRTUAL_ONCONVERSATION      = 39;

/// Virtual event - On Damaged
/// WARNING: Event detection is slightly inaccurate
const int EVENT_VIRTUAL_ONDAMAGED           = 40;

/// Virtual event - On Disturbed
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONDISTURBED         = 41;

/// Virtual event - On Perception
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONPERCEPTION        = 42;

/// Virtual event - On Spawned
const int EVENT_VIRTUAL_ONSPAWNED           = 43;

/// Virtual event - On Spell Cast At
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONSPELLCASTAT       = 44;

/// Virtual event - On Death
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONDEATH             = 45;

/// Virtual event - On Rested
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONRESTED            = 46;

/// Virtual event - On User Defined
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONUSERDEFINED       = 47;

/// Virtual event - On Heartbeat
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONHEARTBEAT         = 48;

/// Virtual event - On Player Chat
/// WARNING: Event detection may be inaccurate
const int EVENT_VIRTUAL_ONPLAYERCHAT        = 50;

// NPC events
/// NPC event - On Blocked
const int EVENT_NPC_ONBLOCKED               = 23;
/// NPC event - On Combat Round End
const int EVENT_NPC_ONCOMBATROUNDEND        = 24;
/// NPC event - On Conversation
const int EVENT_NPC_ONCONVERSATION          = 25;
/// NPC event - On Damaged
const int EVENT_NPC_ONDAMAGED               = 26;
/// NPC event - On Death
const int EVENT_NPC_ONDEATH                 = 27;
/// NPC event - On Disturbed
const int EVENT_NPC_ONDISTURBED             = 28;
/// NPC event - On Heartbeat
const int EVENT_NPC_ONHEARTBEAT             = 29;
/// NPC event - On Perception
const int EVENT_NPC_ONPERCEPTION            = 30;
/// NPC event - On Physically Attacked
const int EVENT_NPC_ONPHYSICALATTACKED      = 31;
/// NPC event - On Rested
const int EVENT_NPC_ONRESTED                = 32;
/// NPC event - On Spell Cast At
const int EVENT_NPC_ONSPELLCASTAT           = 34;


/* Item events */
/// Virtual item event - On Acquire Item
const int EVENT_ITEM_ONACQUIREITEM          = 1000;
/// Virtual item event - On Activate Item
const int EVENT_ITEM_ONACTIVATEITEM         = 1001;
/// Virtual item event - On Player Equip Item
const int EVENT_ITEM_ONPLAYEREQUIPITEM      = 1002;
/// Virtual item event - On Player Unequip Item
const int EVENT_ITEM_ONPLAYERUNEQUIPITEM    = 1003;
/// Virtual item event - On Acquire Item
const int EVENT_ITEM_ONUNAQUIREITEM         = 1004;
/// Virtual item event - On Hit
/// Requires OnHitCastSpell: Unique on the item used to hit
const int EVENT_ITEM_ONHIT                  = 1005;

/* Placeable events */
//Note these will only fire for placeables using the
//prc_plc_* scriptset

// Placeable event - OnClick (1.67 or later only)
const int EVENT_PLACEABLE_ONCLICK           = 3001;
// Placeable event - OnClose
const int EVENT_PLACEABLE_ONCLOSE           = 3002;
// Placeable event - OnDamaged
const int EVENT_PLACEABLE_ONDAMAGED         = 3003;
// Placeable event - OnDeath
const int EVENT_PLACEABLE_ONDEATH           = 3004;
// Placeable event - OnHeartbeat
const int EVENT_PLACEABLE_ONHEARTBEAT       = 3005;
// Placeable event - OnDisturbed
const int EVENT_PLACEABLE_ONDISTURBED       = 3006;
// Placeable event - OnLock
const int EVENT_PLACEABLE_ONLOCK            = 3007;
// Placeable event - OnPhysicalAttacked
const int EVENT_PLACEABLE_ONATTACKED        = 3008;
// Placeable event - OnOpen
const int EVENT_PLACEABLE_ONOPEN            = 3009;
// Placeable event - OnSpellCastAt
const int EVENT_PLACEABLE_ONSPELL           = 3010;
// Placeable event - OnUnLock
const int EVENT_PLACEABLE_ONUNLOCK          = 3011;
// Placeable event - OnUsed
const int EVENT_PLACEABLE_ONUSED            = 3012;
// Placeable event - OnUserDefined
const int EVENT_PLACEABLE_ONUSERDEFINED     = 3013;

/* Door events */
//Note these will only fire for doors using the
//Note that placeable doors use the placeable set
//prc_door_* scriptset
// Door event - OnAreaTransitionClick
const int EVENT_DOOR_ONTRANSITION           = 4001;
// Door event - OnClose
const int EVENT_DOOR_ONCLOSE                = 4002;
// Door event - OnDamaged
const int EVENT_DOOR_ONDAMAGED              = 4003;
// Door event - OnDeath
const int EVENT_DOOR_ONDEATH                = 4004;
// Door event - OnFailToOpen
const int EVENT_DOOR_ONFAILTOOPEN           = 4005;
// Door event - OnHeartbeat
const int EVENT_DOOR_ONHEARTBEAT            = 4006;
// Door event - OnLock
const int EVENT_DOOR_ONLOCK                 = 4007;
// Door event - OnPhysicalAttacked
const int EVENT_DOOR_ONATTACKED             = 4008;
// Door event - OnOpen
const int EVENT_DOOR_ONOPEN                 = 4009;
// Door event - OnSpellCastAt
const int EVENT_DOOR_ONSPELL                = 4010;
// Door event - OnUnLock
const int EVENT_DOOR_ONUNLOCK               = 4011;
// Door event - OnUserDefined
const int EVENT_DOOR_ONUSERDEFINED          = 4012;



/* Callback hooks */
/// Callback hook - Unarmed evaluation
const int CALLBACKHOOK_UNARMED              = 2000;


/// When TRUE, ExecuteAllScriptsHookedToEvent() will print a list of the scripts it executes.
/// Disabling DEBUG will disablet this, too.
const int PRINT_EVENTHOOKS = FALSE;

/////////////////////////
// Internal constants  //
/////////////////////////

const string PERMANENCY_SUFFIX = "_permanent";

// Unused events
//const int EVENT_ONMODULELOAD          = 7;                              // Not included, since anything that would be hooked to this event
//const string NAME_ONMODULELOAD        = "prc_event_array_onmoduleload"; // should be directly in the eventscript anyway.
//const int EVENT_NPC_ONSPAWN         = 33;                           // No way to add script to the hook for a creature before this fires
//const string NAME_NPC_ONSPAWN       = "prc_event_array_npc_onspawn";


//////////////////////////////////////////////////
/* Function prototypes                          */
//////////////////////////////////////////////////

/**
 * Adds the given script to be fired when the event next occurs for the given object.
 * NOTE! Do not add a script that calls ExecuteAllScriptsHookedToEvent() to an eventhook.
 * It will result in recursive infinite loop.
 *
 * @param oObject          The object that the script is to be fired for
 * @param nEvent           One of the EVENT_* constants defined in "inc_eventhook",
 *                         (or any number, but then need to be a bit more careful, since the system won't complain if you typo it)
 * @param sScript          The script to be fired on the event. Special case: "" will not be stored.
 * @param bPermanent       Unless this is set, the script will be only fired once, after which it
 *                         is removed from the list
 *
 * @param bAllowDuplicate  This being set makes the function first check if a script with
 *                         the same name is already queued for the event and avoids adding a
 *                         duplicate. This will not remove duplicates already present, though.
 */
int AddEventScript(object oObject, int nEvent, string sScript, int bPermanent = FALSE, int bAllowDuplicate = TRUE);

/**
 * Removes all instances of the given script from the given eventhook
 *
 * @param oObject          The object that the script is to be removed from the list for.
 * @param nEvent           One of the EVENT_* constants defined in "inc_eventhook"
 * @param sScript          The script to be removed from the event
 *
 * @param bPermanent       Depending on the state of this switch, the script is either removed
 *                         from the one-shot or permanent list.
 *
 * @param bIgnorePermanency Setting this to true will make the function clear the script from
 *                          both one-shot and permanent lists, regardless of the value of bPermanent
 */
void RemoveEventScript(object oObject, int nEvent, string sScript, int bPermanent = FALSE, int bIgnorePermanency = FALSE);

/**
 * Removes all scripts in the given eventhook
 *
 * @param oObject           The object to clear script list for.
 * @param nEvent            One of the EVENT_* constants defined in "inc_eventhook"
 *
 * @param bPermanent        Depending on the state of this switch, the scripts are either removed
 *                          from the one-shot or permanent list.
 *
 * @param bIgnorePermanency Setting this to true will make the function clear both one-shot and
 *                          permanent lists, regardless of the value of bPermanent
 */
void ClearEventScriptList(object oObject, int nEvent, int bPermanent = FALSE, int bIgnorePermanency = FALSE);

/**
 * Gets the first script hooked to the given event.
 * This must be called before any calls to GetNextEventScript() are made.
 *
 * @param oObject          The object to get a script for.
 * @param nEvent           One of the EVENT_* constants defined in "inc_eventhook"
 * @param bPermanent       Which list to get the first script from.
 *
 * @return The name of the first script stored, or "" if one was not found.
 */
string GetFirstEventScript(object oObject, int nEvent, int bPermanent);

/**
 * Gets the next script hooked to the given event.
 * You should call GetFirstEventScript before calling this.
 *
 * @param oObject          The object to get a script for.
 * @param nEvent           One of the EVENT_* constants defined in "inc_eventhook"
 * @param bPermanent       Which list to get the first script from.
 *
 * @return                 The name of the next script in the list, or "" if there are no more scripts
 *                         left. Also returns "" if GetFirstEventScript hasn't been called.
 */
string GetNextEventScript(object oObject, int nEvent, int bPermanent);

/**
 * Executes all scripts in both the one-shot and permanent hooks and
 * clears scripts off the one-shot hook afterwards.
 * It is recommended this be used instead of manually going through
 * the script lists with Get(First|Next)EventScript.
 *
 * All the scripts will be ExecuteScripted on OBJECT_SELF, so they will
 * behave as if being in the script slot for that event.
 *
 * @param oObject          The object to execute listed scripts for.
 * @param nEvent           One of the EVENT_* constants defined in "inc_eventhook"
 */
void ExecuteAllScriptsHookedToEvent(object oObject, int nEvent);

/**
 * Gets the event currently being run via ExecuteAllScriptsHookedToEvent
 *
 * @return One of the EVENT_* constants if an ExecuteAllScriptsHookedToEvent
 *         is being run, FALSE otherwise.
 */
int GetRunningEvent();


//////////////////////////////////////////////////
/* Include section                              */
//////////////////////////////////////////////////

//#include "inc_utility"
//#include "inc_array"
#include "inc_pers_array"  // link higher than inc_array



///////////////////////////////////////////////////////////////////////
/* Private function prototypes - Move on people, nothing to see here */
///////////////////////////////////////////////////////////////////////

/// Internal function. Returns the name matching the given integer constant
string EventTypeIdToName(int nEvent);

string _GetMarkerLocalName(string sScript, string sArrayName);

/// Internal function - Array wrapper
int wrap_array_create(object store, string name);
/// Internal function - Array wrapper
int wrap_array_set_string(object store, string name, int i, string entry);
/// Internal function - Array wrapper
string wrap_array_get_string(object store, string name, int i);
/// Internal function - Array wrapper
int wrap_array_shrink(object store, string name, int size_new);
/// Internal function - Array wrapper
int wrap_array_get_size(object store, string name);
/// Internal function - Array wrapper
int wrap_array_exists(object store, string name);

//////////////////////////////////////////////////
/* Function defintions                          */
//////////////////////////////////////////////////


int AddEventScript(object oObject, int nEvent, string sScript, int bPermanent = FALSE, int bAllowDuplicate = TRUE){
    // If an eventhook is running, place the call into queue
    if(GetLocalInt(GetModule(), "prc_eventhook_running")){
        int nQueue = GetLocalInt(GetModule(), "prc_eventhook_pending_queue") + 1;
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue", nQueue);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_operation", 1);
        SetLocalObject(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_target", oObject);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_event", nEvent);
        SetLocalString(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_script", sScript);
        bPermanent = (bPermanent != 0);
        bAllowDuplicate = (bAllowDuplicate != 0);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_flags", ((bPermanent << 1) | (bAllowDuplicate)));
        return FALSE; //TODO: What should this really be?
    }

    string sArrayName = EventTypeIdToName(nEvent);

    // Abort if the object given / event / script isn't valid
    if(!GetIsObjectValid(oObject) || sArrayName == "" || sScript == "") return FALSE;


    sArrayName += bPermanent ? PERMANENCY_SUFFIX : "";

    // Create the array if necessary
    if(!wrap_array_exists(oObject, sArrayName)){
        wrap_array_create(oObject, sArrayName);
    }

    // Check for duplicates if necessary
    int bAdd = TRUE;
    if(!bAllowDuplicate){
        // Check if a marker is present.
        if(GetLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName)))
            bAdd = FALSE;
        // Since this might be the first time it is looked up, loop through the whole list anyway
        else
        {
            int i, nMax = wrap_array_get_size(oObject, sArrayName);
            for(i = 0; i < nMax; i++){
                if(wrap_array_get_string(oObject, sArrayName, i) == sScript){
                    // Add a marker that the script is present
                    SetLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName), TRUE);
                    bAdd = FALSE;
                    break;
    }   }   }   }
    // Add to the array if needed
    if(bAdd)
    {
        wrap_array_set_string(oObject, sArrayName, wrap_array_get_size(oObject, sArrayName), sScript);
        // Add a marker that the script is present
        SetLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName), TRUE);
    }
    return bAdd;
}


void RemoveEventScript(object oObject, int nEvent, string sScript, int bPermanent = FALSE, int bIgnorePermanency = FALSE){
    // If an eventhook is running, place the call into queue
    if(GetLocalInt(GetModule(), "prc_eventhook_running")){
        int nQueue = GetLocalInt(GetModule(), "prc_eventhook_pending_queue") + 1;
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue", nQueue);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_operation", 2);
        SetLocalObject(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_target", oObject);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_event", nEvent);
        SetLocalString(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_script", sScript);
        bPermanent = (bPermanent != 0);
        bIgnorePermanency = (bIgnorePermanency != 0);
        SetLocalInt(GetModule(),    "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_flags", ((bPermanent << 1) | (bIgnorePermanency)));
        return;
    }

    string sArrayNameBase = EventTypeIdToName(nEvent),
           sArrayName;

    // Abort if the object given / event / script isn't valid
    if(!GetIsObjectValid(oObject) || sArrayNameBase == "" || sScript == "") return;

    // Go through one-shot array
    if(!bPermanent || bIgnorePermanency){
        sArrayName = sArrayNameBase;
        // First, check if there is an array to look through at all and that the script is in the array
        if(wrap_array_exists(oObject, sArrayName)/* &&
           GetLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName))*/
           ){
            int nMoveBackBy = 0;
            int i = 0;
            int nArraySize = wrap_array_get_size(oObject, sArrayName);
            // Loop through the array elements
            for(; i < nArraySize; i++){
                // See if we have an entry to remove
                if(wrap_array_get_string(oObject, sArrayName, i) == sScript){
                    nMoveBackBy++;
                }
                // Move the entries in the array back by an amount great enough to overwrite entries containing sScript
                else if(nMoveBackBy){
                    wrap_array_set_string(oObject, sArrayName, i - nMoveBackBy,
                                          wrap_array_get_string(oObject, sArrayName, i));
            }   }

            // Shrink the array by the number of entries removed, if any
            if(nMoveBackBy)
                wrap_array_shrink(oObject, sArrayName, wrap_array_get_size(oObject, sArrayName) - nMoveBackBy);

            // Remove the script presence marker
            DeleteLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName));
    }   }

    // Go through the permanent array
    if(bPermanent || bIgnorePermanency){
        sArrayName = sArrayNameBase + PERMANENCY_SUFFIX;
        // First, check if there is an array to look through at all and that the script is in the array
        if(wrap_array_exists(oObject, sArrayName)/* &&
           GetLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName))*/
           ){
            int nMoveBackBy = 0;
            int i = 0;
            int nArraySize = wrap_array_get_size(oObject, sArrayName);
            // Loop through the array elements
            for(; i < nArraySize; i++){
                // See if we have an entry to remove
                if(wrap_array_get_string(oObject, sArrayName, i) == sScript){
                    nMoveBackBy++;
                }
                // Move the entries in the array back by an amount great enough to overwrite entries containing sScript
                else if(nMoveBackBy){
                    wrap_array_set_string(oObject, sArrayName, i - nMoveBackBy,
                                          wrap_array_get_string(oObject, sArrayName, i));
            }   }

            // Shrink the array by the number of entries removed, if any
            if(nMoveBackBy)
                wrap_array_shrink(oObject, sArrayName, wrap_array_get_size(oObject, sArrayName) - nMoveBackBy);

            // Remove the script presence marker
            DeleteLocalInt(oObject, _GetMarkerLocalName(sScript, sArrayName));
    }   }
}


void ClearEventScriptList(object oObject, int nEvent, int bPermanent = FALSE, int bIgnorePermanency = FALSE){
    // If an eventhook is running, place the call into queue
    if(GetLocalInt(GetModule(), "prc_eventhook_running")){
        int nQueue = GetLocalInt(GetModule(), "prc_eventhook_pending_queue") + 1;
        SetLocalInt(GetModule(), "prc_eventhook_pending_queue", nQueue);
        SetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_operation", 3);
        SetLocalObject(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_target", oObject);
        SetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_event", nEvent);
        bPermanent = (bPermanent != 0);
        bIgnorePermanency = (bIgnorePermanency != 0);
        SetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(nQueue) + "_flags", ((bPermanent << 1) | (bIgnorePermanency)));
        return;
    }

    string sArrayNameBase = EventTypeIdToName(nEvent),
           sArrayName;

    // Abort if the object given / event isn't valid
    if(!GetIsObjectValid(oObject) || sArrayNameBase == "") return;

    // Go through one-shot array
    if(!bPermanent || bIgnorePermanency){
        sArrayName = sArrayNameBase;
        // First, check if there is an array present
        if(wrap_array_exists(oObject, sArrayName)){
            // Remove all markers
            int i = 0;
            for(; i <= wrap_array_get_size(oObject, sArrayName); i++){
                DeleteLocalInt(oObject, _GetMarkerLocalName(wrap_array_get_string(oObject, sArrayName, i), sArrayName));
            }
            // Shrink the array to 0
            wrap_array_shrink(oObject, sArrayName, 0);
    }   }

    // Go through the permanent array
    if(bPermanent || bIgnorePermanency){
        sArrayName = sArrayNameBase + PERMANENCY_SUFFIX;
        // First, check if there is an array present
        if(wrap_array_exists(oObject, sArrayName)){
            // Remove all markers
            int i = 0;
            for(; i <= wrap_array_get_size(oObject, sArrayName); i++){
                DeleteLocalInt(oObject, _GetMarkerLocalName(wrap_array_get_string(oObject, sArrayName, i), sArrayName));
            }
            // Shrink the array to 0
            wrap_array_shrink(oObject, sArrayName, 0);
    }   }
}


string GetFirstEventScript(object oObject, int nEvent, int bPermanent){
    string sArrayName = EventTypeIdToName(nEvent);

    // Abort if the object given / event isn't valid
    if(!GetIsObjectValid(oObject) || sArrayName == "") return "";

    sArrayName += bPermanent ? PERMANENCY_SUFFIX : "";

    // DelayCommand is somewhat expensive, so do this bit only if there is actually an array to iterate over
    if(wrap_array_exists(oObject, sArrayName)) {
        SetLocalInt(oObject, sArrayName + "_index", 1);
        DelayCommand(0.0f, DeleteLocalInt(oObject, sArrayName + "_index"));
    }

    return wrap_array_get_string(oObject, sArrayName, 0);
}


string GetNextEventScript(object oObject, int nEvent, int bPermanent){
    string sArrayName = GetLocalInt(GetModule(), "prc_eventhook_running") ?
                         GetLocalString(GetModule(), "prc_eventhook_running_sArrayName") :
                         EventTypeIdToName(nEvent);

    // Abort if the object given / event isn't valid
    if(!GetIsObjectValid(oObject) || sArrayName == "") return "";

    sArrayName += bPermanent ? PERMANENCY_SUFFIX : "";

    int nIndex = GetLocalInt(oObject, sArrayName + "_index");
    if(nIndex)
        SetLocalInt(oObject, sArrayName + "_index", nIndex + 1);
    else{
        WriteTimestampedLogEntry("GetNextEventScript called without first calling GetFirstEventScript");
        return "";
    }

    return wrap_array_get_string(oObject, sArrayName, nIndex);
}


void ExecuteAllScriptsHookedToEvent(object oObject, int nEvent){
    // Mark that an eventhook is being run, so calls to modify the
    // scripts listed are delayd until the eventhook is done.
    SetLocalInt(GetModule(), "prc_eventhook_running", nEvent);
    SetLocalString(GetModule(), "prc_eventhook_running_sArrayName", EventTypeIdToName(nEvent));

    if(PRINT_EVENTHOOKS && DEBUG)
        DoDebug("Executing eventhook for event " + IntToString(nEvent) + "; object = " + DebugObject2Str(oObject) + ". Hooked scripts:");

    // Loop through the scripts to be fired only once
    string sScript = GetFirstEventScript(oObject, nEvent, FALSE);
    int bNeedClearing = FALSE;
    while(sScript != ""){
        bNeedClearing = TRUE;

        if(PRINT_EVENTHOOKS && DEBUG)
            DoDebug("\nOneshot: '" + sScript + "'");
        ExecuteScript(sScript, OBJECT_SELF);

        sScript = GetNextEventScript(oObject, nEvent, FALSE);
    }

    // Clear the one-shot script list
    if(bNeedClearing)
        ClearEventScriptList(oObject, nEvent, FALSE, FALSE);

    // Loop through the persistent scripts
    sScript = GetFirstEventScript(oObject, nEvent, TRUE);
    while(sScript != ""){
        if(PRINT_EVENTHOOKS && DEBUG)
            DoDebug("\nPermanent: '" + sScript + "'");
        ExecuteScript(sScript, OBJECT_SELF);

        sScript = GetNextEventScript(oObject, nEvent, TRUE);
    }

    // Remove the lock on modifying the script lists
    DeleteLocalInt(GetModule(), "prc_eventhook_running");
    DeleteLocalString(GetModule(), "prc_eventhook_running_sArrayName");

    // Run the delayed commands
    int nQueued = GetLocalInt(GetModule(), "prc_eventhook_pending_queue"),
    nOperation, nFlags, i;
    object oTarget;
    for(i = 1; i <= nQueued; i++){
        nOperation = GetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_operation");
        oTarget = GetLocalObject(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_target");
        nEvent     = GetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_event");
        sScript = GetLocalString(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_script");
        nFlags     = GetLocalInt(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_flags");

        switch(nOperation){
            case 1:
                AddEventScript(oTarget, nEvent, sScript, nFlags >>> 1, nFlags & 1);
                break;
            case 2:
                RemoveEventScript(oTarget, nEvent, sScript, nFlags >>> 1, nFlags & 1);
                break;
            case 3:
                ClearEventScriptList(oTarget, nEvent, nFlags >>> 1, nFlags & 1);
                break;

            default:
                WriteTimestampedLogEntry("Invalid value in delayed eventhook manipulation operation queue");
        }

        DeleteLocalInt   (GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_operation");
        DeleteLocalObject(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_target");
        DeleteLocalInt   (GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_event");
        DeleteLocalString(GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_script");
        DeleteLocalInt   (GetModule(), "prc_eventhook_pending_queue_" + IntToString(i) + "_flags");
    }

    DeleteLocalInt(GetModule(), "prc_eventhook_pending_queue");

}


int GetRunningEvent(){
    return GetLocalInt(GetModule(), "prc_eventhook_running");
}


string EventTypeIdToName(int nEvent){
    /*
    switch(nEvent){
        // Module events
        case EVENT_ONACQUIREITEM:
            return NAME_ONACQUIREITEM;
        case EVENT_ONACTIVATEITEM:
            return NAME_ONACTIVATEITEM;
        case EVENT_ONCLIENTENTER:
            return NAME_ONCLIENTENTER;
        case EVENT_ONCLIENTLEAVE:
            return NAME_ONCLIENTLEAVE;
        case EVENT_ONCUTSCENEABORT:
            return NAME_ONCUTSCENEABORT;
        case EVENT_ONHEARTBEAT:
            return NAME_ONHEARTBEAT;
//        case EVENT_ONMODULELOAD:
//            return NAME_ONMODULELOAD;
        case EVENT_ONPLAYERDEATH:
            return NAME_ONPLAYERDEATH;
        case EVENT_ONPLAYERDYING:
            return NAME_ONPLAYERDYING;
        case EVENT_ONPLAYEREQUIPITEM:
            return NAME_ONPLAYEREQUIPITEM;
        case EVENT_ONPLAYERLEVELUP:
            return NAME_ONPLAYERLEVELUP;
        case EVENT_ONPLAYERREST_CANCELLED:
            return NAME_ONPLAYERREST_CANCELLED;
        case EVENT_ONPLAYERREST_STARTED:
            return NAME_ONPLAYERREST_STARTED;
        case EVENT_ONPLAYERREST_FINISHED:
            return NAME_ONPLAYERREST_FINISHED;
        case EVENT_ONPLAYERUNEQUIPITEM:
            return NAME_ONPLAYERUNEQUIPITEM;
        case EVENT_ONPLAYERRESPAWN:
            return NAME_ONPLAYERRESPAWN;
        case EVENT_ONUNAQUIREITEM:
            return NAME_ONUNAQUIREITEM;
        case EVENT_ONUSERDEFINED:
            return NAME_ONUSERDEFINED;
        case EVENT_ONPLAYERLEVELDOWN:
            return NAME_ONPLAYERLEVELDOWN;

        // NPC events
        case EVENT_NPC_ONBLOCKED:
            return NAME_NPC_ONBLOCKED;
        case EVENT_NPC_ONCOMBATROUNDEND:
            return NAME_NPC_ONCOMBATROUNDEND;
        case EVENT_NPC_ONCONVERSATION:
            return NAME_NPC_ONCONVERSATION;
        case EVENT_NPC_ONDAMAGED:
            return NAME_NPC_ONDAMAGED;
        case EVENT_NPC_ONDEATH:
            return NAME_NPC_ONDEATH;
        case EVENT_NPC_ONDISTURBED:
            return NAME_NPC_ONDISTURBED;
        case EVENT_NPC_ONHEARTBEAT:
            return NAME_NPC_ONHEARTBEAT;
        case EVENT_NPC_ONPERCEPTION:
            return NAME_NPC_ONPERCEPTION;
        case EVENT_NPC_ONPHYSICALATTACKED:
            return NAME_NPC_ONPHYSICALATTACKED;
        case EVENT_NPC_ONRESTED:
            return NAME_NPC_ONRESTED;
//        case EVENT_NPC_ONSPAWN:
//            return NAME_NPC_ONSPAWN;
        case EVENT_NPC_ONSPELLCASTAT:
            return NAME_NPC_ONSPELLCASTAT;

        // Other events
        case EVENT_ONHIT:
            return NAME_ONHIT;
        case EVENT_ONSPELLCAST:
            return NAME_ONSPELLCAST;
        case EVENT_ONPOWERMANIFEST:
            return NAME_ONPOWERMANIFEST;

        // Item events
        case EVENT_ITEM_ONACQUIREITEM:
            return NAME_ITEM_ONACQUIREITEM;
        case EVENT_ITEM_ONACTIVATEITEM:
            return NAME_ITEM_ONACTIVATEITEM;
        case EVENT_ITEM_ONPLAYEREQUIPITEM:
            return NAME_ITEM_ONPLAYEREQUIPITEM;
        case EVENT_ITEM_ONPLAYERUNEQUIPITEM:
            return NAME_ITEM_ONPLAYERUNEQUIPITEM;
        case EVENT_ITEM_ONUNAQUIREITEM:
            return NAME_ITEM_ONUNAQUIREITEM;
        case EVENT_ITEM_ONHIT:
            return NAME_ITEM_ONHIT;

        // Callbackhooks
        case CALLBACKHOOK_UNARMED:
            return NAME_CALLBACKHOOK_UNARMED;

        default:
            WriteTimestampedLogEntry("Unknown event id passed to EventTypeIdToName: " + IntToString(nEvent) + "\nAdding a name constant for it recommended.");
            return "prc_event_array_" + IntToString(nEvent);
    }
    */

    return "prc_event_array_" + IntToString(nEvent);

    //return ""; // Never going to reach this, but the compiler doesn't realize that :P
}

string _GetMarkerLocalName(string sScript, string sArrayName)
{
    return "prc_eventhook_script:" + sScript + ";array:" + sArrayName;
}


int wrap_array_create(object store, string name){
    if(GetIsPC(store))
        return persistant_array_create(store, name);
    else
        return array_create(store, name);
}
int wrap_array_set_string(object store, string name, int i, string entry){
    if(GetIsPC(store))
        return persistant_array_set_string(store, name, i, entry);
    else
        return array_set_string(store, name, i, entry);
}
string wrap_array_get_string(object store, string name, int i){
    if(GetIsPC(store))
        return persistant_array_get_string(store, name, i);
    else
        return array_get_string(store, name, i);
}
int wrap_array_shrink(object store, string name, int size_new){
    if(GetIsPC(store))
        return persistant_array_shrink(store, name, size_new);
    else
        return array_shrink(store, name, size_new);
}
int wrap_array_get_size(object store, string name){
    if(GetIsPC(store))
        return persistant_array_get_size(store, name);
    else
        return array_get_size(store, name);
}
int wrap_array_exists(object store, string name){
    if(GetIsPC(store))
        return persistant_array_exists(store, name);
    else
        return array_exists(store, name);
}
