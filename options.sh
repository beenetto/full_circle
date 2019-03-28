#!/bin/bash

BRANCH="master"
REMOTE="upstream"
UPDATE_ONLY=false
LOGIN_ONLY=false

while [ -n "$1" ]; do
        # Copy so we can modify it (can't modify $1)
        OPT="$1"
        # Detect argument termination
        if [ x"$OPT" = x"--" ]; then
                shift
                for OPT ; do
                        REMAINS="$REMAINS \"$OPT\""
                done
                break
        fi
        # Parse current opt
        while [ x"$OPT" != x"-" ] ; do
                case "$OPT" in
                        # Handle --flag=value opts like this
                        -b=* | --branch=* )
                                BRANCH="${OPT#*=}"
                                shift
                                ;;
                        # and --flag value opts like this
                        -rd* | --branch )
                                BRANCH="$2"
                                shift
                                ;;
                        -r=* | --remote=* )
                                REMOTE="${OPT#*=}"
                                shift
                                ;;
                        -r* | --remote )
                                REMOTE="$2"
                                shift
                                ;;
                        -uo* | --update-only )
                                UPDATE_ONLY=true
                                ;;
                        -lo* | --login-only )
                                LOGIN_ONLY=true
                                ;;
                        -rc* | --refresh-credintials-only )
                                REFRESH_CREDINTIALS=true
                                ;;
                        # Anything unknown is recorded for later
                        * )
                                REMAINS="$REMAINS \"$OPT\""
                                break
                                ;;
                esac
                # Check for multiple short options
                # NOTICE: be sure to update this pattern to match valid options
                NEXTOPT="${OPT#-[cfr]}" # try removing single short opt
                if [ x"$OPT" != x"$NEXTOPT" ] ; then
                        OPT="-$NEXTOPT"  # multiple short opts, keep going
                else
                        break  # long form, exit inner loop
                fi
        done
        # Done with that param. move to next
        shift
done
# Set the non-parameters back into the positional parameters ($1 $2 ..)
eval set -- $REMAINS
