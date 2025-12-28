//::///////////////////////////////////////////////
//:: 0s_purge_magic
//:://////////////////////////////////////////////
/*
    Allows a character to purge all magic from a magic item.
*/
//:://////////////////////////////////////////////
//:: Created By: Kevin Curtis
//:: Created On: 2017-24-11
//:://////////////////////////////////////////////
void main()
{
    int iCounter = 1;
    object oUser, oItem;
    itemproperty ipProperty;
    effect eVisual;
    oUser = OBJECT_SELF;
    oItem = GetSpellTargetObject ();
    // Setup special effect.
    eVisual = EffectVisualEffect (VFX_FNF_DISPEL_GREATER);
    ApplyEffectToObject (DURATION_TYPE_INSTANT, eVisual, oUser);
    // Cycle through and remove all powers.
    // Get first property
    ipProperty = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid (ipProperty))
    {
        // Check to see if the property type matches the Quality.
        // Quality is not removed.
        if (GetItemPropertyType (ipProperty) != 86)
        {
            RemoveItemProperty (oItem, ipProperty);
        }
        // Get the next property.
        ipProperty = GetNextItemProperty (oItem);
    }
    SetName (oItem, "");
}
