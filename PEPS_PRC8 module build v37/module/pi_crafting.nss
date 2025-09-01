/*//////////////////////////////////////////////////////////////////////////////
// Script Name: pi_crafting
////////////////////////////////////////////////////////////////////////////////
 Executable plug in script for Philos Module Extentions

 Crafting UI for players items.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_items"
#include "nw_inc_gff"

// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    // Set this variable on the player so PEPS can run the targeting script for this plugin.
    SetLocalString(oPC, AI_PLUGIN_TARGET_SCRIPT, "pe_crafting");
    // Set Targeting variables.
    SetLocalString(oPC, AI_TARGET_MODE, "SELECT_TARGET");
    ai_SendMessages("Select your charcter, a henchman or an item possessed by one.", AI_COLOR_YELLOW, oPC);
    EnterTargetingMode(oPC, OBJECT_TYPE_CREATURE | OBJECT_TYPE_ITEM , MOUSECURSOR_EXAMINE, MOUSECURSOR_NOEXAMINE);

}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_crafting"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Item Crafting"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("isk_x2cweap"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

