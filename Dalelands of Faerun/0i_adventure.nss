/*//////////////////////////////////////////////////////////////////////////////
 Spript Name: 0i_adventure
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with adventures.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_database"
#include "0i_area"

void SetDMTransition (object oPC, string sResRef, location lLocation)
{
    // Find the last transition laid.
    int i = 1;
    // Create new transition tag so we can make them unique for each DM.
    string sName = RemoveIllegalCharacters (GetName (oPC));
    string sTag = "Tran_" + sName + "_";
    object oTransition, oTransition2;
    // Find the next free transition.
    // Max of 10 transitions (20 different transitions).
    oTransition = GetObjectByTag (sTag + IntToString (i), 0);
    while (oTransition != OBJECT_INVALID && i < 21)
    {
        i ++;
        oTransition = GetObjectByTag (sTag + IntToString (i), 0);
    }
    // If we have a free slot left then create a new transition.
    if (i < 21)
    {
        // Create the new transition.
        oTransition = CreateObject (OBJECT_TYPE_PLACEABLE, sResRef, lLocation, FALSE, sTag + IntToString (i));
        sName = GetName (oTransition);
        SetLocalInt (oTransition, "0_Spawned", TRUE);
        // Set its transition location.
        if (i % 2 == 0)
        {
            // This creates the second (linking transition)
            // Set the transition tag so we can jump to it.
            SetLocalString (oTransition, "0_TransitionTag", sTag + IntToString (i - 1));
            oTransition2 = GetObjectByTag (sTag + IntToString (i - 1));
            // Inform the dm we have set the transition.
            SendMessages ("Created a " + sName + " linked to " + GetName (oTransition2) + ".", COLOR_GRAY, oPC, FALSE, FALSE);
        }
        else
        {
            // This sets the first transition in the set.
            SetLocalString (oTransition, "0_TransitionTag", sTag + IntToString (i + 1));
            // Send a message to the dm that we have set it.
            SendMessages ("Created a " + sName + ". Needs another transition to work.", COLOR_GRAY, oPC, FALSE, FALSE);
        }
    }
}

void SaveAreaObjects (object oPC, object oArea, string sDBTag)
{
    int nVarCount, nVarInc, nVarType;
    int bSave, nObjectType, nCounter = 1;
    struct NWNX_Object_LocalVariable lvVar;
    string sVar, sLocation, sObjectTag;
    object oMaster;
    object oObject = GetFirstObjectInArea (oArea);
    while (oObject != OBJECT_INVALID && nCounter < 101)
    {
        nObjectType = GetObjectType (oObject);
        if (nObjectType == OBJECT_TYPE_ITEM) bSave = TRUE;
        else if (nObjectType == OBJECT_TYPE_CREATURE)
        {
            oMaster = GetMaster (oObject);
            if (GetIsPC (oObject)) bSave = FALSE;
            else if (oMaster == OBJECT_INVALID) bSave = TRUE;
            else bSave = FALSE;
        }
        else if (nObjectType == OBJECT_TYPE_PLACEABLE && GetLocalInt (oObject, "0_Spawned")) bSave = TRUE;
        else bSave = FALSE;
        if (bSave)
        {
            if (nObjectType == OBJECT_TYPE_CREATURE)
            {
                // Save faction to the creatures subrace field since it isn't used.
                SetSubRace (oObject, IntToString (GetLocalInt (oObject, "0_PermanentFaction")));
            }
            sLocation = LocationToStringArray (GetLocation (oObject));
            sObjectTag = sDBTag + "_" + IntToString (nCounter);
            CheckServerDataAndInitialize (oPC, ADV_OBJ_TABLE, sObjectTag);
            SetServerDatabaseString (oPC, ADV_OBJ_TABLE, "location", sLocation, sObjectTag);
            SetServerDatabaseObject (oPC, ADV_OBJ_TABLE, oObject, sObjectTag);
            SetServerDatabaseString (oPC, ADV_OBJ_TABLE, "objecttag", GetTag (oObject), sObjectTag);
            if (nObjectType == OBJECT_TYPE_PLACEABLE)
            {
                nVarCount = NWNX_Object_GetLocalVariableCount (oObject);
                if (nVarCount > 9) nVarCount = 10;
                nVarInc = 0;
                while (nVarInc < nVarCount)
                {
                    lvVar = NWNX_Object_GetLocalVariable (oObject, nVarInc);
                    SetServerDatabaseInt (oPC, ADV_OBJ_TABLE, "vartype" + IntToString (nVarInc), lvVar.type, sObjectTag);
                    switch (lvVar.type)
                    {
                        case NWNX_OBJECT_LOCALVAR_TYPE_INT: sVar = IntToString (GetLocalInt (oObject, lvVar.key)); break;
                        case NWNX_OBJECT_LOCALVAR_TYPE_FLOAT: sVar = FloatToString (GetLocalFloat (oObject, lvVar.key), 0); break;
                        case NWNX_OBJECT_LOCALVAR_TYPE_STRING: sVar = GetLocalString (oObject, lvVar.key); break;
                    }
                    SetServerDatabaseString (oPC, ADV_OBJ_TABLE, "varname" + IntToString (nVarInc), lvVar.key, sObjectTag);
                    SetServerDatabaseString (oPC, ADV_OBJ_TABLE, "var" + IntToString (nVarInc), sVar, sObjectTag);
                    nVarInc ++;
                }
            }
            nCounter++;
        }
        oObject = GetNextObjectInArea (oArea);
    }
    SendMessages ("Saved " + IntToString (nCounter - 1) + " objects for area (" + GetName (oArea) + ").", COLOR_GREEN, oPC);
    // Clear any saved data after all objects are saved.
    string sData = GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "location", sObjectTag);
    sObjectTag = sDBTag + "_" + IntToString (nCounter);
    while (sData != "")
    {
        DeleteServerDatabaseObject (oPC, ADV_OBJ_TABLE, sObjectTag);
        nCounter++;
        sObjectTag = sDBTag + "_" + IntToString (nCounter);
        sData = GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "location", sObjectTag);
    }
}

void LoadVariables (object oPC, object oObject, string sObjectTag)
{
    int nVarType, nVarInc = 0;
    string sVarName, sVar, sVarInc;
    while (nVarInc < 10)
    {
        sVarInc = IntToString (nVarInc);
        nVarType = GetServerDatabaseInt (oPC, ADV_OBJ_TABLE, "vartype" + sVarInc, sObjectTag);
        sVarName = GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "varname" + sVarInc, sObjectTag);
        sVar = GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "var" + sVarInc, sObjectTag);
        switch (nVarType)
        {
            case NWNX_OBJECT_LOCALVAR_TYPE_INT: SetLocalInt (oObject, sVarName, StringToInt (sVar)); break;
            case NWNX_OBJECT_LOCALVAR_TYPE_FLOAT: SetLocalFloat (oObject, sVarName, StringToFloat (sVar)); break;
            case NWNX_OBJECT_LOCALVAR_TYPE_STRING: SetLocalString (oObject, sVarName, sVar); break;
        }
        nVarInc ++;
    }
}

void LoadAreaObjects (object oPC, string sDBTag, object oArea)
{
    int nObjectType, nCounter = 1;
    string sObjectTag = sDBTag + "_" + IntToString (nCounter);
    location lLocation = StringArrayToLocation (GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "location", sObjectTag));
    object oObject = GetServerDatabaseObject (oPC, ADV_OBJ_TABLE, lLocation, OBJECT_INVALID, sObjectTag);
    while (oObject != OBJECT_INVALID && nCounter < 101)
    {
        nObjectType = GetObjectType (oObject);
        if (nObjectType == OBJECT_TYPE_CREATURE)
        {
            // Load faction from the creatures subrace field since it isn't used.
            SetLocalInt (oObject, "0_PermanentFaction", StringToInt (GetSubRace (oObject)));
            SetSubRace (oObject, "");
        }
        if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            // Tag the placeable as spawned. Used for cleanup scripts and area saving.
            SetLocalInt (oObject, "0_Spawned", TRUE);
            LoadVariables (oPC, oObject, sObjectTag);
        }
        nCounter ++;
        sObjectTag = sDBTag + "_" + IntToString (nCounter);
        lLocation = StringArrayToLocation (GetServerDatabaseString (oPC, ADV_OBJ_TABLE, "location", sObjectTag));
        oObject = GetServerDatabaseObject (oPC, ADV_OBJ_TABLE, lLocation, OBJECT_INVALID, sObjectTag);
    }
    SendMessages ("Loaded " + IntToString (nCounter - 1) + " objects for area (" + GetName (oArea) + ").", COLOR_GREEN, oPC);
}
void LoadAreaFromDB (object oPC, string sDBTag)
{
    int nX, nY, nZ;
    string sAreaToLoadTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
    if (sAreaToLoadTag == "") return;
    object oArea = GetObjectByTag (sAreaToLoadTag);
    if (oArea == OBJECT_INVALID)
    {
        oArea = GenerateArea (sAreaToLoadTag);
    }
    if (oArea != OBJECT_INVALID)
    {
        ClearArea (oArea);
        string sData = GetServerDatabaseString (oPC, AREA_TABLE, "areaname", sDBTag);
        SetName (oArea, sData);
        int nData = GetServerDatabaseInt (oPC, AREA_TABLE, "level", sDBTag);
        SetLocalInt (oArea, "0_Area_Level", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "lootstate", sDBTag);
        SetLocalInt (oArea, "0_LootOFF", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "xpstate", sDBTag);
        SetLocalInt (oArea, "0_XPOFF", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "spellstate", sDBTag);
        SetLocalInt (oArea, "0_Spell_State", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "areastate", sDBTag);
        SetLocalInt (oArea, "0_Area_State", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "populatestate", sDBTag);
        SetLocalInt (oArea, "0_PopulateOFF", nData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "cleanstate", sDBTag);
        SetLocalInt (oArea, "0_CleanOFF", nData);
        object oWaypoint = GetObjectInAreaByTag  (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "reststate", sDBTag);
        object oRestWP = GetObjectInAreaByTag (oArea, "ip_no_rest", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        if (nData && oRestWP == OBJECT_INVALID) CreateObject (OBJECT_TYPE_WAYPOINT, "ip_no_rest", GetLocation (oWaypoint));
        else if (!nData && oRestWP != OBJECT_INVALID) DestroyObject (oRestWP);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "encchance", sDBTag);
        object oWaypoint2 = GetObjectInAreaByTag (oArea, "ip_randomencounter", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        if (oWaypoint2 == OBJECT_INVALID) oWaypoint2 = CreateObject (OBJECT_TYPE_WAYPOINT, "ip_randomencounter", GetLocation (oWaypoint));
        SetLocalInt (oWaypoint2, "0_Enc_Chance", nData);
        sData = GetServerDatabaseString (oPC, AREA_TABLE, "enctable", sDBTag);
        SetLocalString (oWaypoint, "0_Encounter_2da", sData);
        nData = GetServerDatabaseInt (oPC, AREA_TABLE, "animations", sDBTag);
        SetLocalInt (oArea, "0_AnimationsOFF", nData);
        int nMLightColor1 = GetServerDatabaseInt (oPC, AREA_TABLE, "mainlight1", sDBTag);
        int nMLightColor2 = GetServerDatabaseInt (oPC, AREA_TABLE, "mainlight2", sDBTag);
        int nSLightColor1 = GetServerDatabaseInt (oPC, AREA_TABLE, "sourcelight1", sDBTag);
        int nSLightColor2 = GetServerDatabaseInt (oPC, AREA_TABLE, "sourcelight2", sDBTag);
        float fX = 0.0f;
        float fY = 0.0f;
        float fXMaxSize = IntToFloat (GetAreaSize (AREA_WIDTH, oArea));
        float fYMaxSize = IntToFloat (GetAreaSize (AREA_HEIGHT, oArea));
        location lLocation = Location (oArea, Vector (fX, fY, 0.0f), 0.0f);
        while (fY <= fYMaxSize)
        {
            SetTileMainLightColor (lLocation, nMLightColor1, nMLightColor2);
            SetTileSourceLightColor (lLocation, nSLightColor1, nSLightColor2);
            fX += 1.0f;
            // Check to see if we need to go the next fY.
            if (fX > fXMaxSize) { fX = 0.0f; fY = fY + 1.0f; }
            lLocation = Location (oArea, Vector (fX, fY, 0.0f), 0.0f);
        }
        NWNX_Area_SetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_MOON_AMBIENT, GetServerDatabaseInt (oPC, AREA_TABLE, "moonambient", sDBTag));
        NWNX_Area_SetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_MOON_DIFFUSE, GetServerDatabaseInt (oPC, AREA_TABLE, "moondiffuse", sDBTag));
        NWNX_Area_SetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_SUN_AMBIENT, GetServerDatabaseInt (oPC, AREA_TABLE, "sunambient", sDBTag));
        NWNX_Area_SetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_SUN_DIFFUSE, GetServerDatabaseInt (oPC, AREA_TABLE, "sundiffuse", sDBTag));
        NWNX_Area_SetFogClipDistance (oArea, GetServerDatabaseFloat (oPC, AREA_TABLE, "fogdistance", sDBTag));
        LoadAreaObjects (oPC, sDBTag, oArea);
        SendMessages (GetName (oArea) + " has been loaded from " + sDBTag + ".", COLOR_GREEN, oPC);
        RecomputeStaticLighting (oArea);
        SetFogColor (FOG_TYPE_MOON, GetServerDatabaseInt (oPC, AREA_TABLE, "fogmooncolor", sDBTag), oArea);
        SetFogColor (FOG_TYPE_SUN, GetServerDatabaseInt (oPC, AREA_TABLE, "fogsuncolor", sDBTag), oArea);
    }
 }

void LoadAdventure (object oPC, int nAdventureSlot)
{
    int bAreaLoaded = FALSE;
    string sAdventureName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot));
    if (sAdventureName == "Empty")
    {
        SendMessages ("Slot (" + IntToString (nAdventureSlot) + ") is empty! No adventure to load!", COLOR_RED, oPC);
        return;
    }
    object oArea, oModule = GetModule ();
    string sDBTag, sAreaIndex, sAdventureSlot = "Slot" + IntToString (nAdventureSlot);
    int nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "startlevel", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "startlevel", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "restrictrest", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "restrictrest", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "xpslider", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "xpslider", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "treasureslider", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "treasureslider", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "temperature", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "temperature", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "precipitation", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation", nData);
    nData = GetServerDatabaseInt (oPC, ADVENTURE_TABLE, "storm", sAdventureSlot);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "storm", nData);
    float fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windmagnitude", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude", fData);
    fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windx", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windx", fData);
    fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windy", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windy", fData);
    fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windz", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windz", fData);
    fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windyaw", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw", fData);
    fData = GetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windpitch", sAdventureSlot);
    SetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch", fData);
    // Now load all areas in the Adventure.
    int nCounter = 1;
    float fDelay = 0.0f;
    while (nCounter < 11)
    {
        sAreaIndex = "Area" + IntToString (nCounter);
        sDBTag = sAdventureSlot + "_" + sAreaIndex;
        fDelay += 0.2f;
        DelayCommand (fDelay, LoadAreaFromDB (oPC, sDBTag));
        nCounter ++;
    }
    DelayCommand (fDelay + 1.0f, SendMessages ("Adventure (" + sAdventureName + ") has been loaded!", COLOR_GREEN, oPC));
}

void SaveAreaToDB (object oPC, object oArea, string sDBTag)
{
    int bState = FALSE;
    SetServerDatabaseString (oPC, AREA_TABLE, "resref", GetResRef (oArea), sDBTag);
    SetServerDatabaseString (oPC, AREA_TABLE, "areaname", GetName (oArea), sDBTag);
    SetServerDatabaseString (oPC, AREA_TABLE, "areatag", GetTag (oArea), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "level", GetLocalInt (oArea, "0_Area_Level"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "lootstate", GetLocalInt (oArea, "0_LootOFF"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "xpstate", GetLocalInt (oArea, "0_XPOFF"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "spellstate", GetLocalInt (oArea, "0_Spell_State"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "areastate", GetLocalInt (oArea, "0_Area_State"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "populatestate", GetLocalInt (oArea, "0_PopulateOFF"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "cleanstate", GetLocalInt (oArea, "0_CleanOFF"), sDBTag);
    object oWaypoint, oObject = GetFirstObjectInArea (oArea);
    if (GetTag (oObject) == "ip_no_rest") bState = TRUE;
    else if (GetNearestObjectByTag ("ip_no_rest", oObject) != OBJECT_INVALID) bState = TRUE;
    SetServerDatabaseInt (oPC, AREA_TABLE, "reststate", bState, sDBTag);
    if (GetTag (oObject) == "ip_randomencounter") oWaypoint = oObject;
    else oWaypoint = GetNearestObjectByTag ("ip_randomencounter", oObject);
    SetServerDatabaseInt (oPC, AREA_TABLE, "encchance", GetLocalInt (oWaypoint, "0_Enc_Chance"), sDBTag);
    if (GetTag (oObject) == "ip_area_level") oWaypoint = oObject;
    else oWaypoint = GetNearestObjectByTag ("ip_area_level", oObject);
    SetServerDatabaseString (oPC, AREA_TABLE, "enctable", GetLocalString (oWaypoint, "0_Encounter_2da"), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "animations", GetLocalInt (oArea, "0_AnimationsOFF"), sDBTag);
    location lLocation = Location (oArea, Vector (0.0f, 0.0f, 0.0f), 0.0f);
    SetServerDatabaseInt (oPC, AREA_TABLE, "mainlight1", GetTileMainLight1Color (lLocation), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "mainlight2", GetTileMainLight2Color (lLocation), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "sourcelight1", GetTileSourceLight1Color (lLocation), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "sourcelight2", GetTileSourceLight2Color (lLocation), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "moonambient", NWNX_Area_GetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_MOON_AMBIENT), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "moondiffuse", NWNX_Area_GetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_MOON_DIFFUSE), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "sunambient", NWNX_Area_GetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_SUN_AMBIENT), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "sundiffuse", NWNX_Area_GetSunMoonColors (oArea, NWNX_AREA_COLOR_TYPE_SUN_DIFFUSE), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "fogmooncolor", GetFogColor (FOG_TYPE_MOON, oArea), sDBTag);
    SetServerDatabaseInt (oPC, AREA_TABLE, "fogsuncolor", GetFogColor (FOG_TYPE_SUN, oArea), sDBTag);
    SetServerDatabaseFloat (oPC, AREA_TABLE, "fogdistance", NWNX_Area_GetFogClipDistance (oArea), sDBTag);
    SaveAreaObjects (oPC, oArea, sDBTag);
    //SendMessages (GetName (oArea) + " has been saved to " + sTag + ".", COLOR_GREEN, oDM, FALSE, FALSE);
}

void SaveAdventure (object oPC, int nAdventureSlot, string sAdventureName)
{
    SetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot), sAdventureName);
    object oModule = GetModule ();
    string sAdventureSlot = "Slot" + IntToString (nAdventureSlot);
    CheckServerDataAndInitialize (oPC, ADVENTURE_TABLE, sAdventureSlot);
    int nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "startlevel");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "startlevel", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "restrictrest");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "restrictrest", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "xpslider");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "xpslider", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "treasureslider");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "treasureslider", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "temperature");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "temperature", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "precipitation");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "precipitation", nData, sAdventureSlot);
    nData = GetServerDatabaseInt (oModule, SERVER_TABLE, "storm");
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "storm", nData, sAdventureSlot);
    float fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windmagnitude");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windmagnitude", fData, sAdventureSlot);
    fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windx");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windx", fData, sAdventureSlot);
    fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windy");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windy", fData, sAdventureSlot);
    fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windz");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windz", fData, sAdventureSlot);
    fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windyaw");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windyaw", fData, sAdventureSlot);
    fData = GetServerDatabaseFloat (oModule, SERVER_TABLE, "windpitch");
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windpitch", fData, sAdventureSlot);
    // Now save all areas in the Adventure.
    int nX, nY, nZ, nCounter = 1;
    float fDelay = 0.0f;
    string sAreaToSaveTag, sDBTag, sAreaIndex;
    object oArea;
    while (nCounter < 11)
    {
        sAreaIndex = "Area" + IntToString (nCounter);
        sDBTag = sAdventureSlot + "_" + sAreaIndex;
        sAreaToSaveTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
        if (sAreaToSaveTag != "")
        {
            oArea = GetObjectByTag (sAreaToSaveTag);
            if (oArea != OBJECT_INVALID)
            {
                fDelay += 0.2f;
                DelayCommand (fDelay, SaveAreaToDB (oPC, oArea, sDBTag));
            }
        }
        nCounter ++;
    }
    DelayCommand (fDelay + 1.0f, SendMessages ("Adventure (" + sAdventureName + ") has been saved!", COLOR_GREEN, oPC));
}

void SaveAreaToAdventure (object oPC, int nAdventureSlot, object oArea, int nIndex = 0)
{
    int bSave = FALSE;
    // Make sure this Adventure has been created.
    string sAdventureName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot));
    if (sAdventureName == "Empty")
    {
        SendMessages ("Slot (" + IntToString (nAdventureSlot) + ") is empty! Name adventure first!", COLOR_RED, oPC);
        return;
    }
    string sAreaToSaveTag = GetTag (oArea);
    string sAdventureSlot = "Slot" + IntToString (nAdventureSlot);
    string sDBTag, sDBAreaTag, sAreaIndex;
    sAreaIndex = "Area" + IntToString (nIndex);
    sDBTag = sAdventureSlot + "_" + sAreaIndex;
    // This area slot does not have data so lets save the area here.
    if (CheckServerDataAndInitialize (oPC, AREA_TABLE, sDBTag))
    {
       SaveAreaToDB (oPC, oArea, sDBTag);
       bSave = TRUE;
    }
    // Lets check this slots data and if it matches the area we are saving then save.
    else
    {
        sDBAreaTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
        if (sDBAreaTag == sAreaToSaveTag || sDBAreaTag == "")
        {
            SaveAreaToDB (oPC, oArea, sDBTag);
            bSave = TRUE;
        }
    }
    if (bSave) SendMessages (GetName (oArea) + " has been saved to " + sAreaIndex + " of " + sAdventureName + ".", COLOR_GREEN, oPC);
    else SendMessages (GetName (oArea) + " was no saved! An ERROR has occured.", COLOR_RED, oPC);
}

void ListAreasForAdventure (object oDM, int nSlot, object oArea)
{
    int i, nX, nY, nZ, bAreaListed = FALSE;
    string sAreaTag;
    string sATag, sTag, sSlot = "Slot" + IntToString (nSlot);
    string sAdventure = GetServerDatabaseString (oDM, DM_TABLE, sSlot);
    object oArea;
    if (sAdventure == "Empty")
    {
        SendMessages ("Slot (" + IntToString (nSlot) + ") is empty! No areas to list!", COLOR_GREEN, oDM, FALSE, FALSE);
        return;
    }
    // Now list all areas in the Adventure.
    i = 1;
    while (i < 11)
    {
        sATag = "Area" + IntToString (i);
        sTag = sSlot + "_" + sATag;
        sAreaTag = GetServerDatabaseString (oDM, AREA_TABLE, "areatag", sTag);
        if (sAreaTag != "")
        {
            oArea = GetObjectByTag (sAreaTag);
            if (oArea == OBJECT_INVALID) oArea = GenerateArea (sAreaTag);
            if (oArea != OBJECT_INVALID)
            {
                SendMessages (sATag + ": " + GetName (oArea), COLOR_GREEN, oDM, FALSE, FALSE);
                bAreaListed = TRUE;
            }
        }
        i ++;
    }
    if (!bAreaListed) SendMessages ("No areas to list for adventure (" + sAdventure + ").", COLOR_RED, oDM, FALSE, FALSE);
}

void RemoveAreaFromAdventure (object oPC, int nAdventureSlot, object oArea, int nIndex = 0)
{
    string sAdventureName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot));
    if (sAdventureName == "Empty")
    {
        SendMessages ("Slot (" + IntToString (nAdventureSlot) + ") is empty! No area to remove!", COLOR_RED, oPC);
        return;
    }
    string sDBAreaTag, sAreaIndex, sDBTag, sAreaToRemoveTag = GetTag (oArea);;
    string sAdventureSlot = "Slot" + IntToString (nAdventureSlot);
    sAreaIndex = "Area" + IntToString (nIndex);
    sDBTag = sAdventureSlot + "_" + sAreaIndex;
    sDBAreaTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
    if (sDBAreaTag == sAreaToRemoveTag) SetServerDatabaseString (oPC, AREA_TABLE, "areatag", "", sDBTag);
    SendMessages (GetName (oArea) + " has been removed from slot (" + IntToString (nIndex) + " ) in the adventure (" + sAdventureName + ")!", COLOR_GREEN, oPC);
}

void EraseAdventure (object oPC, int nAdventureSlot)
{
    // Now erase all areas in the Adventure.
    int nX, nY, nZ, nCounter = 1;
    float fDelay = 0.0f;
    string sAreaToRemoveTag, sDBTag, sAreaIndex, sName;
    string sAdventureSlot = "Slot" + IntToString (nAdventureSlot);
    object oArea;
    string sAdventureName = GetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot));
    if (sAdventureName == "Empty")
    {
        SendMessages ("Slot (" + IntToString (nAdventureSlot) + ") is empty! No adventure to erase!", COLOR_GREEN, oPC);
        return;
    }
    while (nCounter < 11)
    {
        sAreaIndex = "Area" + IntToString (nCounter);
        sDBTag = sAdventureSlot + "_" + sAreaIndex;
        sAreaToRemoveTag = GetServerDatabaseString (oPC, AREA_TABLE, "areatag", sDBTag);
        if (sAreaToRemoveTag != "")
        {
            SetServerDatabaseString (oPC, AREA_TABLE, "areatag", "", sDBTag);
            oArea = GetObjectByTag (sAreaToRemoveTag);
            sName = GetName (oArea);
            if (sName != "") SendMessages (sName + " has been removed from the adventure (" + sAdventureName + ")!", COLOR_RED, oPC);
        }
        nCounter ++;
    }
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "startlevel", 1, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "restrictrest", 1, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "xpslider", 0, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "treasureslider", 0, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "temperature", 80, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "precipitation", 0, sAdventureSlot);
    SetServerDatabaseInt (oPC, ADVENTURE_TABLE, "storm", 0, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windmagnitude", 0.0f, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windx", 0.0f, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windy", 0.0f, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windz", 0.0f, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windyaw", 0.0f, sAdventureSlot);
    SetServerDatabaseFloat (oPC, ADVENTURE_TABLE, "windpitch", 0.0f, sAdventureSlot);
    SetServerDatabaseString (oPC, DM_TABLE, "slot" + IntToString (nAdventureSlot), "Empty");
    SendMessages (sAdventureName + " has been removed!", COLOR_RED, oPC);
}


