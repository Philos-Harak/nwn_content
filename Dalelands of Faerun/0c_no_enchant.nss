/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_no_enchant
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Actions Taken script that cancels the enchantment process and cleans it up.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
void main()
{
    object oCaster = OBJECT_SELF;
    // Remove the enchanted item.
    DestroyObject(GetLocalObject (oCaster, "0_enchanted_item"));
    // Clean up all variables.
    DeleteLocalObject(oCaster, "0_enchanting_box");
    DeleteLocalObject(oCaster, "0_enchanted_item");
    DeleteLocalObject(oCaster, "0_Item_to_enchant");
    DeleteLocalInt(oCaster, "0_Spell");
    DeleteLocalInt(oCaster, "0_CasterClass");
    DeleteLocalInt(oCaster, "0_GoldCost");
    DeleteLocalInt(oCaster, "0_XPCost");
    DeleteLocalString(oCaster, "0_enchant_column");
    DeleteLocalObject(oCaster, "0_Component_to_enchant");
    DeleteLocalInt(oCaster, "0_Enhancement_Stack_Size");
}
