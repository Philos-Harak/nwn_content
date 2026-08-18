/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ac_0_comp_pouch
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Activate item script for component pouch.
 Used to check to turn off and on enhancing components for spells.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_items"
void main()
{
    object oUser = OBJECT_SELF;
    object oItem = GetLocalObject(oUser, "0_item");
    int bSwitch = !GetLocalInt(oUser, "0_Use_Enhancing_Component");
    string sText, sColor;
    if(bSwitch) 
    {
        sText = " will now use Enhancing Components.";
        sColor = COLOR_GREEN;
    }
    else 
    {
        sText = " will stop using Enhancing Components.";
        sColor = COLOR_RED;
    }
    if(GetIsCharacter(oUser)) SendMessages("You" + sText, sColor, oUser);
    else SendMessages(GetName(oUser) + sText , sColor, GetMaster(oUser));
    SetLocalInt(oUser, "0_Use_Enhancing_Component", bSwitch);
    object oPlayersHandBook = GetCreatureHasItem (oUser, "players_book");
    SetLocalInt(oPlayersHandBook, "0_Use_Enhancing_Component", bSwitch);
    SetLocalObject(oUser, COMPONENT_POUCH, oItem);  
    SendMessages("Only components in this pouch will be used with spells.", COLOR_GRAY, oUser);
}
