
# Horizontal: Each letter requires 3 coordinates, each space requires two spaces
# Vertical: Each letter requires 5 coordinates, each space requires two spaces

# 0 0  0 0  1 1  1 1  2 2  2 2  3 3  3 3  4 4  4 4  5 5  5 5
# 0 2  5 7  0 2  5 7  0 2  5 7  0 2  5 7  0 2  5 7  0 2  5 7
# 111 2111 2111 2111 2111 2111 2111 2111 2111 2111 2111 2111
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 0
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 2
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 4
#
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 7
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 9
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 11
#
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 14
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 16
#
# . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . .  . . 18
#

# slots literally work like a text editor
slot = 1
letter = "C"

apply_a_letter(letter, slot)

def apply_a_letter(letter, slot):
    switch letter:
        case "A":
            pass
            break
        case "B":
            pass
            break
        case "C":
            print("Helaw")
            break
        case "D":
            pass
            break
