#Delphi
![Oracle of Delphi](./delphi.jpg)

Delphi is where Apollo slained the dragon **Python** and founded his own temple. Those who are wondering about their life are welcomed to Delphi to discover his past and future. You can find out the future of your **Python** code as well using Delphi.

---

##Rationale

There are two ways to write python code. By using the `batch mode` and the `interactive mode`. 

`Batch mode`, or whatever you might call it, is the most common way to execute a python scrpipt just by running `python file.py`. However, it can frustrating to have a **change-close-execute-open-change-close-execute** cycle.

`Interactive mode` is responsive, it shows you the result right away. But it quickly becomes unmanageable as soon as you have more than one function or a few variables.

**Delphi** gives you a third option to write your python code. The idea is similar to Apple's [Playground](https://developer.apple.com/swift/blog/?id=24). Though not as fancy, I believe it is incredibly useful.

---

##Demo

Nothing illustrates better than a video.
(The video is included in the repo, see **delphi.mp4**)

---

##Install
Delphi Depends on:

* [Pathogen](https://github.com/tpope/vim-pathogen)
* [vim-addon-background-cmd](https://github.com/MarcWeber/vim-addon-background-cmd), which depends on:
	* [vim-addon-mw-utils](https://github.com/MarcWeber/vim-addon-mw-utils)
	* [vim-addon-manager](https://github.com/MarcWeber/vim-addon-manager)
* A vim with **client-server** function. You can check whether it does by executing `vim --version | grep "clientserver"`, if it gives you something like `+clientserver` then you are good to go. If you see `-clientserver`, then you might have to install another version.
	* on Mac OS you can use homebrew.
___

##Contribute

If you have any thoughts about this project, please let me know! If you like **Delphi** let's work on making it more robust and powerful.