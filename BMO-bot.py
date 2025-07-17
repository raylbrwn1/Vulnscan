import pygame
import time
import os
import random
from gtts import gTTS

# Initialize Pygame
pygame.init()
screen = pygame.display.set_mode((480, 320))
pygame.display.set_caption("BMO Robot Face")

WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
BMO_BLUE = (155, 217, 217)

# State variables
mouth_open = False
is_speaking = False
start_time = 0
speak_duration = 0
last_blink = time.time()
next_blink = random.uniform(3, 7)  # Random blink in 3–7 seconds

def draw_bmo_face(blink=False):
    screen.fill(BMO_BLUE)

    # Eyes
    if blink:
        pygame.draw.ellipse(screen, BLACK, (110, 110, 40, 10))  # Left squint
        pygame.draw.ellipse(screen, BLACK, (330, 110, 40, 10))  # Right squint
    else:
        pygame.draw.ellipse(screen, BLACK, (110, 100, 30, 40))  # Left eye
        pygame.draw.ellipse(screen, BLACK, (330, 100, 30, 40))  # Right eye

    # Mouth
    if is_speaking and mouth_open:
        pygame.draw.ellipse(screen, BLACK, (210, 160, 60, 25))  # Talking mouth (open ellipse)
    else:
        pygame.draw.arc(screen, BLACK, (200, 150, 80, 40), 3.14, 0, 4)  # Smile arc

    pygame.display.flip()

# Use gTTS to generate a female British voice
def start_speaking(text):
    global is_speaking, start_time, speak_duration
    is_speaking = True
    start_time = time.time()
    speak_duration = max(len(text.split()) / 2.5, 1.5)

    tts = gTTS(text=text, lang='en-uk', slow=False)
    tts.save("speech.mp3")
    os.system("mpg321 -q speech.mp3 &")

# Main loop
def main():
    global mouth_open, is_speaking, last_blink, next_blink

    clock = pygame.time.Clock()
    blink = False
    blink_duration = 0.15
    blink_start = 0

    draw_bmo_face()
    time.sleep(0.5)
    draw_bmo_face(blink=True)
    time.sleep(0.2)
    draw_bmo_face()

    # Say hello
    start_speaking("Hello! I am your robot friend.")

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return

        now = time.time()

        # Handle blinking
        if not blink and now - last_blink > next_blink:
            blink = True
            blink_start = now
        elif blink and now - blink_start > blink_duration:
            blink = False
            last_blink = now
            next_blink = random.uniform(3, 7)

        # Handle mouth animation during speaking
        if is_speaking:
            if now - start_time > speak_duration:
                is_speaking = False
            else:
                mouth_open = not mouth_open

        draw_bmo_face(blink=blink)
        clock.tick(6)

main()
