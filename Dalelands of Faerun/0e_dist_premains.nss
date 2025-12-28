/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_dist_premains
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Runs the script on disturbed event for placeable remains.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_position"
void main()
{
    object oItem = GetInventoryDisturbItem ();
    string sItemTag = GetTag (oItem);
    // They have taken the body so remove the remains and visual body.
    if (sItemTag == "0_corpse")
    {
        location lLocation;
        object oLoot = GetFirstItemInInventory (OBJECT_SELF);
        while (oLoot != OBJECT_INVALID)
        {
            lLocation = GetRandomLocation (GetArea (OBJECT_SELF), OBJECT_SELF, 1.0f);
            CopyObject (oLoot, lLocation, OBJECT_INVALID, "", TRUE);
            DestroyObject (oLoot);
            oLoot = GetNextItemInInventory (OBJECT_SELF);
        }
        DestroyObject (OBJECT_SELF);
    }
}

