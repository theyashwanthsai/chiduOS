void kernel_main() {
    char* video_memory = (char*) 0xb8000;
    char* message = "Hello from C kernel!";
    
    // Find the first empty line (where we can add our message)
    // Start from the bottom and work our way up
    int line = 24; // Start from the last line (25th line, 0-indexed)
    int found_empty = 0;
    
    // Look for an empty line to place our message
    for (int l = 24; l >= 0; l--) {
        int empty = 1;
        for (int col = 0; col < 80; col++) {
            if (video_memory[(l * 80 + col) * 2] != 0) {
                empty = 0;
                break;
            }
        }
        if (empty) {
            line = l;
            found_empty = 1;
            break;
        }
    }
    
    // If no empty line found, use the last line
    if (!found_empty) {
        line = 24;
    }
    
    // Print kernel message at the found line
    int start_pos = line * 80 * 2;
    for (int i = 0; message[i] != 0; i++) {
        video_memory[start_pos + i*2] = message[i];
        video_memory[start_pos + i*2 + 1] = 0x0f; // White on black
    }
    
    // Infinite loop
    while(1);
}