/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_no_enchant
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that cancels the enchantment process and cleans it up.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
void main()
{
    // Remove the enchanted item.
    DestroyObject (GetLocalObject (OBJECT_SELF, "0_enchanted_item"));
    // Clean up all variables.
    DeleteLocalObject (OBJECT_SELF, "0_enchanting_box");
    DeleteLocalObject (OBJECT_SELF, "0_enchanted_item");
    DeleteLocalObject (OBJECT_SELF, "0_Item_to_enchant");
    DeleteLocalInt (OBJECT_SELF, "0_Spell");
    DeleteLocalInt (OBJECT_SELF, "0_CasterClass");
    DeleteLocalInt (OBJECT_SELF, "0_GoldCost");
    DeleteLocalInt (OBJECT_SELF, "0_XPCost");
    DeleteLocalString (OBJECT_SELF, "0_enchant_column");
}
