local ProfileTemplate = {
    SchemaVersion = 1,

    Currencies = {
        Coins = 0,
        Gems = 0,
    },

    Inventory = {},
    Upgrades = {},

    Pets = {
        Owned = {},
        Equipped = {},
    },

    Plot = {
        Items = {},
    },

    OfflineProgress = {
        LastSimulationAt = 0,
        TotalClaimed = 0,
    },

    ProcessedReceipts = {},
}

return ProfileTemplate
