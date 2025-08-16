#!/usr/bin/env python3
"""
Test script to verify both arbor and dspy libraries are working correctly.
"""

def test_arbor():
    """Test arbor library import and basic functionality."""
    try:
        import arbor
        print("✓ arbor library imported successfully")
        print(f"  arbor version: {getattr(arbor, '__version__', 'unknown')}")
        return True
    except ImportError as e:
        print(f"✗ Failed to import arbor: {e}")
        return False

def test_dspy():
    """Test dspy library import and basic functionality."""
    try:
        import dspy
        print("✓ dspy library imported successfully")
        print(f"  dspy version: {getattr(dspy, '__version__', 'unknown')}")
        return True
    except ImportError as e:
        print(f"✗ Failed to import dspy: {e}")
        return False

def main():
    """Run all tests."""
    print("Testing library installations...")
    print("=" * 40)
    
    arbor_ok = test_arbor()
    dspy_ok = test_dspy()
    
    print("=" * 40)
    if arbor_ok and dspy_ok:
        print("✓ All libraries are working correctly!")
        return 0
    else:
        print("✗ Some libraries failed to load")
        return 1

if __name__ == "__main__":
    exit(main())