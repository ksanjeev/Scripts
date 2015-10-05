#!/bin/sh

arg ()
{
        echo "Number of arguments: $#"
        echo "Name of script: $0"
        echo "First argument: $1"
        echo "Second argument: $2"
        echo "Third argument: $3"
        echo "All the arguments: $@"
}

arg no yes maybe
