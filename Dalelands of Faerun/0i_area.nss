
/*//////////////////////////////////////////////////////////////////////////////
 Spript Name: 0i_area
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with areas.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_spells"
#include "0i_spawn"
#include "0i_character"
#include "0i_effects"
#include "nwnx_area"
#include "0i_specialevents"

// Populates an area with NPC's based on the WayPoint system.
// See the waypoint "NPC Spawning Information point" in the pallet.
void PopulateArea (object oArea, object oPC);

// Clear an area's quest array.
// An area can have up to 5 quest active.
// oArea = the Area the quest is in.
void ClearAreaQuestArray (object oArea, string sID = "");

// Checks to see if the area torches are on or off based on time of day.
void CheckLights (object oArea);

// Used to remove objects from an area as well as clear quests.
// bForceClear - Clear area no matter what.
void ClearArea (object oArea, int bForceClear = FALSE);

// Used in the on exit event of areas to check if they still need to be cleaned.
// Calls remove RemoveObjectInArea if we still need to clean the area.
void CleanUpAreaCheck (object oArea);

// Closes open door.
void ResetDoor (object oDoor);

// Sets all placeables in the area as permanent.
void SetPlaceablesPermanent (object oPoint);

// Save encounters to DB
// oDM is the DM's encounters to be saved.
void SaveDMEncounters (object oDM);

// Load encounters from DB
// Note this will erase all encounters in the encounter area.
// oDM is the DM's encounters to be loaded.
void LoadDMEncounters (object oDM);

// Transitions a creature from one transition to another.
// If the area does not exist it will try to generate it.
// oCreature is the creature that is transitioning.
void Transition(object oCreature);

// Check a loaded player and moves them to the correct location based
// upon where they were saved last.
// oPC is the character to move.
// sWaypoint is the tag of the waypoint to jump to.
// sWaypoint is "" then it will move them to the last database save location.
void MovePlayer (object oPC, string sWaypoint = "");

// Generates an area from the overland.2da file based on X,Y and Z area tag.
// sAreaTag is the tag of the are to generate using X_Y_Z example 090_100_01
object GenerateArea (string sAreaTag);

// Send the areas diffculty to the entering player.
// oPlayer is the player to send the message to.
// oArea is the area to check difficulty of.
void SendDifficultyMessage (object oPlayer, object oArea);

// Move associates of oMaster to oTarget
void MoveAssociates (object oMaster, object oTarget);

// Save a characters pins on the map.
void LoadCharacterPins (object oPC);

// Delay transition until the creature is at the transition location.
// oCreature is the creature to wait to transition.
void WaitToTransition(object oCreature);

// Jump any players setup to follow this PC with the PC using a target object.
// oPC is the PC to follow
// oTarget is the object to jump to.
void JumpFollowingPCsToObject (object oPC, object oTarget);

// Jump any players setup to follow this PC with the PC using a location.
// oPC is the PC to follow
// lLocation is the location to jump to.
void JumpFollowingPCsToLocation (object oPC, location lLocation);

// Cleans up the variables used to move creatures from area to area.
void DeleteMoveVariables (object oCreature);

// Teleport to a specific location based on spell.
// oCaster is the one castinge teleport.
// sLocation is the location to teleport to.
// nSpell is the spell used. 976 Teleport, 977 Greater Teleport.
void Teleport(object oCaster, string sLocation, int nSpell, int nCasterLevel);

// Populates an area with objects based on the WayPoint system.
// See the waypoint "NPC Spawning Waypoint" in the pallet under NPC Ambience.
void PopulateArea (object oArea, object oPC)
{
   int nAdjustLevel, nMin_Level, nMax_Level, nPartyAvgLevel;
   // Find the ip_area_level to check encounter variables.
   object oWaypoint = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
   Debug("0i_area", "107", "Area: " + GetName (oArea) + " oCreature: " + GetName (oPC, TRUE) + " oWaypoint: " + GetName (oWaypoint));
   // Check to see if we need to stop difficulty messages.
   int bNoDifficulty = GetLocalInt (oWaypoint, "0_No_Difficulty");
   SetLocalInt (oArea, "0_No_Difficulty", bNoDifficulty);
   // Check to see if a DM has locked this area from being populated or cleared.
   if(GetLocalString (oWaypoint, "0_Encounter_2da") == "Off") return;
   // For special events check the Special events to see if we should change
   // encounter charts.
   if(!bNoDifficulty) CheckForSpecialEventEncounterChart(oPC, oArea, oWaypoint);
   // If area level is 0 then set it to the party's average level.
   int nLevel = GetLocalInt (oArea, "0_Area_Level");
   if(nLevel == 0)
   {
      // Get the minimum and maximum area levels.
      nMin_Level = GetLocalInt(oWaypoint, "0_Min_Level");
      if(nMin_Level < 1) nMin_Level = 1;
      nMax_Level = GetLocalInt(oWaypoint, "0_Max_Level");
      if(nMax_Level > 40) nMax_Level = 40;
      if(nMax_Level < nMin_Level) nMax_Level = nMin_Level;
      if(oPC != OBJECT_INVALID)
      {
          // Get the party Level
          nPartyAvgLevel = GetAvgPartyLevel(oPC);
          // Add a variable to the Level of the area if the party is over 3rd.
          if (nPartyAvgLevel > 3)
          {
              int nRoll = d100();
              if (nRoll < 6) nPartyAvgLevel = nPartyAvgLevel - 2;
              else if (nRoll < 26) nPartyAvgLevel --;
              else if (nRoll > 75) nPartyAvgLevel ++;
              else if (nRoll > 95) nPartyAvgLevel = nPartyAvgLevel + 2;
          }
          // Bound the party average level.
          if (nPartyAvgLevel < nMin_Level) nPartyAvgLevel = nMin_Level;
          else if (nPartyAvgLevel > nMax_Level) nPartyAvgLevel = nMax_Level;
          // If the party is over 2 PC's then add an extra level even after min/max.
          if (GetPartySize (oPC) > 2) nPartyAvgLevel ++;
      }
      else nPartyAvgLevel = (nMin_Level + nMax_Level) / 2;
      // Set the areas new level until cleared.
      SetLocalInt(oArea, "0_Area_Level", nPartyAvgLevel);
      nLevel = nPartyAvgLevel;
   }
   CheckObjects(oArea, oPC, nLevel, bNoDifficulty);
}

// Clear a quest in an area.
// An area can have up to 5 quest active.
void ClearAreaQuestArray (object oArea, string sQuestID = "")
{
    int nIndex;
    string sIndex;
    struct NWNX_Object_LocalVariable stVariable;
    // Clear all quests.
    if(sQuestID == "")
    {
        // Check for any quest variables and remove them.
        nIndex = NWNX_Object_GetLocalVariableCount(oArea) - 1;
        while(nIndex >= 0)
        {
            stVariable = NWNX_Object_GetLocalVariable(oArea, nIndex);
            if(stVariable.type == NWNX_OBJECT_LOCALVAR_TYPE_STRING)
            {
                if(GetStringLeft(stVariable.key, 8) == "0_QUEST_") DeleteLocalString(oArea, stVariable.key);
            }
            nIndex--;
        }
    }
    // Clear only the sQuestID quest variables.
    else
    {
        // Check for sQuestID variables and remove them.
        nIndex = NWNX_Object_GetLocalVariableCount(oArea) - 1;
        while(nIndex >= 0)
        {
            stVariable = NWNX_Object_GetLocalVariable(oArea, nIndex);
            if(stVariable.type == NWNX_OBJECT_LOCALVAR_TYPE_STRING)
            {
                if(GetLocalString(oArea, stVariable.key) == sQuestID) DeleteLocalString(oArea, stVariable.key);
            }
            nIndex--;
        }
    }
}

// Checks to see if the area torches are on or off based on time of day.
void CheckLights (object oArea)
{
    int iCounter = 1, iNight, iLightVolume, iEffect, iChance;
    string sLightColor;
    effect eEffect;
    object oSound;
    // Get if its daytime or nighttime.
    iNight = GetIsNight ();
    // Check for underground and set as if it is dark.
    if (GetIsAreaAboveGround (oArea) == AREA_UNDERGROUND) iNight = 1;
    // Go around area and look at all of the torches.
    object oLight = GetObjectInAreaByTag (oArea, "0_Light", iCounter);
    while (GetIsObjectValid (oLight))
    {
        // Check for chance on light to be lit.
        iChance = GetLocalInt (oLight, "0_Chance");
        // Default on is 0 so change it to 100.
        if (iChance == 0) iChance = 100;
       // Is it nighttime or underground?
       if (iNight && d100() < iChance)
       {
            // Make sure they are on.
            // Set variable stating its on.
            SetLocalInt (oLight, "0_Placeable_On", TRUE);
            // Activate it.
            AssignCommand (oLight, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
            // Turn on the ambient light.
            // Get the objects color and volume.
            sLightColor = GetLocalString (oLight, "0_LightColor");
            if (sLightColor == "Blue") iEffect = 153;
            else if (sLightColor == "Green") iEffect = 177;
            else if (sLightColor == "Orange") iEffect = 169;
            else if (sLightColor == "Purple") iEffect = 161;
            else if (sLightColor == "Red") iEffect = 165;
            else if (sLightColor == "White") iEffect = 173;
            else iEffect = 157; // Defaults to Yellow.
            iLightVolume = GetLocalInt (oLight, "0_LightVolume");
            if (iLightVolume == 10) iEffect = iEffect + 1;
            else if (iLightVolume == 15) iEffect = iEffect + 2;
            else if (iLightVolume == 20) iEffect = iEffect + 3;
            else iEffect = iEffect + 2; // Defaults to 15 volume.
            // Generate the correct effect number.
            eEffect = EffectVisualEffect (iEffect);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, oLight);
            oSound = GetNearestObjectByTag ("0_torch_sound", oLight);
            SoundObjectPlay (oSound);
       }
       // Else its daytime.
       else
       {
            // Make sure they are off.
            // Delete variable stating its on.
            DeleteLocalInt (oLight, "0_Placeable_On");
            // Deactivate it.
            AssignCommand (oLight, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE));
            // Turn off the ambient light by removing light effect.
            eEffect = GetFirstEffect (oLight);
            while (GetIsEffectValid (eEffect))
            {
                if (GetEffectType (eEffect) == EFFECT_TYPE_VISUALEFFECT) RemoveEffect (oLight, eEffect);
                eEffect = GetNextEffect (oLight);
            }
            oSound = GetNearestObjectByTag ("0_torch_sound", oLight);
            SoundObjectStop (oSound);
       }
       iCounter ++;
       oLight = GetObjectInAreaByTag (oArea, "0_Light", iCounter);
    }
}

// Used to remove objects from an area as well as clear quests.
// oArea is the area we are clearing.
// bForceClear - Clear area no matter what.
void ClearArea (object oArea, int bForceClear = FALSE)
{
    int nPermanent, nObjectType;
    string sTag, sCounter;
    float fDelay;
    object oPlayer, oObject, oItem;
    // Check to make sure there are no players in the area.
    if (!bForceClear)
    {
        oPlayer = GetFirstPC ();
        while (GetIsObjectValid (oPlayer))
        {
            if (GetArea (oPlayer) == oArea) return;
            oPlayer = GetNextPC ();
        }
    }
    // Ok we can populate this area again so delete the area level
    // unless the DM has set it.
    if (!GetLocalInt (oArea, "0_DM_Level_Set")) DeleteLocalInt (oArea, "0_Area_Level");
    // Remove the variable that defines if the area is populated.
    if (!GetLocalInt (oArea, "0_PopulateOFF")) DeleteLocalInt (oArea, "0_Populated");
    ClearAreaQuestArray (oArea);
    // Cycle through all objects in the area and clear them.
    oObject = GetFirstObjectInArea (oArea);
    while (oObject != OBJECT_INVALID)
    {
        nObjectType = GetObjectType (oObject);
        // Check for Items.
        if (nObjectType == OBJECT_TYPE_ITEM)
        {
            DestroyObject (oObject);
            //Debug ("0i_area", "293", " Destroying item: " + GetName (oObject));
        }
        // Check for Creatures.
        else if (nObjectType == OBJECT_TYPE_CREATURE)
        {
            if (bForceClear)
            {
                // Do not remove any followers of the players.
                if (!GetIsCharacter (GetMaster (oObject)))
                {
                    // Lets make sure we can destroy them.
                    AssignCommand (oObject, SetIsDestroyable (TRUE, FALSE, FALSE));
                    // Destroy the Creature.
                    DestroyObject (oObject);
                    //Debug ("0i_area", "307", " Destroying Creature: " + GetName (oObject));
                }
                //else Debug ("0i_area", "310", " Creature " + GetName (oObject) + " is a PC Associate! We are not deleteing them.");
            }
            else
            {
                // Lets make sure we can destroy them.
                AssignCommand (oObject, SetIsDestroyable (TRUE, FALSE, FALSE));
                // Destroy the Creature.
                DestroyObject (oObject);
                //Debug ("0i_area", "318", " Destroying Creature: " + GetName (oObject));
            }
        }
        // Check for placeables.
        else if (nObjectType == OBJECT_TYPE_PLACEABLE)
        {
            if (GetLocalInt (oObject, "0_Spawned"))
            {
                // lets check for inventory!
                if (GetHasInventory (oObject))
                {
                    oItem = GetFirstItemInInventory (oObject);
                    while (GetIsObjectValid (oItem))
                    {
                        DestroyObject (oItem);
                        //Debug ("0i_area", "333", " Destroying item: " + GetName (oItem) +
                        //       " in " + GetName (oObject));
                        oItem = GetNextItemInInventory (oObject);
                    }
                }
                DestroyObject (oObject);
                //Debug ("0i_area", "339", " Destroying placeable: " + GetName (oObject));
            }
            // Check for specific placeables.
            else
            {
                sTag = GetTag (oObject);
                // Check for body bags.
                if (sTag == "BodyBag")
                {
                    oItem = GetFirstItemInInventory (oObject);
                    while (oItem != OBJECT_INVALID)
                    {
                        DestroyObject (oItem);
                        //Debug ("0i_area", "352", " Destroying item: " + GetName (oItem) +
                        //       " in " + GetName (oObject));
                        oItem = GetNextItemInInventory (oObject);
                    }
                }
            }
        }
        // Check for triggers.
        else if (nObjectType == OBJECT_TYPE_TRIGGER)
        {
            if (GetResRef (oObject) == "")
            {
                DestroyObject (oObject);
                //Debug ("0i_area", "365", " Destroying trap trigger (" + GetName (oObject) +
                //       " (" + GetTag (oObject) + ").");
            }
            else
            {
                DeleteLocalInt (oObject, "0_Populated");
                DeleteLocalInt (oObject, "0_Spoken");
                //Debug ("0i_area", "372", " Clearing trigger (" + GetName (oObject) +
                //       " (" + GetTag (oObject) + ").");
            }
        }
        // Check for doors.
        else if (nObjectType == OBJECT_TYPE_DOOR)
        {
            DeleteLocalInt (oObject, "0_Populated");
            DeleteLocalInt (oObject, "0_Trap_Level");
            ResetDoor (oObject);
        }
        else if (nObjectType == OBJECT_TYPE_AREA_OF_EFFECT)
        {
            DestroyObject (oObject);
            //Debug ("0i_area", "386", " Destroying area of effect: " + GetName (oObject));
        }
        else if (nObjectType == OBJECT_TYPE_WAYPOINT)
        {
            if (GetStringLeft (GetTag (oObject), 8) == "ip_light")
            {
                int nMainLight1 = GetLocalInt (oObject, "0_Org_MLight1");
                int nMainLight2 = GetLocalInt (oObject, "0_Org_MLight2");
                int nSourceLight1 = GetLocalInt (oObject, "0_Org_SLight1");
                int nSourceLight2 = GetLocalInt (oObject, "0_Org_SLight2");
                SetTileMainLightColor (GetLocation (oObject), nMainLight1, nMainLight2);
                SetTileSourceLightColor (GetLocation (oObject), nSourceLight1, nSourceLight2);
                //Debug ("0i_area", "398", " Changing lights back to original settings for " + GetName (GetArea (oObject)));
            }
        }
        oObject = GetNextObjectInArea (oArea);
    }
}

// Closes open doors, and will set locks, traps either randomly or via variables.
void ResetDoor (object oDoor)
{
    // Check to see if the door should be open.
    if (GetLocalInt (oDoor, "0_NO_CLOSE")) AssignCommand (oDoor, ActionOpenDoor (oDoor));
    // Shut the door.
    else
    {
        AssignCommand (oDoor, ActionCloseDoor (oDoor));
        // Check to see if the door needs locked.
        //CheckForLock (oDoor, nLevel);
        // Check to see if the door is trapped.
        //CheckForTrap (oDoor, nLevel);
    }
}

// Save encounters to DB
// Notice this will over write previously saved encounter.
// oDM is the DM's encounters to be saved.
void SaveDMEncounters (object oDM)
{
    /*/ Save encounters.
    int iIndex = 1;
    object oCreature, oWaypoint = GetWaypointByTag ("Encounter1");
    location lLocation = GetLocation (oWaypoint);
    while (iIndex < 51)
    {
        oCreature = GetNearestCreatureToLocation (CREATURE_TYPE_IS_ALIVE, TRUE, lLocation, iIndex);
        SetPersistentCreature (oDM, 0, iIndex, oCreature);
        iIndex ++;
    } */
}

// Load encounters from DB
// Note this will erase all encounters in the encounter area.
// oDM is the DM's encounters to be loaded.
void LoadDMEncounters (object oDM)
{
    /*location lLocation;
    // Clear encounter area.
    object oCreature, oWaypoint = GetWaypointByTag ("Encounter1");
    ClearArea (GetArea (oDM));
    // Load encounters.
    int iIndex = 1;
    while (iIndex < 51)
    {
        GetPersistentCreature (oDM, 0, iIndex);
        iIndex ++;
    } */
}

string CreateAreaTag (int nX, int nY, int nZ)
{
    string sX, sY, sZ;
    // Make sure to add the lead 0's
    sX = IntToString (nX);
    if (nX < 100) sX = "0" + sX;
    if (nX < 10) sX = "0" + sX;
    sY = IntToString (nY);
    if (nY < 100) sY = "0" + sY;
    if (nY < 10) sY = "0" + sY;
    // Check to see if we should add Z to the tag.
    if (nZ > 0)
    {
        sZ = IntToString (nZ);
        if (nZ < 10) sZ = "0" + sZ;
        // Add the z/level to the area tag.
        return sX + "_" + sY + "_" + sZ;
    }
    // Create the area tag.
    else return sX + "_" + sY;
 }

// Transitions a creature from one transition to another.
// If the area does not exist it will try to generate it.
// oCreature is the creature that is transitioning.
void Transition(object oCreature)
{
    string sOldAreaTag, sNewAreaTag, sTransitionTag;
    object oOldArea, oNewArea, oTarget;
    location lLocation;
    float fFacing;
    object oTransition = GetLocalObject (oCreature, "Move_Tran");
    // Clear the Move counter.
    DeleteLocalInt(oCreature, "Move_Count");
    // No Transition object means this is an overland transition.
    if (oTransition == OBJECT_INVALID)
    {
        float fX = GetLocalFloat (oCreature, "Move_X"); // X location we clicked.
        float fY = GetLocalFloat (oCreature, "Move_Y"); // Y location we clicked.
        float fZ = GetLocalFloat (oCreature, "Move_Z"); // Z location we clicked.
        fFacing = GetLocalFloat (oCreature, "Move_Face"); // The way we are facing.
        oOldArea = GetLocalObject (oCreature, "Move_Area"); // Area we are in.
        // Get the coordinates of the area so we can find the new area.
        // The coordinates are built into the tags of the areas.
        sOldAreaTag = GetTag (oOldArea);
        // Get the X,Y,Z of the current area using "100_100_01".
        int nZ;
        int nX = StringToInt (GetStringLeft (sOldAreaTag, 3));
        string sY = GetSubString (sOldAreaTag, 4, 3);
        int nY = StringToInt (sY);
        if (GetStringLength (sOldAreaTag) == 10) nZ = StringToInt (GetStringRight (sOldAreaTag, 2));
        else nZ = 0;
        // Get the X/Y that is at the edge.
        float fMoveX = fX;
        float fMoveY = fY;
        if (fMoveX < 2.1f) { nX--; fMoveX = 119.0f; }
        else if (fMoveX > 117.9f) { nX++; fMoveX = 1.0f; }
        else if (fMoveY < 2.1f) { nY++; fMoveY = 119.0f; }
        else if (fMoveY > 117.9f) { nY--; fMoveY = 1.0f; }
        else
        {
            SetModuleError ("ERROR", "0i_area", "516", GetName (oCreature) + " is not at the " +
                            "edge of the map! [fMoveX: " + FloatToString (fMoveX, 0, 2) +
                            " fMoveY: " + FloatToString (fMoveY, 0, 2));
            return;
        }
        //Debug ("0e_oi_walk_wp_b", "521", "nX: " + IntToString (nX) + " nY: " + IntToString (nY) + " nZ: " + IntToString (nZ));
        // Now get the new area.
        sNewAreaTag = CreateAreaTag (nX, nY, nZ);
        // Get the area to see if it already exists.
        oNewArea = GetObjectByTag (sNewAreaTag);
        // If the area is invalid then create the area based on the overland.2da.
        if (oNewArea == OBJECT_INVALID)
        {
            oNewArea = GenerateArea (sNewAreaTag);
            // If the generated area is invalid then exit.
            if (oNewArea == OBJECT_INVALID)
            {
                string sZ;
                if (nZ > 0) sZ = IntToString (nZ);
                else sZ = "";
                SetModuleError ("TAG", "0i_area", "536", "New Area Tag is invalid [" +
                                sNewAreaTag + "]" + " Original area:" +
                                GetName (oOldArea) + " [" +  sOldAreaTag + "] " +
                                " Overland text: " + Get2DAString ("overland" + sZ, IntToString (nX), nY) + ".");
                return;
            }
        }
        fFacing = GetFacing (oCreature);
        vector vPosition = Vector (fMoveX, fMoveY, fZ);
        lLocation = Location (oNewArea, vPosition, fFacing);
    }
    // We have a transition object so lets use it to transition the creature.
    else
    {
        oTarget = GetTransitionTarget (oTransition);
        sTransitionTag = GetLocalString (oCreature, "Move_Tag");
        // Check to see if a specific location tag has been set.
        if (sTransitionTag == "") sTransitionTag = GetLocalString (oTransition, "0_TransitionTag");
        // If we have a tag then get the object to transition too.
        //Debug ("0i_area", "507", "oTarget: " + GetTag (oTarget) + " oTransition: " + GetTag (oTransition));
        if (sTransitionTag != "")
        {
            // Check in the same area before we branch out to other areas.
            // Secret passages all use the same tag!
            oTarget = GetNearestObjectByTag (sTransitionTag);
            if (oTarget == OBJECT_INVALID) oTarget = GetObjectByTag (sTransitionTag);
            if (oTarget == OBJECT_INVALID)
            {
                SetModuleError ("TAG", "0i_area", "516", "Transition Tag is invalid [" +
                                sTransitionTag + "] for " + GetName (oNewArea) + " [" +
                                GetTag (oNewArea) + "].");
                return;
            }
            oNewArea = GetArea (oTarget);
        }
        // If there is no transition target this must be a directional transition.
        // i.e. North, South, East, West, Up, or Down.
        else if (oTarget == OBJECT_INVALID)
        {
            // Get the coordinates of the area so we can find the new area.
            oOldArea = GetArea (oTransition);
            // The coordinates are built into the tags of the areas.
            sOldAreaTag = GetTag (oOldArea);
            // Get the X,Y,Z of the current area using "100_100_01".
            int nX = StringToInt (GetStringLeft (sOldAreaTag, 3));
            string sY = GetSubString (sOldAreaTag, 4, 3);
            int nY = StringToInt (sY);
            int nZ;
            if (GetStringLength (sOldAreaTag) == 10) nZ = StringToInt (GetStringRight (sOldAreaTag, 2));
            else nZ = 0;
            // Get the tag of the Trigger or Door it defines how we change the coordinates.
            sTransitionTag = GetTag (oTransition);
            // Adjust the x,y based on the triggers tag North, South, East, West, Up, Down.
            if (sTransitionTag == "North") { nY--; sTransitionTag = "South"; }
            else if (sTransitionTag == "South") { nY++; sTransitionTag = "North"; }
            else if (sTransitionTag == "East") { nX++; sTransitionTag = "West"; }
            else if (sTransitionTag == "West") { nX--; sTransitionTag = "East"; }
            else if (sTransitionTag == "Down") { nZ++; sTransitionTag = "Up"; }
            else if (sTransitionTag == "Up") { nZ--; sTransitionTag = "Down"; }
            // Now get the new area.
            sNewAreaTag = CreateAreaTag (nX, nY, nZ);
            // get the area to see if it already exists.
            oNewArea = GetObjectByTag (sNewAreaTag);
            // If the area is invalid then create the area based on the overland.2da.
            if (oNewArea == OBJECT_INVALID)
            {
                oNewArea = GenerateArea (sNewAreaTag);
                // If the generated area is invalid then exit.
                if (oNewArea == OBJECT_INVALID)
                {
                    SetModuleError ("TAG", "0i_area", "558", "Area Tag is invalid [" + sNewAreaTag + "]");
                    return;
                }
            }
            oTarget = GetObjectInAreaByTag (oNewArea, sTransitionTag, 1, OBJECT_TYPE_ALL, TRUE);
        }
        else oNewArea = GetArea (oTarget);
        // If we have a transition target get the location to it.
        lLocation = GetLocation (oTarget);
        fFacing = GetFacing (oTarget);
    }
    //Debug ("0i_area", "618", "Transition: oTarget: " + GetTag (oTarget) + " oTransition: " +
    //       GetTag (oTransition) + " Location: " + LocationToStringArray (lLocation));
    //************************ Code to transition players **********************
    // If it is a different area then some things need to be done.
    if (oNewArea != GetArea (oCreature)) AdjustMoonPhase (oNewArea, oCreature);
    // Face our target.
    AssignCommand (oCreature, SetFacing (fFacing));
    // Make sure to clear all actions before the jump.
    AssignCommand (oCreature, ClearAllActions ());
    // If going to a door use object instead of location and open the door!
    if (GetObjectType (oTarget) == OBJECT_TYPE_DOOR)
    {
        //Debug ("0i_area", "581", " oTransition: " + GetName (oTransition) + " Transition Tag: " + GetTag (oTransition));
        //Debug ("0i_area", "582", " oTarget: " + GetName (oTarget) + " Target Tag: " + GetTag (oTarget));
        // Does not work as the door is shut when a new area is generated.
        // if (!GetIsOpen (oTarget)) DelayCommand (1.0, AssignCommand (oTarget, PlayAnimation (ANIMATION_DOOR_OPEN1)));
        AssignCommand (oCreature, JumpToObject (oTarget));
        DelayCommand (1.0, JumpFollowingPCsToObject (oCreature, oTarget));
    }
    else
    {
        // Jump them via location.
        AssignCommand (oCreature, JumpToLocation (lLocation));
        DelayCommand (1.0, JumpFollowingPCsToLocation (oCreature, lLocation));
    }
    // If we are moving to a location in the same area we need to move associates too!
    if (oNewArea == GetArea (oCreature)) MoveAssociates (oCreature, oTarget);
}

// Check a loaded player and moves them to the correct location based
// upon where they were saved last.
// oPC is the pc to move.
// sWaypoint is the tag of the waypoint to jump to.
// sWaypoint is "" then it will move them to the last database save location.
void MovePlayer (object oPC, string sWaypoint = "")
{
    int nX, nY, nZ, iAreaInvalid = FALSE;
    string sLocation, sAreaTag, sMap, sZ;
    location lLocation;
    object oArea, oWaypoint;
    // If there is no Waypoint then load the players location.
    if (sWaypoint == "")
    {
        // Get the PC's saved location.
        if (GetIsDM (oPC)) sLocation = GetServerDatabaseString (oPC, DM_TABLE, "location");
        else sLocation = GetObjectDatabaseString (oPC, CHARACTER_TABLE, "location");
        // If no database location then default to the starting positions.
        if (sLocation != "")
        {
            lLocation = StringArrayToLocation (sLocation);
            // Check if the area saved for the PC is valid.
            oArea = GetAreaFromLocation (lLocation);
            // Check if it is invalid and if so lets see if this is a generated area.
            if (!GetIsObjectValid (oArea))
            {
                sAreaTag = GetStringArray (sLocation, 0);
                // This is a generated area so lets generate it.
                nX = StringToInt (GetStringLeft (sAreaTag, 3));
                nY = StringToInt (GetSubString (sAreaTag, 4, 3));
                if (GetStringLength (sAreaTag) > 7) nZ = StringToInt (GetStringRight (sAreaTag, 2));
                // Now get the new area.
                oArea = GenerateArea (CreateAreaTag (nX, nY, nZ));
                // If the generated area is not valid then go to a default location.
                if (!GetIsObjectValid (oArea)) iAreaInvalid = TRUE;
                // Reset the location so they will jump.
                lLocation = StringArrayToLocation (sLocation);
            }
        }
        else iAreaInvalid = TRUE;
    }
    else
    {
        oWaypoint = GetWaypointByTag (sWaypoint);
        if (!GetIsObjectValid (oWaypoint))
        {
            // We have an error and we need to send them  to the default respawn location.
            iAreaInvalid = TRUE;
            SetModuleError  ("WAYPOINT", "0i_character", "125", "Incorrect waypoint: " + sWaypoint);
        }
        lLocation = GetLocation (oWaypoint);
        oArea = GetArea (oWaypoint);
    }
    // If the area is invalid then send them to the starting positions.
    if (iAreaInvalid)
    {
        // Send them to a default location.
        // Check if they are a DM then send to Cynosure else default respawn.
        if (GetIsDM (oPC)) lLocation = GetLocation (GetWaypointByTag (WP_CYNOSURE));
        else lLocation = GetLocation (GetWaypointByTag (WP_DEFAULT_RESPAWN));
    }
    AdjustMoonPhase (oArea, oPC);
    // Move the player to the correct location.
    AssignCommand (oPC, JumpToLocation (lLocation));
}

// Generates an area from the overland.2da file based on X,Y and Z area tag.
// sAreaTag is the tag of the are to generate using X_Y_Z example 090_100_01
object GenerateArea (string sAreaTag)
{
    string sZ, sOverlandArray, sName, sEncounter, sTileType;
    int iMinLevel, iMaxLevel;
    object oArea, oAreaInformation;
    // Get the X,Y,Z of the current area using "100_100_01".
    string sX = IntToString (StringToInt (GetStringLeft (sAreaTag, 3)) - 50);
    int nY = StringToInt (GetSubString (sAreaTag, 4, 3)) - 50;
    if (GetStringLength (sAreaTag) == 10) sZ = GetStringRight (sAreaTag, 2);
    else sZ = "";
    // Get the overland.2da data for the area we are looking for.
    // Adjust the xy axis to the 2da line numbers.
    sOverlandArray = Get2DAString ("overland" + sZ, sX, nY);
    // Check to see if there is an overland area.
    if (sOverlandArray != "****" && sOverlandArray != "")
    {
        // Get the name of the area.
        sName = GetStringArray (sOverlandArray, 0);
        // Get the Minimum Level
        iMinLevel = StringToInt (GetStringArray (sOverlandArray, 1));
        // Get the Maximum Level
        iMaxLevel = StringToInt (GetStringArray (sOverlandArray, 2));
        // Get the encounter.
        sEncounter = GetStringArray (sOverlandArray, 3);
        // Get the TileType.
        sTileType = GetStringArray (sOverlandArray, 4);
        // Create the new area.
        oArea = CreateArea (sTileType, sAreaTag, sName);
        // Check to see if the area generated.
        if (!GetIsObjectValid (oArea))
        {
            SetModuleError ("AREA", "0i_area", "733", "Area did not generate: " + sX + "," + IntToString (nY + 50) + "[" + sOverlandArray + "]");
            return OBJECT_INVALID;
        }
        // Now get the area level information point.
        oAreaInformation = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        // Change encounter if we need to.
        if (sEncounter != "") SetLocalString (oAreaInformation, "0_Encounter", sEncounter);
        // Change the levels for this area.
        SetLocalInt (oAreaInformation, "0_Min_Level", iMinLevel);
        SetLocalInt (oAreaInformation, "0_Max_Level", iMaxLevel);
        return oArea;
    }
    else return OBJECT_INVALID;
}

// Send the areas diffculty to the entering player.
// oPlayer is the player to send the message to.
// oArea is the area to check difficulty of.
void SendDifficultyMessage(object oPlayer, object oArea)
{
    // Lets inform the PC of how difficult the area is.
    int iLevel = GetLocalInt(oArea, "0_Area_Level");
    // Should use code as follows.
    if(GetIsDungeonMaster (oPlayer)) SendMessages (GetName (oArea) + "[" + GetTag (oArea) + "] has an area level of " + IntToString (iLevel), COLOR_GRAY, oPlayer, FALSE, FALSE);
    // Do not send difficulty message if level is 0 or the area is set to no difficulty.
    else if(iLevel > 0 && !GetLocalInt (oArea, "0_No_Difficulty"))
    {
        int iPCLevel = GetCharacterLevels(oPlayer);
        int iDifficulty = iLevel - iPCLevel;
        string sDifficulty, sColor;
        // Lets get the difficulty and color for it.
        if (iDifficulty < -2) { sDifficulty = "Effortless"; sColor = COLOR_WHITE; }
        else if (iDifficulty < 0) { sDifficulty = "Easy"; sColor = COLOR_GREEN; }
        else if (iDifficulty < 2) { sDifficulty = "Moderate"; sColor = COLOR_DARK_BLUE; }
        else if (iDifficulty < 4) { sDifficulty = "Challenging"; sColor = COLOR_YELLOW; }
        else if (iDifficulty < 6) { sDifficulty = "Very Difficult"; sColor = COLOR_ORANGE; }
        else if (iDifficulty < 8) { sDifficulty = "Overpowering"; sColor = COLOR_RED; }
        else { sDifficulty = "Impossible"; sColor = COLOR_DARK_MAGENTA;}
        // Now send the message.
        SendMessages(GetName (oArea) + " will be " + sDifficulty + " for you.", sColor, oPlayer);
        if(iLevel > 20) SendMessages("This is an Epic level area!", sColor, oPlayer);
    }
    else
    {
        SendMessages ("Welcome to " + GetName (oArea) + ".", COLOR_GREEN, oPlayer);
        ExploreAreaForPlayer (oArea, oPlayer);
    }
}

// Move associates of oMaster to oTarget
void MoveAssociates (object oMaster, object oTarget)
{
    object oAssociate;
    int nType, i;
    for (nType = 1; nType <= 5; nType++)
    {
        i = 1;
        oAssociate = GetAssociate (nType, oMaster, i);
        while (GetIsObjectValid (oAssociate))
        {
            // Make sure they are not standing ground.
            if (!GetAssociateMode (MODE_STAND_GROUND, oAssociate))
            {
                AssignCommand (oAssociate, ClearAllActions());
                //Debug ("0i_area", "798", GetName (oAssociate) + " =========> Setting Combat round to 0.");
                AssignCommand (oAssociate, JumpToObject (oTarget));
                MoveAssociates (oAssociate, oTarget);
            }
            oAssociate = GetAssociate (nType, oMaster, ++i);
        }
    }
    // Check for players who might be following.
    // Cycle through all followers.
    int nCount = 1;
    object oFollower = GetLocalObject (oMaster, "0_Follower_" + IntToString (nCount));
    while (GetIsObjectValid (oFollower) && nCount <= 10)
    {
        AssignCommand (oFollower, ClearAllActions());
        AssignCommand (oFollower, JumpToObject (oTarget));
        nCount ++;
        oFollower = GetLocalObject (oMaster, "0_Follower_" + IntToString (nCount));
    }
}

// Save a characters pins on the map.
void LoadCharacterPins (object oPC)
{
    int nX, nY, nZ, nAdded;
    string sEntry, sAreaTag, sCheck, sY, sPinID;
    float fXPos, fYPos;
    object oArea;
    // Get pin data.
    sqlquery sql = SqlPrepareQueryObject (oPC, "SELECT areatag, xpos, ypos, entry FROM " + PIN_TABLE + ";");
    while (SqlStep(sql))
    {
        // Get the area to see if it already exists.
        sAreaTag = SqlGetString (sql, 0);
        oArea = GetObjectByTag (sAreaTag);
        // If the area is invalid then create the area based on the overland.2da.
        if (oArea == OBJECT_INVALID)
        {
            // Get the X,Y,Z of the current area using "100_100_01".
            nX = StringToInt (GetStringLeft (sAreaTag, 3));
            sY = GetSubString (sAreaTag, 4, 3);
            nY = StringToInt (sY);
            if (GetStringLength (sAreaTag) == 10) nZ = StringToInt (GetStringRight (sAreaTag, 2));
            else nZ = 0;
            oArea = GenerateArea (CreateAreaTag (nX, nY, nZ));
        }
        if (oArea != OBJECT_INVALID)
        {
            nAdded ++;
            sPinID = IntToString (nAdded);
            fXPos = SqlGetFloat (sql, 1);
            fYPos = SqlGetFloat (sql, 2);
            sEntry = SqlGetString (sql, 3);
            SetLocalObject (oPC, "NW_MAP_PIN_AREA_" + sPinID, oArea);
            SetLocalFloat (oPC, "NW_MAP_PIN_XPOS_" + sPinID, fXPos);
            SetLocalFloat (oPC, "NW_MAP_PIN_YPOS_" + sPinID, fYPos);
            SetLocalString (oPC, "NW_MAP_PIN_NTRY_" + sPinID, sEntry);
            nX = FloatToInt (fXPos / 10.0f);
            nY = FloatToInt (fYPos / 10.0f);
            SetTileExplored (oPC, oArea, nX, nY, TRUE);
            SetTileExplored (oPC, oArea, nX + 1, nY, TRUE);
            SetTileExplored (oPC, oArea, nX + 1, nY + 1, TRUE);
            SetTileExplored (oPC, oArea, nX + 1, nY -1, TRUE);
            SetTileExplored (oPC, oArea, nX, nY + 1, TRUE);
            SetTileExplored (oPC, oArea, nX - 1, nY + 1, TRUE);
            SetTileExplored (oPC, oArea, nX - 1, nY, TRUE);
            SetTileExplored (oPC, oArea, nX - 1, nY -1, TRUE);
            SetTileExplored (oPC, oArea, nX, nY - 1, TRUE);
        }
    }
    SetLocalInt (oPC, "NW_TOTAL_MAP_PINS", nAdded);
}

// Jump any players setup to follow this PC with the PC using a target object.
// oPC is the PC to follow
// oTarget is the object to jump to.
void JumpFollowingPCsToObject (object oPC, object oTarget)
{
    // Cycle through all following players.
    int nCount = 1;
    object oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    while (nCount <= 10)
    {
        if (GetIsObjectValid (oFollower))
        {
            AssignCommand (oFollower ,JumpToObject (oTarget));
            if (GetArea (oTarget) == GetArea (oFollower)) MoveAssociates (oFollower, oTarget);
        }
        nCount ++;
        oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    }
}

// Jump any players setup to follow this PC with the PC using a location.
// oPC is the PC to follow
// lLocation is the location to jump to.
void JumpFollowingPCsToLocation (object oPC, location lLocation)
{
    // Cycle through all following players.
    int nCount = 1;
    object oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    while (nCount <= 10)
    {
        if (GetIsObjectValid (oFollower)) AssignCommand (oFollower ,JumpToLocation (lLocation));
        nCount ++;
        oFollower = GetLocalObject (oPC, "0_Follower_" + IntToString (nCount));
    }
}

// Cleans up the variables used to move creatures from area to area.
void DeleteMoveVariables (object oCreature)
{
    // variables incase we are still looking to transition to an edge.
    DeleteLocalFloat (oCreature, "Move_X"); // X location clicked.
    DeleteLocalFloat (oCreature, "Move_Y"); // Y location clicked.
    DeleteLocalFloat (oCreature, "Move_Z"); // Z location clicked.
    DeleteLocalFloat (oCreature, "Move_Face"); // The way we are facing.
    DeleteLocalObject (oCreature, "Move_Area"); // Area we are moving from.
    DeleteLocalLocation (oCreature, "Move_Loc"); // Location we need to move to before we transition.
    DeleteLocalObject (oCreature, "Move_Tran"); // Transition object with transition data.
    DeleteLocalString (oCreature, "Move_Tag"); // Transition tag if one needs to be forced.
}

// Delay transition until the creature is at the transition location.
// oCreature is the creature to wait to transition.
void WaitToTransition(object oCreature)
{
    // if we have run this script more than 30 times then exit.
    int nCounter = GetLocalInt(oCreature, "Move_Count");
    //Debug("0i_area", "937", "nCounter: " + IntToString (nCounter));
    if(nCounter < 30 && nCounter != 0)
    {
        object oTransition = GetLocalObject(oCreature, "Move_Tran");
        string sTag = GetLocalString(oCreature, "Move_Tag");
        // Get the distance from the transition
        location lClicked = GetLocalLocation(oCreature, "Move_Loc");
        float fDistance = GetDistanceBetweenLocations (GetLocation (oCreature), lClicked);
        //if(oTransition != OBJECT_INVALID) Debug("0i_area", "945", " oTransition: " + GetName (oTransition) +
        //   " sTag: " + sTag + " fDistance: " + FloatToString(fDistance, 0, 2));
        // if its more than 3.0 meters then wait.
        if(fDistance > 3.0f)
        {
            SetLocalInt (oCreature, "Move_Count", ++nCounter);
            DelayCommand (0.5f, WaitToTransition (oCreature));
        }
        // We are close enough so lets transition.
        else Transition(oCreature);
    }
    else
    {
        DeleteLocalInt(oCreature, "Move_Count");
        DeleteMoveVariables(oCreature);
    }
}

// nDmg is the number of damage dice to be rolled.
void CheckForMishapDamage (object oCreature, int nDmg)
{
    // We had a mishap!
    if (nDmg > 0)
    {
        effect eDmg = EffectDamage (d10(nDmg));
        ApplyEffectToObject (DURATION_TYPE_INSTANT, eDmg, oCreature);
    }
}

// Teleport to a specific location based on spell.
// oCaster is the one castinge teleport.
// sLocation is the location to teleport to.
// nSpell is the spell used. 976 Teleport, 977 Greater Teleport.
void Teleport(object oCaster, string sLocation, int nSpell, int nCasterLevel)
{
    // This defines where they will end up on a teleporting.
    // nAppear = 0 - On Target, 1 - Off Target, 2 - Near area.
    int nRoll, nDmg, nAppear = 0;
    string sRoll, sText, sColor;
    location lTeleport = StringArrayToLocation (sLocation);
    string sAreaTag = GetStringArray (sLocation, 0);
    object oArea = GetObjectByTag (sAreaTag);
    object oWP = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    // If the location has a blank section then it is not a location!
    // Teleport checks the casters knowledge of the area.
    if(nSpell == 976/*SPELL_TELEPORT*/)
    {
        // This is a known area (i.e. they typed it into the menu).
        if(GetStringArray (sLocation, 1) == "")
        {
            nRoll = d100();
            while(nAppear == 0)
            {
                // Save the first roll for our text string.
                if(sRoll == "") sRoll = IntToString(nRoll);
                if(nRoll < 89)
                {
                    nAppear = 1;
                    if(sColor == "") sColor = COLOR_GREEN;
                    if(sText == "") sText = "in the target area.";
                }
                else if(nRoll < 97) nAppear = 2;
                // Mishap!
                else
                {
                    sColor = COLOR_RED;
                    sText = "after a mishap!";
                    nDmg++;
                    nRoll = d20() + 80;
                }
            }
        }
        if(nAppear == 0)
        {
            // nLocationKnowledge = 1 - Studied (Saved Civilized area), 0 - Familiar(Saved Wild area).
            int nLocationKnowledge = 0;
            // Decide how knowledgeable the caster is with the area.
            // If the area is civilized then its Familiar, otherwise its Studied.
            if (GetIsObjectValid(oArea))
            {
                // A No difficulty area is a civilized area so we set it to
                // TRUE (1) if it is civilized.
                nLocationKnowledge = GetLocalInt(oWP, "0_No_Difficulty");
            }
            nRoll = d100();
            if(sRoll == "") sRoll = IntToString(nRoll);
            // Studied (TRUE).
            if(nLocationKnowledge)
            {
                while(nAppear == 0)
                {
                    if(nRoll < 98)
                    {
                        nAppear = 1;
                        if(sColor == "") sColor = COLOR_GREEN;
                        if(sText == "") sText = "in the target area.";
                    }
                    else if(nRoll < 100) nAppear = 2;
                    // Mishap!
                    else
                    {
                        sColor = COLOR_RED;
                        sText = "after a mishap!";
                        nDmg++;
                        nRoll = d20() + 80;
                    }

                }
            }
            // Familiar (FALSE).
            else
            {
                if(nRoll < 98) nAppear = 0;
                else if(nRoll < 100) nAppear = 1;
                else nAppear = 2;
            }
        }
    }
    else // Default : 977 - SPELL_GREATER_TELEPORT
    {
        sColor = COLOR_GREEN;
        sText = "in the area.";
        // This is a known area (i.e. they typed it into the menu).
        if(GetStringArray(sLocation, 1) == "") nAppear = 1;
    }
    // We are appearing in a nearby area.
    if(nAppear == 2)
    {
        // If it is a x_y_z location so randomize an above ground random location.
        if(GetSubString(sAreaTag, 3, 1) == "_")
        {
            // Get the x number and y number from the area tag example: "100_100_00"
            int nYR, nXR;
            int nY = StringToInt(GetSubString (sAreaTag, 4, 3));
            int nX = StringToInt(GetStringLeft (sAreaTag, 3));
            // Randomize the Y axis up or down.
            nRoll = d8();
            if(nRoll == 1) { nXR = --nX; nYR = --nY; }
            else if(nRoll == 2) { nXR = nX; nYR = --nY; }
            else if(nRoll == 3) { nXR = ++nX; nYR = --nY; }
            else if(nRoll == 4) { nXR = ++nX; nYR = nY; }
            else if(nRoll == 5) { nXR = ++nX; nYR = ++nY; }
            else if(nRoll == 6) { nXR = nX; nYR = ++nY; }
            else if(nRoll == 7) { nXR = --nX; nYR = ++nY; }
            else { nXR = --nX; nYR = nY; }
            // Adjust to match area tags with leading 0's.
            string sYR, sXR;
            if(nYR < 10) sYR = "00" + IntToString(nYR);
            else if(nYR < 100) sYR = "0" + IntToString(nYR);
            else sYR = IntToString(nYR);
            if(nXR < 10) sXR = "00" + IntToString(nXR);
            else if(nXR < 100) sXR = "0" + IntToString(nXR);
            else sXR = IntToString(nXR);
            // Recompile to get the area.
            sAreaTag = sXR + "_" + sYR;
            oArea = GetObjectByTag(sAreaTag);
        }
        // else it is a town area so lets pick a random town location!
        else
        {
            // Roll for a random area near the quest area.
            // Get the number of areas in the list from row 0.
            string sTownArea = GetLocalString(oWP, "0_Town_Area");
            // Make sure this area is a town area. If it is not then just
            // send them to the actual area.
            if(sTownArea != "")
            {
                int nRoll = StringToInt(Get2DAString("quest_list", sTownArea, 0));
                nRoll = Random (nRoll) + 1;
                // Get the area tag from the list.
                sAreaTag = Get2DAString("quest_list", sTownArea, nRoll);
                oArea = GetObjectByTag(sAreaTag);
            }
            // This is not a town area so just randomize the location as an off target.
            else
            {
                if(sColor == "") sColor = COLOR_RED;
                if(sText == "") sText = "off target!";
            }
        }
        if(sColor == "") sColor = COLOR_RED;
        if(sText == "") sText = "in another area!";
        nAppear = 1;
    }
    // Create the area so we can go there if it is not in the server.
    if(!GetIsObjectValid(oArea))
    {
        oArea = GenerateArea(sAreaTag);
        nAppear = 1;
    }
    if(!GetIsObjectValid(oArea))
    {
        SendMessages("Location does not exist. Teleport aborted!", COLOR_RED, oCaster);
        return;
    }
    int nTh = 1;
    // We are appearing on/off Target we do this after the area is found to be valid.
    if(nAppear == 0)
    {
        sColor = COLOR_GREEN;
        sText = "on target!";
    }
    // We must find a random location in the area.
    else if(nAppear == 1)
    {
        object oWP = GetObjectInAreaByTag(oArea, "ip_encounter", nTh, OBJECT_TYPE_WAYPOINT);
        while(oWP != OBJECT_INVALID)
        {
             oWP = GetObjectInAreaByTag(oArea, "ip_encounter", ++nTh, OBJECT_TYPE_WAYPOINT);
        }
        int nRoll = Random(nTh - 1) + 1;
        oWP = GetObjectInAreaByTag(oArea, "ip_encounter", nRoll, OBJECT_TYPE_WAYPOINT, TRUE);
        if(!GetIsObjectValid (oWP)) oWP = GetObjectInAreaByTag(oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
        lTeleport = GetLocation (oWP);
        if(sColor == "") sColor = COLOR_RED;
        if(sText == "") sText = "off target!";
    }
    // Setup teleport effects.
    effect eDisappear = EffectVisualEffect(VFX_DUR_GHOSTLY_PULSE);
    effect eImpact_str, eImpact_mid, eImpact_end, eDmg;
    float fDelay;
    location lLocation = GetLocation(oCaster);
    if(nSpell == 976/*SPELL_TELEPORT*/)
    {
        eImpact_str = EffectVisualEffect(1006);
        eImpact_mid = EffectVisualEffect(1007);
        eImpact_end = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDisappear, oCaster, 9.5f);
        DelayCommand(1.5f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact_str, oCaster));
        DelayCommand(2.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact_mid, oCaster));
        DelayCommand(4.5f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact_end, lLocation));
        DelayCommand(5.0f, AssignCommand(oCaster, JumpToLocation (lTeleport)));
        DelayCommand(6.5f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact_str, lTeleport));
        DelayCommand(7.0f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact_mid, lTeleport));
        DelayCommand(8.5f, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact_end, lTeleport));
        fDelay = 4.5f;
    }
    else /*977 - SPELL_GREATER_TELEPORT*/
    {
        eImpact_str = EffectVisualEffect(1008);
        eImpact_mid = EffectVisualEffect(1009);
        eImpact_end = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDisappear, oCaster, 10.0f);
        DelayCommand(1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact_str, oCaster));
        DelayCommand(1.5f, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact_mid, oCaster));
        DelayCommand(3.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lLocation));
        DelayCommand(5.0f, AssignCommand(oCaster, JumpToLocation (lTeleport)));
        DelayCommand(6.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_str, lTeleport));
        DelayCommand(6.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_mid, lTeleport));
        DelayCommand(7.5f, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lTeleport));
        fDelay = 3.5f;
    }
    if(sRoll != "") sRoll = " (" + sRoll + ")";
    DelayCommand(8.0f, SendMessages("You appear " + sText + sRoll, sColor, oCaster));
    DelayCommand(8.0f, CheckForMishapDamage(oCaster, nDmg));
    // Get the number of targets we can bring.
    // Count off Henchmen first.
    int nTargets = nCasterLevel / 3;
    eDisappear = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
    nTh = 1;
    object oTarget = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oCaster, nTh);
    while (oTarget != OBJECT_INVALID)
    {
        if(GetLocalInt(oTarget, PC_ASSOCIATE_TYPE) == ASSOCIATE_TYPE_HENCHMAN)
        {
            fDelay += 0.5;
            nTargets --;
            lLocation = GetLocation(oTarget);
            DelayCommand(fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lLocation));
            DelayCommand(fDelay + 1.0, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eDisappear, oTarget, 5.5f));
            DelayCommand(fDelay + 2.5, AssignCommand(oTarget, JumpToLocation (lTeleport)));
            DelayCommand(fDelay + 5.0, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, GetLocation (oTarget)));
            DelayCommand(fDelay + 5.0, CheckForMishapDamage (oTarget, nDmg));
        }
        oTarget = GetAssociate (ASSOCIATE_TYPE_HENCHMAN, oCaster, ++nTh);
    }
    // Finally if there are any targets left that we can bring check PC faction members.
    // These must be within 15' or 5 meters.
    oTarget = GetFirstFactionMember(oCaster);
    while(nTargets > 0 && oTarget != OBJECT_INVALID && oTarget != oCaster)
    {
        if(GetDistanceBetween(oCaster, oTarget) <= 5f && oTarget != oCaster)
        {
            fDelay += 0.5;
            nTargets --;
            lLocation = GetLocation(oTarget);
            DelayCommand(fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, lLocation));
            DelayCommand(fDelay + 1.0, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eDisappear, oTarget, 5.5f));
            DelayCommand(fDelay + 2.5, AssignCommand(oTarget, JumpToLocation (lTeleport)));
            DelayCommand(fDelay + 5.0, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpact_end, GetLocation (oTarget)));
            DelayCommand(fDelay + 5.0, CheckForMishapDamage (oTarget, nDmg));
        }
        oTarget = GetNextFactionMember(oCaster);
    }
}

