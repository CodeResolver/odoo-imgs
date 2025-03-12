import pytest
from src.main import main

def test_main(capsys):
    """Test the main function output"""
    main()
    captured = capsys.readouterr()
    assert captured.out == "Hello, World!\n"
