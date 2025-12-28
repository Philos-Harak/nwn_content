/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pcrespawn
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the character respawns.
 * Updates repsawn counts.
 * Checks to see if an area is saved for respawning and if not defaults to Essembra area.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_henchmen"
#include "0i_webhook"
void main ()
{
    string sRespawn;
    object oPC = OBJECT_SELF;//GetLastRespawnButtonPresser();
    object oRespawnWaypoint, oArea = GetArea(oPC);
    // Set respawn count, new location, and hitpoints.
    // Set player/character respawn counters.
    IncreaseServerDatabaseCounter(oPC, PLAYER_TABLE, "respawns");
    IncreaseObjectDatabaseCounter(oPC, CHARACTER_TABLE, "respawns");
    // Make sure player name is reset to normal to denote they are not Hardcore anymore.
    NWNX_Rename_ClearPCNameOverride(oPC, OBJECT_INVALID, TRUE);
    NWNX_Rename_SetPCNameOverride(oPC, GetName (oPC), "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
    // Remove effects.
    RemoveCreatureEffects(oPC);
    // Resurrect the player so we can move them.
    effect eResurrect = EffectResurrection();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eResurrect, oPC);
    // Remove fringe effects.
    // Clear effect variables.
    DeleteLocalInt(oPC, "0_SPELL_DC_MOD");
    DeleteLocalInt(oPC, "0_SPELL_DMG_MOD");
    DeleteLocalInt(oPC, "0_SPELL_CASTER_LEVEL");
    // Reset the players factions.
    SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oPC);
    SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oPC);
    SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPC);
    // Add permanent effects back to the character.
    SetCharacterEffects(oPC);
    // Get the characters default respawn location.
    // It is the 0 array in the Teleport database.
    sRespawn = JsonGetString(JsonArrayGet (GetObjectDatabaseJson (oPC, CHARACTER_TABLE, "teleport"), 0));
    oRespawnWaypoint = GetObjectByTag(sRespawn);
    if(!GetIsObjectValid(oRespawnWaypoint))
    {
         SetModuleError("WAYPOINT", "0e_pcrespawn", "46", "Respawn waypoint (" + sRespawn + ") can't be found!");
         oRespawnWaypoint = GetObjectByTag(WP_DEFAULT_RESPAWN);
    }
    AssignCommand(oPC, JumpToObject(oRespawnWaypoint));
    // Lets save the player regardless of time laps.
    SaveCharacterData(oPC, TRUE);
    // We save the killer in the 0e_pcdying script so bleeding doesn't mess it up.
    object oKiller = GetLocalObject(oPC, "0_KILLER");
    SendPlayerRespawnToDiscord(oPC, oKiller);
}

