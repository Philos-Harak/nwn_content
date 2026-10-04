/*//////////////////////////////////////////////////////////////////////////////
 Script: 0i_npc
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    NPC AI scripts.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "0i_creature"
// Sets scripts, and abilities for oNPC.
// bFirstSetup - TRUE it is the first time setup for oNPC, FALSE for reloads of oNPC.
void SetUpNPC(object oNPC, int bFirstSetup = TRUE);
// Sets scripts and abilities for villains.
void SetUpVillain(object oVillain);

void SetUpNPC(object oNPC, int bFirstSetup = TRUE)
{
    if (bFirstSetup)
    {
        if(NWNX_Object_GetDialogResref(oNPC) == "") NWNX_Object_SetDialogResref (oNPC, "co_quest");
        SetEventScript (oNPC, EVENT_SCRIPT_CREATURE_ON_DEATH, "0e_npc_ondeath_7");
        // Set NPC's Associates.
        int nAssociateType;
        if(GetHasFeat(FEAT_SUMMON_FAMILIAR, oNPC))
        {
            if(GetHasFeat(1261/*Improved Animal Companion*/, oNPC)) nAssociateType = Random (9)+ 9;
            else nAssociateType = Random(9);
            NWNX_Creature_SetFamiliarName(oNPC, "Familiar");
            NWNX_Creature_SetFamiliarCreatureType(oNPC, nAssociateType);
        }
        if (GetHasFeat (FEAT_ANIMAL_COMPANION, oNPC))
        {
            if (GetHasFeat (1261/*Improved Animal Companion*/, oNPC)) nAssociateType += 9;
            else nAssociateType = Random(9);
            NWNX_Creature_SetAnimalCompanionName(oNPC, "Companion");
            NWNX_Creature_SetAnimalCompanionCreatureType(oNPC, nAssociateType);
        }
        CheckForFeatsToAdd(oNPC);
    }
    // Temporary fix while we are transfering from our AI to Philos PEPS AI.
    if(GetEventScript(oNPC, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "0e_npc_hrtbeat_1")
    {
        SetEventScript (oNPC, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_ch_ac1");
    }
    // Set the NPC to the NPC type.
    SetLocalInt(oNPC, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_NPC);
    // Set to not disappear when dead, not be resurrectable, and selectable.
    SetIsDestroyable (FALSE, FALSE, TRUE, oNPC);
    // On each load we must adjust the spotting distance back to 35 for Spot.
    NWNX_Creature_SetCheckDistance(oNPC, 35.0, 20.0);
    // AI setting used to define how far away from the player they can go.
    DelayCommand(12.0, SetLocalFloat(oNPC, "AI_ASSOC_PERCEPTION_DISTANCE", 35.0));
    // Give class/race specific abilities.
    CheckForClaws(oNPC, GetHitDice (oNPC));
    CheckForWings(oNPC);
    SetCharacterEffectsToSkin(oNPC);
    SetCharacterEffects(oNPC);
    SetCreatureAuras(oNPC);
}
void SetUpVillain(object oVillain)
{
    // Set the villain to use monster scrips.
    SetEventScript(oVillain, EVENT_SCRIPT_CREATURE_ON_DEATH, "nw_c2_default7");
    SetEventScript(oVillain, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT, "nw_c2_default1");
    // Set to not disappear when dead, resurrectable, and selectable.
    SetIsDestroyable (FALSE, TRUE, TRUE, oVillain);
    // These are all done in the spawn script.
    // Give class/race specific abilities.
    //CheckForClaws(oVillain, GetHitDice (oVillain));
    //CheckForWings(oVillain);
    //SetCharacterEffectsToSkin(oVillain);
    //SetCharacterEffects(oVillain);
    //CheckForFeatsToAdd(oVillain);
    //SetCreatureAuras(oVillain);
}

// Creates a base set of traits for an NPC.
// Returns them in text format to be added to descriptions.
// See traits.2da for entries.
string GetNPCTraits ()
{
    int nTimes = d3();
    int nRoll, nDie = StringToInt (Get2DAString ("traits", "Positive_Count", 0));
    string sTraits = "[Positive traits:";
    while (nTimes-- > 0)
    {
        nRoll = Random (nDie) + 1;
        sTraits += " " + Get2DAString ("traits", "Positive_Traits", nRoll);
        if (nTimes > 0) sTraits += ",";
    }
    sTraits += " \n Negative traits:";
    nTimes = d3();
    nDie = StringToInt (Get2DAString ("traits", "Negative_Count", 0));
    while (nTimes-- > 0)
    {
        nRoll = Random (nDie) + 1;
        sTraits += " " + Get2DAString ("traits", "Negative_Traits", nRoll);
        if (nTimes > 0) sTraits += ",";
    }
    return sTraits + "] ";
}

// Setup a json to create an npc.
json SetJsonNPC (object oPlayer)
{
    json jNPC = JsonObject();
    jNPC = JsonObjectSet (jNPC, "name", JsonString ("Random"));
    jNPC = JsonObjectSet (jNPC, "resref", JsonString (" "));
    jNPC = JsonObjectSet (jNPC, "tag", JsonString (" "));
    jNPC = JsonObjectSet (jNPC, "portrait_resref", JsonString ("po_hu_m_99_"));
    jNPC = JsonObjectSet (jNPC, "portrait_id", JsonInt (129));
    jNPC = JsonObjectSet (jNPC, "deity", JsonString ("None"));
    jNPC = JsonObjectSet (jNPC, "gender", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "race", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "class1", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "level1", JsonInt (0));
    jNPC = JsonObjectSet (jNPC, "package1", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "class2", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "level2", JsonInt (0));
    jNPC = JsonObjectSet (jNPC, "package2", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "class3", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "level3", JsonInt (0));
    jNPC = JsonObjectSet (jNPC, "package3", JsonInt (-1));
    jNPC = JsonObjectSet (jNPC, "alignlc", JsonInt (0));
    jNPC = JsonObjectSet (jNPC, "alignge", JsonInt (0));
    jNPC = JsonObjectSet (jNPC, "faction", JsonInt (4));
    jNPC = JsonObjectSet (jNPC, "str", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "dex", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "con", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "int", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "wis", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "cha", JsonInt (2));
    jNPC = JsonObjectSet (jNPC, "description", JsonString ("Description"));
    SetLocalJson (oPlayer, "0_JNPC", jNPC);
    return jNPC;
}

json RanomizeJsonNPC (json jNPC)
{
    int nSwitch, nAnotherClass;
    // Check gender, 2 is random.
    int nGender = JsonGetInt (JsonObjectGet (jNPC, "gender"));
    if (nGender == 2)
    {
        nGender = Random (2);
        jNPC = JsonObjectSet (jNPC, "gender", JsonInt (nGender));
    }
    // Check race, -1 is random.
    int nRace = JsonGetInt (JsonObjectGet (jNPC, "race"));
    if (nRace == -1)
    {
        nSwitch = d100();
        if (nSwitch < 6) nRace = 36; // Dwarf Shield
        else if (nSwitch < 11) nRace = 37; // Dwarf Gold
        else if (nSwitch < 16) nRace = 39; // Elf Moon
        else if (nSwitch < 19) nRace = 40; // Elf Sun
        else if (nSwitch < 20) nRace = 41; // Elf Wood
        else if (nSwitch < 25) nRace = 44; // Gnome Rock
        else if (nSwitch < 26) nRace = 45; // Gnome Forest
        else if (nSwitch < 30) nRace = 48; // Halfling Lightfoot
        else if (nSwitch < 35) nRace = 49; // Halfling Strongheart
        else if (nSwitch < 36) nRace = 50; // Halfling Ghostwise
        else if (nSwitch < 37) nRace = 51; // Half elf Moon
        else if (nSwitch < 38) nRace = 52; // Half elf Sun
        else if (nSwitch < 39) nRace = 53; // Half elf Wood
        else if (nSwitch < 44) nRace = 56; // Half orc
        else if (nSwitch < 52) nRace = 30; // Human Damaran
        else if (nSwitch < 61) nRace = 31; // Human Iluskan
        else if (nSwitch < 69) nRace = 32; // Human Rashemi
        else if (nSwitch < 77) nRace = 33; // Human Mulan
        else if (nSwitch < 85) nRace = 34; // Human Tethyrian
        else if (nSwitch < 98) nRace = 35; // Human Chondathan
        else if (nSwitch < 99) // Rare races
        {
            nSwitch = d100();
            if (nSwitch < 15) nRace = 38; // Dwarf Duergar
            else if (nSwitch < 31) nRace = 46; // Gnome Svirfneblin
            else if (nSwitch < 47) nRace = 42; // Elf Drow
            else if (nSwitch < 48) nRace = 43; // Elf Star
            else if (nSwitch < 49) nRace = 55; // Half elf Star
            else if (nSwitch < 50) nRace = 54; // Half elf Drow
            else if (nSwitch < 66) nRace = 58; // Orc Mountain
            else if (nSwitch < 81) nRace = 59; // Orc Gray
            else if (nSwitch < 91) nRace = 57; // Kobold
            else nRace = 47; // Goblin
        }
        else // Outsiders
        {
            nSwitch = d100();
            if (nSwitch < 17) nRace = 60; // Aasimar
            else if (nSwitch < 34) nRace = 61; // Tiefling
            else if (nSwitch < 51) nRace = 62; // Air Genasi
            else if (nSwitch < 68) nRace = 63; // Earth Genasi
            else if (nSwitch < 85) nRace = 64; // Fire Genasi
            else nRace = 65; // Water Genasi
        }
        jNPC = JsonObjectSet (jNPC, "race", JsonInt (nRace));
        // Select a portrait based on sex and race.
        if (JsonGetInt (JsonObjectGet (jNPC, "portrait_id")) == 129)
        {
            int nPRace, nPGender, nID = Random (1317) + 1;
            int nGender = JsonGetInt (JsonObjectGet (jNPC, "gender"));
            int nRace = GetRaceType(OBJECT_INVALID, TRUE, JsonGetInt (JsonObjectGet (jNPC, "race")));
            string sPRace = Get2DAString ("portraits", "Race", nID);
            if (sPRace != "") nPRace = StringToInt (sPRace);
            else nPRace = -1;
            string sPGender = Get2DAString ("portraits", "Sex", nID);
            if (sPGender != "") nPGender = StringToInt (sPGender);
            else nPGender = -1;
            while ((nRace != nPRace && (nRace != 4 || (nPRace != 1 && nPRace != 6))) || nGender != nPGender)
            {
                nID = nID + 1;
                if (nID > 1317) nID = 1;
                if (nID < 1) nID = 1317;
                sPRace = Get2DAString ("portraits", "Race", nID);
                if (sPRace != "") nPRace = StringToInt (sPRace);
                else nPRace = -1;
                sPGender = Get2DAString ("portraits", "Sex", nID);
                if (sPGender != "") nPGender = StringToInt (sPGender);
                else nPGender = -1;
            }
            string sResRef = "po_" + Get2DAString("portraits", "BaseResRef", nID);
            jNPC = JsonObjectSet (jNPC, "portrait_id", JsonInt (nID));
        }
    }
    // Check name, blank or Random is random.
    string sName = JsonGetString (JsonObjectGet (jNPC, "name"));
    if (sName == "" || sName == "random" || sName == "Random")
    {
        sName = GetRandomName(nGender, nRace);
        jNPC = JsonObjectSet (jNPC, "name", JsonString (sName));
    }
    int nClass1 = JsonGetInt (JsonObjectGet (jNPC, "class1"));
    int nLevel1 = JsonGetInt (JsonObjectGet (jNPC, "level1"));
    int nClass2 = JsonGetInt (JsonObjectGet (jNPC, "class2"));
    int nLevel2 = JsonGetInt (JsonObjectGet (jNPC, "level2"));
    int nClass3 = JsonGetInt (JsonObjectGet (jNPC, "class3"));
    int nLevel3 = JsonGetInt (JsonObjectGet (jNPC, "level3"));
    // Check base class1, -1 is random.
    if (nClass1 == -1)
    {
        nSwitch = d100();
        if (nSwitch <= 5) nClass1 = 0; // Barbarian
        else if (nSwitch <= 10) nClass1 = 1; // Bard
        else if (nSwitch <= 20) nClass1 = 2; // Cleric
        else if (nSwitch <= 22) nClass1 = 3; // Druid
        else if (nSwitch <= 52) nClass1 = 4; // Fighter
        else if (nSwitch <= 54) nClass1 = 5; // Monk
        else if (nSwitch <= 56) nClass1 = 45; // Paladin
        else if (nSwitch <= 61) nClass1 = 46; // Ranger
        else if (nSwitch <= 81) nClass1 = 8; // Rogue
        else if (nSwitch <= 86) nClass1 = 9; // Sorcerer
        else if (nSwitch <= 96) nClass1 = 10; // Wizard
        else if (nSwitch <= 98) nClass1 = 43; // Swashbuckler
        else nClass1 = 47;// if (nSwitch <= 97) nClass1 = "47"; // Favored Soul
        //else nClass1 = "48"; // Warmage - not in yet.
        jNPC = JsonObjectSet (jNPC, "class1", JsonInt (nClass1));
    }
    // Check if package is set if not then randomize, right now packages are random.
    int nPackage1 = JsonGetInt (JsonObjectGet (jNPC, "package1"));
    if (nPackage1 == -1)
    {
        if (d100() > 50)
        {
            // Packages.2da has 5 alternate packages for each class set at 150+.
            nSwitch = (nClass1 * 5) + 66 + Random (5);
            if (Get2DAString ("packages", "Name", nSwitch) == "") nPackage1 = nClass1;
            else nPackage1 = nSwitch;
        }
        else nPackage1 = nClass1;
       jNPC = JsonObjectSet (jNPC, "package1", JsonInt (nPackage1));
    }
    // Check Level, 0 is randomize.
    if (nLevel1 == 0) nLevel1 = d20();
    // Check for another class.
    if (d100() < 26 && nLevel1 > 3 && nClass2 == -1)
    {
        nAnotherClass = nLevel1 / (d4 () + 1);
        nLevel1 = nLevel1 - nAnotherClass;
    }
    else
    {
        nClass2 = 255;
        nClass3 = 255;
    }
    jNPC = JsonObjectSet (jNPC, "level1", JsonInt (nLevel1));
    // Set the Class ability scores.
    int nStr, nDex, nCon, nWis, nInt, nCha;
    if (JsonGetInt (JsonObjectGet (jNPC, "str")) == 2)
    {
        nStr = StringToInt (Get2DAString ("classes", "Str", nClass1));
        nStr += StringToInt (Get2DAString ("racialtypes", "StrAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "str", JsonInt (nStr));
    }
    if (JsonGetInt (JsonObjectGet (jNPC, "dex")) == 2)
    {
        nDex = StringToInt (Get2DAString ("classes", "Dex", nClass1));
        nDex += StringToInt (Get2DAString ("racialtypes", "DexAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "dex", JsonInt (nDex));
    }
    if (JsonGetInt (JsonObjectGet (jNPC, "con")) == 2)
    {
        nCon = StringToInt (Get2DAString ("classes", "Con", nClass1));
        nCon += StringToInt (Get2DAString ("racialtypes", "ConAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "con", JsonInt (nCon));
    }
    if (JsonGetInt (JsonObjectGet (jNPC, "int")) == 2)
    {
        nInt = StringToInt (Get2DAString ("classes", "Int", nClass1));
        nInt += StringToInt (Get2DAString ("racialtypes", "IntAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "int", JsonInt (nInt));
    }
    if (JsonGetInt (JsonObjectGet (jNPC, "wis")) == 2)
    {
        nWis = StringToInt (Get2DAString ("classes", "Wis", nClass1));
        nWis += StringToInt (Get2DAString ("racialtypes", "WisAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "wis", JsonInt (nWis));
    }
    if (JsonGetInt (JsonObjectGet (jNPC, "cha")) == 2)
    {
        nCha = StringToInt (Get2DAString ("classes", "Cha", nClass1));
        nCha += StringToInt (Get2DAString ("racialtypes", "ChaAdjust", nRace));
        jNPC = JsonObjectSet (jNPC, "cha", JsonInt (nCha));
    }
    // Do they have a second class? -1 is random.
    if (nAnotherClass > 0 || nClass2 == -1)
    {
        nSwitch = d100();
        if (nSwitch <= 5) nClass2 = 0; // Barbarian
        else if (nSwitch <= 10) nClass2 = 1; // Bard
        else if (nSwitch <= 20) nClass2 = 2; // Cleric
        else if (nSwitch <= 22) nClass2 = 3; // Druid
        else if (nSwitch <= 52) nClass2 = 4; // Fighter
        else if (nSwitch <= 54) nClass2 = 5; // Monk
        else if (nSwitch <= 56) nClass2 = 45; // Paladin
        else if (nSwitch <= 61) nClass2 = 46; // Ranger
        else if (nSwitch <= 81) nClass2 = 8; // Rogue
        else if (nSwitch <= 86) nClass2 = 9; // Sorcerer
        else if (nSwitch <= 96) nClass2 = 10; // Wizard
        else if (nSwitch <= 98) nClass2 = 43; // Swashbuckler
        else nClass2 = 47;// if (nSwitch <= 97) nClass2 = "47"; // Favored Soul
        //else nClass2 = "48"; // Warmage - not in yet.
        while (nClass1 == nClass2) { nClass2 = d6() - 1; }
        // Check if package is set if not then randomize, right now packages are random.
        int nPackage2 = JsonGetInt (JsonObjectGet (jNPC, "package2"));
        if (nPackage2 == -1)
        {
            if (d100() > 50)
            {
                // Packages.2da has 5 alternate packages for each class set at 150+.
                nSwitch = (nClass2 * 5) + 66 + Random (5);
                if (Get2DAString ("packages", "Name", nSwitch) == "") nPackage2 = nClass2;
                else nPackage2 = nSwitch;
            }
            else nPackage2 = nClass2;
           jNPC = JsonObjectSet (jNPC, "package2", JsonInt (nPackage2));
        }
        // Check Level, 0 is randomize.
        if (nLevel2 == 0 && nAnotherClass == 0) nLevel2 = Random (20 - nLevel1) + 1;
        if (nAnotherClass > 0)
        {
            nLevel2 = nAnotherClass;
            nAnotherClass = 0;
        }
        // Check for another class.
        if (d100() < 26 && nLevel2 > 3 && nClass3 == -1)
        {
            nAnotherClass = nLevel2 / (d4 () + 1);
            nLevel2 = nLevel2 - nAnotherClass;
        }
        else nClass3 = 255;
        // Do they have a third class?
        if (nAnotherClass > 0 || nClass3 == -1)
        {
            nSwitch = d100();
            if (nSwitch <= 5) nClass3 = 0; // Barbarian
            else if (nSwitch <= 10) nClass3 = 1; // Bard
            else if (nSwitch <= 20) nClass3 = 2; // Cleric
            else if (nSwitch <= 22) nClass3 = 3; // Druid
            else if (nSwitch <= 52) nClass3 = 4; // Fighter
            else if (nSwitch <= 54) nClass3 = 5; // Monk
            else if (nSwitch <= 56) nClass3 = 45; // Paladin
            else if (nSwitch <= 61) nClass3 = 46; // Ranger
            else if (nSwitch <= 81) nClass3 = 8; // Rogue
            else if (nSwitch <= 86) nClass3 = 9; // Sorcerer
            else if (nSwitch <= 96) nClass3 = 10; // Wizard
            else if (nSwitch <= 98) nClass3 = 43; // Swashbuckler
            else nClass3 = 47;// if (nSwitch <= 97) sClass3 = "47"; // Favored Soul
            //else sClass3 = "48"; // Warmage - not in yet.
            while (nClass1 == nClass3 || nClass2 == nClass3) { nClass3 = d6() - 1; }
            // Check if package is set if not then randomize, right now packages are random.
            int nPackage3 = JsonGetInt (JsonObjectGet (jNPC, "package3"));
            if (nPackage3 == -1)
            {
                if (d100() > 50)
                {
                    // Packages.2da has 5 alternate packages for each class set at 150+.
                    nSwitch = (nClass3 * 5) + 66 + Random (5);
                    if (Get2DAString ("packages", "Name", nSwitch) == "") nPackage3 = nClass3;
                    else nPackage3 = nSwitch;
                }
                else nPackage3 = nClass3;
                jNPC = JsonObjectSet (jNPC, "package3", JsonInt (nPackage3));
            }
            // Check Level, 0 is randomize.
            if (nLevel3 == 0 && nAnotherClass == 0) nLevel2 = Random (20 - nLevel1 - nLevel2) + 1;
            if (nAnotherClass > 0) nLevel3 = nAnotherClass;
            jNPC = JsonObjectSet (jNPC, "level3", JsonInt (nLevel3));
        }
        jNPC = JsonObjectSet (jNPC, "class3", JsonInt (nClass3));
    }
    jNPC = JsonObjectSet (jNPC, "class2", JsonInt (nClass2));
    jNPC = JsonObjectSet (jNPC, "level2", JsonInt (nLevel2));
    // Check Alignment vs each class.
    int nAlignlc, nAlignge, nClass, nPosition = 1;
    while (nPosition < 4)
    {
        nClass = JsonGetInt (JsonObjectGet (jNPC, "class" + IntToString (nPosition)));
        // Check Alignment law/chaos, random is 0.
        nAlignlc = JsonGetInt (JsonObjectGet (jNPC, "alignlc"));
        if (nAlignlc == 0)
        {
            // Adjust alignment for class restrictions law/chaos.
            if (nClass == CLASS_TYPE_BARD || nClass1 == CLASS_TYPE_BARBARIAN)
            {
                nAlignlc = Random (2) + 2;
            }
            if (nClass == CLASS_TYPE_MONK) nAlignlc = 1;
            else nAlignlc = d3();
        }
        // Check Alignment good/evil, random is 0.
        nAlignge = JsonGetInt (JsonObjectGet (jNPC, "alignge"));
        if (nAlignge == 0)
        {
            // Adjust alignment for class restrictions good/evil.
            if (nClass == 45 /*Paladin*/) nAlignge = 1;
            else
            {
                nSwitch = d6();
                if (nSwitch < 3) nAlignge = 1;
                else if (nSwitch < 5) nAlignge = 2;
                else nAlignge = 3;
            }
        }
        if (nClass == CLASS_TYPE_DRUID)
        {
            if (nAlignlc != ALIGNMENT_NEUTRAL && nAlignge != ALIGNMENT_NEUTRAL)
            {
                nSwitch = Random (2);
                if (nSwitch == 0) nAlignlc = 2;
                else nAlignge = 2;
            }
        }
        nPosition ++;
    }
    jNPC = JsonObjectSet (jNPC, "alignlc", JsonInt (nAlignlc));
    jNPC = JsonObjectSet (jNPC, "alignge", JsonInt (nAlignge));
    string sText = JsonGetString (JsonObjectGet (jNPC, "description"));
    if (sText == "Description" || sText == "") sText = GetNPCTraits ();
    jNPC = JsonObjectSet (jNPC, "description", JsonString (sText));
    return jNPC;
}

void CreateJsonNPC (object oPlayer)
{
    string sText;
    json jNPC = GetLocalJson (oPlayer, "0_JNPC");
    json jTempNPC = RanomizeJsonNPC (jNPC);
    //Debug ("0i_npc", "464", "jNPC: " + JsonDump (jNPC, 1));
    // Get gender.
    int nGender = JsonGetInt (JsonObjectGet (jTempNPC, "gender"));
    if (nGender) sText = "f_";
    else sText = "m_";
    // Get race.
    int nRace = JsonGetInt (JsonObjectGet (jTempNPC, "race"));
    string sRace = IntToString (nRace);
    sText = sText + sRace;
    // Create NPC.
    location lLocation = GetLocalLocation (oPlayer, DM_TARGET_LOCATION);
    vector vPosition = GetPositionFromLocation (lLocation);
    object oArea = GetAreaFromLocation (lLocation);
    lLocation = Location (oArea, vPosition, GetFacing (oPlayer));
    object oCreature = CreateObject (OBJECT_TYPE_CREATURE, sText, lLocation);
    if (!GetIsObjectValid (oCreature))
    {
        SetModuleError ("RESREF", "0i_npc", "729", "Invalid Creature ResRef (" +  sText + ") Generating a male, human (Chondathan) instead.");
        // Generate a generic NPC (Male, Human (Chondathan) on failure.
        oCreature = CreateObject (OBJECT_TYPE_CREATURE, "m_35", lLocation);
    }
    // Set the faction.
    int nFaction = JsonGetInt (JsonObjectGet (jTempNPC, "faction"));
    if (nFaction < 4) ChangeToStandardFaction (oCreature, nFaction);
    // Set faction values.
    SetLocalInt (oCreature, "0_PermanentFaction", nFaction);
    SetLocalInt (oCreature, "0_CurrentFaction", nFaction);
    // Set Alignment.
    int nAlignlc = JsonGetInt (JsonObjectGet (jTempNPC, "alignlc"));
    if (nAlignlc == 1) nAlignlc = 85;
    else if (nAlignlc == 2) nAlignlc = 50;
    else if (nAlignlc == 3) nAlignlc = 15;
    NWNX_Creature_SetAlignmentLawChaos (oCreature, nAlignlc);
    int nAlignge = JsonGetInt (JsonObjectGet (jTempNPC, "alignge"));
    if (nAlignge == 1) nAlignge = 85;
    else if (nAlignge == 2) nAlignge = 50;
    else if (nAlignge == 3) nAlignge = 15;
    NWNX_Creature_SetAlignmentGoodEvil (oCreature, nAlignge);
    // Get classes.
    int nClass = JsonGetInt (JsonObjectGet (jTempNPC, "class1"));
    NWNX_Creature_SetClassByPosition (oCreature, 0, nClass);
    NWNX_Creature_SetLevelByPosition (oCreature, 0, 0);
    // Get package.
    int nPackage = JsonGetInt (JsonObjectGet (jTempNPC, "package1"));
    // Set ability scores.
    int nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "str"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_STRENGTH, nAbility);
    nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "dex"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_DEXTERITY, nAbility);
    nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "con"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_CONSTITUTION, nAbility);
    nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "int"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_INTELLIGENCE, nAbility);
    nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "wis"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_WISDOM, nAbility);
    nAbility = JsonGetInt (JsonObjectGet (jTempNPC, "cha"));
    NWNX_Creature_SetRawAbilityScore (oCreature, ABILITY_CHARISMA, nAbility);
    // Level up NPC.
    int nLevel = JsonGetInt (JsonObjectGet (jTempNPC, "level1"));
    LevelUpCreature (oCreature, nClass, nLevel, TRUE, nPackage);
    // Check for 2nd class.
    nClass = JsonGetInt (JsonObjectGet (jTempNPC, "class2"));
    //Debug ("0i_npc", "895", "nClass: " + IntToString (nClass));
    if (nClass != 255 && nClass != -1)
    {
        nLevel = JsonGetInt (JsonObjectGet (jTempNPC, "level2"));
        nPackage = JsonGetInt (JsonObjectGet (jTempNPC, "package2"));
        //Debug ("0i_npc", "900", "nLevel: " + IntToString (nLevel) +
        //       " nPackage: " + IntToString (nPackage));
        LevelUpCreature (oCreature, nClass, nLevel, TRUE, nPackage);
    }
    // Check for 3rd class.
    nClass = JsonGetInt (JsonObjectGet (jTempNPC, "class3"));
    if (nClass != 255 && nClass != -1)
    {
        nLevel = JsonGetInt (JsonObjectGet (jTempNPC, "level3"));
        nPackage = JsonGetInt (JsonObjectGet (jTempNPC, "package3"));
        LevelUpCreature (oCreature, nClass, nLevel, TRUE, nPackage);
    }
    // Check for Comanion or Familiar
    sText = Get2DAString ("packages", "Associate", nPackage);
    if (sText != "")
    {
        if (nClass == CLASS_TYPE_DRUID || nClass == 46 /*CLASS_TYPE_RANGER*/)
        {
            SetLocalString (oCreature, "0_COMPANION", sText);
        }
        else if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER)
        {
            SetLocalString (oCreature, "0_FAMILIAR", sText);
        }
    }
    // Set portrait.
    int nID = JsonGetInt (JsonObjectGet (jTempNPC, "portrait_id"));
    SetPortraitId (oCreature, nID);
    // Mark the NPC as generated.
    SetLocalInt (oCreature, "0_Generated_NPC", TRUE);
    SetName (oCreature, JsonGetString (JsonObjectGet (jTempNPC, "name")));
    // Set creatures new Tag. First 5 is first 5 of first name, Last 5 is last 5 of last name.
    // With Random number from 0 - 999. Example "philo_harak_999".
    string sName = GetName(oCreature);
    string sTag = GetStringLeft(sName, 5) + "_" +
                  GetStringRight(sName, 5) + "_" + IntToString(Random(1000));
    SetTag(oCreature, GetStringLowerCase(sTag));
    SetDescription (oCreature, JsonGetString (JsonObjectGet (jTempNPC, "description")));
    // Give magical equipment to the NPC.
    nPackage = JsonGetInt (JsonObjectGet (jTempNPC, "package1"));
    DelayCommand (0.5f, GiveMagicalEquipment (oCreature, GetCharacterLevels (oCreature), TRUE, nPackage));
    // Equip items.
    DelayCommand (1.0f, EquipItems (oCreature, TRUE, TRUE));
    // Force rest so they will cast spells.
    ForceRest (oCreature);
}
