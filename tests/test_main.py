import unittest
from src.main import main

class TestMain(unittest.TestCase):
    def test_main(self):
        # Basic test for main function
        self.assertIsNone(main())

if __name__ == "__main__":
    unittest.main()
