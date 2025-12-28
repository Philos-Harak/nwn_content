/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_dist_remains
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script on disturbed event for remains of a henchmen or NPC.
 Checks to see if the armor, helmet or body have been removed.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_position"
void main()
{
    object oCreature = GetLocalObject (OBJECT_SELF, "0_Remains_of_Creature");
    object oItem = GetInventoryDisturbItem ();
    string sItemTag = GetTag (oItem);
    // They have taken the body so remove the remains and visual body.
    if (sItemTag == "0_corpse")
    {
        location lLocation;
        object oLoot = GetFirstItemInInventory (OBJECT_SELF);
        while (oLoot != OBJECT_INVALID)
        {
            lLocation = GetRandomLocation (GetArea (oCreature), oCreature, 1.0f);
            CopyObject (oLoot, lLocation, OBJECT_INVALID, "", TRUE);
            DestroyObject (oLoot);
            oLoot = GetNextItemInInventory (OBJECT_SELF);
        }
        DestroyObject (OBJECT_SELF);
        AssignCommand (oCreature, SetIsDestroyable (TRUE, FALSE, FALSE));
        SetObjectVisualTransform (oCreature, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -50.0f);
    }
    // Do we need to remove the visual bodies equipment.
    {
        object oArmor = GetItemInSlot (INVENTORY_SLOT_CHEST, oCreature);
        object oHelmet = GetItemInSlot (INVENTORY_SLOT_HEAD, oCreature);
        object oCloak = GetItemInSlot (INVENTORY_SLOT_CLOAK , oCreature);
        string sItemName = GetName (oItem);
        if (sItemName == GetName (oArmor)) DestroyObject (oArmor);
        else if (sItemName == GetName (oHelmet)) DestroyObject (oHelmet);
        else if (sItemName == GetName (oCloak)) DestroyObject (oCloak);
    }
}

