if (!active) exit

if (!fullyRevealed()) charProgress += charsPerStep

if (keyboard_check_pressed(vk_enter) 
    || keyboard_check_pressed(vk_space) 
    || keyboard_check_pressed(ord("E"))) {
    advance()
}