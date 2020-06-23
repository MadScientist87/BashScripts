#!/bin/sh
{
	diskutil eject /Volumes/*
	osascript -e 'display notification "All external drives have been ejected" with 	title "HDD Status"'
} || { # catch
    osascript -e 'display notification "Error occured ejecting disks" with 	title "HDD Status"'
}