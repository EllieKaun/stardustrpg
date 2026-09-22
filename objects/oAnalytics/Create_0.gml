/// @description Инициализация GameAnalytics (один раз за запуск)
// Объект persistent и размещён в стартовой комнате. Синглтон: если экземпляр
// уже существует (вернулись в меню) — уничтожаем дубль, чтобы не было двух.
if (instance_number(oAnalytics) > 1) { instance_destroy(); exit; }

// Вся конфигурация и ключи — в analyticsInit() (скрипт scrAnalytics).
analyticsInit()
