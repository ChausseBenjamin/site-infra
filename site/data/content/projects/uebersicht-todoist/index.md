---
title: "Todoist Task Viewer"
date: 2023-10-23T23:20:05-04:00
draft: true
---

Back in 2018, I daily drove a mac and I really wanted my daily tasks
to always be visible. Having learned about the uebersicht desktop app,
I decided to write a task visualizer (available offline) that interacted
with the Todoist API.

[Todoist][1] is pretty great, it's an extensible task management software which
runs on a variety of platforms: Desktop mac, windows, and linux, browser email
extensions, iOS & Android. Up until very recently, I have continued to use this
task manager in my daily life (albeit with different tools & plugins such as
[Todoist.Nvim][2]. As of the writing of this short article I now use a more
custom workflow with [neorg][3]. But I still consider this little tool I built
to be quite nifty as many people actually downloaded it and daily drove it.

Back then my train of thought was as follows:

> if I don't see a task, I might never do it.

Having my tasks always there on my Desktop seemed like a great way to get more
productive. To accomplish this, I discovered a nifty little tool called
[uebersicht][4] which allows to render coffeescript snippets directly on the
mac's desktop (which I daily drove at the time). Althought the rendering was
done with coffeescript, it did allow to run the logical of my snippet in
whichever language I prefered. As I was only beggining to code a bit more
seriously, I chose to do that part in a language I knew, Python.

These were the goals I initially set for this little applet:

- It must show a specific project (since the inbox is a project in itself)
- It must not break whenever the computer comes offline
- Task priorities must be visible through the color of the task

And so, this is what my python code looked like:

```python
# -*-coding:utf-8 -*
import online
import pickle
import os

def main():
  with open('todoist_API.txt') as f:
    # Token must be the first line
    token = f.readline()

  if online.main() == False:
    with open("todoist.cache", "rb") as myFile:
      loaded_cache = pickle.load(myFile)
    # Rank used to display a numbered list
    rank = 0
    for i in loaded_cache: # all the items in todoist
      if i['project_id'] == 170911352: # if item is in "inbox"
        if i['checked'] == 0:  # if item is incomplete
          if i['priority'] == 1:
            pri = "<p class='priority4'>"
          elif i['priority'] == 2:
            pri = "<p class='priority3'>"
          elif i['priority'] == 3:
            pri = "<p class='priority2'>"
          elif i['priority'] == 4:
            pri = "<p class='priority1'>"
          rank += 1
          print(pri, "<b>", rank, '- </b>',
              i['content'], "</p>")  # name and id


  elif online.main() == True:
    from todoist.api import TodoistAPI
    api = TodoistAPI(token)
    api.sync()  # initial sync

    if os.path.exists("todoist.cache"):  # Delete old cache
      os.remove("todoist.cache")
    open("todoist.cache", 'a').close()  # Initialise new cache
    # https://stackoverflow.com/questions/17322273
    with open("todoist.cache", "wb") as myFile:
      pickle.dump(api.state['items'], myFile)

    rank = 0
    for i in api.state['items']: # all the items in todoist
      if i['project_id'] == 170911352: # if item is "inbox"
        if i['checked'] == 0:  # if item is incomplete
          if i['priority'] == 1:
            pri = "<p class='priority4'>"
          elif i['priority'] == 2:
            pri = "<p class='priority3'>"
          elif i['priority'] == 3:
            pri = "<p class='priority2'>"
          elif i['priority'] == 4:
            pri = "<p class='priority1'>"
          rank += 1
          print(pri, "<b>", rank, '- </b>',
              i['content'], "</p>")  # name and id

if __name__ == '__main__':
  main()
```

I did need to verify if the computer was online, and I did this with quite a minimal (and naive)
package which I wrote. Here it is:

```python
# -*-coding:utf-8 -*
from urllib.error import URLError
import urllib.request

def main():
  loop_value = 0
  # Gives up on trying to connect after 6 failed attempts
  while loop_value < 5:
    try:
      urllib.request.urlopen("http://www.google.com")
      loop_value = 6
    except URLError as e:
      loop_value += 1
  if loop_value == 6:
    return(True)
  else:
    return(False)

if __name__ == '__main__':
  main()
```

Albeit simple, here is the final result:

![Todo visual demo](./demo.jpg)

As mentionned, it is quite simple. But that was by design. I used a couple of
other widgets in conjuction with this one. And with a bit of fiddling, this is
the result I daily drove on my machine for quite some time:

![Todo widget in a greater context](./overview.jpg)

[1]: https://todoist.com
[2]: https://github.com/romgrk/todoist.nvim
[3]: https://github.com/nvim-neorg/neorg
[4]: https://tracesof.net/uebersicht
