/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_trigsearch
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script for triggering a search check to do multiple things.
 This trigger will make a search check for any entering PC.
 This also adds a penalty (via a constant) if the pc is not actively searching.
 If the player is searching then they may make multiple searches.

 0_Search_DC - The DC for the search check.
 0_Convo if a conversation is put in this variable it will be started when a successful search is made.
 0_Message will display a message when the search is successful.
 If no conversation it will attempt to act like a spawn script.

 ** Spawns creatures, placeables, or effects based on waypoints in the area
 The waypoints will have a designation and then the tag of the trigger.
 Example: The trigger is called trap1
 To spawn creatures create waypoints with the tag: ip_encountertrap1
 To spawn placeables create waypoints with the tag: ip_placeabletrap1
 To spawn effects create waypoints with the tag: ip_effecttrap1

// May also change the area lighting with the following variables.
    0_lighting Tells the trigger to change the lighting.
    0_MainLight1Color sets the main light 1 for all tiles in area.
    0_MainLight2Color sets the main light 2 for all tiles in area.
    0_SourceLight1Color sets the source light 1 for all tiles in area.
    0_SourceLight2Color sets the source light 2 for all tiles in area.
    0_FogColor set the fog color, if set to -1 then will not change.

 This will spawn them at the time the trigger is crossed as if they where
 a normal spawn waypoint.
 Multiple triggers with the same tag will work as one trigger.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void main ()
{
    int iCheck, iDC, iBonus, iArea_Level;
    string sMessage, sConvo;
    // Get the PC who passed over this trigger.
    object oArea, oPC = GetEnteringObject ();
    // Skip if we are not a PC or henchmen.
    int nHenchmen = GetLocalInt(oPC, PC_ASSOCIATE_TYPE);
    if(GetIsCharacter (oPC) || nHenchmen == ASSOCIATE_TYPE_HENCHMAN)
    {
       // If the trigger has been used then set so we cannot trigger again until
       // the area is cleared.
       if (!GetLocalInt (OBJECT_SELF, "0_Populated"))
       {
          int nDetectDoors = GetHasSpellEffect(933/*SPELL_DETECT_SECRET_DOORS*/, oPC);
          // See if they have already searched here and are not in search mode.
          if (GetLocalInt (OBJECT_SELF, "0_search_" + GetName (oPC, TRUE)) > 0 &&
              GetDetectMode (oPC) == DETECT_MODE_PASSIVE &&
              !nDetectDoors) return;
          // Get the DC.
          iDC = GetLocalInt (OBJECT_SELF, "0_Search_DC");
          if (iDC == 0)
          {
              oArea = GetArea (oPC);
              iArea_Level = GetLocalInt (oArea, "0_Area_Level");
              iDC = BASE_SEARCH_DC + iArea_Level;
          }
          // See if they are in detect mode.
          if (GetDetectMode (oPC) == DETECT_MODE_PASSIVE) iBonus = PASSIVE_SEARCH_PENALTY;
          // Setup a cooldown of a short time.
          SetLocalInt (OBJECT_SELF, "0_search_" + GetName (oPC), TRUE);
          DelayCommand (FIVE_MINUTE_DELAY, DeleteLocalInt (OBJECT_SELF, "0_search_" + GetName (oPC)));
          // Can they automatically see this.
          // Sorcerer: Draconic Bloodline IV: Automatically find secret doors and treasure.
          // Has Detect secret doors spell effect.
          if (GetHasFeat (1333, oPC) || nDetectDoors) iCheck = 99;
          // else make skill check.
          else iCheck = GetSkillCheck (oPC, SKILL_SEARCH, FALSE, iBonus, iDC, FALSE);
          if (iCheck > -1)
          {
              int iCounter = 1;
              object oTrigger = GetNearestObjectByTag (GetTag (OBJECT_SELF), OBJECT_SELF, iCounter);
              if (nHenchmen == ASSOCIATE_TYPE_HENCHMAN) SendMessages (GetName (oPC) + " has found something!", COLOR_GRAY, GetMaster (oPC));
              while (GetIsObjectValid (oTrigger))
              {
                 SetLocalInt (oTrigger, "0_Populated", TRUE);
                 iCounter ++;
                 oTrigger = GetNearestObjectByTag (GetTag (OBJECT_SELF), OBJECT_SELF, iCounter);
              }
              // Check for Convo first.
              sConvo = GetLocalString (OBJECT_SELF, "0_Convo");
              if (sConvo != "")
              {
                  ActionStartConversation (oPC, sConvo, TRUE, FALSE);
                  // Now set all triggers with the same tag as Populated so we don't use it again.
                  // Note: 0e_trigspawn will set populated if used!
                  SetLocalInt (OBJECT_SELF, "0_Populated", TRUE);
              }
              // else run a script for this search.
              else
              {
                  // Check for message and display.
                  sMessage = GetLocalString (OBJECT_SELF, "0_Message");
                  // Play sound!
                  PlaySound ("sce_positive");
                  if (sMessage != "")
                  {
                    if (nHenchmen == ASSOCIATE_TYPE_HENCHMAN) SendMessages (sMessage, COLOR_GREEN, GetMaster (oPC), FALSE, FALSE);
                    SendMessages (sMessage, COLOR_GREEN, oPC, FALSE, FALSE);
                  }
                  ExecuteScript ("0e_trigspawn", OBJECT_SELF);
              }
          }
       }
    }
}

