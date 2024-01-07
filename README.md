[![output-onlinepngtools.png](https://i.postimg.cc/44Sdxk8L/output-onlinepngtools.png)](https://postimg.cc/xqLY67VM)
# GoBox

A ready-to-go dialog box for use in Godot engine 4.2

[![Screenshot-2023-12-25-225813.png](https://i.postimg.cc/KzJFdHQL/Screenshot-2023-12-25-225813.png)](https://postimg.cc/2bbPWTs8)

## Description
This plugin will add a new node called DialogBox.
By default, the dialog box will wait for ui_accept. This can be changed in DialogBox.gd.
The user can hold the ui_accept button to fast forward through the dialog.

### Usage
* After enabling the plugin, create a canvas layer, and then add the DialogBox node as a child of the canvas layer
* See the functions and signals below for usage

### Signals
* dialog_complete - Signal emitted when all dialog has been parsed through by the user

### Functions
* get_history() - Returns history as a string of text
* clear_history() - Clears current history
* set_input_disabled(disabled: bool) - Box will accept input based on whether it is true or false
* set_actor_name(name: String) - Sets the name that will appear over the box. Set blank if no name is desired.
* queue_lines() - Queues any number of lines to go into an animation cycle of the box. If the text does not fit, it will automatically be broken up for the current cycle.

The dialog box has a configurable speed and some public variables for use such as history and input_disabled.
You may also want to use the dialog_complete signal which only emits once the user has gone through all dialog inside the box.
When the plugin is enabled you should be able to add it to a scene as a new node.

If you wish to make changes to the style of the box you may modify the DialogRig.tscn file.

## Authors

Koris

## License

This project is licensed under the MIT License
