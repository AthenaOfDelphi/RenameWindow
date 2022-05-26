# RenameWindow

This is a little utility to get around a bug in OBS.  The bug in question is:-

[OBS 26 fails to switch to other Chrome windows after closing currently captured one](https://github.com/obsproject/obs-studio/issues/3537)

I believe this is an issue with their window matching strategy and it affects not just Chrome, but other applications (primarily it appears to be Electron based apps such as Discord or Notion).

I have windows for both in my streaming setup and had resorted to selecting a specific page in Notion and a specific channel in Discord to allow OBS to reliably find their windows.

Enter 'renamewindow'.

RenameWindow is a small console application that gets a list of windows and then finds the ones you want to change and sets a new title for the window.  The configuration is stored in an INI file (renamewindow.ini) which should be in the same directory as the EXE.

**NOTE:-** The changes made by this application are not permanent.  The examples I give (Notion and Discord) both have highly dynamic window titles and as such, navigating to another page in Notion or changing channel in Discord will change the windows title.  Thus, the intended use is run this application and then fireup OBS immediately.  It should be noted that as far as I can tell, OBS won't find the windows of non-visible sources until they are made visible, so you should setup a hot key or something that makes the sources visible so their windows can be found.

## Sample Configuration

    # Specify some default values
    [_Default]
    Class=Chrome_WidgetWin_1

    # Sample
    #
    #[SectionTitle]
    #Exe=Exe name to look for
    #Title=Title text to look for
    #Class=Window class to look for
    #SetTitle=New title text
    #
    # You do NOT have to specify Exe, Title and Class... it is often enough to specify just
    # the Exe and Class.  In this sample file, we're using a default class which corresponds
    # to the window class of the Electron window that's used to display the apps (for
    # Discord and Notion it's the same)
    #
    # NOTE:- The titles applied here are not permanent changes.  If the application updates
    # the title so be it, but the idea behind this is to rename the windows immediately
    # prior to starting OBS, then update the sources to use your newly named windows.  Next
    # time, run this, run OBS and it should have no problem finding the windows
    #
    # You can get a list of the windows using 'renamewindow /list'

    [Discord]
    Exe=discord.exe
    SetTitle=Discord Wibble

    [Notion]
    Exe=notion.exe
    SetTitle=Notion Wibble

You can search for a window using it's EXE name (Exe), it's current title (Title) and it's window class (Class).  You can use any combination of these.  As shown in the sample configuration, the search is using the EXE name and the window class specified in the [_Default] section.

## Command Line Options

With no options, the program will attempt to load the configuration file, find the windows and perform the renames specified in the configuration.

If you want to obtain a list of windows, you can use the `/list` option.  For example:-

    E:\Development\WindowRenamer\Win32\Debug
    λ renamewindow /list
    RenameWindow - Version 1.0 - Copyright (c) 2022 AthenaOfDelphi (athena.outer-reaches.com)
    Finding windows...
    Window List (Entries => [EXE] - TITLE - {CLASS})
    [adb.exe] - ADB Power Notification Window - {PowerNotificationWindow}
    [adb.exe] - Default IME - {IME}
    .....
    [Discord.exe] - (untitled) - {Base_PowerMessageWindow}
    [Discord.exe] - (untitled) - {Chrome_SystemMessageWindow}
    [Discord.exe] - (untitled) - {Chrome_WidgetWin_0}
    [Discord.exe] - (untitled) - {crashpad_SessionEndWatcher}
    [Discord.exe] - (untitled) - {Electron_NotifyIconHostWindow}
    [Discord.exe] - Discord Wibble - {Chrome_WidgetWin_1}
    [Discord.exe] - MSCTFIME UI - {MSCTFIME UI}
    .....

As you can see, the main Discord window was renamed using the sample configuration provided above.

## Source Code

I've provided all the source code, to be fully transparent.

## Download

The exe and a sample configuration file are available on my [website](https://athena.outer-reaches.com/blog/2022/05/26/utility-renamewindow/).  Unzip them to a directory, edit the INI file as required and you're good to go.

## Issues

I've spun this off as a little EXE to help others who may be having problems with OBS not finding some of their window sources.  I don't use the application as I've built this functionality into a larger application I use for streaming.

What does this have to do with issues?

Well, maintaining this is not a priority for me and I see it as a stop gap until there is a solution properly implemented in OBS.  It's provided as is so it's not been extensively tested... it works using the sample configuration above but beyond that I'm not going to make any guarantees about it's reliability or whether it is fit for purpose.  Use it at your own risk.

That being said, if you do find an issue please report it and I'll see what I can about it.  Just don't expect an instant fix.

## Compatibility
This is for Windows only.  It has been developed and tested on Windows 10, I cannot make any statements about compatibility with Windows 11, but I have no reason to suspect it won't work on earlier versions such as Windows 7.  It is a 32 bit app.
