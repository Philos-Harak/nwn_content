//////////////////////////////////////////////////////////////////////////////////////////////////////
// Name: ac_rd_recall
/*////////////////////////////////////////////////////////////////////////////////////////////////////

 Activate item script for wands of recall.
 Used to recall a character back to a temple.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
// Made By: Philos
// Made On: 3/25/15
//////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_effects"
void main()
{
    object oCreature = OBJECT_SELF;
    object oItem = GetLocalObject(OBJECT_SELF, "0_item");
    object oArea = GetArea(oCreature);
    if(GetLocalInt(oArea, NO_PORTALING))
    {
        SendMessages("You cannot use a Rod of Recall from this location. You have no link to Faerun!", COLOR_RED, oCreature);
        return;
    }
    if(GetIsInCombat(oCreature))
    {
        SendMessages("You cannot use a Rod of Recall during combat!", COLOR_RED, oCreature);
        SetItemCharges(oItem, GetItemCharges(oItem) + 1);
        return;
    }
    float fDelay;
    string sResRef, sWPTag;
    // Get the tag of the item used this is the same as the placeable resref.
    sResRef = GetResRef(oItem);
    if(sResRef == "rd_recall_gond") sWPTag = "WP_ROR_ESS_GOND"; // House of Gond in Essembra.
    else if(sResRef == "rd_recall_lathan") sWPTag = "WP_ROR_HAP_LATHANDER"; // Lathander's Open Hand, Temple to Lathander in Hap.
    else if(sResRef == "rd_recall_chaunt") sWPTag = "WP_ROR_ASH_CHUANTEA"; // Harvest Table shrine, Shrine to Chauntea in Ashabenford.
    else if(sResRef == "rd_recall_tempus") sWPTag = "WP_ROR_AOS_TEMPUS"; // Abby of the Sword, an Abby to Tempus south of Essembra.
    else if(sResRef == "rd_rc_sword_poin") sWPTag = "WP_ROR_SWORD_POINT"; // Sword Point Shrine a Shrine to Tempus in Essembra.
    else if(sResRef == "rd_recall_tymora") sWPTag = "WP_ROR_SHA_TYMORA"; // House of the Lady, Temple to Tymora in Shadowdale.
    else if(sResRef == "rd_rc_house_plen") sWPTag = "WP_ROR_H_OF_PLENTY"; // House of Plenty, Temple to Chauntea in Shadowdale.
    else if(sResRef == "rd_rc_house_morn") sWPTag = "WP_ROR_FEATHER_LATHANDER"; // House of Morning, Temple to Lathander in Feather Fall.
    else if(sResRef == "rd_rc_just_hamme") sWPTag = "WP_ROR_JUST_HAMMER"; // Abby of the Just Hammer, Temple to Tyr near Balck Feather Bridge.
    else if(sResRef == "rd_rc_b_of_godde") sWPTag = "WP_ROR_B_OF_GODDES"; // Bounty of the Goddes, Temple to Chauntea in Voonlar.
    else if(sResRef == "rd_rc_dark_god") sWPTag = "WP_ROR_DARK_GOD"; // The Dark God, Temple to Cyric in Voonlar.
    // Do simple gate magic effect.
    fDelay = RodOfRecallEffect(OBJECT_SELF);
    // Use simple respawn code for now.
    object oRespawn = GetObjectByTag(sWPTag);
    if(!GetIsObjectValid(oRespawn)) SetModuleError(GetName(oItem) + "'s way point can't be found!", "ac_rd_recal", "31", "WAYPOINT");
    DelayCommand (fDelay, AssignCommand(OBJECT_SELF, JumpToObject(oRespawn)));
}
