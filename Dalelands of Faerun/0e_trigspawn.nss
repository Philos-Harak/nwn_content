/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigspawn
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that spawns objects when the character enters a trigger.
 ** Spawns creatures, placeables, or effects based on waypoints in the area
 The waypoints will have a designation and then the tag of the trigger.
 Example: The trigger is called 0_chest1
 To spawn creatures create waypoints with the tag: ip_encounter0_chest1
 To spawn placeables create waypoints with the tag: ip_placeable0_chest1
    Note if you set the following variables you can get additional effects for placeables.
    You can have an item randomly spawn in one of the placeables as long as they can have inventory.
    0_Resref - This will generate the resref item into one of the random placealbes set in the area.
    0_Num_Of_ResRef - This is needed help generate a random placeable to put the item into. If not set then uses 5.
    0_PlaceableTag - This is the tag of the placeables to randomize through.
 To spawn effects create waypoints with the tag: ip_effect0_trap1

 This will spawn them at the time the trigger is crossed as if they where
 a normal spawn waypoint.
 Multiple triggers with the same tag will work as one trigger.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "0i_area"
#include "0i_spawn"
void AddItemToRandomPlaceable (object oTrigger, string sResRef)
{
    object oPlaceable, oArea = GetArea (oTrigger);
    int iNumber, iRoll;
    string sPlaceableTag = GetLocalString (oTrigger, "0_PlaceableTag");
    // Pick a random placeable.
    iNumber = GetLocalInt (oTrigger, "0_Num_Of_ResRef");
    if (iNumber == 0) SetModuleError ("ERROR", "0e_trigspawn", "40", "0_Num_Of_ResRef is not set! Must be set!");
    // Get the first random placeable.
    iRoll = Random (iNumber) + 1;
    oPlaceable = GetObjectInAreaByTag  (oArea, sPlaceableTag, iRoll, OBJECT_TYPE_PLACEABLE, TRUE);
    while (!GetIsObjectValid (oPlaceable) && iNumber > 0)
    {
        iNumber --;
        iRoll = Random (iNumber) + 1;
        oPlaceable = GetObjectInAreaByTag (oArea, sPlaceableTag, iRoll, OBJECT_TYPE_PLACEABLE, TRUE);
    }
    if (iNumber < 1) SetModuleError ("ERROR", "0e_trigspawn", "50", "No placeable in " + GetName (oArea) + " found to place " + sResRef + " in!");
    else CreateItemOnObject (sResRef, oPlaceable);
}

// Cycles through all objects in the area spawning based on information point waypoints.
// oArea is the area to check from.
// oPC used in rolls.
// sType is a prefix to select trigger or special spawn waypoints.
// sNewTag is to change a placeables tag.
void CheckTriggerWaypoints (object oArea, object oPC, string sType = "", string sNewTag = "")
{
    int nIndex = 1;
    // Get the area's encounter waypoint used for all encounters in area.
    object oWPEncounter = GetObjectInAreaByTag (oArea, "ip_area_level", 1, OBJECT_TYPE_WAYPOINT, TRUE);
    int bNoDifficulty = GetLocalInt (oWPEncounter, "0_No_Difficulty");
    int nLevel = GetLocalInt (oArea, "0_Area_Level");
    object oObject = GetObjectInArea (oArea, nIndex);
    while (oObject != OBJECT_INVALID)
    {
        int nObjectType = GetObjectType (oObject);
        if (nObjectType == OBJECT_TYPE_WAYPOINT) CheckWaypoints (oPC, oObject, bNoDifficulty, nLevel, sType, sNewTag);
        nIndex ++;
        oObject = GetObjectInArea (oArea, nIndex);
    }
    // Just in case we changed a light.
    RecomputeStaticLighting (oArea);
}

void main ()
{
    string sResRef, sTag;
    // These can only be triggered by a player!!!!
    object oPlayer = GetEnteringObject ();
    // Skip if we are not a PC or henchmen.
    int nHenchmen = GetLocalInt(oPlayer, PC_ASSOCIATE_TYPE);
    if(GetIsCharacter (oPlayer) || nHenchmen == ASSOCIATE_TYPE_HENCHMAN)
   {
       // First lets make sure the trigger has not already been used.
       // We use a variable to define if it is or not.
       if (!GetLocalInt (OBJECT_SELF, "0_Populated"))
       {
           object oArea = GetArea (OBJECT_SELF);
           // Check to see if a DM has locked this area from being populated or cleared.
           if (GetLocalInt (GetArea (oPlayer), "0_PopulateOFF")) return;
           SetLocalInt (OBJECT_SELF, "0_Populated", TRUE);
           sTag = GetTag (OBJECT_SELF);
           // Now set any triggers with the same tag as populated so we don't over populate.
           int iCounter = 1;
           object oTrigger = GetObjectInAreaByTag  (oArea, sTag, iCounter, OBJECT_TYPE_TRIGGER);
           while (GetIsObjectValid (oTrigger))
           {
              SetLocalInt (oTrigger, "0_Populated", TRUE);
              iCounter ++;
              oTrigger = GetObjectInAreaByTag (oArea, sTag, iCounter, OBJECT_TYPE_TRIGGER);
           }
           // Check to see if we have an item to drop into a random placeable.
           sResRef = GetLocalString (OBJECT_SELF, "0_ItemResRef");
           // Now Spawn each type of object based on Waypoints.
           // Add a tag of the item resref to the placeables so we can randomize it later.
           int nLevel = GetLocalInt (oArea, "0_Area_Level");
           CheckTriggerWaypoints(oArea, oPlayer, GetTag(OBJECT_SELF), sResRef);
           // Check to see if we need to drop an item into a random placeable that can hold items.
           // Used for putting keys and/or other items to advance the party in an area.
           if (sResRef != "") DelayCommand (1.0f, AddItemToRandomPlaceable (OBJECT_SELF, sResRef));
       }
    }
}


