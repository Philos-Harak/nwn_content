/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_placeablerest
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnClick event that starts a players bed rest if they can rest from a placeable.
 0_PlaceableRest - sets the resting bonus per character level they get.
    999 = resting in an inn bed where you fully heal and don't use supplies.
 0_Key_Required - They must have this item (Tag) to rest on this placeable.
 0_Key_Message - If they do not have the proper item then send this message.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
void UsePlaceableForRest (object oPC, object oPlaceable);
void main ()
{
    object oPC = GetPlaceableLastClickedBy ();
    //location lLocation = GetLocation (OBJECT_SELF);
    //AssignCommand (oPC, ActionMoveToLocation (lLocation, TRUE));
    //AssignCommand (oPC, ActionPlayAnimation (ANIMATION_LOOPING_SIT_CROSS, 1.0f, 6.0f));
    UsePlaceableForRest (oPC, OBJECT_SELF);
}

void UsePlaceableForRest (object oPC, object oPlaceable)
{
    // Now check to see if they need a key.
    string sKeyRequired = GetLocalString (oPlaceable, "0_Key_Required");
    if (sKeyRequired != "")
    {
        object oItem = GetCreatureHasItem (oPC, sKeyRequired);
        // Remove the key and continue.
        if (GetIsObjectValid (oItem)) DestroyObject(oItem);
        // They don't have the proper key to rest.
        else
        {
            // Get the message from the object.
            string sMessage = GetLocalString (oPlaceable, "0_Key_Message");
            if (sMessage == "") sMessage = "You need a key to rest here!";
            SendMessages (sMessage, COLOR_RED, oPC, FALSE, FALSE);
            return;
        }
    }
    // Now have the character rest.
    SetLocalInt(oPC, USING_PLACEABLE_TO_REST, TRUE);
    AssignCommand(oPC, ActionRest ());
}




