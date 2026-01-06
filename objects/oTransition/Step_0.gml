switch (state) {
    case "fade_out":
        alpha += speed;
        if (alpha >= 1) {
            alpha = 1;
            room_goto(target_room);
            state = "fade_in";
        }
    break;

    case "fade_in":
        alpha -= speed;
        if (alpha <= 0) {
            alpha = 0;
            state = "idle";
        }
    break;
}
