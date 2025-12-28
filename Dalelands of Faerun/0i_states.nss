/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_states
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts that handle states and conditions.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
#include "inc_sqlite_time"

// Bitwise constants for negative conditions we might want to try to cure
const int COND_CURSE     = 0x00000001;
const int COND_POISON    = 0x00000002;
const int COND_DISEASE   = 0x00000004;
const int COND_ABILITY   = 0x00000008;
const int COND_DRAINED   = 0x00000010;
const int COND_BLINDDEAF = 0x00000020;

// Special combat behavior modes used with GetCombatMode ().
const string sCombatModeVarname = "COMBAT_MODE";
const int COMBAT_MODE_RANGED            = 0x00000001;
const int COMBAT_MODE_DEFENSIVE         = 0x00000002;
const int COMBAT_MODE_NO_COMBAT         = 0x00000004;
const int COMBAT_MODE_AMBUSHER          = 0x00000008;
const int COMBAT_MODE_ARCANE_SONG       = 0x00000010;
const int COMBAT_MODE_DIVINE_SONG       = 0x00000020;
const int COMBAT_MODE_ROGUE_SONG        = 0x00000040;
const int COMBAT_MODE_WARRIOR_SONG      = 0x00000080;
const int COMBAT_MODE_CURSE_SONG        = 0x00000100;


// Special behavior before combat... not using will look at later.
const int BEHAVIOR_SPECIAL       = 0x00000001; // Special behavior
const int BEHAVIOR_CARNIVORE     = 0x00000002; // Will always attack!
const int BEHAVIOR_OMNIVORE      = 0x00000004; // Will only attack if approached.
const int BEHAVIOR_HERBIVORE     = 0x00000008; // Will never attack.  Will always flee.

// Spawn-in conditions for associates and monsters.
const string sSpawnInModeVarname = "SPAWN_IN_MODES";
const int SPAWN_IN_SPECIAL_CONVERSATION        = 0x00000001;
const int SPAWN_IN_SHOUT_ATTACK_MY_TARGET      = 0x00000002;
const int SPAWN_IN_STEALTH                     = 0x00000004;
const int SPAWN_IN_SEARCH                      = 0x00000008;
const int SPAWN_IN_SET_WARNINGS                = 0x00000010;
const int SPAWN_IN_TELEPORT_RETURN             = 0x00000080; //Failed
const int SPAWN_IN_TELEPORT_LEAVE              = 0x00000100;
const int SPAWN_IN_SPECIAL_COMBAT_CONVERSATION = 0x00000200;
const int SPAWN_IN_AMBIENT_ANIMATIONS          = 0x00000400;
const int SPAWN_IN_IMMOBILE_AMBIENT_ANIMATIONS = 0x00000800;
const int SPAWN_IN_AMBIENT_ANIMATIONS_AVIAN    = 0x00001000;
const int SPAWN_IN_APPEAR_SPAWN_IN_ANIMATION   = 0x00002000;

// Associate modes that are set by the player or set a status, used with GetAssociateMode ().
const string sAssociateModeVarname = "ASSOCIATE_MODES";
const int MODE_DISTANCE_2_METERS =   0x00000001; // Stays within 2 meters of master.
const int MODE_DISTANCE_4_METERS =   0x00000002; // Stays within 2 meters of master.
const int MODE_DISTANCE_6_METERS =   0x00000004; // Stays within 2 meters of master.
const int MODE_HEAL_AT_75 =          0x00000008; // Heals master when at 75% hitpoints
const int MODE_HEAL_AT_50 =          0x00000010; // Heals master when at 50% hitpoints
const int MODE_HEAL_AT_25 =          0x00000020; // Heals master when at 25% hitpoints
const int MODE_BUFF_MASTER =         0x00000040; // Buffs master before other allies.
const int MODE_AGGRESSIVE_SEARCH =   0x00000080; // Sets associate to continuous search mode.
const int MODE_AGGRESSIVE_STEALTH =  0x00000100; // Sets associate to continuous stealth mode (Not using).
const int MODE_OPEN_LOCKS =          0x00000200; // Will pick locks, or bash them.
const int MODE_DISARM_TRAPS =        0x00000400; // Will disarm traps.
const int MODE_SCOUT_AHEAD =         0x00000800; // Will move ahead of master and scout.
const int MODE_DEFEND_MASTER =       0x00001000; // Will attack enemies near master.
const int MODE_STAND_GROUND =        0x00002000; // Will stay in one place until new command.
const int MODE_STOP_RANGED =         0x00004000; // Will not use ranged weapons.
const int MODE_FOLLOW =              0x00008000; // Keeps associate following master.
const int MODE_PICKUP_ITEMS =        0x00010000; // Will pickup all items for master.
const int MODE_PICKUP_GEMS_ITEMS =   0x00020000; // Will pickup gems, art, and magic items for master.
const int MODE_PICKUP_MAGIC_ITEMS =  0x00040000; // Will pickup only magic items for master.
const int MODE_NO_INVISIBILITY =     0x00080000; // Will not cast invisibilty effect spells.
const int MODE_STOP_CASTING =        0x00100000; // Will not use spells.
const int MODE_DEFENSIVE_CASTING =   0x00200000; // Will only cast defensive spells.
const int MODE_OFFENSIVE_CASTING =   0x00400000; // Will only cast offensive spells.
const int MODE_STOP_DISPEL =         0x00800000; // Will not cast dispel type spells.
const int MODE_DO_NOT_SPEAK =        0x01000000; // Tells the henchmen to be silent and not talk.
const int MODE_ATK_DISTANCE_10 =     0x02000000; // Will target armored opponents first (high AC).
const int MODE_ATK_DISTANCE_20 =     0x04000000; // Will target non armored opponents first (low AC).
const int MODE_CHECK_ATTACK =        0x08000000; // Will only engage in combats they think they can win.
const int MODE_IS_BUSY =             0x10000000; // Removed but still defined as it works in old code.
const int MODE_REST_BUFFING =        0x20000000; // Will buff themselves and you after resting.
const int MODE_DYING =               0x40000000; // Sets the associate to dying.
const int MODE_DEAD =                0x80000000; // Sets the associate to dead.

// These constants in ChooseTactics routine Remember previous rounds choices.
const string sAllyDiedLastRoundVarname = "ALLY_DIED_LAST_ROUND";
const string sCombatMemoryVarname = "COMBAT_MEMORY";
const int COMBAT_MEMORY_OFFENSE_MELEE  = 1; // We are in melee.
const int COMBAT_MEMORY_DEFENSE_OTHERS = 2; // We used defense others last round.
const int COMBAT_MEMORY_DEFENSE_SELF   = 3; // We used defense self last round.
const int COMBAT_MEMORY_OFFENSE_SPELL  = 4; // We used an offensive spell last round.

// These constants are used in combat to keep track of a creatures last action.
const string sLastActionVarname = "0_LAST_ACTION";
const int LAST_ACTION_NONE = -1;
const int LAST_ACTION_MELEE_ATK = -2;
const int LAST_ACTION_RANGED_ATK = -3;
const int LAST_ACTION_USED_FEAT = -4;
const int LAST_ACTION_USED_ITEM = -5;

// Used in combat to keep track of last rounds actions.
// One use is to make sure we don't use the same spell on consecutive rounds.
// 0+ is the spell that was cast other actions use LAST_ACTION_* constants.
void SetLastAction (int nSpell = LAST_ACTION_NONE);

// Used in combat to make sure we don't use the same spell on consecutive rounds.
int CompareLastAction (int nAction);

// Determine whether the specified COMBAT_MODE_* is set on the target
int GetCombatMode (int nMode, object oTarget = OBJECT_SELF);

// Set one of the COMBAT_MODE_* values on the target
void SetCombatMode (int nMode, int bValid = TRUE, object oTarget = OBJECT_SELF);

// Determine if this henchman is currently dying.
int GetIsHenchmanDying(object oHench=OBJECT_SELF);

// Sets the specified spawn-in condition on the caller as directed.
void SetSpawnInCondition(int nCondition, int bValid = TRUE);

// Returns TRUE if the specified condition has been set on the
// caller, otherwise FALSE.
int GetSpawnInCondition(int nCondition);

// Sets the listening patterns and local variables needed
// for the given spawn-in condition on the caller.
void SetSpawnInLocals(int nCondition);

// Sets the correct listen checks on a monster.
void SetMonsterListeningPatterns ();

// Sets the correct listen checks on an associate.
void SetAssociateListeningPatterns (object oCreature);

// Set one of the MODE_* values on the Associate.
void SetAssociateMode (int nMode, int bValid = TRUE, object oAssoc = OBJECT_SELF);

// Determine whether the specified MODE_* is set on the Associate.
int GetAssociateMode (int nMode, object oAssoc = OBJECT_SELF);

// Returns the henchmen to a commandable state of grace
void ResetHenchmenState ();

// Sets the associate's current location as their
// start location.
void SetAssociateStartLocation ();

// Gets the associate's current start location.
location GetAssociateStartLocation ();

// Set behavior used by AI
void SetBehavior(int nBehavior, int nValue);

// Get behavior used by AI
int GetBehavior(int nBehavior);

// Add the specified condition flag to the behavior state of the caller
void SetBehaviorState(int nCondition, int bValid = TRUE);

// Returns TRUE if the specified behavior flag is set on the caller
int GetBehaviorState(int nCondition);

// True if the creature is an elemental, undead, or golem i.e. non-living.
int IsNonliving (int nRacialType);

// Sets the time that this creatures combat round started.
// Using action based combat rounds has an unfortunate side effect:
// Once you attack in melee you will continue to attack in melee do to hardcoded
// logic. This will "PUSH" your end of round back until it decides to stop attacking!
// We avoid this by setting the time and if we check for combat and 6 seconds has
// passed then we assume the combat round is over and go to the next one.
void SetCombatRound (object oCreature = OBJECT_SELF);

// Clears any Combat Starts by clearing the state.
void EndCombatRound (object oCreature = OBJECT_SELF);

// Checks to see if 6 seconds has passed since Combat Start has been called.
// returns TRUE if not, and FALSE if it has - then clears the state.
int IsInCombatRound (object oCreature = OBJECT_SELF);

// This checks various actions to see if oCreature is busy.
// Busy is in combat round, busy mode, Actions: attacking, casting spell,
// counterspelling, disabling trap, item casting spell, opening lock, resting, setting trap.
int GetIsBusy (object oCreature = OBJECT_SELF);

// Used in combat to keep track of last rounds actions.
// One use is to make sure we don't use the same spell on consecutive rounds.
// 0+ is the spell that was cast other actions use LAST_ACTION_* constants.
void SetLastAction (int nAction = LAST_ACTION_NONE)
{
    SetLocalInt (OBJECT_SELF, sLastActionVarname, nAction);
}

int CompareLastAction (int nAction)
{
    if (nAction == GetLocalInt (OBJECT_SELF, sLastActionVarname)) return TRUE;
    return FALSE;
}

// Determine whether the specified X0_COMBAT_FLAG_* is set on the target
int GetCombatMode (int nMode, object oTarget = OBJECT_SELF)
{
    return (GetLocalInt(oTarget, sCombatModeVarname) & nMode);
}

// Set one of the COMBAT_MODE_* values on the target to give special combat tactics.
void SetCombatMode (int nMode, int bValid = TRUE, object oTarget = OBJECT_SELF)
{
    int nCurrentMode = GetLocalInt (oTarget, sCombatModeVarname);
    if (bValid) SetLocalInt (oTarget, sCombatModeVarname, nCurrentMode | nMode);
    else SetLocalInt(oTarget, sCombatModeVarname, nCurrentMode & ~nMode);
}

// Determine if this henchman is currently dying.
int GetIsHenchmanDying(object oHench=OBJECT_SELF)
{
    int bHenchmanDying = GetAssociateMode(MODE_DYING, oHench);
    if (bHenchmanDying == TRUE)
    {
        //brentDebug("henchman is dying");
        return TRUE;
    }
    else
    {
        //brentDebug("Henchman is not dying");
        return FALSE;
    }
}

// Sets the specified spawn-in condition on the caller as directed.
void SetSpawnInCondition (int nCondition, int bValid = TRUE)
{
    int nSpawnInConditions = GetLocalInt (OBJECT_SELF, sSpawnInModeVarname);
    if (bValid)
    {
        // Add the given spawn-in condition
        nSpawnInConditions = nSpawnInConditions | nCondition;
        SetLocalInt (OBJECT_SELF, sSpawnInModeVarname, nSpawnInConditions);
    }
    else if (!bValid)
    {
        // Remove the given spawn-in condition
        nSpawnInConditions = nSpawnInConditions & ~nCondition;
        SetLocalInt (OBJECT_SELF, sSpawnInModeVarname, nSpawnInConditions);
    }
}

// Returns TRUE if the specified condition has been set on the caller, otherwise FALSE.
int GetSpawnInCondition (int nCondition)
{
    int nPlot = GetLocalInt (OBJECT_SELF, sSpawnInModeVarname);
    if(nPlot & nCondition) return TRUE;
    return FALSE;
}

// Sets the correct listen checks on a monster.
void SetMonsterListeningPatterns ()
{
    SetListening (OBJECT_SELF, TRUE);
    SetListenPattern (OBJECT_SELF, "I_SEE_AN_ENEMY", 1);
    SetListenPattern (OBJECT_SELF, "ATTACKED_BY_WEAPON", 2);
    SetListenPattern (OBJECT_SELF, "ATTACKED_BY_SPELL", 3);
    SetListenPattern (OBJECT_SELF, "NW_I_AM_DEAD", 5);
}

// Sets the correct listen checks on an associate.
void SetAssociateListeningPatterns (object oCreature)
{
    SetListening (oCreature, TRUE);
    SetListenPattern (oCreature, "inventory",101);
    SetListenPattern (oCreature, "pick", 102);
    SetListenPattern (oCreature, "trap", 103);
}

void SetAssociateMode (int nMode, int bValid = TRUE, object oAssoc = OBJECT_SELF)
{
    int nAssocModes = GetLocalInt (oAssoc, sAssociateModeVarname);
    int nAMTest = nAssocModes;
    if (bValid) nAssocModes = nAssocModes | nMode;
    else nAssocModes = nAssocModes & ~nMode;
    SetLocalInt (oAssoc, sAssociateModeVarname, nAssocModes);
}

int GetAssociateMode (int nMode, object oAssoc = OBJECT_SELF)
{
    int nAssocModes = GetLocalInt (oAssoc, sAssociateModeVarname);
    if (nAssocModes & nMode) return TRUE;
    return FALSE;
}

// Sets the henchmen to commandable, deletes locals having to do with doors and clears actions.
void ResetHenchmenState ()
{
    SetCommandable (TRUE);
    DeleteLocalObject (OBJECT_SELF, "BASHING_DOOR");
    ClearAllActions ();
}

int GetBehavior (int nBehavior)
{
    return GetLocalInt (OBJECT_SELF, "NW_L_BEHAVIOR" + IntToString (nBehavior));
}

void SetBehavior(int nBehavior, int nValue)
{
    SetLocalInt (OBJECT_SELF, "NW_L_BEHAVIOR" + IntToString (nBehavior), nValue);
}

// Add the specified condition flag to the behavior state of the caller
void SetBehaviorState (int nCondition, int bValid = TRUE)
{
    int nPlot = GetLocalInt (OBJECT_SELF, "NW_BEHAVIOR_MASTER");
    if (bValid)
    {
        nPlot = nPlot | nCondition;
        SetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER", nPlot);
    }
    else if (!bValid)
    {
        nPlot = nPlot & ~nCondition;
        SetLocalInt (OBJECT_SELF, "NW_BEHAVIOR_MASTER", nPlot);
    }
}

// Returns TRUE if the specified behavior flag is set on the caller
int GetBehaviorState (int nCondition)
{
    int nPlot = GetLocalInt(OBJECT_SELF, "NW_BEHAVIOR_MASTER");
    if(nPlot & nCondition) return TRUE;
    return FALSE;
}

// True if the creature is an elemental, undead, or golem i.e. non-living.
int IsNonliving (int nRacialType)
{
    int nMatch = FALSE;

    switch (nRacialType)
    {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_UNDEAD: nMatch = TRUE; break;
   }
   return nMatch;

}

// Sets the time that this creatures combat round started.
void SetCombatRound (object oCreature = OBJECT_SELF)
{
    SetLocalInt (oCreature, "0_COMBAT_ROUND_START", SQLite_GetTimeStamp ());
    //Debug ("0i_states_cond", "325", " ===============> " + GetName (oCreature) + " ROUND START:" + IntToString (SQLite_GetTimeStamp ()) + " <===============");
}

// Clears any Combat Starts by clearing the state.
void EndCombatRound (object oCreature = OBJECT_SELF)
{
    //Debug ("0i_states_cond", "331", " ===============> " + GetName (oCreature) + " ROUND END:" + IntToString (SQLite_GetTimeStamp ()) + " <===============");
    DeleteLocalInt (oCreature, "0_COMBAT_ROUND_START");
}

// Checks to see if 6 seconds has passed since Combat Start has been called.
// returns TRUE if not, and FALSE if it has - then clears the state.
int IsInCombatRound (object oCreature = OBJECT_SELF)
{
    int nCombatRoundStart = GetLocalInt (oCreature, "0_COMBAT_ROUND_START");
    if (nCombatRoundStart)
    {
        // New combat round calculator. If 6 seconds has passed then we are on a new round!
        int nSQLTime = SQLite_GetTimeStamp ();
        int nCombatRoundTime = nSQLTime - nCombatRoundStart;
        //Debug ("0i_states_cond", "345", " SQLite_GetTimeStamp: " + IntToString (nSQLTime) +
        //       " nCombatRoundStart: " + IntToString (nCombatRoundStart));
        if (nCombatRoundTime >= 6) EndCombatRound (oCreature);
        else return TRUE;
    }
    return FALSE;
}


// This checks various actions to see if oCreature is busy.
// Busy is in combat round, busy mode, Actions: attacking, casting spell,
// counterspelling, disabling trap, item casting spell, opening lock, resting, setting trap.
int GetIsBusy (object oCreature = OBJECT_SELF)
{
    //if (GetAssociateMode (MODE_IN_COMBAT, oCreature)) return TRUE;
    if (IsInCombatRound (oCreature)) return TRUE;
    int nAction = GetCurrentAction (oCreature);
    //Debug ("0i_states_cond", "362", "GetIsBusy: Action: " + IntToString (nAction));
    switch (nAction)
    {
        // We don't check for this cause the game will auto set attacking an object
        // and will have the creature get stuck attacking without checking
        // for new situations.
        //case ACTION_ATTACKOBJECT :
        case ACTION_CASTSPELL :
        case ACTION_COUNTERSPELL :
        case ACTION_DISABLETRAP :
        case ACTION_ITEMCASTSPELL :
        case ACTION_OPENLOCK :
        case ACTION_REST :
        case ACTION_SETTRAP :
            return TRUE;
    }
    return FALSE;
}
