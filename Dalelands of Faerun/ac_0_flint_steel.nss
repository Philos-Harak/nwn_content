/*//////////////////////////////////////////////////////////////////////////////
 Script: ac_0_flint_steel
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Activate item script for Flint and steel.
 Used to create a camp fire.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
void CreateCampfire (location lLocation, object oCreature)
{
   object oItem = GetLocalObject (oCreature, "0_item");
   // Create campfire at location.
   string sCampfire = "0_campfire";
   object oPlaceable = CreateObject (OBJECT_TYPE_PLACEABLE, sCampfire, lLocation);
   ExecuteScript ("0e_uselight", oPlaceable);
   // Make it temporary.
   DestroyObject (oPlaceable, FIVE_MINUTE_DELAY);
}
void main()
{
   location lLocation = GetLocalLocation (OBJECT_SELF, "0_location");
   object oArea = GetAreaFromLocation (lLocation);
   if (GetIsAreaInterior (oArea))
   {
        SendMessages ("It is not a good idea to start a fire here!", COLOR_GRAY, OBJECT_SELF, FALSE, FALSE);
   }
   else
   {
       ActionMoveToLocation (lLocation);
       ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW);
       ActionDoCommand (CreateCampfire (lLocation, OBJECT_SELF));
   }
}
