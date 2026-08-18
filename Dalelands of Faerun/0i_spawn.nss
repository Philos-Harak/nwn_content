/*////////////////////////////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_spawn
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with spawning objects.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "nw_inc_gff"

// Makes a waypoint stop spawning creatures for one minute.
void ClearWaypointSpawning (object oWaypoint);

// Checks a door or placeable to see if it needs to be locked.
// oObject to be locked.
// nLevel is the level of the lock.
void CheckForLock (object oObject, int nLevel);

// Checks a door or placeable to see if it needs to be Trapped.
// oObject to be trapped.
// nLevel is the level of the trap.
void CheckForTrap (object oObject, int nLevel);

// Cycles through all objects in the area spawning based on information point waypoints.
// oArea is the area to check from.
// oPC used in rolls.
// nLevel is the level of the area to check.
// bNoDifficulty defines if the area is hostile to the players.
// sType is a prefix to select trigger or special spawn waypoints.
// sNewTag is to change a placeables tag.
void CheckObjects(object oArea, object oPC, int nLevel, int bNoDifficulty, string sType = "", string sNewTag = "");

// Used to Populate area to build effect for an area.
// oPoint is an object in the area to help find the waypoints.
// sType is the type of waypoint to be used. Defaults are Area, Trigger, Placeable.
void SpawnEffects (object oPC, string sType = "");

// Used to continue an effect on a level while a player is in it.
void SpawnEffectAgain (object oWaypoint);

// oObject is the object to lock.
void LockObject (object oObject, int iLevel);

// oObject is the object to trap.
// nLevel is the level of the trap (1-20).
// nTrapType is the type of trap (1 - 19).
void TrapObject (object oObject, int nLevel, int  nTrapType);

// Creates a group of placeables at lLocation.
// sGroup is the name of the group to make.
// lLocation is the location center of the group.
// sQuestTag will allow a quest to place a special tag onto a container.
void CreateGroupPlaceable(string sGroup, location lLocation, string sQuestTag = "");

// Randomizes a location within the radius of the given location.
location RandomizeLocation  (location lLocation, int nRadius);

// Makes a waypoint stop spawning creatures for one minute.
void ClearWaypointSpawning (object oWaypoint)
{
    int nChance = GetLocalInt (oWaypoint, "0_ChanceDay");
    if (nChance > 0)
    {
        SetLocalInt (oWaypoint, "0_ChanceDay", 0);
        DelayCommand (60.0f, SetLocalInt (oWaypoint, "0_ChanceDay", nChance));
    }
    nChance = GetLocalInt (oWaypoint, "0_ChanceNight");
    if (nChance > 0)
    {
        SetLocalInt (oWaypoint, "0_ChanceNight", 0);
        DelayCommand (60.0f, SetLocalInt (oWaypoint, "0_ChanceNight", nChance));
    }
}

// Checks a door or placeable to see if it needs to be locked.
void CheckForLock (object oObject, int nLevel)
{
   if (GetLockLockable (oObject))
   {
       // Get the objects lock information.
       int nLockChance = GetLocalInt (oObject, "0_LockChance");
       // Limit the levels we use to the minimum area level.
       if (nLevel < MIN_AREA_LEVEL || nLevel > MAX_AREA_LEVEL) nLevel = MIN_AREA_LEVEL;
       // A 0 lock chance means roll for a lock chance based on the area level.
       if (nLockChance == 0) nLockChance = BASE_CHANCE_OF_LOCK + nLevel / LOCK_CHANCE_LVL_DIVISOR;
       // Roll for chance to be locked.
       if (nLockChance >= d100()) LockObject (oObject, nLevel);
       else SetLocked (oObject, FALSE);
   }
   else SetLocked (oObject, FALSE);
}

// Checks a door, trigger or placeable to see if it needs to be Trapped.
void CheckForTrap (object oObject, int nLevel)
{
    // Check the trap type.
    int nTrapType = GetLocalInt (oObject, "0_TrapType");
    if (nTrapType == 0) nTrapType = GetTrapBaseType (oObject);
    // 0 is no trap.
    if (nTrapType == 0)
    {
        SetTrapActive (oObject, FALSE);
        SetTrapDetectable (oObject, FALSE);
    }
    else
    {
        // Get the level of the trap if different from the area.
        int nTrapLevel = GetLocalInt (oObject, "0_Trap_Level");
        if (nTrapLevel > 0) nLevel = nTrapLevel;
        // Limit the levels we use to the minimum area level.
        if (nLevel < MIN_AREA_LEVEL) nLevel = MIN_AREA_LEVEL;
        else if (nLevel > MAX_AREA_LEVEL) nLevel > MAX_AREA_LEVEL;
        // A 0 trap chance means roll for a trap chance based on the area level.
        int nTrapChance = GetLocalInt (oObject, "0_TrapChance");
        if (nTrapChance == 0) nTrapChance = BASE_CHANCE_OF_TRAP + nLevel / TRAP_CHANCE_LVL_DIVISOR;
        // Lets see if its trapped or not.
        if (nTrapChance >= d100()) TrapObject (oObject, nLevel, nTrapType);
        else
        {
            SetTrapActive (oObject, FALSE);
            SetTrapDetectable (oObject, FALSE);
        }
   }
}

void CheckforSummonsEffect (object oWaypoint, location lLocation, object oObject)
{
   // Check to see if we are suppose to fire an effect first.
   int nEffect = GetLocalInt(oWaypoint, "0_Effect");
   if(nEffect != 0)
   {
        effect eVisualEffect = EffectVisualEffect(nEffect);
        Debug("0i_spawn", "133", "Effect: " + IntToString(nEffect) + " Effect_Type: " +
              IntToString(GetLocalInt(oWaypoint, "0_Effect_Type")) + " oObject: " + GetName(oObject));
        if(GetLocalInt(oWaypoint, "0_Effect_Type") == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eVisualEffect, oObject);
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisualEffect, lLocation);
        }
   }
}

void CreateCreature (object oWaypoint, object oPC, int nLevel)
{
   int iRow, iCount, iChampionChance, iNumber, iAnimation, iAppear;
   string sResRef, sEncounter, sName;
   object oCreature, oWPEncounter, oArea, oPlayerBook;
   location lLocation;
   // Get the area.
   oArea = GetArea (oWaypoint);
   // Lets find out if there is a specific.
   sResRef = GetLocalString (oWaypoint, "0_Resref");
   // Get the location of the Waypoint.
   lLocation = GetLocation (oWaypoint);
   iAppear = GetLocalInt (oWaypoint, "0_Appear");
   // Check to see if it defines the number of creatures to spawn.
   iNumber = GetLocalInt (oWaypoint, "0_Number");
   // If there is no Resref then generate one from the encounter list.
   if (sResRef == "")
   {
        // Get the area's encounter waypoint used for all encounters in area.
        oWPEncounter = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        // Get the 2da encounter to use.
        sEncounter = GetLocalString (oWPEncounter, "0_Encounter_2da");
        if (sEncounter != "off")
        {
            // Check to see if we are in a no difficulty area.
            if (GetLocalInt (oWPEncounter, "0_No_Difficulty"))
            {
                // Get the number of entries in the 2da (Its at the top of the 2da).
                // We are in a city so lets use all the entries for spawning.
                iRow = StringToInt (Get2DAString (sEncounter, "Number", 0));
                iRow = Random (iRow) + 1;
            }
            else
            {
                // Make iRow the level & Check to see if the waypoint is adjusting the CR.
                nLevel += GetLocalInt (oWaypoint, "0_CR_Increase");
                if(nLevel < 1) nLevel = 1;
                else if(nLevel > 40) nLevel = 40;
                // Calculate row in the 2da (each level gets 5 entries thus ((ilevel - 1) * 5) + Random (5) + 1)
                iRow = ((nLevel - 1) * 5) + Random (5) + 1;
                //Debug ("0i_spawn", "175", "iRow: " + IntToString (iRow) + " nLevel: " + IntToString (nLevel));
            }
            // Get the 2da encounter to use.
            sEncounter = GetLocalString (oWPEncounter, "0_Encounter_2da");
            // Get the resref of the creature to spawn.
            sResRef = Get2DAString (sEncounter, "ResRef", iRow);
            if (iNumber == 0)
            {
                // Get the number of creatures to spawn from the 2da file.
                iNumber = StringToInt (Get2DAString (sEncounter, "Number", iRow));
                if (iNumber == 0) iNumber = SPAWN_DEFAULT;
            }
            else
            {
                oPlayerBook = GetCreatureHasItem (oPC, "players_book");
                // Randomize the number of creatures after lvl 3 and more than 3 are to spawn.
                // (avg 4 on a base number of 4).
                if (nLevel > 3 && iNumber > 3) iNumber = Random (iNumber) + 2;
                else iNumber = Random (iNumber) + 1;
                // Check for the mark of malar - increase encounters by 1!
                if (GetLocalInt (oPlayerBook, "0_MALAR_MARK")) iNumber ++;
            }
            // Decide if we spread them out or not.
            if (GetIsAreaAboveGround (oArea) && !GetIsAreaInterior (oArea))
            {
                // Spawn the standard number of creatures for the encounter.
                for (iCount = iNumber; iCount > 0; iCount --)
                {
                    oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, RandomizeLocation (lLocation, 10), iAppear);
                    // If we have an error find out what type of spawn and report.
                    if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_spawn", "207", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (iRow) + ") has an invalid ResRef (" +  sResRef + ")");
                    else DelayCommand (0.1, SetupCreature (oCreature, oWaypoint, oPC));
                }
            }
            else
            {
                for (iCount = iNumber; iCount > 0; iCount --)
                {
                    oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, lLocation, iAppear);
                    // If we have an error find out what type of spawn and report.
                    if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_spawn", "217", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (iRow) + ") has an invalid ResRef (" +  sResRef + ")");
                    else DelayCommand (0.1, SetupCreature (oCreature, oWaypoint, oPC));
                }
            }
            // Do we need to add additional creatures?
            // Now roll for extra creature.
            if (GetLocalInt (oWaypoint, "0_Extra_Creature") || EXTRA_CREATURE_CHANCE >= d100())
            {
                // Get the creatures ResRef.
                sResRef = Get2DAString (sEncounter, "Extra_Creature", iRow);
                oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, RandomizeLocation (lLocation, 10), iAppear);
                // If we have an error find out what type of spawn and report.
                if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_spawn", "203", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (iRow) + ") has an invalid Champion ResRef (" +  sResRef + ")");
                // Set the PC to the creature for treasure spawns.
                else DelayCommand (0.1, SetupCreature (oCreature, oWaypoint, oPC));
            }
        }
   }
   // Generate the creature from a resef.
   else
   {
       if (iNumber == 0) iNumber = 1;
       for (iCount = iNumber; iCount > 0; iCount --)
       {
           oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, lLocation, iAppear);
           // If we have an error find out what type of spawn and report.
           if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_spawn", "241", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (iRow) + ") has an invalid ResRef (" +  sResRef + ")");
           else DelayCommand (0.1, SetupCreature (oCreature, oWaypoint, oPC));
       }
   }
   // Check for summons effects.
   CheckforSummonsEffect(oWaypoint, lLocation, oCreature);
}

void CreateVillain (object oWaypoint, object oPC, int nLevel, int bRandom = FALSE)
{
    // Get the area.
    object oArea = GetArea (oWaypoint);
    // Get the location of the Waypoint.
    location lLocation = GetLocation (oWaypoint);
    // Get the area's encounter waypoint used for all encounters in area.
    object oWPEncounter = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    // Get area difficulty level to get the 2da row then add 3 for a boss.
    int nRow;
    // Check for CR increase.
    nLevel = nLevel + GetLocalInt (oWaypoint, "0_CR_Increase") + 2;
    if(nLevel < 1) nLevel = 1;
    else if(nLevel > 40) nLevel = 40;
    // Lets find out if there is a specific creature.
    string sEncounter, sResRef = GetLocalString (oWaypoint, "0_Resref");
    // If there is no Resref then generate one from the encounter list.
    if (sResRef == "")
    {
        // Get the area's encounter waypoint used for all encounters in area.
        oWPEncounter = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        // Get the 2da encounter to use.
        sEncounter = GetLocalString (oWPEncounter, "0_Encounter_2da");
        if (sEncounter != "off")
        {
            // Calculate row in the 2da (each level gets 5 entries thus ((ilevel - 1) * 5) + Random (5) + 1)
            nRow = ((nLevel - 1) * 5) + Random (5) + 1;
            // Get the resref of the creature to spawn.
            sResRef = Get2DAString (sEncounter, "ResRef", nRow);
        }
    }
    int bAppear = GetLocalInt (oWaypoint, "0_Appear");
    // Spawn one boss for the encounter.
    object oCreature = CreateObject (OBJECT_TYPE_CREATURE, sResRef, lLocation, bAppear);
    // If we have an error find out what type of spawn and report.
    if (!GetIsObjectValid (oCreature)) SetModuleError ("RESREF", "0i_spawn", "256", "Encounter2da (" + sEncounter + ") 2da Row:(" + IntToString (nRow) + ") has an invalid ResRef (" +  sResRef + ")");
    // All villains cannot be dispelled.
    SetLocalInt (oCreature, "0_IMMUNE_TO_DISPEL", TRUE);
    SetLocalInt (oCreature, "0_VILLAIN", TRUE);
    // Check to see if we need to change the creatures name.
    string sName = GetLocalString (oWaypoint, "0_Name");
    // No name then randomize one!
    int nAlign = GetAlignmentGoodEvil(oCreature);
    if (sName == "") sName = GetRandomName(0, 0, nAlign, FloatToInt(GetChallengeRating(oCreature)), GetName(oCreature));
    // Color name based on creature CR.
    //sName = ColorVillainName(oCreature, sName);
    // Set the name.
    SetName(oCreature, sName);
    GiveVillianSpecialPower (oCreature);
    // Set all bosses to use battlecries.
    SetLocalInt (oCreature, "0_Battlecry", TRUE);
    if (bRandom || GetLocalInt(oWaypoint, "0_Power"))
    {
        // Slightly increase the size of the boss.
        SetObjectVisualTransform (oCreature, OBJECT_VISUAL_TRANSFORM_SCALE, 1.25f);
        // Random Villains drop a maxamized magic item.
        SetLocalInt (oCreature, "0_MaxNumOfPowers", TRUE);
    }
    // Give villians a base set of items.
    GiveMagicalEquipment (oCreature, FloatToInt (GetChallengeRating (oCreature)));
    SetupCreature (oCreature, oWaypoint, oPC, TRUE);
   // Check for summons effects.
   CheckforSummonsEffect(oWaypoint, lLocation, oCreature);
}

// Checks to see if the placeable should have a corpse.
void CheckForCorpse (object oPlaceable, int nLevel)
{
       int nGender = GetLocalInt (oPlaceable, "0_Gender");
       string sTag = GetTag(oPlaceable);
       object oCorpse;
       if(sTag == "corpse")
       {
            if(nGender) oCorpse = CreateItemOnObject ("0_corpse_female", oPlaceable);
            else oCorpse = CreateItemOnObject ("0_corpse_male", oPlaceable);
       }
       else if(sTag == "skeleton")
       {
            oCorpse = CreateItemOnObject ("0_corpse_skeleto", oPlaceable);
            nGender = Random (2);
       }
       if(oCorpse != OBJECT_INVALID)
       {
            SetEventScript (oPlaceable, EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED, "0e_dist_premains");
            string sArray = "-----------4--0-";
            // (0) Name - randomize.
            // (1) ResRef is not set for randoms.
            // (2) Tag is set below.
            sArray = SetStringArray (sArray, 3, IntToString (nGender), "-");
            // (4) Race - randomize with rare races more common!
            string sRace;
            int nSwitch = d100();
            if(nSwitch < 3) sRace = "38"; // Dwarf Duergar
            else if(nSwitch < 5) sRace = "46"; // Gnome Svirfneblin
            else if(nSwitch < 7) sRace = "42"; // Elf Drow
            else if(nSwitch < 9) sRace = "43"; // Elf Star
            else if(nSwitch < 11) sRace = "55"; // Half elf Star
            else if(nSwitch < 13) sRace = "54"; // Half elf Drow
            else if(nSwitch < 15) sRace = "58"; // Orc Mountain
            else if(nSwitch < 17) sRace = "59"; // Orc Gray
            else if(nSwitch < 19) sRace = "57"; // Kobold
            else if(nSwitch < 21) sRace = "47"; // Goblin
            else if(nSwitch < 23) sRace = "60"; // Aasimar
            else if(nSwitch < 25) sRace = "61"; // Tiefling
            else if(nSwitch < 27) sRace = "62"; // Air Genasi
            else if(nSwitch < 29) sRace = "63"; // Earth Genasi
            else if(nSwitch < 31) sRace = "64"; // Fire Genasi
            else if(nSwitch < 33) sRace = "65"; // Water Genasi
            else if(nSwitch < 35) sRace = "66"; // Water Genasi
            else // Common races
            {
                nSwitch = d100();
                if(nSwitch < 6) sRace = "36"; // Dwarf Shield
                else if(nSwitch < 11) sRace = "37"; // Dwarf Gold
                else if(nSwitch < 16) sRace = "39"; // Elf Moon
                else if(nSwitch < 19) sRace = "40"; // Elf Sun
                else if(nSwitch < 20) sRace = "41"; // Elf Wood
                else if(nSwitch < 25) sRace = "44"; // Gnome Rock
                else if(nSwitch < 26) sRace = "45"; // Gnome Forest
                else if(nSwitch < 30) sRace = "48"; // Halfling Lightfoot
                else if(nSwitch < 35) sRace = "49"; // Halfling Strongheart
                else if(nSwitch < 36) sRace = "50"; // Halfling Ghostwise
                else if(nSwitch < 37) sRace = "51"; // Half elf Moon
                else if(nSwitch < 38) sRace = "52"; // Half elf Sun
                else if(nSwitch < 39) sRace = "53"; // Half elf Wood
                else if(nSwitch < 44) sRace = "56"; // Half orc
                else if(nSwitch < 52) sRace = "30"; // Human Damaran
                else if(nSwitch < 61) sRace = "31"; // Human Iluskan
                else if(nSwitch < 69) sRace = "32"; // Human Rashemi
                else if(nSwitch < 77) sRace = "33"; // Human Mulan
                else if(nSwitch < 85) sRace = "34"; // Human Tethyrian
                else sRace = "35"; // Human Chondathan
            }
            sArray = SetStringArray (sArray, 4, sRace, "-");
            // (5) Class - randomize.
            // (6) Package - randomize.
            sArray = SetStringArray (sArray, 7, IntToString (Random (3) - 1 + nLevel), "-");
            // (8) Alignment - randomize.
            // (9) Alignment - randomize.
            // (10) This is set to 4 neutral.
            // (11) Waypoint spawn is not set for corpses.
            // (12) Items is set to 0 for no equipment.
            sArray = CreateNPCArray (sArray);
            SetLocalString (oCorpse, "0_Array", sArray);
            string sGender, sText = "a ";
            if (nGender) sGender = "female";
            else sGender = "male";
            int nRace = StringToInt (sRace);
            int nTrueRace = GetTrueRacialType(OBJECT_INVALID, nRace);
            float fWeight;
            if (nTrueRace == RACIAL_TYPE_DWARF)
            {
                sRace = "Dwarf";
                if(nGender) fWeight = 1000.0;
                else fWeight = 1300.0;
                fWeight += IntToFloat(d10(2) * d4(2)) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_ELF)
            {
                sText= "an ";
                sRace = "Elf";
                if(nGender) fWeight = 800.0;
                else fWeight = 850.0;
                fWeight += IntToFloat(d6(2) * d6()) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_GNOME)
            {
                sRace = "Gnome";
                if(nGender) fWeight = 350.0;
                else fWeight = 400.0;
                fWeight += IntToFloat(d4(2)) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_HALFLING)
            {
                sRace = "Halfling";
                if(nGender) fWeight = 250.0;
                else fWeight = 300.0;
                fWeight += IntToFloat(d4(2)) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_HALFELF)
            {
                sRace = "Half-elf";
                if(nGender) fWeight = 800.0;
                else fWeight = 1000.0;
                fWeight += IntToFloat(d8(2) * d4(2)) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_HALFORC)
            {
                sText = "an ";
                sRace = "Orc";
                if(nGender) fWeight = 1100.0f;
                else fWeight = 1500.0f;
                fWeight += IntToFloat(d12(2) * d6(2)) * 10.0;
            }
            else if(nTrueRace == RACIAL_TYPE_HUMAN)
            {
                sRace = "Human";
                if(nGender) fWeight = 850.0f;
                else fWeight = 1200.0f;
                fWeight += IntToFloat(d10(2) * d4(2)) * 10.0;
            }
            if(nRace == 38) sRace = "Duergar";
            else if(nRace == 42) sRace = "Drow";
            else if(nRace == 46) sRace = "Svirfneblin";
            else if(nRace == 47)
            {
                sRace = "Goblin";
                if(nGender) fWeight = 225.0f;
                else fWeight = 275.0f;
                fWeight += IntToFloat(d4(2)) * 10.0;
            }
            else if(nRace == 57)
            {
                sRace = "Kobold";
                if(nGender) fWeight = 200.0f;
                else fWeight = 250.0f;
                fWeight += IntToFloat(d4(2)) * 10.0;
            }
            else if(nRace == 60)
            {
                sRace = "Aasimar";
                if(nGender) fWeight = 825.0f;
                else fWeight = 1175.0f;
                fWeight += IntToFloat(d10(2) * d4(2)) * 10.0;
            }
            else if(nRace == 61)
            {
                sRace = "Tiefling";
                if(nGender) fWeight = 850.0f;
                else fWeight = 1200.0f;
                fWeight += IntToFloat(d10(2) * d4(2)) * 10.0;
            }
            else if(nRace == 62)
            {
                sRace = "Air genasi";
                if(nGender) fWeight = 800.0f;
                else fWeight = 1100.0f;
                fWeight += IntToFloat(d8(2) * d4(2)) * 10.0;
            }
            else if(nRace == 63)
            {
                sRace = "Earth genasi";
                if(nGender) fWeight = 900.0f;
                else fWeight = 1300.0f;
                fWeight += IntToFloat(d10(2) * d8(2)) * 10.0;
            }
            else if(nRace == 64)
            {
                sRace = "Fire genasi";
                if(nGender) fWeight = 850.0f;
                else fWeight = 1200.0f;
                fWeight += IntToFloat(d10(2) * d4(2)) * 10.0;
            }
            else if(nRace == 65)
            {
                sRace = "Water genasi";
                if(nGender) fWeight = 875.0f;
                else fWeight = 1250.0f;
                fWeight += IntToFloat(d10(2) * d6(2)) * 10.0;
            }
            else if(nRace == 66)
            {
                sRace = "Gloaming";
                if(nGender) fWeight = 225.0f;
                else fWeight = 275.0f;
                fWeight += IntToFloat(d4(2)) * 10.0;
            }
            if(sTag == "corpse")
            {
                SetName(oCorpse, sRace + " " + sGender + " corpse");
                SetDescription (oCorpse, "This is the body of " + sText + sRace + " " + sGender);
                if(nGender) fWeight = fWeight * 0.8f;
            }
            else if(sTag == "skeleton")
            {
                SetName(oCorpse, sRace + " skeleton");
                SetDescription (oCorpse, "This is the skelton of " + sRace);
                fWeight = fWeight * 0.2f;
            }
            //if(GetPhenoType (oNPC) == 2) fWeight = fWeight * 1.5f;
            int nWeight = FloatToInt(fWeight);
            NWNX_Item_SetWeight(oCorpse, nWeight);
            SetLocalInt(oCorpse, "0_Weight", nWeight);
            SetLocalInt(oCorpse, PC_ASSOCIATE_TYPE, ASSOCIATE_TYPE_HENCHMAN);
       }
}

void CreatePlaceable (object oWaypoint, int nLevel, string sNewTag = "")
{
   // Lets find out the placeable and spawn them, use variable on waypoint to
   // create the ResRef or Template.
   string sTemplate = GetLocalString (oWaypoint, "0_Resref");
   int nIndex = GetLocalInt (oWaypoint, "0_Index");
   // Now create the Resref of the placeable. If 0_Index is greater than 0 then
   // we can generate different looking placeables from the pallet with the 0_Resref + o_Index "Chest_1".
   if (nIndex > 0) sTemplate = sTemplate + "_" + IntToString (Random (nIndex)+1);
   // Get the location of the Waypoint.
   location lLocation = GetLocation (oWaypoint);
   // Create the object.
   object oPlaceable = CreateObject (OBJECT_TYPE_PLACEABLE, sTemplate, lLocation, FALSE);
   // Check for summons effects.
   CheckforSummonsEffect(oWaypoint, lLocation, oPlaceable);
   // Used to help find errors in waypoint data.
   if (!GetIsObjectValid (oPlaceable))
   {
      object oArea = GetArea (oWaypoint);
      SetModuleError ("RESREF", "0_in_spawn", "475", "Waypoint (" + GetName (oWaypoint) +
                      "/" + GetTag (oWaypoint) + ") in area (" + GetName (oArea) +
                      "/" + GetTag (oArea) + ") has an invalid ResRef (" +  sTemplate + ")");
      return;
   }
   // Tag the placeable as spawned. Used for cleanup scripts and area saving.
   SetLocalInt (oPlaceable, "0_Spawned", TRUE);
   PassVariables (oWaypoint, oPlaceable);
   if (GetHasInventory (oPlaceable))
   {
       CheckForCorpse (oPlaceable, nLevel);
       CheckForLock (oPlaceable, nLevel);
       CheckForTrap (oPlaceable, nLevel);
   }
   if (GetLocalInt (oWaypoint, "0_Description"))
   {
      string sDescription = GetName (oWaypoint);
      SetDescription (oPlaceable, sDescription);
   }
   string sName = GetLocalString (oWaypoint, "0_Name");
   if (sName != "") SetName (oPlaceable, sName);
   // Check to see if we need to change the tag.
   if (sNewTag != "") SetTag (oPlaceable, sNewTag);
}

void CreateEffect (object oWaypoint)
{
    // Lets find out the effect and spawn them, use variable on waypoint to
    // create the effect.
    int nEffect = GetLocalInt (oWaypoint, "0_Effect");
    effect eVisualEffect = EffectVisualEffect (nEffect);
    // Get the location of the Waypoint.
    location lLocation = GetLocation (oWaypoint);
    ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eVisualEffect, lLocation);
    float fRepeat = GetLocalFloat (oWaypoint, "0_Repeat");
    if (fRepeat > 0.0f) DelayCommand (fRepeat, SpawnEffectAgain (oWaypoint));
}

void ChangeLight (object oWaypoint)
{
    int nMainLight1 = GetLocalInt (oWaypoint, "0_MLight1");
    int nMainLight2 = GetLocalInt (oWaypoint, "0_MLight2");
    float fDelayLights = GetLocalFloat (oWaypoint, "0_DelayLights");
    int nSourceLight1 = GetLocalInt (oWaypoint, "0_SLight1");
    int nSourceLight2 = GetLocalInt (oWaypoint, "0_SLight2");
    //Debug ("0i_spawn", "546", "Change light! " + IntToString (nMainLight1) + " : " + IntToString (nMainLight2));
    if (fDelayLights == 0.0) fDelayLights = 0.1;
    DelayCommand (fDelayLights, SetTileMainLightColor (GetLocation (oWaypoint), nMainLight1, nMainLight2));
    DelayCommand (fDelayLights, SetTileSourceLightColor (GetLocation (oWaypoint), nSourceLight1, nSourceLight2));
    // Just in case we changed a light.
    DelayCommand (fDelayLights + 0.2, RecomputeStaticLighting (GetArea (oWaypoint)));
}

int CheckChances (object oWaypoint)
{
    // Roll to see if the creature can spawn.
    // Check the day spawn.
    if (GetIsDay () && GetLocalInt (oWaypoint, "0_ChanceDay") >= d100()) return TRUE;
    else if (GetLocalInt (oWaypoint, "0_ChanceNight") >= d100()) return TRUE;
    return FALSE;
}

void CheckWaypoints (object oPC, object oObject, int bNoDifficulty, int nLevel, string sType, string sNewTag)
{
    float fDelay;
    string sTag = GetTag (oObject);
    // Is this a Creature spawn point.
    if (sTag == "ip_encounter" + sType)
    {
        if (CheckChances (oObject))
        {
            // Check for Delay.
            fDelay = GetLocalFloat (oObject, "0_Delay");
            if (fDelay == 0.0f) fDelay = 0.5f;
            // Check for Villain.
            if (GetLocalInt (oObject, "0_Villain")) DelayCommand (fDelay, CreateVillain (oObject, oPC, nLevel));
            // Check for random villians.
            else if (d100 () <= GetLocalInt (GetModule (), "0_VILLAIN_CHANCE") && !bNoDifficulty) DelayCommand (fDelay, CreateVillain (oObject, oPC, nLevel, TRUE));
            // Otherwise create a normal monster.
            else DelayCommand (fDelay, CreateCreature (oObject, oPC, nLevel));
            return;
        }
    }
    // Is this a placeable spawn point.
    else if (sTag == "ip_placeable" + sType)
    {
        // Roll chance of spawning placeable.
        if (CheckChances (oObject))
        {
            // Check for Delay.
            fDelay = GetLocalFloat (oObject, "0_Delay");
            if (fDelay == 0.0f) fDelay = 0.5f;
            DelayCommand (fDelay, CreatePlaceable (oObject, nLevel, sNewTag));
            return;
        }
    }
    // Is this an effect spawn point.
    else if (sTag == "ip_effect" + sType)
    {
        if (CheckChances (oObject))
        {
           // Check for Delay.
           fDelay = GetLocalFloat (oObject, "0_Delay");
           if (fDelay == 0.0f) fDelay = 0.5f;
           DelayCommand (fDelay, CreateEffect (oObject));
           return;
        }
    }
    // Is this a area light?
    else if (sTag == "ip_light" + sType)
    {
        if (CheckChances (oObject))
        {
            ChangeLight (oObject);
            return;
        }
    }
    // Is this a area light?
    else if (sTag == "ip_trap" + sType)
    {
        if (CheckChances (oObject))
        {
            DelayCommand (0.2, TrapObject (oObject, nLevel, GetLocalInt (oObject, "0_TrapType")));
            return;
        }
    }
    // Creates placeables at a specific map location. Usually used on generated
    // overland map areas.
    object oArea = GetArea (oObject);
    if (GetStringLeft (sTag, 11) == "ip_location")
    {
        //object oArea = GetArea (oObject);
        if (GetStringRight (sTag, 7) == GetTag (oArea))
        {
            if (CheckChances (oObject))
            {
                // Check for Delay.
                fDelay = GetLocalFloat (oObject, "0_Delay");
                if (fDelay == 0.0f) fDelay = 0.5f;
                DelayCommand (fDelay, CreatePlaceable (oObject, nLevel, sNewTag));
            }
        }
    }
}

void CheckDoors (object oObject, int nLevel)
{
    if (GetLocalInt (oObject, "0_OpenDoor")) AssignCommand (oObject, ActionOpenDoor (oObject));
    else AssignCommand (oObject, ActionCloseDoor (oObject));
    CheckForLock (oObject, nLevel);
    CheckForTrap (oObject, nLevel);
}

// Cycles through all objects in the area spawning based on information point waypoints.
// oArea is the area to check from.
// oPC used in rolls.
// nLevel is the level of the area to check.
// bNoDifficulty defines if the area is hostile to the players.
// sType is a prefix to select trigger or special spawn waypoints.
// sNewTag is to change a placeables tag.
void CheckObjects (object oArea, object oPC, int nLevel, int bNoDifficulty, string sType = "", string sNewTag = "")
{
    int nIndex = 1;
    // Get the area's objects to setup the area.
    object oObject = GetObjectInArea (oArea, nIndex);
    while (oObject != OBJECT_INVALID)
    {
        int nObjectType = GetObjectType (oObject);
        if (nObjectType == OBJECT_TYPE_WAYPOINT) CheckWaypoints (oPC, oObject, bNoDifficulty, nLevel, sType, sNewTag);
        else if (nObjectType == OBJECT_TYPE_DOOR) CheckDoors (oObject, nLevel);
        nIndex ++;
        oObject = GetObjectInArea (oArea, nIndex);
    }
}

// Used to Populate area to build effect for an area.
// oPC is an object in the area to help find the waypoints.
// sType is the type of waypoint to be used. Defaults are Area, Trigger, Placeable.
void SpawnEffects (object oPC, string sType = "")
{
   int iCounter = 1;
   object oWaypoint = GetNearestObjectByTag ("ip_effect" + sType, oPC, iCounter);
   while (GetIsObjectValid (oWaypoint))
   {
      // Ok so are we spawning the effect?
      if (CheckChances (oWaypoint))
      {
         // Check for Delay.
         float fDelay = GetLocalFloat (oWaypoint, "0_Delay");
         if (fDelay > 0.0f) DelayCommand (fDelay, CreateEffect (oWaypoint));
         else CreateEffect (oWaypoint);
      }
      iCounter ++;
      oWaypoint = GetNearestObjectByTag ("ip_effect" + sType, oPC, iCounter);
   }
}

void SpawnEffectAgain (object oWaypoint)
{
   // Check to see if a player is in the area.
   object oPlayer = GetNearestCreature (CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oWaypoint);
   if (!GetIsObjectValid (oPlayer)) return;
   // Are we spawning the effect?
   if (CheckChances (oWaypoint))
   {
      // Check for Delay.
      float fDelay = GetLocalFloat (oWaypoint, "0_Delay");
      if (fDelay > 0.0f) DelayCommand (fDelay, CreateEffect (oWaypoint));
      else CreateEffect (oWaypoint);
   }
 }

void LockObject (object oObject, int nLevel)
{
    SetLocked (oObject, TRUE);
    // If no lockDC then make one.
    int nUnLockDC = GetLocalInt (oObject, "0_UnLockDC");
    if (nUnLockDC == 0) nUnLockDC = LOCK_BASE_DC + Random (LOCK_DIE) + 1 + nLevel;
    SetLockUnlockDC (oObject, nUnLockDC);
    // If this is a placeable then lets make sure it has gold.
    if (GetObjectType (oObject) == OBJECT_TYPE_PLACEABLE)
    {
        SetLocalInt (oObject, "0_BonusGold", nLevel * (Random (16) + 5));
    }
}

// oObject is the object to trap.
// nLevel is the level of the trap (1-20).
// nTrapType is the type of trap (1 - 19).
void TrapObject (object oObject, int nLevel, int  nTrapType)
{
    int nTrap = GetLocalInt (oObject, "0_Trap_Level");
    if (nLevel < nTrap) nLevel = nTrap;
    // Set trap type for later resets.
    SetLocalInt (oObject, "0_TrapType", nTrapType);
    // Randomize from 19 different traps. See 0i_traps for types.
    if (nTrapType == 1) nTrapType = Random (18) + 2;
    int nObjectType = GetObjectType (oObject);
    if (nObjectType == OBJECT_TYPE_WAYPOINT)
    {
        float fSize = GetLocalFloat (oObject, "0_TrapSize");
        string sTag = GetLocalString (oObject, "0_Tag");
        oObject = CreateTrapAtLocation (nTrapType, GetLocation (oObject), fSize, "spawned_trap", STANDARD_FACTION_HOSTILE, "0e_disarmtrap", "0e_trigtrap");
        if (sTag != "") SetTag (oObject, sTag);
        json jTrigger = ObjectToJson (oObject);
        float fHeight = JsonGetFloat (GffGetFloat (jTrigger, "HighlightHeight"));
        jTrigger = GffReplaceFloat (jTrigger, "HighlightHeight", 0.3 + fHeight);
        DestroyObject (oObject);
        oObject = JsonToObject (jTrigger, GetLocation (oObject), OBJECT_INVALID, TRUE);
    }
    else
    {
        CreateTrapOnObject (nTrapType, oObject, STANDARD_FACTION_HOSTILE, "0e_disarmtrap", "0e_trigtrap");
    }
    // Check to see if it is an Area of effect trap.
    if (d100() > 75) SetLocalInt (oObject, "0_AOE_Trap", TRUE);
    else SetLocalInt (oObject, "0_AOE_Trap", FALSE);
    // Adjust the traps detect DC.
    nTrap = GetLocalInt (oObject, "0_TrapDetectDC");
    if (nTrap == 0)
    {
        nTrap = TRAP_DETECT_BASE_DC + Random (TRAP_DETECT_DIE) + 1 + nLevel;
        SetTrapDetectDC (oObject, nTrap);
    }
    // Adjust traps disarm DC.
    nTrap = GetLocalInt (oObject, "0_TrapDisarmDC");
    if (nTrap == 0)
    {
        nTrap = TRAP_DISARM_BASE_DC + Random (TRAP_DISARM_DIE) + 1 + nLevel;
        SetTrapDisarmDC (oObject, nTrap);
    }
    // Now lets make the trap.
    SetTrapActive (oObject, TRUE);
    SetTrapDetectable (oObject, TRUE);
    // If this is a placeable then lets set an automatic permament magic item.
    if (nObjectType == OBJECT_TYPE_PLACEABLE)
    {
       int nBonus = GetLocalInt (oObject, "0_BonusMagicItems") + 1;
       SetLocalInt (oObject, "0_BonusMagicItems", nBonus);
       int iMagicItemType = GetLocalInt (oObject, "0_BaseItemType");
       if (iMagicItemType == 0) SetLocalInt (oObject, "0_BaseItemType", 149);
    }
}

// Creates a group of placeables at lLocation.
// sGroup is the name of the group to make.
// lLocation is the location center of the group.
// sQuestTag will allow a quest to place a special tag onto a container.
void CreateGroupPlaceable(string sGroup, location lLocation, string sQuestTag = "")
{
    int iIndex;
    object oObject;
    string sNewTag = "";
    if (sQuestTag != "") sNewTag = sQuestTag;
    // first break out the location so we can place our placeables.
    object oArea = GetAreaFromLocation (lLocation);
    // Facings are as follows 0.0f East, 90.0f North, 180.0f West, 270.0f South.
    float fFacing = GetFacingFromLocation (lLocation);
    vector vPos = GetPositionFromLocation (lLocation);
    location lNewLocation;
    // Get the group to make.
    if (sGroup == "CAMP")
    {
        // Tent1
        lNewLocation = Location (oArea, Vector (vPos.x - 5.0f, vPos.y - 5.0f, vPos.z), 300.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "x2_plc_tent_r", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Tent2
        // Tent3
        // Campfire near the center.
        lNewLocation = lLocation;
        string sIndex = IntToString (d10());
        lNewLocation = Location (oArea, Vector (vPos.x - 3.0f, vPos.y, vPos.z), 0.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_campfire_" + sIndex, lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Chest1 east 5ft
        iIndex = Random (5) + 1;
        lNewLocation = Location (oArea, Vector (vPos.x + 5.0f, vPos.y, vPos.z), 0.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_t_chest_" + IntToString (iIndex), lNewLocation, FALSE, sNewTag);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Chest2
    }
    else if (sGroup == "CARAVAN")
    {
        // Wagon at the center.
        lNewLocation = lLocation;
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_wagon_1", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Camp Fire
        lNewLocation = Location (oArea, Vector (vPos.x - 3.5f, vPos.y - 2.5f, vPos.z), 100.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "plc_campfrwspit", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Crate1
        lNewLocation = Location (oArea, Vector (vPos.x + 3.0f, vPos.y - 4.0f, vPos.z), 45.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_crate_1", lNewLocation, FALSE, sNewTag);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Crate2
        lNewLocation = Location (oArea, Vector (vPos.x + 3.0f, vPos.y - 2.5f, vPos.z), 150.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_crate_2", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Guards
        lNewLocation = Location (oArea, Vector (vPos.x + 4.0f, vPos.y - 3.0f, vPos.z), 112.0f);
        object oCreature = CreateObject (OBJECT_TYPE_CREATURE, "0_caravan_guard", lNewLocation);
        SetupCreature  (oCreature);
        lNewLocation = Location (oArea, Vector (vPos.x - 6.0f, vPos.y - 3.0f, vPos.z), 245.0f);
        oCreature = CreateObject (OBJECT_TYPE_CREATURE, "0_caravan_guard", lNewLocation);
        SetupCreature  (oCreature);
    }
    else if (sGroup == "GRAVEYARD")
    {
        lNewLocation = lLocation;
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_grave_" + IntToString(Random(54) + 1), lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x - 5.0f, vPos.y, vPos.z), 180.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_grave_" + IntToString(Random(54) + 1), lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x + 5.0f, vPos.y, vPos.z), 180.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_grave_" + IntToString(Random(54) + 1), lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x - 5.0f, vPos.y - 5.0f, vPos.z), 180.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_grave_" + IntToString(Random(54) + 1), lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x + 5.0f, vPos.y - 5.0f, vPos.z), 180.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_grave_" + IntToString(Random(54) + 1), lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
    }
    else if (sGroup == "LAIR")
    {
        lNewLocation = lLocation;
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "plc_pileskulls", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x - 3.5f, vPos.y, vPos.z), 125.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "plc_bones", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x + 6.0f, vPos.y, vPos.z), 215.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "x3_plc_skelwar", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x - 5.5f, vPos.y - 4.5f, vPos.z), 70.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "x3_plc_skelwar2", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        lNewLocation = Location (oArea, Vector (vPos.x + 2.5f, vPos.y - 7.5f, vPos.z), 30.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "x3_plc_skelmage", lNewLocation);
        SetLocalInt (oObject, "0_Spawned", TRUE);
        // Treasure Chest
        iIndex = Random (5) + 1;
        lNewLocation = Location (oArea, Vector (vPos.x, vPos.y +3.5f, vPos.z), 95.0f);
        oObject = CreateObject (OBJECT_TYPE_PLACEABLE, "0_t_chest_" + IntToString (iIndex), lNewLocation, FALSE, sNewTag);
        SetLocalObject (oArea, "0_Container", oObject);
        SetTag(oObject, "lair_treasure");
    }
}

location RandomizeLocation (location lLocation, int nRadius)
{
    object oArea = GetAreaFromLocation (lLocation);
    vector vPosition = GetPositionFromLocation (lLocation);
    float fOrientation = GetFacingFromLocation (lLocation);
    // Ranomize
    if (d2() == 1) vPosition.x = vPosition.x + Random (nRadius);
    else vPosition.x = vPosition.x - Random (nRadius);
    if (d2() == 1) vPosition.y = vPosition.y + Random (nRadius);
    else vPosition.y = vPosition.y - Random (nRadius);
    return Location (oArea, vPosition, fOrientation);
}


