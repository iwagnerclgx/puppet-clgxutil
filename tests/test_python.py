import unittest
import sys
from os import path

from mock import patch, MagicMock, Mock, mock_open, PropertyMock


SCRIPT_PATH=path.join(path.dirname(__file__), '../files/bootstrap')
sys.path.append(SCRIPT_PATH)

import bootstrap



def test_powershell_escape_1():
    cmd = ["test test"]
    result = bootstrap.powershell_escape(cmd)
    assert result == '& "test test"; exit $LASTEXITCODE'

def test_powershell_escape_2():
    cmd = ["test", "test"]
    result = bootstrap.powershell_escape(cmd)
    assert result == '& test test; exit $LASTEXITCODE'

def test_powershell_escape_3():
    cmd = ["test", "test", 'string with space and \' single quote']
    result = bootstrap.powershell_escape(cmd)
    assert result == '& test test "string with space and \' single quote"; exit $LASTEXITCODE'

def test_powershell_escape_4():
    cmd = ["test", "test=value1;value2"]
    result = bootstrap.powershell_escape(cmd)
    assert result == '& test test=value1`;value2; exit $LASTEXITCODE'

def test_powershell_escape_5():
    cmd = ["test", "test=value1$value2"]
    result = bootstrap.powershell_escape(cmd)
    assert result == '& test test=value1`$value2; exit $LASTEXITCODE'

def test_powershell_escape_6():
    cmd = ["test", "test=value1;$value2"]
    result = bootstrap.powershell_escape(cmd)
    assert result == '& test test=value1`;`$value2'


def test_powershell_encoded_command():
    cmd = "This is and encoded string"
    result = bootstrap.powershell_encoded_command(cmd)
    assert result == 'VABoAGkAcwAgAGkAcwAgAGEAbgBkACAAZQBuAGMAbwBkAGUAZAAgAHMAdAByAGkAbgBnAA=='
