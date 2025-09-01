/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_nui
////////////////////////////////////////////////////////////////////////////////
 Include script for handling window displays.

 Use the following to get/set window information.
 string sBind = NuiGetNthBind (oPlayer, nToken, FALSE, #);
 json jMenuInfo = NuiGetBind (oPlayer, nToken, sBind);
 # Gets json information for window :
 0 - string - "window_title"
 1 - json - "window_geometry" : "h", "w", "x", "y"
 2 - bool - "window_resizable"
 3 - bool - "window_closable"
 4 - bool - "window_transparent"
 5 - bool - "window_border"

 Layout pixel sizes:
 Pixel height Title bar 33.
 Pixel height Top border 10, between widgets 8, bottom border 10.
 Pixel width Left border 10, between widgets 4, right border 10.

 Group outer lines add 12 to the vertical and horizontal lines.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "nw_inc_nui"
struct stComboBox
{
    json jIndex;
    json jCombo;
    json jRow;
    json jResRefArray;
    json jWinArray;
    json jCanSummon; // Index of all the summons in summons.2da
};

// Saves the menu to the campaign database.
void SaveMenuToCampaignDb(object oPC, int nToken, string sWndId);
// Returns the middle of the screen for the x position.
// oPC using the menu.
// fMenuWidth - the width of the menu to display.
float GetGUIWidthMiddle(object oPC, float fMenuWidth);

// Returns the middle of the screen for the y position.
// oPC using the menu.
// fMenuHeight - the height of the menu to display.
float GetGUIHeightMiddle(object oPC, float fMenuHeight);

// Checks to see if sWndId is open.
// If the window is open it removes it and returns FALSE
// If the window is closed it returns TRUE
int IsWindowClosed(object oPC, string sWndId);

// Returns the Window ID (nToken).
// oPC is the PC using the menu.
// jLayout is the Layout of the menu.
// sWinID is the string ID for this window.
// sTitle is the Title of the menu.
// fX is the X position of the menu (-1.0: Centers, -2.0: UpperRight on Mouse, -3.0: Centers top of mouse).
// fY is the Y position of the menu (-1.0: Centers, -2.0: UpperRight on Mouse, -3.0: Centers top of mouse).
// fWidth is the width of the menu.
// fHeight is the height of the menu.
// bResize - TRUE will all it to be resized.
// bCollapse - TRUE will allow the window to be collapsable.
// bClose - TRUE will allow the window to be closed.
// bTransparent - TRUE makes the menu transparent.
// bBorder - TRUE makes the menu have a border.
// sEventScript will fire this event script for this window.
int SetWindow(object oPC, json jLayout, string sWinID, string sTitle, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder, string sEventScript = "");

// Creates a label element in jRow.
// jRow is the row the label goes into.
// sLabel is the text placed in the label.
//     If "" is passed then it will create a bind of sId + "_label".
// fWidth is the width of the label.
// fHeight is the Height of the label.
// nHAlign is horizonal align [NUI_HALING_*].
// nVAlign is vertial align [NUI_VALING_*].
// sId is the bind the event uses sId + "_event".
// sTooltip is the tooltip bind value.
json CreateLabel(json jRow, string sLabel, string sId, float fWidth, float fHeight, int nHAlign = 0, int nVAlign = 0, float fMargin = -1.0, string sTooltip = "");

// Creates a basic button element in jRow.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the button.
// fHeight is the Height of the button.
// fMargin is the space around the button.
// sTooltip is the tooltip bind value.
json CreateButton(json jRow, string sLabel, string sId, float fWidth, float fHeight, float fMargin = -1.0, string sTooltip = "");

// Creates a basic button select element in jRow.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the button.
// fHeight is the Height of the button.
// sTooltip is the tooltip bind value.
json CreateButtonSelect(json jRow, string sLabel, string sId, float fWidth, float fHeight, string sToolTip = "");

// Creates a button element with an image in jRow.
// jRow is the row the label goes into.
// sImage is the resref of the image to use.
//     If "" is passed then it will create a bind of sId + "_image".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the button.
// fHeight is the Height of the button.
// fMargin is the space around the button.
// sTooltip is the tooltip bind value.
json CreateButtonImage(json jRow, string sResRef, string sId, float fWidth, float fHeight, float fMargin = -1.0, string sTooltip = "");

// Creates a basic text box that is not editable element in jRow.
// jRow is the row the TextEdit box goes into.
// sId is the bind variable so we can change the text.
// fWidth the width of the box.
// fHeight the height of the box.
// bBorder will add border TRUE or remove it FALSE.
// nScroll use NUI_SCROLLBARS_*
// sTooltip is the tooltip bind value.
json CreateTextBox(json jRow, string sId, float fWidth, float fHeight, int bBorder = TRUE, int nScroll = NUI_SCROLLBARS_AUTO, string sTooltip = "");

// Creates a basic text edit box element in jRow.
// jRow is the row the TextEdit box goes into.
// sPlaceHolderBind is the bind for Placeholder.
// sValueBind is the bind variable so we can change the text.
// nMaxLength is the maximum lenght of the text (1 - 65535)
// bMultiline - True or False that is has multiple lines.
// fWidth the width of the box.
// fHeight the height of the box.
// sTooltip is the tooltip bind value.
json CreateTextEditBox(json jRow, string sPlaceHolderBind, string sValueBind, int nMaxLength, int bMultiline, float fWidth, float fHeight, string sToolTip = "");

// Creates a combo box element in jRow.
// jRow is the row the combo goes into.
// jCombo is the elements/list for the combo box. Use NuiComboEntry to add.
// sId is the binds for the combo and the event uses sId + "_event"
//      sId + "_selected" is the bind for the selection in the combo box.
// fWidth is the width of the combo.
// fHeight is the Height of the combo.
// sTooltip is the tooltip bind value.
json CreateCombo(json jRow, json jCombo, string sId, float fWidth, float fHeight, string sToolTip = "");

// Creates an image element in jRow.
// jRow is the row the Image goes into.
// sImage is the resref of the image to use. If "" is passed then it will
// create a bind of sId + "_image".
// nAspect is the aspect of the image NUI_ASPECT_*.
// nHAlign is the horizontal alignment of the image NUI_HALIGN_*.
// nVAlign is the vertical alignment of the image NUI_VALIGN_*.
// fWidth the width of the box.
// fHeight the height of the box.
// sTooltip is the tooltip bind value.
json CreateImage(json jRow, string sResRef, string sId, int nAspect, int nHAlign, int nVAlign, float fWidth, float fHeight, float fMargin = -1.0, string sToolTip = "");

// Creates a check box element in jRow.
// jRow is the row the Checkbox box goes into.
// sLabel is the text placed in the label.
//     If "" is passed then it will create a bind of sId + "_label".
// sId is the bind variable so we can change the text.
//     sId + "_check" is the Bind:bool for if it is checked or not.
// fWidth is the width of the label.
// fHeight is the Height of the label.
// sTooltip is the tooltip bind value.
json CreateCheckBox(json jRow, string sLabel, string sId, float fWidth, float fHeight, string sToolTip = "");

// Creates a slider (Int based) element in jRow
// jRow is the row the Check box goes into.
// sId is the bind name.
// The binds are as follows.
// Value: sId + "_value"
// Minimum: sId + "_min"
// Maximum: sId + "_max"
// Step size: sId + "_stepsize"
// fWidth is the width of the slider.
// fHeight is the Height of the slider.
// sTooltip is the tooltip bind value.
json CreateSlider(json jRow, string sId, float fWidth, float fHeight, string sToolTip = "");

// Creates an Options element in jRow.
// jRow is the row the Options will start on.
// sId is the bind name.
// The binds are as follows:
//      Value: sId + "_value"
//      Event is sId + "_event"
// nDirection: NUI_DIRECTION_*
// fWidth is the width of the options labels.
// fHeight is the height of the options labels.
// sTooltip is the tooltip bind value.
json CreateOptions(json jRow, string sId, int nDirection, json jLabels, float fWidth, float fHeight, string sToolTip = "");

// Creates a list element in jRow.
// jRow is the row the list will start on.
// jElements is the list of elements in the list. Use NuiListTemplateCell to add.
// sId is the bind name.
// The binds are Event is sId + "_event".
// Row count is bound to sId + "_count".
// fRowHeight is the height of the rendered rows.
// fWidth is the width of the options labels.
// fHeight is the height of the options labels.
// sTooltip is the tooltip bind value.
json CreateList(json jRow, json jElements, string sId, float fRowHeight, float fWidth, float fHeight, string sTooltip = "");

// Placed here temporarily until we can clean up our includes!
void ai_SetDMWAccessButton(int nButton, int bOn = TRUE);
int ai_GetDMWAccessButton(int nButton);
void ai_SetDMAIAccessButton(int nButton, int bOn = TRUE);
int ai_GetDMAIAccessButton(int nButton);

void SaveMenuToCampaignDb(object oPC, int nToken, string sWndId)
{
    json jGeometry = NuiGetBind(oPC, nToken, "window_geometry");
    float fX = JsonGetFloat(JsonObjectGet(jGeometry, "x"));
    float fY = JsonGetFloat(JsonObjectGet(jGeometry, "y"));
    string sName = ai_RemoveIllegalCharacters(GetName(oPC));
    json jLocations = ai_GetCampaignDbJson("locations", sName, AI_DM_TABLE);
    json jNUI = JsonObjectGet(jLocations, sWndId);
    if(JsonGetType(jNUI) == JSON_TYPE_NULL) jNUI = JsonObject();
    jNUI = JsonObjectSet(jNUI, "x", JsonFloat(fX));
    jNUI = JsonObjectSet(jNUI, "y", JsonFloat(fY));
    jLocations = JsonObjectSet(jLocations, sWndId, jNUI);
    ai_SetCampaignDbJson("locations", jLocations, sName, AI_DM_TABLE);
}

float GetGUIWidthMiddle(object oPC, float fMenuWidth)
{
    // Get players window information.
    float fGUI_Width = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    float fGUI_Scale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    fMenuWidth = fMenuWidth * fGUI_Scale;
    return (fGUI_Width / 2.0) - (fMenuWidth / 2.0);
}
float GetGUIHeightMiddle(object oPC, float fMenuHeight)
{
    // Get players window information.
    float fGUI_Height = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT));
    float fGUI_Scale = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    fMenuHeight = fMenuHeight * fGUI_Scale;
    return (fGUI_Height / 2.0) - (fMenuHeight / 2.0);
}
int IsWindowClosed(object oPC, string sWndId)
{
    int nToken = NuiFindWindow(oPC, sWndId);
    if(nToken)
    {
        NuiDestroy(oPC, nToken);
        return FALSE;
    }
    return TRUE;
}
int SetWindow(object oPC, json jLayout, string sWinID, string sTitle, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder, string sEventScript = "")
{
    json jWindow;
    if (bCollapse) jWindow = NuiWindow (jLayout, NuiBind ("window_title"), NuiBind ("window_geometry"),
    NuiBind ("window_resizable"), JsonNull (), NuiBind ("window_closable"),
    NuiBind ("window_transparent"), NuiBind ("window_border"));

    else jWindow = NuiWindow (jLayout, NuiBind ("window_title"), NuiBind ("window_geometry"),
    NuiBind ("window_resizable"), JsonBool (FALSE), NuiBind ("window_closable"),
    NuiBind ("window_transparent"), NuiBind ("window_border"));

    int nToken = NuiCreate (oPC, jWindow, sWinID, sEventScript);
    if(!bCollapse && !bClose && !bBorder) NuiSetBind (oPC, nToken, "window_title", JsonBool (FALSE));
    else NuiSetBind (oPC, nToken, "window_title", JsonString (sTitle));
    if (fX == -1.0) fX = GetGUIWidthMiddle (oPC, fWidth);
    if (fY == -1.0) fY = GetGUIHeightMiddle (oPC, fHeight);
    int nScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE);
    if(nScale != 100)
    {
        fHeight = fHeight * (IntToFloat(1050 - nScale) / 1000.0);
        fWidth = fWidth * (IntToFloat(1200 - nScale) / 1000.0);
    }
    NuiSetBind (oPC, nToken, "window_geometry", NuiRect (fX,
                fY, fWidth, fHeight));
    NuiSetBind (oPC, nToken, "window_resizable", JsonBool (bResize));
    NuiSetBind (oPC, nToken, "window_closable", JsonBool (bClose));
    NuiSetBind (oPC, nToken, "window_transparent", JsonBool (bTransparent));
    NuiSetBind (oPC, nToken, "window_border", JsonBool (bBorder));
    return nToken;
}
json CreateLabel(json jRow, string sLabel, string sId, float fWidth, float fHeight, int nHAlign = 0, int nVAlign = 0, float fMargin = -1.0, string sTooltip = "")
{
    json jLabel;
    if(sLabel == "") jLabel = NuiId(NuiLabel(NuiBind(sId + "_label"), JsonInt(nHAlign), JsonInt(nVAlign)), sId);
    else jLabel = NuiId(NuiLabel(JsonString(sLabel), JsonInt(nHAlign), JsonInt(nVAlign)), sId);
    jLabel = NuiWidth(jLabel, fWidth);
    jLabel = NuiHeight(jLabel, fHeight);
    if (fMargin > -1.0) jLabel = NuiMargin(jLabel, fMargin);
    if(sTooltip != "") jLabel = NuiTooltip (jLabel, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jLabel);
}
json CreateButton(json jRow, string sLabel, string sId, float fWidth, float fHeight, float fMargin = -1.0, string sTooltip = "")
{
    json jButton;
    if(sLabel == "") jButton = NuiEnabled(NuiId(NuiButton(NuiBind (sId + "_label")), sId), NuiBind(sId + "_event"));
    else jButton = NuiEnabled(NuiId(NuiButton(JsonString(sLabel)), sId), NuiBind(sId + "_event"));
    jButton = NuiWidth(jButton, fWidth);
    jButton = NuiHeight(jButton, fHeight);
    if (fMargin > -1.0) jButton = NuiMargin(jButton, fMargin);
    if (sTooltip != "") jButton = NuiTooltip(jButton, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jButton);
}
json CreateButtonSelect(json jRow, string sLabel, string sId, float fWidth, float fHeight, string sTooltip = "")
{
    json jButton;
    if(sLabel == "") jButton = NuiEnabled(NuiId(NuiButtonSelect(NuiBind (sId + "_label"), NuiBind(sId)), sId), NuiBind(sId + "_event"));
    else jButton = NuiEnabled(NuiId(NuiButtonSelect(JsonString(sLabel), NuiBind(sId)), sId), NuiBind(sId + "_event"));
    jButton = NuiWidth(jButton, fWidth);
    jButton = NuiHeight(jButton, fHeight);
    if(sTooltip != "") jButton = NuiTooltip(jButton, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jButton);
}
json CreateButtonImage(json jRow, string sResRef, string sId, float fWidth, float fHeight, float fMargin = -1.0, string sTooltip = "")
{
    json jButton;
    if(sResRef == "") jButton = NuiEnabled(NuiId (NuiButtonImage(NuiBind(sId + "_image")), sId), NuiBind(sId + "_event"));
    else jButton = NuiEnabled(NuiId(NuiButtonImage(JsonString(sResRef)), sId), NuiBind(sId + "_event"));
    jButton = NuiWidth(jButton, fWidth);
    jButton = NuiHeight(jButton, fHeight);
    if(fMargin > -1.0) jButton = NuiMargin(jButton, fMargin);
    if(sTooltip != "") jButton = NuiTooltip(jButton, NuiBind (sTooltip));
    jButton = NuiEncouraged(jButton, NuiBind(sId + "_encouraged"));
    return JsonArrayInsert(jRow, jButton);
}
json CreateTextBox(json jRow, string sId, float fWidth, float fHeight, int bBorder = TRUE, int nScroll = NUI_SCROLLBARS_AUTO, string sTooltip = "")
{
    json jTextBox = NuiEnabled(NuiText(NuiBind(sId), bBorder, nScroll), NuiBind(sId + "_event"));
    jTextBox = NuiWidth(jTextBox, fWidth);
    jTextBox = NuiHeight(jTextBox, fHeight);
    if(sTooltip != "") jTextBox = NuiTooltip(jTextBox, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, JsonObjectSet(jTextBox, "text_color", NuiColor (255, 0, 0)));
}
json CreateTextEditBox(json jRow, string sPlaceHolderBind, string sValueBind, int nMaxLength, int bMultiline, float fWidth, float fHeight, string sTooltip = "")
{
    json jObject = NuiEnabled(NuiTextEdit(NuiBind(sPlaceHolderBind), NuiBind(sValueBind), nMaxLength, bMultiline), NuiBind(sValueBind + "_event"));
    jObject = NuiWidth(jObject, fWidth);
    jObject = NuiHeight(jObject, fHeight);
    if(sTooltip != "") jObject = NuiTooltip(jObject, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jObject);
}
json CreateCombo(json jRow, json jList, string sId, float fWidth, float fHeight, string sTooltip = "")
{
    json jCombo;
    if(JsonGetType(jList) == JSON_TYPE_NULL)
    {
        jCombo = NuiId(NuiCombo(NuiBind(sId + "_list"), NuiBind(sId + "_selected")), sId + "_event");
    }
    jCombo = NuiId(NuiCombo(jList, NuiBind (sId + "_selected")), sId);
    jCombo = NuiEnabled(jCombo, NuiBind (sId + "_event"));
    jCombo = NuiWidth(jCombo, fWidth);
    jCombo = NuiHeight(jCombo, fHeight);
    if(sTooltip != "") jCombo = NuiTooltip(jCombo, NuiBind(sTooltip));
    return JsonArrayInsert(jRow, jCombo);
}
json CreateImage(json jRow, string sResRef, string sId, int nAspect, int nHAlign, int nVAlign, float fWidth, float fHeight, float fMargin = -1.0, string sTooltip = "")
{
    json jImage;
    if(sResRef == "") jImage = NuiEnabled(NuiId(NuiImage(NuiBind(sId + "_image"), JsonInt(nAspect), JsonInt(nHAlign), JsonInt(nVAlign)), sId), NuiBind(sId + "_event"));
    else jImage = NuiEnabled(NuiId(NuiImage(JsonString(sResRef), JsonInt(nAspect), JsonInt(nHAlign), JsonInt(nVAlign)), sId), NuiBind(sId + "_event"));
    jImage = NuiWidth(jImage, fWidth);
    jImage = NuiHeight(jImage, fHeight);
    if (fMargin > -1.0) jImage = NuiMargin(jImage, fMargin);
    if(sTooltip != "") jImage = NuiTooltip(jImage, NuiBind(sTooltip));
    return JsonArrayInsert(jRow, jImage);
}
json CreateCheckBox(json jRow, string sLabel, string sId, float fWidth, float fHeight, string sTooltip = "")
{
    json jCheckBox;
    if(sLabel == "") jCheckBox = NuiEnabled(NuiId(NuiCheck(NuiBind(sId + "_label"), NuiBind(sId + "_check")), sId), NuiBind(sId + "_event"));
    else jCheckBox = NuiEnabled(NuiId(NuiCheck(JsonString(sLabel), NuiBind(sId + "_check")), sId), NuiBind(sId + "_event"));
    jCheckBox = NuiWidth(jCheckBox, fWidth);
    jCheckBox = NuiHeight(jCheckBox, fHeight);
    if (sTooltip != "") jCheckBox = NuiTooltip (jCheckBox, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jCheckBox);
}
json CreateSlider(json jRow, string sId, float fWidth, float fHeight, string sTooltip = "")
{
    json jSlider;
    jSlider = NuiEnabled(NuiId(NuiSlider(NuiBind(sId + "_value"), NuiBind(sId + "_min"), NuiBind(sId + "_max"), NuiBind(sId + "_stepsize")), sId), NuiBind(sId + "_event"));
    jSlider = NuiWidth(jSlider, fWidth);
    jSlider = NuiHeight(jSlider, fHeight);
    if(sTooltip != "") jSlider = NuiTooltip(jSlider, NuiBind(sTooltip));
    return JsonArrayInsert(jRow, jSlider);
}
json CreateOptions(json jRow, string sId, int nDirection, json jLabels, float fWidth, float fHeight, string sTooltip = "")
{
    json jOption;
    jOption = NuiEnabled(NuiId(NuiOptions(nDirection, jLabels, NuiBind(sId + "_value")), sId), NuiBind(sId + "_event"));
    jOption = NuiWidth(jOption, fWidth);
    jOption = NuiHeight(jOption, fHeight);
    if(sTooltip != "") jOption = NuiTooltip (jOption, NuiBind (sTooltip));
    return JsonArrayInsert(jRow, jOption);
}
json CreateList(json jRow, json jElements, string sId, float fRowHeight, float fWidth, float fHeight, string sTooltip = "")
{
    json jList;
    jList = NuiId(NuiList(jElements, NuiBind(sId), fRowHeight), sId + "_id");
    jList = NuiWidth(jList, fWidth);
    jList = NuiHeight(jList, fHeight);
    if (sTooltip != "") jList = NuiTooltip(jList, NuiBind(sTooltip));
    return JsonArrayInsert(jRow, jList);
}
void ai_SetDMWAccessButton(int nButton, int bOn = TRUE)
{
    json jRules = ai_GetCampaignDbJson("rules");
    int nWidgetButtons = JsonGetInt(JsonObjectGet(jRules, sDMWidgetAccessVarname));
    if(bOn) nWidgetButtons = nWidgetButtons | nButton;
    else nWidgetButtons = nWidgetButtons & ~nButton;
    SetLocalInt(GetModule(), sDMWidgetAccessVarname, nWidgetButtons);
    jRules = JsonObjectSet(jRules, sDMWidgetAccessVarname, JsonInt(nWidgetButtons));
    ai_SetCampaignDbJson("rules", jRules);
}
int ai_GetDMWAccessButton(int nButton)
{
    int nWidgetButtons = GetLocalInt(GetModule(), sDMWidgetAccessVarname);
    return nWidgetButtons & nButton;
}
void ai_SetDMAIAccessButton(int nButton, int bOn = TRUE)
{
    json jRules = ai_GetCampaignDbJson("rules");
    int nWidgetButtons = JsonGetInt(JsonObjectGet(jRules, sDMAIAccessVarname));
    if(bOn) nWidgetButtons = nWidgetButtons | nButton;
    else nWidgetButtons = nWidgetButtons & ~nButton;
    SetLocalInt(GetModule(), sDMAIAccessVarname, nWidgetButtons);
    jRules = JsonObjectSet(jRules, sDMAIAccessVarname, JsonInt(nWidgetButtons));
    ai_SetCampaignDbJson("rules", jRules);
}
int ai_GetDMAIAccessButton(int nButton)
{
    int nWidgetButtons = GetLocalInt(GetModule(), sDMAIAccessVarname);
    return nWidgetButtons & nButton;
}

