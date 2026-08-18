/*//////////////////////////////////////////////////////////////////////////////
 Script: ac_0_mortar_pestle
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Activate item script for a mortar and pestle.
 Used to crush gems and other items into components.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
void main()
{
    object oPC = OBJECT_SELF;
    object oItem = GetSpellTargetObject ();
    string sResRef = GetResRef(oItem);
    sResRef = "d" + GetStringRight(sResRef, GetStringLength(sResRef) - 1);
    if(ResManGetAliasFor(sResRef, RESTYPE_UTI) == "")
    {
        SendMessages(GetName(oItem) + " cannot be turned into a component.", COLOR_RED, oPC);
        return;
    }
    int nGoldValue = GetGoldPieceValue(oItem);
    int nStackSize = nGoldValue / 25;
    string sText;
    object oComponent;
    if(GetItemStackSize(oItem) > 1) sText = "'s";
    while(nStackSize > 99)
    {
       oComponent = CreateItemOnObject(sResRef, oPC, 99);
       nStackSize -= 99;
    }
    if(nStackSize > 0) oComponent = CreateItemOnObject(sResRef, oPC, nStackSize);
    SendMessages("You have crafted your " + GetName(oItem) + sText + " into " + GetName(oComponent), COLOR_GREEN, oPC);
    DestroyObject(oItem);
}
