//::///////////////////////////////////////////////////
//:: X0_STARTCONV
//:: Start a conversation with the user
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/13/2003
//::///////////////////////////////////////////////////

void main()
{
    string sDescription;
    // Get the PC that is clicking on the description.
    object oPC;
    oPC = GetPlaceableLastClickedBy ();
    // Get the description from the placeable.
    sDescription = GetLocalString (OBJECT_SELF, "0_Description");
    FloatingTextStringOnCreature (sDescription, oPC, FALSE);
}
