// Begin Step базового объекта паузы. Наследуется ВСЕМИ потомками автоматически
// (Begin Step не перекрывается обычным Step ребёнка), поэтому анимация спрайта
// замирает у всех наследников без дублирования кода.
//
// Логику (движение/спавн) наследование заморозить не может — родительский exit не
// отменяет Step ребёнка — поэтому логика гейтится в самих объектах через
// `if (global.gamePaused) exit`. Здесь замораживаем только анимацию.
//
// pauseFrozen/pauseAnimSpeed само-инициализируются (без зависимости от Create):
// на входе в паузу запоминаем image_speed и обнуляем, на резюме возвращаем ОДИН раз.
var paused = variable_global_exists("gamePaused") && global.gamePaused
var frozen = variable_instance_exists(id, "pauseFrozen") && pauseFrozen

if (paused) {
    if (!frozen) { pauseAnimSpeed = image_speed; pauseFrozen = true }
    image_speed = 0
} else if (frozen) {
    image_speed = pauseAnimSpeed
    pauseFrozen = false
}
