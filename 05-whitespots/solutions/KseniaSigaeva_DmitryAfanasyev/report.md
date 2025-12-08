# Case "whitespots" report

## Little preview

First of all, sorry for my English. I'm not used to making reports in another language and, actually, I'm looking forward to this experience. 
It gives me the vibe of English essay when you write whatever ypu want and, basically, that's what I'm about to do.

For this case I have visited inview club workshop where I've learnt a little bit about vulnerabilities, security, docker and whitespots. I also have tried to accomplish all the tasks with the great help of the devops guys.

## AppSec Portal and Auditor installation and setup

### Auditor 

I've cloned this repo ```https://gitlab.inview.team/whitespots-public-fork/auditor.git``` and executed the command ```docker compose up -d``` (this thing creates container as I guess). Then I've generated ACCESS TOKEN and restarted the container.

<img width="1280" height="725" alt="image" src="https://github.com/user-attachments/assets/131b6bbe-a759-4279-ba01-924523900fbf" />

### AppSec Portal

Approximately somewhere here I understood that it's better to work in wsl directly than in Docker App.
I've cloned ```https://gitlab.inview.team/whitespots-public-fork/appsec-portal.git``` and ran these:
- ```./set_vars.sh```
- ```echo IMAGE_VERSION=release_v25.11.3 >> .env```
- ```sh run.sh```
- ```docker compose exec back python3 manage.py createsuperuser --username admin``` (fun fact: you do not have to type in your actual email and password - you just have to create it)

Then I had to go there ```127.0.0.1:80 ``` and activate license. Unfortunately, it seems that I wouldn't be able to do it again cause license is one time thing in their opinion.

<img width="948" height="291" alt="image" src="https://github.com/user-attachments/assets/f77516dc-5606-432e-bef3-5ada3411cc16" />

Actually this site has quite nice interface even though not very user-friendly.
So I've started my journey in this app, precisely in Auditor - Config. Here I added auditor address ```http://host.docker.internal:8080/``` and ACCESS TOKEN and
changed Internal Portal URL on ```http://host.docker.internal/```.

### Keys 

I added private key in this app. I've generated it (and public as well) in wsl with ```ssh-keygen```.

<img width="1989" height="1084" alt="image" src="https://github.com/user-attachments/assets/e39d1619-ae8e-475a-8bc9-039e049993e2" />

Public key:
<img width="2617" height="122" alt="image" src="https://github.com/user-attachments/assets/5e06f9fd-00d6-40b4-bc3c-6d8ed886a3e7" />

I am not gonna show you another one cause you know it is private (and privacy is super important!!!)

The public key I added to the Gitlab SSH Keys (I had to register in it)

<img width="3299" height="1872" alt="image" src="https://github.com/user-attachments/assets/cfa1c684-f68b-405f-b9ed-8d59f70c3752" />

### Adding repository and scanning

So I continued travelling around the app and got into Assets - Repositories tab. Here I added this rep https://gitlab.com/whitespots-public/vulnerable-apps and started audit. 
At first, some mistakes have occured and after 6 minutes of waiting nothing happened. Nevertheless, second trial was a little bit more successful. Pipeline ended and jobs were done.

<img width="1280" height="782" alt="image" src="https://github.com/user-attachments/assets/6f908316-b203-4c3a-9046-9b2ab053cd66" />

It was pretty naive but I thought that if everything is marked with green checkmarks that it means that everything is good. How wrong was I...

## END

Actually, nothing was good. Some severe mistakes got in the process. Organizators of the club kindly told me (and some other unlucky guys with the same problem) that they can't solve this "now" and, probably, at all...
They have promised to write to the WhiteSpots founders (or developers) with this concrete problem. Apparently, they have a connection with them (what a cool guys!). 

That was the moment when I learnt that WhiteSpots is a startup and currently in a state of development... so it is ok to have problems.. (I'm doing my lab - it is not okay at all!!!)

I'm not sure that I will be able to continue the accomplishment of this case. However, I'm happy that you've read it and now know my interesting and a little bit sad story.
