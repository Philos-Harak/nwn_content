/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_pcloaded
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a character enters an area for the first time since
 loggin in.
 Used to check a character loading.
 On server resets all characters and new characters load into limbo.
 All other on load characters run this script as an execute script.
 This runs all the code related to the character see 0e_cliententer for player.

Character status
 -1 Banned and cannot play this character - will be sent to limbo.
 1 A normal character.
 2 A priviledged character.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_area"
#include "0i_journal"
#include "0i_quest"
#include "0i_henchmen"
#include "nwnx_rename"
#include "nwnx_player"
#include "0i_win_layout_pc"
#include "0i_webhook"
void SendCharacterRacialXPMessage(object oPC)
{
    int nRacialXP, nRacialXPNeeded, nRacialType;
    string sName = GetName(oPC);
    // Get any racial xp left and display.
    nRacialXP = FloatToInt(GetLocalFloat(oPC, "0_RacialXP"));
    if(nRacialXP > 0)
    {
        float fECL = GetEffectiveCharacterLevel(oPC);
        if(fECL == 1.0) nRacialXPNeeded = 1000; 
        else if(fECL == 2.0) nRacialXPNeeded = 3000;
        else if(fECL == 3.0) nRacialXPNeeded = 6000;
        // We only save what racial xp is left to get.
        // Get the actual Racial xp by looking at what we have left and subtracting what is needed.
        nRacialXP = nRacialXPNeeded - nRacialXP;
        // To get what we need subtract xp needed by actual racial xp.
        nRacialXPNeeded = nRacialXPNeeded - nRacialXP;
        SendMessages(sName + "'s racial xp: " + IntToString(nRacialXP) + ".", COLOR_GRAY, oPC);
        SendMessages(sName + "'s racial xp needed: " + IntToString(nRacialXPNeeded) + ".", COLOR_GRAY, oPC);
    }
}

void main()
{
    int nPlayerStatus, nCharacterStatus, nEye, nNumOfCharacters, nData, nRespawn;
    int bUseEComponent, bNew = FALSE;
    string sAppearanceArray, sWaypoint = "", sData, sName, sOptions, sOptionSelected;
    object oWaypoint;
    location lLocation;
    object oPC = GetEnteringObject();
    // If there is no entering object then this is being run through
    // executescript via 0e_areaenter.
    if(oPC == OBJECT_INVALID) oPC = OBJECT_SELF;
    // Double check that this is a PC if not then exit.
    if(!GetIsPC(oPC)) return;
    // Check to see if a Player has setup notifications.
    object oPlayer = GetFirstPC();
    while(oPlayer != OBJECT_INVALID)
    {
        string sOptions = GetServerDatabaseString(oPlayer, DM_TABLE, "options");
        if(GetStringArray(sOptions, 0) == "1") NWNX_Player_PlaySound(oPlayer, "as_sw_x2gong3");
        oPlayer = GetNextPC();
    }
    // ************************* DM Character code. ****************************
    if (GetIsDungeonMaster(oPC))
    {
        SetLocalInt(oPC, "0_Language", GetServerDatabaseInt(oPC, DM_TABLE, "languageusing"));
        SendPlayerLogToDiscord(oPC);
    }
    // ************************** PC Character code. ***************************
    else
    {
        // ****************** New player character Code ************************
        // If they have no data then setup the Players character database.
        CheckObjectDataTableAndCreateTable(oPC, CHARACTER_TABLE);
        if(GetObjectDatabaseString(oPC, CHARACTER_TABLE, "name") == "")
        {
            // Make sure the players databases are created for a new character.
            CheckObjectDataTableAndCreateTable(oPC, PIN_TABLE);
            CheckObjectDataTableAndCreateTable(oPC, QUEST_TABLE);
            CheckObjectDataAndInitialize(oPC, CHARACTER_TABLE);
            SendMessages(GetPCPlayerName (oPC) + " is making a new character named " + GetName(oPC) + ".", COLOR_GREEN, OBJECT_INVALID, FALSE, TRUE);
            IncreaseServerDatabaseCounter(oPC, PLAYER_TABLE, "characters");
            SendPlayerLogToDiscord(oPC, TEXT_CHAR_CREATE);
            RemoveItems(oPC, TRUE);
            object oPlayerBook = CreateItemOnObject("players_book", oPC);
            SetItemCursedFlag(oPlayerBook, TRUE);
            nPlayerStatus = GetServerDatabaseInt(oPC, PLAYER_TABLE, "status");
            // Check new character for xp and if they are not an administrator.
            if(GetXP(oPC) > 0 && nPlayerStatus < 4)
            {
                DelayCommand(10.0, SendMessages("NOTICE: " + GetPCPlayerName (oPC) + " is logging in " + GetName (oPC) + ", a new character with experience. They have been banned and moved to Limbo.", COLOR_WHITE, OBJECT_INVALID, TRUE, TRUE));
                DelayCommand(10.0, SendMessages("This is a new character with experience. You have been sent to Limbo, please contact a DM or Administrator.", COLOR_RED, oPC));
                // Set the character to banned.
                SetObjectDatabaseInt(oPC, CHARACTER_TABLE, "status", -1);
                // Jump them to the limbo waypoint incase they are not already in limbo.
                oWaypoint = GetWaypointByTag(WP_LIMBO);
                AssignCommand(oPC, JumpToObject(oWaypoint));
                return;
            }
            else
            {
                SetNewCharacter(oPC);
                CheckForClaws(oPC, 1);
                CheckForFeatsToAdd(oPC);
                // Check for weapon feats to be applied.
                object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
                // Remove any effects.
                CheckEquipWeaponFeats(oPC, oItem, FALSE);
                // Reapply any effects.
                CheckEquipWeaponFeats(oPC, oItem);
                sWaypoint = WP_START_LOCATION;
            }
        }
        // ******************* Older player character code. ********************
        else
        {
            FixCharacterDatabase(oPC);
            // Check to see if this character is banned.
            nCharacterStatus = GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "status");
            if(nCharacterStatus == -1)
            {
                DelayCommand(10.0, SendMessages("NOTICE: " + GetPCPlayerName (oPC) + " logging in with " + GetName(oPC) + " who has been banned! Moving them to Limbo.", COLOR_RED, OBJECT_INVALID, TRUE, TRUE));
                DelayCommand(10.0, SendMessages("This character has been banned. Please contact a DM or Administrator about this issue.", COLOR_RED, oPC));
                // Jump them to the limbo waypoint incase they are not already in limbo.
                oWaypoint = GetWaypointByTag(WP_LIMBO);
                AssignCommand(oPC, JumpToObject(oWaypoint));
                return;
            }
            SendMessages(GetPCPlayerName(oPC) + " is logging in with " + GetName(oPC) + ".", COLOR_GREEN, OBJECT_INVALID, FALSE, TRUE);
            CheckSpellEffectsForRemoval(oPC);
            RestoreHitpointsFromDatabase(oPC);
            // Make sure Override damage is restored to defaults.
            NWNX_Creature_OverrideDamageLevel(oPC, -1);
            AdjustSummonUses(oPC, 2);
            // Check for any NPC's they may have and summon them.
            CheckForQuestNPCsOnLoad(oPC);
            CheckForHenchmanOnLoad(oPC);
            // Make sure characters are not Immortal, incase they log out while in a Deathless Rage.
            SetImmortal(oPC, FALSE);
            SendPlayerLogToDiscord(oPC);
        }
        // ***************** All player characters code. ***********************
        // Temp location, move back to new character section when moving to live.
        sOptions = GetObjectDatabaseString(oPC, CHARACTER_TABLE, "appearance");
        SetRestingOption(oPC, GetStringArray(sOptions, 3));
        SetCreatureAuras(oPC);
        SetCharacterEffectsToSkin(oPC);
        SetCharacterEffects(oPC);
        SendCharacterRacialXPMessage(oPC);
        CheckForWings(oPC);
        // Has the server been reset?
        //Debug ("0e_pcloaded", "216", "Reset: " + IntToString (GetLocalInt (oPC, "0_Server_Not_Reset")));
        if(!GetLocalInt(oPC, "0_Server_Not_Reset"))
        {
            SetLocalInt(oPC, "0_Server_Not_Reset", TRUE);
            LoadCharacterPins(oPC);
            // Load variables from the database.
            SetLocalInt(oPC, "0_Luck", GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "luck"));
            SetLocalFloat(oPC, "0_RacialXP", GetObjectDatabaseFloat(oPC, CHARACTER_TABLE, "racialxp"));
            SetLocalInt(oPC, "0_Language", GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "languageusing"));
            // Set spell component pouch if they have one.
            object oPlayersHandBook = GetCreatureHasItem (oPC, "players_book");
            if(GetIsObjectValid(oPlayersHandBook))
            {
                bUseEComponent = GetLocalInt(oPlayersHandBook, "0_Use_Enhancing_Component");
                SetLocalInt(oPC, "0_Use_Enhancing_Component", bUseEComponent);
            }
            SetupPCJournal(oPC);
        }
        // Check to see if we should adjust the characters name for Hardcore color (Gold).
        if(GetObjectDatabaseInt(oPC, CHARACTER_TABLE, "respawns") == 0)
        {
            sName = GetName(oPC);
            sName = AddColorToText(sName, COLOR_GOLD);
            NWNX_Rename_SetPCNameOverride(oPC, sName, "", "", NWNX_RENAME_PLAYERNAME_OVERRIDE);
        }
        // Check to see if the character has glowing eyes.
        sAppearanceArray = GetObjectDatabaseString(oPC, CHARACTER_TABLE, "appearance");
        nEye = StringToInt(GetStringArray(sAppearanceArray, 0));
        if(nEye > 0) ApplyGlowingEyes(nEye, oPC);
        // Make all PC's happy with Commoners, Merchants, Defenders.
        SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oPC);
        SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPC);
        SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oPC);
        int bPassword = GetServerDatabaseInt(GetModule(), SERVER_TABLE, "password");
        if (bPassword) DelayCommand(1.0, PopUpPasswordGUIPanel(oPC));
        else SetLocalInt(oPC, "0_Password", TRUE);
        // Disable GUI panels.
        //SetGuiPanelDisabled(oPC, GUI_PANEL_PLAYERLIST, TRUE);
    }
    // *********************************************************************
    // *********************** All characters code. ************************
    // *********************************************************************
    // Tell the server they are now loaded.
    SetLocalInt(oPC, "0_Character_Loaded", TRUE);
    if(!GetLocalInt(oPC, "0_NEWS_SEEN")) PopUpNewsPanel(oPC);
    SendServerMessage(oPC);
    MovePlayer(oPC, sWaypoint);
}
