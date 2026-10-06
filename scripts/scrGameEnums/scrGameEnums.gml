enum ChestKind { // Вид сундука
    Gold,
    Card,
    Enemy
}

enum ChestState { // Состояние сундука
    Closed,
    Opening,
    Done
}

enum DeckTutorialStage { // Стадии прохождения туториала
    Inactive,
    Dialog,
    AwaitOpen,
    Steps,
    Done
}

enum QuestSpearState { // Состояние квеста Cафара
    Inactive,
    Active,
    SpearObtained,
    Completed
}

enum QuestFoxState { // Состояние квеста Лисички
    Inactive,
    Active,
    ItemsCollected,
    Completed
}

enum QuestFoxItem {
    PineCone,
    Petunia,
    Cauldron
}

enum ShopItemKind { // Виды товаров в магазине
    Card,
    Slot
}

enum FireflyState { // Состояния светлячков
    Appearing, 
    Flying, 
    Fading 
}
