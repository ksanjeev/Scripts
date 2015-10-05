Ã#!/bin/sh

implicit_good_return ()
{
        echo
}

explicit_good_return ()
{
        echo
        return
        this wont ever be executed
}

implicit_bad_return ()
{
        nosuchcommand
}

explicit_bad_return ()
{
        nosuchcommand
        return 127
}

implicit_good_return
echo "Return value from implicit_good_return function: $?"

explicit_good_return
echo "Return value from explicit_good_return function: $?"

implicit_bad_return
echo "Return value from implicit_bad_return_function: $?"

explicit_bad_return
echo "Return value from explicit_bad_return function: $?"
