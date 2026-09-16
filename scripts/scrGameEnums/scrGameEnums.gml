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

enum QuestSpearState { // Состояние квеста копья
    Inactive,
    Active,
    SpearObtained,
    Completed
}

enum ShopItemKind { // Виды товаров в магазине
    Card,
    Slot
}
