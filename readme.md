# [todo-pt](https://github.com/hi5/todo-pt) <sup>v0.5</sup>

## Universal TODO lists for Text Editors (based on PlainTasks)

__todo-pt is (loosly) based on the [PlainTasks](https://github.com/aziz/PlainTasks) todo-list plugin for Sublime Text editor.__

A simple AutoHotkey script consisting of a number of Hotkeys and Hotstrings to manage
simple yet powerful todo lists in almost any text editor. Depending on your preferred
text editor you may need to tweak the script, see the notes & settings below.

**Notes:**

Some text editors already have special plugins / addons which may proof more
usable as they can work with the particular features of that editor, some examples:

1. Sublime Text (2 and 3) <https://github.com/aziz/PlainTasks>
2. EverEdit (2 and 3) <https://github.com/everedit/addons/tree/master/mode/todo>

This script does not include [auto complete](http://en.wikipedia.org/wiki/Auto_complete)
for '@tags' as most text editors will already have a built-in system to facilitate this.

## Installation

Download the [ZIP](https://github.com/hi5/todo-pt/archive/master.zip), unpack and run the script.
You should be able to [#include](http://ahkscript.org/docs/commands/_Include.htm) the script
in your main AutoHotkey script without any problems as the Hotkeys and Hotstrings are context
sensitive and all settings are stored in one Object and apart from the [AHK Group](http://ahkscript.org/docs/commands/GroupAdd.htm)
and the Clipboard it does not use any Global variables.

A label is already included in the script <code>todo-pt-label:</code> just uncomment that 
line and the Return a bit further down in the script below (after the Hotkey, IfWinActive line) 
and add a <code>Gosub, todo-pt-label</code> in the auto-execute section of your main script.

## Using todo-pt

To start a new TODO list simply create a new file in your preferred text editor and
save it with one of the following extensions:

* .todo
* .todolist
* .tasks
* .taskpaper

This will ensure the Hotkeys and Hotstrings below will work on that document. In order
for this to work the full name of the file has to be visible in the title bar of the
editor, so it may not work out of the box with Windows Notepad unless you configure
Windows to [show the file extensions](http://www.bleepingcomputer.com/tutorials/how-to-show-file-extensions-in-windows/).

Tip: You can change or add your own extensions in the filenames object which is defined at the start of objTodo{}

**Note:** If you want to use Unicode characters for your open, cancelled and closed tasks
"icons" (such as ❑ ✔ ✘) you need to save your TODO file using Unicode encoding. Otherwise
stick to regular ASCII characters, see settings below.

Tip: You can find more Unicode characters at http://unicode-table.com/en/

### Hotkeys

**Projects & Tasks:**

* CTRL+P to add a new Project + first task
* CTRL+I to add a new task on the next line
* CTRL+ENTER mark current line as a task

**Managing tasks:**

* CTRL+D marks a task as done, changes mark to checked and adds @done + time
* CTRL+D again will put it back in TODO (open) mode, changes mark and removes @done + time
* CTRL+SHIFT+D marks a task as in pending, changes mark and adds @pending + time
* CTRL+SHIFT+D again will put it back in TODO (open) mode, changes mark and removes @pending + time
* CTRL+M will mark the task as cancelled, changes mark and adds @cancelled + time
* CTRL+M again will put it back in TODO (open) mode, changes mark and remove @cancelled + time
* CTRL+SHIFT+S will archive all tasks, note there two methods to do this which you can define in the [Settings](#settings)

* Alt+T will add the @today tag at the end of the task
* Alt+S will add the @start tag + time at the end of the task
* Alt+S again will remove @start tag + time from the task

**Tags**

todo-pt uses the following default @tags:

* @cancelled
* @done
* @start
* @time - if you add a @start tag and later mark the task as @done the @time tag is automatically added as calculating the time spent on task
* @today
* @pending (task is done but awaiting confirmation)

These tags can be easily changed, see settings.

### Hotstrings

* -- followed by TAB will insert a divider line --- ✄ ------------------------------

## Settings

All settings are stored in the <code>objTodo</code> object. Most settings are self explanatory
and are only briefly addressed here:

**marks & texts**

* mark_[open, done, pending, cancelled, project]: "Icons" used to indicate the status of a task
* mark_indent: depending on your preference you can use to enable/disable automatic indentation of new tasks
* text_[done, pending, cancelled, today, start, time]: @tags used to mark the status of tasks
* text_[line, archive]: text used to display a divider line and archive indicator

**hotkeys**

* hotkey_...[done, pending, cancel, new, start, today, archive, make_task, new_project]: hotkeys to manage tasks and projects
* hotkey_getline: for some editors ^x will suffice

**date & time**

* date_format: You can specify the date/time format as described [here](http://ahkscript.org/docs/commands/FormatTime.htm). Note that Date and Time Formats are case sensitive
* date_options_us: Set date_options_us to 1 if the above date_format is in American date/time format
* date_options_units: "m" ; The time in minutes spent on a task is converted into hours:minutes format so it is advised not to alter this
* date_options_params: Params can be W,D,B,H,M,S - this will allow you to specify weeks, days etc to include and exclude in the @time calculation

## Syntax highlighting

If your editor supports [syntax highlighting](http://en.wikipedia.org/wiki/Syntax_highlighting) you could
develop a language file to highlight projects and @tags. Some examples:

* TODO :-)

Please consult your text editors documentation for instructions on how to install and apply syntax highlighting.

## Credits

* [Allen Bargi](https://github.com/aziz/) for the [PlainTasks](https://github.com/aziz/PlainTasks) plugin for Sublime Text
* [formivore](http://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/page-5#entry561591) for modified version of [DateParse() by polyethene](https://github.com/polyethene/AutoHotkey-Scripts/blob/master/DateParse.ahk)
* [HotKeyIt](http://www.autohotkey.net/~HotKeyIt/) for [Time()](http://www.autohotkey.com/board/topic/42668-time-count-days-hours-minutes-seconds-between-dates/)

## Alternatives (in AutoHotkey)

* [todo.txt-ahk](https://github.com/jdiamond/todo.txt-ahk)
* [YATL - Yet Another Todo List](https://github.com/melvincarvalho/yatl)
* [To-Do List / Reminders](http://www.autohotkey.com/board/topic/57455-to-do-list-reminders/)
* [AHK ToDo-List v0.4.0](http://www.autohotkey.com/board/topic/2878-ahk-todo-list-v040/)

## License

Licensed under the MIT License, see [copying.txt](COPYING.TXT)

## Demo

![Quick demo](https://raw.github.com/hi5/_resources/master/todo-pt-demo.gif)

