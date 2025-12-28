/// @ingroup webhook
/// @file nwnx_webhook_rch.nss
/// @brief Create richer webhook messages suitable for Discord
#include "nwnx_webhook"

/// @ingroup webhook
/// @brief For more information on these fields see https://birdie0.github.io/discord-webhooks-guide/
/// @note URL fields may require NWNX_Util_EncodeStringForURL().
struct NWNX_WebHook_Message {
    string sUsername; // Overrides the predefined username of the BOT.
    string sAvatarURL; // Overrides the predefined avatar picture of the BOT.
    string sContent; // Text message. Up to 300 (2,000) characters.
    // Embeded array of objects for the post.
    string sColor; // color code of the embed. Is in decimal system.
    string sAuthorName; // Name of the author: Is at the top of the embed.
    string sAuthorURL; // URL link, if there is an authorname then it will be the hyperlink.
    string sAuthorIconURL; // URL of the icon used next to the author's name.
    string sTitle; // Large text just under the Author's name.
    string sURL; // URL of embed. If sTitle is used then it will be the hyperlink.
    string sDescription; // Smaller text placed just under the title.
    // You can use Markdown here. *Italic* **bold** __underline__ ~~strikeout~~ [hyperlink](https://google.com) `code`
    string sThumbnailURL; // embeded thumnail picture(object). Large and to the right.
    string sImageURL; // URL of an image Large at the bottom of the embed.
    string sFooterText; // Text at the bottom of the post.
    string sFooterURL; // URL for Footer. If sFooterText is used it will be the hyperlink.
    int nTimestamp; // ISO8601 typestamp (yyyy-mm-ddThh:mm:ss.msZ).
    string sField1Name; // Field 1 text (larger and bold).
    string sField1Value; // Value 1 text (smaller).
    int nField1Inline; // TRUE: fields will be displayed in the same line, 3 per line.
    string sField2Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField2Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField2Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField3Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField3Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField3Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField4Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField4Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField4Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField5Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField5Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField5Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField6Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField6Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField6Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField7Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField7Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField7Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField8Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField8Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField8Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField9Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField9Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField9Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField10Name; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    string sField10Value; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
    int nField10Inline; ///< https://birdie0.github.io/discord-webhooks-guide/structure/embed/fields.html
};

/// @private We don't need this to be a part of the docs.
/// @brief Helper function to convert 0 or 1 to false or true.
/// @param iBool The integer representation of the boolean.
/// @return The string representation (true or false) of the boolean.
string IntToBoolString(int iBool);

/// @ingroup webhook
/// @brief Builds and sends a rich webhook message based on the constructed NWNX_WebHook_Message.
/// @param host The web server to send the hook.
/// @param path The path to the hook.
/// @param stMessage A constructed NWNX_Webhook_Message.
/// @param mrkdwn Set to false if you do not wish your message's markdown be parsed.
/// @warning Your path must end with /slack if using a Discord webhook.
string NWNX_WebHook_BuildMessageForWebHook(struct NWNX_WebHook_Message stMessage, int nMrkdwn = 1);

string IntToBoolString(int iBool)
{
    return iBool == 0 ? "false" : "true";
}

string NWNX_WebHook_BuildMessageForWebHook(struct NWNX_WebHook_Message stMessage, int nMrkdwn = 1)
{
    // The only way to turn off markdown for discord is to surround the text in backticks
    // This is where we setup the content (text) of the post before the embed.
    string sMainText = "";
    if (stMessage.sContent != "")
    {
        if (!nMrkdwn) sMainText = "```text\\n" + stMessage.sContent + "```";
        else sMainText = stMessage.sContent;
    }
    // Open JSON
    string message = "{";
    // Content (text) before the embed must be here.
    message = message + "\"text\": \"" + sMainText + "\"";
    // Set the user attributes for the poster
    if (stMessage.sUsername != "") message = message + ",\"username\": \"" + stMessage.sUsername + "\"";
    if (stMessage.sAvatarURL != "") message = message +  ",\"icon_url\": \"" + stMessage.sAvatarURL + "\"";
    // We need to construct an attachment (embed) object
    if (stMessage.sAuthorName != "" || stMessage.sAuthorURL != "" || stMessage.sAuthorIconURL != "" ||
        stMessage.sTitle != "" || stMessage.sURL != "" || stMessage.sDescription != "" ||
        stMessage.sFooterText != "" || stMessage.sFooterURL != "" || stMessage.nTimestamp > 0 ||
        stMessage.sColor != "" || stMessage.sThumbnailURL != "" || stMessage.sImageURL != "" || stMessage.sField1Name != "")
    {
        message = message + ",\"attachments\": [{\"author_name\": \"" + stMessage.sAuthorName +
                             "\",\"author_link\": \"" + stMessage.sAuthorURL +
                             "\",\"author_icon\": \"" + stMessage.sAuthorIconURL +
                             "\",\"title\": \"" + stMessage.sTitle +
                             "\",\"title_link\": \"" + stMessage.sURL +
                             "\",\"text\": \"" + stMessage.sDescription +
                             "\",\"footer\": \"" + stMessage.sFooterText +
                             "\",\"footer_icon\": \"" + stMessage.sFooterURL +
                             "\",\"color\": \"" + stMessage.sColor +
                             "\",\"thumb_url\": \"" + stMessage.sThumbnailURL +
                             "\",\"image_url\": \"" + stMessage.sImageURL + "\"";
        // Dont post an empty timestamp
        if (stMessage.nTimestamp > 0) message = message + ",\"ts\": \"" + IntToString(stMessage.nTimestamp) + "\"";
        // Fields to handle
        if (stMessage.sField1Name != "" || stMessage.sField1Value != "")
        {
            message = message + ",\"fields\": [";
            message = message + "{\"title\": \"" + stMessage.sField1Name + "\",\"value\": \"" + stMessage.sField1Value + "\",\"short\": " + IntToBoolString(stMessage.nField1Inline) + "}";
            if (stMessage.sField2Name != "" || stMessage.sField2Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField2Name + "\",\"value\": \"" + stMessage.sField2Value + "\",\"short\": " + IntToBoolString(stMessage.nField2Inline) + "}";
            if (stMessage.sField3Name != "" || stMessage.sField3Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField3Name + "\",\"value\": \"" + stMessage.sField3Value + "\",\"short\": " + IntToBoolString(stMessage.nField3Inline) + "}";
            if (stMessage.sField4Name != "" || stMessage.sField4Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField4Name + "\",\"value\": \"" + stMessage.sField4Value + "\",\"short\": " + IntToBoolString(stMessage.nField4Inline) + "}";
            if (stMessage.sField5Name != "" || stMessage.sField5Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField5Name + "\",\"value\": \"" + stMessage.sField5Value + "\",\"short\": " + IntToBoolString(stMessage.nField5Inline) + "}";
            if (stMessage.sField6Name != "" || stMessage.sField6Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField6Name + "\",\"value\": \"" + stMessage.sField6Value + "\",\"short\": " + IntToBoolString(stMessage.nField6Inline) + "}";
            if (stMessage.sField7Name != "" || stMessage.sField7Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField7Name + "\",\"value\": \"" + stMessage.sField7Value + "\",\"short\": " + IntToBoolString(stMessage.nField7Inline) + "}";
            if (stMessage.sField8Name != "" || stMessage.sField8Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField8Name + "\",\"value\": \"" + stMessage.sField8Value + "\",\"short\": " + IntToBoolString(stMessage.nField8Inline) + "}";
            if (stMessage.sField9Name != "" || stMessage.sField9Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField9Name + "\",\"value\": \"" + stMessage.sField9Value + "\",\"short\": " + IntToBoolString(stMessage.nField9Inline) + "}";
            if (stMessage.sField10Name != "" || stMessage.sField10Value != "")
                message = message + ",{\"title\": \"" + stMessage.sField10Name + "\",\"value\": \"" + stMessage.sField10Value + "\",\"short\": " + IntToBoolString(stMessage.nField10Inline) + "}";
            // Close fields array
            message = message + "]";
        }
        // Close attachments array
        message = message + "}]";
    }
    // Close JSON
    message = message + "}";
    return message;
}

