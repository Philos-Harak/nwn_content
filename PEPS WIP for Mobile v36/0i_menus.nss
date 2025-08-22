/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_menus
////////////////////////////////////////////////////////////////////////////////
 Include script for handling NUI menus.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_nui"
#include "0i_associates"
// Mobile work around to allow the player to freeze the character when using the menus.
const string AI_FREEZE_OPTION = "AI_FREEZE_OPTION";

// Set one of the BTN_* "Widget" bitwise constants on oPlayer to bValid.
void ai_SetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_* "Widget" bitwise constants.
int ai_GetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Set one of the BTN_AI_*  bitwise constants on oPlayer to bValid.
void ai_SetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN_AI_* "Widget" bitwise constants.
int ai_GetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Set one of the BTN2_AI_*  bitwise constants on oPlayer to bValid.
void ai_SetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE);
// Return if nButton is set on oPlayer. Uses the BTN2_AI_* "Widget" bitwise constants.
int ai_GetAIButton2(object oPlayer, int nButton, object oAssociate, string sAssociateType);
// Creates the json array required to build a companion drop down box for
// Animal Companions or Familiars.
// sCompanion2da should be either "hen_companion" or "hen_familiar".
json ai_CreateCompanionJson(object oPC, string sCompanion2da);
// Return any Metamagic or Domain attributes to place on a spell icon image.
string ai_GetSpellIconAttributes(object oCaster, int nMetaMagic, int nDomain);
// Populates the Quick widget list menu.
void ai_PopulateWidgetList(object oPC, object oAssociate, int nToken, json jWidget);
// Creates the AI options menu.
void ai_CreateAIMainNUI(object oPC);
// Creates the AI options menu.
void ai_CreateAssociateCommandNUI(object oPC, object oAssociate);
// Creates an associates AI NUI.
void ai_CreateAssociateAINUI(object oPC, object oAssociate);
// Creates a widget for the player or associate.
void ai_CreateWidgetNUI(object oPC, object oAssociate);
// Creates the Loot filter menu.
void ai_CreateLootFilterNUI(object oPC, object oAssociate);
// Creates the Plugin Manager menu.
void ai_CreatePluginNUI(object oPC);
// Creates the Spell menu that selects the spells to go on the Spell Widget.
void ai_CreateQuickWidgetSelectionNUI(object oPC, object oAssociate);
// Creates the Spell menu that lets the player to select the associates castable spells.
void ai_CreateSpellMemorizationNUI(object oPC, object oAssociate);
// Creates the spell description menu so a player can see what a spell does.
void ai_CreateDescriptionNUI(object oPC, json jSpell, int nSpell = 0);

string ai_GetRandomTip()
{
    int nRoll;
    if(AI_SERVER) nRoll = Random(26);
    else nRoll = Random(44);
    return Get2DAString("ai_messages", "Text", nRoll);
}
void ai_SetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE)
{
    int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    if(bOn) nWidgetButtons = nWidgetButtons | nButton;
    else nWidgetButtons = nWidgetButtons & ~nButton;
    SetLocalInt(oAssociate, sWidgetButtonsVarname, nWidgetButtons);
    jButtons = JsonArraySet(jButtons, 0, JsonInt(nWidgetButtons));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
}
int ai_GetWidgetButton(object oPlayer, int nButton, object oAssociate, string sAssociateType)
{
    int nWidgetButtons = GetLocalInt(oAssociate, sWidgetButtonsVarname);
    return nWidgetButtons & nButton;
}
void ai_SetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType, int bOn = TRUE)
{
    int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
    json jButtons = ai_GetAssociateDbJson(oPlayer, sAssociateType, "buttons");
    if(bOn) nAIButtons = nAIButtons | nButton;
    else nAIButtons = nAIButtons & ~nButton;
    SetLocalInt(oAssociate, sAIButtonsVarname, nAIButtons);
    jButtons = JsonArraySet(jButtons, 1, JsonInt(nAIButtons));
    ai_SetAssociateDbJson(oPlayer, sAssociateType, "buttons", jButtons);
}
int ai_GetAIButton(object oPlayer, int nButton, object oAssociate, string sAssociateType)
{
    int nAIButtons = GetLocalInt(oAssociate, sAIButtonsVarname);
    return nAIButtons & nButton;
}
json ai_CreateAIScriptJson(object oPC)
{
    json jScript = JsonArrayInsert(JsonArray(), NuiComboEntry("", 0));
    int nNth = 1;
    string sScript = ResManFindPrefix("ai_a_", RESTYPE_NCS, nNth);
    while(sScript != "")
    {
        jScript = JsonArrayInsert(jScript, NuiComboEntry(sScript, nNth));
        sScript = ResManFindPrefix("ai_a_", RESTYPE_NCS, ++nNth);
    }
    return jScript;
}
json ai_CreateCompanionJson(object oPC, string sCompanion2da)
{
    int nCnt, nMaxRowCount = Get2DARowCount(sCompanion2da);
    string sName;
    json jCompanion = JsonArray();
    while(nCnt < nMaxRowCount)
    {
        sName = GetStringByStrRef(StringToInt(Get2DAString(sCompanion2da, "STRREF", nCnt)));
        jCompanion = JsonArrayInsert(jCompanion, NuiComboEntry(sName, nCnt++));
    }
    jCompanion = JsonArrayInsert(jCompanion, NuiComboEntry("Random", nCnt));
    return jCompanion;
}
string ai_GetSpellIconAttributes(object oCaster, int nMetaMagic, int nDomain)
{
    string sAttributeText;
    if(nMetaMagic != METAMAGIC_ANY && nMetaMagic != METAMAGIC_NONE)
    {
       if(nMetaMagic == METAMAGIC_EXTEND) sAttributeText = "X";
       if(nMetaMagic == METAMAGIC_EMPOWER) sAttributeText = "P";
       if(nMetaMagic == METAMAGIC_MAXIMIZE) sAttributeText = "M";
       if(nMetaMagic == METAMAGIC_QUICKEN) sAttributeText = "Q";
       if(nMetaMagic == METAMAGIC_SILENT) sAttributeText = "I";
       if(nMetaMagic == METAMAGIC_STILL) sAttributeText = "T";
    }
    else sAttributeText = "";
    if(nDomain > 0) sAttributeText += "D";
    return sAttributeText;
}
void ai_PopulateWidgetList(object oPC, object oAssociate, int nToken, json jWidget)
{
    int nSAIndex, nSpell, nClass, nFeat, nBaseItemType, nIprpSubType, nUses;
    int nLevel, nMetaMagic, nDomain, nIndex;
    string sIndex, sBaseName, sName, sSpellIcon, sText, sClass, sMetaMagicText;
    object oItem;
    json jSpell;
    while(nIndex < 10)
    {
        jSpell = JsonArrayGet(jWidget, nIndex);
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
        if(JsonGetType(jSpell) != JSON_TYPE_NULL)
        {
            nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
            nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
            nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
            if(nClass == -1) // This is an Item.
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                nBaseItemType = JsonGetInt(JsonArrayGet(jSpell, 3));
                nIprpSubType = JsonGetInt(JsonArrayGet(jSpell, 4));
                if(nSpell == SPELL_HEALINGKIT)
                {
                    sName = "Healer's Kit +" + IntToString(nIprpSubType);
                    sSpellIcon = "isk_heal";
                    sBaseName = "Healer's Kit";
                }
                else if(nBaseItemType == BASE_ITEM_ENCHANTED_SCROLL ||
                   nBaseItemType == BASE_ITEM_SCROLL ||
                   nBaseItemType == BASE_ITEM_SPELLSCROLL)
                {
                    sSpellIcon = Get2DAString("iprp_spells", "Icon", nIprpSubType);
                    sBaseName = "Scroll";
                }
                else
                {
                    if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                       nBaseItemType == BASE_ITEM_POTIONS) sBaseName = "Potion";
                    else if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
                            nBaseItemType == BASE_ITEM_MAGICWAND ||
                            nBaseItemType == FEAT_CRAFT_WAND) sBaseName = "Wand";
                    else sBaseName = ai_StripColorCodes(GetName(GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)))));
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                }
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                nUses = ai_GetItemUses(oItem, nIprpSubType);
                if(nUses)
                {
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                    if(nUses == 999) sText = "Unlimited";
                    else sText = IntToString(nUses);
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sBaseName + " / " + sText + ")"));
                }
            }
            else if(nFeat) // This is a feat.
            {
                sSpellIcon = "";
                if(nSpell)
                {
                    sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                }
                if(sSpellIcon == "" || sSpellIcon == "IR_USE")
                {
                    sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                    sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                }
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName));
            }
            else // This is a spell.
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                nLevel = JsonGetInt(JsonArrayGet(jSpell, 2));
                nMetaMagic = JsonGetInt(JsonArrayGet(jSpell, 3));
                nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                if(nClass == 255)
                {
                    nSAIndex = JsonGetInt(JsonArrayGet(jSpell, 6));
                    sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (Special Ability / " + IntToString(nLevel) + ")"));
                }
                else
                {
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevel) + ")"));
                    sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                    NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
                }
            }
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
        }
        ++nIndex;
    }
    if(nIndex < 10) return;
    // Row 6 Quick widget List2
    while(nIndex < 20)
    {
        jSpell = JsonArrayGet(jWidget, nIndex);
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
        if(JsonGetType(jSpell) != JSON_TYPE_NULL)
        {
            nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
            nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
            nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
            if(nClass == -1) // This is an Item.
            {
                string sBaseName;
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                int nBaseItemType = JsonGetInt(JsonArrayGet(jSpell, 3));
                int nIprpSubType = JsonGetInt(JsonArrayGet(jSpell, 4));
                if(nSpell == SPELL_HEALINGKIT)
                {
                    sName = "Healer's Kit +" + IntToString(nIprpSubType);
                    sSpellIcon = "isk_heal";
                    sBaseName = "Healer's Kit";
                }
                else if(nBaseItemType == BASE_ITEM_ENCHANTED_SCROLL ||
                   nBaseItemType == BASE_ITEM_SCROLL ||
                   nBaseItemType == BASE_ITEM_SPELLSCROLL)
                {
                    sSpellIcon = Get2DAString("iprp_spells", "Icon", nIprpSubType);
                    sBaseName = "Scroll";
                }
                else
                {
                    if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                       nBaseItemType == BASE_ITEM_POTIONS) sBaseName = "Potion";
                    else if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
                            nBaseItemType == BASE_ITEM_MAGICWAND ||
                            nBaseItemType == FEAT_CRAFT_WAND) sBaseName = "Wand";
                    else sBaseName = ai_StripColorCodes(GetName(GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)))));
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                }
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                int nUses = ai_GetItemUses(oItem, nIprpSubType);
                if(nUses)
                {
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                    if(nUses == 999) sText = "Unlimited";
                    else sText = IntToString(nUses);
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sBaseName + " / " + sText + ")"));
                }
            }
            else if(nFeat) // This is a feat.
            {
                sSpellIcon = "";
                if(nSpell)
                {
                    sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                }
                if(sSpellIcon == "" || sSpellIcon == "IR_USE")
                {
                    sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                    sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                }
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName));
            }
            else // This is a spell.
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                nLevel = JsonGetInt(JsonArrayGet(jSpell, 2));
                nMetaMagic = JsonGetInt(JsonArrayGet(jSpell, 3));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                if(nClass == 255)
                {
                    nSAIndex = JsonGetInt(JsonArrayGet(jSpell, 6));
                    if(GetSpellAbilityReady(oAssociate, nSAIndex))
                    {
                        sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (Special Ability / " + IntToString(nLevel) + ")"));
                    }
                }
                else
                {
                    NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevel) + ")"));
                    sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                    NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
                }
            }
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
        }
        ++nIndex;
    }
}
void ai_CreateAIMainNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int nMonsterAI = (ResManGetAliasFor("ai_default", RESTYPE_NCS) != "");
    int nAssociateAI = (ResManGetAliasFor("ai_a_default", RESTYPE_NCS) != "");
    string sText = " [Single player]";
    if(AI_SERVER) sText = " [Server]";
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, PHILOS_VERSION  + sText, "lbl_version ", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = CreateLabel(JsonArray(), "", "lbl_ai_info", 510.0f, 20.0f, NUI_HALIGN_CENTER);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 134
    jRow = CreateButton(JsonArray(), "Plugin Manager", "btn_plugin_manager", 166.0f, 25.0f, -1.0, "btn_plugin_manager_tooltip");
    jRow = CreateButtonSelect(jRow, "Ghost Mode", "btn_action_ghost", 166.0f, 25.0f, "btn_action_ghost_tooltip");
    jRow = CreateButton(jRow, "Close", "btn_close", 166.0f, 25.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 161
    //jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    //jRow = CreateLabel(jRow, "AI RULES", "lbl_ai_rules", 80.0f, 20.0f, NUI_HALIGN_CENTER);
    //jRow = JsonArrayInsert(jRow, NuiSpacer());
    //jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 134.0;
    // Row 5 ******************************************************************* 500 / --- (28)
    // Make the AI options a Group.
    json jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_max_henchman", 6, FALSE, 40.0f, 35.0f, "txt_max_henchman_tooltip");
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_max_hench_up", 35.0, 35.0, 0.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_max_hench_down", 35.0, 35.0, 0.0);
    jGroupRow = CreateLabel(jGroupRow, "Maximum henchmen that is allowed in your party.", "lbl_max_hench", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_max_henchman_tooltip");
    json jGroupCol = JsonArrayInsert(JsonArray(), NuiRow(jGroupRow));
    jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_xp_scale", 3, FALSE, 40.0f, 35.0f, "txt_xp_scale_tooltip");
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_xp_scale_up", 35.0, 35.0, 0.0);
    jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_xp_scale_down", 35.0, 35.0, 0.0);
    jGroupRow = CreateLabel(jGroupRow, "Module experience scale.", "lbl_xp_scale", 170.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_xp_scale_tooltip");
    jGroupRow = CreateCheckBox(jGroupRow, "scale to party.", "chbx_party_scale", 115.0, 35.0, "chbx_party_scale_tooltip");
    jGroupRow = CreateButton(jGroupRow, "Default", "btn_default_xp", 60.0f, 35.0f, -1.0, "btn_default_xp_tooltip");
    jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
    fHeight += 108.0;
    jGroupRow = JsonArray();
    if(nMonsterAI)
    {
        jGroupRow = CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_ai_difficulty", 6, FALSE, 40.0f, 35.0f, "txt_ai_difficulty_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_ai_diff_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_ai_diff_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "% chance monsters will attack the weakest target.", "lbl_ai_difficulty", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, -1.0, "txt_ai_difficulty_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Allow monsters to prebuff before combat starts.", "chbx_buff_monsters", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Allow monsters to use summons before combat starts.", "chbx_buff_summons", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Allow monsters to use tactics (ambush, defensive, etc).", "chbx_ambush_monsters", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        //jGroupRow = CreateCheckBox(JsonArray(), " Allow monsters to summon companions.", "chbx_companions", 450.0, 20.0);
        //jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Summoned associates to remain after masters death.", "chbx_perm_assoc", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_perception_distance", 6, FALSE, 40.0f, 35.0f, "txt_perception_distance_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_perc_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_perc_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "meters a monster can respond to allies.", "lbl_perception_distance", 370.0f, 35.0f, NUI_HALIGN_LEFT, 0, 0.0, "txt_perception_distance_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        //jGroupRow = CreateLabel(JsonArray(), "", "lbl_perc_dist", 450.0f, 20.0f, NUI_HALIGN_LEFT, 0, 0.0, "lbl_perc_dist_tooltip");
        //jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        //jGroupRow = CreateCheckBox(JsonArray(), " Make enemy corpses remain. ** This can break some modules! **", "chbx_corpses_stay", 490.0, 20.0);
        //jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Monsters can wander ", "chbx_wander", 175.0, 35.0, "chbx_wander_tooltip");
        jGroupRow = CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_wander_distance", 6, FALSE, 40.0f, 35.0f, "chbx_wander_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_wander_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_wander_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, " meters & ", "lbl_wander_distance", 70.0f, 35.0f, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "chbx_wander_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, "open doors.", "chbx_open_doors", 100.0, 35.0, "chbx_wander_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateLabel(JsonArray(), "Add ", "lbl_inc_enc", 30.0, 35.0, NUI_HALIGN_LEFT, 0, -1.0);
        jGroupRow = CreateTextEditBox(jGroupRow, "sPlaceHolder", "txt_inc_enc", 4, FALSE, 55.0f, 35.0f, "txt_inc_enc_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_encounter_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_encounter_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "monsters per spawned encounter monster.", "lbl_inc_enc", 325.0, 35.0, NUI_HALIGN_LEFT, NUI_VALIGN_MIDDLE, 0.0, "txt_inc_enc_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateTextEditBox(JsonArray(), "sPlaceHolder", "txt_inc_hp", 6, FALSE, 40.0f, 35.0f, "txt_inc_hp_tooltip");
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_up", "btn_inc_hp_up", 35.0, 35.0, 0.0);
        jGroupRow = CreateButtonImage(jGroupRow, "nui_cnt_down", "btn_inc_hp_down", 35.0, 35.0, 0.0);
        jGroupRow = CreateLabel(jGroupRow, "% increase in all monster's hitpoints.", "lbl_inc_percentage", 370.0, 35.0, NUI_HALIGN_LEFT);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        fHeight += 360.0;
    }
    if(nMonsterAI || nAssociateAI)
    {
        jGroupRow = CreateCheckBox(JsonArray(), " Allow creatures to use advanced combat movement.", "chbx_advanced_movement", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Use item level restrictions for creatures [Default is off].", "chbx_ilr", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Allow creatures to use the skill Use Magic Device.", "chbx_umd", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Allow creatures to use Healing kits.", "chbx_use_healingkits", 450.0, 20.0);
        jGroupRow = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateCheckBox(JsonArray(), " Moral checks, wounded creatures may flee during combat.", "chbx_moral", 450.0, 20.0);
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        jGroupRow = CreateLabel(JsonArray(), " Spells the AI will not use:", "lbl_restrict_spells", 190.0, 20.0, NUI_HALIGN_LEFT);
        jGroupRow = CreateCheckBox(jGroupRow, " Darkness", "chbx_darkness", 90.0, 20.0, "chbx_darkness_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, " Dispels", "chbx_dispels", 90.0, 20.0, "chbx_dispels_tooltip");
        jGroupRow = CreateCheckBox(jGroupRow, " Time Stop", "chbx_timestop", 90.0, 20.0, "chbx_timestop_tooltip");
        jGroupCol = JsonArrayInsert(jGroupCol, NuiRow(jGroupRow));
        fHeight += 168.0;
    }
    jRow = JsonArrayInsert(JsonArray(), NuiGroup(NuiCol(jGroupCol)));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, "pc", "locations");
    jLocations = JsonObjectGet(jLocations, AI_MAIN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, AI_MAIN_NUI, sName + " PEPS Main Menu",
                             fX, fY, 534.0f, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    object oModule = GetModule();
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1 - Version label.
    // Row 2
    int nUsing;
    // Check the monster AI.
    string sLocation = ResManGetAliasFor("ai_default", RESTYPE_NCS);
    if(sLocation != "")
    {
        nUsing = TRUE;
        string sLocation = ResManGetAliasFor("nw_c2_default1", RESTYPE_NCS);
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps36" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText = "Monster AI working";
        else sText = "Monster AI not working";
    }
    else sText = "Monster AI not loaded";
    // Check the associate AI.
    sLocation = ResManGetAliasFor("ai_a_default", RESTYPE_NCS);
    if(sLocation != "")
    {
        nUsing = TRUE;
        string sLocation = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS);
        if(sLocation != "OVERRIDE:" && sLocation != "PATCH:peps36" && sLocation != "DEVELOPMENT:") nUsing = FALSE;
        if(nUsing) sText += ", Associate AI working";
        else sText += ", Associate AI not working";
    }
    else sText += ", Associate AI not loaded";
    // Check for PRC.
    sLocation = ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS);
    if(sLocation != "") sText += ", PRC loaded.";
    else
    {
        // Check the player AI.
        sLocation = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS);
        if(sLocation != "") sText += ", Player AI loaded.";
        else sText += ", Player AI not loaded.";
    }
    NuiSetBind(oPC, nToken, "lbl_ai_info_label", JsonString(sText));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_plugin_manager_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_plugin_manager_tooltip", JsonString("  Manages external executable scripts."));
    int bActionGhost = ai_GetAIMode(oPC, AI_MODE_ACTION_GHOST);
    NuiSetBind(oPC, nToken, "btn_action_ghost", JsonBool (bActionGhost));
    NuiSetBind(oPC, nToken, "btn_action_ghost_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_action_ghost_tooltip", JsonString("  Allows associates to move through creatures while in command mode."));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 3 Label for AI RULES
    // Row 4
    NuiSetBind(oPC, nToken, "txt_max_henchman_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_max_hench_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_max_hench_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_max_henchman", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_MAX_HENCHMAN))));
    NuiSetBindWatch (oPC, nToken, "txt_max_henchman", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_henchman_tooltip", JsonString("  Set max number of henchman allowed in your party (1-12)."));
    NuiSetBind(oPC, nToken, "txt_xp_scale_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_xp_scale_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_xp_scale_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_xp_scale", JsonString(IntToString(GetModuleXPScale())));
    NuiSetBindWatch (oPC, nToken, "txt_xp_scale", TRUE);
    NuiSetBind(oPC, nToken, "txt_xp_scale_tooltip", JsonString("  Set the modules XP scale (0 - 200) Normal D&D is 10."));
    NuiSetBind(oPC, nToken, "chbx_party_scale_check", JsonBool(GetLocalInt(oModule, AI_RULE_PARTY_SCALE)));
    NuiSetBindWatch(oPC, nToken, "chbx_party_scale_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_party_scale_event", JsonBool(TRUE));
    sText = IntToString(GetLocalInt(oModule, AI_BASE_PARTY_SCALE_XP));
    NuiSetBind(oPC, nToken, "chbx_party_scale_tooltip", JsonString("  PEPS adjusts your XP based on party size from (" + sText + ")."));
    NuiSetBind(oPC, nToken, "btn_default_xp_event", JsonBool(TRUE));
    sText = IntToString(GetLocalInt(oModule, AI_RULE_DEFAULT_XP_SCALE));
    NuiSetBind(oPC, nToken, "btn_default_xp_tooltip", JsonString("  Reset the Modules XP to (" + sText + ")."));
    if(nMonsterAI)
    {
        NuiSetBind(oPC, nToken, "txt_ai_difficulty_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_diff_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_diff_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_ai_difficulty", JsonString(IntToString(GetLocalInt(oModule, AI_RULE_AI_DIFFICULTY))));
        NuiSetBindWatch(oPC, nToken, "txt_ai_difficulty", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_BUFF_MONSTERS)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_monsters_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_buff_summons_check", JsonBool(GetLocalInt(oModule, AI_RULE_PRESUMMON)));
        NuiSetBindWatch(oPC, nToken, "chbx_buff_summons_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_summons_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_check", JsonBool(GetLocalInt(oModule, AI_RULE_AMBUSH)));
        NuiSetBindWatch(oPC, nToken, "chbx_ambush_monsters_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ambush_monsters_event", JsonBool(TRUE));
        //NuiSetBind(oPC, nToken, "chbx_companions_check", JsonBool(GetLocalInt(oModule, AI_RULE_SUMMON_COMPANIONS)));
        //NuiSetBindWatch(oPC, nToken, "chbx_companions_check", TRUE);
        //NuiSetBind(oPC, nToken, "chbx_companions_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_check", JsonBool(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
        NuiSetBindWatch(oPC, nToken, "chbx_perm_assoc_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_perm_assoc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_perception_distance_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_perception_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_PERCEPTION_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_perception_distance", TRUE);
        NuiSetBind(oPC, nToken, "txt_perception_distance_tooltip", JsonString("  Range [10 to 60 meters] from the player."));
        NuiSetBindWatch(oPC, nToken, "lbl_perc_dist", TRUE);
        //int nPercDist = GetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE);
        //if(nPercDist < 8 || nPercDist > 11)
        //{
        //    nPercDist = 11;
        //    SetLocalInt(oModule, AI_RULE_MON_PERC_DISTANCE, 11);
        //}
        //if(nPercDist == 8) sText = " Monster perception: Short [10 Sight / 10 Listen]";
        //else if(nPercDist == 9) sText = " Monster perception: Medium [20 Sight / 20 Listen]";
        //else if(nPercDist == 10) sText = " Monster perception: Long [35 Sight / 20 Listen]";
        //else sText = " Monster perception: Default [Monster's default values]";
        //NuiSetBind(oPC, nToken, "lbl_perc_dist_label", JsonString(sText));
        //NuiSetBind(oPC, nToken, "lbl_perc_dist_tooltip", JsonString("  Use the mouse wheel to change values."));
        //NuiSetBind(oPC, nToken, "chbx_corpses_stay_check", JsonBool(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)));
        //NuiSetBindWatch(oPC, nToken, "chbx_corpses_stay_check", TRUE);
        //NuiSetBind(oPC, nToken, "chbx_corpses_stay_event", JsonBool(TRUE));
        int bWander = GetLocalInt(oModule, AI_RULE_WANDER);
        NuiSetBind(oPC, nToken, "chbx_wander_check", JsonBool(bWander));
        NuiSetBindWatch(oPC, nToken, "chbx_wander_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_wander_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_wander_distance_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "txt_wander_distance", JsonString(FloatToString(GetLocalFloat(oModule, AI_RULE_WANDER_DISTANCE), 0, 0)));
        NuiSetBindWatch(oPC, nToken, "txt_wander_distance", TRUE);
        NuiSetBind(oPC, nToken, "btn_wander_up_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "btn_wander_down_event", JsonBool(bWander));
        NuiSetBind(oPC, nToken, "chbx_open_doors_check", JsonBool(GetLocalInt(oModule, AI_RULE_OPEN_DOORS)));
        NuiSetBindWatch(oPC, nToken, "chbx_open_doors_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_open_doors_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_wander_tooltip", JsonString("  ** This can break some modules! **"));
        NuiSetBind(oPC, nToken, "txt_inc_enc_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_encounter_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_encounter_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_enc_tooltip", JsonString("  Spawns one extra monster per counter above 1. Adds value to counter per encounter monster spawned."));
        NuiSetBind(oPC, nToken, "txt_inc_enc", JsonString(FloatToString(GetLocalFloat(oModule, AI_INCREASE_ENC_MONSTERS), 0, 2)));
        NuiSetBindWatch(oPC, nToken, "txt_inc_enc", TRUE);
        NuiSetBind(oPC, nToken, "txt_inc_hp_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inc_hp_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inc_hp_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "txt_inc_hp", JsonString(IntToString(GetLocalInt(oModule, AI_INCREASE_MONSTERS_HP))));
        NuiSetBindWatch(oPC, nToken, "txt_inc_hp", TRUE);
    }
    if(nMonsterAI || nAssociateAI)
    {
        NuiSetBind(oPC, nToken, "chbx_moral_check", JsonBool(GetLocalInt(oModule, AI_RULE_MORAL_CHECKS)));
        NuiSetBindWatch (oPC, nToken, "chbx_moral_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_moral_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_advanced_movement_check", JsonBool(GetLocalInt(oModule, AI_RULE_ADVANCED_MOVEMENT)));
        NuiSetBindWatch (oPC, nToken, "chbx_advanced_movement_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_advanced_movement_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_ilr_check", JsonBool(GetLocalInt(oModule, AI_RULE_ILR)));
        NuiSetBindWatch (oPC, nToken, "chbx_ilr_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ilr_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_umd_check", JsonBool(GetLocalInt(oModule, AI_RULE_ALLOW_UMD)));
        NuiSetBindWatch (oPC, nToken, "chbx_umd_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_umd_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_use_healingkits_check", JsonBool(GetLocalInt(oModule, AI_RULE_HEALERSKITS)));
        NuiSetBindWatch (oPC, nToken, "chbx_use_healingkits_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_use_healingkits_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_darkness_check", JsonBool(ai_SpellRestricted(SPELL_DARKNESS)));
        NuiSetBindWatch (oPC, nToken, "chbx_darkness_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_darkness_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_darkness_tooltip", JsonString("  AI will not use the Darkness spell in combat."));
        NuiSetBind(oPC, nToken, "chbx_dispels_check", JsonBool(ai_SpellRestricted(SPELL_DISPEL_MAGIC)));
        NuiSetBindWatch (oPC, nToken, "chbx_dispels_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_dispels_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_dispels_tooltip", JsonString("  AI will not use any of the Dispel spells in combat."));
        NuiSetBind(oPC, nToken, "chbx_timestop_check", JsonBool(ai_SpellRestricted(SPELL_TIME_STOP)));
        NuiSetBindWatch (oPC, nToken, "chbx_timestop_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_timestop_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "chbx_timestop_tooltip", JsonString("  AI will not use the Time Stop spell in combat."));
    }
}
void ai_CreateAssociateCommandNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    int bIsPC = ai_GetIsCharacter(oAssociate);
    int bUsingPCAI = ResManGetAliasFor("xx_pc_1_hb", RESTYPE_NCS) != "";
    int bUsingHenchAI = ResManGetAliasFor("nw_ch_ac1", RESTYPE_NCS) != "";
    float fHeight = 73.0;
    // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArray();
    json jCol = JsonArray();
    if(bIsPC)
    {
        if(bUsingPCAI || !AI_SERVER)
        {
            if(bUsingPCAI)
            {
                jRow = CreateButton(jRow, "AI Menu", "btn_ai_menu", 125.0, 30.0, -1.0, "btn_ai_menu_tooltip");
            }
            jRow = CreateButtonSelect(jRow, "Freeze Player", "btn_freeze_player", 125.0, 30.0, "btn_freeze_player_tooltip");
            if(!AI_SERVER)
            {
                jRow = CreateButton(jRow, "Main Menu", "btn_main_menu", 125.0, 30.0, -1.0, "btn_main_menu_tooltip");
            }
            jRow = CreateButton(jRow, "Close", "btn_close", 125.0f, 30.0f);
            jCol = JsonArrayInsert(jCol, NuiRow(jRow));
            fHeight += 38.0;
        }
    }
    else
    {
        if(bUsingHenchAI)
        {
            jRow = CreateButton(jRow, "AI Menu", "btn_ai_menu", 168.0, 30.0, -1.0, "btn_ai_menu_tooltip");
        }
        jRow = CreateButtonSelect(jRow, "", "btn_widget_onoff", 168.0, 30.0, "btn_widget_onoff_tooltip");
        jRow = CreateButton(jRow, "Close", "btn_close", 168.0f, 30.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 2 ******************************************************************* 500 / 101
    jRow = CreateButtonSelect(JsonArray(), "Lock Widget", "btn_widget_lock", 168.0, 30.0, "btn_widget_lock_tooltip");
    jRow = CreateButtonSelect(jRow, "Vertical Widget", "btn_vertical_widget", 168.0, 30.0, "btn_vertical_widget_tooltip");
    jRow = CreateButton(jRow, "Copy Settings", "btn_copy_settings", 168.0, 30.0, -1.0, "btn_copy_settings_tooltip");
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 129
    if(bUsingHenchAI && bIsPC)
    {
        jRow = CreateButton(JsonArray(), "", "btn_toggle_assoc_widget", 230.0f, 30.0f, -1.0, "btn_toggle_assoc_widget_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_toggle_assoc_widget", 25.0, 30.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    // Row 4 ******************************************************************* 500 / 129
    jRow = CreateButton(JsonArray(), "", "btn_cmd_action", 230.0, 30.0, -1.0, "btn_cmd_action_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_action", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "", "btn_cmd_guard", 230.0, 30.0, -1.0, "btn_cmd_guard_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_guard", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 500 / 157
    jRow = CreateButton(JsonArray(), "", "btn_cmd_hold", 230.0, 30.0, -1.0, "btn_cmd_hold_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_hold", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "", "btn_cmd_attack", 230.0, 30.0, -1.0, "btn_cmd_attack_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_attack", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 500 / 185
    jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_follow_up", 30.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_follow_down", 30.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
    jRow = CreateButton(jRow, "", "btn_cmd_follow", 162.0, 30.0, -1.0, "btn_cmd_follow_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_follow", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_follow_up", 30.0, 30.0, -1.0, "btn_follow_target_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_follow_down", 30.0, 30.0, -1.0, "btn_follow_target_tooltip");
    jRow = CreateButton(jRow, "", "btn_follow_target", 162.0, 30.0, -1.0, "btn_follow_target_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_follow_target", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 190.0;
    // Row 7 ******************************************************************* 500 / ---
    if(bIsPC)
    {
        jRow = CreateButton(JsonArray(), "All Search Mode", "btn_cmd_search", 230.0, 30.0, -1.0, "btn_cmd_search_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_cmd_search", 25.0, 30.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "All Stealth Mode", "btn_cmd_stealth", 230.0, 30.0, -1.0, "btn_cmd_stealth_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_cmd_stealth", 25.0, 30.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 38.0;
    }
    // Row 8 ******************************************************************* 500 / ---
    jRow = CreateButton(JsonArray(), "", "btn_cmd_ai_script", 230.0, 30.0, -1.0, "btn_cmd_ai_script_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_ai_script", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Place a Trap", "btn_cmd_place_trap", 230.0, 30.0, -1.0, "btn_cmd_place_trap_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cmd_place_trap", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 9 ******************************************************************* 500 / ---
    int bMemorize = ai_GetIsSpellCaster(oAssociate);
    int bSpellbook = ai_GetIsSpellBookRestrictedCaster(oAssociate);
    jRow = CreateButton(JsonArray(), "Set Quick Widget", "btn_quick_widget", 230.0, 30.0, -1.0, "btn_quick_widget_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_quick_widget", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    if(bMemorize == 2 && bSpellbook)
    {
        jRow = CreateButton(jRow, "Memorize Spells", "btn_spell_memorize", 114.0, 30.0, -1.0, "btn_spell_memorize_tooltip");
        jRow = CreateButton(jRow, "Known Spells", "btn_spell_known", 110.0, 30.0, -1.0, "btn_spell_known_tooltip");
    }
    else if(bMemorize == 2) // Memorizes their spells.
    {
        jRow = CreateButton(jRow, "Set Memorized Spells", "btn_spell_memorize", 230.0, 30.0, -1.0, "btn_spell_memorize_tooltip");
        jRow = CreateLabel(jRow, "", "blank_label_1", 25.0, 30.0);
    }
    else if(bSpellbook && !ai_GetIsCharacter(oAssociate))
    {
        jRow = CreateButton(jRow, "Set Known Spells", "btn_spell_known", 230.0, 30.0, -1.0, "btn_spell_known_tooltip");
        jRow = CreateLabel(jRow, "", "blank_label_1", 25.0, 30.0);
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 10 ******************************************************************* 500 / ---
    jRow = CreateButton(JsonArray(), "Cast Short Buff spells", "btn_buff_short", 230.0, 30.0, -1.0, "btn_buff_short_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_buff_short", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Cast Long Buff spells", "btn_buff_long", 230.0, 30.0, -1.0, "btn_buff_long_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_buff_long", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 11 ****************************************************************** 500 / ---
    jRow = CreateButton(JsonArray(), "Cast All Buff spells", "btn_buff_all", 230.0, 30.0, -1.0, "btn_buff_all_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_buff_all", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "", "btn_buff_rest", 230.0, 30.0, -1.0, "btn_buff_rest_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_buff_rest", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 12 ******************************************************************* 500 / ---
    jRow = CreateButton(JsonArray(), "", "btn_jump_to", 230.0, 30.0, -1.0, "btn_jump_to");
    jRow = CreateCheckBox(jRow, "", "chbx_jump_to", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Ghost Mode", "btn_ghost_mode", 230.0, 30.0, -1.0, "btn_ghost_mode_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_ghost_mode", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Row 13 ****************************************************************** 500 / ---
    jRow = CreateButton(JsonArray(), "Toggle Camera Focus", "btn_camera", 230.0, 30.0, -1.0, "btn_camera_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_camera", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Open/Close Inventory", "btn_inventory", 230.0, 30.0, -1.0, "btn_inventory_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_inventory", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    /* DOES NOT WORK WITH VERSION 36!
    // Row 14 ****************************************************************** 500 / ---
    int bFamiliar = GetHasFeat(FEAT_SUMMON_FAMILIAR, oAssociate, TRUE);
    if(bFamiliar)
    {
        jRow = CreateLabel(JsonArray(), "", "lbl_familiar_type", 225.0, 20.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateLabel(jRow, "", "lbl_familiar_name", 225.0, 20.0);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    // Row 15 ******************************************************************* 500 / ---
        jRow = CreateCombo(JsonArray(), ai_CreateCompanionJson(oPC, "hen_familiar"), "cmb_familiar", 200.0, 20.0);
        jRow = CreateCheckBox(jRow, "", "chbx_familiar", 25.0, 20.0);
        jRow = CreateTextEditBox(jRow, "txtbox", "txt_familiar_name", 50, FALSE, 178.0, 20.0);
        jRow = CreateButton(jRow, "", "btn_familiar_name", 55.0, 20.0);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    }
    // Row 16 ****************************************************************** 500 / ---
    int bCompanion = GetHasFeat(FEAT_ANIMAL_COMPANION, oAssociate, TRUE);
    if(bCompanion)
    {
        jRow = CreateLabel(JsonArray(), "", "lbl_companion_type", 225.0, 20.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateLabel(jRow, "", "lbl_companion_name", 225.0, 20.0);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    // Row 17 ****************************************************************** 500 / ---
        jRow = CreateCombo(JsonArray(), ai_CreateCompanionJson(oPC, "hen_companion"), "cmb_companion", 200.0, 20.0);
        jRow = CreateCheckBox(jRow, "", "chbx_companion", 25.0, 20.0);
        jRow = CreateTextEditBox(jRow, "txtbox", "txt_companion_name", 50, FALSE, 178.0, 20.0);
        jRow = CreateButton(jRow, "", "btn_companion_name", 55.0, 20.0);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight = fHeight + 28.0;
    }
    */
    // Row 18+ ****************************************************************** 500 / ---
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jPCPlugins;
    if(bIsPC)
    {
        jPCPlugins = ai_UpdatePluginsForPC(oPC);
        // Set the plugins the player can use.
        int nIndex;
        string sButton, sName;
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sButton = IntToString(nIndex);
            sName = JsonGetString(JsonArrayGet(jPlugin, 2));
            jRow = CreateButton(JsonArray(), sName, "btn_plugin_" + sButton, 230.0f, 30.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
            jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 30.0, "chbx_plugin_tooltip");
            jRow = JsonArrayInsert(jRow, NuiSpacer());
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
            if(JsonGetType(jPlugin) != JSON_TYPE_NULL)
            {
                sButton = IntToString(nIndex);
                sName = JsonGetString(JsonArrayGet(jPlugin, 2));
                jRow = CreateButton(jRow, sName, "btn_plugin_" + sButton, 230.0f, 30.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
                jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 30.0, "chbx_plugin_tooltip");
                // Add row to the column.
                jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                fHeight += 38.0;
            }
            else
            {
                // Add row to the column.
                jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                fHeight += 38.0;
                break;
            }
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
    }
    // Row 19+ ****************************************************************** 500 / ---
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_info_1", 475.0, 30.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight = fHeight + 38.0;
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_COMMAND_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_COMMAND_NUI, sName + " Command Menu",
                           fX, fY, 560.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAIWidgetLock = ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
    int bCmdAction = ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType);
    int bCmdGuard = ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType);
    int bCmdHold = ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType);
    int bCmdSearch = ai_GetWidgetButton(oPC, BTN_CMD_SEARCH, oAssociate, sAssociateType);
    int bCmdStealth = ai_GetWidgetButton(oPC, BTN_CMD_STEALTH, oAssociate, sAssociateType);
    int bCmdAttack = ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType);
    int bCmdFollow = ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType);
    int bFollowTarget = ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType);
    int bCmdAIScript = ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType);
    int bCmdPlacetrap = ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType);
    int bSpellWidget = ai_GetWidgetButton(oPC, BTN_CMD_SPELL_WIDGET, oAssociate, sAssociateType);
    int bBuffRest = ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType);
    int bBuffShort = ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType);
    int bBuffLong = ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType);
    int bBuffAll = ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType);
    int bJumpTo = ai_GetWidgetButton(oPC, BTN_CMD_JUMP_TO, oAssociate, sAssociateType);
    int bGhostMode = ai_GetWidgetButton(oPC, BTN_CMD_GHOST_MODE, oAssociate, sAssociateType);
    int bCamera = ai_GetWidgetButton(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType);
    int bInventory = ai_GetWidgetButton(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType);
    int bBtnFamiliar = ai_GetWidgetButton(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType);
    int bBtnCompanion = ai_GetWidgetButton(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType);
    int bAssocWidgetOff = ai_GetWidgetButton(oPC, BTN_ASSOC_WIDGETS_OFF, oAssociate, sAssociateType);
    int bVertical = ai_GetWidgetButton(oPC, BTN_WIDGET_VERTICAL, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    string sText;
    // Row 1
    if(bIsPC)
    {
        if(bUsingPCAI)
        {
            NuiSetBind(oPC, nToken, "btn_ai_menu_event", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_ai_menu_tooltip", JsonString("  " + sName + " AI options"));
        }
        NuiSetBind(oPC, nToken, "btn_freeze_player", JsonBool(GetLocalInt(oPC, AI_FREEZE_OPTION)));
        NuiSetBind(oPC, nToken, "btn_freeze_player_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_freeze_player_tooltip", JsonString("  Freezes the player when using the menus."));
        if(!AI_SERVER)
        {
            NuiSetBind(oPC, nToken, "btn_main_menu_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_main_menu_tooltip", JsonString("  Module Options"));
        }
    }
    else
    {
        if(bUsingHenchAI)
        {
            NuiSetBind(oPC, nToken, "btn_ai_menu_event", JsonBool (TRUE));
            NuiSetBind(oPC, nToken, "btn_ai_menu_tooltip", JsonString("  " + sName + " AI options"));
        }
        string sText2;
        if(ai_GetAIButton(oPC, BTN_WIDGET_OFF, oAssociate, sAssociateType))
        {
            sText = "Off"; sText2 = "on";
            NuiSetBind(oPC, nToken, "btn_widget_onoff", JsonBool(FALSE));
        }
        else
        {
            sText = "On"; sText2 = "off";
            NuiSetBind(oPC, nToken, "btn_widget_onoff", JsonBool(TRUE));
        }
        NuiSetBind(oPC, nToken, "btn_widget_onoff_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_widget_onoff_label", JsonString("Widget " + sText));
        NuiSetBind(oPC, nToken, "btn_widget_onoff_tooltip", JsonString(
                                "  Turn " + sName + " widget " + sText2));
    }
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));

    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
                            "  Locks " + sName + " widget to the current location."));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_widget_lock_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_widget_lock", JsonBool(bAIWidgetLock));
    NuiSetBind(oPC, nToken, "btn_widget_lock_tooltip", JsonString(
                            "  Locks " + sName + " widget to the current location."));
    NuiSetBind(oPC, nToken, "btn_copy_settings_event", JsonBool (TRUE));
    sText = "  Copy AI and command settings for one creature to otheres.";
    NuiSetBind(oPC, nToken, "btn_copy_settings_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_vertical_widget_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_vertical_widget", JsonBool(bVertical));
    NuiSetBind(oPC, nToken, "btn_vertical_widget_tooltip", JsonString(
                            "  " + sName + " widget will display vertically"));
    // Row 3
    if(bUsingHenchAI)
    {
        if(ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, OBJECT_INVALID, "pc")) sText = "Associate Widgets [Off]";
        else sText = "Associate Widgets [On]";
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_label", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_tooltip", JsonString("  " + sText));
        NuiSetBind(oPC, nToken, "chbx_toggle_assoc_widget_check", JsonBool (bAssocWidgetOff));
        NuiSetBindWatch (oPC, nToken, "chbx_toggle_assoc_widget_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_toggle_assoc_widget_event", JsonBool(TRUE));
    }
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_cmd_action_check", JsonBool (bCmdAction));
    NuiSetBindWatch(oPC, nToken, "chbx_cmd_action_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_action_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_check", JsonBool (bCmdGuard));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_guard_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_guard_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool (TRUE));
    // Row 5
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_check", JsonBool (bCmdHold));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_hold_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_hold_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_check", JsonBool (bCmdAttack));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_attack_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_attack_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool (TRUE));
    // Row 6
    NuiSetBind(oPC, nToken, "btn_follow_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_check", JsonBool (bCmdFollow));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_follow_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_follow_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "chbx_follow_target_check", JsonBool (bFollowTarget));
    NuiSetBindWatch (oPC, nToken, "chbx_follow_target_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_follow_target_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool (TRUE));
    // Row 7
    if(bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_cmd_search_check", JsonBool (bCmdSearch));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_search_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_search_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_search_event", JsonBool (TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_SEARCH)) sText = " leave ";
        else sText = " enter ";
        NuiSetBind(oPC, nToken, "btn_cmd_search_tooltip", JsonString("  Everyone" + sText + "search mode"));
        NuiSetBind(oPC, nToken, "chbx_cmd_stealth_check", JsonBool (bCmdStealth));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_stealth_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_stealth_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_stealth_event", JsonBool (TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_STEALTH)) sText = " leave ";
        else sText = " enter ";
        NuiSetBind(oPC, nToken, "btn_cmd_stealth_tooltip", JsonString("  Everyone" + sText + "stealth mode"));
    }
    // Command labels
    float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                   StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
    string sRange = FloatToString(fRange, 0, 0);
    if(bIsPC) sText = "All ";
    else sText = "";
    NuiSetBind(oPC, nToken, "btn_cmd_action_label", JsonString(sText + "Action"));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_label", JsonString(sText + "Guard Mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_label", JsonString(sText + "Hold Mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_label", JsonString(sText + "Normal Mode"));
    if(bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_follow_label", JsonString(sText + "Follow Mode"));
    else NuiSetBind(oPC, nToken, "btn_cmd_follow_label", JsonString(sText + "Follow Mode [" + sRange + "]"));
    NuiSetBind(oPC, nToken, "btn_follow_target_label", JsonString("Follow Target [" + sRange + "]"));
    if(bIsPC)
    {
        sText = "  All associates";
        NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString("  " + sText + " enter follow mode"));
    }
    else
    {
        sText = "  " + GetName(oAssociate);
        NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(sText + " enter follow mode [" + sRange + " meters]"));
    }
    NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(sText + " do actions"));
    NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(sText + " enter guard mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(sText + " enter hold mode"));
    NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(sText + " enter normal mode"));
    object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
    string sTarget;
    if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
    else
    {
        if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
        else sTarget = GetName(oPC);
    }
    NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]"));
    // Row 8
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_check", JsonBool (bCmdAIScript));
    NuiSetBindWatch (oPC, nToken, "chbx_cmd_ai_script_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_cmd_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool (TRUE));
    sText = "  Default tactics: Using the creatures base AI script";
    string sScript;
    if(ResManGetAliasFor("ai_a_default", RESTYPE_NCS) != "")
    {
        sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
        if(sScript == "ai_a_ambusher") sText = "  Ambusher: Attacks from a hidden position";
        else if(sScript == "ai_a_flanker") sText = "  Flanker: Attacks enemies engaged with allies";
        else if(sScript == "ai_a_peaceful") sText = "  Peaceful: Avoids attacking any enemies if possible";
        else if(sScript == "ai_a_defensive") sText = "  Defensive: Attacks then uses Expertise/Parry";
        else if(sScript == "ai_a_ranged") sText = "  Ranged: Attacks from range as much as possible";
        else if(sScript == "ai_a_cntrspell") sText = "  Counter Spell: Tries to counter enemy spells";
    }
    else
    {
        if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate)) sText = "Using ambush tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate)) sText = "Using coward tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate)) sText = "Using defensive tactics";
        else if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate)) sText = "Using ranged tactics";
    }
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_label", JsonString("Tactics: " + sScript));
    NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString(sText));
    if(GetSkillRank(SKILL_SET_TRAP, oAssociate, TRUE) > 0)
    {
        NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_check", JsonBool (bCmdPlacetrap));
        NuiSetBindWatch (oPC, nToken, "chbx_cmd_place_trap_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_cmd_place_trap_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool (TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString (
                   "  Place a trap at the location selected"));
    }
    // Row 9
    NuiSetBind(oPC, nToken, "btn_quick_widget_event", JsonBool(TRUE));
    NuiSetBind (oPC, nToken, "btn_quick_widget_tooltip", JsonString(
               "  Add/Remove abilities and spells from creatures widget"));
    NuiSetBind(oPC, nToken, "chbx_quick_widget_check", JsonBool (bSpellWidget));
    NuiSetBindWatch (oPC, nToken, "chbx_quick_widget_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quick_widget_event", JsonBool(TRUE));
    if(bMemorize == 2) // Memorizes their spells.
    {
        NuiSetBind(oPC, nToken, "btn_spell_memorize_event", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_spell_memorize_tooltip", JsonString(
                   "  Change memorized spell list."));
    }
    if(bSpellbook) // Change known spells.
    {
        NuiSetBind(oPC, nToken, "btn_spell_known_event", JsonBool(TRUE));
        NuiSetBind (oPC, nToken, "btn_spell_known_tooltip", JsonString(
                   "  Change known spell list."));
    }
    // Row 10
    NuiSetBind(oPC, nToken, "chbx_buff_short_check", JsonBool (bBuffShort));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_short_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_short_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_buff_short_tooltip", JsonString (
               "  Buff the party with short duration spells"));
    NuiSetBind(oPC, nToken, "chbx_buff_long_check", JsonBool (bBuffLong));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_long_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_long_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString (
               "  Buff the party with long duration spells"));
    // Row 11
    NuiSetBind(oPC, nToken, "chbx_buff_all_check", JsonBool (bBuffAll));
    NuiSetBindWatch (oPC, nToken, "chbx_buff_all_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_buff_all_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString (
               "  Buff the party with all our defensive spells"));
    if(!bIsPC)
    {
        NuiSetBind(oPC, nToken, "chbx_buff_rest_check", JsonBool (bBuffRest));
        NuiSetBindWatch (oPC, nToken, "chbx_buff_rest_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_buff_rest_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool (TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "Buff after resting [On]";
        else sText = "Buff after resting [Off]";
        NuiSetBind(oPC, nToken, "btn_buff_rest_label", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_buff_rest_tooltip", JsonString ("  " + sText));
    }
    else NuiSetBind(oPC, nToken, "btn_buff_rest_label", JsonString("Buff after Resting [Off]"));
    // Row 12
    NuiSetBind(oPC, nToken, "chbx_jump_to_check", JsonBool(bJumpTo));
    NuiSetBindWatch (oPC, nToken, "chbx_jump_to_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_jump_to_event", JsonBool(TRUE));
    sText = GetName(oPC);
    if(oPC == oAssociate) sName = "everyone";
    else sName = GetName(oAssociate);
    NuiSetBind(oPC, nToken, "btn_jump_to_label", JsonString("Jump to " + sText));
    NuiSetBind(oPC, nToken, "btn_jump_to_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_jump_to_tooltip", JsonString (
               "  Jump " + sName + " to " + sText));
    NuiSetBind(oPC, nToken, "chbx_ghost_mode_check", JsonBool (bGhostMode));
    NuiSetBindWatch (oPC, nToken, "chbx_ghost_mode_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ghost_mode_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ghost_mode_event", JsonBool (TRUE));
    sText = "On";
    if(ai_GetAIMode(oAssociate, AI_MODE_GHOST)) sText = "Off";
    NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString (
               "  Turn " + sText + " clipping through creatures for " + GetName(oAssociate)));
    // Row 13
    NuiSetBind(oPC, nToken, "chbx_camera_check", JsonBool (bCamera));
    NuiSetBindWatch (oPC, nToken, "chbx_camera_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_camera_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString (
               "  Toggle camera view for " + sName));
    NuiSetBind(oPC, nToken, "chbx_inventory_check", JsonBool (bInventory));
    NuiSetBindWatch (oPC, nToken, "chbx_inventory_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_inventory_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString (
               "  Open " + sName + " inventory"));
    /*/ Row 14 & 15
    DOES NOT WORK WITH version 36!
    if(bFamiliar)
    {
        NuiSetBind(oPC, nToken, "chbx_familiar_check", JsonBool(bBtnFamiliar));
        NuiSetBindWatch (oPC, nToken, "chbx_familiar_check", TRUE);
        int nFamiliar = GetFamiliarCreatureType(oAssociate);
        NuiSetBind(oPC, nToken, "cmb_familiar_selected", JsonInt(nFamiliar));
        string sFamiliarName = GetFamiliarName(oAssociate);
        NuiSetBind(oPC, nToken, "txt_familiar_name", JsonString(sFamiliarName));
        if(!bIsPC)
        {
            NuiSetBind(oPC, nToken, "lbl_familiar_type_label", JsonString("Change familiar type"));
            NuiSetBind(oPC, nToken, "lbl_familiar_name_label", JsonString("Change familiar name"));
            NuiSetBind(oPC, nToken, "cmb_familiar_event", JsonBool(TRUE));
            NuiSetBindWatch(oPC, nToken, "cmb_familiar_selected", TRUE);
            NuiSetBindWatch(oPC, nToken, "txt_familiar_name", TRUE);
            NuiSetBind(oPC, nToken, "btn_familiar_name_label", JsonString("Save"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "lbl_familiar_type_label", JsonString("Familiar type"));
            NuiSetBind(oPC, nToken, "lbl_familiar_name_label", JsonString("Familiar name"));
        }
    }
    // Row 16 & 17
    if(bCompanion)
    {
        NuiSetBind(oPC, nToken, "chbx_companion_check", JsonBool(bBtnCompanion));
        NuiSetBindWatch (oPC, nToken, "chbx_companion_check", TRUE);
        int nCompanion = GetAnimalCompanionCreatureType(oAssociate);
        NuiSetBind(oPC, nToken, "cmb_companion_selected", JsonInt(nCompanion));
        string sCompanionName = GetAnimalCompanionName(oAssociate);
        NuiSetBind(oPC, nToken, "txt_companion_name", JsonString(sCompanionName));
        if(!bIsPC)
        {
            NuiSetBind(oPC, nToken, "lbl_companion_type_label", JsonString("Change Companion type"));
            NuiSetBind(oPC, nToken, "lbl_companion_name_label", JsonString("Change Companion name"));
            NuiSetBind(oPC, nToken, "cmb_companion_event", JsonBool(TRUE));
            NuiSetBindWatch(oPC, nToken, "cmb_companion_selected", TRUE);
            NuiSetBindWatch(oPC, nToken, "txt_companion_name", TRUE);
            NuiSetBind(oPC, nToken, "btn_companion_name_label", JsonString("Save"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "lbl_companion_type_label", JsonString("Companion type"));
            NuiSetBind(oPC, nToken, "lbl_companion_name_label", JsonString("Companion name"));
        }
    } */
    if(bIsPC)
    {
        // Row 18+
        int nIndex, bWidget;
        string sButton, sText;
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            sButton = IntToString(nIndex);
            NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
            bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bWidget));
            NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
            NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
            sText = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
            NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
        NuiSetBind(oPC, nToken, "chbx_plugin_tooltip", JsonString("  Adds the plugin to your widget."));
    }
    // Row 19+
    sText = ai_GetRandomTip();
    NuiSetBind(oPC, nToken, "lbl_info_1_label", JsonString(sText));
}
void ai_CreateAssociateAINUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    float fHeight = 45.0;
    // ************************************************************************* Width / Height
    int bIsPC = ai_GetIsCharacter(oAssociate);
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    json jCol = JsonArray();
    // Row 1 ******************************************************************* 500 / 73
    if(bIsPC)
    {
        jRow = CreateButton(jRow, "Command Menu", "btn_command_menu", 175.0, 30.0, -1.0, "btn_command_menu_tooltip");
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "Main Menu", "btn_main_menu", 175.0, 30.0, -1.0, "btn_main_menu_tooltip");
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "Close", "btn_close", 175.0f, 30.0f);
        jRow = CreateLabel(jRow, "", "lbl_space", 25.0, 30.0);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    // Row 2 ******************************************************************* 500 / 101
    if(!bIsPC)
    {
        jRow = CreateButton(jRow, "Command Menu", "btn_command_menu", 230.0, 30.0, -1.0, "btn_command_menu_tooltip");
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        jRow = CreateButton(jRow, "Close", "btn_close", 230.0f, 30.0f);
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Loot Filter", "btn_loot_filter", 230.0, 30.0);
    jRow = CreateLabel(jRow, "", "blank_label", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 500 / 129
    jRow = CreateButton(JsonArray(), "Player AI On/Off", "btn_ai", 230.0, 30.0, -1.0, "btn_ai_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_ai", 25.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Reduce Speech", "btn_quiet", 230.0, 30.0, -1.0, "btn_quiet_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_quiet", 25.0, 20.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 500 / 157
    jRow = CreateButton(JsonArray(), "Ranged Combat", "btn_ranged", 230.0, 30.0, -1.0, "btn_ranged_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_ranged", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Equip Best Weapons", "btn_equip_weapon", 230.0, 30.0, -1.0, "btn_equip_weapon_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_equip_weapon", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 500 / 185
    jRow = CreateButton(JsonArray(), "Search Mode", "btn_search", 230.0, 30.0, -1.0, "btn_search_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_search", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Stealth Mode", "btn_stealth", 230.0, 30.0, -1.0, "btn_stealth_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_stealth", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 ******************************************************************* 500 / 185
    jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_door_up", 30.0, 30.0, -1.0, "btn_open_door_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_door_down", 30.0, 30.0, -1.0, "btn_open_door_tooltip");
    jRow = CreateButton(jRow, "", "btn_open_door", 170.0, 30.0, -1.0, "btn_open_door_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_open_door", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_traps_up", 30.0, 30.0, -1.0, "btn_traps_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_traps_down", 30.0, 30.0, -1.0, "btn_traps_tooltip");
    jRow = CreateButton(jRow, "", "btn_traps", 170.0, 30.0, -1.0, "btn_traps_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_traps", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 7 ******************************************************************* 500 / 213
    jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_pick_up", 30.0, 30.0, -1.0, "btn_pick_locks_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_pick_down", 30.0, 30.0, -1.0, "btn_pick_locks_tooltip");
    jRow = CreateButton(jRow, "", "btn_pick_locks", 170.0, 30.0, -1.0, "btn_pick_locks_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_pick_locks", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_bash_up", 30.0, 30.0, -1.0, "btn_bash_locks_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_bash_down", 30.0, 30.0, -1.0, "btn_bash_locks_tooltip");
    jRow = CreateButton(jRow, "", "btn_bash_locks", 170.0, 30.0, -1.0, "btn_bash_locks_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_bash_locks", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 8 ******************************************************************* 500 / 241
    jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_magic_up", 30.0, 30.0, -1.0, "btn_magic_level_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_magic_down", 30.0, 30.0, -1.0, "btn_magic_level_tooltip");
    jRow = CreateButton(jRow, "", "btn_magic_level", 170.0, 30.0f, -1.0, "btn_magic_level_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_magic_level", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(JsonArray(), "Cleric Spontaneous Casting", "btn_spontaneous", 230.0, 30.0, -1.0, "btn_spontaneous_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_spontaneous", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 9 ******************************************************************* 500 / 269
    jRow = CreateButtonImage(JsonArray(), "nui_cnt_up", "btn_heal_out_up", 30.0, 30.0, -1.0, "btn_heal_out_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_heal_out_down", 30.0, 30.0, -1.0, "btn_heal_out_tooltip");
    jRow = CreateButton(jRow, "", "btn_heal_out", 170.0, 30.0, -1.0, "btn_heal_out_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_heal_out", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_heal_in_up", 30.0, 30.0, -1.0, "btn_heal_in_tooltip");
    jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_heal_in_down", 30.0, 30.0, -1.0, "btn_heal_in_tooltip");
    jRow = CreateButton(jRow, "", "btn_heal_in", 170.0, 30.0, -1.0, "btn_heal_in_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_heal_in", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 ****************************************************************** 500 / 297
    jRow = CreateButton(JsonArray(), "Use Magic", "btn_magic", 230.0, 30.0, -1.0, "btn_magic_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_magic", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Use Magic Items", "btn_magic_items", 230.0, 30.0, -1.0, "btn_magic_items_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_magic_items", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 ******************************************************************* 500 / 325
    jRow = CreateButton(JsonArray(), "Use Defensive Magic Only", "btn_def_magic", 230.0, 30.0, -1.0, "btn_def_magic_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_def_magic", 25.0, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Use Offensive Magic Only", "btn_off_magic", 230.0, 30.0, -1.0, "btn_off_magic_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_off_magic", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 12 ****************************************************************** 500 / 353
    jRow = CreateButton(JsonArray(), "Self Healing", "btn_heals_onoff", 230.0, 30.0, -1.0, "btn_heals_onoff_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_heals_onoff", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Party Healing", "btn_healp_onoff", 230.0, 30.0, -1.0, "btn_healp_onoff_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_healp_onoff", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 13 ****************************************************************** 500 / ---
    jRow = CreateButton(JsonArray(), "Cast Cure Spells", "btn_cure_onoff", 230.0, 30.0, -1.0, "btn_cure_onoff_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_cure_onoff", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    if(sAssociateType != "summons" && sAssociateType != "dominated")
    {
        jRow = CreateButtonImage(jRow, "nui_cnt_up", "btn_loot_up", 30.0, 30.0, -1.0, "btn_loot_tooltip");
        jRow = CreateButtonImage(jRow, "nui_cnt_down", "btn_loot_down", 30.0, 30.0, -1.0, "btn_loot_tooltip");
        jRow = CreateButton(jRow, "", "btn_loot", 170.0, 30.0, -1.0, "btn_loot_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_loot", 25.0, 30.0);
    }
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 ****************************************************************** 500 / ---
    jRow = CreateButton(JsonArray(), "Ignore Associates", "btn_ignore_assoc", 230.0, 30.0, -1.0, "btn_ignore_assoc_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_ignore_assoc", 25.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Ignore floor Traps", "btn_ignore_traps", 230.0, 30.0, -1.0, "btn_ignore_traps_tooltip");
    jRow = CreateCheckBox(jRow, "", "chbx_ignore_traps", 25.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 15 ****************************************************************** 500 / ---
    jRow = CreateButton(JsonArray(), "Set Current AI:", "btn_ai_script", 175.0f, 30.0f, -1.0, "btn_ai_script_tooltip");
    jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_ai_script", 16, FALSE, 175.0f, 30.0f, "txt_ai_script_tooltip");
    jRow = CreateCombo(jRow, ai_CreateAIScriptJson(oPC), "cmb_ai_script", 176.0, 30.0);
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 16 ****************************************************************** 500 / ---
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "", "lbl_info", 475.0, 30.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    fHeight += 570.0;
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_NUI, sName + " AI Menu",
                           fX, fY, 560.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Get which buttons are activated.
    int bAI = ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType);
    int bReduceSpeech = ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType);
    int bRanged = ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType);
    int bEquipWeapons = ai_GetAIButton(oPC, BTN_AI_STOP_WEAPON_EQUIP, oAssociate, sAssociateType);
    int bSearch = ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType);
    int bStealth = ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType);
    int bOpenDoors = ai_GetAIButton(oPC, BTN_AI_OPEN_DOORS, oAssociate, sAssociateType);
    int bTraps = ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType);
    int bPickLocks = ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType);
    int bBashLocks = ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType);
    int bMagicLevel = ai_GetAIButton(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType);
    int bSpontaneous = ai_GetAIButton(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType);
    int bNoMagic = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType);
    int bNoMagicItems = ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_ITEM_USE, oAssociate, sAssociateType);
    int bDefMagic = ai_GetAIButton(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType);
    int bOffMagic = ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType);
    int bHealOut = ai_GetAIButton(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType);
    int bHealIn = ai_GetAIButton(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType);
    int bSelfHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType);
    int bPartyHealOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType);
    int bCureOnOff = ai_GetAIButton(oPC, BTN_AI_STOP_CURE_SPELLS, oAssociate, sAssociateType);
    int bIgnoreAssociates = ai_GetAIButton(oPC, BTN_AI_IGNORE_ASSOCIATES, oAssociate, sAssociateType);
    int bIgnoreTraps = ai_GetAIButton(oPC, BTN_AI_IGNORE_TRAPS, oAssociate, sAssociateType);
    int bLoot = ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType);
    int bPercRange = ai_GetAIButton(oPC, BTN_AI_PERC_RANGE, oAssociate, sAssociateType);
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    if(bIsPC)
    {
        NuiSetBind(oPC, nToken, "btn_main_menu_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_main_menu_tooltip", JsonString("  Module Options"));
    }
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_command_menu_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_command_menu_tooltip", JsonString("  " + sName + " Command options"));
    NuiSetBind(oPC, nToken, "btn_loot_filter_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_loot_filter", JsonInt(TRUE));
    // Row 3
    // Only activate ai on/off if this is for the pc.
    if(bIsPC && ResManGetAliasFor("prc_ai_fam_percp", RESTYPE_NCS) == "")
    {
        NuiSetBind(oPC, nToken, "chbx_ai_check", JsonBool(bAI));
        NuiSetBindWatch (oPC, nToken, "chbx_ai_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_ai_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
        if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI On";
        else sText = "  AI Off";
        NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(sText));
    }
    NuiSetBind(oPC, nToken, "chbx_quiet_check", JsonBool(bReduceSpeech));
    NuiSetBindWatch (oPC, nToken, "chbx_quiet_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_quiet_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) sText = "  Reduced Speech On";
    else sText = "  Reduces Speech Off";
    NuiSetBind (oPC, nToken, "btn_quiet_tooltip", JsonString(sText));
    // Row 4
    NuiSetBind(oPC, nToken, "chbx_ranged_check", JsonBool(bRanged));
    NuiSetBindWatch(oPC, nToken, "chbx_ranged_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ranged_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged Off";
    else sText = "  Ranged On";
    NuiSetBind (oPC, nToken, "btn_ranged_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_equip_weapon_check", JsonBool(bEquipWeapons));
    NuiSetBindWatch(oPC, nToken, "chbx_equip_weapon_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_equip_weapon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_equip_weapon_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_EQUIP_WEAPON_OFF)) sText = "  Equiping Best Weapons Off";
    else sText = "  Equiping Best Weapons On";
    NuiSetBind (oPC, nToken, "btn_equip_weapon_tooltip", JsonString(sText));
    // Row 5
    if(GetRacialType(oAssociate) != RACIAL_TYPE_ELF)
    {
        NuiSetBind(oPC, nToken, "chbx_search_check", JsonBool(bSearch));
        NuiSetBindWatch (oPC, nToken, "chbx_search_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_search_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search mode On";
        else sText = "  Search mode Off";
        NuiSetBind (oPC, nToken, "btn_search_tooltip", JsonString(sText));
    }
    NuiSetBind(oPC, nToken, "chbx_stealth_check", JsonBool(bStealth));
    NuiSetBindWatch(oPC, nToken, "chbx_stealth_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_stealth_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth mode On";
    else sText = "  Stealth mode Off";
    NuiSetBind (oPC, nToken, "btn_stealth_tooltip", JsonString(sText));
    // Row 6
    NuiSetBind(oPC, nToken, "btn_door_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_door_down_event", JsonBool(TRUE));
    string sRange = FloatToString(GetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_open_door_check", JsonBool(bOpenDoors));
    NuiSetBindWatch (oPC, nToken, "chbx_open_door_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_open_door_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_door_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_OPEN_DOORS)) sText = "Open Doors On [" + sRange + "]";
    else sText = "Open Doors Off [" + sRange + "]";
    NuiSetBind(oPC, nToken, "btn_open_door_label", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_open_door_tooltip", JsonString("  " + sText));
    NuiSetBind(oPC, nToken, "btn_traps_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_down_event", JsonBool(TRUE));
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_traps_check", JsonBool(bTraps));
    NuiSetBindWatch (oPC, nToken, "chbx_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "Disable Traps On [" + sRange + "]";
    else sText = "Disable Traps Off [" + sRange + "]";
    NuiSetBind(oPC, nToken, "btn_traps_label", JsonString(sText));
    NuiSetBind (oPC, nToken, "btn_traps_tooltip", JsonString("  " + sText));
    // Row 7
    NuiSetBind(oPC, nToken, "btn_pick_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_down_event", JsonBool(TRUE));
    sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
    NuiSetBind(oPC, nToken, "chbx_pick_locks_check", JsonBool(bPickLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_pick_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_pick_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sText = "Pick locks On [" + sRange + "]";
    else sText = "Pick Locks Off [" + sRange + "]";
    NuiSetBind(oPC, nToken, "btn_pick_locks_label", JsonString(sText));
    NuiSetBind (oPC, nToken, "btn_pick_locks_tooltip", JsonString("  " + sText));
    NuiSetBind(oPC, nToken, "btn_bash_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_down_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_bash_locks_check", JsonBool(bBashLocks));
    NuiSetBindWatch(oPC, nToken, "chbx_bash_locks_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_bash_locks_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS)) sText = "Bash On [" + sRange + "]";
    else sText = "Bash Off [" + sRange + "]";
    NuiSetBind(oPC, nToken, "btn_bash_locks_label", JsonString(sText));
    NuiSetBind (oPC, nToken, "btn_bash_locks_tooltip", JsonString("  " + sText));
    // Row 8
    NuiSetBind(oPC, nToken, "btn_magic_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_down_event", JsonBool(TRUE));
    string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
    NuiSetBind(oPC, nToken, "chbx_magic_level_check", JsonBool(bMagicLevel));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_level_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_level_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_level_label", JsonString("Magic Level [" + sMagic + "]"));
    NuiSetBind (oPC, nToken, "btn_magic_level_tooltip", JsonString("  Magic level [" + sMagic + "]"));
    sText = "  Spontaneous casting On";
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE)) sText = "  Spontaneous casting Off";
    NuiSetBind(oPC, nToken, "chbx_spontaneous_check", JsonBool(bSpontaneous));
    NuiSetBindWatch (oPC, nToken, "chbx_spontaneous_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(sText));
    // Row 9
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  Magic Off";
    else sText = "  Magic On";
    NuiSetBind(oPC, nToken, "chbx_magic_check", JsonBool(bNoMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_tooltip", JsonString(sText));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS)) sText = "  Magic Items Off";
    else sText = "  Magic Items On";
    NuiSetBind(oPC, nToken, "chbx_magic_items_check", JsonBool(bNoMagicItems));
    NuiSetBindWatch (oPC, nToken, "chbx_magic_items_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_magic_items_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_items_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_magic_items_tooltip", JsonString(sText));
    // Row 10
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  Defensive Magic On";
    else sText = "  Defensive Magic Off";
    NuiSetBind(oPC, nToken, "chbx_def_magic_check", JsonBool (bDefMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_def_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_def_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString(sText));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  Offensive Magic On";
    else sText = "  Offensive Magic Off";
    NuiSetBind(oPC, nToken, "chbx_off_magic_check", JsonBool(bOffMagic));
    NuiSetBindWatch (oPC, nToken, "chbx_off_magic_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_off_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString(sText));
    // Row 11
    NuiSetBind(oPC, nToken, "btn_heal_out_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_down_event", JsonBool(TRUE));
    int nHeal = GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT);
    NuiSetBind(oPC, nToken, "btn_heal_out_label", JsonString("Heal " + IntToString(nHeal) + "% out combat"));
    NuiSetBind(oPC, nToken, "chbx_heal_out_check", JsonBool(bHealOut));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_out_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_out_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_out_event", JsonBool(TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health out of combat";
    NuiSetBind(oPC, nToken, "btn_heal_out_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "btn_heal_in_up_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_down_event", JsonBool(TRUE));
    nHeal = GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT);
    NuiSetBind(oPC, nToken, "btn_heal_in_label", JsonString("Heal " + IntToString(nHeal) + "% in combat"));
    NuiSetBind(oPC, nToken, "chbx_heal_in_check", JsonBool(bHealIn));
    NuiSetBindWatch (oPC, nToken, "chbx_heal_in_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heal_in_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heal_in_event", JsonBool (TRUE));
    sText = "  Will heal at or below [" + IntToString(nHeal) + "%] health in combat";
    NuiSetBind(oPC, nToken, "btn_heal_in_tooltip", JsonString(sText));
    // Row 12
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_check", JsonBool(bSelfHealOnOff));
    NuiSetBindWatch (oPC, nToken, "chbx_heals_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_heals_onoff_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF)) sText = "  Self healing Off";
    else sText = "  Self healing On";
    NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_check", JsonBool(bPartyHealOnOff));
    NuiSetBind(oPC, nToken, "chbx_healp_onoff_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "chbx_healp_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF)) sText = "  Party healing Off";
    else sText = "  Party healing On";
    NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(sText));
    // Row 13
    NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_cure_onoff_check", JsonBool(bCureOnOff));
    NuiSetBind(oPC, nToken, "chbx_cure_onoff_event", JsonBool(TRUE));
    NuiSetBindWatch (oPC, nToken, "chbx_cure_onoff_check", TRUE);
    NuiSetBind(oPC, nToken, "btn_cure_onoff_event", JsonBool(TRUE));
    if(ai_GetMagicMode(oAssociate, AI_MAGIC_CURE_SPELLS_OFF)) sText = "  Cast Cure Spells Off";
    else sText = "  Cast Cure Spells On";
    NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(sText));
    if(sAssociateType != "summons" && sAssociateType != "dominated")
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
        if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sText = "Looting On [" + sRange + "]";
        else sText = "Looting Off [" + sRange + "]";
        NuiSetBind(oPC, nToken, "chbx_loot_check", JsonBool(bLoot));
        NuiSetBindWatch (oPC, nToken, "chbx_loot_check", TRUE);
        NuiSetBind(oPC, nToken, "chbx_loot_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_up_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_down_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_label", JsonString(sText));
        NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString("  " + sText));
    }
    // Row 14
    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_check", JsonBool(bIgnoreAssociates));
    NuiSetBindWatch(oPC, nToken, "chbx_ignore_assoc_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ignore_assoc_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ignore_assoc_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES)) sText = "  Ignore Enemy Associates On";
    else sText = "  Ignore Enemy Associates Off";
    NuiSetBind (oPC, nToken, "btn_ignore_assoc_tooltip", JsonString(sText));
    NuiSetBind(oPC, nToken, "chbx_ignore_traps_check", JsonBool(bIgnoreTraps));
    NuiSetBindWatch(oPC, nToken, "chbx_ignore_traps_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_ignore_traps_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ignore_traps_event", JsonBool(TRUE));
    if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_TRAPS)) sText = "  Ignore Floor Traps On";
    else sText = "  Ignore Floor Traps Off";
    NuiSetBind (oPC, nToken, "btn_ignore_traps_tooltip", JsonString(sText));
    /* DOES NOT WORK IN VERSION 36!
    if(!bIsPC)
    {
        int nRange = GetLocalInt(oAssociate, AI_PERCEPTION_RANGE);
        if(nRange < 8 || nRange > 11)
        {
            nRange = 11;
            SetLocalInt(oAssociate, AI_PERCEPTION_RANGE, 11);
            json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
            jAIData = JsonArraySet(jAIData, 7, JsonInt(11));
            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        }
        if(nRange == 8) sText = "  Perception Range Short [10 meters Sight / 10 meters Listen]";
        if(nRange == 9) sText = "  Perception Range Medium [20 meters Sight / 20 meters Listen]";
        if(nRange == 10) sText = "  Perception Range Long [35 meters Sight / 20 meters Listen]";
        else sText = "  Perception Range Default [20 meters Sight / 20 meters Listen]";
        NuiSetBind(oPC, nToken, "chbx_perc_range_check", JsonBool(bPercRange));
        NuiSetBindWatch (oPC, nToken, "chbx_perc_range_check", TRUE);
        NuiSetBind(oPC, nToken, "btn_perc_range_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_range_tooltip", JsonString(sText));
    }     */
    // Row 15
    string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    if(sScript == "") sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
    NuiSetBind(oPC, nToken, "btn_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_ai_script_tooltip", JsonString("  Sets " + GetName(oAssociate) + " to use the ai script in the text box."));
    NuiSetBind(oPC, nToken, "txt_ai_script_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_ai_script", JsonString(sScript));
    NuiSetBind(oPC, nToken, "txt_ai_script_tooltip", JsonString("  Associate AI scripts must start with ai_a_"));
    NuiSetBind(oPC, nToken, "cmb_ai_script_event", JsonBool(TRUE));
    NuiSetBindWatch(oPC, nToken, "cmb_ai_script_selected", TRUE);
    // Row 16
    sText = ai_GetRandomTip();
    NuiSetBind (oPC, nToken, "lbl_info_label", JsonString(sText));
}
void ai_SetWidgetBinds(object oPC, object oAssociate, string sAssociateType, int nToken, string sName)
{
    int bBool, bIsPC = ai_GetIsCharacter(oAssociate);
    string sText, sRange, sHeal;
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set the buttons to show events.
    NuiSetBind(oPC, nToken, "btn_open_main_image", JsonString(GetPortraitResRef(oAssociate) + "s"));
    NuiSetBind(oPC, nToken, "btn_open_main_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_open_main_tooltip", JsonString("  " + sName + " widget menu"));
    if(ai_GetWidgetButton(oPC, BTN_ASSOC_WIDGETS_OFF, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_event", JsonBool(TRUE));
        if(ai_GetWidgetButton(oPC, BTN_WIDGET_OFF, oPC, "pc")) sText = "Associate Widgets [Off]";
        else sText = "Associate Widgets [On]";
        NuiSetBind(oPC, nToken, "btn_toggle_assoc_widget_tooltip", JsonString("  " + sText));
    }
    if(bIsPC) sText = "  All associates";
    else sText = "  " + GetName(oAssociate);
    if(ai_GetWidgetButton(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_camera_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_camera_tooltip", JsonString("  Toggle camera view for " + sName));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_action_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_action_tooltip", JsonString(sText + " do actions"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_guard_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_guard_tooltip", JsonString(sText + " enter guard mode"));
        bBool = ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER);
        NuiSetBind(oPC, nToken, "btn_cmd_guard_encouraged", JsonBool(bBool));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_hold_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_hold_tooltip", JsonString(sText + " enter hold mode"));
        bBool = ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND);
        NuiSetBind(oPC, nToken, "btn_cmd_hold_encouraged", JsonBool(bBool));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_attack_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_attack_tooltip", JsonString(sText + " enter normal mode"));
        if(!bIsPC)
        {
            if(!ai_GetAIMode(oAssociate, AI_MODE_DEFEND_MASTER) &&
               !ai_GetAIMode(oAssociate, AI_MODE_STAND_GROUND) &&
               !ai_GetAIMode(oAssociate, AI_MODE_FOLLOW)) bBool = TRUE;
            else bBool = FALSE;
            if(!bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_attack_encouraged", JsonBool(bBool));
        }
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_follow_event", JsonBool(TRUE));
        float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                       StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
        string sRange = FloatToString(fRange, 0, 0);
        if(bIsPC)
        {
            sText = "  All associates";
            NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(sText + " enter follow mode"));
        }
        else
        {
            sText = "  " + GetName(oAssociate);
            NuiSetBind(oPC, nToken, "btn_cmd_follow_tooltip", JsonString(sText + " enter follow mode [" + sRange + " meters]"));
        }
        bBool = ai_GetAIMode(oAssociate, AI_MODE_FOLLOW);
        if(!bIsPC) NuiSetBind(oPC, nToken, "btn_cmd_follow_encouraged", JsonBool(bBool));
    }
    if(ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_follow_target_event", JsonBool(TRUE));
        object oTarget = GetLocalObject(oAssociate, AI_FOLLOW_TARGET);
        string sTarget;
        if(oTarget != OBJECT_INVALID) sTarget = GetName(oTarget);
        else
        {
            if(ai_GetIsCharacter(oAssociate)) sTarget = "nobody";
            else sTarget = GetName(oPC);
        }
        float fRange = GetLocalFloat(oAssociate, AI_FOLLOW_RANGE) +
                       StringToFloat(Get2DAString("appearance", "PREFATCKDIST", GetAppearanceType(oAssociate)));
        string sRange = FloatToString(fRange, 0, 0);
        NuiSetBind(oPC, nToken, "btn_follow_target_tooltip", JsonString("  " + GetName(oAssociate) + " following " + sTarget + " [" + sRange + " meters]"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_SEARCH, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_search_event", JsonBool(TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_SEARCH)) sText = " leave ";
        else sText = " enter ";
        NuiSetBind(oPC, nToken, "btn_cmd_search_tooltip", JsonString("  Everyone" + sText + "search mode"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_STEALTH, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_stealth_event", JsonBool(TRUE));
        if(ai_GetAIMode(oPC, AI_MODE_AGGRESSIVE_STEALTH)) sText = " leave ";
        else sText = " enter ";
        NuiSetBind(oPC, nToken, "btn_cmd_stealth_tooltip", JsonString(" Everyone" + sText + "stealth mode"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType))
    {
        sText = "  Default tactics: Using the creatures base AI script";
        string sIcon = "ir_scommand";
        if(ResManGetAliasFor("0e_ch_1_hb", RESTYPE_NCS) != "")
        {
            string sScript = GetLocalString(oAssociate, AI_COMBAT_SCRIPT);
            if(sScript == "ai_a_ambusher")
            {
                sText = "  Ambusher: Attacks from a hidden position";
                sIcon = "ir_rogue";
            }
            else if(sScript == "ai_a_flanker")
            {
                sText = "  Flanker: Attacks enemies engaged with allies";
                sIcon = "ir_invite";
            }
            else if(sScript == "ai_a_peaceful")
            {
                sText = "  Peaceful: Avoids attacking any enemies if possible";
                sIcon = "ir_ignore";
            }
            else if(sScript == "ai_a_defensive")
            {
                sText = "  Defensive: Attacks then uses Expertise/Parry";
                sIcon = "ir_knockdwn";
            }
            else if(sScript == "ai_a_ranged")
            {
                sText = "  Ranged: Attacks from range as much as possible";
                sIcon = "ir_ranger";
            }
            else if(sScript == "ai_a_cntrspell")
            {
                sText = "  Counter Spell: Tries to counter enemy spells";
                sIcon = "ir_dcaster";
            }
        }
        else
        {
            if(GetCombatCondition(X0_COMBAT_FLAG_AMBUSHER, oAssociate)) sText = "Using ambush tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_COWARDLY, oAssociate)) sText = "Using coward tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_DEFENSIVE, oAssociate)) sText = "Using defensive tactics";
            if(GetCombatCondition(X0_COMBAT_FLAG_RANGED, oAssociate)) sText = "Using ranged tactics";
        }
        NuiSetBind(oPC, nToken, "btn_cmd_ai_script_image", JsonString(sIcon));
        NuiSetBind(oPC, nToken, "btn_cmd_ai_script_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_ai_script_tooltip", JsonString(sText));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_cmd_place_trap_tooltip", JsonString("    Place a trap at the location selected"));
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_buff_short_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_short_tooltip", JsonString("  Buff the party with short duration spells"));
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_buff_long_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_long_tooltip", JsonString("  Buff the party with long duration spells"));
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_buff_all_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_buff_all_tooltip", JsonString("  Buff the party with all our defensive spells"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_JUMP_TO, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_jump_to_event", JsonBool(TRUE));
        sText = GetName(oPC);
        if(oPC == oAssociate) sName = "everyone";
        else sName = GetName(oAssociate);
        NuiSetBind(oPC, nToken, "btn_jump_to_tooltip", JsonString("  Jump " + sName + " to " + sText));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_GHOST_MODE, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_ghost_mode_event", JsonBool (TRUE));
        sText = "On";
        if(ai_GetAIMode(oAssociate, AI_MODE_GHOST)) sText = "Off";
        NuiSetBind(oPC, nToken, "btn_ghost_mode_tooltip", JsonString (
                   "  Turn " + sText + " clipping through creatures for " + GetName(oAssociate)));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_inventory_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_inventory_tooltip", JsonString("  Open " + sName + " inventory"));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_familiar_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_familiar_tooltip", JsonString("  Summon " + sName + " familiar."));
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_companion_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_companion_tooltip", JsonString("  Open " + sName + " Animal Companion."));
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_buff_rest_event", JsonBool(TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_BUFF_AFTER_REST)) sText = "  Turn buffing after resting off";
        else sText = "  Turn buffing after resting on.";
        NuiSetBind(oPC, nToken, "btn_buff_rest_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_ai_event", JsonBool(TRUE));
        if(GetEventScript(oAssociate, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "xx_pc_1_hb") sText = "  AI [On] Turn off";
        else sText = "  AI [Off] Turn on";
        NuiSetBind(oPC, nToken, "btn_ai_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_quiet_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_DO_NOT_SPEAK)) sText = "  Reduced Speech On";
        else sText = "  Reduced Speech Off";
        NuiSetBind(oPC, nToken, "btn_quiet_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_ranged_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_STOP_RANGED)) sText = "  Ranged Off";
        else sText = "  Ranged On";
        NuiSetBind(oPC, nToken, "btn_ranged_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_WEAPON_EQUIP, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_equip_weapon_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_EQUIP_WEAPON_OFF)) sText = "  Equiping Best Weapons Off";
        else sText = "  Equiping Best Weapons On";
        NuiSetBind(oPC, nToken, "btn_equip_weapon_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_search_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_SEARCH)) sText = "  Search On";
        else sText = "  Search Off";
        NuiSetBind(oPC, nToken, "btn_search_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_stealth_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_AGGRESSIVE_STEALTH)) sText = "  Stealth On";
        else sText = "  Stealth Off";
        NuiSetBind(oPC, nToken, "btn_stealth_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_OPEN_DOORS, oAssociate, sAssociateType))
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_OPEN_DOORS_RANGE), 0, 0);
        NuiSetBind(oPC, nToken, "btn_open_door_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_OPEN_DOORS)) sText = "  Open Doors On [" + sRange + " meters]";
        else sText = "  Open Doors Off [" + sRange + " meters]";
        NuiSetBind(oPC, nToken, "btn_open_door_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType))
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_TRAP_CHECK_RANGE), 0, 0);
        NuiSetBind(oPC, nToken, "btn_traps_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_DISARM_TRAPS)) sText = "  Disable Traps On [" + sRange + " meters]";
        else sText = "  Disable Traps Off [" + sRange + " meters]";
        NuiSetBind(oPC, nToken, "btn_traps_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType))
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
        NuiSetBind(oPC, nToken, "btn_pick_locks_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_PICK_LOCKS)) sText = "  Pick locks On [" + sRange + " meters]";
        else sText = "  Pick Locks Off [" + sRange + " meters]";
        NuiSetBind(oPC, nToken, "btn_pick_locks_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType))
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOCK_CHECK_RANGE), 0, 0);
        NuiSetBind(oPC, nToken, "btn_bash_locks_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_BASH_LOCKS)) sText = "  Bash On [" + sRange + " meters]";
        else sText = "  Bash Off [" + sRange + " meters]";
        NuiSetBind(oPC, nToken, "btn_bash_locks_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_magic_level_event", JsonBool(TRUE));
        string sMagic = IntToString(GetLocalInt(oAssociate, AI_DIFFICULTY_ADJUSTMENT));
        NuiSetBind(oPC, nToken, "btn_magic_level_tooltip", JsonString(" Magic Level [" + sMagic + "]"));
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType))
    {
        string sCasting = "  Spontaneous casting On";
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_NO_SPONTANEOUS_CURE)) sCasting = "  Spontaneous casting Off";
        NuiSetBind(oPC, nToken, "btn_spontaneous_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_spontaneous_tooltip", JsonString(sCasting));
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType))
    {
        if(ai_GetAIMode(oAssociate, AI_MAGIC_NO_MAGIC)) sText = "  Magic Off";
        else sText = "  Magic On";
        NuiSetBind(oPC, nToken, "btn_magic_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_magic_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_ITEM_USE, oAssociate, sAssociateType))
    {
        if(ai_GetAIMode(oAssociate, AI_MAGIC_NO_MAGIC_ITEMS)) sText = "  Magic Items Off";
        else sText = "  Magic Items On";
        NuiSetBind(oPC, nToken, "btn_magic_items_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_magic_items_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType))
    {
        if(ai_GetAIMode(oAssociate, AI_MAGIC_DEFENSIVE_CASTING)) sText = "  Defensive Magic On";
        else sText = "  Defensive Magic Off";
        NuiSetBind(oPC, nToken, "btn_def_magic_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_def_magic_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType))
    {
        if(ai_GetAIMode(oAssociate, AI_MAGIC_OFFENSIVE_CASTING)) sText = "  Offensive Magic On";
        else sText = "  Offensive Magic Off";
        NuiSetBind(oPC, nToken, "btn_off_magic_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_off_magic_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_heal_out_event", JsonBool(TRUE));
        sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_OUT_OF_COMBAT_LIMIT));
        sText = "  Will heal at or below [" + sHeal + "%] health out of combat";
        NuiSetBind(oPC, nToken, "btn_heal_out_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_heal_in_event", JsonBool(TRUE));
        sHeal = IntToString(GetLocalInt(oAssociate, AI_HEAL_IN_COMBAT_LIMIT));
        sText = "  Will heal at or below [" + sHeal + "%] health in combat";
        NuiSetBind(oPC, nToken, "btn_heal_in_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_heals_onoff_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_SELF_HEALING_OFF)) sText = "  Self healing Off";
        else sText = "  Self healing On";
        NuiSetBind(oPC, nToken, "btn_heals_onoff_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_healp_onoff_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_PARTY_HEALING_OFF)) sText = "  Party healing Off";
        else sText = "  Party healing On";
        NuiSetBind(oPC, nToken, "btn_healp_onoff_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_CURE_SPELLS, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_cure_onoff_event", JsonBool(TRUE));
        if(ai_GetMagicMode(oAssociate, AI_MAGIC_CURE_SPELLS_OFF)) sText = "  Cast Cure Spells Off";
        else sText = "  Cast Cure Spells On";
        NuiSetBind(oPC, nToken, "btn_cure_onoff_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType))
    {
        sRange = FloatToString(GetLocalFloat(oAssociate, AI_LOOT_CHECK_RANGE), 0, 0);
        string sLoot = "  Looting Off [" + sRange + " meters]";
        if(ai_GetAIMode(oAssociate, AI_MODE_PICKUP_ITEMS)) sLoot = "  Looting On [" + sRange + " meters]";
        NuiSetBind(oPC, nToken, "btn_loot_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_loot_tooltip", JsonString(sLoot));
    }
    if(ai_GetAIButton(oPC, BTN_AI_IGNORE_ASSOCIATES, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_ignore_assoc_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_ASSOCIATES)) sText = "  Ignore Enemy Associates On";
        else sText = "  Ignore Enemy Associates Off";
        NuiSetBind(oPC, nToken, "btn_ignore_assoc_tooltip", JsonString(sText));
    }
    if(ai_GetAIButton(oPC, BTN_AI_IGNORE_TRAPS, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_ignore_traps_event", JsonBool(TRUE));
        if(ai_GetAIMode(oAssociate, AI_MODE_IGNORE_TRAPS)) sText = "  Ignore Floor Traps On";
        else sText = "  Ignore Floor Traps Off";
        NuiSetBind(oPC, nToken, "btn_ignore_traps_tooltip", JsonString(sText));
    }
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    if(ai_GetAIButton(oPC, BTN_AI_PERC_RANGE, oAssociate, sAssociateType))
    {
        int nRange = GetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION);
        if(nRange < 8 || nRange > 11)
        {
            nRange = 11;
            SetLocalInt(oAssociate, AI_ASSOCIATE_PERCEPTION, 11);
            jAIData = JsonArraySet(jAIData, 7, JsonInt(11));
            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        }
        if(nRange == 8) sText = "  Perception Range Short [10 meters Sight / 10 meters Listen]";
        if(nRange == 9) sText = "  Perception Range Medium [20 meters Sight / 20 meters Listen]";
        if(nRange == 10) sText = "  Perception Range Long [35 meters Sight / 20 meters Listen]";
        else sText = "  Perception Range Default [20 meters Sight / 20 meters Listen]";
        NuiSetBind(oPC, nToken, "btn_perc_range_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_perc_range_tooltip", JsonString(sText));
    }
    if(bIsPC)
    {
        int nIndex, bWidget;
        string sButton, sName, sText, sScript;
        json jPCPlugins = ai_UpdatePluginsForPC(oPC);
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
            if(bWidget)
            {
                sButton = IntToString(nIndex);
                sScript = JsonGetString(JsonArrayGet(jPlugin, 0));
                if(ResManGetAliasFor(sScript, RESTYPE_NCS) == "")
                {
                    sText = "  " + sScript + " not found by ResMan!";
                }
                else sName = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
                NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_event", JsonBool (TRUE));
                NuiSetBind(oPC, nToken, "btn_exe_plugin_" + sButton + "_tooltip", JsonString(sName));
            }
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_SPELL_WIDGET, oAssociate, sAssociateType))
    {
        NuiSetBind(oPC, nToken, "btn_update_widget_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_update_widget_tooltip", JsonString("  Updates Quick Use Widget"));
        json jSpell, jSpells = JsonArrayGet(jAIData, 10);
        json jWidget = JsonArrayGet(jSpells, 2);
        object oItem;
        if(JsonGetType(jWidget) != JSON_TYPE_NULL)
        {
            int nLevel, nSpell, nIndex, nClass, nMetaMagic, nDomain, nSubSpell, nFeat, nSAIndex;
            string sSpellIcon, sMetaMagicText, sSubSpell, sClass, sIndex;
            while(nIndex < 10)
            {
                jSpell = JsonArrayGet(jWidget, nIndex);
                if(JsonGetType(jSpell) != JSON_TYPE_NULL)
                {
                    sIndex = IntToString(nIndex);
                    nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                    nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
                    if(nClass == -1) // This is an Item.
                    {
                        string sBaseName;
                        sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        int nBaseItemType = JsonGetInt(JsonArrayGet(jSpell, 3));
                        int nIprpSubType = JsonGetInt(JsonArrayGet(jSpell, 4));
                        if(nSpell == SPELL_HEALINGKIT)
                        {
                            sName = "Healer's Kit +" + IntToString(nIprpSubType);
                            sSpellIcon = "isk_heal";
                            sBaseName = "Healer's Kit";
                        }
                        else if(nBaseItemType == BASE_ITEM_ENCHANTED_SCROLL ||
                           nBaseItemType == BASE_ITEM_SCROLL ||
                           nBaseItemType == BASE_ITEM_SPELLSCROLL)
                        {
                            sSpellIcon = Get2DAString("iprp_spells", "Icon", nIprpSubType);
                            sBaseName = "Scroll";
                        }
                        else
                        {
                            if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                               nBaseItemType == BASE_ITEM_POTIONS) sBaseName = "Potion";
                            else if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
                                    nBaseItemType == BASE_ITEM_MAGICWAND ||
                                    nBaseItemType == FEAT_CRAFT_WAND) sBaseName = "Wand";
                            else sBaseName = ai_StripColorCodes(GetName(GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)))));
                            sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        }
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                        oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                        int nUses = ai_GetItemUses(oItem, nIprpSubType);
                        if(nUses)
                        {
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                            if(nUses == 999) sText = "Unlimited";
                            else sText = IntToString(nUses);
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sBaseName + " / " + sText + ")"));
                        }
                        else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                    }
                    else
                    {
                        nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
                        if(nFeat) // This is a feat.
                        {
                            nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                            sSpellIcon = "";
                            if(nSpell)
                            {
                                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                            }
                            if(sSpellIcon == "" || sSpellIcon == "IR_USE")
                            {
                                sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                                sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                            }
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                            if(GetHasFeat(nFeat, oAssociate))
                            {
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName));
                            }
                            else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                        }
                        else // This is a spell.
                        {
                            nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                            nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
                            nLevel = JsonGetInt(JsonArrayGet(jSpell, 2));
                            nMetaMagic = JsonGetInt(JsonArrayGet(jSpell, 3));
                            nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
                            sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                            sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                            NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
                            nSAIndex = JsonGetInt(JsonArrayGet(jSpell, 6));
                            if(nClass == 255 && GetSpellAbilityReady(oAssociate, nSAIndex))
                            {
                                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (Special Ability / " + IntToString(nLevel) + ")"));
                            }
                            else if(GetSpellUsesLeft(oAssociate, nClass, nSpell, nMetaMagic, nDomain))
                            {
                                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevel) + ")"));
                            }
                            else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                        }
                    }
                }
                else break;
                ++nIndex;
            }
            while(nIndex < 20)
            {
                jSpell = JsonArrayGet(jWidget, nIndex);
                if(JsonGetType(jSpell) != JSON_TYPE_NULL)
                {
                    sIndex = IntToString(nIndex);
                    nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                    nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
                    nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
                    if(nClass == -1) // This is an Item.
                    {
                        oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                        if(oItem != OBJECT_INVALID)
                        {
                            string sBaseName;
                            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                            int nBaseItemType = JsonGetInt(JsonArrayGet(jSpell, 3));
                            int nIprpSubType = JsonGetInt(JsonArrayGet(jSpell, 4));
                            if(nSpell == SPELL_HEALINGKIT)
                            {
                                sName = "Healer's Kit +" + IntToString(nIprpSubType);
                                sSpellIcon = "isk_heal";
                                sBaseName = "Healer's Kit";
                            }
                            else if(nBaseItemType == BASE_ITEM_ENCHANTED_SCROLL ||
                               nBaseItemType == BASE_ITEM_SCROLL ||
                               nBaseItemType == BASE_ITEM_SPELLSCROLL)
                            {
                                sSpellIcon = Get2DAString("iprp_spells", "Icon", nIprpSubType);
                                sBaseName = "Scroll";
                            }
                            else
                            {
                                if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                                   nBaseItemType == BASE_ITEM_POTIONS) sBaseName = "Potion";
                                else if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
                                        nBaseItemType == BASE_ITEM_MAGICWAND ||
                                        nBaseItemType == FEAT_CRAFT_WAND) sBaseName = "Wand";
                                else sBaseName = ai_StripColorCodes(GetName(GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)))));
                                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                            }
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                            int nUses = ai_GetItemUses(oItem, nIprpSubType);
                            if(nUses)
                            {
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                                if(nUses == 999) sText = "Unlimited";
                                else sText = IntToString(nUses);
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sBaseName + " / " + sText + ")"));
                            }
                            else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                        }
                        else jWidget = JsonArrayDel(jWidget, nIndex--);
                    }
                    else if(nFeat) // This is a feat.
                    {
                        nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                        sSpellIcon = "";
                        if(nSpell)
                        {
                            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                            sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        }
                        if(sSpellIcon == "" || sSpellIcon == "IR_USE")
                        {
                            sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                            sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                        }
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                        if(GetHasFeat(nFeat, oAssociate))
                        {
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName));
                        }
                        else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                    }
                    else // This is a spell.
                    {
                        nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
                        nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
                        nMetaMagic = JsonGetInt(JsonArrayGet(jSpell, 3));
                        nDomain = JsonGetInt(JsonArrayGet(jSpell, 4));
                        sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        //SendMessageToPC(oPC, GetName(oAssociate) + " nSpell: " + IntToString(nSpell) +
                        //                " nClass: " + IntToString(nClass) + " nMetaMagic: " + IntToString(nMetaMagic) +
                        //                " nDomain: " + IntToString(nDomain) + " nLevel: " + IntToString(nLevel));
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_image", JsonString(sSpellIcon));
                        sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                        NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
                        sSubSpell = Get2DAString("spells", "Master", nSpell);
                        if(sSubSpell != "") nSpell = StringToInt(sSubSpell);
                        if(nClass == 255)
                        {
                            nSAIndex = JsonGetInt(JsonArrayGet(jSpell, 6));
                            if(GetSpellAbilityReady(oAssociate, nSAIndex))
                            {
                                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                                NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (Special Ability / " + IntToString(nLevel) + ")"));
                            }
                        }
                        else if(GetSpellUsesLeft(oAssociate, nClass, nSpell, nMetaMagic, nDomain))
                        {
                            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                            sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                            NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevel) + ")"));
                        }
                        else NuiSetBind(oPC, nToken, "btn_widget_" + sIndex + "_event", JsonBool(FALSE));
                    }
                }
                else break;
                ++nIndex;
            }
        }
    }
}
void ai_CreateWidgetNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0f, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    if(sAssociateType == "") return;
    int bAIWidgetLock = ai_GetWidgetButton(oPC, BTN_WIDGET_LOCK, oAssociate, sAssociateType);
    int bVertical = ai_GetWidgetButton(oPC, BTN_WIDGET_VERTICAL, oAssociate, sAssociateType);
    float fButtons;
    // ************************************************************************* Width / Height
    // Row 1 (buttons)**********************************************************
    // Setup the main associate button to use their portrait.
    json jButton = NuiEnabled(NuiId (NuiButtonImage(NuiBind("btn_open_main_image")), "btn_open_main"), NuiBind("btn_open_main_event"));
    jButton = NuiWidth(jButton, 35.0);
    jButton = NuiHeight(jButton, 35.0);
    jButton = NuiMargin(jButton, 0.0);
    jButton = NuiTooltip(jButton, NuiBind ("btn_open_main_tooltip"));
    jButton = NuiImageRegion(jButton, NuiRect(0.0, 0.0, 32.0, 35.0));
    json jRow = JsonArrayInsert(JsonArray(), jButton);
    if(ai_GetWidgetButton(oPC, BTN_ASSOC_WIDGETS_OFF, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_invite", "btn_toggle_assoc_widget", 35.0f, 35.0f, 0.0, "btn_toggle_assoc_widget_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_CAMERA, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_examine", "btn_camera", 35.0f, 35.0f, 0.0, "btn_camera_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_ACTION, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_action", "btn_cmd_action", 35.0f, 35.0f, 0.0, "btn_cmd_action_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_GUARD, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_guard", "btn_cmd_guard", 35.0f, 35.0f, 0.0, "btn_cmd_guard_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_HOLD, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_standground", "btn_cmd_hold", 35.0f, 35.0f, 0.0, "btn_cmd_hold_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_ATTACK, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_attacknearest", "btn_cmd_attack", 35.0f, 35.0f, 0.0, "btn_cmd_attack_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_FOLLOW, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_follow", "btn_cmd_follow", 35.0f, 35.0f, 0.0, "btn_cmd_follow_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_FOLLOW_TARGET, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_dmchat", "btn_follow_target", 35.0f, 35.0f, 0.0, "btn_follow_target_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_SEARCH, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ife_foc_search", "btn_cmd_search", 35.0f, 35.0f, 0.0, "btn_cmd_search_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_STEALTH, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ife_foc_hide", "btn_cmd_stealth", 35.0f, 35.0f, 0.0, "btn_cmd_stealth_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_AI_SCRIPT, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "", "btn_cmd_ai_script", 35.0f, 35.0f, 0.0, "btn_cmd_ai_script_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_PLACE_TRAP, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_settrap", "btn_cmd_place_trap", 35.0f, 35.0f, 0.0, "btn_cmd_place_trap_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_SHORT, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_cantrips", "btn_buff_short", 35.0f, 35.0f, 0.0, "btn_buff_short_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_LONG, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_cast", "btn_buff_long", 35.0f, 35.0f, 0.0, "btn_buff_long_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_ALL, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_level789", "btn_buff_all", 35.0f, 35.0f, 0.0, "btn_buff_all_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_BUFF_REST, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_rest", "btn_buff_rest", 35.0f, 35.0f, 0.0, "btn_buff_rest_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_JUMP_TO, oAssociate, sAssociateType))
    {
        string sImage;
        if(oPC == oAssociate) sImage = "dm_jumpall";
        else sImage = "dm_jump";
        jRow = CreateButtonImage(jRow, sImage, "btn_jump_to", 35.0f, 35.0f, 0.0, "btn_jump_to_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_GHOST_MODE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "dm_limbo", "btn_ghost_mode", 35.0f, 35.0f, 0.0, "btn_ghost_mode_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_INVENTORY, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_pickup", "btn_inventory", 35.0f, 35.0f, 0.0, "btn_inventory_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_FAMILIAR, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ife_familiar", "btn_familiar", 35.0f, 35.0f, 0.0, "btn_familiar_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetWidgetButton(oPC, BTN_CMD_COMPANION, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ife_animal", "btn_companion", 35.0f, 35.0f, 0.0, "btn_companion_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_FOR_PC, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "dm_ai", "btn_ai", 35.0f, 35.0f, 0.0, "btn_ai_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_REDUCE_SPEECH, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_movsilent", "btn_quiet", 35.0f, 35.0f, 0.0, "btn_quiet_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_RANGED, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_archer", "btn_ranged", 35.0f, 35.0f, 0.0, "btn_ranged_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_WEAPON_EQUIP, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "dm_takeitem", "btn_equip_weapon", 35.0f, 35.0f, 0.0, "btn_equip_weapon_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_SEARCH, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_search", "btn_search", 35.0f, 35.0f, 0.0, "btn_search_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_USE_STEALTH, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_hide", "btn_stealth", 35.0f, 35.0f, 0.0, "btn_stealth_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_OPEN_DOORS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_open", "btn_open_door", 35.0f, 35.0f, 0.0, "btn_open_door_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_REMOVE_TRAPS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_distrap", "btn_traps", 35.0f, 35.0f, 0.0, "btn_traps_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_PICK_LOCKS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_olock", "btn_pick_locks", 35.0f, 35.0f, 0.0, "btn_pick_locks_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_BASH_LOCKS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_bash", "btn_bash_locks", 35.0f, 35.0f, 0.0, "btn_bash_locks_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_MAGIC_LEVEL, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "dm_control", "btn_magic_level", 35.0f, 35.0f, 0.0, "btn_magic_level_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_SPONTANEOUS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_xability", "btn_spontaneous", 35.0f, 35.0f, 0.0, "btn_spontaneous_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_USE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_cntrspell", "btn_magic", 35.0f, 35.0f, 0.0, "btn_magic_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_NO_MAGIC_ITEM_USE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_moreattacks", "btn_magic_items", 35.0f, 35.0f, 0.0, "btn_magic_items_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_DEF_MAGIC_USE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_orisons", "btn_def_magic", 35.0f, 35.0f, 0.0, "btn_def_magic_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_OFF_MAGIC_USE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_metamagic", "btn_off_magic", 35.0f, 35.0f, 0.0, "btn_off_magic_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_HEAL_OUT, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "isk_heal", "btn_heal_out", 35.0f, 35.0f, 0.0, "btn_heal_out_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_HEAL_IN, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "dm_heal", "btn_heal_in", 35.0f, 35.0f, 0.0, "btn_heal_in_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_SELF_HEALING, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_heal", "btn_heals_onoff", 35.0f, 35.0f, 0.0, "btn_heals_onoff_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_PARTY_HEALING, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_party", "btn_healp_onoff", 35.0f, 35.0f, 0.0, "btn_healp_onoff_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_STOP_CURE_SPELLS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_accept", "btn_cure_onoff", 35.0f, 35.0f, 0.0, "btn_cure_onoff_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_LOOT, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_barter", "btn_loot", 35.0f, 35.0f, 0.0, "btn_loot_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_IGNORE_ASSOCIATES, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_ignore", "btn_ignore_assoc", 35.0f, 35.0f, 0.0, "btn_ignore_assoc_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_IGNORE_TRAPS, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_abort", "btn_ignore_traps", 35.0f, 35.0f, 0.0, "btn_ignore_traps_tooltip");
        fButtons += 1.0;
    }
    if(ai_GetAIButton(oPC, BTN_AI_PERC_RANGE, oAssociate, sAssociateType))
    {
        jRow = CreateButtonImage(jRow, "ir_dmchat", "btn_perc_range", 35.0f, 35.0f, 0.0, "btn_perc_range_tooltip");
        fButtons += 1.0;
    }
    int bIsPC = ai_GetIsCharacter(oAssociate);
    if(bIsPC)
    {
        json jPCPlugins = ai_UpdatePluginsForPC(oPC);
        // Plug in buttons *****************************************************
        int nIndex, bWidget;
        string sIcon, sButton;
        json jPlugin = JsonArrayGet(jPCPlugins, nIndex);
        while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
        {
            bWidget = JsonGetInt(JsonArrayGet(jPlugin, 1));
            if(bWidget)
            {
                sIcon = JsonGetString(JsonArrayGet(jPlugin, 3));
                sButton = IntToString(nIndex);
                jRow = CreateButtonImage(jRow, sIcon, "btn_exe_plugin_" + sButton, 35.0f, 35.0f, 0.0, "btn_exe_plugin_" + sButton + "_tooltip");
                fButtons += 1.0;
            }
            jPlugin = JsonArrayGet(jPCPlugins, ++nIndex);
        }
    }
    float fHeight, fWidth;
    if(bAIWidgetLock)
    {
        fWidth = 50.0f;
        fHeight = 50.0;
    }
    else if(bVertical)
    {
        fWidth = 88.0f;
        fHeight = 55.0f;
    }
    else
    {
        fWidth = 55.0f;
        fHeight = 88.0f;
    }
    // Quick Widget.
    int nIndex, nSpell, nLevel, nMetaMagic;
    float fQuickWidgetColumns;
    string sClass, sLevel, sIndex;
    object oItem;
    json jSpell;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jWidget = JsonArrayGet(jSpells, 2);
    json jCol = JsonArray();
    if(ai_GetWidgetButton(oPC, BTN_CMD_SPELL_WIDGET, oAssociate, sAssociateType) &&
       JsonGetLength(jWidget) > 0)
    {
        // Row 2 (Widget Row 1)*************************************************
        if(JsonGetType(jWidget) != JSON_TYPE_NULL)
        {
            fQuickWidgetColumns += 1.0;
            int bAdd;
            float fSpellButtons;
            json jButton, jRectangle, jMetaMagic, jDrawList;
            // Add row to the column.
            if(bVertical) jCol = JsonArrayInsert(jCol, NuiCol(jRow));
            else jCol = JsonArrayInsert(jCol, NuiRow(jRow));
            jRow = CreateButtonImage(JsonArray(), "ir_back", "btn_update_widget", 35.0f, 35.0f, 0.0, "btn_update_widget_tooltip");
            //CreateLabel(jRow, "", "blank_label", 35.0, 35.0, 0, 0, 0.0);
            while(nIndex < 10)
            {
                bAdd = TRUE;
                jSpell = JsonArrayGet(jWidget, nIndex);
                if(JsonGetType(jSpell) != JSON_TYPE_NULL)
                {
                    if(JsonGetInt(JsonArrayGet(jSpell, 1)) == -1)
                    {
                        oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                        if(oItem == OBJECT_INVALID)
                        {
                            bAdd = FALSE;
                            jWidget = JsonArrayDel(jWidget, nIndex--);
                            jSpells = JsonArrayInsert(jSpells, jWidget, 2);
                            jAIData = JsonArrayInsert(jAIData, jSpells, 10);
                            ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                        }
                    }
                    if(bAdd)
                    {
                        sIndex = IntToString(nIndex);
                        jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
                        jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
                        jButton = NuiId(jButton, "btn_widget_" + sIndex);
                        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
                        jButton = NuiMargin(jButton, 0.0);
                        jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
                        jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
                        jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
                        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
                        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
                        jRow = JsonArrayInsert(jRow, jButton);
                        fSpellButtons += 1.0;
                    }
                }
                else break;
                ++nIndex;
            }
            if(fSpellButtons > fButtons) fButtons = fSpellButtons;
            // Row 3 (Widget Row 2)*************************************************
            if(nIndex > 9  && JsonGetLength(jWidget) > 10)
            {
                fQuickWidgetColumns += 1.0;
                // Add row to the column.
                if(bVertical) jCol = JsonArrayInsert(jCol, NuiCol(jRow));
                else jCol = JsonArrayInsert(jCol, NuiRow(jRow));
                jRow = CreateLabel(JsonArray(), "", "blank_label", 35.0, 35.0, 0, 0, 0.0);
                while(nIndex < 20)
                {
                    jSpell = JsonArrayGet(jWidget, nIndex);
                    if(JsonGetType(jSpell) != JSON_TYPE_NULL)
                    {
                        if(JsonGetInt(JsonArrayGet(jSpell, 1)) == -1)
                        {
                            oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                            if(oItem == OBJECT_INVALID)
                            {
                                bAdd = FALSE;
                                jWidget = JsonArrayDel(jWidget, nIndex--);
                                jSpells = JsonArrayInsert(jSpells, jWidget, 2);
                                jAIData = JsonArrayInsert(jAIData, jSpells, 10);
                                ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
                            }
                        }
                        if(bAdd)
                        {
                            sIndex = IntToString(nIndex);
                            jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
                            jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
                            jButton = NuiId(jButton, "btn_widget_" + sIndex);
                            jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
                            jButton = NuiMargin(jButton, 0.0);
                            jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
                            jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
                            jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
                            jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
                            jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
                            jRow = JsonArrayInsert(jRow, jButton);
                            fSpellButtons += 1.0;
                        }
                    }
                    else break;
                    ++nIndex;
                }
            }
        }
        // Add the row to the column.
        if(nIndex > 0)
        {
            if(bVertical) jCol = JsonArrayInsert(jCol, NuiCol(jRow));
            else jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        }
    }
    else
    {
        // Add the row to the column.
        if(bVertical) jCol = JsonArrayInsert(jCol, NuiCol(jRow));
        else jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    }
    float fScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE) / 100.0;
    float fButtonScale;
    // 1.1 = 2.5  2.0 = 6.0 Ranges we need for scales to work correctly.
    if(fScale > 1.0) fButtonScale = (fScale - 1.1) / (2.0 - 1.1) * 3.5 + 2.5;
    else fButtonScale = 1.0;
    if(fButtons > 0.0f)
    {
        if(bVertical) fWidth = fWidth + fButtons * 35.0f + fButtons * fButtonScale;
        else fWidth = fWidth + fButtons * 35.0f;
    }
    if(fQuickWidgetColumns > 0.0f)
    {
        if(bVertical) fHeight = fHeight + fQuickWidgetColumns * 39.0f;
        else fHeight = fHeight + fQuickWidgetColumns * 39.0f + fQuickWidgetColumns * fButtonScale;
    }
    // Get the window location to restore it from the database.
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    //SendMessageToPC(oPC, "0i_menu, 2124, sAssociateType: " + sAssociateType + " jLocations: " + JsonDump(jLocations, 1));
    if(JsonGetType(jLocations) == JSON_TYPE_NULL)
    {
        ai_SetupAssociateData(oPC, oAssociate, sAssociateType);
        jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    }
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_WIDGET_NUI);
    float fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    // Keeps the widgets from bunching up in the top corner.
    if(fY == 0.0 && fX == 0.0)
    {
        if(sAssociateType == "pc") fY = 1.0;
        else if(sAssociateType == "familiar") fY = 96.0 * fScale;
        else if(sAssociateType == "companion") fY = 192.0 * fScale;
        else if(sAssociateType == "summons") fY = 288.0 * fScale;
        else if(sAssociateType == "dominated") fY = 384.0 * fScale;
        else
        {
            int nIndex = 1;
            string sAssociateName = GetName(oAssociate);
            while(nIndex < AI_MAX_HENCHMAN)
            {
                if(sAssociateName == GetName(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex)))
                {
                    fY = (88.0 + 88.0 * IntToFloat(nIndex - 1));
                    break;
                }
                nIndex++;
            }
        }
        fY = fY * fScale;
    }
    if(bAIWidgetLock)
    {
        fX += 4.0f;
        // GUI scales are a mess, I just figured them out per scale to keep the widget from moving.
        if(fScale == 1.0) fY += 37.0;
        else if(fScale == 1.1) fY += 38.0;
        else if(fScale == 1.2) fY += 40.0;
        else if(fScale == 1.3) fY += 42.0;
        else if(fScale == 1.4) fY += 43.0;
        else if(fScale == 1.5) fY += 45.0;
        else if(fScale == 1.6) fY += 47.0;
        else if(fScale == 1.7) fY += 48.0;
        else if(fScale == 1.8) fY += 50.0;
        else if(fScale == 1.9) fY += 52.0;
        else if(fScale == 2.0) fY += 54.0;
    }
    // Set the layout of the window.
    json jLayout;
    int nToken, bBool;
    string sHeal, sText, sRange;
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    if(bVertical)
    {
        jLayout = NuiRow(jCol);
        if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, sAssociateType + AI_WIDGET_NUI, "AI Widget", fX, fY, fHeight, fWidth, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui");
        else nToken = SetWindow(oPC, jLayout, sAssociateType + AI_WIDGET_NUI, sName + " Widget", fX, fY, fHeight, fWidth, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui");
}
    else
    {
        jLayout = NuiCol(jCol);
        if(bAIWidgetLock) nToken = SetWindow(oPC, jLayout, sAssociateType + AI_WIDGET_NUI, "AI Widget", fX, fY, fWidth, fHeight, FALSE, FALSE, FALSE, TRUE, FALSE, "0e_nui");
        else nToken = SetWindow(oPC, jLayout, sAssociateType + AI_WIDGET_NUI, sName + " Widget", fX, fY, fWidth, fHeight, FALSE, FALSE, FALSE, TRUE, TRUE, "0e_nui");
    }
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    ai_SetWidgetBinds(oPC, oAssociate, sAssociateType, nToken, sName);
}
json ai_CreateLootFilterRow(json jRow, string sLabel, int nIndex)
{
    string sIndex = IntToString(nIndex);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateTextEditBox(jRow, "plc_hold", "txt_gold_" + sIndex, 9, FALSE, 90.0, 20.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateCheckBox(jRow, sLabel, "chbx_" + sIndex, 190.0, 20.0);
    return JsonArrayInsert(jRow, NuiSpacer());
}
void ai_SetupLootElements(object oPC, object oAssociate, int nToken, int nLootBit, int nIndex)
{
    string sIndex = IntToString(nIndex);
    int bLoot = ai_GetLootFilter(oAssociate, nLootBit);
    NuiSetBind(oPC, nToken, "chbx_" + sIndex + "_check", JsonBool(bLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_" + sIndex + "_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_" + sIndex + "_event", JsonBool(TRUE));
    string sGold = IntToString(GetLocalInt(oAssociate, AI_MIN_GOLD_ + sIndex));
    NuiSetBind(oPC, nToken, "txt_gold_" + sIndex + "_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_gold_" + sIndex, JsonString(sGold));
    NuiSetBindWatch (oPC, nToken, "txt_gold_" + sIndex, TRUE);
}
void ai_CreateLootFilterNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 1 ******************************************************************* 318 / 73
    int bIsPC = ai_GetIsCharacter(oAssociate);
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateCheckBox(jRow, "Give all loot to the player", "chbx_give_loot", 200.0, 20.0, "chbx_give_loot_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 *************************************************************** 388 / 101
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateTextEditBox(jRow, "plc_hold", "txt_max_weight", 9, FALSE, 50.0, 20.0, "txt_max_weight_tooltip");
    jRow = CreateLabel(jRow, "Maximum Weight to pickup", "lbl_weight", 200.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 *************************************************************** 388 / 129
    jRow = CreateButton(JsonArray(), "Set All", "btn_set_all", 110.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 110.0f, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Clear All", "btn_clear_all", 110.0, 30.0);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 *************************************************************** 388 / 129
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Minimum Gold", "lbl_min_gold", 100.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateLabel(jRow, "Items to Pickup", "lbl_pickup", 140.0, 20.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 *************************************************************** 388 / 157
    jRow = ai_CreateLootFilterRow(JsonArray(), "Plot items", 2);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 *************************************************************** 388 / 185
    jRow = ai_CreateLootFilterRow(JsonArray(), "Armor", 3);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 7 *************************************************************** 388 / 213
    jRow = ai_CreateLootFilterRow(JsonArray(), "Belts", 4);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 8 *************************************************************** 388 / 241
    jRow = ai_CreateLootFilterRow(JsonArray(), "Boots", 5);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 9 *************************************************************** 388 / 269
    jRow = ai_CreateLootFilterRow(JsonArray(), "Cloaks", 6);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 10 *************************************************************** 388 / 297
    jRow = ai_CreateLootFilterRow(JsonArray(), "Gems", 7);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 11 *************************************************************** 388 / 325
    jRow = ai_CreateLootFilterRow(JsonArray(), "Gloves and Bracers", 8);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 12 *************************************************************** 388 / 353
    jRow = ai_CreateLootFilterRow(JsonArray(), "Headgear", 9);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 13 *************************************************************** 388 / 381
    jRow = ai_CreateLootFilterRow(JsonArray(), "Jewelry", 10);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 14 *************************************************************** 388 / 409
    jRow = ai_CreateLootFilterRow(JsonArray(), "Miscellaneous items", 11);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 15 *************************************************************** 388 / 437
    jRow = ai_CreateLootFilterRow(JsonArray(), "Potions", 12);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 16 *************************************************************** 388 / 465
    jRow = ai_CreateLootFilterRow(JsonArray(), "Scrolls", 13);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 17 *************************************************************** 388 / 493
    jRow = ai_CreateLootFilterRow(JsonArray(), "Shields", 14);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 18 *************************************************************** 388 / 521
    jRow = ai_CreateLootFilterRow(JsonArray(), "Wands, Rods, and Staves", 15);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 19 ************************************************************** 388 / 549
    jRow = ai_CreateLootFilterRow(JsonArray(), "Weapons", 16);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 20 ************************************************************** 388 / 577
    jRow = ai_CreateLootFilterRow(JsonArray(), "Arrows", 17);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 21 ************************************************************** 388 / 605
    jRow = ai_CreateLootFilterRow(JsonArray(), "Bolts", 18);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 22 ************************************************************** 388 / 633
    jRow = ai_CreateLootFilterRow(JsonArray(), "Bullets", 19);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 661.0;
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_LOOTFILTER_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_LOOTFILTER_NUI, sName + " Loot Filter",
                           fX, fY, 350.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 1
    int bGiveLoot = ai_GetLootFilter(oAssociate, AI_LOOT_GIVE_TO_PC);
    NuiSetBind(oPC, nToken, "chbx_give_loot_check", JsonBool (bGiveLoot));
    NuiSetBindWatch (oPC, nToken, "chbx_give_loot_check", TRUE);
    NuiSetBind(oPC, nToken, "chbx_give_loot_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "chbx_give_loot_tooltip", JsonString(
               "  Check this to make henchman give any loot picked up to the player."));
    // Row 2
    int nWeight = GetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT);
    if(nWeight == 0)
    {
        nWeight = 200;
        SetLocalInt(oAssociate, AI_MAX_LOOT_WEIGHT, nWeight);
    }
    NuiSetBind(oPC, nToken, "txt_max_weight_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_max_weight", JsonString(IntToString(nWeight)));
    NuiSetBindWatch (oPC, nToken, "txt_max_weight", TRUE);
    NuiSetBind(oPC, nToken, "txt_max_weight_tooltip", JsonString("  Max weighted item you will pickup from 1 to 1,000"));
    // Row 3
    NuiSetBind(oPC, nToken, "btn_set_all_event", JsonBool (TRUE));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_all_event", JsonBool (TRUE));
    // Row 4
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_PLOT, 2);
    // Row 5
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARMOR, 3);
    // Row 6
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BELTS, 4);
    // Row 7
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOOTS, 5);
    // Row 8
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_CLOAKS, 6);
    // Row 9
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GEMS, 7);
    // Row 10
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_GLOVES, 8);
    // Row 11
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_HEADGEAR, 9);
    // Row 12
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_JEWELRY, 10);
    // Row 13
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_MISC, 11);
    // Row 14
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_POTIONS, 12);
    // Row 15
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SCROLLS, 13);
    // Row 16
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_SHIELDS, 14);
    // Row 17
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WANDS_RODS_STAVES, 15);
    // Row 18
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_WEAPONS, 16);
    // Row 19
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_ARROWS, 17);
    // Row 20
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BOLTS, 18);
    // Row 21
    ai_SetupLootElements(oPC, oAssociate, nToken, AI_LOOT_BULLETS, 19);
}
json ai_CreateHenchmanPasteButton(object oPC, int nIndex, json jRow)
{
    string sName, sIndex = IntToString(nIndex);
    object oHenchman = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
    if(oHenchman != OBJECT_INVALID)
    {
        sName = GetName(oHenchman);
        if(GetStringRight(sName, 1) == "s") sName = sName + "'";
        else sName = sName + "'s";
        return CreateButton(jRow, sName, "btn_paste_henchman" + sIndex, 220.0, 30.0);
    }
    return jRow;
}
void ai_CreateCopySettingsNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    // ************************************************************************* Width / Height
    // Row 0 ******************************************************************* 244 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 220.0f, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 1 ******************************************************************* 244 / 108
    string sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Copy settings to", "lbl_paste", 220.0, 30.0, NUI_HALIGN_CENTER);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 146
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "All associates", "btn_paste_all", 220.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 2 ******************************************************************* 244 / 184
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Familiar", "btn_paste_familiar", 220.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 ******************************************************************* 244 / 222
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Companion", "btn_paste_companion", 220.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 ******************************************************************* 244 / 260
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Summons", "btn_paste_summons", 220.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 ******************************************************************* 244 / 298
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Dominated", "btn_paste_dominated", 220.0, 30.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6+ ****************************************************************** 244 / 336
    float fHeight = 336.0;
    int nIndex;
    for(nIndex = 1; nIndex < 7; nIndex++)
    {
        jRow = JsonArray();
        ai_CreateHenchmanPasteButton(oPC, nIndex, jRow);
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
    }
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_COPY_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_COPY_NUI, sName + " Copy Settings Menu",
                           fX, fY, 244.0, fHeight + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui.
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Set all binds, events, and watches.
    // Row 0
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 1
    NuiSetBind(oPC, nToken, "btn_paste_all_event", JsonBool (TRUE));
    object oCreature = GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_familiar_event", JsonBool(oCreature != oAssociate));
    oCreature = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_companion_event", JsonBool(oCreature != oAssociate));
    oCreature = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_summons_event", JsonBool(oCreature != oAssociate));
    oCreature = GetAssociate(ASSOCIATE_TYPE_DOMINATED, oPC);
    NuiSetBind(oPC, nToken, "btn_paste_dominated_event", JsonBool(oCreature != oAssociate));
    for(nIndex = 1; nIndex < AI_MAX_HENCHMAN; nIndex++)
    {
        oCreature = GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, nIndex);
        if(oCreature != OBJECT_INVALID)
        {
            NuiSetBind(oPC, nToken, "btn_paste_henchman" + IntToString(nIndex) + "_event", JsonBool(oCreature != oAssociate));
        }
    }
}
void ai_CreatePluginNUI(object oPC)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    int nIndex, nButton;
    string sButton;
   // Row 1 ******************************************************************* 500 / 73
    json jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Load All Plugins", "btn_load_plugins", 150.0f, 30.0f, -1.0, "btn_load_plugins_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Check All", "btn_check_plugins", 105.0f, 30.0f, -1.0, "btn_check_plugins_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Clear All", "btn_clear_plugins", 105.0f, 30.0f, -1.0, "btn_clear_plugins_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 105.0f, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 ******************************************************************* 500 / 101
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "Add Plugin", "btn_add_plugin", 150.0f, 30.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateTextEditBox(jRow, "sPlaceHolder", "txt_plugin", 16, FALSE, 310.0f, 30.0f, "txt_plugin_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    float fHeight = 121.0;
    // Row 3+ ****************************************************************** 500 / ---
    nIndex = 0;
    string sName;
    json jPlugins = ai_GetAssociateDbJson(oPC, "pc", "plugins");
    json jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        sButton = IntToString(nIndex);
        jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
        jRow = CreateButton(jRow, "Remove Plugin", "btn_remove_plugin_" + sButton, 150.0f, 30.0f);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        sName = JsonGetString(JsonArrayGet(jPlugin, 2));
        jRow = CreateButton(jRow, sName, "btn_plugin_" + sButton, 290.0f, 30.0f, -1.0, "btn_plugin_" + sButton + "_tooltip");
        jRow = CreateCheckBox(jRow, "", "chbx_plugin_" + sButton, 25.0, 30.0);
        jRow = JsonArrayInsert(jRow, NuiSpacer());
        // Add row to the column.
        jCol = JsonArrayInsert(jCol, NuiRow(jRow));
        fHeight += 38.0;
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, "pc", "locations");
    jLocations = JsonObjectGet(jLocations, AI_PLUGIN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    sName = GetName(oPC);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, AI_PLUGIN_NUI, sName + " PEPS Plugin Manager",
                             fX, fY, 500.0f, fHeight + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    // Row 1
    NuiSetBind(oPC, nToken, "btn_load_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_load_plugins_tooltip", JsonString("  Load all known PEPS plugins that are in the game files."));
    NuiSetBind(oPC, nToken, "btn_check_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_check_plugins_tooltip", JsonString("  Add all plugins to the players widget."));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_clear_plugins_tooltip", JsonString("  Remove all plugins from the players widget."));
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_add_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "txt_plugin_tooltip", JsonString("  Enter an executable script name."));
    // Row 3+
    nIndex = 0;
    int bCheck;
    string sText;
    jPlugin = JsonArrayGet(jPlugins, nIndex);
    while(JsonGetType(jPlugin) != JSON_TYPE_NULL)
    {
        sButton = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_remove_plugin_" + sButton + "_event", JsonBool(TRUE));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_event", JsonBool(TRUE));
        bCheck = JsonGetInt(JsonArrayGet(jPlugin, 1));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_check", JsonBool(bCheck));
        NuiSetBind(oPC, nToken, "chbx_plugin_" + sButton + "_event", JsonBool(TRUE));
        NuiSetBindWatch (oPC, nToken, "chbx_plugin_" + sButton + "_check", TRUE);
        sText = "  " + JsonGetString(JsonArrayGet(jPlugin, 2));
        NuiSetBind(oPC, nToken, "btn_plugin_" + sButton + "_tooltip", JsonString(sText));
        jPlugin = JsonArrayGet(jPlugins, ++nIndex);
    }
}
int ai_SpellNotInList(int nSpell, json jSpellArray)
{
    int nMaxArray = JsonGetLength(jSpellArray);
    int nIndex;
    while(nIndex < nMaxArray)
    {
        if(nSpell == JsonGetInt(JsonArrayGet(JsonArrayGet(jSpellArray, nIndex), 0))) return FALSE;
        nIndex++;
    }
    return TRUE;
}
json ai_CheckItemAbilities(json jQuickListArray, object oCreature, object oItem, json jSpell_Icon, json jSpell_Text, int bEquiped = FALSE)
{
    // We have established that we can use the item if it is equiped.
    if(!bEquiped && !ai_CheckIfCanUseItem(oCreature, oItem)) return jQuickListArray;
    int nPerDay, nCharges, nUses, bSaveTalent;
    int nBaseItemType, nIprpSubType, nSpell, nLevel, nIPType, nIndex;
    string sSpellIcon, sSpellName;
    itemproperty ipProp = GetFirstItemProperty(oItem);
    json jSpell;
    // Lets skip this if there are no properties.
    if(!GetIsItemPropertyValid(ipProp)) return jQuickListArray;
    // Check for cast spell property and add them to the talent list.
    while(GetIsItemPropertyValid(ipProp))
    {
        nIPType = GetItemPropertyType(ipProp);
        if(nIPType == ITEM_PROPERTY_CAST_SPELL)
        {
            bSaveTalent = TRUE;
            // Get how they use the item (charges or uses per day).
            nUses = GetItemPropertyCostTableValue(ipProp);
            if(nUses > 1 && nUses < 7)
            {
                nCharges = GetItemCharges(oItem);
                if((nUses == IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE && nCharges < 1) ||
                   (nUses == IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE && nCharges < 2) ||
                   (nUses == IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE && nCharges < 3) ||
                   (nUses == IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE && nCharges < 4) ||
                   (nUses == IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE && nCharges < 5)) bSaveTalent = FALSE;
            }
            else if(nUses > 7 && nUses < 13)
            {
                nPerDay = GetItemPropertyUsesPerDayRemaining(oItem, ipProp);
                if(AI_DEBUG) ai_Debug("0i_talents", "1676", "Item uses: " + IntToString(nPerDay));
                if(nPerDay == 0) bSaveTalent = FALSE;
            }
            if(bSaveTalent)
            {
                // SubType is the ip spell index for iprp_spells.2da
                nIprpSubType = GetItemPropertySubType(ipProp);
                nSpell = StringToInt(Get2DAString("iprp_spells", "SpellIndex", nIprpSubType));
                nBaseItemType = GetBaseItemType(oItem);
                if(nBaseItemType == BASE_ITEM_ENCHANTED_SCROLL ||
                   nBaseItemType == BASE_ITEM_SCROLL ||
                   nBaseItemType == BASE_ITEM_SPELLSCROLL)
                {
                    sSpellIcon = Get2DAString("iprp_spells", "Icon", nIprpSubType);
                    sSpellName = ai_StripColorCodes(GetName(oItem));
                    nUses = GetNumStackedItems(oItem);
                }
                else
                {
                    if(nBaseItemType == BASE_ITEM_ENCHANTED_POTION ||
                       nBaseItemType == BASE_ITEM_POTIONS)
                    {
                        sSpellName = ai_StripColorCodes(GetName(oItem));
                        nUses = GetNumStackedItems(oItem);
                    }
                    else if(nBaseItemType == BASE_ITEM_ENCHANTED_WAND ||
                       nBaseItemType == BASE_ITEM_MAGICWAND ||
                       nBaseItemType == FEAT_CRAFT_WAND)
                    {
                        sSpellName = ai_StripColorCodes(GetName(oItem));
                        nUses = nCharges;
                    }
                    else
                    {
                        sSpellName = ai_StripColorCodes(GetName(oItem)) + ": ";
                        sSpellName += GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        if(nCharges) nUses = nCharges;
                        else nUses = nPerDay;
                    }
                    sSpellIcon = Get2DAString("spells", "iConResRef", nSpell);
                }
                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                jSpell = JsonArrayInsert(JsonArray(), JsonInt(nSpell));
                jSpell = JsonArrayInsert(jSpell, JsonInt(-1)); // Class is set to -1 for items
                jSpell = JsonArrayInsert(jSpell, JsonInt(nUses));
                jSpell = JsonArrayInsert(jSpell, JsonInt(nBaseItemType));
                jSpell = JsonArrayInsert(jSpell, JsonInt(nIprpSubType));
                jSpell = JsonArrayInsert(jSpell, JsonString(GetObjectUUID(oItem)));
                jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
            }
        }
        else if(nIPType == ITEM_PROPERTY_HEALERS_KIT)
        {
            // Must also have ranks in healing kits.
            if(GetSkillRank(SKILL_HEAL, oCreature) > 0)
            {
                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString("isk_heal"));
                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(ai_StripColorCodes(GetName(oItem))));
                jSpell = JsonArrayInsert(JsonArray(), JsonInt(SPELL_HEALINGKIT));
                jSpell = JsonArrayInsert(jSpell, JsonInt(-1)); // Class is set to -1 for items
                jSpell = JsonArrayInsert(jSpell, JsonInt(GetNumStackedItems(oItem)));
                jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                jSpell = JsonArrayInsert(jSpell, JsonInt(GetItemPropertyCostTableValue(ipProp)));
                jSpell = JsonArrayInsert(jSpell, JsonString(GetObjectUUID(oItem)));
                jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
            }
        }
        nIndex++;
        ipProp = GetNextItemProperty(oItem);
    }
    SetLocalJson(oCreature, "JSPELL_ICON", jSpell_Icon);
    SetLocalJson(oCreature, "JSPELL_NAME", jSpell_Text);
    return jQuickListArray;
}
void ai_CreateQuickWidgetSelectionNUI(object oPC, object oAssociate)
{
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 88
    int nClass, nLevel, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            // This saves the class position in the button id so we can get it later.
            sIndex = IntToString(nIndex);
            sClassIcon = Get2DAString("classes", "Icon", nClass);
            jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 131
    jRow = CreateButtonImage(JsonArray(), "", "btn_level_11" , 35.0f, 35.0f, 0.0, "btn_level_11_tooltip");
    jRow = CreateButtonImage(jRow, "", "btn_level_10" , 35.0f, 35.0f, 0.0, "btn_level_10_tooltip");
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell List)******************************************************* 414 / 433
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
    json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_text"));
    jDrawList = JsonArrayInsert(jDrawList, jMetaMagic);
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 345.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 282.0));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 461
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Quick Widget List", "lbl_quick_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Widget row 1)***************************************************** 414 / 504
    jRow = JsonArray();
    for(nIndex = 0; nIndex < 10; nIndex++)
    {
        // This saves the index location in the json jWidget in the button id for later use.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_widget_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
        json jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
        json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 6 (Widget row 2)***************************************************** 414 / 543
    jRow = JsonArray();
    for(nIndex = 10; nIndex < 20; nIndex++)
    {
        // This saves the index location in the json jWidget in the button id for later use.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_widget_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_widget_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_widget_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_widget_" + sIndex + "_tooltip"));
        json jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
        json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
        jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_QUICK_WIDGET_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_QUICK_WIDGET_NUI, sName + " Quick Widget Menu",
                           fX, fY, 414.0, 543.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Get the class and level selected from the database.
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jClassSelected = JsonArrayGet(jSpells, 0);
    if(JsonGetType(jClassSelected) == JSON_TYPE_NULL)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        nClass = 1;
        nLevel = 0;
    }
    else
    {
        nClass = JsonGetInt(jClassSelected);
        nLevel = JsonGetInt(JsonArrayGet(jSpells, 1));
    }
    if(nClass < 1 || nClass > AI_MAX_CLASSES_PER_CHARACTER) nClass = 1;
    nClass = GetClassByPosition(nClass, oAssociate);
    // Row 1 & 2 Class & Level
    int nSpellLevel, nLevelIndex, nClassIndex, nMaxSpellLevel;
    string sClass, sLevel, sLevelImage, sLevelIndex;
    NuiSetBind(oPC, nToken, "btn_level_11_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_11_tooltip", JsonString("  Item Powers"));
    NuiSetBind(oPC, nToken, "btn_level_11_image", JsonString("ir_attack"));
    NuiSetBind(oPC, nToken, "btn_level_10_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "btn_level_10_tooltip", JsonString("  Special Abilities"));
    NuiSetBind(oPC, nToken, "btn_level_10_image", JsonString("dm_god"));
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClassIndex = GetClassByPosition(nIndex, oAssociate);
        if(nClassIndex != CLASS_TYPE_INVALID)
        {
            sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClassIndex)));
            sIndex = IntToString(nIndex);
            NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
            NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
            if(nClass == nClassIndex)
            {
                if(StringToInt(Get2DAString("classes", "SpellCaster", nClass)))
                {
                    int nClassLevel = ai_GetCasterTotalLevel(oAssociate, nClass);
                    string sSpellsGained = Get2DAString("classes", "SpellGainTable", nClass);
                    int nMaxSpellLevel = StringToInt(Get2DAString(sSpellsGained, "NumSpellLevels", nClassLevel - 1));
                    for(nLevelIndex = 0; nLevelIndex <= 9; nLevelIndex++)
                    {
                        sLevelIndex = IntToString(nLevelIndex);
                        if(nLevelIndex < nMaxSpellLevel)
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                            if(nLevelIndex == 0) sLevelImage = "ir_cantrips";
                            else if(nLevelIndex < 7)sLevelImage = "ir_level" + sLevelIndex;
                            else sLevelImage = "ir_level789";
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString(sLevelImage));
                            if(nLevelIndex == 0) sLevel = " Cantrips";
                            else if(nLevelIndex == 1) sLevel = " First level";
                            else if(nLevelIndex == 2) sLevel = " Second level";
                            else if(nLevelIndex == 3) sLevel = " Third level";
                            else if(nLevelIndex == 4) sLevel = " Fourth level";
                            else if(nLevelIndex == 5) sLevel = " Fifth level";
                            else if(nLevelIndex == 6) sLevel = " Sixth level";
                            else if(nLevelIndex == 7) sLevel = " Seventh level";
                            else if(nLevelIndex == 8) sLevel = " Eighth level";
                            else if(nLevelIndex == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_tooltip", JsonString("  " + sLevel));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevel) + "_encouraged", JsonBool(TRUE));
                }
                // Default to the abilities tab since they are not a caster.
                else
                {
                    if(nLevel < 10) nLevel = 10;
                    for(nLevelIndex = 0; nLevelIndex <= 9; nLevelIndex++)
                    {
                        sLevelIndex = IntToString(nLevelIndex);
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(TRUE));
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                        NuiSetBind(oPC, nToken, "btn_level_" + sLevelIndex + "_event", JsonBool(FALSE));
                    }
                    NuiSetBind(oPC, nToken, "btn_level_10_encouraged", JsonBool(TRUE));
                }
                NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClass) + "_encouraged", JsonBool(TRUE));
            }
        }
    }
    // Row 3 Items/Abilities/Skills/Spells
    int nSpell, nMetaMagic, nDomain, nSubSpell, nSubSpellIndex;
    int nSpellSlot, nCounter, nMax2daRow, nFeat;
    string sSpellIcon, sSpellName, sMetaMagicText, sClassFeats, sSubSpellIndex;
    object oItem;
    json jQuickListArray = JsonArray();
    json jSpell;
    json jSpell_Icon = JsonArray();
    json jSpell_Text = JsonArray();
    SetLocalJson(oAssociate, "JSPELL_ICON", jSpell_Icon);
    SetLocalJson(oAssociate, "JSPELL_NAME", jSpell_Text);
    json jMetaMagic_Text = JsonArray();
    // Item powers
    if(nLevel == 11)
    {
        string sSlots;
        // Cycle through all the creatures inventory items.
        oItem = GetFirstItemInInventory(oAssociate);
        while(oItem != OBJECT_INVALID)
        {
            if(GetIdentified(oItem))
            {
                // Does the item need to be equiped to use its powers?
                sSlots = Get2DAString("baseitems", "EquipableSlots", GetBaseItemType(oItem));
                if(sSlots == "0x00000")
                {
                    jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, FALSE);
                    jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
                    jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
                    //WriteTimestampedLogEntry("0i_menus, 3643, oAssociate: " + GetName(oAssociate) +
                    //     " jSpell_Text: " + JsonDump(jSpell_Text, 4));
                }
            }
            oItem = GetNextItemInInventory(oAssociate);
        }
        int nSlot;
        // Cycle through all the creatures equiped items.
        oItem = GetItemInSlot(nSlot, oAssociate);
        while(nSlot < 11)
        {
            if(oItem != OBJECT_INVALID)
            {
                jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, TRUE);
                jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
                jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
            }
            oItem = GetItemInSlot(++nSlot, oAssociate);
        }
        oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oAssociate);
        if(oItem != OBJECT_INVALID)
        {
            jQuickListArray = ai_CheckItemAbilities(jQuickListArray, oAssociate, oItem, jSpell_Icon, jSpell_Text, TRUE);
            jSpell_Icon = GetLocalJson(oAssociate, "JSPELL_ICON");
            jSpell_Text = GetLocalJson(oAssociate, "JSPELL_NAME");
        }
        DeleteLocalJson(oAssociate, "JSPELL_ICON");
        DeleteLocalJson(oAssociate, "JSPELL_NAME");
    }
    // Special abilities and skills.
    else if(nLevel == 10)
    {
        json jCreature = ObjectToJson(oAssociate);
        json jFeatList = GffGetList(jCreature, "FeatList");
        int nIndex, nSuccessor;
        json jFeat = JsonArrayGet(jFeatList, nIndex);
        while(JsonGetType(jFeat) != JSON_TYPE_NULL)
        {
            nFeat = JsonGetInt(GffGetWord(jFeat, "Feat"));
            if(Get2DAString("feat", "USESPERDAY", nFeat) != "" ||
               Get2DAString("feat", "HostileFeat", nFeat) != "")
            {
                // Check for subfeats.
                nSpell = StringToInt(Get2DAString("feat", "SPELLID", nFeat));
                nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                //SendMessageToPC(oPC, "nFeat: " + IntToString(nFeat) +
                //            " nSpell: " + IntToString(nSpell) +
                //            " nSubSpell: " + IntToString(nSubSpell));
                if(nSubSpell)
                {
                    for(nSubSpellIndex = 1; nSubSpellIndex <= 5; nSubSpellIndex++)
                    {
                        sSubSpellIndex = IntToString(nSubSpellIndex);
                        nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                        //SendMessageToPC(oPC, " nSpell: " + IntToString(nSpell) +
                        //            " nSubSpell: " + IntToString(nSubSpell));
                        if(nSubSpell != 0)
                        {
                            sSpellIcon = Get2DAString("spells", "iConResRef", nSubSpell);
                            jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                            sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                            jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                            jSpell = JsonArray();
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nSubSpell));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(-1)); // Level
                            jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // MetaMagic
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nFeat));
                            jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        }
                    }
                }
                else if((nFeat < 71 || nFeat > 81))
                {
                    nSuccessor = StringToInt(Get2DAString("feat", "SUCCESSOR", nFeat));
                    if(nSuccessor && GetHasFeat(nSuccessor, oAssociate, TRUE))
                    { /* Don't do anything we just skip adding this feat. */}
                    else
                    {
                        sSpellIcon = Get2DAString("feat", "ICON", nFeat);
                        jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                        jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                        jSpell = JsonArray();
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Level
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // MetaMagic
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nFeat));
                        jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                    }
                }
            }
            jFeat = JsonArrayGet(jFeatList, ++nIndex);
        }
        // Checks for monsters special abilities.
        int nCounter = 0, nPreviousSpell = -1, nMaxSpellAbility = GetSpellAbilityCount(oAssociate);
        while(nCounter < nMaxSpellAbility)
        {
            nSpell = GetSpellAbilitySpell(oAssociate, nCounter);
            if(nPreviousSpell != nSpell)
            {
                nPreviousSpell = nSpell;
                // Check for subfeats.
                nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                if(nSubSpell)
                {
                    for(nSubSpellIndex = 1; nSubSpellIndex <= 5; nSubSpellIndex++)
                    {
                        sSubSpellIndex = IntToString(nSubSpellIndex);
                        nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                        if(nSubSpell != 0)
                        {
                            sSpellIcon = Get2DAString("spells", "iConResRef", nSubSpell);
                            jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                            sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                            jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                            jSpell = JsonArray();
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nSubSpell));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Level
                            jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // MetaMagic
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Domain
                            jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // Feat
                            jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        }
                    }
                }
                else
                {
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                    jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                    sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                    sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                    jMetaMagic_Text = JsonArrayInsert(jMetaMagic_Text, JsonString(sMetaMagicText));
                    jSpell = JsonArray();
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nSpell));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(255)); // Class - Special abilities is always 255.
                    jSpell = JsonArrayInsert(jSpell, JsonInt(GetSpellAbilityCasterLevel(oAssociate, nCounter)));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // metamagic
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // domain
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0)); // feat
                    // Index of Special ability on monster.
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nCounter));
                    jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                    //SendMessageToPC(oPC, "nSpell: " + IntToString(nSpell) +
                    //               " sSpellIcon: " + sSpellIcon +
                    //               " sSpellName: " + sSpellName+
                    //               " nMaxSlot: " + IntToString(nMaxSpellAbility) +
                    //               " nSpellAbilityIndex: " + IntToString(nCounter));
                }
            }
            nCounter++;
        }
        // Used in the execution script to get the special abilities.
        //jData = JsonArrayInsert(jData, jQuickListArray);
    }
    else // Anything else is for spells.
    {
        // Search all memorized spells for the spell.
        //SendMessageToPC(oPC, GetName(oAssociate) + " nClass: " + IntToString(nClass) +
        //               " nLevelSelected: " + IntToString(nLevel) +
        //               " nMemorizesSpells: " + Get2DAString("classes", "MemorizesSpells", nClass));
        if(Get2DAString("classes", "MemorizesSpells", nClass) == "1")
        {
            int nMaxSlot = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevel);
            while(nSpellSlot < nMaxSlot)
            {
                nSpell = GetMemorizedSpellId(oAssociate, nClass, nLevel, nSpellSlot);
                if(nSpell != -1 && ai_SpellNotInList(nSpell, jQuickListArray))
                {
                    nMetaMagic = GetMemorizedSpellMetaMagic(oAssociate, nClass, nLevel, nSpellSlot);
                    nDomain = GetMemorizedSpellIsDomainSpell(oAssociate, nClass, nLevel, nSpellSlot);
                    // Check for subspells.
                    nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell1", nSpell));
                    if(nSubSpell)
                    {
                        for(nSubSpellIndex = 1; nSubSpellIndex < 6; nSubSpellIndex++)
                        {
                            sSubSpellIndex = IntToString(nSubSpellIndex);
                            nSubSpell = StringToInt(Get2DAString("spells", "SubRadSpell" + sSubSpellIndex, nSpell));
                            if(nSubSpell  && ai_SpellNotInList(nSubSpell, jQuickListArray))
                            {
                                sSpellIcon = Get2DAString("spells", "IconResRef", nSubSpell);
                                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                                sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSubSpell)));
                                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                                sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                                jMetaMagic_Text = JsonArrayInsert(jMetaMagic_Text, JsonString(sMetaMagicText));
                                jSpell = JsonArrayInsert(JsonArray(), JsonInt(nSubSpell));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nMetaMagic));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(nDomain));
                                jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                                jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                            }
                        }
                    }
                    else
                    {
                        sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                        jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                        sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                        jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                        sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nMetaMagic, nDomain);
                        jMetaMagic_Text = JsonArrayInsert(jMetaMagic_Text, JsonString(sMetaMagicText));
                        jSpell = JsonArrayInsert(JsonArray(), JsonInt(nSpell));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nMetaMagic));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(nDomain));
                        jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                        jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                        //SendMessageToPC(oPC, "nSpell: " + IntToString(nSpell) +
                        //               " sSpellIcon: " + sSpellIcon +
                        //               " sSpellName: " + sSpellName+
                        //               " nMaxSlot: " + IntToString(nMaxSlot) +
                        //               " nSpellSlot: " + IntToString(nSpellSlot));
                    }
                }
                ++nSpellSlot;
            }
        }
        // Non-memorized spells.
        else
        {
            int nMaxSlot = GetKnownSpellCount(oAssociate, nClass, nLevel);
            while(nSpellSlot < nMaxSlot)
            {
                nSpell = GetKnownSpellId(oAssociate, nClass, nLevel, nSpellSlot);
                if(nSpell != -1)// && ai_SpellNotInList(nSpell, jQuickListArray))
                {
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                    jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                    sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                    jSpell = JsonArrayInsert(JsonArray(), JsonInt(nSpell));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nClass));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(nLevel));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(255));
                    jSpell = JsonArrayInsert(jSpell, JsonInt(0));
                    jQuickListArray = JsonArrayInsert(jQuickListArray, jSpell);
                }
                ++nSpellSlot;
            }
        }
    }
    NuiSetBind(oPC, nToken, "icon_spell", jSpell_Icon);
    NuiSetBind(oPC, nToken, "text_spell", jSpell_Text);
    NuiSetBind(oPC, nToken, "metamagic_text", jMetaMagic_Text);
    jData = JsonArrayInsert(jData, jQuickListArray);
    NuiSetUserData(oPC, nToken, jData);
    // Row 4 Quick widget list label.
    // Row 5 Quick widget List 1
    ai_PopulateWidgetList(oPC, oAssociate, nToken, JsonArrayGet(jSpells, 2));
}
void ai_CreateSpellMemorizationNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 73
    int nClass, bCaster, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            if(StringToInt(Get2DAString("classes", "MemorizesSpells", nClass)))
            {
                // This saves the class position in the button id so we can get it later.
                sIndex = IntToString(nIndex);
                sClassIcon = Get2DAString("classes", "Icon", nClass);
                jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
            }
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 116
    jRow = JsonArray();
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell List)******************************************************* 414 / 398
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    //jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
    //json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_text"));
    //jDrawList = JsonArrayInsert(jDrawList, jMetaMagic);
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 275.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 282.0));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 426
    jRow = JsonArray();
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateLabel(jRow, "Memorized Spell List", "lbl_spell_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Memorize slots)*************************************************** 414 / 469
    // Get the class and level selected from the database.
    int nClassSelected, nLevelSelected;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jClassSelected = JsonArrayGet(jSpells, 0);
    if(JsonGetType(jClassSelected) == JSON_TYPE_NULL)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        nClassSelected = 1;
        nLevelSelected = 0;
    }
    else
    {
        nClassSelected = JsonGetInt(jClassSelected);
        nLevelSelected = JsonGetInt(JsonArrayGet(jSpells, 1));
    }
    // If we left the Quick Use widget on Special Abilities (10) or Items (11) goto level 0
    if(nLevelSelected == 10 || nLevelSelected == 11)
    {
        nLevelSelected = 0;
        jSpells = JsonArraySet(jSpells, 1, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    if(nClassSelected < 1 || nClassSelected > AI_MAX_CLASSES_PER_CHARACTER) nClassSelected = 1;
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    int nMaxMemorizationSlots = GetMemorizedSpellCountByLevel(oAssociate, nClass, nLevelSelected);
    jRow = JsonArray();
    for(nIndex = 0; nIndex < nMaxMemorizationSlots; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_memorized_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_memorized_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_memorized_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_memorized_" + sIndex + "_tooltip"));
        //json jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
        //json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
        //jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        //jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_SPELL_MEMORIZE_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_SPELL_MEMORIZE_NUI, sName + " Spell Memorization Menu",
                           fX, fY, 375.0, 504.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 1 & 2 Class & Level
    int nSpellLevel, nIndexLevel, nMaxSpellLevel;
    string sClass, sLevel, sLevelImage, sIndexLevel;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            bCaster = StringToInt(Get2DAString("classes", "SpellCaster", nClass));
            if(bCaster)
            {
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                sIndex = IntToString(nIndex);
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
                if(nClassSelected == nIndex)
                {
                    int nClassLevel = GetLevelByClass(nClass, oAssociate);
                    string sSpellsGained = Get2DAString("classes", "SpellGainTable", nClass);
                    int nMaxSpellLevel = StringToInt(Get2DAString(sSpellsGained, "NumSpellLevels", nClassLevel - 1));
                    for(nIndexLevel = 0; nIndexLevel <= 9; nIndexLevel++)
                    {
                        sIndexLevel = IntToString(nIndexLevel);
                        if(nIndexLevel < nMaxSpellLevel)
                        {
                            if(nIndexLevel == 0) sLevelImage = "ir_cantrips";
                            else if(nIndexLevel < 7)sLevelImage = "ir_level" + sIndexLevel;
                            else sLevelImage = "ir_level789";
                            if(nIndexLevel == 0) sLevel = " Cantrips";
                            else if(nIndexLevel == 1) sLevel = " First level";
                            else if(nIndexLevel == 2) sLevel = " Second level";
                            else if(nIndexLevel == 3) sLevel = " Third level";
                            else if(nIndexLevel == 4) sLevel = " Fourth level";
                            else if(nIndexLevel == 5) sLevel = " Fifth level";
                            else if(nIndexLevel == 6) sLevel = " Sixth level";
                            else if(nIndexLevel == 7) sLevel = " Seventh level";
                            else if(nIndexLevel == 8) sLevel = " Eighth level";
                            else if(nIndexLevel == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_tooltip", JsonString("  " + sLevel));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString(sLevelImage));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevelSelected) + "_encouraged", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClassSelected) + "_encouraged", JsonBool(TRUE));
                }
            }
        }
    }
    // Row 3 Spells
    int nSpellSlot, nSpell, nMetamagic;
    json jSpell;
    json jWidget = JsonArrayGet(jSpells, 2);
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    string sSpellIcon, sSpellName, sMetaMagicText;
    json jSpellArray = JsonArray();
    json jSpell_Icon = JsonArray();
    json jSpell_Text = JsonArray();
    json jMetaMagic_Text = JsonArray();
    // List the spells they know from their spellbook.
    if(Get2DAString("classes", "SpellbookRestricted", nClass) == "1")
    {
        int nMaxSpells = GetKnownSpellCount(oAssociate, nClass, nLevelSelected);
        //WriteTimestampedLogEntry("Maxspells: " + IntToString(nMaxSpells) +
        //                         " nClass: " + IntToString(nClass) +
        //                         " nLevelSelected: " + IntToString(nLevelSelected));
        while(nSpellSlot < nMaxSpells)
        {
            nSpell = GetKnownSpellId(oAssociate, nClass, nLevelSelected, nSpellSlot);
            if(nSpell != -1)
            {
                jSpellArray = JsonArrayInsert(jSpellArray, JsonInt(nSpell));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                //SendMessageToPC(oPC, "SpellBook: nSpell: " + IntToString(nSpell) +
                //               " sSpellIcon: " + sSpellIcon +
                //               " sSpellName: " + sSpellName+
                //               " nMaxSpells: " + IntToString(nMaxSpells) +
                //               " nSpellSlot: " + IntToString(nSpellSlot));
                //sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, nClass, nLevelSelected, nSpellSlot);
                //jMetaMagic_Text = JsonArrayInsert(jMetaMagic_Text, JsonString(sMetaMagicText));
                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
            }
            ++nSpellSlot;
        }
    }
    // List the spells from the spells.2da file (they get to choose from them all!).
    else
    {
        string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
        int nMaxSpells = Get2DARowCount("spells");
        while(nSpell < nMaxSpells)
        {
            sLevel = Get2DAString("spells", sSpellTableColumn, nSpell);
            if(sLevel != "")
            {
                if(StringToInt(sLevel) == nLevelSelected)
                {
                    jSpellArray = JsonArrayInsert(jSpellArray, JsonInt(nSpell));
                    sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                    sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                    jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                    jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
                   }
            }
            ++nSpell;
        }
    }
    jData = JsonArrayInsert(jData, jSpellArray);
    NuiSetUserData(oPC, nToken, jData);
    NuiSetBind(oPC, nToken, "icon_spell", jSpell_Icon);
    NuiSetBind(oPC, nToken, "text_spell", jSpell_Text);
    NuiSetBind(oPC, nToken, "metamagic_text", jMetaMagic_Text);
    // Row 4 Spell memorized list label.
    // Row 5 Spell memorized List
    int nMetaMagic, nDomain;
    nIndex = 0;
    while(nIndex < nMaxMemorizationSlots)
    {
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(TRUE));
        if(GetMemorizedSpellId(oAssociate, nClass, nLevelSelected, nIndex) > -1)
        {
            nSpell = GetMemorizedSpellId(oAssociate, nClass, nLevelSelected, nIndex);
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            //nMetaMagic = 255;
            //nDomain = 0;
            sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString(sSpellIcon));
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevelSelected) + ")"));
            //sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, -1, -1, -1, nMetaMagic, nDomain);
            //NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            //NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_memorized_" + sIndex + "_event", JsonBool(FALSE));
        }
        ++nIndex;
    }
}
void ai_CreateSpellKnownNUI(object oPC, object oAssociate)
{
    // Set window to not save until it has been created.
    SetLocalInt (oPC, AI_NO_NUI_SAVE, TRUE);
    DelayCommand (2.0, DeleteLocalInt (oPC, AI_NO_NUI_SAVE));
    string sAssociateType = ai_GetAssociateType(oPC, oAssociate);
    json jRow = JsonArray();
    // Row 1 Classes************************************************************ 414 / 73
    int nClass, bCaster, nIndex;
    string sIndex, sClassIcon, sLevelIcon;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            if(StringToInt(Get2DAString("classes", "SpellbookRestricted", nClass)))
            {
                // This saves the class position in the button id so we can get it later.
                sIndex = IntToString(nIndex);
                sClassIcon = Get2DAString("classes", "Icon", nClass);
                jRow = CreateButtonImage(jRow, sClassIcon, "btn_class_" + sIndex, 35.0f, 35.0f, 0.0, "btn_class_" + sIndex + "_tooltip");
            }
        }
    }
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    jRow = CreateButton(jRow, "Close", "btn_close", 100.0f, 35.0f);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 2 (Levels) ********************************************************** 414 / 116
    jRow = JsonArray();
    for(nIndex = 0; nIndex <= 9; nIndex++)
    {
        // This saves the level in the button id so we can get it later.
        sIndex = IntToString(nIndex);
        jRow = CreateButtonImage(jRow, "", "btn_level_" + sIndex, 35.0f, 35.0f, 0.0, "btn_level_" + sIndex + "_tooltip");
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 3 (Spell List)******************************************************* 414 / 398
    json jButton = JsonArray();
    jButton = NuiButton(NuiBind("text_spell"));
    jButton = NuiId(jButton, "btn_text_spell");
    json jRectangle = NuiRect(4.0, 4.0, 27.0, 27.0);
    json jDrawList = JsonArrayInsert(JsonArray(), NuiDrawListImage(JsonBool(TRUE), NuiBind("icon_spell"), jRectangle, JsonInt(NUI_ASPECT_FILL), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)));
    //jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
    //json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_text"));
    //jDrawList = JsonArrayInsert(jDrawList, jMetaMagic);
    jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
    json jListTemplate = JsonArrayInsert(JsonArray(), NuiListTemplateCell(jButton, 275.0, FALSE));
    json jInfo = NuiButtonImage(JsonString("gui_cg_qstn_mark"));
    jInfo = NuiId(jInfo, "btn_info_spell");
    jListTemplate = JsonArrayInsert(jListTemplate, NuiListTemplateCell(jInfo, 35.0, FALSE));
    jRow = JsonArrayInsert(JsonArray(), NuiHeight(NuiList(jListTemplate, NuiBind("icon_spell"), 35.0), 282.0));
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 4 (Widget Label)***************************************************** 414 / 426
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    CreateLabel(jRow, "Known Spell List", "lbl_spell_list", 150.0, 20.0, 0, 0, 0.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Row 5 (Memorize slots)*************************************************** 414 / 469
    // Get the class and level selected from the database.
    int nClassSelected, nLevelSelected;
    json jAIData = ai_GetAssociateDbJson(oPC, sAssociateType, "aidata");
    json jSpells = JsonArrayGet(jAIData, 10);
    json jClassSelected = JsonArrayGet(jSpells, 0);
    if(JsonGetType(jClassSelected) == JSON_TYPE_NULL)
    {
        jSpells = JsonArray();
        jSpells = JsonArrayInsert(jSpells, JsonInt(1));
        jSpells = JsonArrayInsert(jSpells, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
        nClassSelected = 1;
        nLevelSelected = 0;
    }
    else
    {
        nClassSelected = JsonGetInt(jClassSelected);
        nLevelSelected = JsonGetInt(JsonArrayGet(jSpells, 1));
    }
    // If we left the Quick Use widget on Special Abilities (10) or Items (11) goto level 0
    if(nLevelSelected == 10 || nLevelSelected == 11)
    {
        nLevelSelected = 0;
        jSpells = JsonArraySet(jSpells, 1, JsonInt(0));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    if(nClassSelected < 1 || nClassSelected > AI_MAX_CLASSES_PER_CHARACTER)
    {
        nClassSelected = 1;
        jSpells = JsonArraySet(jSpells, 0, JsonInt(1));
        jAIData = JsonArraySet(jAIData, 10, jSpells);
        ai_SetAssociateDbJson(oPC, sAssociateType, "aidata", jAIData);
    }
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    jRow = JsonArray();
    for(nIndex = 0; nIndex < 10; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_known_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_known_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_known_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_known_" + sIndex + "_tooltip"));
        //json jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
        //json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
        //jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        //jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Do the second row.
    jRow = JsonArray();
    for(nIndex = 10; nIndex < 20; nIndex++)
    {
        // This saves the index location of the spell in the list.
        sIndex = IntToString(nIndex);
        json jButton = NuiButtonImage(NuiBind("btn_known_" + sIndex + "_image"));
        jButton = NuiEnabled(jButton, NuiBind("btn_known_" + sIndex + "_event"));
        jButton = NuiId(jButton, "btn_known_" + sIndex);
        jButton = NuiWidth(NuiHeight(jButton, 35.0), 35.0);
        jButton = NuiMargin(jButton, 0.0);
        jButton = NuiTooltip(jButton, NuiBind("btn_known_" + sIndex + "_tooltip"));
        //json jRectangle = NuiRect(4.0, 4.0, 10.0, 10.0);
        //json jMetaMagic = NuiDrawListText(JsonBool(TRUE), NuiColor(255, 255, 0), jRectangle, NuiBind("metamagic_" + sIndex + "_text"));
        //jDrawList = JsonArrayInsert(JsonArray(), jMetaMagic);
        //jButton = NuiDrawList(jButton, JsonBool(TRUE), jDrawList);
        jRow = JsonArrayInsert(jRow, jButton);
    }
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Get the window location to restore it from the database.
    float fX, fY;
    json jLocations = ai_GetAssociateDbJson(oPC, sAssociateType, "locations");
    jLocations = JsonObjectGet(jLocations, sAssociateType + AI_SPELL_KNOWN_NUI);
    if(JsonGetType(jLocations) == JSON_TYPE_NULL) { fX = -1.0; fY = -1.0; }
    else
    {
        fX = JsonGetFloat(JsonObjectGet(jLocations, "x"));
        fY = JsonGetFloat(JsonObjectGet(jLocations, "y"));
    }
    string sText, sName = GetName(oAssociate);
    if(GetStringRight(sName, 1) == "s") sName = sName + "'";
    else sName = sName + "'s";
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    int nToken = SetWindow(oPC, jLayout, sAssociateType + AI_SPELL_KNOWN_NUI, sName + " Spell Known Menu",
                           fX, fY, 375.0, 539.0 + 12.0, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    // Set the Layout of the window.
    // Save the associate to the nui for use in 0e_nui
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oAssociate)));
    // Set event watches for save window location.
    NuiSetBindWatch(oPC, nToken, "window_geometry", TRUE);
    NuiSetBind(oPC, nToken, "btn_close_event", JsonBool(TRUE));
    // Row 1 & 2 Class & Level
    int nSpellLevel, nIndexLevel, nMaxSpellLevel, nClassLevel;
    string sClass, sLevel, sLevelImage, sIndexLevel, sSpellsGained;
    for(nIndex = 1; nIndex <= AI_MAX_CLASSES_PER_CHARACTER; nIndex++)
    {
        nClass = GetClassByPosition(nIndex, oAssociate);
        if(nClass != CLASS_TYPE_INVALID)
        {
            bCaster = StringToInt(Get2DAString("classes", "SpellbookRestricted", nClass));
            if(bCaster)
            {
                sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));
                sIndex = IntToString(nIndex);
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_event", JsonBool(TRUE));
                NuiSetBind(oPC, nToken, "btn_class_" + sIndex + "_tooltip", JsonString("  " + sClass));
                if(nClassSelected == nIndex)
                {
                    nClassLevel = GetLevelByClass(nClass, oAssociate);
                    sSpellsGained = Get2DAString("classes", "SpellGainTable", nClass);
                    nMaxSpellLevel = StringToInt(Get2DAString(sSpellsGained, "NumSpellLevels", nClassLevel - 1));
                    for(nIndexLevel = 0; nIndexLevel <= 9; nIndexLevel++)
                    {
                        sIndexLevel = IntToString(nIndexLevel);
                        if(nIndexLevel < nMaxSpellLevel)
                        {
                            if(nIndexLevel == 0) sLevelImage = "ir_cantrips";
                            else if(nIndexLevel < 7)sLevelImage = "ir_level" + sIndexLevel;
                            else sLevelImage = "ir_level789";
                            if(nIndexLevel == 0) sLevel = " Cantrips";
                            else if(nIndexLevel == 1) sLevel = " First level";
                            else if(nIndexLevel == 2) sLevel = " Second level";
                            else if(nIndexLevel == 3) sLevel = " Third level";
                            else if(nIndexLevel == 4) sLevel = " Fourth level";
                            else if(nIndexLevel == 5) sLevel = " Fifth level";
                            else if(nIndexLevel == 6) sLevel = " Sixth level";
                            else if(nIndexLevel == 7) sLevel = " Seventh level";
                            else if(nIndexLevel == 8) sLevel = " Eighth level";
                            else if(nIndexLevel == 9) sLevel = " Ninth level";
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_tooltip", JsonString("  " + sLevel));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString(sLevelImage));
                        }
                        else
                        {
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(TRUE));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_image", JsonString("ctl_cg_btn_splvl"));
                            NuiSetBind(oPC, nToken, "btn_level_" + sIndexLevel + "_event", JsonBool(FALSE));
                        }
                    }
                    NuiSetBind(oPC, nToken, "btn_level_" + IntToString(nLevelSelected) + "_encouraged", JsonBool(TRUE));
                    NuiSetBind(oPC, nToken, "btn_class_" + IntToString(nClassSelected) + "_encouraged", JsonBool(TRUE));
                }
            }
        }
    }
    // Row 3 Spells
    int nSpellSlot, nSpell, nMetamagic;
    json jSpell;
    json jWidget = JsonArrayGet(jSpells, 2);
    nClass = GetClassByPosition(nClassSelected, oAssociate);
    string sSpellIcon, sSpellName, sMetaMagicText;
    json jSpellArray = JsonArray();
    json jSpell_Icon = JsonArray();
    json jSpell_Text = JsonArray();
    json jMetaMagic_Text = JsonArray();
    // List the spells from the spells.2da file (they get to choose from them all!).
    string sSpellTableColumn = Get2DAString("classes", "SpellTableColumn", nClass);
    int nMaxSpells = Get2DARowCount("spells");
    while(nSpell < nMaxSpells)
    {
        sLevel = Get2DAString("spells", sSpellTableColumn, nSpell);
        if(sLevel != "")
        {
            if(StringToInt(sLevel) == nLevelSelected)
            {
                jSpellArray = JsonArrayInsert(jSpellArray, JsonInt(nSpell));
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                sSpellName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                jSpell_Icon = JsonArrayInsert(jSpell_Icon, JsonString(sSpellIcon));
                jSpell_Text = JsonArrayInsert(jSpell_Text, JsonString(sSpellName));
            }
        }
        ++nSpell;
    }
    jData = JsonArrayInsert(jData, jSpellArray);
    NuiSetUserData(oPC, nToken, jData);
    NuiSetBind(oPC, nToken, "icon_spell", jSpell_Icon);
    NuiSetBind(oPC, nToken, "text_spell", jSpell_Text);
    NuiSetBind(oPC, nToken, "metamagic_text", jMetaMagic_Text);
    // Row 4 Spell known list label.
    // Row 5 Spell known List
    int nMetaMagic, nDomain, nMaxKnownSlots;
    json jClassList = GetLocalJson(oAssociate, AI_CLASS_LIST_JSON);
    if(JsonGetType(jClassList) == JSON_TYPE_NULL)
    {
        jClassList = ObjectToJson(oAssociate);
        jClassList = GffGetList(jClassList, "ClassList");
        SetLocalJson(oAssociate, AI_CLASS_LIST_JSON, jClassList);
    }
    // Get the correct class array.
    nIndex = 0;
    json jClass = JsonArrayGet(jClassList, nIndex);
    while(JsonGetInt(GffGetInt(jClass, "Class")) != nClass)
    {
        jClass = JsonArrayGet(jClassList, ++nIndex);
    }
    json jKnownList = GffGetList(jClass, "KnownList" + IntToString(nLevelSelected));
    string sSpellKnownTable = Get2DAString("classes", "SpellKnownTable", nClass);
    if(sSpellKnownTable != "") nMaxKnownSlots = StringToInt(Get2DAString(sSpellKnownTable, "SpellLevel" + IntToString(nLevelSelected), nClassLevel - 1));
    else nMaxKnownSlots = 20;
    nIndex = 0;
    while(nIndex < 20)
    {
        sIndex = IntToString(nIndex);
        NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_event", JsonBool(TRUE));
        if(nIndex < nMaxKnownSlots)
        {
            jSpell = JsonArrayGet(jKnownList, nIndex);
            if(JsonGetType(jSpell) == JSON_TYPE_NULL)
            {
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_tooltip", JsonString("  Empty known spell slot"));
            }
            else
            {
                nSpell = JsonGetInt(GffGetWord(jSpell, "Spell"));
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                //nMetaMagic = 255;
                //nDomain = 0;
                sSpellIcon = Get2DAString("spells", "IconResRef", nSpell);
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString(sSpellIcon));
                NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_tooltip", JsonString("  " + sName + " (" + sClass + " / " + IntToString(nLevelSelected) + ")"));
                //sMetaMagicText = ai_GetSpellIconAttributes(oAssociate, -1, -1, -1, nMetaMagic, nDomain);
                //NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(sMetaMagicText));
            }
        }
        else
        {
            NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_image", JsonString("ctl_cg_btn_splvl"));
            //NuiSetBind(oPC, nToken, "metamagic_" + sIndex + "_text", JsonString(""));
            NuiSetBind(oPC, nToken, "btn_known_" + sIndex + "_event", JsonBool(FALSE));
        }
        ++nIndex;
    }
}
void ai_CreateDescriptionNUI(object oPC, json jSpell, int nSpell = 0)
{
    // Row 1 ******************************************************************* 500 / 469
    json jRow = CreateImage(JsonArray(), "", "spell_icon", NUI_ASPECT_FIT, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE, 40.0, 40.0);
    jRow = CreateTextBox(jRow, "spell_text", 380.0, 400.0, FALSE, NUI_SCROLLBARS_Y);
    // Add row to the column.
    json jCol = JsonArrayInsert(JsonArray(), NuiRow(jRow));
    // Row 1 ******************************************************************* 500 / 522
    jRow = JsonArrayInsert(JsonArray(), NuiSpacer());
    jRow = CreateButton(jRow, "OK", "btn_ok", 150.0f, 45.0f);
    // Add row to the column.
    jCol = JsonArrayInsert(jCol, NuiRow(jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol(jCol);
    string sName, sIcon, sDescription;
    int nFeat, nDescription;
    int nClass;
    if(nSpell) nClass = 0;
    else
    {
        nSpell = JsonGetInt(JsonArrayGet(jSpell, 0));
        nClass = JsonGetInt(JsonArrayGet(jSpell, 1));
    }
    if(nClass == -1)
    {
        if(nSpell == SPELL_HEALINGKIT)
        {
            sName = "Healer's Kit";
            sIcon = "isk_heal";
            sDescription = GetStringByStrRef(1720);
        }
        else
        {
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            sIcon = Get2DAString("spells", "IconResRef", nSpell);
            nDescription = StringToInt(Get2DAString("spells", "SpellDesc", nSpell));
            if(nDescription) sDescription = GetStringByStrRef(nDescription);
            else
            {
                object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                sDescription = GetDescription(oItem);
            }
        }
    }
    else
    {
        nFeat = JsonGetInt(JsonArrayGet(jSpell, 5));
        if(nFeat)
        {
            if(nSpell)
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
                sIcon = Get2DAString("spells", "IconResRef", nSpell);
            }
            else
            {
                sName = GetStringByStrRef(StringToInt(Get2DAString("feat", "FEAT", nFeat)));
                sIcon = Get2DAString("feat", "ICON", nFeat);
            }
            sDescription = GetStringByStrRef(StringToInt(Get2DAString("feat", "DESCRIPTION", nFeat)));
        }
        else
        {
            sName = GetStringByStrRef(StringToInt(Get2DAString("spells", "Name", nSpell)));
            sIcon = Get2DAString("spells", "IconResRef", nSpell);
            nDescription = StringToInt(Get2DAString("spells", "SpellDesc", nSpell));
            if(nDescription) sDescription = GetStringByStrRef(nDescription);
            else
            {
                object oItem = GetObjectByUUID(JsonGetString(JsonArrayGet(jSpell, 5)));
                sDescription = GetDescription(oItem);
            }
        }
    }
    int nToken = SetWindow(oPC, jLayout, AI_SPELL_DESCRIPTION_NUI, sName,
                             -1.0, -1.0, 460.0f, 537.0 + 12.0f, FALSE, FALSE, TRUE, FALSE, TRUE, "0e_nui");
    json jData = JsonArrayInsert(JsonArray(), JsonString(ObjectToString(oPC)));
    NuiSetUserData(oPC, nToken, jData);
    // Row 1
    NuiSetBind(oPC, nToken, "spell_icon_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "spell_icon_image", JsonString(sIcon));
    NuiSetBind(oPC, nToken, "spell_text_event", JsonBool(TRUE));
    NuiSetBind(oPC, nToken, "spell_text", JsonString(sDescription));
    // Row 2
    NuiSetBind(oPC, nToken, "btn_ok_event", JsonBool(TRUE));
}


