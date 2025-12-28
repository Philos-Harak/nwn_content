/*//////////////////////////////////////////////////////////////////////////////
 Script: ac_0_bedroll
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Activate item script for Bed Roll.
 Used to create a bed roll placeable.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_character"
#include "nwnx_player"
void CreateBed (location lLocation, object oCreature);
void UsePlaceableForRest (location lLocation, object oPC, object oPlaceable);

void main()
{
    location lLocation = GetLocalLocation (OBJECT_SELF, "0_location");
    ActionMoveToLocation (lLocation);
    ActionPlayAnimation (ANIMATION_LOOPING_GET_LOW);
    ActionDoCommand (CreateBed (lLocation, OBJECT_SELF));
}

void CreateBed (location lLocation, object oCreature)
{
    object oItem = GetLocalObject (oCreature, "0_item");
    // Check for magical bedrolls.
    string sResRef = GetResRef(oItem);
    string sBonus = GetStringRight(sResRef, GetStringLength (sResRef) - 10);
    int iBonus = StringToInt(sBonus) + 1;
    // create bedroll at location based on the bed roll they have.
    string sBed = "0_bedroll";
    object oPlaceable = CreateObject (OBJECT_TYPE_PLACEABLE, sBed, lLocation);
    SetLocalInt(oPlaceable, "0_PlaceableRest", iBonus);
    // Make it temporary.
    DestroyObject (oPlaceable, FIVE_MINUTE_DELAY);
}
