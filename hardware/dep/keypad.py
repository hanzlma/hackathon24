from pad4pi import rpi_gpio
_keys = []

class Keypad:
    def __init__(self):
        KEYPAD = [
            [1, 2, 3,"A"],
            [4, 5, 6,"B"],
            [7, 8, 9,"C"],
            ["*", 0, "#","D"]
        ]

        ROW_PINS = [5,6,13,19] # BCM numbering
        COL_PINS = [26,16,20,21] # BCM numbering

        factory = rpi_gpio.KeypadFactory()

        # Try factory.create_4_by_3_keypad
        # and factory.create_4_by_4_keypad for reasonable defaults
        self.keypad = factory.create_keypad(keypad=KEYPAD, row_pins=ROW_PINS, col_pins=COL_PINS)
        self.registerHandler(self._getKeyHandler)
    def __del__(self):
        self.keypad.cleanup()

    def registerHandler(self,fn):

        # printKey will be called each time a keypad button is pressed
        self.keypad.registerKeyPressHandler(fn)



    @staticmethod
    def _getKeyHandler(key):
        global _keys
        _keys.append(key)

    def getKey(self):
        global _keys
        while not _keys:
            pass
        key = _keys[0]
        _keys.pop(0)
        return key


if __name__ == "__main__":
    def printKey(key):
        print(key)

    keypad = Keypad()
    keypad.registerHandler(printKey)
    try:
        while True:
            pass
    except KeyboardInterrupt:
        rpi_gpio.GPIO.cleanup()