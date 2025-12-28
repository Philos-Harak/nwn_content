/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pclvlup
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when the character levels up.
 Note: this runs after they have leveled the character.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_database"
#include "0i_creature"
#include "0i_master"
#include "0i_henchmen"
#include "0i_webhook"
void main()
{
    int nHighestLevel, nCharacterLevel, nGainedFeat, nCheckforFeat, nCounter;
    string sAllGainedFeats;
    object oItem, oPC = GetPCLevellingUp();
    // Get Players highest level achieved and save to database if its the new high.
    // Get the highest level achieved so far.
    nHighestLevel = GetServerDatabaseInt(oPC, PLAYER_TABLE, "highestlevel");
    // Get Characters level.
    nCharacterLevel = GetCharacterLevels(oPC);
    // Compare and save character level if it is higher than the players highest.
    if(nCharacterLevel > nHighestLevel) SetServerDatabaseInt(oPC, PLAYER_TABLE, "highestlevel", nCharacterLevel);
    SetCreatureAuras(oPC);
    SetCharacterEffectsToSkin(oPC);
    SetCharacterEffects(oPC);
    CheckForWings(oPC);
    CheckForClaws(oPC, nCharacterLevel);
    CheckForFeatsToAdd(oPC);
    // Check for weapon feats to be applied.
    oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    // Remove any effects.
    CheckEquipWeaponFeats(oPC, oItem, FALSE);
    // Reapply any effects.
    CheckEquipWeaponFeats(oPC, oItem);
    // Remove all Class effects so we can re-apply.
    AdjustFeatUses(oPC);
    if(GetIsCharacter(oPC)) SendPlayerLogToDiscord(oPC, TEXT_LEVEL_UP);
    LevelUpCurrentHenchman(oPC);
}

